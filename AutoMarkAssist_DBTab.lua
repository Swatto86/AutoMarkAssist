-- AutoMarkAssist_DBTab.lua
-- Database tab UI: browse all zones by expansion/type, edit mob mark preferences.
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

local NAV_WIDTH  = 200
local ROW_HEIGHT = 20
local ROW_PAD    = 1
local NAV_ROW_H  = 18
local NAV_PAD    = 1

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

local dbTabFrame
local navScrollChild, mobScrollChild
local navRowPool, mobRowPool = {}, {}
local selectedZone = nil
local zoneHeaderFS, countFS
local addMobEdit
local expandedExpansions = {}
local expandedCategories = {}

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

local function CountZoneMobs(zoneName)
    local count = 0
    local base = AutoMarkAssist_MobDB and AutoMarkAssist_MobDB[zoneName]
    if base then for _ in pairs(base) do count = count + 1 end end
    local player = AutoMarkAssistDB and AutoMarkAssistDB.mobMarks
        and AutoMarkAssistDB.mobMarks[zoneName]
    if player then
        for mob in pairs(player) do
            if not (base and base[mob]) then count = count + 1 end
        end
    end
    return count
end

-- ============================================================
-- NAV ROW CREATION
-- ============================================================

local function GetNavRow(parent, index)
    if navRowPool[index] then return navRowPool[index] end

    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(NAV_ROW_H)
    row:EnableMouse(true)
    row:RegisterForClicks("LeftButtonUp")

    local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("LEFT", row, "LEFT", 4, 0)
    fs:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(false)
    row._fs = fs

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(W8)
    highlight:SetAllPoints()
    highlight:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.12)

    local selected = row:CreateTexture(nil, "BACKGROUND")
    selected:SetTexture(W8)
    selected:SetAllPoints()
    selected:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.25)
    selected:Hide()
    row._selected = selected

    navRowPool[index] = row
    return row
end

-- ============================================================
-- MOB ROW CREATION
-- ============================================================

local function GetMobRow(parent, index)
    if mobRowPool[index] then return mobRowPool[index] end

    local row = CreateFrame("Frame", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    row:SetHeight(ROW_HEIGHT)
    Skin(row)

    local nameFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nameFS:SetPoint("LEFT", row, "LEFT", 6, 0)
    nameFS:SetJustifyH("LEFT")
    nameFS:SetWordWrap(false)
    row._nameFS = nameFS

    local overrideFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    overrideFS:SetPoint("LEFT", nameFS, "RIGHT", 4, 0)
    overrideFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.7)
    row._overrideFS = overrideFS

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

    nameFS:SetPoint("RIGHT", markBtn, "LEFT", -24, 0)

    row._markBtn = markBtn
    mobRowPool[index] = row
    return row
end

-- ============================================================
-- REFRESH NAV (left panel)
-- ============================================================

local function RefreshNav()
    if not navScrollChild then return end

    local expansions = AutoMarkAssist_ExpansionOrder or {}
    local rowIdx = 0

    for _, exp in ipairs(expansions) do
        local expName = exp.name
        local isExpExpanded = expandedExpansions[expName]

        rowIdx = rowIdx + 1
        local row = GetNavRow(navScrollChild, rowIdx)
        row:SetPoint("TOPLEFT", navScrollChild, "TOPLEFT", 0,
            -((rowIdx - 1) * (NAV_ROW_H + NAV_PAD)))
        row:SetPoint("RIGHT", navScrollChild, "RIGHT", 0, 0)

        local arrow = isExpExpanded and "- " or "+ "
        row._fs:SetText(arrow .. "|cFFFFD700" .. expName .. "|r")
        row._selected:Hide()
        row:SetScript("OnClick", function()
            expandedExpansions[expName] = not expandedExpansions[expName]
            RefreshNav()
        end)
        row:Show()

        if isExpExpanded then
            local categories = {}
            if exp.dungeons and #exp.dungeons > 0 then
                categories[#categories + 1] = { label = "Dungeons", zones = exp.dungeons }
            end
            if exp.raids and #exp.raids > 0 then
                categories[#categories + 1] = { label = "Raids", zones = exp.raids }
            end

            for _, cat in ipairs(categories) do
                local catKey = expName .. "|" .. cat.label
                local isCatExpanded = expandedCategories[catKey]

                rowIdx = rowIdx + 1
                local catRow = GetNavRow(navScrollChild, rowIdx)
                catRow:SetPoint("TOPLEFT", navScrollChild, "TOPLEFT", 12,
                    -((rowIdx - 1) * (NAV_ROW_H + NAV_PAD)))
                catRow:SetPoint("RIGHT", navScrollChild, "RIGHT", 0, 0)

                local catArrow = isCatExpanded and "- " or "+ "
                catRow._fs:SetText(catArrow .. "|cFFAAAAAA" .. cat.label .. "|r")
                catRow._selected:Hide()
                catRow:SetScript("OnClick", function()
                    expandedCategories[catKey] = not expandedCategories[catKey]
                    RefreshNav()
                end)
                catRow:Show()

                if isCatExpanded then
                    for _, zoneName in ipairs(cat.zones) do
                        rowIdx = rowIdx + 1
                        local zoneRow = GetNavRow(navScrollChild, rowIdx)
                        zoneRow:SetPoint("TOPLEFT", navScrollChild, "TOPLEFT", 24,
                            -((rowIdx - 1) * (NAV_ROW_H + NAV_PAD)))
                        zoneRow:SetPoint("RIGHT", navScrollChild, "RIGHT", 0, 0)

                        local mobCount = CountZoneMobs(zoneName)
                        local isActive = (zoneName == AMA.currentZoneName)
                        local isSelected = (zoneName == selectedZone)
                        local nameColor = isActive and "|cFF00FF00" or "|cFFCCCCCC"
                        local countStr = mobCount > 0
                            and " |cFF666666(" .. mobCount .. ")|r" or ""
                        zoneRow._fs:SetText(nameColor .. zoneName .. "|r" .. countStr)

                        if isSelected then
                            zoneRow._selected:Show()
                        else
                            zoneRow._selected:Hide()
                        end

                        zoneRow:SetScript("OnClick", function()
                            selectedZone = zoneName
                            RefreshNav()
                            AMA._RefreshDBMobList()
                        end)
                        zoneRow:Show()
                    end
                end
            end
        end
    end

    for i = rowIdx + 1, #navRowPool do
        if navRowPool[i] then navRowPool[i]:Hide() end
    end

    local totalH = rowIdx * (NAV_ROW_H + NAV_PAD) + 4
    navScrollChild:SetHeight(math.max(totalH, 1))
end

-- ============================================================
-- REFRESH MOB LIST (right panel)
-- ============================================================

local function RefreshMobList()
    if not mobScrollChild then return end

    local zone = selectedZone or ""
    zoneHeaderFS:SetText(zone ~= "" and ("|cFFFFFFFF" .. zone .. "|r")
        or "|cFF888888Select a zone|r")

    local list = {}
    if zone ~= "" then
        list = AMA.GetZoneMobList(zone)
    end
    countFS:SetText(string.format("|cFF888888%d entries|r", #list))

    local totalH = #list * (ROW_HEIGHT + ROW_PAD) + 4
    mobScrollChild:SetHeight(math.max(totalH, 1))

    for i = #list + 1, #mobRowPool do
        if mobRowPool[i] then mobRowPool[i]:Hide() end
    end

    for i, entry in ipairs(list) do
        local row = GetMobRow(mobScrollChild, i)
        row:SetPoint("TOPLEFT", mobScrollChild, "TOPLEFT", 0,
            -((i - 1) * (ROW_HEIGHT + ROW_PAD)))
        row:SetPoint("RIGHT", mobScrollChild, "RIGHT", 0, 0)

        row._nameFS:SetText(entry.name)
        row._overrideFS:SetText(entry.isOverride and "*" or "")

        local markVal = entry.mark
        row._markBtn._fs:SetText(MarkDisplayText(markVal))

        if row.SetBackdropColor then
            if entry.isOverride then
                row:SetBackdropColor(0.08, 0.12, 0.14, 1)
            else
                row:SetBackdropColor(BG[1], BG[2], BG[3], BG[4])
            end
        end

        row._markBtn:SetScript("OnClick", function(_, button)
            if button == "RightButton" then
                if entry.isOverride then
                    if AutoMarkAssistDB and AutoMarkAssistDB.mobMarks
                    and AutoMarkAssistDB.mobMarks[zone] then
                        AutoMarkAssistDB.mobMarks[zone][entry.name] = nil
                        if next(AutoMarkAssistDB.mobMarks[zone]) == nil then
                            AutoMarkAssistDB.mobMarks[zone] = nil
                        end
                    end
                    AMA.VPrint("Reverted override for: " .. entry.name)
                    if zone == AMA.currentZoneName then
                        AMA.currentZoneMobDB = AMA.BuildZoneMobDB(zone)
                    end
                    RefreshMobList()
                end
                return
            end

            local newMark = CycleMark(markVal)
            if zone == "" then return end

            if newMark == 0 then
                if entry.isOverride then
                    if AutoMarkAssistDB and AutoMarkAssistDB.mobMarks
                    and AutoMarkAssistDB.mobMarks[zone] then
                        AutoMarkAssistDB.mobMarks[zone][entry.name] = nil
                        if next(AutoMarkAssistDB.mobMarks[zone]) == nil then
                            AutoMarkAssistDB.mobMarks[zone] = nil
                        end
                    end
                end
            else
                AMA.SetPlayerMobMark(zone, entry.name, newMark)
            end

            if zone == AMA.currentZoneName then
                AMA.currentZoneMobDB = AMA.BuildZoneMobDB(zone)
            end
            RefreshMobList()
        end)

        row:Show()
    end
end

AMA._RefreshDBMobList = RefreshMobList

-- ============================================================
-- COMBINED REFRESH (called on tab switch)
-- ============================================================

local function RefreshDBTab()
    if not dbTabFrame then return end
    RefreshNav()
    RefreshMobList()
end

AMA._RefreshDBTab = RefreshDBTab

-- ============================================================
-- BUILD TAB (called once from Config)
-- ============================================================

function AMA.BuildDBTab(parent)
    dbTabFrame = parent

    -- Left panel: zone navigation.
    local navBorder = CreateFrame("Frame", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    navBorder:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -4)
    navBorder:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 4, 42)
    navBorder:SetWidth(NAV_WIDTH)
    Skin(navBorder)

    local navScroll = CreateFrame("ScrollFrame", "AMA_DBNavScroll", navBorder,
        "UIPanelScrollFrameTemplate")
    navScroll:SetPoint("TOPLEFT", navBorder, "TOPLEFT", 2, -2)
    navScroll:SetPoint("BOTTOMRIGHT", navBorder, "BOTTOMRIGHT", -20, 2)

    navScrollChild = CreateFrame("Frame", nil, navScroll)
    navScrollChild:SetWidth(NAV_WIDTH - 22)
    navScrollChild:SetHeight(1)
    navScroll:SetScrollChild(navScrollChild)

    navScroll:SetScript("OnSizeChanged", function(_, w)
        navScrollChild:SetWidth(math.max(w - 2, 1))
    end)

    -- Right panel: mob list.
    local rightPanel = CreateFrame("Frame", nil, parent)
    rightPanel:SetPoint("TOPLEFT", navBorder, "TOPRIGHT", 4, 0)
    rightPanel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -4, 42)

    zoneHeaderFS = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    zoneHeaderFS:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 8, -4)
    zoneHeaderFS:SetJustifyH("LEFT")

    countFS = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    countFS:SetPoint("TOPRIGHT", rightPanel, "TOPRIGHT", -8, -6)

    local hdrName = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hdrName:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 8, -22)
    hdrName:SetText("|cFF888888Mob Name|r")

    local hdrMark = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hdrMark:SetPoint("TOPRIGHT", rightPanel, "TOPRIGHT", -8, -22)
    hdrMark:SetText("|cFF888888Mark|r")

    local sep = rightPanel:CreateTexture(nil, "ARTWORK")
    sep:SetTexture(W8); sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 4, -34)
    sep:SetPoint("TOPRIGHT", rightPanel, "TOPRIGHT", -4, -34)
    sep:SetVertexColor(BORDER[1], BORDER[2], BORDER[3], 0.8)

    local mobBorder = CreateFrame("Frame", nil, rightPanel,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    mobBorder:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 0, -38)
    mobBorder:SetPoint("BOTTOMRIGHT", rightPanel, "BOTTOMRIGHT", 0, 0)
    Skin(mobBorder)

    local mobScroll = CreateFrame("ScrollFrame", "AMA_DBMobScroll", mobBorder,
        "UIPanelScrollFrameTemplate")
    mobScroll:SetPoint("TOPLEFT", mobBorder, "TOPLEFT", 2, -2)
    mobScroll:SetPoint("BOTTOMRIGHT", mobBorder, "BOTTOMRIGHT", -20, 2)

    mobScrollChild = CreateFrame("Frame", nil, mobScroll)
    mobScrollChild:SetWidth(1)
    mobScrollChild:SetHeight(1)
    mobScroll:SetScrollChild(mobScrollChild)

    mobScroll:SetScript("OnSizeChanged", function(_, w)
        mobScrollChild:SetWidth(math.max(w - 2, 1))
    end)

    -- Bottom bar: Add Mob + Reset.
    local addLbl = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    addLbl:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 12, 16)
    addLbl:SetText("Add Mob:")

    addMobEdit = CreateFrame("EditBox", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    addMobEdit:SetSize(180, 20)
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

        local zone = selectedZone or ""
        if zone == "" then
            AMA.Print("Select a zone first.")
            self:ClearFocus()
            return
        end

        AMA.SetPlayerMobMark(zone, text, 8)
        AMA.VPrint("Added mob: " .. text .. " = Skull in " .. zone)
        if zone == AMA.currentZoneName then
            AMA.currentZoneMobDB = AMA.BuildZoneMobDB(zone)
        end
        self:SetText("")
        self:ClearFocus()
        RefreshMobList()
        RefreshNav()
    end)

    local resetBtn = CreateFrame("Button", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    resetBtn:SetSize(130, 22)
    resetBtn:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -8, 13)
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
        local zone = selectedZone or ""
        if zone == "" then return end
        AMA.ClearPlayerMobMarks(zone)
        AMA.Print("Cleared all player overrides for: " .. zone)
        if zone == AMA.currentZoneName then
            AMA.currentZoneMobDB = AMA.BuildZoneMobDB(zone)
        end
        RefreshMobList()
        RefreshNav()
    end)

    local sep2 = parent:CreateTexture(nil, "ARTWORK")
    sep2:SetTexture(W8); sep2:SetHeight(1)
    sep2:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 8, 38)
    sep2:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -8, 38)
    sep2:SetVertexColor(BORDER[1], BORDER[2], BORDER[3], 0.8)

    -- Auto-select current zone and expand its tree path.
    if AMA.currentZoneName and AMA.currentZoneName ~= "" then
        selectedZone = AMA.currentZoneName
        for _, exp in ipairs(AutoMarkAssist_ExpansionOrder or {}) do
            for _, catKey in ipairs({"dungeons", "raids"}) do
                local zones = exp[catKey]
                if zones then
                    for _, z in ipairs(zones) do
                        if z == selectedZone then
                            expandedExpansions[exp.name] = true
                            local label = catKey == "dungeons"
                                and "Dungeons" or "Raids"
                            expandedCategories[exp.name .. "|" .. label] = true
                        end
                    end
                end
            end
        end
    end
end
