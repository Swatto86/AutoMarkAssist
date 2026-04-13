-- AutoMarkAssist_Core.lua
-- Mark allocation, assignment, release, and rebalancing logic.
-- Loaded after AutoMarkAssist.lua (namespace).

local AMA = AutoMarkAssist

-- ============================================================
-- FILE-SCOPE CONSTANTS
-- Declared locally here for readable mark/priority comparisons.
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

-- Spill pool: draw from this when all tier-specific slots are exhausted.
local SPILL_POOL = {
    MARK_TRIANGLE, MARK_CIRCLE, MARK_STAR,
    MARK_SQUARE,   MARK_MOON,   MARK_DIAMOND,
}

-- Numeric priority ranks for comparison: lower number = higher in-game priority.
local PRIORITY_RANK_MAP = {
    [PRIORITY_BOSS]   = 0,
    [PRIORITY_HIGH]   = 1,
    [PRIORITY_CC]     = 2,
    [PRIORITY_MEDIUM] = 3,
    [PRIORITY_LOW]    = 4,
}

local PRIORITY_TIER_ORDER = {
    PRIORITY_HIGH,
    PRIORITY_CC,
    PRIORITY_MEDIUM,
    PRIORITY_LOW,
}

local DUNGEON_SMART_CC_RULES = {
    MAGE = {
        ccLabel = "Polymorph",
        marks = { MARK_SQUARE, MARK_MOON, MARK_DIAMOND },
        creatureTypes = { Humanoid = true, Beast = true, Critter = true },
    },
    ROGUE = {
        ccLabel = "Sap",
        marks = { MARK_MOON, MARK_SQUARE, MARK_DIAMOND },
        creatureTypes = { Humanoid = true },
    },
    HUNTER = {
        ccLabel = "Trap",
        marks = { MARK_DIAMOND, MARK_MOON, MARK_SQUARE },
        creatureTypes = { Beast = true },
    },
    PRIEST = {
        ccLabel = "Shackle",
        marks = { MARK_MOON, MARK_SQUARE, MARK_DIAMOND },
        creatureTypes = { Undead = true },
    },
    WARLOCK = {
        ccLabel = "Banish",
        marks = { MARK_DIAMOND, MARK_MOON, MARK_SQUARE },
        creatureTypes = { Demon = true, Elemental = true },
    },
    DRUID = {
        ccLabel = "Hibernate",
        marks = { MARK_MOON, MARK_SQUARE, MARK_DIAMOND },
        creatureTypes = { Beast = true, Dragonkin = true },
    },
}

local function BuildSmartCCGroupTokens()
    local tokens = {}

    if IsInRaid and IsInRaid() then
        for i = 1, 40 do
            local token = "raid" .. i
            if UnitExists(token) then
                tokens[#tokens + 1] = token
            end
        end
        return tokens
    end

    for _, token in ipairs({ "player", "party1", "party2", "party3", "party4" }) do
        if UnitExists(token) then
            tokens[#tokens + 1] = token
        end
    end

    return tokens
end

-- Count how many currently-tracked mobs have CC priority.
local function CountActiveCC()
    local count = 0
    for _, pri in pairs(AMA.guidPriority) do
        if pri == PRIORITY_CC then count = count + 1 end
    end
    return count
end

local function IsDungeonSmartCCEnabled()
    if not (AMA.IsAddonEnabled and AMA.IsAddonEnabled()) then
        return false
    end
    if not AutoMarkAssistDB.smartDungeonCC then
        return false
    end
    if not (IsInInstance and IsInGroup) then
        return false
    end
    local inInstance, instanceType = IsInInstance()
    return inInstance
        and (instanceType == "party" or instanceType == "raid")
        and (IsInGroup() or (IsInRaid and IsInRaid()))
end

local function BuildAllowedMarkSet(pool)
    local allowed = {}
    if type(pool) ~= "table" then
        return allowed
    end
    for _, markIdx in ipairs(pool) do
        allowed[markIdx] = true
    end
    return allowed
end

local function BuildDungeonSmartCCAvailableMarks(options)
    local configuredPool = AMA.GetConfiguredPool(PRIORITY_CC) or {}
    if #configuredPool == 0 then
        return {}
    end

    local availableMarks = {}
    local ccLimit = 0
    if options and options.respectCCLimit and AutoMarkAssistDB then
        ccLimit = AutoMarkAssistDB.ccLimit or 0
    end

    for _, markIdx in ipairs(configuredPool) do
        if ccLimit <= 0 or #availableMarks < ccLimit then
            availableMarks[#availableMarks + 1] = markIdx
        end
    end

    return availableMarks
end

local function BuildDungeonSmartCCMarkOrder(rule, preferredMark, availableMarks)
    local marks = {}
    local seen = {}

    local function AddMark(rawMark)
        local markIdx = tonumber(rawMark)
        if markIdx then
            markIdx = math.floor(markIdx)
        end
        if markIdx
        and markIdx >= MARK_STAR
        and markIdx <= MARK_SKULL
        and not seen[markIdx] then
            seen[markIdx] = true
            marks[#marks + 1] = markIdx
        end
    end

    AddMark(preferredMark)

    for _, markIdx in ipairs((rule and rule.marks) or {}) do
        AddMark(markIdx)
    end

    for _, markIdx in ipairs(availableMarks or {}) do
        AddMark(markIdx)
    end

    return marks
end

local function BuildDungeonSmartCCCandidates(creatureType, availableMarks)
    local candidates = {}
    local allowedMarks = BuildAllowedMarkSet(availableMarks)
    local roleMarks = (AMA.GetSmartCCRoleMarks and AMA.GetSmartCCRoleMarks()) or {}

    for _, groupToken in ipairs(BuildSmartCCGroupTokens()) do
        if UnitExists(groupToken) then
            local name = UnitName(groupToken)
            local _, classTag = UnitClass(groupToken)
            local rule = classTag and DUNGEON_SMART_CC_RULES[classTag]

            if name and name ~= "" and rule and (not creatureType or rule.creatureTypes[creatureType]) then
                local markRanks = {}
                local compatibleMarkCount = 0
                local markOrder = BuildDungeonSmartCCMarkOrder(
                    rule,
                    roleMarks[classTag],
                    availableMarks)

                for preferenceRank, preferredMark in ipairs(markOrder) do
                    if allowedMarks[preferredMark] then
                        markRanks[preferredMark] = preferenceRank
                        compatibleMarkCount = compatibleMarkCount + 1
                    end
                end

                if compatibleMarkCount > 0 then
                    candidates[#candidates + 1] = {
                        token = groupToken,
                        name = name,
                        classTag = classTag,
                        ccLabel = rule.ccLabel or "CC",
                        groupOrder = #candidates + 1,
                        markRanks = markRanks,
                    }
                end
            end
        end
    end

    return candidates
end

local function IsBetterDungeonSmartCCState(candidateState, bestState, availableMarks)
    if not bestState then
        return true
    end
    if candidateState.count ~= bestState.count then
        return candidateState.count > bestState.count
    end

    for markPos = 1, #availableMarks do
        local markIdx = availableMarks[markPos]
        local candidateMember = candidateState.slots[markPos]
        local bestMember = bestState.slots[markPos]

        if candidateMember ~= bestMember then
            if candidateMember and not bestMember then
                return true
            end
            if bestMember and not candidateMember then
                return false
            end
            if candidateMember and bestMember then
                local candidatePref = candidateMember.markRanks[markIdx] or 99
                local bestPref = bestMember.markRanks[markIdx] or 99

                if candidatePref ~= bestPref then
                    return candidatePref < bestPref
                end
                if candidateMember.groupOrder ~= bestMember.groupOrder then
                    return candidateMember.groupOrder < bestMember.groupOrder
                end
            end
        end
    end

    return false
end

local function CopyDungeonSmartCCAssignments(assignments)
    local copy = {}
    if type(assignments) ~= "table" then
        return copy
    end

    for index, assignment in ipairs(assignments) do
        copy[index] = {
            token = assignment.token,
            name = assignment.name,
            classTag = assignment.classTag,
            markIdx = assignment.markIdx,
            ccLabel = assignment.ccLabel,
        }
    end

    return copy
end

local function BuildDungeonSmartCCAssignments(unitToken, options)
    if not IsDungeonSmartCCEnabled() then
        return nil
    end

    options = options or {}
    local availableMarks = BuildDungeonSmartCCAvailableMarks(options)
    if #availableMarks == 0 then
        return {}
    end

    local creatureType = nil
    if unitToken then
        creatureType = UnitCreatureType and UnitCreatureType(unitToken)
        if not creatureType or creatureType == "" then
            return {}
        end
    end

    local candidates = BuildDungeonSmartCCCandidates(creatureType, availableMarks)
    if #candidates == 0 then
        return {}
    end

    local bestState = nil
    local currentSlots = {}
    local usedCandidates = {}

    local function Search(markPos, assignedCount)
        if bestState
        and assignedCount + (#availableMarks - markPos + 1) < bestState.count then
            return
        end

        if markPos > #availableMarks then
            local candidateState = {
                count = assignedCount,
                slots = {},
            }
            for index = 1, #availableMarks do
                candidateState.slots[index] = currentSlots[index]
            end
            if IsBetterDungeonSmartCCState(candidateState, bestState, availableMarks) then
                bestState = candidateState
            end
            return
        end

        currentSlots[markPos] = nil
        Search(markPos + 1, assignedCount)

        local markIdx = availableMarks[markPos]
        for candidateIndex, candidate in ipairs(candidates) do
            if not usedCandidates[candidateIndex] and candidate.markRanks[markIdx] then
                usedCandidates[candidateIndex] = true
                currentSlots[markPos] = candidate
                Search(markPos + 1, assignedCount + 1)
                currentSlots[markPos] = nil
                usedCandidates[candidateIndex] = nil
            end
        end
    end

    Search(1, 0)

    if not bestState or bestState.count == 0 then
        return {}
    end

    local assignments = {}
    for markPos = 1, #availableMarks do
        local candidate = bestState.slots[markPos]
        if candidate then
            assignments[#assignments + 1] = {
                token = candidate.token,
                name = candidate.name,
                classTag = candidate.classTag,
                markIdx = availableMarks[markPos],
                ccLabel = candidate.ccLabel,
            }
        end
    end

    return assignments
end

local function BuildDungeonSmartCCPool(unitToken)
    local assignments = BuildDungeonSmartCCAssignments(unitToken)
    if not assignments then
        return nil
    end

    local pool = {}
    for _, assignment in ipairs(assignments) do
        pool[#pool + 1] = assignment.markIdx
    end

    return pool
end

function AMA.IsDungeonSmartCCEnabled()
    return IsDungeonSmartCCEnabled()
end

function AMA.GetSmartCCGroupTokens()
    local tokens = {}
    for _, token in ipairs(BuildSmartCCGroupTokens()) do
        tokens[#tokens + 1] = token
    end
    return tokens
end

function AMA.GetDungeonSmartCCAssignments(unitToken, options)
    local assignments = BuildDungeonSmartCCAssignments(unitToken, options)
    if not assignments then
        return nil
    end

    return CopyDungeonSmartCCAssignments(assignments)
end

function AMA.GetActiveCCPool(unitToken)
    local smartPool = BuildDungeonSmartCCPool(unitToken)
    if smartPool then
        return smartPool
    end
    return AMA.GetConfiguredPool(PRIORITY_CC)
end

local ENCOUNTER_PRIORITY_RULES = {
    ["The Steamvault"] = {
        ["Hydromancer Thespia"] = {
            forceLowWhile = { ["Steam Surger"] = true, ["Tidal Surger"] = true },
        },
        ["Mekgineer Steamrigger"] = {
            forceLowWhile = { ["Steamrigger Mechanic"] = true },
        },
    },
    ["Shadow Labyrinth"] = {
        ["Grandmaster Vorpil"] = {
            forceLowWhile = { ["Void Traveler"] = true },
        },
    },
    ["Magisters' Terrace"] = {
        ["Sunblade Imp"] = {
            skipWhile = { ["Sunblade Imp Handler"] = true },
        },
    },
}

local PRIMARY_MARK_RESERVED_ZONES = {
    ["The Black Morass"] = true,
}

-- Optional tie-break priority within a single tier (lower value = higher
-- precedence). Used when multiple mobs share the same main priority.
local DEFAULT_SUB_PRIORITY = 9999

-- Built-in encounter tie-breakers. Players can override/extend these via
-- AutoMarkAssistDB.mobSubPriorities (zone-scoped, same keys as mobOverrides).
local ENCOUNTER_SUB_PRIORITY_RULES = {
    ["Shadow Labyrinth"] = {
        ["Cabal Shadow Priest"] = 1,
        ["Cabal Hexer"]         = 2,
        ["Cabal Warlock"]       = 3,
        ["Cabal Cultist"]       = 4,
    },
}

-- ============================================================
-- PERMISSION CHECK
-- Returns: canMark (bool), reason (string describing the blocker).
-- Exposed on AMA because ManualCycleMarkOnMouseover (Minimap) also calls it.
-- ============================================================

local function HasRaidTargetPermission()
    if not (IsInRaid and IsInRaid()) then
        return true
    end

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

    local isAssistant = false
    if UnitIsGroupAssistant then
        isAssistant = UnitIsGroupAssistant("player") and true or false
    end
    if not isAssistant and IsRaidOfficer then
        isAssistant = IsRaidOfficer() and true or false
    end

    return isLeader or isAssistant
end

AMA.HasRaidTargetPermission = HasRaidTargetPermission

function AMA.CanMarkReason(options)
    local ignoreEnabled = type(options) == "table" and options.ignoreEnabled
    if not AutoMarkAssistDB then
        return false, "DB not initialised"
    end
    if not ignoreEnabled and not AutoMarkAssistDB.enabled then
        return false, "disabled - use /ama enable or left-click the minimap icon"
    end
    if not HasRaidTargetPermission() then
        return false, "raid target icons require raid leader or assistant permissions in raids"
    end
    return true, "ok"
end

function AMA.IsLocalMark(guid)
    return AMA.guidMarkSource[guid] == MARK_SOURCE_LOCAL
end

function AMA.TrySetRaidTarget(unitToken, markIdx)
    local ok = pcall(SetRaidTarget, unitToken, markIdx)
    if not ok then
        return false, "SetRaidTarget failed"
    end
    if not UnitExists(unitToken) then
        if markIdx == MARK_NONE then
            return true, nil
        end
        return false, "unit disappeared"
    end

    local applied = GetRaidTargetIndex and GetRaidTargetIndex(unitToken) or MARK_NONE
    if (applied or MARK_NONE) == markIdx then
        return true, nil
    end

    return false, string.format(
        "requested %s, observed %s",
        tostring(markIdx),
        tostring(applied or MARK_NONE))
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
    AMA.guidSubPriority[guid] = nil
    AMA.guidMarkSource[guid] = nil

    if next(AMA.markedGUIDs) == nil then
        AMA.pullMarkCount = 0
    end

    return markIdx
end

function AMA.ForgetMark(guid)
    return ForgetTrackedMark(guid)
end

function AMA.IsCombatMarkLockActive()
    if not AutoMarkAssistDB then return false end
    if not AutoMarkAssistDB.lockMarksInCombat then return false end
    if AutoMarkAssistDB.manualMode then return false end
    return UnitAffectingCombat and UnitAffectingCombat("player")
end

-- ============================================================
-- AUTO-MARK RANGE CHECKS
-- Classic uses CheckInteractDistance as the only reliable range
-- check for arbitrary unit tokens.
-- ============================================================

local function IsUnitWithinInteractRange(unitToken, rangeIdx)
    local ok, result = pcall(CheckInteractDistance, unitToken, rangeIdx or 4)
    if not ok then return false end
    return result == 1 or result == true
end

local function IsUnitInProximity(unitToken)
    if not AutoMarkAssistDB then
        return true
    end
    if not AutoMarkAssistDB.proximityMode then
        return false
    end
    return IsUnitWithinInteractRange(unitToken, AutoMarkAssistDB.proximityRange or 4)
end

local function IsUnitInMouseoverRange(unitToken)
    if not AutoMarkAssistDB then
        return true
    end
    if AutoMarkAssistDB.mouseoverMode == false then
        return false
    end
    if not AutoMarkAssistDB.mouseoverRangeEnabled then
        return true
    end
    return IsUnitWithinInteractRange(unitToken, AutoMarkAssistDB.mouseoverRange or 4)
end

local function IsUnitInAutoMarkRange(unitToken, source)
    if source == "mouseover" then
        if AutoMarkAssistDB and AutoMarkAssistDB.mouseoverMode == false then
            return false, "mouseover disabled"
        end
        if IsUnitInMouseoverRange(unitToken) then
            return true
        end
        return false, "out of mouseover range"
    end

    if AutoMarkAssistDB and not AutoMarkAssistDB.proximityMode then
        return false, "proximity disabled"
    end

    if IsUnitInProximity(unitToken) then
        return true
    end
    return false, "out of proximity range"
end

-- ============================================================
-- PRIORITY RANK
-- Converts a priority tier string to a numeric rank.
-- Lower number = higher priority (BOSS always wins).
-- ============================================================

local function GetPriorityRank(priority)
    return PRIORITY_RANK_MAP[priority] or 3
end

local function NormalizeSubPriority(raw)
    if raw == nil then return nil end
    local n = tonumber(raw)
    if not n then return nil end
    n = math.floor(n)
    if n < 1 then return nil end
    return n
end

local function ResolveSubPriority(raw, priority)
    if type(raw) == "table" then
        return NormalizeSubPriority(raw[priority] or raw.DEFAULT or raw.sub)
    end
    return NormalizeSubPriority(raw)
end

local function GetSubPriorityRank(subPriority)
    return NormalizeSubPriority(subPriority) or DEFAULT_SUB_PRIORITY
end

local function ShouldDisplaceOwner(myPriority, mySubPriority, ownerGUID)
    if not AMA.IsLocalMark(ownerGUID) then return false end

    local ownerPriority = AMA.guidPriority[ownerGUID] or PRIORITY_MEDIUM
    local myRank = GetPriorityRank(myPriority)
    local ownerRank = GetPriorityRank(ownerPriority)
    if myRank < ownerRank then return true end
    if myRank > ownerRank then return false end
    return GetSubPriorityRank(mySubPriority)
        < GetSubPriorityRank(AMA.guidSubPriority[ownerGUID])
end

function AMA.GetMobSubPriorityForZone(zoneName, mobName, priority)
    local zone = AMA.ResolveZoneName and AMA.ResolveZoneName(zoneName) or zoneName
    if not zone or zone == "" or not mobName or mobName == "" then
        return nil
    end

    if AutoMarkAssistDB and AutoMarkAssistDB.mobSubPriorities then
        local userZone = AutoMarkAssistDB.mobSubPriorities[zone]
        if userZone and userZone[mobName] ~= nil then
            local userSub = ResolveSubPriority(userZone[mobName], priority)
            if userSub then return userSub end
        end
    end

    local builtInZone = ENCOUNTER_SUB_PRIORITY_RULES[zone]
    if builtInZone and builtInZone[mobName] ~= nil then
        local builtInSub = ResolveSubPriority(builtInZone[mobName], priority)
        if builtInSub then return builtInSub end
    end
    return nil
end

local function GetMobSubPriority(mobName, priority)
    return AMA.GetMobSubPriorityForZone(AMA.currentZoneName, mobName, priority)
end

local function HasVisibleAliveNamedMob(nameSet, excludeGUID)
    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token)
        and UnitCanAttack("player", token)
        and not (UnitIsDead and UnitIsDead(token)) then
            local tokenName = UnitName(token)
            if tokenName and nameSet[tokenName] then
                local guid = UnitGUID and UnitGUID(token)
                if not excludeGUID or guid ~= excludeGUID then
                    return true
                end
            end
        end
    end
    return false
end

local function ApplyEncounterPriorityRules(mobName, unitToken, priority)
    local zoneRules = ENCOUNTER_PRIORITY_RULES[AMA.currentZoneName]
    if not zoneRules then return priority end

    local rule = zoneRules[mobName]
    if not rule then return priority end

    local guid = unitToken and UnitGUID and UnitGUID(unitToken)
    if rule.skipWhile and HasVisibleAliveNamedMob(rule.skipWhile, guid) then
        return "SKIP"
    end
    if rule.forceLowWhile and HasVisibleAliveNamedMob(rule.forceLowWhile, guid) then
        return PRIORITY_LOW
    end

    return priority
end

local function ReservePrimaryMarksForZone(priority)
    if not PRIMARY_MARK_RESERVED_ZONES[AMA.currentZoneName] then
        return false
    end
    return priority ~= PRIORITY_HIGH and priority ~= PRIORITY_BOSS
end

-- ============================================================
-- MARK POOL MANAGEMENT
-- ============================================================

local function NextFreeMarkInPool(pool)
    for _, markIdx in ipairs(pool) do
        if not AMA.markOwners[markIdx] then return markIdx end
    end
    return nil
end

-- Returns the configured pool for a priority tier from saved vars,
-- falling back to the compile-time default.
-- Exposed on AMA so the /ama pools slash command (Events) can call it.
function AMA.GetConfiguredPool(priority)
    local key = (priority == PRIORITY_BOSS) and PRIORITY_HIGH or priority
    if AutoMarkAssistDB
    and AutoMarkAssistDB.markPools
    and AutoMarkAssistDB.markPools[key] then
        return AutoMarkAssistDB.markPools[key]
    end
    return AMA.PRIORITY_POOLS[key]
end

function AMA.GetPriorityTierForMark(markIdx)
    local normalizedMark = tonumber(markIdx)
    if normalizedMark then
        normalizedMark = math.floor(normalizedMark)
    end
    if not normalizedMark
    or normalizedMark < MARK_STAR
    or normalizedMark > MARK_SKULL then
        return PRIORITY_MEDIUM
    end

    for _, tier in ipairs(PRIORITY_TIER_ORDER) do
        local pool = AMA.GetConfiguredPool(tier)
        if pool then
            for _, idx in ipairs(pool) do
                if idx == normalizedMark then
                    return tier
                end
            end
        end
    end

    return PRIORITY_MEDIUM
end

-- Builds a lookup set of every mark index that appears in at least one
-- configured pool.  Any mark not in this set has been deliberately excluded
-- by the user and MUST NOT be assigned automatically.  Manual assignment
-- (ManualCycleMarkOnMouseover) bypasses this check intentionally.
local function GetAllowedMarks()
    local allowed = {}
    for _, tier in ipairs({ PRIORITY_HIGH, PRIORITY_CC, PRIORITY_MEDIUM, PRIORITY_LOW }) do
        local pool = AMA.GetConfiguredPool(tier)
        if pool then
            for _, markIdx in ipairs(pool) do
                allowed[markIdx] = true
            end
        end
    end
    return allowed
end

-- Like NextFreeMarkInPool but skips marks absent from the allowed set.
local function NextFreeAllowedMarkInPool(pool, allowed)
    for _, markIdx in ipairs(pool) do
        if allowed[markIdx] and not AMA.markOwners[markIdx] then
            return markIdx
        end
    end
    return nil
end

local function AllocateMark(priority, options)
    -- Allowed set: union of all configured pools.  Marks the user has removed
    -- from every pool are never assigned automatically.  An empty tier pool
    -- (e.g. CC={} in "Kill Only") does NOT suppress the mob entirely -- the
    -- mob can still receive a mark via the Skull/Cross fallback or the
    -- allowed-filtered spill pool.  The constraint is on which *marks* may be
    -- used, not which *mobs* may be marked.
    local allowed = (options and options.allowedMarks) or GetAllowedMarks()
    local idealPool = (options and options.idealPool) or AMA.GetConfiguredPool(priority)
    local allowPrimary = not (options and options.skipPrimary)
    local allowSpill = not (options and options.skipSpill)

    if priority == PRIORITY_HIGH then
        local mark = idealPool and NextFreeAllowedMarkInPool(idealPool, allowed)
        if mark then return mark end
        if allowSpill then
            return NextFreeAllowedMarkInPool(SPILL_POOL, allowed)
        end
        return nil
    end
    if idealPool then
        local mark = NextFreeAllowedMarkInPool(idealPool, allowed)
        if mark then return mark end
    end
    -- Skull/Cross fallback for non-HIGH tiers.  Tier-specific pools remain
    -- authoritative; these primary kill-order icons are only used when the
    -- configured tier pool cannot satisfy the assignment.
    if allowPrimary and not ReservePrimaryMarksForZone(priority) then
        if allowed[MARK_SKULL] and not AMA.markOwners[MARK_SKULL] then return MARK_SKULL end
        if allowed[MARK_CROSS] and not AMA.markOwners[MARK_CROSS] then return MARK_CROSS end
    end
    if allowSpill then
        return NextFreeAllowedMarkInPool(SPILL_POOL, allowed)
    end
    return nil
end

-- ============================================================
-- DYNAMIC MARK ALLOCATION (bump-aware)
-- Returns (markIdx, evictGUID).  evictGUID is non-nil when the chosen
-- slot is occupied by a lower-priority mob that we can outrank.
-- ============================================================

local function AllocateMarkDynamic(priority, subPriority, options)
    -- Allowed set: union of all configured pools.  See AllocateMark for the
    -- full rationale.  Empty tier pool does not suppress the mob -- it just
    -- means no dedicated marks for that tier; Skull/Cross fallback and the
    -- allowed-filtered spill pool still apply.
    local allowed = (options and options.allowedMarks) or GetAllowedMarks()
    local idealPool = (options and options.idealPool) or AMA.GetConfiguredPool(priority)
    local allowPrimary = not (options and options.skipPrimary)
    local allowSpill = not (options and options.skipSpill)

    -- Walk pool in prestige order.  Returns first free slot, or first
    -- slot whose occupant we outrank. Pool order is authoritative.
    -- Skips marks not in the allowed set so user pool config is honoured.
    local function BestFromPool(pool)
        for _, markIdx in ipairs(pool) do
            if allowed[markIdx] then
                local ownerGUID = AMA.markOwners[markIdx]
                if not ownerGUID then
                    return markIdx, nil
                else
                    if ShouldDisplaceOwner(priority, subPriority, ownerGUID) then
                        return markIdx, ownerGUID
                    end
                end
            end
        end
        return nil, nil
    end

    -- 1. Ideal pool for this tier (all marks in the tier are allowed by
    --    definition, so no filtering needed).
    if idealPool then
        local m, eg = BestFromPool(idealPool)
        if m then return m, eg end
    end

    -- 2. Skull/Cross fallback for non-HIGH tiers (including BOSS).
    --    BOSS (rank 0) can still displace any trash mob from Skull/Cross, but
    --    only after the tier's configured pool was considered first.
    if allowPrimary and priority ~= PRIORITY_HIGH and not ReservePrimaryMarksForZone(priority) then
        for _, markIdx in ipairs({MARK_SKULL, MARK_CROSS}) do
            if allowed[markIdx] then
                local ownerGUID = AMA.markOwners[markIdx]
                if not ownerGUID then
                    return markIdx, nil
                else
                    if ShouldDisplaceOwner(priority, subPriority, ownerGUID) then
                        return markIdx, ownerGUID
                    end
                end
            end
        end
    end

    -- 3. Spill pool fallback -- filtered to allowed marks only.
    if allowSpill then
        local m, eg = BestFromPool(SPILL_POOL)
        if m then return m, eg end
    end

    return nil, nil
end

-- ============================================================
-- RECORD / RELEASE MARK
-- ============================================================

-- Record a newly placed mark in all bookkeeping tables.
-- Exposed on AMA because ManualCycleMarkOnMouseover (Minimap) also calls it.
function AMA.RecordMark(guid, markIdx, unitToken, priority, subPriority, source)
    local previousMark = AMA.markedGUIDs[guid]
    if previousMark and previousMark ~= markIdx and AMA.markOwners[previousMark] == guid then
        AMA.markOwners[previousMark] = nil
        AMA.markTokens[previousMark] = nil
    end

    local previousOwner = AMA.markOwners[markIdx]
    if previousOwner and previousOwner ~= guid then
        ForgetTrackedMark(previousOwner)
    end

    AMA.markedGUIDs[guid]   = markIdx
    AMA.markOwners[markIdx] = guid
    AMA.markTokens[markIdx] = unitToken
    if priority then AMA.guidPriority[guid] = priority end
    if subPriority ~= nil then
        AMA.guidSubPriority[guid] = NormalizeSubPriority(subPriority)
    else
        AMA.guidSubPriority[guid] = nil
    end
    AMA.guidMarkSource[guid] = source or MARK_SOURCE_LOCAL
end

-- Release all bookkeeping for a mob (death or reset).
-- Returns true when a slot was freed so the caller can trigger re-scan.
function AMA.ReleaseMark(guid)
    local markIdx = AMA.markedGUIDs[guid]
    if markIdx then
        local token = AMA.markTokens[markIdx]
        if AMA.IsLocalMark(guid)
        and token and UnitExists(token)
        and UnitGUID and UnitGUID(token) == guid
        and (GetRaidTargetIndex(token) or MARK_NONE) == markIdx then
            AMA.TrySetRaidTarget(token, MARK_NONE)
        end

        ForgetTrackedMark(guid)
        AMA.VPrint("Released " ..
            (AMA.MARK_NAMES[markIdx] or markIdx) .. " from GUID " .. guid)
        return true
    end
    return false
end

-- ============================================================
-- PRIORITY DETECTION
-- ============================================================

local function GetMobPriority(mobName, unitToken)
    local priority = nil

    -- The merged zone DB (currentZoneMobDB) already incorporates user
    -- overrides, removals, and zone-specific additions.  Checking it first
    -- covers all user customisation in a single lookup.
    if AMA.currentZoneMobDB then
        local dbPriority = AMA.currentZoneMobDB[mobName]
        if dbPriority then priority = dbPriority end
    end

    -- Boss/rare auto-detection for mobs not in the DB.
    if not priority and unitToken then
        local level = UnitLevel and UnitLevel(unitToken)
        if level and level < 0 then priority = PRIORITY_BOSS end
        local class = UnitClassification and UnitClassification(unitToken)
        if not priority and (class == "worldboss" or class == "boss"
        or class == "rareelite" or class == "rare") then
            priority = PRIORITY_BOSS
        end
    end

    if not priority then
        local lower = mobName:lower()
        for _, kw in ipairs(AMA.HIGH_KEYWORDS) do
            if lower:find(kw, 1, true) then
                priority = PRIORITY_HIGH
                break
            end
        end
        if not priority then
            for _, kw in ipairs(AMA.CC_KEYWORDS) do
                if lower:find(kw, 1, true) then
                    priority = PRIORITY_CC
                    break
                end
            end
        end
    end

    priority = priority or PRIORITY_MEDIUM
    priority = ApplyEncounterPriorityRules(mobName, unitToken, priority)
    return priority, GetMobSubPriority(mobName, priority)
end

local function GetPrimaryKillOrderPool()
    local allowedMarks = GetAllowedMarks()
    local primaryPool = {}

    for _, markIdx in ipairs({ MARK_SKULL, MARK_CROSS }) do
        if allowedMarks[markIdx] then
            primaryPool[#primaryPool + 1] = markIdx
        end
    end

    if #primaryPool > 0 then
        return primaryPool
    end

    local configuredHigh = AMA.GetConfiguredPool(PRIORITY_HIGH) or {}
    for _, markIdx in ipairs(configuredHigh) do
        if allowedMarks[markIdx] then
            primaryPool[#primaryPool + 1] = markIdx
        end
    end

    return primaryPool
end

local function CollectVisibleAutoMarkMobs(source)
    local seen = {}
    local mobs = {}

    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token)
        and UnitCanAttack("player", token)
        and not (UnitIsDead and UnitIsDead(token)) then
            local guid = UnitGUID and UnitGUID(token)
            if guid and not seen[guid] then
                local inRange = true
                if source then
                    inRange = select(1, IsUnitInAutoMarkRange(token, source))
                end

                if inRange then
                    local mobName = UnitName(token)
                    if mobName and mobName ~= "" and mobName ~= "Unknown" then
                        local skip = false

                        if AutoMarkAssistDB and AutoMarkAssistDB.skipCritters then
                            local ctype = UnitCreatureType and UnitCreatureType(token)
                            if ctype == "Critter" then
                                skip = true
                            end
                        end

                        if not skip then
                            local priority, subPriority = GetMobPriority(mobName, token)
                            if not (priority == "SKIP"
                                and AutoMarkAssistDB
                                and AutoMarkAssistDB.skipFillerMobs ~= false) then
                                if priority == "SKIP" then
                                    priority = PRIORITY_MEDIUM
                                    subPriority = GetMobSubPriority(mobName, priority)
                                end

                                seen[guid] = true
                                mobs[#mobs + 1] = {
                                    guid = guid,
                                    token = token,
                                    name = mobName,
                                    priority = priority,
                                    subPriority = subPriority,
                                    creatureType = UnitCreatureType and UnitCreatureType(token),
                                    currentMark = (GetRaidTargetIndex and GetRaidTargetIndex(token))
                                        or AMA.markedGUIDs[guid],
                                }
                        end
                    end
                end
            end
        end
    end

        return mobs
end

    local function CompareAutoMarkMobOrder(left, right)
        local leftRank = GetPriorityRank(left.priority)
        local rightRank = GetPriorityRank(right.priority)
        if leftRank ~= rightRank then
            return leftRank < rightRank
    end

        local leftSub = GetSubPriorityRank(left.subPriority)
        local rightSub = GetSubPriorityRank(right.subPriority)
        if leftSub ~= rightSub then
            return leftSub < rightSub
    end

        if left.name ~= right.name then
            return left.name < right.name
        end

        return (left.guid or "") < (right.guid or "")
end

    local function BuildExactMarkAllocationOptions(markIdx)
        if not markIdx then
            return nil
        end

        return {
            idealPool = { markIdx },
            allowedMarks = BuildAllowedMarkSet({ markIdx }),
            skipPrimary = true,
            skipSpill = true,
        }
    end

    local function BuildPrimaryKillAssignments(source)
    local primaryPool = GetPrimaryKillOrderPool()
    if #primaryPool == 0 then
            return {}
    end

        local candidates = CollectVisibleAutoMarkMobs(source)
        local assignments = {}
        local slot = 0

        table.sort(candidates, CompareAutoMarkMobOrder)

        for _, mob in ipairs(candidates) do
            if not ReservePrimaryMarksForZone(mob.priority) then
                slot = slot + 1
                assignments[mob.guid] = primaryPool[slot]
                if slot >= #primaryPool then
                    break
                end
            end
        end

        return assignments
    end

    local function IsBetterVisibleSmartCCState(candidateState, bestState, roleAssignments)
        if not bestState then
            return true
        end
        if candidateState.count ~= bestState.count then
            return candidateState.count > bestState.count
        end

        for markPos = 1, #roleAssignments do
            local markIdx = roleAssignments[markPos].markIdx
            local candidateMob = candidateState.slots[markPos]
            local bestMob = bestState.slots[markPos]

            if candidateMob ~= bestMob then
                if candidateMob and not bestMob then
                    return true
                end
                if bestMob and not candidateMob then
                    return false
                end
                if candidateMob and bestMob then
                    if candidateMob.compatibleCount ~= bestMob.compatibleCount then
                        return candidateMob.compatibleCount < bestMob.compatibleCount
                    end

                    local candidateKeepsMark = candidateMob.currentMark == markIdx
                    local bestKeepsMark = bestMob.currentMark == markIdx
                    if candidateKeepsMark ~= bestKeepsMark then
                        return candidateKeepsMark
                    end

                    if CompareAutoMarkMobOrder(candidateMob, bestMob) then
                        return true
                    end
                    if CompareAutoMarkMobOrder(bestMob, candidateMob) then
                        return false
                    end
                end
            end
        end

        return false
    end

    local function BuildVisibleSmartCCAssignments(source)
        if not IsDungeonSmartCCEnabled() then
            return nil
        end

        local roleAssignments = BuildDungeonSmartCCAssignments(nil, {
            respectCCLimit = true,
        })
        if not roleAssignments or #roleAssignments == 0 then
            return {}
        end

        local primaryAssignments = BuildPrimaryKillAssignments(source)
        local candidates = {}

        for _, mob in ipairs(CollectVisibleAutoMarkMobs(source)) do
            if mob.priority == PRIORITY_CC
            and not primaryAssignments[mob.guid]
            and mob.creatureType
            and mob.creatureType ~= "" then
                local markRanks = {}
                local compatibleCount = 0

                for markPos, assignment in ipairs(roleAssignments) do
                    local rule = assignment.classTag and DUNGEON_SMART_CC_RULES[assignment.classTag]
                    if rule and rule.creatureTypes[mob.creatureType] then
                        markRanks[assignment.markIdx] = markPos
                        compatibleCount = compatibleCount + 1
                    end
                end

                if compatibleCount > 0 then
                    mob.markRanks = markRanks
                    mob.compatibleCount = compatibleCount
                    candidates[#candidates + 1] = mob
                end
            end
        end

        if #candidates == 0 then
            return {}
        end

        local bestState = nil
        local currentSlots = {}
        local usedCandidates = {}

        local function Search(markPos, assignedCount)
            if bestState
            and assignedCount + (#roleAssignments - markPos + 1) < bestState.count then
                return
            end

            if markPos > #roleAssignments then
                local candidateState = {
                    count = assignedCount,
                    slots = {},
                }
                for index = 1, #roleAssignments do
                    candidateState.slots[index] = currentSlots[index]
                end
                if IsBetterVisibleSmartCCState(candidateState, bestState, roleAssignments) then
                    bestState = candidateState
                end
                return
            end

            currentSlots[markPos] = nil
            Search(markPos + 1, assignedCount)

            local markIdx = roleAssignments[markPos].markIdx
            for candidateIndex, candidate in ipairs(candidates) do
                if not usedCandidates[candidateIndex] and candidate.markRanks[markIdx] then
                    usedCandidates[candidateIndex] = true
                    currentSlots[markPos] = candidate
                    Search(markPos + 1, assignedCount + 1)
                    currentSlots[markPos] = nil
                    usedCandidates[candidateIndex] = nil
                end
            end
        end

        Search(1, 0)

        if not bestState or bestState.count == 0 then
            return {}
        end

        local assignments = {}
        for markPos = 1, #roleAssignments do
            local mob = bestState.slots[markPos]
            if mob then
                assignments[mob.guid] = {
                    markIdx = roleAssignments[markPos].markIdx,
                    classTag = roleAssignments[markPos].classTag,
                    ccLabel = roleAssignments[markPos].ccLabel,
                }
            end
        end

        return assignments
end

local function ResolveAutoMarkStrategy(mobName, unitToken, priority, subPriority, source)
    local effectivePriority = priority
    local effectiveSubPriority = subPriority
        local guid = unitToken and UnitGUID and UnitGUID(unitToken)

        local primaryAssignments = guid and BuildPrimaryKillAssignments(source) or nil
        local primaryMark = primaryAssignments and primaryAssignments[guid]
        if primaryMark then
            return effectivePriority,
                effectiveSubPriority,
                BuildExactMarkAllocationOptions(primaryMark),
                "primary-kill-order"
    end

    if effectivePriority == PRIORITY_CC and IsDungeonSmartCCEnabled() then
            local smartCCAssignments = BuildVisibleSmartCCAssignments(source)
            local smartCCAssignment = guid and smartCCAssignments and smartCCAssignments[guid]

            if not smartCCAssignment or not smartCCAssignment.markIdx then
                AMA.VPrint("No compatible smart CC slot selected, treating as kill-order: " .. mobName)
            effectivePriority = PRIORITY_MEDIUM
            effectiveSubPriority = GetMobSubPriority(mobName, effectivePriority)
        else
                return effectivePriority,
                    effectiveSubPriority,
                    BuildExactMarkAllocationOptions(smartCCAssignment.markIdx),
                    "smart-cc"
        end
    end

    return effectivePriority, effectiveSubPriority, nil, nil
end

local function CollectVisibleMarks()
    local visible = {}

    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token)
        and UnitCanAttack("player", token)
        and not (UnitIsDead and UnitIsDead(token)) then
            local guid = UnitGUID and UnitGUID(token)
            local markIdx = guid and GetRaidTargetIndex(token)
            if guid and markIdx and markIdx > MARK_NONE and not visible[guid] then
                local priority = PRIORITY_MEDIUM
                local subPriority = nil
                local mobName = UnitName(token)

                if mobName and mobName ~= "" and mobName ~= "Unknown" then
                    priority, subPriority = GetMobPriority(mobName, token)
                    if priority == "SKIP" then
                        priority = PRIORITY_MEDIUM
                        subPriority = GetMobSubPriority(mobName, priority)
                    end
                end

                visible[guid] = {
                    markIdx = markIdx,
                    token = token,
                    priority = priority,
                    subPriority = subPriority,
                }
            end
        end
    end

    return visible
end

local function FindVisibleTokenForGUID(guid, preferredToken)
    if not guid then return nil end

    if preferredToken and UnitExists(preferredToken)
    and UnitGUID and UnitGUID(preferredToken) == guid then
        return preferredToken
    end

    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token)
        and UnitGUID and UnitGUID(token) == guid then
            return token
        end
    end

    return nil
end

function AMA.SyncVisibleMarks()
    local previous = {}
    for guid, markIdx in pairs(AMA.markedGUIDs) do
        previous[guid] = {
            markIdx = markIdx,
            source = AMA.guidMarkSource[guid],
            token = AMA.markTokens[markIdx],
            priority = AMA.guidPriority[guid],
            subPriority = AMA.guidSubPriority[guid],
        }
    end

    local visible = CollectVisibleMarks()

    wipe(AMA.markedGUIDs)
    wipe(AMA.markOwners)
    wipe(AMA.markTokens)
    wipe(AMA.guidPriority)
    wipe(AMA.guidSubPriority)
    wipe(AMA.guidMarkSource)
    AMA.pullMarkCount = 0

    for guid, info in pairs(visible) do
        local source = MARK_SOURCE_OBSERVED
        local prior = previous[guid]
        if prior and prior.source == MARK_SOURCE_LOCAL and prior.markIdx == info.markIdx then
            source = MARK_SOURCE_LOCAL
            AMA.pullMarkCount = AMA.pullMarkCount + 1
        end

        AMA.RecordMark(
            guid,
            info.markIdx,
            info.token,
            info.priority,
            info.subPriority,
            source)
    end

    for guid, prior in pairs(previous) do
        if prior.source == MARK_SOURCE_LOCAL
        and not AMA.markedGUIDs[guid]
        and not AMA.markOwners[prior.markIdx] then
            local token = FindVisibleTokenForGUID(guid, prior.token)
            local keep = true

            if token then
                keep = (GetRaidTargetIndex(token) or MARK_NONE) == prior.markIdx
            end

            if keep then
                AMA.RecordMark(
                    guid,
                    prior.markIdx,
                    token,
                    prior.priority,
                    prior.subPriority,
                    MARK_SOURCE_LOCAL)
                AMA.pullMarkCount = AMA.pullMarkCount + 1
            end
        end
    end
end

-- ============================================================
-- MANUAL MARK PREFERENCE HELPERS
-- ============================================================

-- Saves the mark the player assigned during manual mode.
-- Zone-keyed so preferences don't bleed across dungeons with shared mob names.
-- Exposed on AMA because ManualCycleMarkOnMouseover (Minimap) calls it.
function AMA.SaveManualPref(mobName, markIdx)
    if not AutoMarkAssistDB then return end
    if not AMA.currentZoneName or AMA.currentZoneName == "" then return end
    if not AutoMarkAssistDB.manualMarkPrefs then
        AutoMarkAssistDB.manualMarkPrefs = {}
    end
    if not AutoMarkAssistDB.manualMarkPrefs[AMA.currentZoneName] then
        AutoMarkAssistDB.manualMarkPrefs[AMA.currentZoneName] = {}
    end
    AutoMarkAssistDB.manualMarkPrefs[AMA.currentZoneName][mobName] = markIdx
    AMA.VPrint("Saved manual pref: " .. mobName .. " -> " ..
        (AMA.MARK_NAMES[markIdx] or tostring(markIdx)))
end

-- Derives the priority tier from which configured pool markIdx belongs to,
-- then saves it as a persistent mob override so auto-mode correctly
-- prioritises the mob on future dungeon runs without the player having to
-- use the DB tab.
-- Called by ManualCycleMarkOnMouseover each time a mark is manually assigned.
function AMA.SaveManualPriorityOverride(mobName, markIdx)
    if not AutoMarkAssistDB then return end
    if not AMA.currentZoneName or AMA.currentZoneName == "" then return end

    -- Marks not present in any configured pool fall back to MEDIUM.
    local detectedPri = AMA.GetPriorityTierForMark(markIdx)

    -- Skip writing an override when the detected tier already matches the
    -- mob's current effective DB entry -- no change, keep the table clean.
    local currentEff = AMA.currentZoneMobDB and AMA.currentZoneMobDB[mobName]
    if currentEff == detectedPri then return end

    -- Persist the override so future sessions and future auto-mark runs
    -- treat the mob with the player's intended priority.
    local cz = AMA.currentZoneName
    local baseDB = AutoMarkAssist_MobDB and AutoMarkAssist_MobDB[cz]

    if baseDB and baseDB[mobName] then
        -- Mob exists in the base zone DB: store as a zone-scoped override.
        local overrides = AMA.GetZoneMobOverrides(cz, true)
        local removals  = AMA.GetZoneMobRemovals(cz, true)
        overrides[mobName] = detectedPri
        removals[mobName]  = nil
    else
        -- Mob not in the base zone DB: register as a zone-specific addition
        -- so it appears in the Database tab for this zone.
        AutoMarkAssistDB.zoneAdditions = AutoMarkAssistDB.zoneAdditions or {}
        AutoMarkAssistDB.zoneAdditions[cz] = AutoMarkAssistDB.zoneAdditions[cz] or {}
        AutoMarkAssistDB.zoneAdditions[cz][mobName] = detectedPri
    end

    -- Rebuild the live zone DB immediately so the rest of this session also
    -- reflects the new override without needing a zone transition.
    AMA.currentZoneMobDB = AMA.BuildZoneMobDB(cz)

    AMA.VPrint(string.format(
        "Auto-saved override: |cFFFFFFFF%s|r -> |cFFFFD700%s|r",
        mobName, detectedPri))
end

-- Returns the saved manual mark preference for this mob in the current zone,
-- or nil when no preference exists.
local function GetManualPref(mobName)
    if not AutoMarkAssistDB then return nil end
    if not AMA.currentZoneName or AMA.currentZoneName == "" then return nil end
    local zonePrefs = AutoMarkAssistDB.manualMarkPrefs
    if not zonePrefs then return nil end
    local zp = zonePrefs[AMA.currentZoneName]
    if not zp then return nil end
    return zp[mobName]
end

-- ============================================================
-- ASSIGN MARK
-- ============================================================

-- Rate-limit the "cannot mark" verbose message so it does not spam
-- chat every 0.5 s when the proximity scanner fires.
local BLOCK_WARN_INTERVAL = 20   -- seconds between repeated warnings

function AMA.AssignMark(unitToken, skipSync, source)
    local canMark, blockReason = AMA.CanMarkReason()
    if not canMark then
        local now = GetTime()
        if now - AMA.lastBlockWarnTime >= BLOCK_WARN_INTERVAL then
            AMA.VPrint("Cannot mark: " .. blockReason)
            AMA.lastBlockWarnTime = now
        end
        return
    end
    if AMA.IsCombatMarkLockActive() then return end
    if not UnitExists(unitToken)              then return end
    if not UnitCanAttack("player", unitToken) then return end
    local isDead = UnitIsDead and UnitIsDead(unitToken)
    if isDead then return end
    local rangeSource = source or "proximity"
    local isInRange, rangeReason = IsUnitInAutoMarkRange(unitToken, rangeSource)
    if not isInRange then
        AMA.VPrint("Skipped (" .. tostring(rangeReason or "out of range") .. "): "
            .. (UnitName(unitToken) or unitToken))
        return
    end

    if not skipSync and AMA.SyncVisibleMarks then
        AMA.SyncVisibleMarks()
    end

    local guid = UnitGUID and UnitGUID(unitToken)
    if not guid then return end

    local trackedMark = AMA.markedGUIDs[guid]
    if trackedMark then
        AMA.markTokens[trackedMark] = unitToken
        return
    end

    local mobName = UnitName(unitToken)
    if not mobName or mobName == "" or mobName == "Unknown" then return end

    local existingMark = GetRaidTargetIndex(unitToken)
    if existingMark and existingMark > MARK_NONE then
        if not AMA.markOwners[existingMark] or AMA.markOwners[existingMark] == guid then
            local observedPri, observedSub = GetMobPriority(mobName, unitToken)
            if observedPri == "SKIP" then
                observedPri = PRIORITY_MEDIUM
                observedSub = GetMobSubPriority(mobName, observedPri)
            end

            AMA.RecordMark(
                guid,
                existingMark,
                unitToken,
                observedPri,
                observedSub,
                MARK_SOURCE_OBSERVED)
        end

        return
    end

    -- Skip critter-type creatures globally when the option is enabled.
    if AutoMarkAssistDB and AutoMarkAssistDB.skipCritters then
        local ctype = UnitCreatureType and UnitCreatureType(unitToken)
        if ctype == "Critter" then
            AMA.VPrint("Skipped (critter): " .. mobName)
            return
        end
    end

    local priority, subPriority = GetMobPriority(mobName, unitToken)
    local allocationOptions, allocationStrategy = nil, nil

    if priority == "SKIP" then
        if AutoMarkAssistDB and AutoMarkAssistDB.skipFillerMobs ~= false then
            AMA.VPrint("Skipped (SKIP priority): " .. mobName)
            return
        end
        priority = PRIORITY_MEDIUM
        subPriority = GetMobSubPriority(mobName, priority)
    end

    priority, subPriority, allocationOptions, allocationStrategy =
        ResolveAutoMarkStrategy(mobName, unitToken, priority, subPriority, rangeSource)

    local prefMark = GetManualPref(mobName)
    local markIdx, evictGUID

    if prefMark and not AMA.markOwners[prefMark] then
        markIdx = prefMark
        AMA.VPrint("Using manual pref for " .. mobName .. ": " ..
            (AMA.MARK_NAMES[prefMark] or prefMark))
    elseif AutoMarkAssistDB and AutoMarkAssistDB.dynamicMarking
            and not AutoMarkAssistDB.manualMode then
        markIdx, evictGUID = AllocateMarkDynamic(priority, subPriority, allocationOptions)
    else
        markIdx = AllocateMark(priority, allocationOptions)
    end

    if allocationStrategy == "smart-cc" and not markIdx then
        AMA.VPrint("Compatible CC slots exhausted, treating as kill-order: " .. mobName)
        priority = PRIORITY_MEDIUM
        subPriority = GetMobSubPriority(mobName, priority)
        if AutoMarkAssistDB and AutoMarkAssistDB.dynamicMarking
                and not AutoMarkAssistDB.manualMode then
            markIdx, evictGUID = AllocateMarkDynamic(priority, subPriority)
        else
            markIdx = AllocateMark(priority)
        end
    end

    if not markIdx then
        AMA.VPrint("All marks exhausted, cannot mark: " .. mobName)
        return
    end

    -- Evict the lower-priority mob if the dynamic allocator chose to bump it.
    local evictedToken = nil
    local evictedMark = nil
    local evictedPri = nil
    local evictedSub = nil
    if evictGUID then
        evictedMark = AMA.markedGUIDs[evictGUID]
        evictedPri  = AMA.guidPriority[evictGUID] or "?"
        evictedSub  = AMA.guidSubPriority[evictGUID]
        evictedToken = AMA.markTokens[evictedMark]
        AMA.VPrint(string.format(
            "Bumping %s (priority=%s, sub=%s, mark=%s) -> freed for %s (priority=%s, sub=%s)",
            evictGUID, evictedPri, tostring(evictedSub or "-"),
            AMA.MARK_NAMES[evictedMark] or "?", mobName, priority, tostring(subPriority or "-")))
    end

    local applied, applyReason = AMA.TrySetRaidTarget(unitToken, markIdx)
    if not applied then
        AMA.VPrint(string.format(
            "Failed to mark %s -> %s (%s)",
            mobName,
            AMA.MARK_NAMES[markIdx] or markIdx,
            tostring(applyReason or "unknown error")))
        return
    end

    if evictGUID then
        ForgetTrackedMark(evictGUID)
    end

    AMA.RecordMark(guid, markIdx, unitToken, priority, subPriority, MARK_SOURCE_LOCAL)
    if not evictGUID then
        AMA.pullMarkCount = AMA.pullMarkCount + 1
    end
    AMA.VPrint(string.format("Marked %s -> %s (priority=%s, sub=%s, pull#%d%s)",
        mobName, AMA.MARK_NAMES[markIdx] or markIdx, priority, tostring(subPriority or "-"),
        AMA.pullMarkCount, evictGUID and " [bumped]" or ""))

    -- Immediately re-assign the displaced mob so no mob is left temporarily
    -- unmarked.  AssignMark is re-entrant-safe: it checks markedGUIDs first.
    if evictedToken then
        AMA.AssignMark(evictedToken, false, rangeSource)
    end
end

-- ============================================================
-- RESET
-- ============================================================

function AMA.ResetState()
    local cleared = {}

    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token) then
            local guid = UnitGUID and UnitGUID(token)
            local markIdx = guid and AMA.markedGUIDs[guid]
            if guid and markIdx and AMA.IsLocalMark(guid) and not cleared[guid] then
                local currentIdx = GetRaidTargetIndex(token) or MARK_NONE
                if currentIdx == markIdx then
                    AMA.TrySetRaidTarget(token, MARK_NONE)
                    cleared[guid] = true
                end
            end
        end
    end

    wipe(AMA.markedGUIDs)
    wipe(AMA.markOwners)
    wipe(AMA.markTokens)
    wipe(AMA.guidPriority)
    wipe(AMA.guidSubPriority)
    wipe(AMA.guidMarkSource)
    AMA.pullMarkCount = 0
    AMA.VPrint("Mark state cleared.")
end

function AMA.ResetWithMessage()
    if not (AMA.IsAddonEnabled and AMA.IsAddonEnabled()) then
        AMA.Print("AutoMarkAssist is disabled.")
        return
    end
    AMA.ResetState()
    AMA.Print("Mark tracking reset.")
end

-- ============================================================
-- REBALANCE
-- Full reshuffle: after a mob dies, all surviving tracked mobs are
-- re-assigned from scratch in priority order so the best available icon
-- always goes to the highest-priority survivor.
-- ============================================================

function AMA.RebalanceMarks()
    if not (AMA.IsAddonEnabled and AMA.IsAddonEnabled()) then
        AMA.Print("AutoMarkAssist is disabled.")
        return
    end

    if AMA.SyncVisibleMarks then
        AMA.SyncVisibleMarks()
    end

    -- Build a guid -> current token map by scanning all visible unit tokens.
    -- Re-discover instead of trusting stale markTokens entries (nameplate tokens
    -- are recycled by WoW and may point to different mobs between events).
    local guidToToken = {}
    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS) do
        if UnitExists(token) then
            local g = UnitGUID and UnitGUID(token)
            if g and AMA.markedGUIDs[g]
            and not (UnitIsDead and UnitIsDead(token)) then
                guidToToken[g] = token
            end
        end
    end

    -- Snapshot all live tracked mobs with fresh token references.
    local liveMobs = {}
    for guid, _ in pairs(AMA.markedGUIDs) do
        if AMA.IsLocalMark(guid) then
        local token = guidToToken[guid]
        if token then
            local name     = UnitName(token) or "Unknown"
            local priority = AMA.guidPriority[guid]
            local subPriority = AMA.guidSubPriority[guid]
            if not priority then
                priority, subPriority = GetMobPriority(name, token)
            end
            table.insert(liveMobs, {
                guid=guid,
                token=token,
                markIdx=AMA.markedGUIDs[guid],
                priority=priority,
                subPriority=subPriority,
                name=name,
            })
        end
        end
    end

    if #liveMobs == 0 then
        AMA.VPrint("RebalanceMarks: no live local marks remain.")
        return
    end

    -- Sort: lowest rank number first = highest in-game priority first.
    table.sort(liveMobs, function(a, b)
        local ra = GetPriorityRank(a.priority)
        local rb = GetPriorityRank(b.priority)
        if ra ~= rb then return ra < rb end
        local sa = GetSubPriorityRank(a.subPriority)
        local sb = GetSubPriorityRank(b.subPriority)
        if sa ~= sb then return sa < sb end
        return a.name < b.name   -- alphabetical tie-break for stability
    end)

    -- Clear local in-game icons and local tracking tables.
    for _, mob in ipairs(liveMobs) do
        if (GetRaidTargetIndex(mob.token) or MARK_NONE) == (mob.markIdx or MARK_NONE) then
            AMA.TrySetRaidTarget(mob.token, MARK_NONE)
        end
        ForgetTrackedMark(mob.guid)
    end
    AMA.pullMarkCount = 0

    -- Re-assign in priority order.
    for _, mob in ipairs(liveMobs) do
        if UnitExists(mob.token)
        and not (UnitIsDead and UnitIsDead(mob.token)) then
            local effectivePriority, effectiveSubPriority, allocationOptions, allocationStrategy =
                ResolveAutoMarkStrategy(mob.name, mob.token, mob.priority, mob.subPriority)
            local markIdx = AllocateMark(effectivePriority, allocationOptions)

            if allocationStrategy == "smart-cc" and not markIdx then
                AMA.VPrint("Compatible CC slots exhausted, treating as kill-order: " .. mob.name)
                effectivePriority = PRIORITY_MEDIUM
                effectiveSubPriority = GetMobSubPriority(mob.name, effectivePriority)
                markIdx = AllocateMark(effectivePriority)
            end

            if markIdx then
                local applied, applyReason = AMA.TrySetRaidTarget(mob.token, markIdx)
                if applied then
                    AMA.RecordMark(
                        mob.guid,
                        markIdx,
                        mob.token,
                        effectivePriority,
                        effectiveSubPriority,
                        MARK_SOURCE_LOCAL)
                    AMA.pullMarkCount = AMA.pullMarkCount + 1
                    AMA.VPrint(string.format("Rebalanced: %s -> %s (priority=%s, sub=%s)",
                        mob.name, AMA.MARK_NAMES[markIdx] or markIdx, effectivePriority,
                        tostring(effectiveSubPriority or "-")))
                else
                    AMA.VPrint(string.format(
                        "Rebalanced: failed to apply %s to %s (%s)",
                        AMA.MARK_NAMES[markIdx] or markIdx,
                        mob.name,
                        tostring(applyReason or "unknown error")))
                end
            else
                AMA.VPrint("Rebalanced: marks exhausted, skipping " .. mob.name)
            end
        end
    end

    -- Try to assign any currently-visible mob that was previously skipped.
    if AutoMarkAssistDB and AutoMarkAssistDB.proximityMode then
        AMA.AssignMark("target", true, "proximity")
        AMA.AssignMark("mouseover", true, "proximity")
    end
end

-- ============================================================
-- CASCADE MARKS AFTER DEATH  (dynamic mode, rebalance OFF)
-- When a mob dies and dynamicMarking is ON, the freed slot propagates
-- upward through surviving tracked mobs so the best available icon
-- always goes to the highest-priority survivor.
--
-- Algorithm: repeat until no improvement found (capped at 8 passes):
--   1. Snapshot all tracked live mobs, sorted best-priority first.
--   2. For each mob, temporarily release its bookkeeping and ask
--      AllocateMark what it would get with current free slots.
--   3. If a better slot is available, move it there and restart the loop.
--   4. If no mob improved, stop.
-- Finally, sweep SCAN_UNIT_TOKENS to fill any remaining free slots.
-- ============================================================

function AMA.CascadeMarksAfterDeath()
    if not (AMA.IsAddonEnabled and AMA.IsAddonEnabled()) then
        return
    end

    if AMA.SyncVisibleMarks then
        AMA.SyncVisibleMarks()
    end

    -- Discover fresh guid -> token mapping (avoids stale nameplate token reliance).
    local guidToToken = {}
    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS) do
        if UnitExists(token) then
            local g = UnitGUID and UnitGUID(token)
            if g then guidToToken[g] = token end
        end
    end

    local changed    = true
    local iterations = 0
    while changed and iterations < 8 do
        iterations = iterations + 1
        changed    = false

        local tracked = {}
        for guid, markIdx in pairs(AMA.markedGUIDs) do
            if AMA.IsLocalMark(guid) then
            local token = guidToToken[guid]
            if not token then
                local stored = AMA.markTokens[markIdx]
                if stored and UnitExists(stored)
                and UnitGUID and UnitGUID(stored) == guid then
                    token = stored
                end
            end
            if token and UnitExists(token)
            and not (UnitIsDead and UnitIsDead(token)) then
                table.insert(tracked, {
                    guid     = guid,
                    token    = token,
                    markIdx  = markIdx,
                    priority = AMA.guidPriority[guid] or PRIORITY_MEDIUM,
                    subPriority = AMA.guidSubPriority[guid],
                    name     = UnitName(token) or "Unknown",
                })
            end
            end
        end
        table.sort(tracked, function(a, b)
            local ra = GetPriorityRank(a.priority)
            local rb = GetPriorityRank(b.priority)
            if ra ~= rb then return ra < rb end
            local sa = GetSubPriorityRank(a.subPriority)
            local sb = GetSubPriorityRank(b.subPriority)
            if sa ~= sb then return sa < sb end
            return (a.guid or "") < (b.guid or "")
        end)

        for _, mob in ipairs(tracked) do
            -- Temporarily release bookkeeping (NOT the in-game icon) so
            -- AllocateMark treats this mob's slot as available.
            AMA.markOwners[mob.markIdx] = nil
            AMA.markedGUIDs[mob.guid]   = nil
            AMA.markTokens[mob.markIdx] = nil
            AMA.guidMarkSource[mob.guid] = nil

            local effectivePriority, effectiveSubPriority, allocationOptions, allocationStrategy =
                ResolveAutoMarkStrategy(mob.name, mob.token, mob.priority, mob.subPriority)
            local newMark = AllocateMark(effectivePriority, allocationOptions)

            if allocationStrategy == "smart-cc" and not newMark then
                AMA.VPrint("Compatible CC slots exhausted, treating as kill-order: " .. (mob.name or mob.guid or "mob"))
                effectivePriority = PRIORITY_MEDIUM
                effectiveSubPriority = GetMobSubPriority(mob.name, effectivePriority)
                newMark = AllocateMark(effectivePriority)
            end

            if newMark and newMark ~= mob.markIdx then
                -- Better slot available: move the in-game icon and record.
                local applied, applyReason = AMA.TrySetRaidTarget(mob.token, newMark)
                if applied then
                    AMA.RecordMark(
                        mob.guid,
                        newMark,
                        mob.token,
                        effectivePriority,
                        effectiveSubPriority,
                        MARK_SOURCE_LOCAL)
                    AMA.VPrint(string.format("CascadeAfterDeath: %s (sub=%s) %s -> %s",
                        effectivePriority, tostring(effectiveSubPriority or "-"),
                        AMA.MARK_NAMES[mob.markIdx] or mob.markIdx,
                        AMA.MARK_NAMES[newMark]     or newMark))
                    changed = true
                    break   -- restart outer loop with updated state
                else
                    AMA.VPrint(string.format(
                        "CascadeAfterDeath: failed to move %s to %s (%s)",
                        mob.name or mob.guid or "mob",
                        AMA.MARK_NAMES[newMark] or newMark,
                        tostring(applyReason or "unknown error")))
                end
            end

            -- No improvement: restore bookkeeping, leave icon unchanged.
            AMA.RecordMark(
                mob.guid,
                mob.markIdx,
                mob.token,
                effectivePriority,
                effectiveSubPriority,
                MARK_SOURCE_LOCAL)
        end
    end

    -- Fill any remaining free slots from currently visible unmarked mobs.
    if AutoMarkAssistDB and AutoMarkAssistDB.proximityMode then
        for _, token in ipairs(AMA.SCAN_UNIT_TOKENS) do
            AMA.AssignMark(token, true, "proximity")
        end
    end
end
