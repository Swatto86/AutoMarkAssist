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

    -- Fail-open range gate.  CheckInteractDistance is unreliable for hostile
    -- units on the Classic Anniversary (1.15) client and frequently returns nil
    -- regardless of true distance.  Treating that nil as "out of range" would
    -- silently block marking the mob you are deliberately pointing at -- the same
    -- failure that disabled proximity mode.  So we only reject when the API gives
    -- a DEFINITE negative; a nil/no-answer falls through to marking.  The range
    -- limit still applies whenever the client actually reports a distance.
    local ok, result = pcall(CheckInteractDistance, "mouseover", range)
    if not ok then return true end          -- API errored: don't block.
    if result == nil then return true end   -- API gave no answer: don't block.
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

    -- Cheap early-out: UPDATE_MOUSEOVER_UNIT fires for every unit the cursor
    -- touches -- friendly NPCs, party frames, corpses, the ground.  Bail before
    -- the expensive holistic pack scan unless the hovered unit is actually an
    -- attackable, living mob worth marking.
    if not UnitExists("mouseover") then return end
    if not UnitCanAttack("player", "mouseover") then return end
    if UnitIsDead and UnitIsDead("mouseover") then return end

    if not IsMouseoverWithinConfiguredRange() then return end

    if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
    AMA.AssignMarkHolistic("mouseover")
end
