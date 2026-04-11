-- AutoMarkAssist_Minimap.lua
-- Minimap button, scroll-wheel mark picker HUD, and options dropdown.
-- Loaded after AutoMarkAssist_Core.lua.

local AMA = AutoMarkAssist

-- ============================================================
-- FILE-SCOPE CONSTANTS
-- ============================================================

local MARK_SKULL = 8
local MARK_CROSS = 7

-- Flat texture reused for all HUD backgrounds and borders (ElvUI style).
local W8 = "Interface\\Buttons\\WHITE8x8"

-- ElvUI skin helpers (local to Minimap; mirrored in Config).
local HUD_BG       = {0.05, 0.05, 0.05, 0.94}
local HUD_BORDER   = {0.15, 0.15, 0.15, 1.00}
local HUD_ACCENT   = {0.10, 0.62, 0.75, 1.00}  -- teal highlight / selected
local HUD_CELL_N   = {0.10, 0.10, 0.10, 1.00}  -- cell bg: normal
local HUD_CELL_SEL = {0.06, 0.20, 0.25, 1.00}  -- cell bg: selected
local HUD_CELL_TKN = {0.18, 0.04, 0.04, 1.00}  -- cell bg: taken by others
local HUD_MIN_SCALE = 0.60
local HUD_SCREEN_PAD = 20

local HUD_FLAT_BD = {
    bgFile   = W8,
    edgeFile = W8,
    tile     = false,
    edgeSize = 1,
    insets   = { left=1, right=1, top=1, bottom=1 },
}

-- ============================================================
-- FORWARD DECLARATIONS
-- markHUD and its update functions are defined further below in a do block.
-- ManualCycleMarkOnMouseover (and the scroll catcher) reference them as
-- upvalues so the declarations must appear first.
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
        if UnitExists(token)
        and UnitGUID and UnitGUID(token) == guid then
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
    if not guid or selectedMark == nil then
        return false
    end

    if AMA.SyncVisibleMarks then
        AMA.SyncVisibleMarks()
    end

    local token = FindVisibleTokenForGUID(guid, manualPendingMark.token)
    local name = manualPendingMark.name or "Target"
    if not token then
        AMA.VPrint("Manual mark pending selection dropped: target is no longer visible.")
        ClearPendingManualMark()
        return false
    end

    local currentMark = GetRaidTargetIndex(token)
    if currentMark == nil then
        currentMark = 0
    end

    if selectedMark == currentMark then
        ClearPendingManualMark()
        return true
    end

    if selectedMark == 0 then
        if currentMark > 0 then
            local cleared, clearReason = AMA.TrySetRaidTarget and AMA.TrySetRaidTarget(token, 0)
            if cleared then
                if AMA.ForgetMark then
                    AMA.ForgetMark(guid)
                end
                AMA.VPrint(string.format(
                    "Manual mark applied on close: cleared %s%s",
                    name,
                    reason and (" (" .. reason .. ")") or ""))
            else
                AMA.VPrint(string.format(
                    "Manual mark apply failed for %s (%s)",
                    name,
                    tostring(clearReason or "unknown error")))
            end
        end

        ClearPendingManualMark()
        return true
    end

    local displacedGUID = AMA.markOwners[selectedMark]
    local applied, applyReason = AMA.TrySetRaidTarget and AMA.TrySetRaidTarget(token, selectedMark)
    if not applied then
        AMA.VPrint(string.format(
            "Manual mark apply failed for %s (%s)",
            name,
            tostring(applyReason or "unknown error")))
        ClearPendingManualMark()
        return false
    end

    if currentMark > 0 and currentMark ~= selectedMark and AMA.ForgetMark then
        AMA.ForgetMark(guid)
    end
    if displacedGUID and displacedGUID ~= guid and AMA.ForgetMark then
        AMA.ForgetMark(displacedGUID)
    end

    local trackedPriority = AMA.GetPriorityTierForMark
        and AMA.GetPriorityTierForMark(selectedMark)
        or AMA.PRIORITY_MEDIUM
    local trackedSubPriority = AMA.GetMobSubPriorityForZone
        and AMA.GetMobSubPriorityForZone(AMA.currentZoneName, name, trackedPriority)
        or nil

    AMA.RecordMark(guid, selectedMark, token, trackedPriority, trackedSubPriority)
    AMA.SaveManualPref(name, selectedMark)
    AMA.SaveManualPriorityOverride(name, selectedMark)
    AMA.VPrint(string.format(
        "Manual mark applied on close: %s -> %s%s",
        name,
        AMA.MARK_NAMES[selectedMark] or tostring(selectedMark),
        reason and (" (" .. reason .. ")") or ""))

    ClearPendingManualMark()
    return true
end

HideMarkPickerHUD = function(commitPending, reason)
    if commitPending and CommitPendingManualMark then
        CommitPendingManualMark(reason)
    end
    if markHUD then
        markHUD:Hide()
    end
end

-- ============================================================
-- MANUAL MODE: SCROLL-WHEEL MARKING
-- ============================================================
-- When manual mode is active the proximity scanner is paused.
-- The player hovers over an enemy and scrolls the mouse wheel to cycle
-- through the configured mark order.  Any mark can be selected even when it is
-- already used by another mob.  The chosen mark is applied when the picker
-- closes or when the player moves to a different target.

local function ManualCycleMarkOnMouseover(delta)
    if not UnitExists("mouseover") then
        AMA.VPrint("Manual scroll: no mouseover unit.")
        return
    end
    if not UnitCanAttack("player", "mouseover") then
        AMA.VPrint("Manual scroll: mouseover is not attackable.")
        return
    end
    local isDead = UnitIsDead and UnitIsDead("mouseover")
    if isDead then
        AMA.VPrint("Manual scroll: mouseover is dead.")
        return
    end
    local guid = UnitGUID("mouseover")
    if not guid then
        AMA.VPrint("Manual scroll: UnitGUID returned nil.")
        return
    end

    if manualPendingMark.guid and manualPendingMark.guid ~= guid then
        CommitPendingManualMark("target switch")
    end

    local canMark, blockReason = AMA.CanMarkReason({ ignoreEnabled = true })
    if not canMark then
        AMA.Print("Cannot mark: " .. blockReason)
        return
    end

    if AMA.SyncVisibleMarks then
        AMA.SyncVisibleMarks()
    end

    -- Invert scroll direction when the user preference is set (default).
    -- Inverted: scroll-down starts at the left-most mark and cycles right.
    if AMA.IsManualScrollInverted and AMA.IsManualScrollInverted() then
        delta = -delta
    end

    local currentMark = GetPendingManualSelection(guid, "mouseover")

    -- Build the full ordered list of marks for preview.  Manual mode may
    -- intentionally choose a mark that is already in use and steal it when
    -- the picker closes.
    local scrollOrder = AMA.GetManualScrollOrder and AMA.GetManualScrollOrder()
                        or {8, 7, 3, 4, 5, 6, 2, 1}

    -- Find the current mark's position (0 = unmarked).
    local currentPos = 0
    for i, m in ipairs(scrollOrder) do
        if m == currentMark then currentPos = i; break end
    end

    -- Advance by delta.  The list has a virtual "none" slot at both ends:
    --   none(0) <--> Star <--> ... <--> Skull <--> none(0)
    -- Scrolling past either end unmarks the mob rather than wrapping.
    local newPos
    if currentPos == 0 then
        newPos = (delta > 0) and 1 or #scrollOrder
    else
        newPos = currentPos + (delta > 0 and 1 or -1)
        if newPos > #scrollOrder then newPos = 0 end
        if newPos < 1          then newPos = 0 end
    end

    local name = UnitName("mouseover") or "Target"
    local selectedMark = (newPos == 0) and 0 or scrollOrder[newPos]
    SetPendingManualMark(guid, "mouseover", name, selectedMark)
    UpdateMarkPickerHUD(guid, selectedMark)
end

local function IsManualModifierDown()
    local mod = AutoMarkAssistDB and AutoMarkAssistDB.manualModifier or "ALT"
    if mod == "SHIFT" then return IsShiftKeyDown() end
    if mod == "CTRL"  then return IsControlKeyDown() end
    return IsAltKeyDown()
end

-- ============================================================
-- SCROLL-WHEEL CATCHER
-- A hidden frame sized to WorldFrame intercepts mouse wheel events when
-- manual mode is active AND the modifier key is held.  We do NOT hook
-- WorldFrame:OnMouseWheel directly because doing so disrupts the C++-level
-- camera zoom routing in TBC Classic even when the Lua handler returns
-- immediately.
--
-- The catcher only enables mouse-wheel capture while the modifier is held
-- (toggled via a lightweight OnUpdate poll).  When the modifier is released,
-- EnableMouseWheel(false) lets scroll events fall through to whatever frame
-- is underneath (chat window, map, bags, etc.) so normal UI scrolling is
-- never blocked.
-- ============================================================
do
    local sc = CreateFrame("Frame", "AMAScrollCatcher", UIParent)
    -- Anchor to UIParent (same parent) instead of WorldFrame.  Cross-tree
    -- anchoring between UIParent-parented frames and WorldFrame can produce
    -- incorrect geometry under non-default UI scale, giving the catcher zero
    -- effective width/height so it never receives mouse wheel events.
    sc:SetAllPoints(UIParent)
    sc:SetFrameStrata("LOW")
    sc:EnableMouseWheel(false)
    sc:Hide()   -- hidden = no scroll capture until manual mode active

    -- OnUpdate: toggle mouse-wheel capture based on modifier key state.
    -- When the modifier is not held the catcher is transparent to scroll
    -- events, allowing chat, map, and other frames to scroll normally.
    local wasCapturing = false
    sc:SetScript("OnUpdate", function()
        local shouldCapture = IsManualModifierDown()
        if shouldCapture ~= wasCapturing then
            wasCapturing = shouldCapture
            sc:EnableMouseWheel(shouldCapture)
        end
    end)

    sc:SetScript("OnMouseWheel", function(self, delta)
        local hasOver = UnitExists("mouseover")
        if hasOver then
            ManualCycleMarkOnMouseover(delta)
        else
            AMA.VPrint("Scroll: modifier held but no mouseover unit detected.")
            -- Forward to camera zoom so scroll feels normal.
            if delta > 0 then
                CameraZoomIn(3)
            else
                CameraZoomOut(3)
            end
        end
    end)
end

-- ============================================================
-- MARK PICKER HUD
-- Small floating bar showing all 8 mark icons; displayed when the player
-- hovers a valid enemy while manual mode is active.  The currently selected
-- mark is gold; marks held by other mobs are dimmed red.
-- ============================================================

do  -- HUD construction scope: MH_* constants, hudLabel, hudHint, hudCells freed after block

local MH_CELL = 34   -- icon cell size (px)
local MH_GAP  = 4    -- gap between cells
local MH_PAD  = 6    -- outer horizontal padding
local MH_W    = MH_PAD * 2 + 8 * MH_CELL + 7 * MH_GAP   -- 320
local MH_H    = 70   -- total height (name + icons + hint)

markHUD = CreateFrame("Frame", "AMAMarkPickerHUD", UIParent,
    BackdropTemplateMixin and "BackdropTemplate" or nil)
markHUD:SetSize(MH_W, MH_H)
markHUD:SetFrameStrata("DIALOG")
markHUD:SetFrameLevel(200)
markHUD:SetClampedToScreen(true)
markHUD:Hide()

-- Keeps the HUD fully visible on smaller screens while preserving its
-- internal icon layout through parent scaling rather than per-cell resizing.
ApplyResponsiveHUDLayout = function()
    if not markHUD then return end

    local uiW = UIParent and UIParent:GetWidth() or 0
    local uiH = UIParent and UIParent:GetHeight() or 0
    if uiW <= 0 or uiH <= 0 then
        uiW = (GetScreenWidth and GetScreenWidth()) or MH_W
        uiH = (GetScreenHeight and GetScreenHeight()) or MH_H
    end

    local usableW = math.max(1, uiW - HUD_SCREEN_PAD * 2)
    local usableH = math.max(1, uiH - HUD_SCREEN_PAD * 2)
    local scale = math.min(1, usableW / MH_W, usableH / MH_H)
    scale = math.max(HUD_MIN_SCALE, scale)
    if MH_W * scale > usableW or MH_H * scale > usableH then
        scale = math.min(1, usableW / MH_W, usableH / MH_H)
    end
    markHUD:SetScale(scale)

    local topGap = math.floor(math.min(150, math.max(72, uiH * 0.18)))
    markHUD:ClearAllPoints()
    markHUD:SetPoint("TOP", UIParent, "TOP", 0, -topGap)
end

ApplyResponsiveHUDLayout()

-- ElvUI-style flat backdrop: 1-px solid border, very dark fill.
if markHUD.SetBackdrop then
    markHUD:SetBackdrop(HUD_FLAT_BD)
    markHUD:SetBackdropColor(HUD_BG[1], HUD_BG[2], HUD_BG[3], HUD_BG[4])
    markHUD:SetBackdropBorderColor(HUD_BORDER[1], HUD_BORDER[2], HUD_BORDER[3], 1)
end

-- 2-px teal accent line along the top edge.
local hudTopLine = markHUD:CreateTexture(nil, "ARTWORK")
hudTopLine:SetTexture(W8); hudTopLine:SetHeight(2)
hudTopLine:SetPoint("TOPLEFT",  markHUD, "TOPLEFT",  0, 0)
hudTopLine:SetPoint("TOPRIGHT", markHUD, "TOPRIGHT", 0, 0)
hudTopLine:SetVertexColor(HUD_ACCENT[1], HUD_ACCENT[2], HUD_ACCENT[3], 1)

-- Mob name label (top of HUD).
local hudLabel = markHUD:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
hudLabel:SetPoint("TOPLEFT",  markHUD, "TOPLEFT",  MH_PAD, -6)
hudLabel:SetPoint("TOPRIGHT", markHUD, "TOPRIGHT", -MH_PAD, -6)
hudLabel:SetJustifyH("CENTER")
hudLabel:SetTextColor(1, 1, 1, 1)

-- Scroll hint label (bottom of HUD).
local hudHint = markHUD:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
hudHint:SetPoint("BOTTOMLEFT",  markHUD, "BOTTOMLEFT",  MH_PAD, 5)
hudHint:SetPoint("BOTTOMRIGHT", markHUD, "BOTTOMRIGHT", -MH_PAD, 5)
hudHint:SetJustifyH("CENTER")
hudHint:SetTextColor(0.40, 0.40, 0.40, 1)

-- 8 icon cells: Star (1) on the left, Skull (8) on the right.
local hudCells = {}
for i = 1, 8 do
    -- Flat-backdrop cell (ElvUI style: 1-px border, dark fill)
    local cell = CreateFrame("Frame", nil, markHUD,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    cell:SetSize(MH_CELL, MH_CELL)
    cell:SetPoint("TOPLEFT", markHUD, "TOPLEFT",
        MH_PAD + (i - 1) * (MH_CELL + MH_GAP), -18)

    if cell.SetBackdrop then
        cell:SetBackdrop(HUD_FLAT_BD)
        cell:SetBackdropColor(HUD_CELL_N[1], HUD_CELL_N[2], HUD_CELL_N[3], 1)
        cell:SetBackdropBorderColor(HUD_BORDER[1], HUD_BORDER[2], HUD_BORDER[3], 1)
    else
        -- Fallback flat fill when BackdropTemplate unavailable
        local bg = cell:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture(W8)
        bg:SetVertexColor(HUD_CELL_N[1], HUD_CELL_N[2], HUD_CELL_N[3], 1)
        cell.bg = bg
    end

    local icon = cell:CreateTexture(nil, "ARTWORK")
    icon:SetSize(MH_CELL - 4, MH_CELL - 4)
    icon:SetPoint("CENTER", cell, "CENTER", 0, 0)
    icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i)
    cell.icon = icon

    -- Teal selection highlight (replaces the old gold glow texture).
    -- Implemented as a 2-px bottom bar + slight bg tint set in UpdateMarkPickerHUD.
    local selBar = cell:CreateTexture(nil, "OVERLAY")
    selBar:SetTexture(W8); selBar:SetHeight(2)
    selBar:SetPoint("BOTTOMLEFT",  cell, "BOTTOMLEFT",  0, 0)
    selBar:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", 0, 0)
    selBar:SetVertexColor(HUD_ACCENT[1], HUD_ACCENT[2], HUD_ACCENT[3], 1); selBar:Hide()
    cell.glow = selBar   -- keep field name for compatibility

    hudCells[i] = cell
end

-- Refresh all 8 cell states for the given hovered mob.
-- selectedMark=0 means the mob currently has no mark.
function UpdateMarkPickerHUD(guid, selectedMark)
    if not (AutoMarkAssistDB and AutoMarkAssistDB.manualMode) then
        if markHUD then markHUD:Hide() end
        return
    end
    if not guid then
        if markHUD then markHUD:Hide() end
        return
    end

    local name = UnitName("mouseover") or "?"
    hudLabel:SetText(name)

    if ApplyResponsiveHUDLayout then ApplyResponsiveHUDLayout() end

    local mod = AutoMarkAssistDB.manualModifier or "ALT"
    local directionHint = AMA.GetManualScrollDirectionHint and AMA.GetManualScrollDirectionHint()
        or "Down = left to right, Up = right to left"
    hudHint:SetText(mod .. " + Scroll  |  " .. directionHint .. "  |  close = apply")

    -- Reposition cells to match the configured scroll order so the HUD reads
    -- left-to-right in the same sequence as scroll-wheel advancement.
    local scrollOrder = AMA.GetManualScrollOrder and AMA.GetManualScrollOrder()
        or {8, 7, 3, 4, 5, 6, 2, 1}
    for pos, markIdx in ipairs(scrollOrder) do
        hudCells[markIdx]:ClearAllPoints()
        hudCells[markIdx]:SetPoint("TOPLEFT", markHUD, "TOPLEFT",
            MH_PAD + (pos - 1) * (MH_CELL + MH_GAP), -18)
    end

    for i = 1, 8 do
        local cell       = hudCells[i]
        local owner      = AMA.markOwners[i]
        local isSelected = (i == selectedMark)
        local isTaken    = (owner ~= nil and owner ~= guid)

        if isSelected then
            -- Teal tinted fill + bottom accent bar
            if cell.SetBackdropColor then
                cell:SetBackdropColor(HUD_CELL_SEL[1], HUD_CELL_SEL[2], HUD_CELL_SEL[3], 1)
                cell:SetBackdropBorderColor(HUD_ACCENT[1], HUD_ACCENT[2], HUD_ACCENT[3], 1)
            elseif cell.bg then
                cell.bg:SetVertexColor(HUD_CELL_SEL[1], HUD_CELL_SEL[2], HUD_CELL_SEL[3], 1)
            end
            cell.icon:SetAlpha(1.0)
            cell.icon:SetVertexColor(1, 1, 1, 1)
            cell.glow:Show()
        elseif isTaken then
            -- Dim red fill, muted icon
            if cell.SetBackdropColor then
                cell:SetBackdropColor(HUD_CELL_TKN[1], HUD_CELL_TKN[2], HUD_CELL_TKN[3], 1)
                cell:SetBackdropBorderColor(HUD_BORDER[1], HUD_BORDER[2], HUD_BORDER[3], 1)
            elseif cell.bg then
                cell.bg:SetVertexColor(HUD_CELL_TKN[1], HUD_CELL_TKN[2], HUD_CELL_TKN[3], 1)
            end
            cell.icon:SetAlpha(0.28)
            cell.icon:SetVertexColor(1, 0.40, 0.40, 1)
            cell.glow:Hide()
        else
            -- Normal dark fill
            if cell.SetBackdropColor then
                cell:SetBackdropColor(HUD_CELL_N[1], HUD_CELL_N[2], HUD_CELL_N[3], 1)
                cell:SetBackdropBorderColor(HUD_BORDER[1], HUD_BORDER[2], HUD_BORDER[3], 1)
            elseif cell.bg then
                cell.bg:SetVertexColor(HUD_CELL_N[1], HUD_CELL_N[2], HUD_CELL_N[3], 1)
            end
            cell.icon:SetAlpha(0.75)
            cell.icon:SetVertexColor(1, 1, 1, 1)
            cell.glow:Hide()
        end
    end

    markHUD:Show()
end

-- Called on UPDATE_MOUSEOVER_UNIT in manual mode; shows HUD for the
-- current mouseover target when the modifier key is held.
function AMA.ShowMarkPickerForMouseover()
    if not (AutoMarkAssistDB and AutoMarkAssistDB.manualMode) then
        HideMarkPickerHUD(true, "manual off")
        return
    end
    if not IsManualModifierDown() then
        HideMarkPickerHUD(true, "picker closed")
        return
    end
    if not UnitExists("mouseover") then
        HideMarkPickerHUD(true, "target lost")
        return
    end
    if not UnitCanAttack("player", "mouseover") then
        HideMarkPickerHUD(true, "target lost")
        return
    end
    if UnitIsDead and UnitIsDead("mouseover") then
        HideMarkPickerHUD(true, "target lost")
        return
    end
    local guid = UnitGUID and UnitGUID("mouseover")
    if not guid then
        HideMarkPickerHUD(true, "target lost")
        return
    end

    if manualPendingMark.guid and manualPendingMark.guid ~= guid then
        CommitPendingManualMark("target switch")
    end

    if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end

    local currentMark = GetPendingManualSelection(guid, "mouseover")
    SetPendingManualMark(guid, "mouseover", UnitName("mouseover") or "Target", currentMark)
    UpdateMarkPickerHUD(guid, currentMark)
end

end  -- HUD construction scope

-- ============================================================
-- MINIMAP BUTTON
-- ============================================================

AMA.minimapButton = CreateFrame(
    "Button", "AutoMarkAssistMinimapButton", Minimap)
AMA.minimapButton:SetWidth(31)
AMA.minimapButton:SetHeight(31)
AMA.minimapButton:SetFrameStrata("MEDIUM")
AMA.minimapButton:SetFrameLevel(8)
AMA.minimapButton:EnableMouse(true)
AMA.minimapButton:RegisterForDrag("LeftButton")
AMA.minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
AMA.minimapButton:SetHighlightTexture(
    "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local minimapBorder = AMA.minimapButton:CreateTexture(nil, "OVERLAY")
minimapBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
minimapBorder:SetWidth(53)
minimapBorder:SetHeight(53)
minimapBorder:SetPoint("TOPLEFT")

local minimapIcon = AMA.minimapButton:CreateTexture(nil, "BACKGROUND")
minimapIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_8")
minimapIcon:SetWidth(24)
minimapIcon:SetHeight(24)
minimapIcon:SetPoint("CENTER", AMA.minimapButton, "CENTER", 0, 0)

-- Status indicator dot - 3-state: Red=disabled, Green=auto, Gold=manual.
-- Each state is a separate texture pre-coloured at creation time via
-- SetVertexColor.  UpdateMinimapState uses Show/Hide only, avoiding every
-- known TBC Classic renderer batch-state issue with dynamic tinting.
local minimapDotBg = AMA.minimapButton:CreateTexture(nil, "OVERLAY")
minimapDotBg:SetTexture("Interface\\COMMON\\Indicator-Gray")
minimapDotBg:SetWidth(18)
minimapDotBg:SetHeight(18)
minimapDotBg:SetPoint("BOTTOMRIGHT", AMA.minimapButton, "BOTTOMRIGHT", -2, 2)
minimapDotBg:SetVertexColor(0, 0, 0, 0)   -- transparent anchor only

local minimapDotRed = AMA.minimapButton:CreateTexture(nil, "OVERLAY")
minimapDotRed:SetTexture("Interface\\COMMON\\Indicator-Red")
minimapDotRed:SetWidth(16)
minimapDotRed:SetHeight(16)
minimapDotRed:SetPoint("CENTER", minimapDotBg, "CENTER", 0, 0)
minimapDotRed:SetVertexColor(1.0, 1.0, 1.0, 1)

local minimapDotGold = AMA.minimapButton:CreateTexture(nil, "OVERLAY")
minimapDotGold:SetTexture("Interface\\COMMON\\Indicator-Yellow")
minimapDotGold:SetWidth(16)
minimapDotGold:SetHeight(16)
minimapDotGold:SetPoint("CENTER", minimapDotBg, "CENTER", 0, 0)
minimapDotGold:SetVertexColor(1.0, 1.0, 1.0, 1)
minimapDotGold:Hide()

local minimapDotGreen = AMA.minimapButton:CreateTexture(nil, "OVERLAY")
minimapDotGreen:SetTexture("Interface\\COMMON\\Indicator-Green")
minimapDotGreen:SetWidth(16)
minimapDotGreen:SetHeight(16)
minimapDotGreen:SetPoint("CENTER", minimapDotBg, "CENTER", 0, 0)
minimapDotGreen:SetVertexColor(1.0, 1.0, 1.0, 1)
minimapDotGreen:Hide()

-- Update the status dot and scroll-catcher visibility to match the current state.
-- Dot selection uses Show/Hide on pre-coloured textures - no SetVertexColor
-- during state transition avoids renderer batch-state interference.
function AMA.UpdateMinimapState()
    local enabled = AutoMarkAssistDB and AutoMarkAssistDB.enabled
    local manual  = AutoMarkAssistDB and (AutoMarkAssistDB.manualMode == true)
    minimapIcon:SetVertexColor(1.0, 1.0, 1.0, 1)
    if manual then
        minimapDotRed:Hide(); minimapDotGold:Show(); minimapDotGreen:Hide()
    elseif enabled then
        minimapDotRed:Hide(); minimapDotGold:Hide(); minimapDotGreen:Show()
    else
        minimapDotRed:Show(); minimapDotGold:Hide(); minimapDotGreen:Hide()
    end
    if not manual then HideMarkPickerHUD(true, "manual off") end
    if AMAScrollCatcher then
        if manual then AMAScrollCatcher:Show() else AMAScrollCatcher:Hide() end
    end
end

-- ============================================================
-- MINIMAP POSITION
-- Orbit the button around the minimap at the saved angle.
-- When the minimap reports a square shape, project the ray to the square edge.
-- ============================================================

do  -- Minimap position scope: MINIMAP_RADIUS, MINIMAP_SQ_HALF freed after block
    local MINIMAP_RADIUS  = 90
    local MINIMAP_SQ_HALF = 78

    function AMA.UpdateMinimapPosition()
        if not AutoMarkAssistDB then return end
        local angle = math.rad(AutoMarkAssistDB.minimapAngle or 225)
        local cos_a = math.cos(angle)
        local sin_a = math.sin(angle)
        local x, y
        local isSquare = Minimap.GetShape and Minimap:GetShape() == "SQUARE"
        if isSquare then
            local h = MINIMAP_SQ_HALF
            if math.abs(cos_a) < 1e-9 then
                x, y = 0, (sin_a >= 0) and h or -h
            elseif math.abs(sin_a) < 1e-9 then
                x, y = (cos_a >= 0) and h or -h, 0
            else
                local t = math.min(h / math.abs(cos_a), h / math.abs(sin_a))
                x, y = cos_a * t, sin_a * t
            end
        else
            x = cos_a * MINIMAP_RADIUS
            y = sin_a * MINIMAP_RADIUS
        end
        AMA.minimapButton:ClearAllPoints()
        AMA.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end
end  -- Minimap position scope

-- ============================================================
-- MINIMAP DRAG
-- Delta-based angle update using cursor movement projected onto the orbit
-- tangent.  Immune to coordinate-space issues because only relative cursor
-- movement is used, not absolute minimap-to-cursor angle.
-- ============================================================

do  -- Minimap drag scope: mmLastX, mmLastY freed after block
    local mmLastX, mmLastY = 0, 0

    AMA.minimapButton:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        mmLastX, mmLastY = GetCursorPosition()
        self:SetScript("OnUpdate", function()
            local cx, cy = GetCursorPosition()
            local dx = cx - mmLastX
            local dy = cy - mmLastY
            mmLastX, mmLastY = cx, cy
            if dx == 0 and dy == 0 then return end
            local scale  = UIParent:GetEffectiveScale()
            local dx_ui  = dx / scale
            local dy_ui  = dy / scale
            local theta  = math.rad(AutoMarkAssistDB.minimapAngle or 225)
            local tang   = dx_ui * (-math.sin(theta)) + dy_ui * math.cos(theta)
            local dAngle = math.deg(tang / 90)
            AutoMarkAssistDB.minimapAngle =
                (AutoMarkAssistDB.minimapAngle + dAngle) % 360
            AMA.UpdateMinimapPosition()
        end)
    end)

    AMA.minimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        self:UnlockHighlight()
        AMA.UpdateMinimapPosition()
    end)
end  -- Minimap drag scope

-- ============================================================
-- MINIMAP BUTTON SCRIPTS
-- ============================================================

AMA.minimapButton:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if AutoMarkAssistDB then
            AutoMarkAssistDB.enabled = not AutoMarkAssistDB.enabled
            AMA.UpdateMinimapState()
            AMA.Print("Auto-marking " .. (AutoMarkAssistDB.enabled
                and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r"))
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end
    elseif button == "MiddleButton" then
        AMA.ResetWithMessage()
    elseif button == "RightButton" then
        AMA.OpenOptionsMenu("AutoMarkAssistMinimapButton")
    end
end)

AMA.minimapButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(AMA.minimapButton, "ANCHOR_LEFT")
    GameTooltip:AddLine("|cFF00CCFFAutoMarkAssist|r v" ..
        AMA.VERSION .. " by |cFFFFD700" .. AMA.AUTHOR .. "|r")
    GameTooltip:AddLine("|cFFFFFFFFLeft-click:|r Toggle auto-marking")
    GameTooltip:AddLine("|cFFFFFFFFMiddle-click:|r Reset all marks")
    GameTooltip:AddLine("|cFFFFFFFFRight-click:|r Options menu")
    GameTooltip:AddLine("|cFFFFFFFFDrag:|r Reposition around minimap")
    if AutoMarkAssistDB then
        local function OnOff(val)
            return val and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"
        end
        GameTooltip:AddLine(" ")
        local stateStr = AutoMarkAssistDB.enabled
            and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r"
        GameTooltip:AddLine("Status: " .. stateStr)
        if AMA.currentZoneMobDB then
            GameTooltip:AddLine("Zone DB: |cFF00FF00" ..
                AMA.CountTable(AMA.currentZoneMobDB) .. " entries|r")
        else
            GameTooltip:AddLine("Zone DB: |cFFFF6600None|r")
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Between-pull refresh: " .. OnOff(AutoMarkAssistDB.autoReset))
        GameTooltip:AddLine("Dynamic marking: " .. OnOff(AutoMarkAssistDB.dynamicMarking))
        GameTooltip:AddLine("Combat mark lock: " .. OnOff(AutoMarkAssistDB.lockMarksInCombat))
        GameTooltip:AddLine("Rebalance on death: " .. OnOff(AutoMarkAssistDB.rebalanceOnDeath))
        GameTooltip:AddLine("Skip filler mobs: " .. OnOff(AutoMarkAssistDB.skipFillerMobs))
        GameTooltip:AddLine("Skip critters: " .. OnOff(AutoMarkAssistDB.skipCritters))
        local proxMode = AutoMarkAssistDB.proximityMode
        local proxDetail
        if proxMode then
            proxDetail = "|cFF00FF00ON|r  " ..
                (AMA.PROXIMITY_RANGE_LABELS[AutoMarkAssistDB.proximityRange or 4] or "")
        else
            proxDetail = "|cFFFF0000OFF|r"
        end
        GameTooltip:AddLine("Proximity: " .. proxDetail)
        local moMode = AutoMarkAssistDB.mouseoverMode ~= false
        local moDetail
        if moMode then
            if AutoMarkAssistDB.mouseoverRangeEnabled then
                moDetail = "|cFF00FF00ON|r  " ..
                (AMA.PROXIMITY_RANGE_LABELS[AutoMarkAssistDB.mouseoverRange or 4] or "")
            else
                moDetail = "|cFF00FF00ON|r  Unlimited"
            end
        else
            moDetail = "|cFFFF0000OFF|r"
        end
        GameTooltip:AddLine("Mouseover: " .. moDetail)
        GameTooltip:AddLine("Manual mode: " .. OnOff(AutoMarkAssistDB.manualMode))
        GameTooltip:AddLine("Wheel direction: " .. (AMA.GetManualScrollDirectionLabel and AMA.GetManualScrollDirectionLabel() or "Scroll Down Starts Left"))
    end
    GameTooltip:Show()
end)

AMA.minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- ============================================================
-- OPTIONS POPUP MENU  (taint-free)
-- Uses a custom Frame instead of UIDropDownMenuTemplate to avoid
-- spreading taint to Blizzard's secure dropdown system.
-- All locals are scoped inside the do block; only AMA.OpenOptionsMenu
-- is exposed so Events (slash /ama options) and the button can call it.
-- ============================================================

do  -- Options popup scope

local POPUP_W       = 210
local ROW_H         = 22
local PAD           = 6
local SEP_H         = 8
local POPUP_BD      = {
    bgFile   = W8,
    edgeFile = W8,
    tile     = false,
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

local popup = CreateFrame("Frame", "AMAOptionsPopup", UIParent,
    BackdropTemplateMixin and "BackdropTemplate" or nil)
if popup.SetBackdrop then
    popup:SetBackdrop(POPUP_BD)
    popup:SetBackdropColor(0.05, 0.05, 0.05, 0.96)
    popup:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
end
popup:SetFrameStrata("TOOLTIP")
popup:SetClampedToScreen(true)
popup:EnableMouse(true)
popup:Hide()

-- Close when the user clicks anywhere outside the popup.
popup:SetScript("OnShow", function(self)
    self.closeTimer = nil
end)
popup:SetScript("OnUpdate", function(self)
    if not self:IsMouseOver() and not (AMA.minimapButton and AMA.minimapButton:IsMouseOver()) then
        if not self.closeTimer then
            self.closeTimer = GetTime()
        elseif GetTime() - self.closeTimer > 0.35 then
            self:Hide()
        end
    else
        self.closeTimer = nil
    end
end)

local rows = {}

local function MakeRow(parent, idx)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(ROW_H)
    row:SetPoint("LEFT", parent, "LEFT", PAD, 0)
    row:SetPoint("RIGHT", parent, "RIGHT", -PAD, 0)

    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.text:SetPoint("LEFT", 4, 0)
    row.text:SetPoint("RIGHT", -4, 0)
    row.text:SetJustifyH("LEFT")

    row.check = row:CreateTexture(nil, "ARTWORK")
    row.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    row.check:SetSize(16, 16)
    row.check:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    row.check:Hide()

    row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
    row.highlight:SetTexture(W8)
    row.highlight:SetAllPoints()
    row.highlight:SetVertexColor(0.10, 0.62, 0.75, 0.18)

    return row
end

local function ClosePopup() popup:Hide() end

local function BuildPopup()
    -- Define menu entries.
    local items = {
        { text = "AutoMarkAssist " .. AMA.VERSION, isTitle = true },
        { text = "By " .. AMA.AUTHOR, isTitle = true },
        { sep = true },
        { text = "Enable Auto-Marking",
          checked = function() return AutoMarkAssistDB and AutoMarkAssistDB.enabled end,
          func = function()
              AutoMarkAssistDB.enabled = not AutoMarkAssistDB.enabled
              AMA.UpdateMinimapState()
              if AMA.RefreshDungeonCCAnnouncementQueue then
                  AMA.RefreshDungeonCCAnnouncementQueue(0.5)
              end
              if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
              AMA.Print("Auto-marking " .. (AutoMarkAssistDB.enabled
                  and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r"))
          end },
        { text = "Manual Mode (scroll wheel)",
          checked = function() return AutoMarkAssistDB and AutoMarkAssistDB.manualMode end,
          func = function()
              AutoMarkAssistDB.manualMode = not AutoMarkAssistDB.manualMode
              AMA.UpdateMinimapState()
              if AMA.RefreshDungeonCCAnnouncementQueue then
                  AMA.RefreshDungeonCCAnnouncementQueue(0.5)
              end
              if AutoMarkAssistDB.manualMode then
                  AMA.Print("Manual mode |cFFFFD700ON|r - hover a mob and scroll to assign marks.")
              else
                  AMA.Print("Manual mode |cFF888888OFF|r - auto-marking resumed.")
              end
              if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
          end },
        { sep = true },
        { text = "Options / Configure...", func = function()
              ClosePopup()
              if AMA.OpenConfigFrame then AMA.OpenConfigFrame() end
          end },
        { sep = true },
        { text = "Announce Marks", func = function()
              ClosePopup()
              if AutoMarkAssist_Announce then AutoMarkAssist_Announce() end
          end },
        { text = "Repeat Dungeon CC", func = function()
              ClosePopup()
              if AutoMarkAssist_AnnounceDungeonSmartCC then
                  AutoMarkAssist_AnnounceDungeonSmartCC({ showFeedback = true })
              end
          end },
        { sep = true },
        { text = "Reset Mark Tracking", func = function()
              ClosePopup()
              AMA.ResetWithMessage()
          end },
        { sep = true },
        { text = "Hide Minimap Button", func = function()
              ClosePopup()
              AutoMarkAssistDB.minimapHide = true
              AMA.minimapButton:Hide()
              if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
              AMA.Print("Minimap button hidden. Use |cFFAAAAAA/ama show|r to restore.")
          end },
        { sep = true },
        { text = "Close", func = ClosePopup },
    }

    -- Ensure enough rows exist.
    for i = #rows + 1, #items do
        rows[i] = MakeRow(popup, i)
    end

    -- Layout rows.
    local y = -PAD
    for i, item in ipairs(items) do
        local row = rows[i]
        row:ClearAllPoints()

        if item.sep then
            row:SetHeight(SEP_H)
            row:SetPoint("TOPLEFT", popup, "TOPLEFT", PAD, y)
            row:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -PAD, y)
            row.text:SetText("")
            row.check:Hide()
            row.highlight:Hide()
            row:SetScript("OnClick", nil)
            row:EnableMouse(false)
            y = y - SEP_H
        else
            row:SetHeight(ROW_H)
            row:SetPoint("TOPLEFT", popup, "TOPLEFT", PAD, y)
            row:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -PAD, y)
            row.highlight:Show()
            row:EnableMouse(true)

            if item.isTitle then
                row.text:SetText("|cFF00CCFF" .. item.text .. "|r")
                row.text:SetJustifyH("CENTER")
                row.check:Hide()
                row:SetScript("OnClick", nil)
                row:EnableMouse(false)
                row.highlight:Hide()
            else
                row.text:SetText(item.text)
                row.text:SetJustifyH("LEFT")
                if item.checked then
                    local val = item.checked()
                    if val then row.check:Show() else row.check:Hide() end
                else
                    row.check:Hide()
                end
                row:SetScript("OnClick", function()
                    if item.func then item.func() end
                    -- Refresh check marks after toggle.
                    for j, it in ipairs(items) do
                        if it.checked and rows[j] then
                            local v = it.checked()
                            if v then rows[j].check:Show() else rows[j].check:Hide() end
                        end
                    end
                end)
            end
            y = y - ROW_H
        end
    end

    -- Hide unused rows.
    for i = #items + 1, #rows do rows[i]:Hide() end

    popup:SetSize(POPUP_W, -y + PAD)
end

function AMA.OpenOptionsMenu(anchor)
    BuildPopup()
    popup:ClearAllPoints()
    if type(anchor) == "string" then
        local f = _G[anchor]
        if f then
            popup:SetPoint("TOPRIGHT", f, "BOTTOMLEFT", 0, -4)
        else
            popup:SetPoint("CENTER", UIParent, "CENTER")
        end
    else
        popup:SetPoint("TOPRIGHT", anchor, "BOTTOMLEFT", 0, -4)
    end
    if popup:IsShown() then popup:Hide() else popup:Show() end
end

end  -- Options popup scope
