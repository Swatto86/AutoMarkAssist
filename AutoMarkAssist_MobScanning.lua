-- AutoMarkAssist_MobScanning.lua
-- Mob filtering, zone database, mark allocation, visible mark sync,
-- mark assignment entry point, and rebalance-after-death logic.
-- Loaded after AutoMarkAssist_Core.lua.

local AMA = AutoMarkAssist

-- ============================================================
-- FILE-SCOPE CONSTANTS
-- ============================================================

local MARK_SKULL    = 8
local MARK_CROSS    = 7
local MARK_NONE     = 0

local MARK_SOURCE_LOCAL    = "local"
local MARK_SOURCE_OBSERVED = "observed"

-- ============================================================
-- RANGE CHECKS
-- ============================================================

local function IsUnitInRange(unitToken, rangeIdx)
    if rangeIdx == 2 then rangeIdx = 3 end
    local ok, result = pcall(CheckInteractDistance, unitToken, rangeIdx or 4)
    if not ok then return false end
    return result == 1 or result == true
end

function AMA.IsUnitInAutoMarkRange(unitToken)
    local mode = AMA.GetMarkingMode()
    if mode == "manual" or mode == "mouseover" then return true end
    return IsUnitInRange(unitToken, AutoMarkAssistDB and AutoMarkAssistDB.proximityRange or 4)
end

-- ============================================================
-- ZONE DATABASE
-- ============================================================

function AMA.ResolveZoneName(rawZone)
    if not rawZone or rawZone == "" then return rawZone end
    if AutoMarkAssist_ZoneAliases and AutoMarkAssist_ZoneAliases[rawZone] then
        return AutoMarkAssist_ZoneAliases[rawZone]
    end
    return rawZone
end

--- Build a merged mob→mark table for the given zone.
--- Player overrides (mobMarks) win over static DB entries.
function AMA.BuildZoneMobDB(zoneName)
    if not zoneName or zoneName == "" then return nil end

    local baseMobs = AutoMarkAssist_MobDB and AutoMarkAssist_MobDB[zoneName]
    local playerMobs = AutoMarkAssistDB and AutoMarkAssistDB.mobMarks
                       and AutoMarkAssistDB.mobMarks[zoneName]

    if not baseMobs and not playerMobs then return nil end

    local merged = {}
    if baseMobs then
        for mob, mark in pairs(baseMobs) do merged[mob] = mark end
    end
    if playerMobs then
        for mob, mark in pairs(playerMobs) do merged[mob] = mark end
    end

    if next(merged) == nil then return nil end
    return merged
end

--- Look up the preferred mark for a mob in the current zone.
--- Returns: markIdx (number), "SKIP", or nil (no preference).
function AMA.LookupMobMark(mobName)
    if not mobName then return nil end

    -- Player overrides first.
    local zone = AMA.currentZoneName
    if zone and AutoMarkAssistDB and AutoMarkAssistDB.mobMarks then
        local playerMobs = AutoMarkAssistDB.mobMarks[zone]
        if playerMobs and playerMobs[mobName] ~= nil then
            return playerMobs[mobName]
        end
    end

    -- Static DB.
    if AMA.currentZoneMobDB and AMA.currentZoneMobDB[mobName] ~= nil then
        return AMA.currentZoneMobDB[mobName]
    end

    return nil
end

--- Save a player mark preference for a mob in the current zone.
function AMA.SetPlayerMobMark(zoneName, mobName, markIdx)
    if not AutoMarkAssistDB then return end
    if not zoneName or not mobName then return end
    if not AutoMarkAssistDB.mobMarks then AutoMarkAssistDB.mobMarks = {} end
    if not AutoMarkAssistDB.mobMarks[zoneName] then
        AutoMarkAssistDB.mobMarks[zoneName] = {}
    end
    AutoMarkAssistDB.mobMarks[zoneName][mobName] = markIdx
end

--- Clear all player overrides for a zone.
function AMA.ClearPlayerMobMarks(zoneName)
    if not AutoMarkAssistDB or not AutoMarkAssistDB.mobMarks then return end
    AutoMarkAssistDB.mobMarks[zoneName] = nil
end

--- Get the merged mob DB for a zone (for UI display).
--- Returns: { { name, mark, isOverride }, ... } sorted by name.
function AMA.GetZoneMobList(zoneName)
    if not zoneName or zoneName == "" then return {} end

    local baseMobs = AutoMarkAssist_MobDB and AutoMarkAssist_MobDB[zoneName]
    local playerMobs = AutoMarkAssistDB and AutoMarkAssistDB.mobMarks
                       and AutoMarkAssistDB.mobMarks[zoneName]

    local byName = {}
    if baseMobs then
        for mob, mark in pairs(baseMobs) do
            byName[mob] = { mark = mark, isOverride = false }
        end
    end
    if playerMobs then
        for mob, mark in pairs(playerMobs) do
            byName[mob] = { mark = mark, isOverride = true }
        end
    end

    local list = {}
    for mob, info in pairs(byName) do
        list[#list + 1] = { name = mob, mark = info.mark, isOverride = info.isOverride }
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

-- ============================================================
-- MOB FILTERING
-- ============================================================

local function IsMarkableTarget(unitToken)
    local name = UnitName(unitToken)
    if not name or name == "" then return false end

    if AutoMarkAssistDB and AutoMarkAssistDB.skipCritters then
        local ctype = UnitCreatureType and UnitCreatureType(unitToken)
        if ctype == "Critter" then return false end
    end

    local pref = AMA.LookupMobMark(name)
    if pref == "SKIP" then return false end

    return true, name
end

-- ============================================================
-- MARK ALLOCATION
-- ============================================================

local function ValidateOwner(guid)
    if not guid then return nil end
    for _, t in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(t) and UnitGUID(t) == guid then
            if UnitIsDead and UnitIsDead(t) then return nil end
            return t
        end
    end
    return nil
end

local function IsMarkSlotFree(markIdx)
    local ownerGuid = AMA.markOwners[markIdx]
    if not ownerGuid then return true end
    local token = ValidateOwner(ownerGuid)
    if not token then
        AMA.ForgetMark(ownerGuid)
        return true
    end
    return false
end

--- Find a CC mark for a creature type based on group composition.
local function FindCCMark(creatureType)
    if not creatureType or creatureType == "" then return nil end
    local reserved = AMA.GetReservedCCMarks()
    for markIdx, ability in pairs(reserved) do
        if ability.creatureTypes[creatureType] and IsMarkSlotFree(markIdx) then
            return markIdx
        end
    end
    return nil
end

--- Core allocation: DB preference → kill marks → CC by creature type → any.
local function AllocateMark(unitToken, mobName)
    -- 1. DB preference: if the mob has a preferred mark, try it.
    local preferred = AMA.LookupMobMark(mobName)
    if type(preferred) == "number" and preferred >= 1 and preferred <= 8 then
        if AMA.IsMarkEnabled(preferred) and IsMarkSlotFree(preferred) then
            return preferred
        end
        -- Preferred mark unavailable; fall through to FCFS.
    end

    -- 2. Kill marks (Skull → Cross) — first come, first served.
    for _, m in ipairs(AMA.KILL_MARKS) do
        if AMA.IsMarkEnabled(m) and IsMarkSlotFree(m) then
            return m
        end
    end

    -- 3. CC by creature type + group composition.
    local ctype = unitToken and UnitCreatureType and UnitCreatureType(unitToken)
    local ccMark = FindCCMark(ctype)
    if ccMark then return ccMark end

    -- 4. Any remaining enabled mark (ordered: kill, then CC, then rest).
    local reserved = AMA.GetReservedCCMarks()
    for _, m in ipairs(AMA.ALL_MARKS_ORDERED) do
        if AMA.IsMarkEnabled(m) and not reserved[m] and IsMarkSlotFree(m) then
            return m
        end
    end

    -- 5. Spill into reserved CC marks if all non-CC marks are taken.
    for markIdx in pairs(reserved) do
        if IsMarkSlotFree(markIdx) then return markIdx end
    end

    return nil
end

-- ============================================================
-- SYNC VISIBLE MARKS
-- ============================================================

function AMA.SyncVisibleMarks()
    local seenGuids = {}

    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token) and UnitCanAttack("player", token) then
            local isDead = UnitIsDead and UnitIsDead(token)
            local guid = UnitGUID and UnitGUID(token)
            local visibleMark = GetRaidTargetIndex and GetRaidTargetIndex(token) or 0

            if guid then
                local trackedMark = AMA.markedGUIDs[guid]

                if isDead then
                    if trackedMark then
                        AMA.ForgetMark(guid)
                    end
                else
                    seenGuids[guid] = true

                    if visibleMark and visibleMark > 0 then
                        local prevOwner = AMA.markOwners[visibleMark]
                        if prevOwner and prevOwner ~= guid then
                            AMA.ForgetMark(prevOwner)
                        end

                        if not trackedMark then
                            AMA.markedGUIDs[guid] = visibleMark
                            AMA.markOwners[visibleMark] = guid
                            AMA.markTokens[visibleMark] = token
                            AMA.guidMarkSource[guid] = MARK_SOURCE_OBSERVED
                        elseif trackedMark ~= visibleMark then
                            AMA.ForgetMark(guid)
                            AMA.markedGUIDs[guid] = visibleMark
                            AMA.markOwners[visibleMark] = guid
                            AMA.markTokens[visibleMark] = token
                            AMA.guidMarkSource[guid] = MARK_SOURCE_OBSERVED
                        else
                            AMA.markTokens[visibleMark] = token
                        end
                    elseif trackedMark and trackedMark > 0 then
                        AMA.ForgetMark(guid)
                    end
                end
            end
        end
    end

    local staleGuids = {}
    for guid in pairs(AMA.markedGUIDs) do
        if not seenGuids[guid] then
            staleGuids[#staleGuids + 1] = guid
        end
    end
    for _, guid in ipairs(staleGuids) do
        AMA.ForgetMark(guid)
    end
end

-- ============================================================
-- ASSIGN MARK (main entry point for auto-marking)
-- ============================================================

function AMA.AssignMark(unitToken, force, source)
    if not UnitExists(unitToken) then return end
    if not UnitCanAttack("player", unitToken) then return end
    if UnitIsDead and UnitIsDead(unitToken) then return end

    local guid = UnitGUID and UnitGUID(unitToken)
    if not guid then return end

    if AMA.markedGUIDs[guid] and not force then return end

    if not AMA.IsUnitInAutoMarkRange(unitToken) then return end

    local isValid, mobName = IsMarkableTarget(unitToken)
    if not isValid then return end

    local markIdx = AllocateMark(unitToken, mobName)
    if not markIdx then return end

    local applied, reason = AMA.TrySetRaidTarget(unitToken, markIdx)
    if not applied then
        AMA.VPrint(string.format("Failed to mark %s: %s",
            mobName or "?", reason or "unknown"))
        return
    end

    AMA.RecordMark(guid, markIdx, unitToken)
    AMA.VPrint(string.format("Marked %s -> %s (%s)",
        mobName or "?",
        AMA.MARK_NAMES[markIdx] or tostring(markIdx),
        source or "auto"))
end

-- ============================================================
-- RESET STATE
-- ============================================================

function AMA.ResetState()
    local marksToClear = {}
    for markIdx in pairs(AMA.markOwners) do
        marksToClear[markIdx] = true
    end

    local clearedMarks = {}
    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token) then
            local visibleMark = GetRaidTargetIndex and GetRaidTargetIndex(token) or 0
            if visibleMark > 0 and marksToClear[visibleMark] and not clearedMarks[visibleMark] then
                pcall(SetRaidTarget, token, 0)
                clearedMarks[visibleMark] = true
            end
        end
    end

    local playerMark = GetRaidTargetIndex and GetRaidTargetIndex("player")
    local bouncedAny = false

    for markIdx in pairs(marksToClear) do
        if not clearedMarks[markIdx] then
            pcall(SetRaidTarget, "player", markIdx)
            pcall(SetRaidTarget, "player", 0)
            bouncedAny = true
        end
    end

    if bouncedAny and playerMark and not marksToClear[playerMark] then
        pcall(SetRaidTarget, "player", playerMark)
    end

    wipe(AMA.markedGUIDs)
    wipe(AMA.markOwners)
    wipe(AMA.markTokens)
    wipe(AMA.guidMarkSource)
    AMA.pullMarkCount = 0
end

function AMA.ResetWithMessage()
    AMA.ResetState()
    if AutoMarkAssistDB and AutoMarkAssistDB.verbose then
        AMA.Print("All marks cleared.")
    end
end

-- ============================================================
-- REBALANCE AFTER DEATH
-- ============================================================

local function ResolveToken(guid, cachedToken)
    if cachedToken and UnitExists(cachedToken) and UnitGUID(cachedToken) == guid then
        if not (UnitIsDead and UnitIsDead(cachedToken)) then
            return cachedToken
        end
        return nil
    end
    return ValidateOwner(guid)
end

function AMA.CascadeMarksAfterDeath()
    if AMA.GetMarkingMode() == "manual" then return end
    if AMA.IsCombatMarkLockActive() then return end

    if AMA.IsMarkEnabled(MARK_SKULL) and IsMarkSlotFree(MARK_SKULL) then
        if AMA.IsMarkEnabled(MARK_CROSS) and AMA.markOwners[MARK_CROSS] then
            local crossGuid = AMA.markOwners[MARK_CROSS]
            local crossToken = ResolveToken(crossGuid, AMA.markTokens[MARK_CROSS])

            if crossToken then
                AMA.ForgetMark(crossGuid)
                local applied = AMA.TrySetRaidTarget(crossToken, MARK_SKULL)
                if applied then
                    AMA.RecordMark(crossGuid, MARK_SKULL, crossToken)
                    AMA.VPrint("Promoted Cross to Skull: " .. (UnitName(crossToken) or "?"))
                end
            else
                AMA.ForgetMark(crossGuid)
            end
        end
    end

    if AMA.IsMarkEnabled(MARK_CROSS) and IsMarkSlotFree(MARK_CROSS) then
        local bestMark, bestGuid, bestToken = nil, nil, nil

        for m = 1, 6 do
            local ownerGuid = AMA.markOwners[m]
            if ownerGuid then
                local token = ResolveToken(ownerGuid, AMA.markTokens[m])
                if token then
                    bestMark = m
                    bestGuid = ownerGuid
                    bestToken = token
                    break
                else
                    AMA.ForgetMark(ownerGuid)
                end
            end
        end

        if bestMark and bestToken then
            local oldMarkName = AMA.MARK_NAMES[bestMark] or tostring(bestMark)
            AMA.ForgetMark(bestGuid)
            local applied = AMA.TrySetRaidTarget(bestToken, MARK_CROSS)
            if applied then
                AMA.RecordMark(bestGuid, MARK_CROSS, bestToken)
                AMA.VPrint("Promoted " .. oldMarkName .. " to Cross: " .. (UnitName(bestToken) or "?"))
            end
        end
    end
end
