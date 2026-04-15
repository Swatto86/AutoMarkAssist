-- AutoMarkAssist_Proximity.lua
-- Proximity scanning mode: periodically scans visible unit tokens
-- and auto-assigns marks to hostile mobs within range.
-- Loaded after AutoMarkAssist_MobScanning.lua.

local AMA = AutoMarkAssist

-- ============================================================
-- SCAN INTERVAL
-- ============================================================

local SCAN_INTERVAL = 0.5
local scanElapsed = 0

-- ============================================================
-- PROXIMITY SCANNER (OnUpdate)
-- ============================================================

local frame = CreateFrame("Frame", "AMA_ProximityScanFrame", UIParent)

frame:SetScript("OnUpdate", function(self, elapsed)
    scanElapsed = scanElapsed + elapsed
    if scanElapsed < SCAN_INTERVAL then return end
    scanElapsed = 0

    if not AutoMarkAssistDB then return end
    if not AutoMarkAssistDB.enabled then return end
    if AMA.GetMarkingMode() ~= "proximity" then return end
    if AMA.IsCombatMarkLockActive and AMA.IsCombatMarkLockActive() then return end

    local canMark = AMA.CanMarkReason()
    if not canMark then return end

    if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end

    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS) do
        if UnitExists(token) and UnitCanAttack("player", token) then
            if not (UnitIsDead and UnitIsDead(token)) then
                AMA.AssignMark(token, false, "proximity")
            end
        end
    end
end)
