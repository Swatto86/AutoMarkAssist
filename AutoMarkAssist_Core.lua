-- AutoMarkAssist_Core.lua
-- Shared mark state, permission checks, mark tracking, and combat lock.
-- Loaded after AutoMarkAssist.lua (namespace).

local AMA = AutoMarkAssist

-- ============================================================
-- FILE-SCOPE CONSTANTS
-- ============================================================

local MARK_NONE     = 0
local MARK_SOURCE_LOCAL    = "local"

-- ============================================================
-- MARK STATE
-- ============================================================

AMA.markedGUIDs    = {}   -- guid -> markIdx
AMA.markOwners     = {}   -- markIdx -> guid
AMA.markTokens     = {}   -- markIdx -> unitToken
AMA.guidMarkSource = {}   -- guid -> "local" | "observed"

-- ============================================================
-- UNIT TOKEN LIST
-- ============================================================

do
    AMA.SCAN_UNIT_TOKENS = {
        "target", "focus", "mouseover",
        "player",
        "party1", "party2", "party3", "party4",
        "party1target", "party2target", "party3target", "party4target",
    }
    for i = 1, 40 do
        AMA.SCAN_UNIT_TOKENS[#AMA.SCAN_UNIT_TOKENS + 1] = "raid" .. i
        AMA.SCAN_UNIT_TOKENS[#AMA.SCAN_UNIT_TOKENS + 1] = "raid" .. i .. "target"
    end
    for i = 1, 20 do
        AMA.SCAN_UNIT_TOKENS[#AMA.SCAN_UNIT_TOKENS + 1] = "nameplate" .. i
    end
end

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
end

local function ForgetTrackedMark(guid)
    local markIdx = AMA.markedGUIDs[guid]
    if not markIdx then return nil end
    if AMA.markOwners[markIdx] == guid then
        AMA.markOwners[markIdx] = nil
        AMA.markTokens[markIdx] = nil
    end
    AMA.markedGUIDs[guid] = nil
    AMA.guidMarkSource[guid] = nil
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
