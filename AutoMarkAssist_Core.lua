-- AutoMarkAssist_Core.lua
-- Mark allocation, priority detection, CC matching, sync, and rebalance.
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

local PRIORITY_BOSS   = "BOSS"
local PRIORITY_HIGH   = "HIGH"
local PRIORITY_CC     = "CC"
local PRIORITY_MEDIUM = "MEDIUM"
local PRIORITY_LOW    = "LOW"

local MARK_SOURCE_LOCAL    = "local"
local MARK_SOURCE_OBSERVED = "observed"

local PRIORITY_RANK = {
    [PRIORITY_BOSS]   = 0,
    [PRIORITY_HIGH]   = 1,
    [PRIORITY_CC]     = 2,
    [PRIORITY_MEDIUM] = 3,
    [PRIORITY_LOW]    = 4,
}

-- ============================================================
-- MARK STATE
-- ============================================================

AMA.markedGUIDs    = {}   -- guid -> markIdx
AMA.markOwners     = {}   -- markIdx -> guid
AMA.markTokens     = {}   -- markIdx -> unitToken
AMA.guidPriority   = {}   -- guid -> priority tier
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

function AMA.RecordMark(guid, markIdx, token, priority)
    AMA.markedGUIDs[guid] = markIdx
    AMA.markOwners[markIdx] = guid
    AMA.markTokens[markIdx] = token
    AMA.guidPriority[guid] = priority
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
    AMA.guidPriority[guid] = nil
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
-- MOB PRIORITY DETECTION
-- ============================================================

local function MatchesKeyword(name, keywords)
    local lower = name:lower()
    for _, kw in ipairs(keywords) do
        if lower:find(kw, 1, true) then return true end
    end
    return false
end

local function GetMobPriority(unitToken)
    local name = UnitName(unitToken)
    if not name or name == "" then return nil end

    -- Skip critters.
    if AutoMarkAssistDB and AutoMarkAssistDB.skipCritters then
        local ctype = UnitCreatureType and UnitCreatureType(unitToken)
        if ctype == "Critter" then return nil end
    end

    -- Check classification: bosses and rares.
    local class = UnitClassification and UnitClassification(unitToken)
    if class == "worldboss" or class == "raidboss" then
        return PRIORITY_BOSS, name
    end
    if class == "elite" or class == "rareelite" or class == "rare" then
        -- Check zone DB first for elites.
    end

    -- Check zone database.
    if AMA.currentZoneMobDB and AMA.currentZoneMobDB[name] then
        local pri = AMA.currentZoneMobDB[name]
        if pri == "SKIP" then return nil end
        return pri, name
    end

    -- Keyword heuristics for mobs not in DB.
    if MatchesKeyword(name, AMA.HIGH_KEYWORDS) then
        return PRIORITY_HIGH, name
    end
    if MatchesKeyword(name, AMA.CC_KEYWORDS) then
        return PRIORITY_CC, name
    end

    -- Default to MEDIUM for mobs in a dungeon/raid zone with a DB.
    if AMA.currentZoneMobDB then
        return PRIORITY_MEDIUM, name
    end

    -- Outside a known zone, mark as MEDIUM if it's attackable.
    return PRIORITY_MEDIUM, name
end

-- ============================================================
-- MARK ALLOCATION
-- The simplified allocation works as follows:
-- 1. BOSS/HIGH priority -> Skull, then Cross
-- 2. CC priority -> matching CC mark if class is in group
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

-- Find the CC mark for a specific creature type given current group.
local function FindCCMark(creatureType)
    if not creatureType or creatureType == "" then return nil end
    local reserved = AMA.GetReservedCCMarks()
    for markIdx, ability in pairs(reserved) do
        if ability.creatureTypes[creatureType] and not AMA.markOwners[markIdx] then
            return markIdx, ability
        end
    end
    return nil
end

local function AllocateMark(priority, unitToken)
    if priority == PRIORITY_BOSS or priority == PRIORITY_HIGH then
        -- Try kill marks first.
        local killOrder = BuildKillOrder()
        for _, m in ipairs(killOrder) do
            if not AMA.markOwners[m] then return m end
        end
        return nil
    end

    if priority == PRIORITY_CC then
        -- Try to find a matching CC mark based on creature type.
        local ctype = unitToken and UnitCreatureType and UnitCreatureType(unitToken)
        local ccMark = FindCCMark(ctype)
        if ccMark then return ccMark end
        -- Fall through to kill order if no CC match.
    end

    -- For MEDIUM, LOW, or CC-without-match: use next free enabled mark.
    local killOrder = BuildKillOrder()
    for _, m in ipairs(killOrder) do
        if not AMA.markOwners[m] then return m end
    end
    -- Also try CC marks as overflow.
    local reserved = AMA.GetReservedCCMarks()
    for markIdx in pairs(reserved) do
        if not AMA.markOwners[markIdx] then return markIdx end
    end
    return nil
end

-- Dynamic allocation: can displace a lower-priority mob.
local function AllocateMarkDynamic(priority, unitToken)
    local mark = AllocateMark(priority, unitToken)
    if mark then return mark, nil end

    if not (AutoMarkAssistDB and AutoMarkAssistDB.dynamicMarking) then
        return nil, nil
    end

    -- Try to displace a lower-priority mob, or a distant/stale mob of the same priority.
    local myRank = PRIORITY_RANK[priority] or 3
    local bestMark, bestGUID, bestRank = nil, nil, -1

    for m = 1, 8 do
        if AMA.IsMarkEnabled(m) then
            local ownerGUID = AMA.markOwners[m]
            if ownerGUID and AMA.guidMarkSource[ownerGUID] == MARK_SOURCE_LOCAL then
                local ownerPri = AMA.guidPriority[ownerGUID] or PRIORITY_MEDIUM
                local ownerRank = PRIORITY_RANK[ownerPri] or 3
                
                local token = AMA.markTokens[m]
                -- Evaluate physical closeness, subtracting defensive rank from out-of-range or stale mobs
                local isClose = token and UnitExists(token) and IsUnitInRange(token, AutoMarkAssistDB and AutoMarkAssistDB.proximityRange or 4)
                
                local effectiveRank = ownerRank
                if not isClose then
                    effectiveRank = ownerRank + 0.5
                end

                if myRank < effectiveRank and effectiveRank > bestRank then
                    bestMark = m
                    bestGUID = ownerGUID
                    bestRank = effectiveRank
                end
            end
        end
    end

    return bestMark, bestGUID
end

-- ============================================================
-- SYNC VISIBLE MARKS
-- Reconcile in-game raid target icons with internal tracking.
-- ============================================================

function AMA.SyncVisibleMarks()
    -- Build a reverse map of what's currently visible.
    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token) and UnitCanAttack("player", token) then
            local guid = UnitGUID and UnitGUID(token)
            local visibleMark = GetRaidTargetIndex and GetRaidTargetIndex(token) or 0

            if guid then
                local trackedMark = AMA.markedGUIDs[guid]

                if visibleMark and visibleMark > 0 then
                    if not trackedMark then
                        -- Observed mark from another player.
                        AMA.markedGUIDs[guid] = visibleMark
                        AMA.markOwners[visibleMark] = guid
                        AMA.markTokens[visibleMark] = token
                        AMA.guidPriority[guid] = PRIORITY_MEDIUM
                        AMA.guidMarkSource[guid] = MARK_SOURCE_OBSERVED
                    elseif trackedMark ~= visibleMark then
                        -- Mark changed externally.
                        ForgetTrackedMark(guid)
                        AMA.markedGUIDs[guid] = visibleMark
                        AMA.markOwners[visibleMark] = guid
                        AMA.markTokens[visibleMark] = token
                        AMA.guidPriority[guid] = PRIORITY_MEDIUM
                        AMA.guidMarkSource[guid] = MARK_SOURCE_OBSERVED
                    else
                        -- Update token reference.
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

    -- Get priority.
    local priority, mobName = GetMobPriority(unitToken)
    if not priority then return end

    -- Allocate a mark.
    local markIdx, evictGUID
    if AutoMarkAssistDB and AutoMarkAssistDB.dynamicMarking then
        markIdx, evictGUID = AllocateMarkDynamic(priority, unitToken)
    else
        markIdx = AllocateMark(priority, unitToken)
    end

    if not markIdx then return end

    -- Evict displaced mob if needed.
    if evictGUID then
        local evictMark = AMA.markedGUIDs[evictGUID]
        local evictToken = evictMark and AMA.markTokens[evictMark]
        if evictToken and UnitExists(evictToken) then
            AMA.TrySetRaidTarget(evictToken, 0)
        end
        ForgetTrackedMark(evictGUID)
    end

    -- Apply the mark.
    local applied, reason = AMA.TrySetRaidTarget(unitToken, markIdx)
    if not applied then
        AMA.VPrint(string.format("Failed to mark %s: %s",
            mobName or "?", reason or "unknown"))
        return
    end

    AMA.RecordMark(guid, markIdx, unitToken, priority)
    AMA.VPrint(string.format("Marked %s -> %s (%s, %s)",
        mobName or "?",
        AMA.MARK_NAMES[markIdx] or tostring(markIdx),
        priority,
        source or "auto"))
end

-- ============================================================
-- RESET STATE
-- ============================================================

function AMA.ResetState()
    -- Clear all locally-assigned marks from mobs.
    for guid, markIdx in pairs(AMA.markedGUIDs) do
        if AMA.guidMarkSource[guid] == MARK_SOURCE_LOCAL then
            local token = AMA.markTokens[markIdx]
            if token and UnitExists(token) then
                pcall(SetRaidTarget, token, 0)
            end
        end
    end

    -- Wipe state tables.
    wipe(AMA.markedGUIDs)
    wipe(AMA.markOwners)
    wipe(AMA.markTokens)
    wipe(AMA.guidPriority)
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

function AMA.CascadeMarksAfterDeath()
    if AMA.GetMarkingMode() == "manual" then return end
    if AMA.IsCombatMarkLockActive() then return end

    -- Re-scan visible mobs and re-assign if better marks are free.
    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token) and UnitCanAttack("player", token)
        and not (UnitIsDead and UnitIsDead(token)) then
            local guid = UnitGUID and UnitGUID(token)
            if guid and AMA.markedGUIDs[guid]
            and AMA.guidMarkSource[guid] == MARK_SOURCE_LOCAL then
                local priority = AMA.guidPriority[guid]
                if priority then
                    local currentMark = AMA.markedGUIDs[guid]
                    local idealMark = AllocateMark(priority, token)
                    -- If the ideal mark is "better" (higher prestige), re-assign.
                    if idealMark and idealMark ~= currentMark then
                        local myRank = PRIORITY_RANK[priority] or 3
                        -- Only cascade kill marks upward.
                        if priority == PRIORITY_HIGH or priority == PRIORITY_BOSS then
                            if idealMark == MARK_SKULL or
                               (idealMark == MARK_CROSS and currentMark ~= MARK_SKULL) then
                                ForgetTrackedMark(guid)
                                local applied = AMA.TrySetRaidTarget(token, idealMark)
                                if applied then
                                    AMA.RecordMark(guid, idealMark, token, priority)
                                    AMA.VPrint("Cascaded: " .. (UnitName(token) or "?") ..
                                        " -> " .. (AMA.MARK_NAMES[idealMark] or "?"))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
