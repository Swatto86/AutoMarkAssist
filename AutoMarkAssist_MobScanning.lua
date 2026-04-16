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

--- Normalise a mob DB entry to { mark, creatureType, ccImmune } or "SKIP".
--- Handles plain-number entries (static DB, legacy player overrides)
--- and the new table format.
local function NormaliseMobEntry(entry)
    if entry == "SKIP" then return "SKIP" end
    if type(entry) == "number" then
        return { mark = entry, creatureType = nil, ccImmune = false }
    end
    if type(entry) == "table" and entry.mark then
        return {
            mark = entry.mark,
            creatureType = entry.creatureType or nil,
            ccImmune = entry.ccImmune or false,
        }
    end
    return nil
end

--- Build a merged mob→entry table for the given zone.
--- Player overrides (mobMarks) win over static DB entries.
function AMA.BuildZoneMobDB(zoneName)
    if not zoneName or zoneName == "" then return nil end

    local baseMobs = AutoMarkAssist_MobDB and AutoMarkAssist_MobDB[zoneName]
    local playerMobs = AutoMarkAssistDB and AutoMarkAssistDB.mobMarks
                       and AutoMarkAssistDB.mobMarks[zoneName]

    if not baseMobs and not playerMobs then return nil end

    local merged = {}
    if baseMobs then
        for mob, entry in pairs(baseMobs) do merged[mob] = NormaliseMobEntry(entry) end
    end
    if playerMobs then
        for mob, entry in pairs(playerMobs) do merged[mob] = NormaliseMobEntry(entry) end
    end

    if next(merged) == nil then return nil end
    return merged
end

--- Look up the preferred mark and creature type for a mob.
--- Returns: { mark, creatureType }, "SKIP", or nil.
function AMA.LookupMobMark(mobName)
    if not mobName then return nil end

    -- Player overrides first.
    local zone = AMA.currentZoneName
    if zone and AutoMarkAssistDB and AutoMarkAssistDB.mobMarks then
        local playerMobs = AutoMarkAssistDB.mobMarks[zone]
        if playerMobs and playerMobs[mobName] ~= nil then
            return NormaliseMobEntry(playerMobs[mobName])
        end
    end

    -- Static DB.
    if AMA.currentZoneMobDB and AMA.currentZoneMobDB[mobName] ~= nil then
        return AMA.currentZoneMobDB[mobName]
    end

    return nil
end

--- Save a player mark preference + creature type for a mob.
--- If creatureType is nil, preserves any previously stored creature type.
--- If ccImmune is nil, preserves any previously stored ccImmune flag.
function AMA.SetPlayerMobMark(zoneName, mobName, markIdx, creatureType, ccImmune)
    if not AutoMarkAssistDB then return end
    if not zoneName or not mobName then return end
    if not AutoMarkAssistDB.mobMarks then AutoMarkAssistDB.mobMarks = {} end
    if not AutoMarkAssistDB.mobMarks[zoneName] then
        AutoMarkAssistDB.mobMarks[zoneName] = {}
    end
    if markIdx == "SKIP" then
        AutoMarkAssistDB.mobMarks[zoneName][mobName] = "SKIP"
    else
        -- Preserve existing fields if not provided.
        -- Pass false to explicitly clear a field; nil means "keep existing".
        local existing = AutoMarkAssistDB.mobMarks[zoneName][mobName]
        if type(existing) == "table" then
            if creatureType == nil and existing.creatureType then
                creatureType = existing.creatureType
            end
            if ccImmune == nil and existing.ccImmune then
                ccImmune = existing.ccImmune
            end
        end
        -- Normalise false back to nil for storage.
        if creatureType == false then creatureType = nil end
        if ccImmune == false then ccImmune = false end
        AutoMarkAssistDB.mobMarks[zoneName][mobName] = {
            mark = markIdx,
            creatureType = creatureType or nil,
            ccImmune = ccImmune or false,
        }
    end
end

--- Clear all player overrides for a zone.
function AMA.ClearPlayerMobMarks(zoneName)
    if not AutoMarkAssistDB or not AutoMarkAssistDB.mobMarks then return end
    AutoMarkAssistDB.mobMarks[zoneName] = nil
end

--- Get the merged mob DB for a zone (for UI display).
--- Returns: { { name, mark, creatureType, isOverride }, ... } sorted by name.
function AMA.GetZoneMobList(zoneName)
    if not zoneName or zoneName == "" then return {} end

    local baseMobs = AutoMarkAssist_MobDB and AutoMarkAssist_MobDB[zoneName]
    local playerMobs = AutoMarkAssistDB and AutoMarkAssistDB.mobMarks
                       and AutoMarkAssistDB.mobMarks[zoneName]

    local byName = {}
    if baseMobs then
        for mob, raw in pairs(baseMobs) do
            local entry = NormaliseMobEntry(raw)
            if entry and entry ~= "SKIP" then
                byName[mob] = { mark = entry.mark, creatureType = entry.creatureType, isOverride = false }
            elseif entry == "SKIP" then
                byName[mob] = { mark = "SKIP", creatureType = nil, isOverride = false }
            end
        end
    end
    if playerMobs then
        for mob, raw in pairs(playerMobs) do
            local entry = NormaliseMobEntry(raw)
            if entry and entry ~= "SKIP" then
                byName[mob] = { mark = entry.mark, creatureType = entry.creatureType, isOverride = true }
            elseif entry == "SKIP" then
                byName[mob] = { mark = "SKIP", creatureType = nil, isOverride = true }
            end
        end
    end

    local list = {}
    for mob, info in pairs(byName) do
        list[#list + 1] = { name = mob, mark = info.mark, creatureType = info.creatureType, isOverride = info.isOverride }
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
    if type(pref) == "table" and pref.mark == "SKIP" then return false end

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
--- Returns nil if the mob is CC-immune.
local function FindCCMark(creatureType, ccImmune)
    if ccImmune then return nil end
    if not creatureType or creatureType == "" then return nil end
    local reserved = AMA.GetReservedCCMarks()
    for markIdx, ability in pairs(reserved) do
        if ability.creatureTypes[creatureType] and IsMarkSlotFree(markIdx) then
            return markIdx
        end
    end
    return nil
end

--- Core allocation: assigns marks based on dungeon difficulty and group
--- composition.  CC marks are ONLY assigned when the CC ability can
--- actually work on the mob's creature type.  No spill.
---
--- Normal:  DB pref → Skull → Cross → CC (creature type)
--- Heroic:  DB pref → Skull → CC (creature type) → Cross
local function AllocateMark(unitToken, mobName)
    local reserved = AMA.GetReservedCCMarks()
    local heroic = AMA.IsHeroicDifficulty()

    -- Resolve creature type: prefer live data, fall back to stored DB entry.
    local ctype = unitToken and UnitCreatureType and UnitCreatureType(unitToken)
    local dbEntry = AMA.LookupMobMark(mobName)
    local storedCtype = type(dbEntry) == "table" and dbEntry.creatureType or nil
    local ccImmune = type(dbEntry) == "table" and dbEntry.ccImmune or false
    local effectiveCtype = ctype or storedCtype

    -- 1. DB preference: if the mob has a preferred mark, try it.
    --    For CC marks, validate the creature type is compatible and mob is not CC-immune.
    local preferred = type(dbEntry) == "table" and dbEntry.mark or nil
    if type(preferred) == "number" and preferred >= 1 and preferred <= 8 then
        if AMA.IsMarkAvailable(preferred, reserved) and IsMarkSlotFree(preferred) then
            local ccAbility = reserved[preferred]
            if not ccAbility then
                -- Kill mark — always valid.
                return preferred
            elseif not ccImmune and effectiveCtype and ccAbility.creatureTypes[effectiveCtype] then
                return preferred
            end
        end
    end

    -- 2. Skull is always first.
    if AMA.IsMarkEnabled(MARK_SKULL) and IsMarkSlotFree(MARK_SKULL) then
        return MARK_SKULL
    end

    -- 3. Normal: Cross before CC.  Heroic: CC before Cross.
    if not heroic then
        if AMA.IsMarkEnabled(MARK_CROSS) and IsMarkSlotFree(MARK_CROSS) then
            return MARK_CROSS
        end
    end

    -- 4. CC by creature type + group composition (skip if CC-immune).
    local ccMark = FindCCMark(effectiveCtype, ccImmune)
    if ccMark then return ccMark end

    -- 5. Heroic: Cross comes last.
    if heroic then
        if AMA.IsMarkEnabled(MARK_CROSS) and IsMarkSlotFree(MARK_CROSS) then
            return MARK_CROSS
        end
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

    -- Runtime capture: enrich the player overlay DB with creature type if
    -- the static/player DB is missing it.
    local inInstance = IsInInstance and IsInInstance()
    local zone = AMA.currentZoneName
    if inInstance and zone and zone ~= "" and mobName then
        local liveCtype = UnitCreatureType and UnitCreatureType(unitToken)
        if liveCtype then
            local dbEntry = AMA.LookupMobMark(mobName)
            local storedCtype = type(dbEntry) == "table" and dbEntry.creatureType or nil
            if not storedCtype then
                local storedMark = type(dbEntry) == "table" and dbEntry.mark or markIdx
                AMA.SetPlayerMobMark(zone, mobName, storedMark, liveCtype)
                AMA.currentZoneMobDB = AMA.BuildZoneMobDB(zone)
            end
        end
    end

    AMA.VPrint(string.format("Marked %s -> %s (%s)",
        mobName or "?",
        AMA.MARK_NAMES[markIdx] or tostring(markIdx),
        source or "auto"))
end

-- ============================================================
-- RUNTIME CC IMMUNITY DETECTION
-- Called from the combat log handler when a CC spell is IMMUNE.
-- ============================================================

-- Spell IDs of CC abilities we track for immunity detection.
AMA.CC_SPELL_IDS = {
    -- Polymorph variants
    [118]   = true, [12824] = true, [12825] = true, [12826] = true,
    [28271] = true, [28272] = true, [61305] = true, [61025] = true,
    [61721] = true, [61780] = true,
    -- Sap
    [6770]  = true, [2070]  = true, [11297] = true,
    -- Banish
    [710]   = true, [18647] = true,
    -- Shackle Undead
    [9484]  = true, [9485]  = true, [10955] = true,
    -- Hibernate
    [2637]  = true, [18657] = true, [18658] = true,
    -- Freezing Trap
    [3355]  = true, [14308] = true, [14309] = true,
}

function AMA.HandleCCImmune(destName)
    if not destName or destName == "" then return end
    local zone = AMA.currentZoneName
    if not zone or zone == "" then return end
    local inInstance = IsInInstance and IsInInstance()
    if not inInstance then return end

    local dbEntry = AMA.LookupMobMark(destName)
    local alreadyImmune = type(dbEntry) == "table" and dbEntry.ccImmune
    if alreadyImmune then return end

    local storedMark = type(dbEntry) == "table" and dbEntry.mark or 8
    local storedCtype = type(dbEntry) == "table" and dbEntry.creatureType or nil
    AMA.SetPlayerMobMark(zone, destName, storedMark, storedCtype, true)
    AMA.currentZoneMobDB = AMA.BuildZoneMobDB(zone)
    AMA.VPrint(string.format("Detected CC immunity: %s (saved to DB)", destName))
end

-- ============================================================
-- RESET STATE
-- ============================================================

function AMA.ResetState(forceAll)
    local marksToClear = {}
    for markIdx, ownerGuid in pairs(AMA.markOwners) do
        if forceAll or AMA.guidMarkSource[ownerGuid] == MARK_SOURCE_LOCAL then
            marksToClear[markIdx] = true
        end
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

    -- Skip the player-bounce fallback: if we can't find the token the mob is
    -- likely dead anyway, and bouncing would nuke marks set by other players
    -- on mobs we can't currently see.

    wipe(AMA.markedGUIDs)
    wipe(AMA.markOwners)
    wipe(AMA.markTokens)
    wipe(AMA.guidMarkSource)
end

function AMA.ResetWithMessage(forceAll)
    AMA.ResetState(forceAll)
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

    -- Refresh token mappings so we work with live data after a death.
    AMA.SyncVisibleMarks()

    -- Helper: find the highest-priority living CC-marked mob to promote.
    local function FindBestCCPromotion()
        for _, m in ipairs(AMA.ALL_MARKS_ORDERED) do
            if m ~= MARK_SKULL and m ~= MARK_CROSS then
                local ownerGuid = AMA.markOwners[m]
                if ownerGuid then
                    local token = ResolveToken(ownerGuid, AMA.markTokens[m])
                    if token then
                        return m, ownerGuid, token
                    else
                        AMA.ForgetMark(ownerGuid)
                    end
                end
            end
        end
        return nil, nil, nil
    end

    -- === Skull died: always promote Cross → Skull ===
    -- CC'd mobs are locked down; the kill target (Cross) becomes the new Skull.
    if AMA.IsMarkEnabled(MARK_SKULL) and IsMarkSlotFree(MARK_SKULL) then
        if AMA.markOwners[MARK_CROSS] then
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

    -- === Cross is now free (died or promoted away): promote best CC → Cross ===
    if AMA.IsMarkEnabled(MARK_CROSS) and IsMarkSlotFree(MARK_CROSS) then
        local _, ccGuid, ccToken = FindBestCCPromotion()
        if ccGuid and ccToken then
            local oldMark = AMA.markedGUIDs[ccGuid]
            local oldName = oldMark and AMA.MARK_NAMES[oldMark] or "?"
            AMA.ForgetMark(ccGuid)
            local applied = AMA.TrySetRaidTarget(ccToken, MARK_CROSS)
            if applied then
                AMA.RecordMark(ccGuid, MARK_CROSS, ccToken)
                AMA.VPrint("Promoted " .. oldName .. " to Cross: " .. (UnitName(ccToken) or "?"))
            end
        end
    end
end
