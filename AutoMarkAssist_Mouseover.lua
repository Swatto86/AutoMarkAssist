-- AutoMarkAssist_Mouseover.lua
-- Mouseover marking mode: marks hostile mobs when you mouse over them.
-- Called from the UPDATE_MOUSEOVER_UNIT event handler in Events.
-- Loaded after AutoMarkAssist_MobScanning.lua.

local AMA = AutoMarkAssist

-- ============================================================
-- RANGE GATE
-- Mouseover mode optionally limits marking to units within the
-- configured CheckInteractDistance range.  0 means unlimited.
-- ============================================================

local function IsMouseoverWithinConfiguredRange()
    local range = AutoMarkAssistDB and AutoMarkAssistDB.mouseoverRange or 0
    if not range or range == 0 then return true end
    local ok, result = pcall(CheckInteractDistance, "mouseover", range)
    if not ok then return false end
    return result == 1 or result == true
end

-- ============================================================
-- MOUSEOVER MARK HANDLER
-- ============================================================

function AMA.HandleMouseoverMark()
    if not AMA.IsAddonEnabled() then return end
    if AMA.GetMarkingMode() ~= "mouseover" then return end
    if AMA.IsCombatMarkLockActive and AMA.IsCombatMarkLockActive() then return end

    local canMark = AMA.CanMarkReason()
    if not canMark then return end

    if not IsMouseoverWithinConfiguredRange() then return end

    if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
    AMA.AssignMarkHolistic("mouseover")
end
