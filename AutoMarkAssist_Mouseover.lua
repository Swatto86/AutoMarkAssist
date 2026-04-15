-- AutoMarkAssist_Mouseover.lua
-- Mouseover marking mode: marks hostile mobs when you mouse over them.
-- Called from the UPDATE_MOUSEOVER_UNIT event handler in Events.
-- Loaded after AutoMarkAssist_MobScanning.lua.

local AMA = AutoMarkAssist

-- ============================================================
-- MOUSEOVER MARK HANDLER
-- ============================================================

function AMA.HandleMouseoverMark()
    if not AMA.IsAddonEnabled() then return end
    if AMA.GetMarkingMode() ~= "mouseover" then return end
    if AMA.IsCombatMarkLockActive and AMA.IsCombatMarkLockActive() then return end

    local canMark = AMA.CanMarkReason()
    if not canMark then return end

    if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
    AMA.AssignMark("mouseover", false, "mouseover")
end
