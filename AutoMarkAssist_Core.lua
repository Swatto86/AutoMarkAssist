-- AutoMarkAssist_Core.lua
-- Mark allocation, CC matching, sync, and rebalance.
-- Loaded after AutoMarkAssist.lua (namespace).

local AMA = AutoMarkAssist

-- ============================================================
-- FILE-SCOPE CONSTANTS
-- ============================================================

local MARK_STAR     = 1
local MARK_CIRCLE   = 2
local MARK_DIAMOND  = 3
local MARK_TRIANGLE = 4
local MARK_MOON     = 5
local MARK_SQUARE   = 6
local MARK_CROSS    = 7
local MARK_SKULL    = 8
local MARK_NONE     = 0

local MARK_SOURCE_LOCAL    = "local"
local MARK_SOURCE_OBSERVED = "observed"

-- ============================================================
-- MARK STATE
-- ============================================================

AMA.markedGUIDs    = {}   -- guid -> markIdx
AMA.markOwners     = {}   -- markIdx -> guid
AMA.markTokens     = {}   -- markIdx -> unitToken
AMA.guidMarkSource = {}   -- guid -> "local" | "observed"
AMA.pullMarkCount  = 0

-- ============================================================
-- PERMISSION CHECK
-- ============================================================

local function HasRaidTargetPermission()
    if not (IsInRaid and IsInRaid()) then return true end
    local isLeader = false
    if UnitIsGroupLeader then
        isLeader = UnitIsGroupLeader("player") and true or false
    end
    if not isLeader and IsRaidLeader then
        isLeader = IsRaidLeader() and true or false
    end
    if not isLeader and IsPartyLeader then
        isLeader = IsPartyLeader() and true or false
    end
    local isAssist = false
    if UnitIsGroupAssistant then
        isAssist = UnitIsGroupAssistant("player") and true or false
    end
    if not isAssist and IsRaidOfficer then
        isAssist = IsRaidOfficer() and true or false
    end
    return isLeader or isAssist
end

AMA.HasRaidTargetPermission = HasRaidTargetPermission

function AMA.CanMarkReason(options)
    local ignoreEnabled = type(options) == "table" and options.ignoreEnabled
    if not AutoMarkAssistDB then
        return false, "DB not initialised"
    end
    if not ignoreEnabled and not AutoMarkAssistDB.enabled then
        return false, "disabled"
    end
    if not HasRaidTargetPermission() then
        return false, "need raid leader or assistant"
    end
    return true, "ok"
end

-- ============================================================
-- TRY SET RAID TARGET (protected call)
-- ============================================================

function AMA.TrySetRaidTarget(unitToken, markIdx)
    local ok = pcall(SetRaidTarget, unitToken, markIdx)
    if not ok then return false, "SetRaidTarget failed" end
    if not UnitExists(unitToken) then
        if markIdx == MARK_NONE then return true, nil end
        return false, "unit disappeared"
    end
    -- Skip checking GetRaidTargetIndex immediately, as the server API 
    -- often takes a tick to sync the target back to the client.
    return true, nil
end

function AMA.IsLocalMark(guid)
    return AMA.guidMarkSource[guid] == MARK_SOURCE_LOCAL
end

function AMA.IsCombatMarkLockActive()
    if not AutoMarkAssistDB then return false end
    if not AutoMarkAssistDB.lockMarksInCombat then return false end
    if AMA.GetMarkingMode() == "manual" then return false end
    return UnitAffectingCombat and UnitAffectingCombat("player")
end

-- ============================================================
-- MARK TRACKING
-- ============================================================

function AMA.RecordMark(guid, markIdx, token)
    AMA.markedGUIDs[guid] = markIdx
    AMA.markOwners[markIdx] = guid
    AMA.markTokens[markIdx] = token
    AMA.guidMarkSource[guid] = MARK_SOURCE_LOCAL
    AMA.pullMarkCount = AMA.pullMarkCount + 1
end

local function ForgetTrackedMark(guid)
    local markIdx = AMA.markedGUIDs[guid]
    if not markIdx then return nil end
    if AMA.markOwners[markIdx] == guid then
        AMA.markOwners[markIdx] = nil
    end
    AMA.markedGUIDs[guid] = nil
    AMA.markTokens[markIdx] = nil
    AMA.guidMarkSource[guid] = nil
    if next(AMA.markedGUIDs) == nil then
        AMA.pullMarkCount = 0
    end
    return markIdx
end

function AMA.ForgetMark(guid)
    return ForgetTrackedMark(guid)
end

function AMA.ReleaseMark(guid)
    local markIdx = ForgetTrackedMark(guid)
    if not markIdx then return end
    AMA.VPrint("Released mark: " .. (AMA.MARK_NAMES[markIdx] or tostring(markIdx)))
end

-- ============================================================
-- RANGE CHECKS
-- ============================================================

local function IsUnitInRange(unitToken, rangeIdx)
    -- Map Trade range (2) to Duel range (3) because CheckInteractDistance index 2 
    -- returns false for hostile NPCs, breaking proximity marking at ~11yd.
    if rangeIdx == 2 then rangeIdx = 3 end

    local ok, result = pcall(CheckInteractDistance, unitToken, rangeIdx or 4)
    if not ok then return false end
    return result == 1 or result == true
end

local function IsUnitInAutoMarkRange(unitToken)
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

function AMA.BuildZoneMobDB(zoneName)
    if not zoneName or zoneName == "" then return nil end
    local baseMobs = AutoMarkAssist_MobDB and AutoMarkAssist_MobDB[zoneName]
    if not baseMobs and not (AutoMarkAssistDB and AutoMarkAssistDB.zoneAdditions
            and AutoMarkAssistDB.zoneAdditions[zoneName]) then
        return nil
    end

    local merged = {}
    if baseMobs then
        for mob, pri in pairs(baseMobs) do merged[mob] = pri end
    end

    -- Apply user overrides.
    if AutoMarkAssistDB then
        local overrides = AutoMarkAssistDB.mobOverrides and AutoMarkAssistDB.mobOverrides[zoneName]
        if overrides then
            for mob, pri in pairs(overrides) do merged[mob] = pri end
        end
        local removals = AutoMarkAssistDB.mobRemovals and AutoMarkAssistDB.mobRemovals[zoneName]
        if removals then
            for mob in pairs(removals) do merged[mob] = nil end
        end
        local additions = AutoMarkAssistDB.zoneAdditions and AutoMarkAssistDB.zoneAdditions[zoneName]
        if additions then
            for mob, pri in pairs(additions) do merged[mob] = pri end
        end
    end

    if next(merged) == nil then return nil end
    return merged
end

function AMA.NormalizeZoneScopedMobSettings()
    if not AutoMarkAssistDB then return end
    local function Clean(tbl)
        if type(tbl) ~= "table" then return end
        for zone, mobs in pairs(tbl) do
            if type(mobs) ~= "table" or next(mobs) == nil then
                tbl[zone] = nil
            end
        end
    end
    Clean(AutoMarkAssistDB.mobOverrides)
    Clean(AutoMarkAssistDB.mobRemovals)
    Clean(AutoMarkAssistDB.zoneAdditions)
end

function AMA.GetZoneMobOverrides(zoneName, create)
    if not AutoMarkAssistDB then return nil end
    if not AutoMarkAssistDB.mobOverrides then AutoMarkAssistDB.mobOverrides = {} end
    if create and not AutoMarkAssistDB.mobOverrides[zoneName] then
        AutoMarkAssistDB.mobOverrides[zoneName] = {}
    end
    return AutoMarkAssistDB.mobOverrides[zoneName]
end

function AMA.GetZoneMobRemovals(zoneName, create)
    if not AutoMarkAssistDB then return nil end
    if not AutoMarkAssistDB.mobRemovals then AutoMarkAssistDB.mobRemovals = {} end
    if create and not AutoMarkAssistDB.mobRemovals[zoneName] then
        AutoMarkAssistDB.mobRemovals[zoneName] = {}
    end
    return AutoMarkAssistDB.mobRemovals[zoneName]
end

function AMA.GetZoneAdditions(zoneName, create)
    if not AutoMarkAssistDB then return nil end
    if not AutoMarkAssistDB.zoneAdditions then AutoMarkAssistDB.zoneAdditions = {} end
    if create and not AutoMarkAssistDB.zoneAdditions[zoneName] then
        AutoMarkAssistDB.zoneAdditions[zoneName] = {}
    end
    return AutoMarkAssistDB.zoneAdditions[zoneName]
end

-- ============================================================
-- MOB FILTERING
-- ============================================================

local function MatchesKeyword(name, keywords)
    local lower = name:lower()
    for _, kw in ipairs(keywords) do
        if lower:find(kw, 1, true) then return true end
    end
    return false
end

local function IsMarkableTarget(unitToken)
    local name = UnitName(unitToken)
    if not name or name == "" then return false end

    -- Skip critters.
    if AutoMarkAssistDB and AutoMarkAssistDB.skipCritters then
        local ctype = UnitCreatureType and UnitCreatureType(unitToken)
        if ctype == "Critter" then return false end
    end

    -- Check zone database to see if explicitly skipped
    if AMA.currentZoneMobDB and AMA.currentZoneMobDB[name] == "SKIP" then
        return false
    end

    return true, name
end

-- ============================================================
-- MARK ALLOCATION
-- The simplified allocation works as follows:
-- 1. Try to assign Skull or Cross (if free)
-- 2. Try to find a matching CC mark for the creature type
-- 3. Any remaining -> next free enabled mark
-- ============================================================

-- Build the ordered list of kill-order marks (enabled marks not reserved for CC).
local function BuildKillOrder()
    local reserved = AMA.GetReservedCCMarks()
    local order = {}
    -- Skull and Cross first.
    for _, m in ipairs(AMA.KILL_MARKS) do
        if AMA.IsMarkEnabled(m) then
            order[#order + 1] = m
        end
    end
    -- Then remaining enabled marks not reserved for CC and not already in kill list.
    local inKill = {}
    for _, m in ipairs(order) do inKill[m] = true end
    for _, m in ipairs(AMA.ALL_MARKS_ORDERED) do
        if AMA.IsMarkEnabled(m) and not inKill[m] and not reserved[m] then
            order[#order + 1] = m
        end
    end
    return order
end

-- Check whether a tracked GUID is still alive and visible in the world.
-- Returns the unit token if found alive, nil otherwise.
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

-- Check if a mark slot is genuinely available.
-- If the recorded owner is dead or invisible, reclaim the slot.
local function IsMarkSlotFree(markIdx)
    local ownerGuid = AMA.markOwners[markIdx]
    if not ownerGuid then return true end
    local token = ValidateOwner(ownerGuid)
    if not token then
        -- Owner gone or dead — reclaim
        ForgetTrackedMark(ownerGuid)
        return true
    end
    return false
end

-- Find the CC mark for a specific creature type given current group.
local function FindCCMark(creatureType)
    if not creatureType or creatureType == "" then return nil end
    local reserved = AMA.GetReservedCCMarks()
    for markIdx, ability in pairs(reserved) do
        if ability.creatureTypes[creatureType] and IsMarkSlotFree(markIdx) then
            return markIdx, ability
        end
    end
    return nil
end

local function AllocateMark(unitToken)
    -- 1. Try kill marks first (Skull, Cross).
    for _, m in ipairs(AMA.KILL_MARKS) do
        if AMA.IsMarkEnabled(m) and IsMarkSlotFree(m) then
            return m
        end
    end

    -- 2. Try to find a matching CC mark based on creature type.
    local ctype = unitToken and UnitCreatureType and UnitCreatureType(unitToken)
    local ccMark = FindCCMark(ctype)
    if ccMark then return ccMark end

    -- 3. For any remaining, use next free non-CC mark.
    local killOrder = BuildKillOrder()
    for _, m in ipairs(killOrder) do
        if IsMarkSlotFree(m) then return m end
    end

    -- 4. Try CC marks as overflow if nothing else is available.
    local reserved = AMA.GetReservedCCMarks()
    for markIdx in pairs(reserved) do
        if IsMarkSlotFree(markIdx) then return markIdx end
    end

    return nil
end

-- ============================================================
-- SYNC VISIBLE MARKS
-- Reconcile in-game raid target icons with internal tracking.
-- ============================================================

function AMA.SyncVisibleMarks()
    -- Track which GUIDs we can still see alive in the world.
    local seenGuids = {}

    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token) and UnitCanAttack("player", token) then
            local isDead = UnitIsDead and UnitIsDead(token)
            local guid = UnitGUID and UnitGUID(token)
            local visibleMark = GetRaidTargetIndex and GetRaidTargetIndex(token) or 0

            if guid then
                local trackedMark = AMA.markedGUIDs[guid]

                if isDead then
                    -- Actively forget marks on dead units.
                    if trackedMark then
                        ForgetTrackedMark(guid)
                    end
                else
                    seenGuids[guid] = true

                    if visibleMark and visibleMark > 0 then
                        -- If someone else now owns that mark index, evict them.
                        local prevOwner = AMA.markOwners[visibleMark]
                        if prevOwner and prevOwner ~= guid then
                            ForgetTrackedMark(prevOwner)
                        end

                        if not trackedMark then
                            AMA.markedGUIDs[guid] = visibleMark
                            AMA.markOwners[visibleMark] = guid
                            AMA.markTokens[visibleMark] = token
                            AMA.guidMarkSource[guid] = MARK_SOURCE_OBSERVED
                        elseif trackedMark ~= visibleMark then
                            ForgetTrackedMark(guid)
                            AMA.markedGUIDs[guid] = visibleMark
                            AMA.markOwners[visibleMark] = guid
                            AMA.markTokens[visibleMark] = token
                            AMA.guidMarkSource[guid] = MARK_SOURCE_OBSERVED
                        else
                            AMA.markTokens[visibleMark] = token
                        end
                    elseif trackedMark and trackedMark > 0 then
                        -- Mark was removed externally.
                        ForgetTrackedMark(guid)
                    end
                end
            end
        end
    end

    -- Stale-owner sweep: any tracked GUID we did NOT see alive is orphaned.
    -- Collect them first to avoid mutating while iterating.
    local staleGuids = {}
    for guid in pairs(AMA.markedGUIDs) do
        if not seenGuids[guid] then
            staleGuids[#staleGuids + 1] = guid
        end
    end
    for _, guid in ipairs(staleGuids) do
        ForgetTrackedMark(guid)
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

    -- Already marked?
    if AMA.markedGUIDs[guid] and not force then return end

    -- Range check.
    if not IsUnitInAutoMarkRange(unitToken) then return end

    -- Check if it's a valid target
    local isValid, mobName = IsMarkableTarget(unitToken)
    if not isValid then return end

    -- Allocate a mark.
    local markIdx = AllocateMark(unitToken)
    if not markIdx then return end

    -- Apply the mark.
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
    -- Collect the set of mark indices we need to clear.
    local marksToClear = {}
    for markIdx in pairs(AMA.markOwners) do
        marksToClear[markIdx] = true
    end

    -- Phase 1: Clear marks on visible unit tokens (cheapest API call).
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

    -- Phase 2: For any marks we couldn't clear via visible tokens, bounce via player.
    -- Save the player's current mark so we can restore it.
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

    -- Wipe state tables.
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

-- Helper: find a live, visible token for a GUID, validating the cached token first.
local function ResolveToken(guid, cachedToken)
    -- Try the cached token first (fast path)
    if cachedToken and UnitExists(cachedToken) and UnitGUID(cachedToken) == guid then
        if not (UnitIsDead and UnitIsDead(cachedToken)) then
            return cachedToken
        end
        return nil
    end
    -- Fallback: scan for a live token
    return ValidateOwner(guid)
end

function AMA.CascadeMarksAfterDeath()
    if AMA.GetMarkingMode() == "manual" then return end
    if AMA.IsCombatMarkLockActive() then return end

    -- 1. Try to promote Cross to Skull if Skull is free
    if AMA.IsMarkEnabled(MARK_SKULL) and IsMarkSlotFree(MARK_SKULL) then
        if AMA.IsMarkEnabled(MARK_CROSS) and AMA.markOwners[MARK_CROSS] then
            local crossGuid = AMA.markOwners[MARK_CROSS]
            local crossToken = ResolveToken(crossGuid, AMA.markTokens[MARK_CROSS])

            if crossToken then
                ForgetTrackedMark(crossGuid)
                local applied = AMA.TrySetRaidTarget(crossToken, MARK_SKULL)
                if applied then
                    AMA.RecordMark(crossGuid, MARK_SKULL, crossToken)
                    AMA.VPrint("Promoted Cross to Skull: " .. (UnitName(crossToken) or "?"))
                end
            else
                -- Cross owner is gone, just reclaim
                ForgetTrackedMark(crossGuid)
            end
        end
    end

    -- 2. Try to promote a CC mark to Cross if Cross is now free
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
                    -- Owner is gone, reclaim this stale slot
                    ForgetTrackedMark(ownerGuid)
                end
            end
        end

        if bestMark and bestToken then
            local oldMarkName = AMA.MARK_NAMES[bestMark] or tostring(bestMark)
            ForgetTrackedMark(bestGuid)
            local applied = AMA.TrySetRaidTarget(bestToken, MARK_CROSS)
            if applied then
                AMA.RecordMark(bestGuid, MARK_CROSS, bestToken)
                AMA.VPrint("Promoted " .. oldMarkName .. " to Cross: " .. (UnitName(bestToken) or "?"))
            end
        end
    end
end
