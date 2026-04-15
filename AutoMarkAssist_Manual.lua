-- AutoMarkAssist_Manual.lua
-- Manual marking mode: scroll-wheel mark picker HUD with modifier key.
-- Loaded after AutoMarkAssist_MobScanning.lua.

local AMA = AutoMarkAssist

-- ============================================================
-- FILE-SCOPE CONSTANTS
-- ============================================================

local W8 = "Interface\\Buttons\\WHITE8x8"

local HUD_BG       = { 0.05, 0.05, 0.05, 0.94 }
local HUD_BORDER   = { 0.15, 0.15, 0.15, 1.00 }
local HUD_ACCENT   = { 0.10, 0.62, 0.75, 1.00 }
local HUD_CELL_N   = { 0.10, 0.10, 0.10, 1.00 }
local HUD_CELL_SEL = { 0.06, 0.20, 0.25, 1.00 }
local HUD_MIN_SCALE = 0.60
local HUD_SCREEN_PAD = 20

local HUD_FLAT_BD = {
    bgFile   = W8,
    edgeFile = W8,
    tile     = false,
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

-- ============================================================
-- FORWARD DECLARATIONS
-- ============================================================

local markHUD, UpdateMarkPickerHUD, ApplyResponsiveHUDLayout
local CommitPendingManualMark, HideMarkPickerHUD

local manualPendingMark = {
    guid = nil,
    token = nil,
    name = nil,
    selectedMark = nil,
}

local function ClearPendingManualMark()
    manualPendingMark.guid = nil
    manualPendingMark.token = nil
    manualPendingMark.name = nil
    manualPendingMark.selectedMark = nil
end

local function FindVisibleTokenForGUID(guid, preferredToken)
    if not guid then return nil end
    if preferredToken and UnitExists(preferredToken)
    and UnitGUID and UnitGUID(preferredToken) == guid then
        return preferredToken
    end
    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS or {}) do
        if UnitExists(token) and UnitGUID and UnitGUID(token) == guid then
            return token
        end
    end
    return nil
end

local function SetPendingManualMark(guid, token, name, selectedMark)
    manualPendingMark.guid = guid
    manualPendingMark.token = token
    manualPendingMark.name = name
    manualPendingMark.selectedMark = selectedMark
end

local function GetPendingManualSelection(guid, preferredToken)
    if manualPendingMark.guid == guid and manualPendingMark.selectedMark ~= nil then
        return manualPendingMark.selectedMark
    end
    local token = FindVisibleTokenForGUID(guid, preferredToken)
    if token and GetRaidTargetIndex then
        return GetRaidTargetIndex(token) or 0
    end
    return AMA.markedGUIDs[guid] or 0
end

CommitPendingManualMark = function(reason)
    local guid = manualPendingMark.guid
    local selectedMark = manualPendingMark.selectedMark
    if not guid or selectedMark == nil then return false end

    if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end

    local token = FindVisibleTokenForGUID(guid, manualPendingMark.token)
    local name = manualPendingMark.name or "Target"
    if not token then
        AMA.VPrint("Manual mark dropped: target no longer visible.")
        ClearPendingManualMark()
        return false
    end

    local currentMark = GetRaidTargetIndex(token) or 0
    if selectedMark == currentMark then
        ClearPendingManualMark()
        return true
    end

    if selectedMark == 0 then
        if currentMark > 0 then
            local cleared = AMA.TrySetRaidTarget and AMA.TrySetRaidTarget(token, 0)
            if not cleared then
                ClearPendingManualMark()
                return false
            end
            if AMA.ForgetMark then AMA.ForgetMark(guid) end
        end
        ClearPendingManualMark()
        return true
    end

    local displacedGUID = AMA.markOwners[selectedMark]
    local applied = AMA.TrySetRaidTarget and AMA.TrySetRaidTarget(token, selectedMark)
    if not applied then
        ClearPendingManualMark()
        return false
    end

    if currentMark > 0 and currentMark ~= selectedMark and AMA.ForgetMark then
        AMA.ForgetMark(guid)
    end
    if displacedGUID and displacedGUID ~= guid and AMA.ForgetMark then
        AMA.ForgetMark(displacedGUID)
    end

    AMA.RecordMark(guid, selectedMark, token)

    -- Learn: save the player's mark choice to the DB when inside an instance.
    local inInstance = IsInInstance and IsInInstance()
    local zone = AMA.currentZoneName
    if inInstance and zone and zone ~= "" and name and AMA.SetPlayerMobMark then
        local existing = AMA.LookupMobMark and AMA.LookupMobMark(name)
        if existing ~= selectedMark then
            AMA.SetPlayerMobMark(zone, name, selectedMark)
            AMA.VPrint(string.format("Learned: %s = %s in %s",
                name, AMA.MARK_NAMES[selectedMark] or tostring(selectedMark), zone))
        end
    end

    AMA.VPrint(string.format("Manual mark: %s -> %s%s",
        name, AMA.MARK_NAMES[selectedMark] or tostring(selectedMark),
        reason and (" (" .. reason .. ")") or ""))

    ClearPendingManualMark()
    return true
end

HideMarkPickerHUD = function(commitPending, reason)
    if commitPending and CommitPendingManualMark then
        CommitPendingManualMark(reason)
    end
    if markHUD then markHUD:Hide() end
    if AMA._scrollCatcher then AMA._scrollCatcher:Hide() end
end

-- ============================================================
-- MANUAL MODE: SCROLL-WHEEL CYCLING
-- ============================================================

local function ManualCycleMarkOnMouseover(delta)
    if AMA.GetMarkingMode() ~= "manual" then return end
    if not UnitExists("mouseover") then return end
    if not UnitCanAttack("player", "mouseover") then return end

    local guid = UnitGUID and UnitGUID("mouseover")
    if not guid then return end

    local name = UnitName("mouseover") or "Target"
    local scrollOrder = AMA.GetActiveManualScrollOrder()
    local currentSelection = GetPendingManualSelection(guid, "mouseover")

    local pos = 0
    for i, m in ipairs(scrollOrder) do
        if m == currentSelection then pos = i; break end
    end

    local invert = AutoMarkAssistDB and AutoMarkAssistDB.invertScroll
    if invert then delta = -delta end

    pos = pos + delta
    if pos < 0 then pos = #scrollOrder end
    if pos > #scrollOrder then pos = 0 end

    local newMark = (pos > 0) and scrollOrder[pos] or 0
    SetPendingManualMark(guid, "mouseover", name, newMark)

    if UpdateMarkPickerHUD then UpdateMarkPickerHUD() end
end

-- ============================================================
-- MARK PICKER HUD
-- ============================================================

do
    markHUD = CreateFrame("Frame", "AMA_MarkPickerHUD", UIParent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    markHUD:SetSize(280, 50)
    markHUD:SetFrameStrata("TOOLTIP")
    markHUD:SetFrameLevel(200)
    markHUD:EnableMouse(false)
    markHUD:Hide()

    if markHUD.SetBackdrop then
        markHUD:SetBackdrop(HUD_FLAT_BD)
        markHUD:SetBackdropColor(HUD_BG[1], HUD_BG[2], HUD_BG[3], HUD_BG[4])
        markHUD:SetBackdropBorderColor(HUD_BORDER[1], HUD_BORDER[2], HUD_BORDER[3], 1)
    end

    local CELL_SIZE = 50
    local CELL_PAD = 4
    local hudCells = {}

    for i = 1, 8 do
        local cell = CreateFrame("Frame", nil, markHUD,
            BackdropTemplateMixin and "BackdropTemplate" or nil)
        cell:SetSize(CELL_SIZE, CELL_SIZE)
        if cell.SetBackdrop then
            cell:SetBackdrop(HUD_FLAT_BD)
            cell:SetBackdropColor(HUD_CELL_N[1], HUD_CELL_N[2], HUD_CELL_N[3], 1)
            cell:SetBackdropBorderColor(HUD_BORDER[1], HUD_BORDER[2], HUD_BORDER[3], 1)
        end

        local icon = cell:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("CENTER", cell, "CENTER", 0, 0)
        cell._icon = icon

        local bar = cell:CreateTexture(nil, "OVERLAY")
        bar:SetTexture(W8)
        bar:SetHeight(2)
        bar:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 1, 1)
        bar:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -1, 1)
        bar:SetVertexColor(HUD_ACCENT[1], HUD_ACCENT[2], HUD_ACCENT[3], 1)
        bar:Hide()
        cell._bar = bar

        cell._markIdx = 0
        hudCells[i] = cell
    end

    UpdateMarkPickerHUD = function()
        local scrollOrder = AMA.GetActiveManualScrollOrder()
        local guid = manualPendingMark.guid
        local selectedMark = manualPendingMark.selectedMark or 0

        for i, cell in ipairs(hudCells) do
            local markIdx = scrollOrder[i]
            if markIdx then
                cell._markIdx = markIdx
                cell._icon:SetTexture(
                    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. markIdx)
                cell:Show()

                local isSelected = markIdx == selectedMark

                if cell.SetBackdropColor then
                    if isSelected then
                        cell:SetBackdropColor(HUD_CELL_SEL[1], HUD_CELL_SEL[2], HUD_CELL_SEL[3], 1)
                        cell:SetBackdropBorderColor(HUD_ACCENT[1], HUD_ACCENT[2], HUD_ACCENT[3], 1)
                    else
                        cell:SetBackdropColor(HUD_CELL_N[1], HUD_CELL_N[2], HUD_CELL_N[3], 1)
                        cell:SetBackdropBorderColor(HUD_BORDER[1], HUD_BORDER[2], HUD_BORDER[3], 1)
                    end
                end

                if isSelected then cell._bar:Show() else cell._bar:Hide() end
                cell._icon:SetAlpha(1.0)
            else
                cell:Hide()
            end
        end

        if not markHUD:IsShown() then
            markHUD:Show()
            if ApplyResponsiveHUDLayout then ApplyResponsiveHUDLayout() end
        end
    end

    ApplyResponsiveHUDLayout = function()
        if not markHUD then return end
        local scrollOrder = AMA.GetActiveManualScrollOrder()
        local count = #scrollOrder
        if count == 0 then count = 8 end

        local totalW = count * (CELL_SIZE + CELL_PAD) + CELL_PAD + 8
        local totalH = CELL_SIZE + CELL_PAD * 2 + 8
        markHUD:SetSize(totalW, totalH)

        for i, cell in ipairs(hudCells) do
            cell:ClearAllPoints()
            cell:SetPoint("LEFT", markHUD, "LEFT",
                4 + (i - 1) * (CELL_SIZE + CELL_PAD) + CELL_PAD, 0)
        end

        local uiW = UIParent and UIParent:GetWidth() or 800
        local uiH = UIParent and UIParent:GetHeight() or 600
        local scale = math.max(HUD_MIN_SCALE, math.min(1, (uiW - HUD_SCREEN_PAD * 2) / totalW))
        markHUD:SetScale(scale)

        markHUD:ClearAllPoints()
        markHUD:SetPoint("BOTTOM", UIParent, "CENTER", 0, 150)
    end

    -- Scroll catcher: invisible fullscreen frame that captures scroll events.
    local scrollCatcher = CreateFrame("Frame", "AMA_ScrollCatcher", UIParent)
    scrollCatcher:SetAllPoints(UIParent)
    scrollCatcher:SetFrameStrata("TOOLTIP")
    scrollCatcher:SetFrameLevel(199)
    scrollCatcher:EnableMouseWheel(true)
    scrollCatcher:EnableMouse(false)
    scrollCatcher:Hide()

    scrollCatcher:SetScript("OnMouseWheel", function(self, delta)
        ManualCycleMarkOnMouseover(delta)
    end)

    local modCheckElapsed = 0
    scrollCatcher:SetScript("OnUpdate", function(self, elapsed)
        modCheckElapsed = modCheckElapsed + elapsed
        if modCheckElapsed < 0.05 then return end
        modCheckElapsed = 0

        if AMA.GetMarkingMode() ~= "manual" then
            HideMarkPickerHUD(false)
            self:Hide()
            return
        end

        local mod = AutoMarkAssistDB and AutoMarkAssistDB.manualModifier or "ALT"
        local modDown = false
        if mod == "NONE" then modDown = true
        elseif mod == "ALT" then modDown = IsAltKeyDown and IsAltKeyDown()
        elseif mod == "SHIFT" then modDown = IsShiftKeyDown and IsShiftKeyDown()
        elseif mod == "CTRL" then modDown = IsControlKeyDown and IsControlKeyDown()
        end

        if not modDown then
            HideMarkPickerHUD(true, "modifier released")
            return
        end

        if UnitExists("mouseover") and UnitCanAttack("player", "mouseover") then
            local guid = UnitGUID and UnitGUID("mouseover")
            if guid and guid ~= manualPendingMark.guid then
                CommitPendingManualMark("target changed")
                local name = UnitName("mouseover") or "Target"
                local current = GetRaidTargetIndex and GetRaidTargetIndex("mouseover") or 0
                SetPendingManualMark(guid, "mouseover", name, current)
                if UpdateMarkPickerHUD then UpdateMarkPickerHUD() end
            end
        else
            HideMarkPickerHUD(true, "target lost")
        end
    end)

    AMA._scrollCatcher = scrollCatcher

    function AMA.ShowMarkPickerForMouseover()
        if AMA.GetMarkingMode() ~= "manual" then return end

        local mod = AutoMarkAssistDB and AutoMarkAssistDB.manualModifier or "ALT"
        local modDown = false
        if mod == "NONE" then modDown = true
        elseif mod == "ALT" then modDown = IsAltKeyDown and IsAltKeyDown()
        elseif mod == "SHIFT" then modDown = IsShiftKeyDown and IsShiftKeyDown()
        elseif mod == "CTRL" then modDown = IsControlKeyDown and IsControlKeyDown()
        end
        if not modDown then return end

        if not UnitExists("mouseover") then return end
        if not UnitCanAttack("player", "mouseover") then return end

        local guid = UnitGUID and UnitGUID("mouseover")
        if not guid then return end

        scrollCatcher:Show()

        if guid ~= manualPendingMark.guid then
            CommitPendingManualMark("new target")
            local name = UnitName("mouseover") or "Target"
            local current = GetRaidTargetIndex and GetRaidTargetIndex("mouseover") or 0
            SetPendingManualMark(guid, "mouseover", name, current)
        end

        if UpdateMarkPickerHUD then UpdateMarkPickerHUD() end
    end
end
