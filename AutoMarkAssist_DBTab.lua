-- AutoMarkAssist_DBTab.lua
-- Database tab UI: view and edit mob mark preferences per zone.
-- Loaded after AutoMarkAssist_Manual.lua, before AutoMarkAssist_Config.lua.

local AMA = AutoMarkAssist

-- ============================================================
-- FILE-SCOPE CONSTANTS
-- ============================================================

local W8 = "Interface\\Buttons\\WHITE8x8"
local FLAT_BD = {
    bgFile   = W8,
    edgeFile = W8,
    tile     = false,
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

local ACCENT = { 0.10, 0.62, 0.75, 1.00 }
local BORDER = { 0.15, 0.15, 0.15, 1.00 }
local BG     = { 0.06, 0.06, 0.06, 0.96 }
local BTN_N  = { 0.12, 0.12, 0.12, 1.00 }
local BTN_H  = { 0.22, 0.22, 0.22, 1.00 }
local BTN_A  = { 0.08, 0.25, 0.30, 1.00 }

local ROW_HEIGHT = 22
local ROW_PAD    = 2

-- Mark cycle order for clicking (includes 0 = no mark / remove).
local CYCLE_ORDER = { 8, 7, 5, 3, 4, 1, 2, 6, 0 }
local CYCLE_INDEX = {}
for i, m in ipairs(CYCLE_ORDER) do CYCLE_INDEX[m] = i end

local MARK_LABEL = {
    [0] = "|cFF888888None|r",
    [8] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14|t Skull",
    [7] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14|t Cross",
    [5] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:14:14|t Moon",
    [3] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t Diamond",
    [4] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14|t Triangle",
    [1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14|t Star",
    [2] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:14:14|t Circle",
    [6] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:14:14|t Square",
}

local SKIP_LABEL = "|cFFFF4444SKIP|r"

-- ============================================================
-- STATE
-- ============================================================

local dbTabFrame     -- parent content frame (set by BuildDBTab)
local scrollChild    -- inner scroll child
local rowPool = {}   -- reusable row frames
local zoneLabel, countLabel
local addMobEdit
local currentRows = {}  -- list of visible row data

-- ============================================================
-- HELPERS
-- ============================================================

local function Skin(f)
    if not f.SetBackdrop then return end
    f:SetBackdrop(FLAT_BD)
    f:SetBackdropColor(BG[1], BG[2], BG[3], BG[4])
    f:SetBackdropBorderColor(BORDER[1], BORDER[2], BORDER[3], 1.0)
end

local function MarkDisplayText(val)
    if val == "SKIP" then return SKIP_LABEL end
    if type(val) == "number" then return MARK_LABEL[val] or tostring(val) end
    return MARK_LABEL[0]
end

local function CycleMark(current)
    if current == "SKIP" then return CYCLE_ORDER[1] end
    local idx = CYCLE_INDEX[current] or 0
    idx = idx + 1
    if idx > #CYCLE_ORDER then return "SKIP" end
    return CYCLE_ORDER[idx]
end

-- ============================================================
-- ROW CREATION
-- ============================================================

local function GetRow(parent, index)
    if rowPool[index] then return rowPool[index] end

    local row = CreateFrame("Frame", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    row:SetHeight(ROW_HEIGHT)
    Skin(row)

    -- Mob name label.
    local nameFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nameFS:SetPoint("LEFT", row, "LEFT", 6, 0)
    nameFS:SetJustifyH("LEFT")
    nameFS:SetWidth(260)
    nameFS:SetWordWrap(false)
    row._nameFS = nameFS

    -- Override indicator.
    local overrideFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    overrideFS:SetPoint("LEFT", nameFS, "RIGHT", 4, 0)
    overrideFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.7)
    row._overrideFS = overrideFS

    -- Mark button (click to cycle).
    local markBtn = CreateFrame("Button", nil, row,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    markBtn:SetSize(120, ROW_HEIGHT - 2)
    markBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    markBtn:RegisterForClicks("AnyUp")
    Skin(markBtn)

    local markFS = markBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    markFS:SetPoint("CENTER")
    markBtn._fs = markFS

    markBtn:SetScript("OnEnter", function(self)
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
        end
    end)
    markBtn:SetScript("OnLeave", function(self)
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(BORDER[1], BORDER[2], BORDER[3], 1)
        end
    end)

    row._markBtn = markBtn
    rowPool[index] = row
    return row
end

-- ============================================================
-- REFRESH
-- ============================================================

local function RefreshDBTab()
    if not dbTabFrame or not scrollChild then return end

    local zone = AMA.currentZoneName or ""
    zoneLabel:SetText(zone ~= "" and ("|cFFFFFFFF" .. zone .. "|r") or "|cFF888888No zone|r")

    local list = AMA.GetZoneMobList(zone)
    countLabel:SetText(string.format("|cFF888888%d entries|r", #list))

    -- Size the scroll child to fit all rows.
    local totalH = #list * (ROW_HEIGHT + ROW_PAD) + 4
    scrollChild:SetHeight(math.max(totalH, 1))

    -- Hide unused rows.
    for i = #list + 1, #rowPool do
        if rowPool[i] then rowPool[i]:Hide() end
    end

    for i, entry in ipairs(list) do
        local row = GetRow(scrollChild, i)
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -((i - 1) * (ROW_HEIGHT + ROW_PAD)))
        row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)

        row._nameFS:SetText(entry.name)
        row._overrideFS:SetText(entry.isOverride and "*" or "")

        local markVal = entry.mark
        row._markBtn._fs:SetText(MarkDisplayText(markVal))

        -- Colour the row background based on override status.
        if row.SetBackdropColor then
            if entry.isOverride then
                row:SetBackdropColor(0.08, 0.12, 0.14, 1)
            else
                row:SetBackdropColor(BG[1], BG[2], BG[3], BG[4])
            end
        end

        row._markBtn:SetScript("OnClick", function(self, button)
            local newMark
            if button == "RightButton" then
                -- Right-click: remove player override (revert to default or delete).
                if entry.isOverride then
                    local zone2 = AMA.currentZoneName or ""
                    if AutoMarkAssistDB and AutoMarkAssistDB.mobMarks
                    and AutoMarkAssistDB.mobMarks[zone2] then
                        AutoMarkAssistDB.mobMarks[zone2][entry.name] = nil
                        -- Clean up empty zone table.
                        if next(AutoMarkAssistDB.mobMarks[zone2]) == nil then
                            AutoMarkAssistDB.mobMarks[zone2] = nil
                        end
                    end
                    AMA.VPrint("Reverted override for: " .. entry.name)
                    RefreshDBTab()
                    return
                end
                return  -- no-op for non-overrides on right-click
            end

            -- Left-click: cycle mark.
            newMark = CycleMark(markVal)
            local zone2 = AMA.currentZoneName or ""
            if zone2 == "" then return end

            if newMark == 0 then
                -- "None" = remove from player overrides.
                if entry.isOverride then
                    if AutoMarkAssistDB and AutoMarkAssistDB.mobMarks
                    and AutoMarkAssistDB.mobMarks[zone2] then
                        AutoMarkAssistDB.mobMarks[zone2][entry.name] = nil
                        if next(AutoMarkAssistDB.mobMarks[zone2]) == nil then
                            AutoMarkAssistDB.mobMarks[zone2] = nil
                        end
                    end
                end
            else
                AMA.SetPlayerMobMark(zone2, entry.name, newMark)
            end

            RefreshDBTab()
        end)

        row:Show()
    end
end

-- Expose for Config tab switching.
AMA._RefreshDBTab = RefreshDBTab

-- ============================================================
-- BUILD TAB (called once from Config)
-- ============================================================

function AMA.BuildDBTab(parent)
    dbTabFrame = parent
    local y = -8

    -- Zone header.
    local zoneLbl = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    zoneLbl:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, y)
    zoneLbl:SetText("Zone:")
    zoneLbl:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)

    zoneLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    zoneLabel:SetPoint("LEFT", zoneLbl, "RIGHT", 6, 0)

    countLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    countLabel:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -12, y)
    y = y - 20

    -- Column headers.
    local hdrName = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hdrName:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, y)
    hdrName:SetText("|cFF888888Mob Name|r")

    local hdrMark = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hdrMark:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -12, y)
    hdrMark:SetText("|cFF888888Mark (click to cycle)|r")
    y = y - 16

    -- Separator.
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetTexture(W8); sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
    sep:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, y)
    sep:SetVertexColor(BORDER[1], BORDER[2], BORDER[3], 0.8)
    y = y - 4

    -- Scroll frame.
    local scrollFrame = CreateFrame("ScrollFrame", "AMA_DBTabScroll", parent,
        "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, y)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -26, 64)

    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(scrollFrame:GetWidth() or 480)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)

    -- Update scroll child width when scroll frame sizes.
    scrollFrame:SetScript("OnSizeChanged", function(self, w)
        scrollChild:SetWidth(w)
    end)

    -- Bottom bar: Add Mob + Reset.
    local bottomY = 40
    local addLbl = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    addLbl:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 12, bottomY)
    addLbl:SetText("Add Mob:")

    addMobEdit = CreateFrame("EditBox", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    addMobEdit:SetSize(200, 20)
    addMobEdit:SetPoint("LEFT", addLbl, "RIGHT", 6, 0)
    addMobEdit:SetAutoFocus(false)
    if addMobEdit.SetBackdrop then
        addMobEdit:SetBackdrop(FLAT_BD)
        addMobEdit:SetBackdropColor(0.10, 0.10, 0.10, 1)
        addMobEdit:SetBackdropBorderColor(BORDER[1], BORDER[2], BORDER[3], 1)
    end
    addMobEdit:SetFontObject("GameFontHighlightSmall")
    addMobEdit:SetTextColor(1, 1, 1, 1)
    addMobEdit:SetTextInsets(4, 4, 0, 0)
    addMobEdit:SetScript("OnEditFocusGained", function(self)
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
        end
    end)
    addMobEdit:SetScript("OnEditFocusLost", function(self)
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(BORDER[1], BORDER[2], BORDER[3], 1)
        end
    end)
    addMobEdit:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        if not text or text == "" then self:ClearFocus(); return end
        text = text:gsub("^%s+", ""):gsub("%s+$", "")
        if text == "" then self:ClearFocus(); return end

        local zone = AMA.currentZoneName or ""
        if zone == "" then
            AMA.Print("Cannot add mob: no zone detected.")
            self:ClearFocus()
            return
        end

        AMA.SetPlayerMobMark(zone, text, 8)  -- default to Skull
        AMA.VPrint("Added mob: " .. text .. " = Skull in " .. zone)
        self:SetText("")
        self:ClearFocus()
        RefreshDBTab()
    end)

    -- Reset button.
    local resetBtn = CreateFrame("Button", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    resetBtn:SetSize(130, 22)
    resetBtn:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -8, bottomY - 2)
    Skin(resetBtn)
    local resetBg = resetBtn:CreateTexture(nil, "BACKGROUND")
    resetBg:SetTexture(W8); resetBg:SetAllPoints()
    resetBg:SetVertexColor(BTN_N[1], BTN_N[2], BTN_N[3], 1)
    local resetFS = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    resetFS:SetPoint("CENTER"); resetFS:SetText("Reset to Defaults")
    resetBtn:SetScript("OnEnter", function()
        resetBg:SetVertexColor(0.35, 0.10, 0.10, 1)
    end)
    resetBtn:SetScript("OnLeave", function()
        resetBg:SetVertexColor(BTN_N[1], BTN_N[2], BTN_N[3], 1)
    end)
    resetBtn:SetScript("OnClick", function()
        local zone = AMA.currentZoneName or ""
        if zone == "" then return end
        AMA.ClearPlayerMobMarks(zone)
        AMA.Print("Cleared all player overrides for: " .. zone)
        -- Rebuild zone DB after clearing overrides.
        AMA.currentZoneMobDB = AMA.BuildZoneMobDB(zone)
        RefreshDBTab()
    end)

    -- Bottom separator.
    local sep2 = parent:CreateTexture(nil, "ARTWORK")
    sep2:SetTexture(W8); sep2:SetHeight(1)
    sep2:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 8, 58)
    sep2:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -8, 58)
    sep2:SetVertexColor(BORDER[1], BORDER[2], BORDER[3], 0.8)
end
