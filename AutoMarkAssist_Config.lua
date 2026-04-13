-- AutoMarkAssist_Config.lua
-- Announce helpers and Options configuration frame.
-- Loaded after AutoMarkAssist_Minimap.lua.
-- UI Style: ElvUI-inspired flat dark theme.

local AMA = AutoMarkAssist

-- ============================================================
-- FILE-SCOPE CONSTANTS
-- ============================================================

local MARK_STAR     = 1
local MARK_CIRCLE   = 2
local MARK_DIAMOND  = 3
local MARK_TRIANGLE = 4
local MARK_MOON     = 5
local MARK_SQUARE   = 6
local MARK_CROSS    = 7
local MARK_SKULL    = 8

local CONFIG_W = 480
local CONFIG_H = 700
local TAB_H    = 24
local CONFIG_MIN_SCALE   = 0.55
local CONFIG_SCREEN_PAD  = 24
local CONFIG_TITLE_H     = 24
local CONFIG_TOP_OFFSET  = 50

-- ============================================================
-- ANNOUNCE SYSTEM
-- ============================================================

do
    local CHAT_ICON = {
        [1] = "{star}", [2] = "{circle}", [3] = "{diamond}", [4] = "{triangle}",
        [5] = "{moon}", [6] = "{square}", [7] = "{cross}",   [8] = "{skull}",
    }
    local LOCAL_ICON = AMA.MARK_ICON_COORDS

    local function ResolveChannel(ch)
        if ch == "RAID" then
            if IsInRaid() then return "RAID" end
            if IsInGroup() then return "PARTY" end
            return nil, "Not in a group."
        end
        if ch == "PARTY" then
            if IsInRaid() then return "RAID" end
            if IsInGroup() then return "PARTY" end
            return nil, "Not in a group."
        end
        return ch
    end

    local function BuildMarkPlanLines(iconMap)
        local lines = {}
        local abilities = AMA.GetGroupCCAbilities()
        local ccByMark = {}
        for _, ab in ipairs(abilities) do
            ccByMark[ab.mark] = ab
        end

        -- Kill marks first.
        for _, m in ipairs(AMA.KILL_MARKS) do
            if AMA.IsMarkEnabled(m) then
                local icon = iconMap[m] or ("[" .. m .. "]")
                lines[#lines + 1] = string.format("%s  %s",
                    icon, AMA.MARK_DESCRIPTIONS[m] or "Kill")
            end
        end

        -- CC marks: only for classes present in the group.
        for _, classTag in ipairs(AMA.CC_CLASS_ORDER) do
            local cc = AMA.CC_ASSIGNMENTS[classTag]
            if cc and ccByMark[cc.mark] then
                local ab = ccByMark[cc.mark]
                local icon = iconMap[cc.mark] or ("[" .. cc.mark .. "]")
                lines[#lines + 1] = string.format("%s  %s - %s",
                    icon, ab.label, ab.playerName or "?")
            end
        end

        return lines
    end

    function AMA.AnnounceMarkPlan()
        local canMark, reason = AMA.CanMarkReason()
        if not canMark then
            AMA.Print("Cannot announce: " .. tostring(reason))
            return false
        end

        local ch = AutoMarkAssistDB and AutoMarkAssistDB.announceChannel or "PARTY"
        local resolved, err = ResolveChannel(ch)
        if not resolved then
            AMA.Print(err or "Cannot announce right now.")
            return false
        end

        local lines = BuildMarkPlanLines(CHAT_ICON)
        if #lines == 0 then
            AMA.Print("No marks configured to announce.")
            return false
        end

        local prefix = AMA.BuildAnnouncementPrefix()
        SendChatMessage(prefix .. "Mark Plan:", resolved)
        for _, line in ipairs(lines) do
            SendChatMessage(line, resolved)
        end
        return true
    end

    function AMA.PreviewMarkPlan()
        local lines = BuildMarkPlanLines(LOCAL_ICON)
        if #lines == 0 then
            AMA.Print("No marks configured to preview.")
            return
        end
        local prefix = AMA.BuildAnnouncementPrefix()
        AMA.Print(prefix .. "Mark Plan:")
        for _, line in ipairs(lines) do
            AMA.Print(line)
        end
    end

    -- Auto-announce on dungeon entry (called from Events).
    function AMA.AutoAnnounceOnEntry()
        if not AutoMarkAssistDB or not AutoMarkAssistDB.announceOnEntry then return false end
        if not AutoMarkAssistDB.enabled then return false end
        if AMA.GetMarkingMode() == "manual" then return false end

        local inInstance, instanceType = IsInInstance()
        if not inInstance then return false end
        if instanceType ~= "party" and instanceType ~= "raid" then return false end
        if not (IsInGroup() or (IsInRaid and IsInRaid())) then return false end

        local canMark = AMA.CanMarkReason()
        if not canMark then return false end

        return AMA.AnnounceMarkPlan()
    end
end

-- ============================================================
-- ELVUI-STYLE SKIN HELPERS
-- ============================================================

local E = {}
local W8 = "Interface\\Buttons\\WHITE8x8"
local FLAT_BD = {
    bgFile   = W8,
    edgeFile = W8,
    tile     = false,
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

E.BG     = { 0.06, 0.06, 0.06, 0.96 }
E.BG2    = { 0.04, 0.04, 0.04, 0.98 }
E.BORDER = { 0.15, 0.15, 0.15, 1.00 }
E.ACCENT = { 0.10, 0.62, 0.75, 1.00 }
E.BTN_N  = { 0.12, 0.12, 0.12, 1.00 }
E.BTN_H  = { 0.22, 0.22, 0.22, 1.00 }
E.BTN_P  = { 0.07, 0.07, 0.07, 1.00 }
E.BTN_A  = { 0.08, 0.25, 0.30, 1.00 }

function E.Skin(f, br, bg2, bb)
    if not f.SetBackdrop then return end
    f:SetBackdrop(FLAT_BD)
    f:SetBackdropColor(E.BG[1], E.BG[2], E.BG[3], E.BG[4])
    f:SetBackdropBorderColor(br or E.BORDER[1], bg2 or E.BORDER[2], bb or E.BORDER[3], 1.0)
end

function E.Label(parent, text, x, y, font)
    local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    fs:SetText(text)
    return fs
end

function E.Header(parent, text, x, y)
    local bar = parent:CreateTexture(nil, "ARTWORK")
    bar:SetTexture(W8); bar:SetSize(2, 12)
    bar:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y - 1)
    bar:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 7, y)
    fs:SetText(text)
    fs:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
    return fs
end

function E.Sep(parent, y, xPad)
    xPad = xPad or 8
    local s = parent:CreateTexture(nil, "ARTWORK")
    s:SetTexture(W8); s:SetHeight(1)
    s:SetPoint("TOPLEFT", parent, "TOPLEFT", xPad, y)
    s:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -xPad, y)
    s:SetVertexColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 0.8)
    return s
end

function E.Btn(parent, text, w, h)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(w or 80, h or 20)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(W8); bg:SetAllPoints()
    bg:SetVertexColor(E.BTN_N[1], E.BTN_N[2], E.BTN_N[3], 1)
    btn._bg = bg
    if BackdropTemplateMixin then
        local bd = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        bd:SetAllPoints(); bd:SetFrameLevel(btn:GetFrameLevel())
        bd:SetBackdrop({ bgFile = nil, edgeFile = W8, tile = false,
            edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        bd:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
    end
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("CENTER"); fs:SetText(text or ""); fs:SetTextColor(1, 1, 1, 1)
    btn:SetFontString(fs)
    btn._active = false
    btn._disabled = false

    local function ApplyVisual(state)
        if btn._disabled then
            fs:SetTextColor(0.4, 0.4, 0.4, 1)
            bg:SetVertexColor(E.BTN_N[1], E.BTN_N[2], E.BTN_N[3], 0.5)
            return
        end
        if btn._active then
            fs:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
        else
            fs:SetTextColor(1, 1, 1, 1)
        end
        if state == "down" then
            bg:SetVertexColor(E.BTN_P[1], E.BTN_P[2], E.BTN_P[3], 1)
        elseif state == "hover" and not btn._active then
            bg:SetVertexColor(E.BTN_H[1], E.BTN_H[2], E.BTN_H[3], 1)
        elseif btn._active then
            bg:SetVertexColor(E.BTN_A[1], E.BTN_A[2], E.BTN_A[3], 1)
        else
            bg:SetVertexColor(E.BTN_N[1], E.BTN_N[2], E.BTN_N[3], 1)
        end
    end

    btn:SetScript("OnEnter", function() ApplyVisual("hover") end)
    btn:SetScript("OnLeave", function() ApplyVisual("normal") end)
    btn:SetScript("OnMouseDown", function() ApplyVisual("down") end)
    btn:SetScript("OnMouseUp", function() ApplyVisual("hover") end)
    btn.SetActive = function(_, active)
        btn._active = active and true or false; ApplyVisual("normal")
    end
    btn.SetDisabled = function(_, disabled)
        btn._disabled = disabled and true or false
        btn:EnableMouse(not btn._disabled); ApplyVisual("normal")
    end
    return btn
end

-- Checkbox references for RefreshConfigFrame.
local checkboxRefs = {}

function E.Chk(parent, text, x, y, dbKey, onChange)
    local box = CreateFrame("Button", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    box:SetSize(16, 16)
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y - 1)
    box:RegisterForClicks("AnyUp"); box:EnableMouse(true)
    E.Skin(box)
    local ck = box:CreateTexture(nil, "OVERLAY")
    ck:SetTexture(W8); ck:SetSize(12, 12); ck:SetPoint("CENTER")
    ck:SetVertexColor(0.20, 0.90, 1.0, 1); ck:Hide()
    box._ck = ck; box.checked = false

    local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lbl:SetPoint("LEFT", box, "RIGHT", 5, 1); lbl:SetText(text)
    box._lbl = lbl

    local hit = CreateFrame("Button", nil, parent)
    hit:SetHeight(18)
    hit:SetPoint("LEFT", box, "RIGHT", 3, 0)
    hit:SetPoint("RIGHT", lbl, "RIGHT", 2, 0)
    hit:SetFrameLevel(box:GetFrameLevel() + 1)
    hit:RegisterForClicks("AnyUp"); hit:EnableMouse(true)

    -- Disabled visual style update for unchecked boxes.
    local function SetState(val)
        box.checked = val and true or false
        if box.checked then ck:Show() else ck:Hide() end
        if box.SetBackdropColor then
            if box.checked then
                box:SetBackdropColor(0.10, 0.30, 0.36, 1)
                box:SetBackdropBorderColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
            else
                box:SetBackdropColor(0.04, 0.04, 0.04, 0.98)
                box:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
            end
        end
    end

    local function Toggle()
        SetState(not box.checked)
        if AutoMarkAssistDB then AutoMarkAssistDB[dbKey] = box.checked end
        AMA.Print(text .. ": " .. (box.checked and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))
        if onChange then onChange() end
        if AMA.UpdateMinimapState then AMA.UpdateMinimapState() end
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
    end

    box:SetScript("OnClick", Toggle)
    hit:SetScript("OnClick", Toggle)
    box:SetScript("OnEnter", function()
        if box.SetBackdropBorderColor then
            box:SetBackdropBorderColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 0.6)
        end
    end)
    box:SetScript("OnLeave", function()
        SetState(box.checked)
    end)
    box.SetCheckedState = function(_, val) SetState(val) end
    box.SetDisabled = function(_, disabled)
        box._disabled = disabled and true or false
        box:EnableMouse(not box._disabled)
        hit:EnableMouse(not box._disabled)
        lbl:SetTextColor(box._disabled and 0.4 or 1, box._disabled and 0.4 or 1, box._disabled and 0.4 or 1, 1)
    end
    box._dbKey = dbKey
    checkboxRefs[#checkboxRefs + 1] = { box, dbKey }
    return box
end

function E.EditBox(parent, w, h)
    local eb = CreateFrame("EditBox", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    eb:SetSize(w or 200, h or 20)
    eb:SetAutoFocus(false)
    if eb.SetBackdrop then
        eb:SetBackdrop(FLAT_BD)
        eb:SetBackdropColor(0.10, 0.10, 0.10, 1)
        eb:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
    end
    eb:SetFontObject("GameFontHighlightSmall")
    eb:SetTextColor(1, 1, 1, 1); eb:SetTextInsets(4, 4, 0, 0)
    eb:SetScript("OnEditFocusGained", function(self)
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
        end
    end)
    eb:SetScript("OnEditFocusLost", function(self)
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
        end
    end)
    return eb
end

-- ============================================================
-- CONFIG FRAME
-- ============================================================

local cfgFrame, currentTab, tabContents, tabBtns, ShowTab
local ApplyResponsiveConfigLayout
local modeBtns, proxRangeBtns, modBtns, announceChannelBtns
local announcePrefixEdit, scrollOrderCells, invertScrollBtn
local markToggleBoxes = {}
local dbTabCurrentZone, dbTabZoneChild, RefreshDBTab, dbTabMobScroll
local cbDynamic, cbCombatLock, cbRebal, cbAutoReset, cbCritters, cbAnnounce

-- ============================================================
-- RESPONSIVE LAYOUT
-- ============================================================

local function GetUIParentSize()
    local w = UIParent and UIParent:GetWidth() or 0
    local h = UIParent and UIParent:GetHeight() or 0
    if w > 0 and h > 0 then return w, h end
    return (GetScreenWidth and GetScreenWidth()) or CONFIG_W,
           (GetScreenHeight and GetScreenHeight()) or CONFIG_H
end

ApplyResponsiveConfigLayout = function()
    if not cfgFrame then return end
    local uiW, uiH = GetUIParentSize()
    local usableW = math.max(1, uiW - CONFIG_SCREEN_PAD * 2)
    local usableH = math.max(1, uiH - CONFIG_SCREEN_PAD * 2)
    local scale = math.max(CONFIG_MIN_SCALE, math.min(1, usableW / CONFIG_W, usableH / CONFIG_H))
    cfgFrame:SetScale(scale)
    cfgFrame:ClearAllPoints()
    cfgFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
end

-- ============================================================
-- FRAME CONSTRUCTION
-- ============================================================

do
    cfgFrame = CreateFrame("Frame", "AutoMarkAssistConfigFrame", UIParent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    cfgFrame:SetSize(CONFIG_W, CONFIG_H)
    cfgFrame:SetFrameStrata("DIALOG"); cfgFrame:SetFrameLevel(100)
    cfgFrame:EnableMouse(true); cfgFrame:SetMovable(true)
    cfgFrame:RegisterForDrag("LeftButton")
    cfgFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    cfgFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if ApplyResponsiveConfigLayout then ApplyResponsiveConfigLayout() end
    end)
    cfgFrame:SetClampedToScreen(true)
    cfgFrame:Hide()
    E.Skin(cfgFrame)

    -- Top accent line.
    local topAccent = cfgFrame:CreateTexture(nil, "ARTWORK")
    topAccent:SetTexture(W8); topAccent:SetHeight(2)
    topAccent:SetPoint("TOPLEFT", cfgFrame, "TOPLEFT", 0, 0)
    topAccent:SetPoint("TOPRIGHT", cfgFrame, "TOPRIGHT", 0, 0)
    topAccent:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)

    -- Title strip.
    local titleStrip = cfgFrame:CreateTexture(nil, "BACKGROUND")
    titleStrip:SetTexture(W8); titleStrip:SetHeight(24)
    titleStrip:SetPoint("TOPLEFT", cfgFrame, "TOPLEFT", 1, -2)
    titleStrip:SetPoint("TOPRIGHT", cfgFrame, "TOPRIGHT", -1, -2)
    titleStrip:SetVertexColor(0.10, 0.10, 0.10, 1)
    local title = cfgFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    title:SetPoint("LEFT", cfgFrame, "TOPLEFT", 10, -13)
    title:SetText("|cFF1A9EC0AutoMarkAssist|r  v" .. AMA.VERSION)

    -- Close button.
    local closeBtn = CreateFrame("Button", nil, cfgFrame)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("TOPRIGHT", cfgFrame, "TOPRIGHT", -5, -6)
    local cBg = closeBtn:CreateTexture(nil, "BACKGROUND")
    cBg:SetTexture(W8); cBg:SetAllPoints(); cBg:SetVertexColor(0.25, 0.07, 0.07, 0)
    local cFS = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cFS:SetPoint("CENTER", closeBtn, "CENTER", 0, 1); cFS:SetText("X")
    cFS:SetTextColor(0.55, 0.55, 0.55, 1)
    closeBtn:SetScript("OnEnter", function()
        cBg:SetVertexColor(0.60, 0.10, 0.10, 1); cFS:SetTextColor(1, 1, 1, 1)
    end)
    closeBtn:SetScript("OnLeave", function()
        cBg:SetVertexColor(0.25, 0.07, 0.07, 0); cFS:SetTextColor(0.55, 0.55, 0.55, 1)
    end)
    closeBtn:SetScript("OnClick", function() cfgFrame:Hide() end)

    -- ── TAB BAR ──
    local TAB_NAMES = { "General", "Database", "About" }
    tabContents = {}
    tabBtns = {}
    currentTab = 1

    for i, name in ipairs(TAB_NAMES) do
        local tb = E.Btn(cfgFrame, name, math.floor(CONFIG_W / #TAB_NAMES) - 2, TAB_H)
        tb:SetPoint("TOPLEFT", cfgFrame, "TOPLEFT",
            2 + (i - 1) * math.floor(CONFIG_W / #TAB_NAMES), -26)
        tabBtns[i] = tb

        local content = CreateFrame("Frame", nil, cfgFrame)
        content:SetPoint("TOPLEFT", cfgFrame, "TOPLEFT", 0, -26 - TAB_H - 2)
        content:SetPoint("BOTTOMRIGHT", cfgFrame, "BOTTOMRIGHT", 0, 0)
        content:Hide()
        tabContents[i] = content
    end

    ShowTab = function(idx)
        currentTab = idx
        for i, content in ipairs(tabContents) do
            if i == idx then content:Show() else content:Hide() end
            tabBtns[i]:SetActive(i == idx)
        end
        if idx == 2 and RefreshDBTab then RefreshDBTab() end
    end

    for i, tb in ipairs(tabBtns) do
        tb:SetScript("OnClick", function() ShowTab(i) end)
    end

    -- ================================================================
    -- TAB 1: GENERAL
    -- ================================================================

    local t1 = tabContents[1]
    local y = -10

    -- ── Enabled ──
    E.Chk(t1, "Enable Auto-Marking", 12, y, "enabled", function()
        AMA.UpdateMinimapState()
    end)
    y = y - 24

    E.Sep(t1, y)
    y = y - 8

    -- ── Marking Mode ──
    E.Header(t1, "Marking Mode", 8, y)
    y = y - 22

    local MODE_DEFS = {
        { key = "proximity", label = "Proximity" },
        { key = "mouseover", label = "Mouseover" },
        { key = "manual",    label = "Manual" },
    }
    modeBtns = {}
    for i, def in ipairs(MODE_DEFS) do
        local mb = E.Btn(t1, def.label, 90, 22)
        mb:SetPoint("TOPLEFT", t1, "TOPLEFT", 12 + (i - 1) * 108, y)
        mb:SetScript("OnClick", function()
            AMA.SetMarkingMode(def.key)
            AMA.UpdateMinimapState()
            AMA.Print("Marking mode: |cFFFFD700" .. def.label .. "|r")
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end)
        modeBtns[i] = mb
        modeBtns[i]._key = def.key
    end
    y = y - 28

    -- Proximity range.
    E.Label(t1, "Proximity Range:", 16, y)
    proxRangeBtns = {}
    for prIdx, rangeVal in ipairs({ 2, 3, 4 }) do
        local rb = E.Btn(t1, AMA.PROXIMITY_RANGE_LABELS[rangeVal] or tostring(rangeVal), 130, 22)
        rb:SetPoint("TOPLEFT", t1, "TOPLEFT", 130 + (prIdx - 1) * 135, y)
        rb:SetScript("OnClick", function()
            if AutoMarkAssistDB then AutoMarkAssistDB.proximityRange = rangeVal end
            AMA.Print("Proximity range: " .. (AMA.PROXIMITY_RANGE_LABELS[rangeVal] or tostring(rangeVal)))
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end)
        rb._val = rangeVal
        proxRangeBtns[#proxRangeBtns + 1] = rb
    end
    y = y - 24

    -- Manual modifier key.
    E.Label(t1, "Manual Modifier:", 16, y)
    modBtns = {}
    for mi, mod in ipairs({ "ALT", "SHIFT", "CTRL" }) do
        local mb = E.Btn(t1, mod, 60, 22)
        mb:SetPoint("TOPLEFT", t1, "TOPLEFT", 130 + (mi - 1) * 65, y)
        mb:SetScript("OnClick", function()
            if AutoMarkAssistDB then AutoMarkAssistDB.manualModifier = mod end
            AMA.Print("Manual modifier: " .. mod)
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end)
        mb._val = mod
        modBtns[#modBtns + 1] = mb
    end
    y = y - 28

    E.Sep(t1, y)
    y = y - 8

    -- ── Mark Toggles ──
    E.Header(t1, "Enabled Marks", 8, y)
    y = y - 22

    markToggleBoxes = {}
    for _, markIdx in ipairs(AMA.ALL_MARKS_ORDERED) do
        local desc = AMA.MARK_DESCRIPTIONS[markIdx] or "?"
        local markName = AMA.MARK_NAMES[markIdx] or "?"
        local isKill = (markIdx == MARK_SKULL or markIdx == MARK_CROSS)

        local row = CreateFrame("Frame", nil, t1)
        row:SetSize(CONFIG_W - 24, 20)
        row:SetPoint("TOPLEFT", t1, "TOPLEFT", 12, y)

        -- Mark icon.
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. markIdx)
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", row, "LEFT", 0, 0)

        -- Label.
        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", row, "LEFT", 22, 0)
        label:SetText(string.format("%s - %s", markName, desc))

        -- Checkbox (toggle).
        if not isKill then
            local box = CreateFrame("Button", nil, row,
                BackdropTemplateMixin and "BackdropTemplate" or nil)
            box:SetSize(16, 16)
            box:SetPoint("RIGHT", row, "RIGHT", -4, 0)
            box:RegisterForClicks("AnyUp"); box:EnableMouse(true)
            E.Skin(box)
            local ck = box:CreateTexture(nil, "OVERLAY")
            ck:SetTexture(W8); ck:SetSize(12, 12); ck:SetPoint("CENTER")
            ck:SetVertexColor(0.20, 0.90, 1.0, 1); ck:Hide()
            box._ck = ck; box._markIdx = markIdx

            local function SetState(val)
                box.checked = val and true or false
                if box.checked then ck:Show() else ck:Hide() end
                if box.SetBackdropColor then
                    if box.checked then
                        box:SetBackdropColor(0.10, 0.30, 0.36, 1)
                        box:SetBackdropBorderColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
                    else
                        box:SetBackdropColor(0.04, 0.04, 0.04, 0.98)
                        box:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
                    end
                end
            end

            box:SetScript("OnClick", function()
                local newVal = not box.checked
                SetState(newVal)
                if AutoMarkAssistDB and AutoMarkAssistDB.enabledMarks then
                    AutoMarkAssistDB.enabledMarks[markIdx] = newVal
                end
            end)
            box.SetCheckedState = function(_, val) SetState(val) end
            markToggleBoxes[markIdx] = box
        else
            -- Kill marks are always enabled; show "Always On" label.
            local alwaysLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            alwaysLabel:SetPoint("RIGHT", row, "RIGHT", -4, 0)
            alwaysLabel:SetText("|cFF888888Always On|r")
        end

        y = y - 22
    end
    y = y - 6

    E.Sep(t1, y)
    y = y - 8

    -- ── Behaviour ──
    E.Header(t1, "Behaviour", 8, y)
    y = y - 22

    cbDynamic = E.Chk(t1, "Dynamic Marking (bump lower-priority mobs)", 12, y, "dynamicMarking")
    y = y - 20
    cbCombatLock = E.Chk(t1, "Lock Marks in Combat", 12, y, "lockMarksInCombat")
    y = y - 20
    cbRebal = E.Chk(t1, "Rebalance Marks on Death", 12, y, "rebalanceOnDeath")
    y = y - 20
    cbAutoReset = E.Chk(t1, "Auto-Reset After Combat", 12, y, "autoReset")
    y = y - 20
    cbCritters = E.Chk(t1, "Skip Critters", 12, y, "skipCritters")
    y = y - 20
    E.Chk(t1, "Verbose Mode", 12, y, "verbose")
    y = y - 24

    E.Sep(t1, y)
    y = y - 8

    -- ── Announce ──
    E.Header(t1, "Announcements", 8, y)
    y = y - 22

    cbAnnounce = E.Chk(t1, "Announce Mark Plan on Dungeon Entry", 12, y, "announceOnEntry")
    y = y - 24

    E.Label(t1, "Channel:", 16, y)
    announceChannelBtns = {}
    for ci, ch in ipairs({ "SAY", "PARTY", "RAID" }) do
        local cb = E.Btn(t1, ch, 60, 22)
        cb:SetPoint("TOPLEFT", t1, "TOPLEFT", 80 + (ci - 1) * 68, y)
        cb:SetScript("OnClick", function()
            if AutoMarkAssistDB then AutoMarkAssistDB.announceChannel = ch end
            AMA.Print("Announce channel: " .. ch)
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end)
        cb._val = ch
        announceChannelBtns[#announceChannelBtns + 1] = cb
    end
    y = y - 24

    E.Label(t1, "Prefix:", 16, y)
    announcePrefixEdit = E.EditBox(t1, 200, 20)
    announcePrefixEdit:SetPoint("TOPLEFT", t1, "TOPLEFT", 80, y)
    announcePrefixEdit:SetScript("OnEnterPressed", function(self)
        if AutoMarkAssistDB then
            AutoMarkAssistDB.announcePrefixText = self:GetText()
        end
        self:ClearFocus()
    end)
    y = y - 28

    -- Announce/Preview buttons.
    local announceBtn = E.Btn(t1, "Announce Now", 100, 24)
    announceBtn:SetPoint("TOPLEFT", t1, "TOPLEFT", 24, y)
    announceBtn:SetScript("OnClick", function() AMA.AnnounceMarkPlan() end)

    local previewBtn = E.Btn(t1, "Preview", 80, 24)
    previewBtn:SetPoint("TOPLEFT", t1, "TOPLEFT", 140, y)
    previewBtn:SetScript("OnClick", function() AMA.PreviewMarkPlan() end)

    -- ================================================================
    -- TAB 2: DATABASE
    -- ================================================================

    local t2 = tabContents[2]

    -- Zone list on the left.
    local zoneListFrame = CreateFrame("Frame", nil, t2,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    zoneListFrame:SetPoint("TOPLEFT", t2, "TOPLEFT", 4, -4)
    zoneListFrame:SetPoint("BOTTOMLEFT", t2, "BOTTOMLEFT", 4, 4)
    zoneListFrame:SetWidth(160)
    E.Skin(zoneListFrame)

    local zoneScroll = CreateFrame("ScrollFrame", "AMA_ZoneScrollFrame", zoneListFrame, "UIPanelScrollFrameTemplate")
    zoneScroll:SetPoint("TOPLEFT", zoneListFrame, "TOPLEFT", 4, -4)
    zoneScroll:SetPoint("BOTTOMRIGHT", zoneListFrame, "BOTTOMRIGHT", -22, 4)
    local zoneChild = CreateFrame("Frame", nil, zoneScroll)
    zoneChild:SetWidth(130)
    zoneScroll:SetScrollChild(zoneChild)

    -- Mob list on the right.
    local mobListFrame = CreateFrame("Frame", nil, t2,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    mobListFrame:SetPoint("TOPLEFT", zoneListFrame, "TOPRIGHT", 4, 0)
    mobListFrame:SetPoint("BOTTOMRIGHT", t2, "BOTTOMRIGHT", -4, 4)
    E.Skin(mobListFrame)

    dbTabMobScroll = CreateFrame("ScrollFrame", "AMA_MobScrollFrame", mobListFrame, "UIPanelScrollFrameTemplate")
    dbTabMobScroll:SetPoint("TOPLEFT", mobListFrame, "TOPLEFT", 4, -4)
    dbTabMobScroll:SetPoint("BOTTOMRIGHT", mobListFrame, "BOTTOMRIGHT", -22, 4)
    dbTabZoneChild = CreateFrame("Frame", nil, dbTabMobScroll)
    dbTabZoneChild:SetWidth(260)
    dbTabMobScroll:SetScrollChild(dbTabZoneChild)

    local PRIORITY_CYCLE = { "HIGH", "CC", "MEDIUM", "LOW", "SKIP" }
    local PRIORITY_COLORS = {
        HIGH   = { 1.0, 0.4, 0.0 },
        CC     = { 0.0, 0.9, 0.9 },
        MEDIUM = { 0.9, 0.9, 0.2 },
        LOW    = { 0.5, 0.9, 0.5 },
        SKIP   = { 0.4, 0.4, 0.4 },
    }

    local function RefreshMobList(zoneName)
        if not dbTabZoneChild then return end
        -- Clear existing children.
        for _, child in ipairs({ dbTabZoneChild:GetChildren() }) do
            child:Hide(); child:SetParent(nil)
        end

        if not zoneName or zoneName == "" then return end

        local mobs = AMA.BuildZoneMobDB(zoneName)
        if not mobs then
            local noData = dbTabZoneChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            noData:SetPoint("TOPLEFT", dbTabZoneChild, "TOPLEFT", 8, -8)
            noData:SetText("|cFF888888No mob data for this zone.|r")
            dbTabZoneChild:SetHeight(30)
            return
        end

        -- Sort mob names.
        local sorted = {}
        for name in pairs(mobs) do sorted[#sorted + 1] = name end
        table.sort(sorted)

        local rowY = -4
        for _, mobName in ipairs(sorted) do
            local pri = mobs[mobName]
            local row = CreateFrame("Button", nil, dbTabZoneChild)
            row:SetSize(250, 18)
            row:SetPoint("TOPLEFT", dbTabZoneChild, "TOPLEFT", 4, rowY)
            row:RegisterForClicks("LeftButtonUp", "RightButtonUp")

            local nameFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            nameFS:SetPoint("LEFT", row, "LEFT", 2, 0)
            nameFS:SetText(mobName)
            nameFS:SetWidth(170)
            nameFS:SetJustifyH("LEFT")

            local priFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            priFS:SetPoint("RIGHT", row, "RIGHT", -2, 0)
            local c = PRIORITY_COLORS[pri] or { 0.7, 0.7, 0.7 }
            priFS:SetText(pri or "?")
            priFS:SetTextColor(c[1], c[2], c[3], 1)

            row:SetScript("OnClick", function(self, button)
                if button == "RightButton" then
                    -- Reset to default.
                    local overrides = AMA.GetZoneMobOverrides(zoneName, false)
                    if overrides then overrides[mobName] = nil end
                    RefreshMobList(zoneName)
                    return
                end
                -- Cycle priority.
                local currentIdx = 1
                for ci, cp in ipairs(PRIORITY_CYCLE) do
                    if cp == pri then currentIdx = ci; break end
                end
                local nextIdx = (currentIdx % #PRIORITY_CYCLE) + 1
                local newPri = PRIORITY_CYCLE[nextIdx]
                local overrides = AMA.GetZoneMobOverrides(zoneName, true)
                overrides[mobName] = newPri
                RefreshMobList(zoneName)
            end)

            row:SetScript("OnEnter", function()
                nameFS:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
            end)
            row:SetScript("OnLeave", function()
                nameFS:SetTextColor(1, 1, 1, 1)
            end)

            rowY = rowY - 18
        end

        dbTabZoneChild:SetHeight(math.abs(rowY) + 8)
    end

    local function RefreshZoneList()
        for _, child in ipairs({ zoneChild:GetChildren() }) do
            child:Hide(); child:SetParent(nil)
        end

        local zones = {}
        -- Collect from ExpansionOrder.
        if AutoMarkAssist_ExpansionOrder then
            for _, group in ipairs(AutoMarkAssist_ExpansionOrder) do
                if type(group) == "table" then
                    for i = 2, #group do
                        local z = group[i]
                        if z and z ~= "" then zones[#zones + 1] = z end
                    end
                end
            end
        end
        -- Also collect from MobDB directly.
        if AutoMarkAssist_MobDB then
            local zoneSet = {}
            for _, z in ipairs(zones) do zoneSet[z] = true end
            for z in pairs(AutoMarkAssist_MobDB) do
                if not zoneSet[z] then zones[#zones + 1] = z end
            end
        end

        local btnY = -4
        for _, zoneName in ipairs(zones) do
            local zBtn = CreateFrame("Button", nil, zoneChild)
            zBtn:SetSize(126, 16)
            zBtn:SetPoint("TOPLEFT", zoneChild, "TOPLEFT", 2, btnY)
            zBtn:RegisterForClicks("LeftButtonUp")

            local zFS = zBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            zFS:SetPoint("LEFT", zBtn, "LEFT", 2, 0)
            zFS:SetText(zoneName)
            zFS:SetWidth(122); zFS:SetJustifyH("LEFT")
            zFS:SetTextColor(0.8, 0.8, 0.8, 1)

            zBtn:SetScript("OnClick", function()
                dbTabCurrentZone = zoneName
                RefreshMobList(zoneName)
            end)
            zBtn:SetScript("OnEnter", function()
                zFS:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
            end)
            zBtn:SetScript("OnLeave", function()
                if dbTabCurrentZone == zoneName then
                    zFS:SetTextColor(1, 1, 1, 1)
                else
                    zFS:SetTextColor(0.8, 0.8, 0.8, 1)
                end
            end)

            btnY = btnY - 16
        end
        zoneChild:SetHeight(math.abs(btnY) + 8)
    end

    RefreshDBTab = function()
        RefreshZoneList()
        if dbTabCurrentZone then
            RefreshMobList(dbTabCurrentZone)
        end
    end

    -- ================================================================
    -- TAB 3: ABOUT
    -- ================================================================

    local t3 = tabContents[3]
    local ay = -12

    E.Header(t3, "AutoMarkAssist", 8, ay)
    ay = ay - 20
    E.Label(t3, "|cFFFFFFFFVersion:|r " .. AMA.VERSION, 16, ay)
    ay = ay - 16
    E.Label(t3, "|cFFFFFFFFAuthor:|r " .. AMA.AUTHOR, 16, ay)
    ay = ay - 24

    E.Header(t3, "Mark Assignments", 8, ay)
    ay = ay - 20

    local markInfo = {
        { 8, "First Kill" }, { 7, "Second Kill" },
        { 5, "Polymorph (Mage)" }, { 3, "Sap (Rogue)" },
        { 4, "Banish (Warlock)" }, { 1, "Shackle (Priest)" },
        { 2, "Hibernate (Druid)" }, { 6, "Trap (Hunter)" },
    }
    for _, info in ipairs(markInfo) do
        local markIdx, desc = info[1], info[2]
        local row = t3:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row:SetPoint("TOPLEFT", t3, "TOPLEFT", 16, ay)
        row:SetText((AMA.MARK_ICON_COORDS[markIdx] or "") .. "  " ..
            (AMA.MARK_NAMES[markIdx] or "?") .. " = " .. desc)
        ay = ay - 16
    end
    ay = ay - 8

    E.Header(t3, "Commands", 8, ay)
    ay = ay - 20

    local commands = {
        "/ama - Open options",
        "/ama enable | disable | toggle",
        "/ama reset - Clear all marks",
        "/ama announce - Send mark plan to chat",
        "/ama preview - Preview mark plan locally",
        "/ama mode <proximity|mouseover|manual>",
        "/ama verbose - Toggle debug output",
    }
    for _, cmd in ipairs(commands) do
        local cmdFS = t3:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        cmdFS:SetPoint("TOPLEFT", t3, "TOPLEFT", 16, ay)
        cmdFS:SetText("|cFFAAAAAA" .. cmd .. "|r")
        ay = ay - 14
    end

    -- Initial tab.
    ShowTab(1)
    ApplyResponsiveConfigLayout()
end

-- ============================================================
-- REFRESH & OPEN
-- ============================================================

function AMA.RefreshConfigFrame()
    if not cfgFrame or not cfgFrame:IsShown() then return end

    -- Sync checkboxes.
    for _, ref in ipairs(checkboxRefs) do
        local box, dbKey = ref[1], ref[2]
        if AutoMarkAssistDB and box.SetCheckedState then
            box:SetCheckedState(AutoMarkAssistDB[dbKey])
        end
    end

    -- Mode buttons.
    if modeBtns then
        local mode = AMA.GetMarkingMode()
        for _, mb in ipairs(modeBtns) do
            mb:SetActive(mb._key == mode)
        end
    end

    -- Proximity range.
    if proxRangeBtns then
        local range = AutoMarkAssistDB and AutoMarkAssistDB.proximityRange or 4
        for _, rb in ipairs(proxRangeBtns) do
            rb:SetActive(rb._val == range)
        end
    end

    -- Manual modifier.
    if modBtns then
        local mod = AutoMarkAssistDB and AutoMarkAssistDB.manualModifier or "ALT"
        for _, mb in ipairs(modBtns) do
            mb:SetActive(mb._val == mod)
        end
    end

    -- Announce channel.
    if announceChannelBtns then
        local ch = AutoMarkAssistDB and AutoMarkAssistDB.announceChannel or "PARTY"
        for _, cb in ipairs(announceChannelBtns) do
            cb:SetActive(cb._val == ch)
        end
    end

    -- Prefix.
    if announcePrefixEdit and AutoMarkAssistDB then
        announcePrefixEdit:SetText(AutoMarkAssistDB.announcePrefixText or "AutoMarkAssist")
    end

    -- Mark toggle boxes.
    for markIdx, box in pairs(markToggleBoxes) do
        if AutoMarkAssistDB and AutoMarkAssistDB.enabledMarks and box.SetCheckedState then
            box:SetCheckedState(AutoMarkAssistDB.enabledMarks[markIdx] ~= false)
        end
    end
end

function AMA.OpenConfigFrame(tabIdx)
    if not cfgFrame then return end
    if ApplyResponsiveConfigLayout then ApplyResponsiveConfigLayout() end
    cfgFrame:Show()
    AMA.RefreshConfigFrame()
    if tabIdx and ShowTab then ShowTab(tabIdx) end
end
