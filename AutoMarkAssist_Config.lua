-- AutoMarkAssist_Config.lua
-- Announce helpers and the Options configuration frame.
-- Loaded after AutoMarkAssist_Minimap.lua.
--
-- UI Style: ElvUI-inspired flat dark theme.
-- WHITE8x8 textured fills, 1-px solid borders, no Blizzard gradient
-- or border templates.  All layout dimensions derive from CONFIG_W /
-- CONFIG_H so the frame is accurate at any screen resolution or UI scale.

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

local CONFIG_W = 540
local CONFIG_H = 640
local TAB_H    = 22
local CONFIG_MIN_SCALE   = 0.55
local CONFIG_SCREEN_PAD  = 24
local CONFIG_TITLE_H     = 24
local CONFIG_TOP_OFFSET  = 50

-- Tier colour/label metadata used in pool editor.
local TIER_DEFS = {
    { key="HIGH",   label="High",   r=1.0, g=0.60, b=0.0  },
    { key="CC",     label="CC",     r=0.0, g=0.90, b=0.90 },
    { key="MEDIUM", label="Medium", r=0.9, g=0.90, b=0.2  },
    { key="LOW",    label="Low",    r=0.5, g=0.90, b=0.5  },
}

-- ============================================================
-- ANNOUNCE
-- /ama announce prints a formatted pull assignment list.
-- ============================================================

do  -- Announce scope

-- Chat-safe raid icon names recognised by SendChatMessage.
-- |T...texture...|t escape codes are LOCAL-ONLY (AddMessage);
-- SendChatMessage requires {skull}, {cross}, etc.
local CHAT_ICON = {
    [1]="{star}", [2]="{circle}", [3]="{diamond}", [4]="{triangle}",
    [5]="{moon}", [6]="{square}", [7]="{cross}",   [8]="{skull}",
}

local LOCAL_ICON = AMA.MARK_ICON_COORDS

local function GetAnnouncementHeader(label)
    local prefix = (AMA.BuildAnnouncementPrefix and AMA.BuildAnnouncementPrefix())
        or "[AutoMarkAssist] "
    if prefix ~= "" then
        return prefix .. label
    end
    return label
end

local function SendFormattedAnnouncement(channel, label, lines)
    local header = GetAnnouncementHeader(label)
    local lineByLine = AMA.IsLineByLineAnnouncementsEnabled
        and AMA.IsLineByLineAnnouncementsEnabled()

    if lineByLine then
        SendChatMessage(header, channel)
        for _, line in ipairs(lines) do
            SendChatMessage(line, channel)
        end
        return
    end

    local payload = table.concat(lines, ", ")
    if payload ~= "" then
        SendChatMessage(header .. " " .. payload, channel)
    else
        SendChatMessage(header, channel)
    end
end

local function PreviewFormattedAnnouncement(label, lines)
    local header = GetAnnouncementHeader(label)
    local lineByLine = AMA.IsLineByLineAnnouncementsEnabled
        and AMA.IsLineByLineAnnouncementsEnabled()

    if lineByLine then
        AMA.Print(header)
        for _, line in ipairs(lines) do
            AMA.Print(line)
        end
        return
    end

    local payload = table.concat(lines, ", ")
    if payload ~= "" then
        AMA.Print(header .. " " .. payload)
    else
        AMA.Print(header)
    end
end

local function ResolveAnnounceChannel(ch)
    if ch == "RAID" then
        if IsInRaid() then return "RAID" end
        if IsInGroup() then return "PARTY" end
        return nil, "Cannot announce to RAID - you are not in a group."
    end
    if ch == "PARTY" then
        if IsInRaid() then return "RAID" end
        if IsInGroup() then return "PARTY" end
        return nil, "Cannot announce to PARTY - you are not in a group."
    end
    return ch
end

-- Build a lookup of mark indices in the CC pool.
local function BuildCCPoolSet()
    local set = {}
    local pool = (AMA.GetActiveCCPool and AMA.GetActiveCCPool())
        or (AMA.GetConfiguredPool and AMA.GetConfiguredPool("CC"))
    if pool then
        for _, mi in ipairs(pool) do set[mi] = true end
    end
    return set
end

local function BuildConfiguredCCOrder()
    local order = {}
    local pool = (AMA.GetConfiguredPool and AMA.GetConfiguredPool("CC")) or {}
    for index, markIdx in ipairs(pool) do
        order[markIdx] = index
    end
    return order
end

local function IsAddonActionAvailable(showFeedback)
    if not AutoMarkAssistDB then
        if showFeedback then
            AMA.Print("DB not loaded.")
        end
        return false
    end
    if not (AMA.IsAddonEnabled and AMA.IsAddonEnabled()) then
        if showFeedback then
            AMA.Print("AutoMarkAssist is disabled.")
        end
        return false
    end
    return true
end

local function CanSendAnnouncements(showFeedback)
    if not IsAddonActionAvailable(showFeedback) then
        return false
    end
    if AMA.CanMarkReason then
        local canMark, reason = AMA.CanMarkReason()
        if not canMark then
            if showFeedback then
                AMA.Print("Announcements are suppressed until you can place raid markers (" .. tostring(reason) .. ").")
            end
            return false
        end
    end
    return true
end

local function BuildMarkLegendLines(iconMap)
    local legend = AutoMarkAssistDB and AutoMarkAssistDB.markLegend or {}
    local ccLimit = AutoMarkAssistDB and AutoMarkAssistDB.ccLimit or 0
    local ccPool = (ccLimit > 0) and BuildCCPoolSet() or {}
    local ccSeen = 0
    local lines = {}

    for _, idx in ipairs(AMA.ALL_MARKS_ORDERED) do
        local inCCPool = ccLimit > 0 and ccPool[idx]
        if inCCPool then
            ccSeen = ccSeen + 1
        end

        if not (inCCPool and ccSeen > ccLimit) then
            local desc = legend[idx]
            if desc and desc ~= "" then
                local icon = iconMap[idx] or ("[" .. idx .. "]")
                local ownerGUID = AMA.markOwners[idx]
                local line
                if ownerGUID then
                    local token = AMA.markTokens[idx]
                    local name = token and UnitName(token) or "?"
                    line = string.format("%s  %s  -  %s", icon, desc, name)
                else
                    line = string.format("%s  %s", icon, desc)
                end
                lines[#lines + 1] = line
            end
        end
    end

    return lines
end

local function AnnounceMarkOrder()
    if not CanSendAnnouncements(true) then return end
    local ch = AutoMarkAssistDB.announceChannel or "PARTY"
    local resolvedChannel, err = ResolveAnnounceChannel(ch)
    if not resolvedChannel then
        AMA.Print(err)
        return
    end
    ch = resolvedChannel

    local lines = BuildMarkLegendLines(CHAT_ICON)

    if #lines == 0 then
        AMA.Print("No legend descriptions set.  Fill in the Legend tab first.")
        return
    end

    SendFormattedAnnouncement(ch, "Mark legend:", lines)
end

local function PreviewMarkOrder()
    if not IsAddonActionAvailable(true) then return end
    local lines = BuildMarkLegendLines(LOCAL_ICON)

    if #lines == 0 then
        AMA.Print("No legend descriptions set.  Fill in the Legend tab first.")
        return
    end

    PreviewFormattedAnnouncement("Mark legend:", lines)
end

local function AnnounceDungeonSmartCCAssignments(options)
    options = options or {}

    if not CanSendAnnouncements(options.showFeedback) then
        return false
    end
    if not (AMA.IsDungeonSmartCCEnabled and AMA.IsDungeonSmartCCEnabled()) then
        if options.showFeedback then
            AMA.Print("Dungeon Smart CC announcements are only available while Smart Dungeon CC is enabled inside a 5-player dungeon.")
        end
        return false
    end

    local ch, err = ResolveAnnounceChannel("PARTY")
    if not ch then
        if options.showFeedback then
            AMA.Print(err or "Cannot announce the dungeon CC assignments right now.")
        end
        AMA.VPrint("Skipped automatic dungeon CC announcement: " .. tostring(err))
        return false
    end

    local configuredCCPool = (AMA.GetConfiguredPool and AMA.GetConfiguredPool("CC")) or {}
    local effectiveCCMarks = 0
    local ccLimit = AutoMarkAssistDB and AutoMarkAssistDB.ccLimit or 0
    for _ in ipairs(configuredCCPool) do
        effectiveCCMarks = effectiveCCMarks + 1
        if ccLimit > 0 and effectiveCCMarks >= ccLimit then
            break
        end
    end
    if effectiveCCMarks == 0 then
        if options.showFeedback then
            AMA.Print("No dedicated CC marks are configured in the current pool.")
        end
        return false
    end

    local assignments = AMA.GetDungeonSmartCCAssignments
        and AMA.GetDungeonSmartCCAssignments(nil, { respectCCLimit = true })
    if not assignments then
        return false
    end

    if #assignments == 0 then
        SendFormattedAnnouncement(ch, "Dungeon CC:", {
            "No dedicated party CC detected, so CC targets will fall back to kill-order marks.",
        })
        if options.showFeedback then
            AMA.Print("Repeated the dungeon CC fallback announcement to party chat.")
        end
        return true
    end

    local ccOrder = BuildConfiguredCCOrder()
    table.sort(assignments, function(left, right)
        local leftOrder = ccOrder[left.markIdx] or 99
        local rightOrder = ccOrder[right.markIdx] or 99
        if leftOrder ~= rightOrder then
            return leftOrder < rightOrder
        end
        return (left.markIdx or 0) < (right.markIdx or 0)
    end)

    local segments = {}
    for _, assignment in ipairs(assignments) do
        local icon = CHAT_ICON[assignment.markIdx] or ""
        local ccLabel = assignment.ccLabel or "CC"
        local name = assignment.name or "?"
        segments[#segments + 1] = string.format("%s %s - %s", icon, ccLabel, name)
    end

    SendFormattedAnnouncement(ch, "Dungeon CC:", segments)
    if options.showFeedback then
        AMA.Print("Repeated the dungeon CC assignments to party chat.")
    end
    return true
end

function AutoMarkAssist_Announce()  AnnounceMarkOrder() end
function AutoMarkAssist_Preview()   PreviewMarkOrder()  end
function AutoMarkAssist_AnnounceDungeonSmartCC(options) return AnnounceDungeonSmartCCAssignments(options) end
function AutoMarkAssist_ResetPreviewWarning() end

AMA.AnnounceDungeonSmartCCAssignments = AnnounceDungeonSmartCCAssignments

end  -- Announce scope

-- ============================================================
-- CONFIG FRAME -- forward-declare shared upvalues
-- ============================================================

local cfgFrame
local currentTab  = 1
local tabContents = {}
local tabBtns     = {}
local ShowTab
local ApplyResponsiveConfigLayout
local ShowConfigHelpPopup

-- All checkboxes register here so RefreshConfigFrame can sync them.
local checkboxRefs = {}  -- { {boxFrame, dbKey}, ... }

-- Widget tables that must survive the do block so RefreshConfigFrame can
-- read them as upvalues (Lua locals die at the end of their do scope).
local proxBtns, moRangeBtns, modBtns, announceChannelBtns, announceFormatBtns, resetKeyBtn, ccLimitBtns
local repeatDungeonCCBtn, announcePrefixEdit
local poolBtnsMap
local legendBoxes
local smartCCRoleMarkBtns

-- DB tab upvalues (outlive the construction do-block)
local dbTabMobScroll
local dbTabCurrentZone
local dbTabActiveZoneBtn
local dbTabZoneChild
local RefreshDBTab
local dbResetZoneBtn
local dbAddMobEB
local dbAddMobPriSel
local dbAddMobPriBtns

-- Scroll order reorder cells (Manual Mode section of Tab 1)
local scrollOrderCells
local invertScrollBtn

-- Checkboxes that must be disabled when manual mode is active.
local cbDynamic, cbCombatLock, cbRebal, cbSkip, cbCrit, cbProx, cbMouseover, cbMoRange, cbSmartDungeonCC, cbAutoDungeonCC

-- ============================================================
-- ELVUI-STYLE SKIN HELPERS
-- Centralised colour constants and element factories.
-- ============================================================

local E = {}

-- Colour tables  {r, g, b, a}
E.BG     = {0.06, 0.06, 0.06, 0.96}   -- main frame background
E.BG2    = {0.04, 0.04, 0.04, 0.98}   -- deeper / inset fill
E.BORDER = {0.15, 0.15, 0.15, 1.00}   -- default 1-px border
E.ACCENT = {0.10, 0.62, 0.75, 1.00}   -- ElvUI teal highlight
E.BTN_N  = {0.12, 0.12, 0.12, 1.00}   -- button: normal
E.BTN_H  = {0.22, 0.22, 0.22, 1.00}   -- button: hover
E.BTN_P  = {0.07, 0.07, 0.07, 1.00}   -- button: pressed
E.BTN_A  = {0.08, 0.25, 0.30, 1.00}   -- button: active/selected

-- The single flat texture used everywhere.
local W8 = "Interface\\Buttons\\WHITE8x8"

-- 1-px solid-border backdrop descriptor.
local FLAT_BD = {
    bgFile   = W8,
    edgeFile = W8,
    tile     = false,
    edgeSize = 1,
    insets   = { left=1, right=1, top=1, bottom=1 },
}

-- Apply an ElvUI flat backdrop to a frame.
-- Optional br/bg/bb override the default border colour.
function E.Skin(f, br, bg2, bb)
    if not f.SetBackdrop then return end
    f:SetBackdrop(FLAT_BD)
    f:SetBackdropColor(E.BG[1], E.BG[2], E.BG[3], E.BG[4])
    f:SetBackdropBorderColor(br or E.BORDER[1], bg2 or E.BORDER[2], bb or E.BORDER[3], 1.0)
end

-- Small left-anchored label.
function E.Label(parent, text, x, y, font)
    local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    fs:SetText(text)
    return fs
end

-- Section header: 2-px left accent bar + teal text.
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

-- Thin 1-px horizontal separator.
function E.Sep(parent, y, xPad)
    xPad = xPad or 8
    local s = parent:CreateTexture(nil, "ARTWORK")
    s:SetTexture(W8); s:SetHeight(1)
    s:SetPoint("TOPLEFT",  parent, "TOPLEFT",   xPad, y)
    s:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -xPad, y)
    s:SetVertexColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 0.8)
    return s
end

-- Flat button.  GetFontString() is wired to the label font string.
function E.Btn(parent, text, w, h)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(w or 80, h or 20)
    -- Fill
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(W8); bg:SetAllPoints()
    bg:SetVertexColor(E.BTN_N[1], E.BTN_N[2], E.BTN_N[3], 1)
    btn._bg = bg
    -- 1-px border via child BackdropTemplate when available
    if BackdropTemplateMixin then
        local bd = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        bd:SetAllPoints(); bd:SetFrameLevel(btn:GetFrameLevel())
        bd:SetBackdrop({ bgFile=nil, edgeFile=W8, tile=false,
            edgeSize=1, insets={left=0,right=0,top=0,bottom=0} })
        bd:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
        btn._bd = bd
    end
    -- Label
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("CENTER", btn, "CENTER", 0, 0)
    fs:SetText(text or ""); fs:SetTextColor(1, 1, 1, 1)
    btn:SetFontString(fs)

    -- SetDisabled(true) greys out the button and blocks clicks;
    -- SetDisabled(false) restores normal interaction.
    btn._disabled = false
    btn._active = false

    local function ApplyVisual(state)
        if btn._disabled then
            fs:SetTextColor(0.40, 0.40, 0.40, 1)
            btn._bg:SetVertexColor(E.BTN_N[1], E.BTN_N[2], E.BTN_N[3], 0.5)
            return
        end
        if btn._active then
            fs:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
        else
            fs:SetTextColor(1, 1, 1, 1)
        end
        if state == "down" then
            btn._bg:SetVertexColor(E.BTN_P[1], E.BTN_P[2], E.BTN_P[3], 1)
        elseif state == "hover" and not btn._active then
            btn._bg:SetVertexColor(E.BTN_H[1], E.BTN_H[2], E.BTN_H[3], 1)
        elseif btn._active then
            btn._bg:SetVertexColor(E.BTN_A[1], E.BTN_A[2], E.BTN_A[3], 1)
        else
            btn._bg:SetVertexColor(E.BTN_N[1], E.BTN_N[2], E.BTN_N[3], 1)
        end
    end

    -- Interaction states.
    btn:SetScript("OnEnter",    function() ApplyVisual("hover") end)
    btn:SetScript("OnLeave",    function() ApplyVisual("normal") end)
    btn:SetScript("OnMouseDown",function() ApplyVisual("down") end)
    btn:SetScript("OnMouseUp",  function() ApplyVisual("hover") end)

    btn.SetActive = function(_, active)
        btn._active = active and true or false
        ApplyVisual("normal")
    end

    btn.SetDisabled = function(_, disabled)
        btn._disabled = disabled and true or false
        if btn._disabled then
            btn:EnableMouse(false)
        else
            btn:EnableMouse(true)
        end
        ApplyVisual("normal")
    end

    return btn
end

-- Flat checkbox.  Returns the box frame which exposes :SetCheckedState(bool).
-- Automatically registers in checkboxRefs for DB state sync on frame open.
function E.Chk(parent, text, x, y, dbKey, onChange)
    -- Box -- uses a Button so it directly receives mouse clicks.
    local box = CreateFrame("Button", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    box:SetSize(14, 14)
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y - 2)
    box:RegisterForClicks("AnyUp")
    box:EnableMouse(true)
    E.Skin(box)
    -- Tick mark: solid teal square (10x10 for high visibility)
    local ck = box:CreateTexture(nil, "OVERLAY")
    ck:SetTexture(W8); ck:SetSize(10, 10); ck:SetPoint("CENTER", box, "CENTER")
    ck:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1); ck:Hide()
    box._ck     = ck
    box.checked = false
    -- Label
    local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lbl:SetPoint("LEFT", box, "RIGHT", 5, 1)
    lbl:SetText(text); lbl:SetTextColor(1, 1, 1, 1)
    -- Extended hit region over the label text so clicking the label
    -- also toggles the checkbox.
    local hit = CreateFrame("Button", nil, parent)
    hit:SetHeight(18)
    hit:SetPoint("LEFT",  box, "RIGHT", 3, 0)
    hit:SetPoint("RIGHT", lbl, "RIGHT", 2, 0)
    hit:SetFrameLevel(box:GetFrameLevel() + 1)
    hit:RegisterForClicks("AnyUp")
    hit:EnableMouse(true)

    local function SetState(val)
        box.checked = val and true or false
        if box.checked then
            ck:Show()
            if box.SetBackdropColor then
                box:SetBackdropColor(0.08, 0.18, 0.22, 1)
            end
            if box.SetBackdropBorderColor then
                box:SetBackdropBorderColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
            end
        else
            ck:Hide()
            if box.SetBackdropColor then
                box:SetBackdropColor(E.BG[1], E.BG[2], E.BG[3], E.BG[4])
            end
            if box.SetBackdropBorderColor then
                box:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
            end
        end
    end

    local function Toggle()
        SetState(not box.checked)
        if AutoMarkAssistDB then AutoMarkAssistDB[dbKey] = box.checked end
        local stateStr = box.checked and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"
        AMA.Print(text .. ": " .. stateStr)
        if onChange then onChange() end
        if AMA.UpdateMinimapState then AMA.UpdateMinimapState() end
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
    end

    -- Both the box and the label hit region trigger Toggle.
    box:SetScript("OnClick", Toggle)
    hit:SetScript("OnClick", Toggle)
    -- Hover feedback on the box square.
    box:SetScript("OnEnter", function()
        if box.SetBackdropBorderColor then
            box:SetBackdropBorderColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 0.6)
        end
    end)
    box:SetScript("OnLeave", function()
        if box.checked then
            if box.SetBackdropBorderColor then
                box:SetBackdropBorderColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
            end
        else
            if box.SetBackdropBorderColor then
                box:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
            end
        end
    end)
    -- Wrap so that colon-call syntax (box:SetCheckedState(val)) discards
    -- the implicit 'self' argument and forwards only 'val' to SetState.
    box.SetCheckedState = function(_, val) SetState(val) end

    -- Expose label and hit-region so callers can grey-out / disable.
    box._lbl = lbl
    box._hit = hit
    box._dbKey = dbKey

    -- SetDisabled(true) greys out the checkbox and ignores clicks;
    -- SetDisabled(false) restores normal interaction.
    box._disabled = false
    box.SetDisabled = function(_, disabled)
        box._disabled = disabled and true or false
        if box._disabled then
            box:EnableMouse(false)
            hit:EnableMouse(false)
            lbl:SetTextColor(0.40, 0.40, 0.40, 1)
            ck:SetVertexColor(0.40, 0.40, 0.40, 1)
            if box.SetBackdropBorderColor then
                box:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 0.5)
            end
            if box.SetBackdropColor then
                box:SetBackdropColor(E.BG[1], E.BG[2], E.BG[3], 0.5)
            end
        else
            box:EnableMouse(true)
            hit:EnableMouse(true)
            lbl:SetTextColor(1, 1, 1, 1)
            ck:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
            -- Re-apply checked/unchecked visual state.
            SetState(box.checked)
        end
    end

    -- Register for automatic sync
    checkboxRefs[#checkboxRefs + 1] = { box, dbKey }
    return box
end

-- Flat EditBox with focus-acquired teal border highlight.
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

-- Returns the current UIParent size, falling back to the physical screen
-- when the parent has not been sized yet during load.
local function GetUIParentSize()
    local width = UIParent and UIParent:GetWidth() or 0
    local height = UIParent and UIParent:GetHeight() or 0
    if width and width > 0 and height and height > 0 then
        return width, height
    end
    width = (GetScreenWidth and GetScreenWidth()) or CONFIG_W
    height = (GetScreenHeight and GetScreenHeight()) or CONFIG_H
    return width, height
end

-- Scales and repositions the config frame so the entire shell stays visible
-- on smaller resolutions while preserving the existing fixed-pixel layout.
ApplyResponsiveConfigLayout = function()
    if not cfgFrame then return end

    local uiW, uiH = GetUIParentSize()
    local usableW = math.max(1, uiW - CONFIG_SCREEN_PAD * 2)
    local usableH = math.max(1, uiH - CONFIG_SCREEN_PAD * 2)

    local scaleW = usableW / CONFIG_W
    local scaleH = usableH / CONFIG_H
    local scale = math.min(1, scaleW, scaleH)
    scale = math.max(CONFIG_MIN_SCALE, scale)
    if CONFIG_W * scale > usableW or CONFIG_H * scale > usableH then
        scale = math.min(1, scaleW, scaleH)
    end

    local centerX, centerY = cfgFrame:GetCenter()
    if (not centerX or not centerY) and AutoMarkAssistDB and AutoMarkAssistDB.configFramePos then
        centerX = tonumber(AutoMarkAssistDB.configFramePos.x)
        centerY = tonumber(AutoMarkAssistDB.configFramePos.y)
    end
    cfgFrame:SetScale(scale)

    local topGap = math.floor(math.min(CONFIG_TOP_OFFSET, math.max(8, uiH * 0.08)))
    local verticalOffset = math.floor((CONFIG_TITLE_H + TAB_H) * scale * 0.5)

    local scaledW = CONFIG_W * scale
    local scaledH = CONFIG_H * scale
    local halfW = scaledW * 0.5
    local halfH = scaledH * 0.5

    if not centerX or not centerY then
        centerX = uiW * 0.5
        centerY = uiH - topGap - verticalOffset - halfH
    end

    if scaledW + CONFIG_SCREEN_PAD * 2 >= uiW then
        centerX = uiW * 0.5
    else
        centerX = math.max(halfW + CONFIG_SCREEN_PAD, math.min(uiW - halfW - CONFIG_SCREEN_PAD, centerX))
    end

    if scaledH + CONFIG_SCREEN_PAD * 2 >= uiH then
        centerY = uiH * 0.5
    else
        centerY = math.max(halfH + CONFIG_SCREEN_PAD, math.min(uiH - halfH - CONFIG_SCREEN_PAD, centerY))
    end

    cfgFrame:ClearAllPoints()
    cfgFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", centerX, centerY)
end

-- ============================================================
-- MAIN CONSTRUCTION
-- do-block keeps intermediate locals scoped; only the upvalues above
-- (cfgFrame, tabContents, poolBtnsMap, etc.) survive for REFRESH.
-- ============================================================

do  -- Config frame construction scope

-- ---- FRAME SHELL -------------------------------------------------------
cfgFrame = CreateFrame("Frame", "AutoMarkAssistConfigFrame", UIParent,
    BackdropTemplateMixin and "BackdropTemplate" or nil)
cfgFrame:SetSize(CONFIG_W, CONFIG_H)
cfgFrame:SetFrameStrata("DIALOG"); cfgFrame:SetFrameLevel(100)
cfgFrame:EnableMouse(true); cfgFrame:SetMovable(true)
cfgFrame:RegisterForDrag("LeftButton")
cfgFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
cfgFrame:SetScript("OnDragStop",  function(self)
    self:StopMovingOrSizing()
    if ApplyResponsiveConfigLayout then ApplyResponsiveConfigLayout() end
    if AutoMarkAssistDB then
        local centerX, centerY = self:GetCenter()
        if centerX and centerY then
            AutoMarkAssistDB.configFramePos = {
                x = centerX,
                y = centerY,
            }
        end
    end
end)
cfgFrame:SetClampedToScreen(true)
cfgFrame:Hide()

ApplyResponsiveConfigLayout()

E.Skin(cfgFrame)

-- 2-px accent line across the very top
local topAccent = cfgFrame:CreateTexture(nil, "ARTWORK")
topAccent:SetTexture(W8); topAccent:SetHeight(2)
topAccent:SetPoint("TOPLEFT",  cfgFrame, "TOPLEFT",  0, 0)
topAccent:SetPoint("TOPRIGHT", cfgFrame, "TOPRIGHT", 0, 0)
topAccent:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)

-- Slightly lighter title strip
local titleStrip = cfgFrame:CreateTexture(nil, "BACKGROUND")
titleStrip:SetTexture(W8); titleStrip:SetHeight(24)
titleStrip:SetPoint("TOPLEFT",  cfgFrame, "TOPLEFT",  1, -2)
titleStrip:SetPoint("TOPRIGHT", cfgFrame, "TOPRIGHT", -1, -2)
titleStrip:SetVertexColor(0.10, 0.10, 0.10, 1)

local title = cfgFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
title:SetPoint("LEFT", cfgFrame, "TOPLEFT", 10, -13)
title:SetText("|cFF1A9EC0AutoMarkAssist|r  v" .. AMA.VERSION)

-- Close button: flat 16x16 with hover-red fill
local closeBtn = CreateFrame("Button", nil, cfgFrame)
closeBtn:SetSize(16, 16)
closeBtn:SetPoint("TOPRIGHT", cfgFrame, "TOPRIGHT", -5, -6)
local cBg = closeBtn:CreateTexture(nil, "BACKGROUND")
cBg:SetTexture(W8); cBg:SetAllPoints(); cBg:SetVertexColor(0.25, 0.07, 0.07, 0)
local cFS = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
cFS:SetPoint("CENTER", closeBtn, "CENTER", 0, 1)
cFS:SetText("X"); cFS:SetTextColor(0.55, 0.55, 0.55, 1)
closeBtn:SetScript("OnEnter", function()
    cBg:SetVertexColor(0.60, 0.10, 0.10, 1); cFS:SetTextColor(1, 1, 1, 1)
end)
closeBtn:SetScript("OnLeave", function()
    cBg:SetVertexColor(0.25, 0.07, 0.07, 0); cFS:SetTextColor(0.55, 0.55, 0.55, 1)
end)
closeBtn:SetScript("OnClick", function() cfgFrame:Hide() end)

do
    local helpPopup = CreateFrame("Frame", nil, cfgFrame,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    helpPopup:SetSize(396, 244)
    helpPopup:SetPoint("CENTER", cfgFrame, "CENTER", 0, 0)
    helpPopup:SetFrameStrata("FULLSCREEN_DIALOG")
    helpPopup:SetFrameLevel(cfgFrame:GetFrameLevel() + 30)
    helpPopup:EnableMouse(true)
    helpPopup:Hide()
    E.Skin(helpPopup)

    local helpTopAccent = helpPopup:CreateTexture(nil, "ARTWORK")
    helpTopAccent:SetTexture(W8)
    helpTopAccent:SetHeight(2)
    helpTopAccent:SetPoint("TOPLEFT", helpPopup, "TOPLEFT", 0, 0)
    helpTopAccent:SetPoint("TOPRIGHT", helpPopup, "TOPRIGHT", 0, 0)
    helpTopAccent:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)

    local helpTitle = helpPopup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    helpTitle:SetPoint("TOPLEFT", helpPopup, "TOPLEFT", 12, -12)
    helpTitle:SetPoint("TOPRIGHT", helpPopup, "TOPRIGHT", -32, -12)
    helpTitle:SetJustifyH("LEFT")
    helpTitle:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)

    local helpBody = helpPopup:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    helpBody:SetPoint("TOPLEFT", helpPopup, "TOPLEFT", 12, -42)
    helpBody:SetPoint("TOPRIGHT", helpPopup, "TOPRIGHT", -12, -42)
    helpBody:SetPoint("BOTTOM", helpPopup, "BOTTOM", 0, 38)
    helpBody:SetJustifyH("LEFT")
    helpBody:SetJustifyV("TOP")
    helpBody:SetTextColor(0.84, 0.84, 0.84, 1)

    local helpCloseBtn = E.Btn(helpPopup, "Close", 88, 20)
    helpCloseBtn:SetPoint("BOTTOM", helpPopup, "BOTTOM", 0, 10)
    helpCloseBtn:SetScript("OnClick", function()
        helpPopup:Hide()
    end)

    local helpXBtn = CreateFrame("Button", nil, helpPopup)
    helpXBtn:SetSize(16, 16)
    helpXBtn:SetPoint("TOPRIGHT", helpPopup, "TOPRIGHT", -5, -6)
    local helpXBg = helpXBtn:CreateTexture(nil, "BACKGROUND")
    helpXBg:SetTexture(W8)
    helpXBg:SetAllPoints()
    helpXBg:SetVertexColor(0.25, 0.07, 0.07, 0)
    local helpXFs = helpXBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    helpXFs:SetPoint("CENTER", helpXBtn, "CENTER", 0, 1)
    helpXFs:SetText("X")
    helpXFs:SetTextColor(0.55, 0.55, 0.55, 1)
    helpXBtn:SetScript("OnEnter", function()
        helpXBg:SetVertexColor(0.60, 0.10, 0.10, 1)
        helpXFs:SetTextColor(1, 1, 1, 1)
    end)
    helpXBtn:SetScript("OnLeave", function()
        helpXBg:SetVertexColor(0.25, 0.07, 0.07, 0)
        helpXFs:SetTextColor(0.55, 0.55, 0.55, 1)
    end)
    helpXBtn:SetScript("OnClick", function()
        helpPopup:Hide()
    end)

    ShowConfigHelpPopup = function(titleText, bodyText)
        helpTitle:SetText(titleText or "")
        helpBody:SetText(bodyText or "")
        helpPopup:Show()
    end

    cfgFrame:HookScript("OnHide", function()
        helpPopup:Hide()
    end)
end

local function ShowManualSaveHelp()
    if not ShowConfigHelpPopup then return end
    ShowConfigHelpPopup(
        "How Manual Marks Are Saved",
        "Manual marking lets you choose a mark first, then apply it when the picker closes.\n\n"
            .. "After that, the addon saves a per-zone memory for that mob.\n\n"
            .. "The icon you pick is remembered as a preferred mark. If that icon is free later, auto mode will try to use it again.\n\n"
            .. "The mob's matching priority tier is also written into the Database tab for that zone. That lets auto marking keep using your chosen setup after you leave manual mode.")
end

local function ShowSubPriorityHelp()
    if not ShowConfigHelpPopup then return end
    ShowConfigHelpPopup(
        "How Sub-Priority Works",
        "Sub only matters when two mobs have the same main Priority.\n\n"
            .. "Lower number wins, so Sub 1 gets the better mark before Sub 2.\n\n"
            .. "A higher main Priority still wins first, so HIGH beats MEDIUM or LOW even if the lower tier has Sub 1.\n\n"
            .. "Use the Sub column to cycle 1-9 with left-click, or right-click to clear your custom value.")
end

local function ShowSmartCCHelp()
    if not ShowConfigHelpPopup then return end
    ShowConfigHelpPopup(
        "How Smart Dungeon CC Works",
        "When enabled, dungeon auto-marking looks at your current 5-player group and only hands out CC marks that match the party's available control classes.\n\n"
            .. "It also checks the target's creature type before using a CC icon. Example: undead prefer Priest-style CC, demons and elementals prefer Warlock-style CC, and beasts can use Hunter, Druid, or Mage-style CC.\n\n"
            .. "You can change which icon each CC type prefers from the Legend tab, so assignments like moon for sheep or diamond for sap can match your group's conventions.\n\n"
            .. "If the party cannot reliably crowd-control that target type, or all compatible CC marks are already taken, the mob falls back to kill-order marks instead of receiving a misleading CC icon.\n\n"
            .. "On dungeon entry, automated mode also posts the current party CC responsibilities to party chat so everyone can see which player owns each CC mark.\n\n"
            .. "If the group needs a reminder later, use the Repeat Party CC button or /ama ccannounce to post the assignments again.")
end

local function ShowLatestWhatsNew()
    if AutoMarkAssistDB then
        AutoMarkAssistDB.lastSeenWhatsNew = AMA.VERSION
    end
    if AMA.OpenConfigFrame then
        AMA.OpenConfigFrame(5)
    end
    if not ShowConfigHelpPopup then return end
    ShowConfigHelpPopup(
        (AMA.GetLatestWhatsNewTitle and AMA.GetLatestWhatsNewTitle()) or ("What's New in v" .. AMA.VERSION),
        (AMA.GetLatestWhatsNewText and AMA.GetLatestWhatsNewText()) or "")
end
AMA.ShowLatestWhatsNew = ShowLatestWhatsNew

-- ---- TAB STRIP ---------------------------------------------------------
-- Tabs are distributed evenly across CONFIG_W; no hard-coded pixel widths,
-- so the strip stays accurate at any effective UI scale.

local TAB_NAMES = { "General", "Pools", "Legend", "Database", "About" }
local TAB_GAP   = 2
local TAB_Y     = -28  -- distance from cfgFrame top to tab strip top
local TAB_AVAIL = CONFIG_W - 2  -- 1-px margin each side
local TAB_W     = math.floor((TAB_AVAIL - TAB_GAP * (#TAB_NAMES - 1)) / #TAB_NAMES)

-- Thin accent separator below the tab strip
local tabSep = cfgFrame:CreateTexture(nil, "ARTWORK")
tabSep:SetTexture(W8); tabSep:SetHeight(1)
tabSep:SetPoint("TOPLEFT",  cfgFrame, "TOPLEFT",  1, TAB_Y - TAB_H)
tabSep:SetPoint("TOPRIGHT", cfgFrame, "TOPRIGHT", -1, TAB_Y - TAB_H)
tabSep:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 0.45)

for i, name in ipairs(TAB_NAMES) do
    local btn = CreateFrame("Button", nil, cfgFrame)
    btn:SetSize(TAB_W, TAB_H)
    local tx = 1 + (i - 1) * (TAB_W + TAB_GAP)
    btn:SetPoint("TOPLEFT", cfgFrame, "TOPLEFT", tx, TAB_Y)

    local tbg = btn:CreateTexture(nil, "BACKGROUND")
    tbg:SetTexture(W8); tbg:SetAllPoints()
    tbg:SetVertexColor(0.10, 0.10, 0.10, 1); btn._bg = tbg

    -- Active indicator: 2-px teal bar along the bottom edge
    local tbar = btn:CreateTexture(nil, "OVERLAY")
    tbar:SetTexture(W8); tbar:SetHeight(2)
    tbar:SetPoint("BOTTOMLEFT",  btn, "BOTTOMLEFT",  0, 0)
    tbar:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
    tbar:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1); tbar:Hide()
    btn._bar = tbar

    local tfs = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tfs:SetPoint("CENTER", btn, "CENTER", 0, 0)
    tfs:SetText(name); tfs:SetTextColor(0.50, 0.50, 0.50, 1); btn._lbl = tfs
    btn:SetFontString(tfs)
    btn:SetID(i)
    btn:SetScript("OnClick", function(self) ShowTab(self:GetID()) end)
    btn:SetScript("OnEnter", function(self)
        if currentTab ~= self:GetID() then self._bg:SetVertexColor(0.16, 0.16, 0.16, 1) end
    end)
    btn:SetScript("OnLeave", function(self)
        if currentTab ~= self:GetID() then self._bg:SetVertexColor(0.10, 0.10, 0.10, 1) end
    end)
    tabBtns[i] = btn
end

-- Content area background (darker shade below tab strip)
local CONTENT_Y = TAB_Y - TAB_H - 2

local contentBg = cfgFrame:CreateTexture(nil, "BACKGROUND")
contentBg:SetTexture(W8)
contentBg:SetPoint("TOPLEFT",     cfgFrame, "TOPLEFT",  1, CONTENT_Y)
contentBg:SetPoint("BOTTOMRIGHT", cfgFrame, "BOTTOMRIGHT", -1, 1)
contentBg:SetVertexColor(E.BG2[1], E.BG2[2], E.BG2[3], 1)

-- ---- TAB CONTENT CONTAINERS -------------------------------------------

local function MakeTabFrame()
    local f = CreateFrame("Frame", nil, cfgFrame)
    f:SetPoint("TOPLEFT",     cfgFrame, "TOPLEFT",  2, CONTENT_Y - 2)
    f:SetPoint("BOTTOMRIGHT", cfgFrame, "BOTTOMRIGHT", -2, 2)
    f:Hide(); return f
end

for i = 1, #TAB_NAMES do
    tabContents[i] = MakeTabFrame()
end

-- ShowTab: fulfil forward-declaration; activates one tab content frame
-- and repaints all tab button states.
function ShowTab(idx)
    currentTab = idx
    for i, f in ipairs(tabContents) do
        if i == idx then f:Show() else f:Hide() end
    end
    for i, btn in ipairs(tabBtns) do
        if i == idx then
            btn._bg:SetVertexColor(0.12, 0.12, 0.12, 1)
            btn._bar:Show()
            btn._lbl:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
        else
            btn._bg:SetVertexColor(0.10, 0.10, 0.10, 1)
            btn._bar:Hide()
            btn._lbl:SetTextColor(0.50, 0.50, 0.50, 1)
        end
    end
end

-- ================================================================
-- TAB 1 -- GENERAL
-- ================================================================

local t1_container = tabContents[1]
local t1_scroll = CreateFrame("ScrollFrame", nil, t1_container)
t1_scroll:SetAllPoints(t1_container)
t1_scroll:EnableMouseWheel(true)
t1_scroll:SetScript("OnMouseWheel", function(self, delta)
    local cur = self:GetVerticalScroll()
    local maxVal = self:GetVerticalScrollRange()
    local newVal = math.max(0, math.min(maxVal, cur - delta * 30))
    self:SetVerticalScroll(newVal)
end)
local t1 = CreateFrame("Frame", nil, t1_scroll)
t1:SetWidth(CONFIG_W - 4)
t1_scroll:SetScrollChild(t1)
local ROW = -8

E.Header(t1, "Core Settings", 8, ROW);  ROW = ROW - 22

local cbEnabled      = E.Chk(t1, "Enable auto-marking",                                  8, ROW, "enabled",
    function()
        if AMA.RefreshDungeonCCAnnouncementQueue then
            AMA.RefreshDungeonCCAnnouncementQueue(0.5)
        end
    end)
ROW = ROW - 22
local cbAutoReset    = E.Chk(t1, "Refresh marks between pulls (preserve visible icons)", 8, ROW, "autoReset")
ROW = ROW - 22
local cbMinimapHide  = E.Chk(t1, "Hide minimap button",                                   8, ROW, "minimapHide",
    function()
        if AutoMarkAssistDB and AutoMarkAssistDB.minimapHide then
            AMA.minimapButton:Hide()
        else
            AMA.minimapButton:Show()
            AMA.UpdateMinimapPosition()
        end
    end)
ROW = ROW - 22
local cbVerbose      = E.Chk(t1, "Verbose debug output",                                 8, ROW, "verbose")
ROW = ROW - 26

E.Sep(t1, ROW);  ROW = ROW - 12

E.Header(t1, "Dynamic Marking", 8, ROW);  ROW = ROW - 22

cbDynamic = E.Chk(t1, "Dynamic marking (reassign as group composition changes)",   8, ROW, "dynamicMarking")
ROW = ROW - 22
cbCombatLock = E.Chk(t1, "Lock existing auto-marks while in combat",               8, ROW, "lockMarksInCombat")
ROW = ROW - 22
cbRebal   = E.Chk(t1, "Rebalance marks on death",                                  8, ROW, "rebalanceOnDeath")
ROW = ROW - 22
cbSkip    = E.Chk(t1, "Skip filler / trash mobs (LOW priority)",                   8, ROW, "skipFillerMobs")
ROW = ROW - 22
cbCrit    = E.Chk(t1, "Skip critter-type creatures",                               8, ROW, "skipCritters")
ROW = ROW - 24

ccLimitBtns = {}
local ccLimitLabel = E.Label(t1, "CC Limit:", 28, ROW)
local prevCCBtn
for ci, cdata in ipairs({ {0,"No Limit"}, {1,"1"}, {2,"2"}, {3,"3"} }) do
    local cVal, cText = cdata[1], cdata[2]
    local cb = E.Btn(t1, cText, (cVal == 0) and 72 or 36, 20)
    if prevCCBtn then
        cb:SetPoint("LEFT", prevCCBtn, "RIGHT", 4, 0)
    else
        cb:SetPoint("LEFT", ccLimitLabel, "RIGHT", 12, 0)
    end
    cb:SetScript("OnClick", function()
        if AutoMarkAssistDB then
            AutoMarkAssistDB.ccLimit = cVal
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end
    end)
    ccLimitBtns[cVal] = cb
    prevCCBtn = cb
end
ROW = ROW - 26

cbSmartDungeonCC = E.Chk(
    t1,
    "In dungeons, adapt CC marks to group composition and mob type",
    8,
    ROW,
    "smartDungeonCC",
    function()
        if AMA.RefreshDungeonCCAnnouncementQueue then
            AMA.RefreshDungeonCCAnnouncementQueue(0.5)
        end
    end)
ROW = ROW - 24

cbAutoDungeonCC = E.Chk(
    t1,
    "Auto-announce party CC on dungeon entry and roster updates",
    28,
    ROW,
    "autoAnnounceDungeonCC",
    function()
        if AMA.RefreshDungeonCCAnnouncementQueue then
            AMA.RefreshDungeonCCAnnouncementQueue(0.5)
        end
    end)
ROW = ROW - 24

repeatDungeonCCBtn = E.Btn(t1, "Repeat Party CC", 104, 18)
repeatDungeonCCBtn:SetPoint("TOPLEFT", t1, "TOPLEFT", 28, ROW + 2)
repeatDungeonCCBtn:SetScript("OnClick", function()
    if AMA.AnnounceDungeonSmartCCAssignments then
        AMA.AnnounceDungeonSmartCCAssignments({ showFeedback = true })
    end
end)
repeatDungeonCCBtn:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Repeat the current dungeon Smart CC assignments in party chat.")
    GameTooltip:Show()
end)
repeatDungeonCCBtn:HookScript("OnLeave", function()
    GameTooltip:Hide()
end)

local smartCCHelpBtn = E.Btn(t1, "How It Works", 100, 18)
smartCCHelpBtn:SetPoint("LEFT", repeatDungeonCCBtn, "RIGHT", 12, 0)
smartCCHelpBtn:SetScript("OnClick", ShowSmartCCHelp)
smartCCHelpBtn:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Open a short explanation of the group-aware dungeon CC option.")
    GameTooltip:Show()
end)
smartCCHelpBtn:HookScript("OnLeave", function()
    GameTooltip:Hide()
end)
ROW = ROW - 28

local smartCCNote = t1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
smartCCNote:SetPoint("TOPLEFT", t1, "TOPLEFT", 28, ROW + 2)
smartCCNote:SetWidth(470)
smartCCNote:SetJustifyH("LEFT")
smartCCNote:SetText("Only applies inside 5-player dungeons. Unsupported or exhausted CC targets fall back to kill-order marks. Turn off the automatic party reminder here if you only want manual /ama ccannounce or Repeat Party CC posts.")
smartCCNote:SetTextColor(0.70, 0.70, 0.70, 1)
ROW = ROW - math.max(40,
    math.ceil((smartCCNote.GetStringHeight and smartCCNote:GetStringHeight()) or 0)) - 10

E.Sep(t1, ROW);  ROW = ROW - 12

E.Header(t1, "Proximity Marking", 8, ROW);  ROW = ROW - 22

cbProx = E.Chk(t1, "Mark enemies within proximity range", 8, ROW, "proximityMode",
    function()
        if AutoMarkAssistDB and AutoMarkAssistDB.proximityMode
        and AMA.SetAutoMarkMode then
            AMA.SetAutoMarkMode("proximity", true)
        end
    end)
ROW = ROW - 24

proxBtns = {}
local rangeLabel = E.Label(t1, "Range:", 28, ROW)
local prevRangeBtn
for ri, rdata in ipairs({ {2,"~11 yd"}, {3,"~10 yd"}, {4,"~28 yd"} }) do
    local rIdx, rText = rdata[1], rdata[2]
    local rb = E.Btn(t1, rText, 68, 20)
    if prevRangeBtn then
        rb:SetPoint("LEFT", prevRangeBtn, "RIGHT", 4, 0)
    else
        rb:SetPoint("LEFT", rangeLabel, "RIGHT", 12, 0)
    end
    rb:SetID(rIdx)
    rb:SetScript("OnClick", function(self)
        if AutoMarkAssistDB then
            AutoMarkAssistDB.proximityRange = self:GetID()
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end
    end)
    proxBtns[rIdx] = rb
    prevRangeBtn = rb
end
ROW = ROW - 26

E.Sep(t1, ROW);  ROW = ROW - 12

E.Header(t1, "Mouseover Marking", 8, ROW);  ROW = ROW - 22

cbMouseover = E.Chk(t1, "Mark enemies on mouseover", 8, ROW, "mouseoverMode",
    function()
        if AutoMarkAssistDB and AutoMarkAssistDB.mouseoverMode
        and AMA.SetAutoMarkMode then
            AMA.SetAutoMarkMode("mouseover", true)
        end
    end)
ROW = ROW - 24

cbMoRange = E.Chk(t1, "Limit mouseover marking to a maximum range", 8, ROW, "mouseoverRangeEnabled")
ROW = ROW - 24

moRangeBtns = {}
local moRangeLabel = E.Label(t1, "Range:", 28, ROW)
local prevMoBtn
for ri, rdata in ipairs({ {2,"~11 yd"}, {3,"~10 yd"}, {4,"~28 yd"} }) do
    local rIdx, rText = rdata[1], rdata[2]
    local rb = E.Btn(t1, rText, 68, 20)
    if prevMoBtn then
        rb:SetPoint("LEFT", prevMoBtn, "RIGHT", 4, 0)
    else
        rb:SetPoint("LEFT", moRangeLabel, "RIGHT", 12, 0)
    end
    rb:SetID(rIdx)
    rb:SetScript("OnClick", function(self)
        if AutoMarkAssistDB then
            AutoMarkAssistDB.mouseoverRange = self:GetID()
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end
    end)
    moRangeBtns[rIdx] = rb
    prevMoBtn = rb
end
ROW = ROW - 26

local autoModeNote = t1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
autoModeNote:SetPoint("TOPLEFT", t1, "TOPLEFT", 28, ROW + 2)
autoModeNote:SetWidth(470)
autoModeNote:SetJustifyH("LEFT")
autoModeNote:SetText("Choose one automatic scan mode at a time: enabling proximity turns off mouseover, and enabling mouseover turns off proximity. Manual Mode pauses automatic scanning without clearing your saved preference.")
autoModeNote:SetTextColor(0.70, 0.70, 0.70, 1)
ROW = ROW - math.max(32,
    math.ceil((autoModeNote.GetStringHeight and autoModeNote:GetStringHeight()) or 0)) - 8

E.Sep(t1, ROW);  ROW = ROW - 12

E.Header(t1, "Manual Mode", 8, ROW);  ROW = ROW - 22

local cbManual = E.Chk(t1, "Manual mode (scroll wheel to assign marks)", 8, ROW, "manualMode",
    function()
        if AMA.RefreshDungeonCCAnnouncementQueue then
            AMA.RefreshDungeonCCAnnouncementQueue(0.5)
        end
    end)
ROW = ROW - 24

local manualSaveNote = t1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
manualSaveNote:SetPoint("TOPLEFT", t1, "TOPLEFT", 28, ROW)
manualSaveNote:SetWidth(330)
manualSaveNote:SetJustifyH("LEFT")
manualSaveNote:SetText("Scroll to choose. Close the picker to apply. Saved per zone for auto mode.")
manualSaveNote:SetTextColor(0.70, 0.70, 0.70, 1)

local manualSaveHelpBtn = E.Btn(t1, "How It Saves", 100, 18)
manualSaveHelpBtn:SetPoint("TOPLEFT", t1, "TOPLEFT", 392, ROW + 2)
manualSaveHelpBtn:SetScript("OnClick", ShowManualSaveHelp)
manualSaveHelpBtn:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Open a short explanation of how manual marks are saved for later auto-marking.")
    GameTooltip:Show()
end)
manualSaveHelpBtn:HookScript("OnLeave", function()
    GameTooltip:Hide()
end)
ROW = ROW - 24

local modLabel = E.Label(t1, "Modifier:", 28, ROW)
modBtns = {}
local prevModBtn
for mi, mod in ipairs({ "ALT", "SHIFT", "CTRL" }) do
    local mb = E.Btn(t1, mod, 58, 20)
    if prevModBtn then
        mb:SetPoint("LEFT", prevModBtn, "RIGHT", 4, 0)
    else
        mb:SetPoint("LEFT", modLabel, "RIGHT", 12, 0)
    end
    mb:SetScript("OnClick", function()
        if AutoMarkAssistDB then
            AutoMarkAssistDB.manualModifier = mod
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end
    end)
    modBtns[mod] = mb
    prevModBtn = mb
end
ROW = ROW - 26

local scrollOrderLabel = E.Label(t1, "Scroll Order:", 28, ROW)
local scrollOrderHint = t1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
scrollOrderHint:SetPoint("LEFT", scrollOrderLabel, "RIGHT", 8, 0)
scrollOrderHint:SetText("|cFF888888(drag to reorder)|r")
ROW = ROW - 18

do  -- Scroll Order reorder widget scope
    local SO_CELL = 34   -- icon cell size (px)
    local SO_GAP  = 4    -- gap between cells
    local SO_PAD  = 28   -- left padding to align with modifier row

    local dragSrcSlot = nil

    -- Ghost frame: semi-transparent icon that follows the cursor during drag.
    local dragGhost = CreateFrame("Frame", nil, UIParent)
    dragGhost:SetSize(SO_CELL, SO_CELL)
    dragGhost:SetFrameStrata("TOOLTIP")
    dragGhost:SetFrameLevel(300)
    dragGhost:Hide()
    local ghostIcon = dragGhost:CreateTexture(nil, "ARTWORK")
    ghostIcon:SetSize(SO_CELL - 4, SO_CELL - 4)
    ghostIcon:SetPoint("CENTER")
    ghostIcon:SetAlpha(0.70)
    dragGhost._icon = ghostIcon

    scrollOrderCells = {}

    local lastCell
    for slot = 1, 8 do
        local cell = CreateFrame("Button", nil, t1,
            BackdropTemplateMixin and "BackdropTemplate" or nil)
        cell:SetSize(SO_CELL, SO_CELL)
        if lastCell then
            cell:SetPoint("LEFT", lastCell, "RIGHT", SO_GAP, 0)
        else
            cell:SetPoint("TOPLEFT", t1, "TOPLEFT", SO_PAD, ROW)
        end
        cell:RegisterForDrag("LeftButton")
        cell:EnableMouse(true)

        if cell.SetBackdrop then
            cell:SetBackdrop(FLAT_BD)
            cell:SetBackdropColor(E.BG2[1], E.BG2[2], E.BG2[3], 1)
            cell:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
        end

        local icon = cell:CreateTexture(nil, "ARTWORK")
        icon:SetSize(SO_CELL - 6, SO_CELL - 6)
        icon:SetPoint("CENTER")
        cell._icon = icon
        cell._slot = slot

        -- Drag start: record source slot, show ghost, dim source icon.
        cell:SetScript("OnDragStart", function(self)
            dragSrcSlot = self._slot
            local order = AMA.GetManualScrollOrder and AMA.GetManualScrollOrder()
                          or {8, 7, 3, 4, 5, 6, 2, 1}
            local markIdx = order[dragSrcSlot]
            if markIdx then
                dragGhost._icon:SetTexture(
                    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. markIdx)
            end
            dragGhost:Show()
            self._icon:SetAlpha(0.25)
            -- Track cursor position via OnUpdate on the ghost frame.
            dragGhost:SetScript("OnUpdate", function(g)
                local cx, cy = GetCursorPosition()
                local scale  = UIParent:GetEffectiveScale()
                g:ClearAllPoints()
                g:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
                    cx / scale, cy / scale)
            end)
        end)

        -- Drag stop: calculate destination slot from cursor x, reorder array.
        cell:SetScript("OnDragStop", function(self)
            if not dragSrcSlot then return end
            dragGhost:Hide()
            dragGhost:SetScript("OnUpdate", nil)
            self._icon:SetAlpha(1.0)
            -- Determine drop slot from cursor x relative to the cell row.
            local firstCell = scrollOrderCells and scrollOrderCells[1]
            local rowLeft = firstCell and firstCell:GetLeft()
            local rowScale = (firstCell and firstCell:GetEffectiveScale())
                or UIParent:GetEffectiveScale()
            if rowLeft and AutoMarkAssistDB then
                local cx = GetCursorPosition()
                cx = cx / rowScale
                local relX  = cx - rowLeft
                local dstSlot = math.floor(relX / (SO_CELL + SO_GAP)) + 1
                dstSlot = math.max(1, math.min(8, dstSlot))
                if dstSlot ~= dragSrcSlot then
                    local order = AMA.GetManualScrollOrder and AMA.GetManualScrollOrder()
                                  or {8, 7, 3, 4, 5, 6, 2, 1}
                    -- Remove mark from source and insert at destination.
                    local mark = table.remove(order, dragSrcSlot)
                    table.insert(order, dstSlot, mark)
                    AutoMarkAssistDB.manualScrollOrder = order
                    AMA.VPrint("Scroll order updated.")
                end
            end
            dragSrcSlot = nil
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end)

        -- Tooltip and drag-target highlight.
        cell:SetScript("OnEnter", function(self)
            if dragSrcSlot and self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(
                    E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
            end
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            local order = AMA.GetManualScrollOrder and AMA.GetManualScrollOrder()
                          or {8, 7, 3, 4, 5, 6, 2, 1}
            local markIdx = order[self._slot]
            local name = markIdx and (AMA.MARK_NAMES[markIdx] or "?") or "?"
            GameTooltip:SetText(name .. "  |cFF888888(#" .. self._slot .. ")|r")
            GameTooltip:Show()
        end)

        cell:SetScript("OnLeave", function(self)
            if self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(
                    E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
            end
            GameTooltip:Hide()
        end)

        scrollOrderCells[slot] = cell
        lastCell = cell
    end

    -- Reset Order button: restores the default scroll sequence.
    local resetOrderBtn = E.Btn(t1, "Reset Order", 82, 20)
    resetOrderBtn:SetPoint("LEFT", lastCell, "RIGHT", 8, 0)
    resetOrderBtn:SetScript("OnClick", function()
        if AutoMarkAssistDB then
            AutoMarkAssistDB.manualScrollOrder = AMA.GetDefaultManualScrollOrder
                and AMA.GetDefaultManualScrollOrder()
                or {8, 7, 3, 4, 5, 6, 2, 1}
            AMA.Print("Scroll order reset to default.")
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end
    end)

    local directionLabel = E.Label(t1, "Wheel Direction:", 28, ROW - 42)

    invertScrollBtn = E.Btn(t1, "", 188, 20)
    invertScrollBtn:SetPoint("LEFT", directionLabel, "RIGHT", 8, 0)
    invertScrollBtn:SetScript("OnClick", function()
        if AutoMarkAssistDB then
            AutoMarkAssistDB.invertScroll = not AutoMarkAssistDB.invertScroll
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end
    end)
    invertScrollBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(
            "Choose whether scroll up or scroll down starts at the left-most icon in the manual scroll order.")
        GameTooltip:Show()
    end)
    invertScrollBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end  -- Scroll Order reorder widget scope
ROW = ROW - 90

E.Sep(t1, ROW);  ROW = ROW - 12

E.Header(t1, "Reset Marks Keybind", 8, ROW);  ROW = ROW - 22

E.Label(t1, "Press the button then press a key/mouse button to bind.", 28, ROW)
ROW = ROW - 20

do  -- Reset keybind picker scope
    local FRIENDLY_NAMES = {
        BUTTON3 = "Middle Mouse", BUTTON4 = "Mouse 4", BUTTON5 = "Mouse 5",
    }
    local function FriendlyKey(k)
        if not k or k == "" then return "(none)" end
        return FRIENDLY_NAMES[k] or k
    end

    local bindBtn = E.Btn(t1, "", 140, 22)
    bindBtn:SetPoint("TOPLEFT", t1, "TOPLEFT", 28, ROW + 2)
    resetKeyBtn = bindBtn

    local waiting = false

    local function StopListening()
        waiting = false
        bindBtn:EnableKeyboard(false)
        bindBtn:SetScript("OnKeyDown", nil)
        bindBtn:SetScript("OnMouseDown", nil)
        local key = AutoMarkAssistDB and AutoMarkAssistDB.resetMarksKey or "BUTTON3"
        bindBtn:SetText(FriendlyKey(key))
    end

    local function ApplyKey(key)
        if AutoMarkAssistDB then
            AutoMarkAssistDB.resetMarksKey = key
        end
        if AMA.ApplyResetKeybind then AMA.ApplyResetKeybind() end
        StopListening()
    end

    bindBtn:SetScript("OnClick", function(self, btn)
        if waiting then
            -- This click IS the binding (mouse buttons arrive here as OnClick)
            if btn == "LeftButton" then btn = "BUTTON1" end
            if btn == "RightButton" then btn = "BUTTON2" end
            if btn == "MiddleButton" then btn = "BUTTON3" end
            ApplyKey(btn)
            return
        end
        -- Enter listening mode.
        waiting = true
        self:SetText("|cFFFFFF00Press a key...|r")
        self:EnableKeyboard(true)
        self:SetScript("OnKeyDown", function(_, k)
            if k == "ESCAPE" then StopListening(); return end
            ApplyKey(k)
        end)
        self:SetScript("OnMouseDown", function(_, mb)
            if mb == "LeftButton" then mb = "BUTTON1" end
            if mb == "RightButton" then mb = "BUTTON2" end
            if mb == "MiddleButton" then mb = "BUTTON3" end
            ApplyKey(mb)
        end)
    end)

    local clearKeyBtn = E.Btn(t1, "Unbind", 58, 22)
    clearKeyBtn:SetPoint("LEFT", bindBtn, "RIGHT", 6, 0)
    clearKeyBtn:SetScript("OnClick", function()
        if AutoMarkAssistDB then
            AutoMarkAssistDB.resetMarksKey = ""
        end
        if AMA.ApplyResetKeybind then AMA.ApplyResetKeybind() end
        StopListening()
    end)
end  -- Reset keybind picker scope
ROW = ROW - 30

E.Sep(t1, ROW);  ROW = ROW - 12

E.Header(t1, "Announce Channel", 8, ROW);  ROW = ROW - 22

announceChannelBtns = {}
local prevAnnounceBtn
for ai, ch in ipairs({ "SAY", "PARTY", "RAID" }) do
    local ab = E.Btn(t1, ch, 62, 20)
    if prevAnnounceBtn then
        ab:SetPoint("LEFT", prevAnnounceBtn, "RIGHT", 4, 0)
    else
        ab:SetPoint("TOPLEFT", t1, "TOPLEFT", 8, ROW + 3)
    end
    ab:SetScript("OnClick", function()
        if AutoMarkAssistDB then
            AutoMarkAssistDB.announceChannel = ch
            if AutoMarkAssist_ResetPreviewWarning then AutoMarkAssist_ResetPreviewWarning() end
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end
    end)
    announceChannelBtns[ch] = ab
    prevAnnounceBtn = ab
end
ROW = ROW - 28

local formatLabel = E.Label(t1, "Format:", 8, ROW)
announceFormatBtns = {}
local prevFormatBtn
for _, formatData in ipairs({
    { key = true,  label = "Line by Line", width = 96 },
    { key = false, label = "Single Line", width = 92 },
}) do
    local formatKey = formatData.key
    local formatBtn = E.Btn(t1, formatData.label, formatData.width, 20)
    if prevFormatBtn then
        formatBtn:SetPoint("LEFT", prevFormatBtn, "RIGHT", 4, 0)
    else
        formatBtn:SetPoint("LEFT", formatLabel, "RIGHT", 12, 0)
    end
    formatBtn:SetScript("OnClick", function()
        if AutoMarkAssistDB then
            AutoMarkAssistDB.announceLineByLine = formatKey
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end
    end)
    announceFormatBtns[formatKey] = formatBtn
    prevFormatBtn = formatBtn
end
ROW = ROW - 28

local prefixLabel = E.Label(t1, "Chat Prefix:", 8, ROW)
announcePrefixEdit = E.EditBox(t1, 132, 20)
announcePrefixEdit:SetPoint("LEFT", prefixLabel, "RIGHT", 12, 0)
announcePrefixEdit:SetMaxLetters(24)
announcePrefixEdit:SetScript("OnTextChanged", function(self, userInput)
    if userInput and AutoMarkAssistDB then
        AutoMarkAssistDB.announcePrefixText = self:GetText() or ""
    end
end)
announcePrefixEdit:SetScript("OnEnterPressed", function(self)
    if AutoMarkAssistDB then
        AutoMarkAssistDB.announcePrefixText = self:GetText() or ""
        if AMA.GetAnnouncementPrefixText then
            self:SetText(AMA.GetAnnouncementPrefixText())
        end
    end
    self:ClearFocus()
end)
announcePrefixEdit:HookScript("OnEditFocusLost", function(self)
    if AutoMarkAssistDB then
        AutoMarkAssistDB.announcePrefixText = self:GetText() or ""
        if AMA.GetAnnouncementPrefixText then
            self:SetText(AMA.GetAnnouncementPrefixText())
        end
    end
end)

local prefixNote = t1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
prefixNote:SetPoint("LEFT", announcePrefixEdit, "RIGHT", 8, 0)
prefixNote:SetWidth(214)
prefixNote:SetJustifyH("LEFT")
prefixNote:SetText("Blank removes the [AutoMarkAssist] prefix.")
prefixNote:SetTextColor(0.70, 0.70, 0.70, 1)
ROW = ROW - 28

local announceNowBtn = E.Btn(t1, "Announce Now", 120, 22)
announceNowBtn:SetPoint("TOPLEFT", t1, "TOPLEFT", 8, ROW + 2)
announceNowBtn:SetScript("OnClick", function()
    if AutoMarkAssist_Announce then AutoMarkAssist_Announce() end
end)

local previewBtn = E.Btn(t1, "Preview", 100, 22)
previewBtn:SetPoint("LEFT", announceNowBtn, "RIGHT", 6, 0)
previewBtn:SetScript("OnClick", function()
    if AutoMarkAssist_Preview then AutoMarkAssist_Preview() end
end)
ROW = ROW - 30

E.Sep(t1, ROW);  ROW = ROW - 14

local resetBtn = E.Btn(t1, "Reset Addon Settings to Defaults", 220, 22)
resetBtn:SetPoint("TOPLEFT", t1, "TOPLEFT", 8, ROW + 2)
resetBtn:SetScript("OnClick", function()
    if not AutoMarkAssistDB then return end
    if AMA.ResetSettingsToDefaults then
        AMA.ResetSettingsToDefaults()
    end
    if AMA.ResetState then AMA.ResetState() end
    AMA.Print("All settings reset to defaults.")
    if AMA.minimapButton then AMA.minimapButton:Show(); AMA.UpdateMinimapPosition() end
    if AMA.ApplyResetKeybind then AMA.ApplyResetKeybind() end
    if AMA.UpdateMinimapState then AMA.UpdateMinimapState() end
    if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
    if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
end)

resetBtn:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Reset the saved addon settings, mark pools, legends, Smart Dungeon CC role marks, manual scroll order, and Database-tab customizations back to the shipped defaults.")
    GameTooltip:Show()
end)
resetBtn:HookScript("OnLeave", function()
    GameTooltip:Hide()
end)

local resetNote = t1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
resetNote:SetPoint("TOPLEFT", resetBtn, "BOTTOMLEFT", 20, -8)
resetNote:SetWidth(486)
resetNote:SetJustifyH("LEFT")
resetNote:SetText("Restores shipped defaults for addon settings, pools, legends, Smart Dungeon CC role marks, manual scroll order, and Database-tab overrides.")
resetNote:SetTextColor(0.70, 0.70, 0.70, 1)
ROW = ROW - 22 - 8 - math.max(24,
    math.ceil((resetNote.GetStringHeight and resetNote:GetStringHeight()) or 0)) - 28

-- Set scroll child height so the ScrollFrame knows the content extent.
t1:SetHeight(-ROW + 68)

-- ================================================================
-- TAB 2 -- MARK POOLS
-- ================================================================

local t2 = tabContents[2]
poolBtnsMap = {}

E.Label(t2, "Click a mark icon to assign it to a priority tier.", 8, -10)
E.Label(t2, "Each mark can belong to one tier at most. Click again to remove.", 8, -24)

local function GetDefaultPools()
    if AMA.GetDefaultMarkPools then
        return AMA.GetDefaultMarkPools()
    end
    return {
        HIGH   = { 8, 7       },
        CC     = { 6, 5, 3    },
        MEDIUM = { 4, 2       },
        LOW    = { 1          },
    }
end

-- Tier colours for "owned by another tier" border tints
local TIER_COL = {}
for _, td in ipairs(TIER_DEFS) do TIER_COL[td.key] = { td.r, td.g, td.b } end

-- Helper: find which tier (if any) owns a mark
local function FindMarkTier(mi)
    if not AutoMarkAssistDB or not AutoMarkAssistDB.markPools then return nil end
    for _, td in ipairs(TIER_DEFS) do
        for _, v in ipairs(AutoMarkAssistDB.markPools[td.key] or {}) do
            if v == mi then return td.key, td.label end
        end
    end
    return nil
end

for ti, tdef in ipairs(TIER_DEFS) do
    local rowY = -42 - (ti - 1) * 72

    local lbl = t2:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", t2, "TOPLEFT", 8, rowY)
    lbl:SetText(tdef.label); lbl:SetTextColor(tdef.r, tdef.g, tdef.b, 1)

    poolBtnsMap[tdef.key] = {}

    for mi = 1, 8 do
        -- Flat backdrop cell (visual only, not interactive)
        local cell = CreateFrame("Frame", nil, t2,
            BackdropTemplateMixin and "BackdropTemplate" or nil)
        cell:SetSize(34, 34)
        cell:SetPoint("TOPLEFT", t2, "TOPLEFT", 8 + (8 - mi) * 42, rowY - 16)
        if cell.SetBackdrop then
            cell:SetBackdrop(FLAT_BD)
            cell:SetBackdropColor(E.BG2[1], E.BG2[2], E.BG2[3], 1)
            cell:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
        end

        local ic = cell:CreateTexture(nil, "ARTWORK")
        ic:SetSize(26, 26); ic:SetPoint("CENTER", cell, "CENTER")
        ic:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. mi)
        ic:SetAlpha(0.25)

        -- Teal active tint overlay
        local hl = cell:CreateTexture(nil, "OVERLAY")
        hl:SetTexture(W8); hl:SetAllPoints()
        hl:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 0.18); hl:Hide()

        -- Transparent Button for click/tooltip (sits above the cell)
        local btn = CreateFrame("Button", nil, t2)
        btn:SetAllPoints(cell); btn:SetFrameLevel(cell:GetFrameLevel() + 1)
        btn.markIdx   = mi;  btn.priority = tdef.key
        btn.icon      = ic;  btn.highlight = hl; btn._cell = cell

        btn:SetScript("OnClick", function(self)
            if not AutoMarkAssistDB then return end
            local pools = AutoMarkAssistDB.markPools or GetDefaultPools()
            -- Check if mark belongs to another tier
            local owner = FindMarkTier(self.markIdx)
            if owner and owner ~= self.priority then return end
            -- Toggle in this tier
            local pool  = pools[self.priority] or {}
            local found = false
            for i, v in ipairs(pool) do
                if v == self.markIdx then
                    table.remove(pool, i); found = true; break
                end
            end
            if not found then
                pool[#pool + 1] = self.markIdx
                table.sort(pool, function(a, b) return a > b end)
            end
            pools[self.priority]       = pool
            AutoMarkAssistDB.markPools = pools
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local name = AMA.MARK_NAMES[self.markIdx] or "?"
            local owner, ownerLabel = FindMarkTier(self.markIdx)
            if owner and owner ~= self.priority then
                GameTooltip:SetText(name .. "  |cFFAAAAAA(assigned to " .. ownerLabel .. ")|r")
            else
                GameTooltip:SetText(name)
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        poolBtnsMap[tdef.key][mi] = btn
    end

    local clearBtn = E.Btn(t2, "Clear", 52, 20)
    clearBtn:SetPoint("TOPLEFT", t2, "TOPLEFT", 365, rowY - 16)
    local tkey = tdef.key
    clearBtn:SetScript("OnClick", function()
        if not AutoMarkAssistDB then return end
        AutoMarkAssistDB.markPools       = AutoMarkAssistDB.markPools or GetDefaultPools()
        AutoMarkAssistDB.markPools[tkey] = {}
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
    end)
end

-- ── Presets ──
E.Sep(t2, -330)
E.Label(t2, "|cFF1A9EC0Presets|r", 8, -342)

local POOL_PRESETS = {
    { label = "Default",   pools = { HIGH = {8,7}, CC = {6,5,3}, MEDIUM = {4,2}, LOW = {1} } },
    { label = "Kill Only", pools = { HIGH = {8,7}, CC = {},       MEDIUM = {},    LOW = {} } },
    { label = "No CC",     pools = { HIGH = {8,7}, CC = {},       MEDIUM = {4,2}, LOW = {1} } },
    { label = "Clear All", pools = { HIGH = {},    CC = {},       MEDIUM = {},    LOW = {} } },
}

for pi, preset in ipairs(POOL_PRESETS) do
    local btn = E.Btn(t2, preset.label, 100, 22)
    btn:SetPoint("TOPLEFT", t2, "TOPLEFT", 8 + (pi - 1) * 110, -358)
    btn:SetScript("OnClick", function()
        if not AutoMarkAssistDB then return end
        local pools = {}
        for k, v in pairs(preset.pools) do
            pools[k] = {}
            for i, mi in ipairs(v) do pools[k][i] = mi end
        end
        AutoMarkAssistDB.markPools = pools
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
    end)
end

-- ================================================================
-- TAB 3 -- MARK LEGEND
-- ================================================================

local t3 = tabContents[3]
legendBoxes = {}

E.Label(t3, "Set the description for each mark icon (shown in pull announcements).", 8, -10)
E.Label(t3, "These text labels affect previews and announcements only.", 8, -24)

for row, mi in ipairs(AMA.ALL_MARKS_ORDERED) do
    local yOff = -44 - (row - 1) * 30

    local ic = t3:CreateTexture(nil, "ARTWORK")
    ic:SetSize(22, 22)
    ic:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. mi)
    ic:SetPoint("TOPLEFT", t3, "TOPLEFT", 10, yOff)

    local nm = t3:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nm:SetPoint("TOPLEFT", t3, "TOPLEFT", 36, yOff - 3)
    nm:SetText(AMA.MARK_NAMES[mi]); nm:SetWidth(55); nm:SetJustifyH("LEFT")

    local eb = E.EditBox(t3, 336, 20)
    eb:SetPoint("TOPLEFT", t3, "TOPLEFT", 96, yOff - 1)
    eb:SetMaxLetters(80); eb.markIdx = mi
    local function PersistLegendText(self)
        if AutoMarkAssistDB then
            AutoMarkAssistDB.markLegend = AutoMarkAssistDB.markLegend or {}
            AutoMarkAssistDB.markLegend[self.markIdx] = self:GetText() or ""
        end
    end
    eb:SetScript("OnTextChanged", function(self)
        PersistLegendText(self)
    end)
    eb:SetScript("OnEnterPressed", function(self)
        PersistLegendText(self)
        self:ClearFocus()
    end)
    eb:HookScript("OnEditFocusLost", function(self)
        PersistLegendText(self)
    end)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    legendBoxes[mi] = eb
end

-- Preview Legend button -- sends the legend via the user's configured announce channel
local legendPreviewBtn = E.Btn(t3, "Preview Legend in Chat", 190, 22)
legendPreviewBtn:SetPoint("TOPLEFT", t3, "TOPLEFT", 8, -296)
legendPreviewBtn:SetScript("OnClick", function()
    AutoMarkAssist_Preview()
end)

E.Sep(t3, -330)
E.Label(t3, "|cFF1A9EC0Smart Dungeon CC Preferred Marks|r", 8, -342)

local smartCCRoleNote = E.Label(
    t3,
    "Choose the preferred icon for each CC type. Smart Dungeon CC will try that icon first when it is part of the active CC pool.",
    8,
    -358)
smartCCRoleNote:SetWidth(500)
smartCCRoleNote:SetJustifyH("LEFT")

smartCCRoleMarkBtns = {}

for row, roleDef in ipairs(AMA.DUNGEON_SMART_CC_ROLE_DEFS or {}) do
    local rowY = -398 - (row - 1) * 28

    local lbl = t3:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", t3, "TOPLEFT", 8, rowY)
    lbl:SetWidth(78)
    lbl:SetJustifyH("LEFT")
    lbl:SetText(roleDef.label)

    smartCCRoleMarkBtns[roleDef.classTag] = {}

    for col, mi in ipairs(AMA.ALL_MARKS_ORDERED) do
        local cell = CreateFrame("Frame", nil, t3,
            BackdropTemplateMixin and "BackdropTemplate" or nil)
        cell:SetSize(26, 26)
        cell:SetPoint("TOPLEFT", t3, "TOPLEFT", 92 + (col - 1) * 32, rowY + 4)
        if cell.SetBackdrop then
            cell:SetBackdrop(FLAT_BD)
            cell:SetBackdropColor(E.BG2[1], E.BG2[2], E.BG2[3], 1)
            cell:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
        end

        local ic = cell:CreateTexture(nil, "ARTWORK")
        ic:SetSize(20, 20)
        ic:SetPoint("CENTER", cell, "CENTER")
        ic:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. mi)
        ic:SetAlpha(0.30)

        local hl = cell:CreateTexture(nil, "OVERLAY")
        hl:SetTexture(W8)
        hl:SetAllPoints()
        hl:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 0.18)
        hl:Hide()

        local btn = CreateFrame("Button", nil, t3)
        btn:SetAllPoints(cell)
        btn:SetFrameLevel(cell:GetFrameLevel() + 1)
        btn.classTag = roleDef.classTag
        btn.markIdx = mi
        btn.icon = ic
        btn.highlight = hl
        btn._cell = cell
        btn.ccLabel = roleDef.label

        btn:SetScript("OnClick", function(self)
            if not AutoMarkAssistDB then return end
            AutoMarkAssistDB.smartCCRoleMarks =
                (AMA.GetSmartCCRoleMarks and AMA.GetSmartCCRoleMarks()) or {}
            AutoMarkAssistDB.smartCCRoleMarks[self.classTag] = self.markIdx
            if AMA.NormalizeSmartCCRoleMarks then
                AutoMarkAssistDB.smartCCRoleMarks =
                    AMA.NormalizeSmartCCRoleMarks(AutoMarkAssistDB.smartCCRoleMarks)
            end
            if AMA.RefreshDungeonCCAnnouncementQueue then
                AMA.RefreshDungeonCCAnnouncementQueue(0.5)
            end
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(string.format(
                "%s prefers %s",
                self.ccLabel or "CC",
                AMA.MARK_NAMES[self.markIdx] or tostring(self.markIdx)))
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        smartCCRoleMarkBtns[roleDef.classTag][mi] = btn
    end
end

local smartCCRoleResetBtn = E.Btn(t3, "Reset CC Role Marks", 138, 22)
smartCCRoleResetBtn:SetPoint("TOPLEFT", t3, "TOPLEFT", 8, -572)
smartCCRoleResetBtn:SetScript("OnClick", function()
    if not AutoMarkAssistDB then return end
    AutoMarkAssistDB.smartCCRoleMarks =
        (AMA.GetDefaultSmartCCRoleMarks and AMA.GetDefaultSmartCCRoleMarks()) or nil
    if AMA.RefreshDungeonCCAnnouncementQueue then
        AMA.RefreshDungeonCCAnnouncementQueue(0.5)
    end
    if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
end)

-- ================================================================
-- TAB 4 -- DATABASE
-- Embedded mob explorer with click-to-cycle priority editing.
-- Left panel  : scrollable dungeon zone list; click to select.
--               "Reset Zone to Defaults" button below zone list.
-- Right panel : scrollable mob list with pre-allocated row buttons.
--               Left-click  a mob row to cycle its effective priority.
--               Right-click a mob row to reset it to the DB default.
--               x button removes explicit overrides or user-added mobs.
-- Bottom bar  : Add-mob form (name input + priority selector + Add btn).
-- ================================================================
do  -- Database tab construction scope

local t5          = tabContents[4]
local DB_LEFT_W   = 150   -- zone list panel width (includes scrollbar)
local DB_RIGHT_W  = CONFIG_W - DB_LEFT_W - 12
local MOB_CHILD_W = DB_RIGHT_W
local ROW_H       = 18    -- height of each mob row
local TOOLBAR_H   = 74    -- height of the add-mob toolbar at the bottom
local PRI_COL_W   = 66
local SUB_COL_X   = 74
local SUB_COL_W   = 24
local NAME_COL_X  = 104
local DELETE_BTN_W = 22
local UI_MAX_SUB_PRIORITY = 9

-- Priority colour table {r, g, b}
local PRI_COL = {
    BOSS    = {1.00, 0.25, 0.25},
    HIGH    = {1.00, 0.60, 0.00},
    CC      = {0.00, 0.90, 0.90},
    MEDIUM  = {0.90, 0.90, 0.20},
    LOW     = {0.50, 0.90, 0.50},
    SKIP    = {0.40, 0.40, 0.40},
    REMOVED = {0.30, 0.30, 0.30},
}
local PRI_RANK = { BOSS=0, HIGH=1, CC=2, MEDIUM=3, LOW=4, SKIP=5, REMOVED=6 }
-- Cycle order: BOSS -> HIGH -> CC -> MEDIUM -> LOW -> SKIP -> REMOVED -> reset
local CYCLE = { "BOSS", "HIGH", "CC", "MEDIUM", "LOW", "SKIP", "REMOVED" }

local function NormalizeUISubPriority(raw)
    local n = tonumber(raw)
    if not n then return nil end
    n = math.floor(n)
    if n < 1 then return nil end
    return n
end

local function GetZoneCustomSubPriority(zoneName, mobName)
    local subs = AMA.GetZoneMobSubPriorities and AMA.GetZoneMobSubPriorities(zoneName, false)
    if not subs then return nil end
    return NormalizeUISubPriority(subs[mobName])
end

local function SetZoneCustomSubPriority(zoneName, mobName, value)
    local sub = NormalizeUISubPriority(value)
    local subs = AMA.GetZoneMobSubPriorities and AMA.GetZoneMobSubPriorities(zoneName, sub ~= nil)
    if not subs then return end
    subs[mobName] = sub
end

local function ClearZoneCustomSubPriority(zoneName, mobName)
    local subs = AMA.GetZoneMobSubPriorities and AMA.GetZoneMobSubPriorities(zoneName, false)
    if subs then subs[mobName] = nil end
end

local function GetEffectiveSubPriority(zoneName, mobName, priority)
    if priority == "REMOVED" then return nil end
    if AMA.GetMobSubPriorityForZone then
        return AMA.GetMobSubPriorityForZone(zoneName, mobName, priority)
    end
    return GetZoneCustomSubPriority(zoneName, mobName)
end

local function GetSubSortRank(subPriority)
    return NormalizeUISubPriority(subPriority) or 9999
end

local function FormatSubPriority(subPriority)
    local n = NormalizeUISubPriority(subPriority)
    if n then return tostring(n) end
    return "-"
end

local function ApplyRowChangeState(row, hasChange)
    if hasChange then
        row._nameFS:SetTextColor(1.0, 0.95, 0.75, 1)
        row._dBtn:Show()
    else
        row._nameFS:SetTextColor(0.85, 0.85, 0.85, 1)
        row._dBtn:Hide()
    end
end

local function UpdateRowSubPriorityDisplay(row, zoneName, mobName, priority)
    if not row or not row._subFS or not row._subBtn then return end

    local customSub = GetZoneCustomSubPriority(zoneName, mobName)
    local effSub    = GetEffectiveSubPriority(zoneName, mobName, priority)

    row._subFS:SetText(FormatSubPriority(effSub))
    if priority == "REMOVED" then
        row._subFS:SetTextColor(0.28, 0.28, 0.28, 1)
        row._subBtn:EnableMouse(false)
    elseif customSub then
        row._subFS:SetTextColor(1.00, 0.82, 0.25, 1)
        row._subBtn:EnableMouse(true)
    elseif effSub then
        row._subFS:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
        row._subBtn:EnableMouse(true)
    else
        row._subFS:SetTextColor(0.45, 0.45, 0.45, 1)
        row._subBtn:EnableMouse(true)
    end

    row._subBtn.currentSub   = customSub
    row._subBtn.effectiveSub = effSub
    row._subBtn.priority     = priority
    row._subBtn.zoneKey      = zoneName
    row._subBtn.mobName      = mobName
end

-- Helper: rebuild AMA.currentZoneMobDB from base DB + overrides + zone additions.
local function RebuildLiveZoneDB()
    if not AMA.currentZoneName or AMA.currentZoneName == "" or not AMA.ResolveZoneName then return end
    local cz = AMA.ResolveZoneName(AMA.currentZoneName)
    AMA.currentZoneMobDB = AMA.BuildZoneMobDB(cz)
end

-- Vertical 1-px separator between the two panels
local dbDivLine = t5:CreateTexture(nil, "ARTWORK")
dbDivLine:SetTexture(W8); dbDivLine:SetWidth(1)
dbDivLine:SetPoint("TOPLEFT",    t5, "TOPLEFT",    DB_LEFT_W, 0)
dbDivLine:SetPoint("BOTTOMLEFT", t5, "BOTTOMLEFT", DB_LEFT_W, 28)
dbDivLine:SetVertexColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)

-- ---- LEFT PANEL: scrollable zone list ----------------------------------
local zoneScroll = CreateFrame("ScrollFrame", "AMATabZoneScroll", t5)
zoneScroll:SetPoint("TOPLEFT",    t5, "TOPLEFT",    4,  -2)
zoneScroll:SetPoint("BOTTOMLEFT", t5, "BOTTOMLEFT", 4,  28)
zoneScroll:SetWidth(DB_LEFT_W - 8)
zoneScroll:EnableMouseWheel(true)
zoneScroll:SetScript("OnMouseWheel", function(self, delta)
    local cur = self:GetVerticalScroll()
    local maxVal = self:GetVerticalScrollRange()
    local newVal = math.max(0, math.min(maxVal, cur - delta * 30))
    self:SetVerticalScroll(newVal)
end)

dbTabZoneChild = CreateFrame("Frame", nil, zoneScroll)
dbTabZoneChild:SetWidth(DB_LEFT_W - 8)
zoneScroll:SetScrollChild(dbTabZoneChild)

-- "Reset Zone to Defaults" button anchored below the zone scroll
dbResetZoneBtn = E.Btn(t5, "Reset Zone to Defaults", DB_LEFT_W - 10, 20)
dbResetZoneBtn:SetPoint("BOTTOMLEFT", t5, "BOTTOMLEFT", 4, 4)
dbResetZoneBtn:GetFontString():SetTextColor(0.35, 0.35, 0.35, 1)
dbResetZoneBtn:Disable()
dbResetZoneBtn:SetScript("OnClick", function()
    if not AutoMarkAssistDB or not dbTabCurrentZone then return end
    local zoneName = dbTabCurrentZone
    local baseDB   = AutoMarkAssist_MobDB and AutoMarkAssist_MobDB[zoneName]
    local zoneOverrides = AMA.GetZoneMobOverrides(zoneName, false)
    local zoneRemovals = AMA.GetZoneMobRemovals(zoneName, false)
    local zoneSubs = AMA.GetZoneMobSubPriorities and AMA.GetZoneMobSubPriorities(zoneName, false)
    -- Clear overrides and removals for every mob in this zone's base DB.
    if baseDB then
        for mobName in pairs(baseDB) do
            if zoneOverrides then zoneOverrides[mobName] = nil end
            if zoneRemovals  then zoneRemovals[mobName]  = nil end
            if zoneSubs      then zoneSubs[mobName]      = nil end
        end
    end
    -- Clear all zone-specific additions for this zone.
    if AutoMarkAssistDB.zoneAdditions then
        AutoMarkAssistDB.zoneAdditions[zoneName] = nil
    end
    if AutoMarkAssistDB.mobSubPriorities then
        AutoMarkAssistDB.mobSubPriorities[zoneName] = nil
    end
    RebuildLiveZoneDB()
    AMA.Print(string.format("Reset |cFFFFD700%s|r to defaults.", zoneName))
    RefreshDBTab()
end)

-- ---- RIGHT PANEL: fixed column header + scrollable mob list ------------
local dbHdrFrame = CreateFrame("Frame", nil, t5)
dbHdrFrame:SetPoint("TOPLEFT",  t5, "TOPLEFT",  DB_LEFT_W + 4, -2)
dbHdrFrame:SetPoint("TOPRIGHT", t5, "TOPRIGHT",            -4, -2)
dbHdrFrame:SetHeight(18)

do  -- header widgets scope
    local hPri = dbHdrFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hPri:SetPoint("LEFT", dbHdrFrame, "LEFT", 4, 0)
    hPri:SetText("Priority"); hPri:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)

    local hSub = dbHdrFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hSub:SetPoint("LEFT", dbHdrFrame, "LEFT", SUB_COL_X, 0)
    hSub:SetText("Sub"); hSub:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)

    local hMob = dbHdrFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hMob:SetPoint("LEFT", dbHdrFrame, "LEFT", NAME_COL_X, 0)
    hMob:SetText("Mob Name"); hMob:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)

    local hHint = dbHdrFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hHint:SetText("Pri: L/R   Sub: L/R")
    hHint:SetTextColor(0.36, 0.36, 0.36, 1)

    local subHelpBtn = E.Btn(dbHdrFrame, "Sub Help", 68, 16)
    subHelpBtn:SetPoint("RIGHT", dbHdrFrame, "RIGHT", -2, 0)
    subHelpBtn:SetScript("OnClick", ShowSubPriorityHelp)
    subHelpBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Open a simple explanation of how Sub tie-breaks work.")
        GameTooltip:Show()
    end)
    subHelpBtn:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    hHint:SetPoint("RIGHT", subHelpBtn, "LEFT", -6, 0)
    hHint:SetText("Pri: L/R   Sub: L/R")

    local hS = dbHdrFrame:CreateTexture(nil, "ARTWORK")
    hS:SetTexture(W8); hS:SetHeight(1)
    hS:SetPoint("BOTTOMLEFT",  dbHdrFrame, "BOTTOMLEFT",  0, 0)
    hS:SetPoint("BOTTOMRIGHT", dbHdrFrame, "BOTTOMRIGHT", 0, 0)
    hS:SetVertexColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 0.8)
end  -- header widgets scope

-- Mob scroll leaves TOOLBAR_H px at the bottom for the add-mob toolbar.
dbTabMobScroll = CreateFrame("ScrollFrame", "AMATabMobScroll", t5)
dbTabMobScroll:SetPoint("TOPLEFT",     t5, "TOPLEFT",     DB_LEFT_W + 4, -20)
dbTabMobScroll:SetPoint("BOTTOMRIGHT", t5, "BOTTOMRIGHT",            -4, TOOLBAR_H + 4)
dbTabMobScroll:EnableMouseWheel(true)
dbTabMobScroll:SetScript("OnMouseWheel", function(self, delta)
    local cur = self:GetVerticalScroll()
    local maxVal = self:GetVerticalScrollRange()
    local newVal = math.max(0, math.min(maxVal, cur - delta * 30))
    self:SetVerticalScroll(newVal)
end)

local mobChild = CreateFrame("Frame", nil, dbTabMobScroll)
mobChild:SetWidth(MOB_CHILD_W)
mobChild:SetHeight(600)
dbTabMobScroll:SetScrollChild(mobChild)

-- Pre-allocate MAX_MOB_ROWS reusable row buttons.
-- PopulateDBMobs updates them in-place; scroll child is never recreated.
local MAX_MOB_ROWS = 36
local mobRows = {}

do  -- row pre-allocation scope
    for ri = 1, MAX_MOB_ROWS do
        local row = CreateFrame("Button", nil, mobChild)
        row:SetSize(MOB_CHILD_W, ROW_H)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        local rBg = row:CreateTexture(nil, "BACKGROUND")
        rBg:SetTexture(W8); rBg:SetAllPoints()
        rBg:SetVertexColor(0, 0, 0, 0); row._bg = rBg

        local pFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        pFS:SetPoint("LEFT", row, "LEFT", 4, 0)
        pFS:SetWidth(PRI_COL_W); pFS:SetJustifyH("LEFT"); row._priFS = pFS

        local sBtn = CreateFrame("Button", nil, row)
        sBtn:SetSize(SUB_COL_W, ROW_H - 2)
        sBtn:SetPoint("LEFT", row, "LEFT", SUB_COL_X - 2, 0)
        sBtn:SetFrameLevel(row:GetFrameLevel() + 1)
        sBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        local sFS = sBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        sFS:SetPoint("CENTER")
        sFS:SetText("-")
        row._subFS = sFS
        row._subBtn = sBtn

        sBtn:SetScript("OnEnter", function(self)
            if not self:IsMouseEnabled() then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Sub only matters when mobs share the same main Priority.")
            if self.currentSub then
                GameTooltip:AddLine("Custom value: " .. self.currentSub, 1, 0.82, 0.25, true)
            elseif self.effectiveSub then
                GameTooltip:AddLine("Built-in value: " .. self.effectiveSub, E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], true)
            else
                GameTooltip:AddLine("No sub-priority set. Uses default tie-break order.", 0.75, 0.75, 0.75, true)
            end
            GameTooltip:AddLine("Lower number wins, so 1 gets the better mark before 2.", 0.75, 0.75, 0.75, true)
            GameTooltip:AddLine("Higher main Priority still wins first.", 0.75, 0.75, 0.75, true)
            GameTooltip:AddLine("Left-click cycles 1-" .. UI_MAX_SUB_PRIORITY .. ".", 0.75, 0.75, 0.75, true)
            GameTooltip:AddLine("Right-click clears the custom value.", 0.75, 0.75, 0.75, true)
            GameTooltip:Show()
        end)
        sBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        sBtn:SetScript("OnClick", function(self, button)
            if not AutoMarkAssistDB or not self.mobName or not self.zoneKey then return end
            if self.priority == "REMOVED" then return end

            if button == "RightButton" then
                ClearZoneCustomSubPriority(self.zoneKey, self.mobName)
            else
                local nextSub = (self.currentSub or 0) + 1
                if nextSub > UI_MAX_SUB_PRIORITY then nextSub = 1 end
                SetZoneCustomSubPriority(self.zoneKey, self.mobName, nextSub)
            end

            local rowParent = self:GetParent()
            local zoneOverrides = AMA.GetZoneMobOverrides(self.zoneKey, false) or {}
            local zoneRemovals  = AMA.GetZoneMobRemovals(self.zoneKey, false) or {}
            local hasChange = self.isUserAdded
                or zoneOverrides[self.mobName]
                or zoneRemovals[self.mobName]
                or GetZoneCustomSubPriority(self.zoneKey, self.mobName)

            UpdateRowSubPriorityDisplay(rowParent, self.zoneKey, self.mobName, self.priority)
            ApplyRowChangeState(rowParent, hasChange)
        end)

        -- Name column width reduced to leave 24 px for the delete button.
        local nFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nFS:SetPoint("LEFT", row, "LEFT", NAME_COL_X, 0)
        nFS:SetWidth(MOB_CHILD_W - NAME_COL_X - DELETE_BTN_W - 8)
        nFS:SetJustifyH("LEFT"); row._nameFS = nFS

        -- Small per-row delete / reset button (shown only when mob has changes).
        local dBtn = CreateFrame("Button", nil, row)
        dBtn:SetSize(DELETE_BTN_W, ROW_H - 2)
        dBtn:SetPoint("RIGHT", row, "RIGHT", -2, 0)
        dBtn:SetFrameLevel(row:GetFrameLevel() + 2)
        local dBtnBg = dBtn:CreateTexture(nil, "BACKGROUND")
        dBtnBg:SetTexture(W8); dBtnBg:SetAllPoints()
        dBtnBg:SetVertexColor(0, 0, 0, 0); dBtn._bg = dBtnBg
        local dBtnFS = dBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        dBtnFS:SetPoint("CENTER"); dBtnFS:SetText("x")
        dBtnFS:SetTextColor(0.55, 0.20, 0.20, 1)
        dBtn:SetScript("OnEnter", function(s)
            s._bg:SetVertexColor(0.50, 0.08, 0.08, 1)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetText(s.isUserAdded and "Delete user-added mob" or "Reset user changes")
            GameTooltip:Show()
        end)
        dBtn:SetScript("OnLeave", function(s)
            s._bg:SetVertexColor(0, 0, 0, 0); GameTooltip:Hide()
        end)
        dBtn:SetScript("OnClick", function(self)
            if not AutoMarkAssistDB or not self.mobName then return end
            if self.isUserAdded and self.zoneKey then
                -- Fully remove a user-added mob from zone additions.
                if AutoMarkAssistDB.zoneAdditions and
                   AutoMarkAssistDB.zoneAdditions[self.zoneKey] then
                    AutoMarkAssistDB.zoneAdditions[self.zoneKey][self.mobName] = nil
                end
                ClearZoneCustomSubPriority(self.zoneKey, self.mobName)
            else
                -- Reset any override or removal back to the base DB priority.
                local zoneOverrides = AMA.GetZoneMobOverrides(self.zoneKey, false)
                local zoneRemovals = AMA.GetZoneMobRemovals(self.zoneKey, false)
                if zoneOverrides then zoneOverrides[self.mobName] = nil end
                if zoneRemovals  then zoneRemovals[self.mobName]  = nil end
                ClearZoneCustomSubPriority(self.zoneKey, self.mobName)
            end
            RebuildLiveZoneDB()
            RefreshDBTab()
        end)
        dBtn:Hide()
        row._dBtn = dBtn

        row:SetScript("OnEnter", function(s)
            s._bg:SetVertexColor(E.BTN_H[1], E.BTN_H[2], E.BTN_H[3], 0.55)
        end)
        row:SetScript("OnLeave", function(s)
            if s._altRow then
                s._bg:SetVertexColor(1, 1, 1, 0.03)
            else
                s._bg:SetVertexColor(0, 0, 0, 0)
            end
        end)
        row:SetScript("OnClick", function(self, button)
            if not AutoMarkAssistDB or not self.mobName then return end
            -- User-added mobs cycle through the same priority list but are
            -- stored in zoneAdditions rather than the zone override tables.
            if self.isUserAdded then
                local capN    = self.mobName
                local capZ    = self.zoneKey
                local adds    = AutoMarkAssistDB.zoneAdditions
                local currEff = adds and adds[capZ] and adds[capZ][capN] or "HIGH"
                if button == "RightButton" then
                    -- Right-click: reset to HIGH (original add default)
                    if adds and adds[capZ] then adds[capZ][capN] = "HIGH" end
                else
                    local nextPri = nil
                    for ci, v in ipairs(CYCLE) do
                        if v == currEff then nextPri = CYCLE[ci + 1]; break end
                    end
                    -- Wrapping past REMOVED cycles back to HIGH for user-added mobs.
                    nextPri = nextPri or "HIGH"
                    if nextPri == "REMOVED" then
                        -- Cycle once more to skip REMOVED for user-added mobs;
                        -- use the x-button to fully delete instead.
                        nextPri = nil
                        for ci, v in ipairs(CYCLE) do
                            if v == "REMOVED" then nextPri = CYCLE[ci + 1]; break end
                        end
                        nextPri = nextPri or "HIGH"
                    end
                    AutoMarkAssistDB.zoneAdditions = AutoMarkAssistDB.zoneAdditions or {}
                    AutoMarkAssistDB.zoneAdditions[capZ] = AutoMarkAssistDB.zoneAdditions[capZ] or {}
                    AutoMarkAssistDB.zoneAdditions[capZ][capN] = nextPri
                end
                RebuildLiveZoneDB()
                local newEff = (AutoMarkAssistDB.zoneAdditions and
                                AutoMarkAssistDB.zoneAdditions[capZ] and
                                AutoMarkAssistDB.zoneAdditions[capZ][capN]) or "HIGH"
                local newCol = PRI_COL[newEff] or PRI_COL.MEDIUM
                self._priFS:SetText(newEff)
                self._priFS:SetTextColor(newCol[1], newCol[2], newCol[3], 1)
                UpdateRowSubPriorityDisplay(self, capZ, capN, newEff)
                self._subBtn.isUserAdded = true
                return
            end

            local zoneOverrides = AMA.GetZoneMobOverrides(self.zoneKey, true)
            local zoneRemovals  = AMA.GetZoneMobRemovals(self.zoneKey, true)
            local capN    = self.mobName
            local capB    = self.basePri
            local currEff = (zoneRemovals[capN] and "REMOVED")
                         or zoneOverrides[capN]
                         or capB

            if button == "RightButton" then
                -- Right-click: instant reset to DB default
                zoneOverrides[capN] = nil
                zoneRemovals[capN]  = nil
            else
                -- Left-click: advance one step in CYCLE
                local nextPri = nil
                for ci, v in ipairs(CYCLE) do
                    if v == currEff then nextPri = CYCLE[ci + 1]; break end
                end
                -- Wrap past end of cycle back to the first entry (BOSS).
                nextPri = nextPri or CYCLE[1]
                -- If we've cycled back to the base priority, clear the
                -- override instead of storing a redundant entry.
                if nextPri == capB then
                    zoneOverrides[capN] = nil
                    zoneRemovals[capN]  = nil
                elseif nextPri == "REMOVED" then
                    zoneRemovals[capN]  = true
                    zoneOverrides[capN] = nil
                else
                    zoneOverrides[capN] = nextPri
                    zoneRemovals[capN]  = nil
                end
            end

            RebuildLiveZoneDB()

            -- Update this row's display in-place rather than re-sorting the
            -- whole list.  The row keeps its position; only its colour and
            -- priority label change.  RefreshDBTab re-sorts on zone switch.
            local newEff = (zoneRemovals[capN] and "REMOVED")
                        or zoneOverrides[capN]
                        or capB
            local newCol = PRI_COL[newEff] or PRI_COL.MEDIUM
            self._priFS:SetText(newEff)
            self._priFS:SetTextColor(newCol[1], newCol[2], newCol[3], 1)
            UpdateRowSubPriorityDisplay(self, self.zoneKey, capN, newEff)
            self._subBtn.isUserAdded = false
            local hasChange = zoneOverrides[capN]
                or zoneRemovals[capN]
                or GetZoneCustomSubPriority(self.zoneKey, capN)
            ApplyRowChangeState(self, hasChange)
        end)

        row:Hide()
        mobRows[ri] = row
    end
end  -- row pre-allocation scope

-- Populate the right panel for the given zone.
-- Updates pre-allocated rows in-place; never recreates the scroll child.
local function PopulateDBMobs(zoneName)
    for ri = 1, MAX_MOB_ROWS do mobRows[ri]:Hide() end
    if not zoneName then return end

    local zoneDB = AutoMarkAssist_MobDB and AutoMarkAssist_MobDB[zoneName]

    local db  = AutoMarkAssistDB
    local ovr = AMA.GetZoneMobOverrides(zoneName, false) or {}
    local rem = AMA.GetZoneMobRemovals(zoneName, false) or {}
    local subs = AMA.GetZoneMobSubPriorities and AMA.GetZoneMobSubPriorities(zoneName, false) or {}

    -- Build list: base-DB mobs + user-added mobs for this zone.
    local list = {}
    if zoneDB then
        for name, basePri in pairs(zoneDB) do
            local eff = (rem[name] and "REMOVED") or ovr[name] or basePri
            list[#list + 1] = {
                name=name,
                basePri=basePri,
                eff=eff,
                effSub=GetEffectiveSubPriority(zoneName, name, eff),
                isUserAdded=false,
            }
        end
    end
    -- User-added mobs that are not in the base DB for this zone.
    local adds = db and db.zoneAdditions and db.zoneAdditions[zoneName]
    if adds then
        for name, pri in pairs(adds) do
            if not (zoneDB and zoneDB[name]) then
                list[#list + 1] = {
                    name=name,
                    basePri=nil,
                    eff=pri,
                    effSub=GetEffectiveSubPriority(zoneName, name, pri),
                    isUserAdded=true,
                }
            end
        end
    end

    if #list == 0 then
        local r = mobRows[1]
        r._priFS:SetText("")
        r._subFS:SetText("")
        r._nameFS:SetText("|cFFFF4444No database entry for this zone.|r")
        r._nameFS:SetTextColor(1, 1, 1, 1)
        r._dBtn:Hide()
        r.mobName = nil
        r._subBtn.mobName = nil
        r._altRow = false; r._bg:SetVertexColor(0, 0, 0, 0)
        r:SetPoint("TOPLEFT", mobChild, "TOPLEFT", 0, 0); r:Show()
        mobChild:SetHeight(30)
        return
    end

    -- Sort by the effective (overridden) priority so user overrides are
    -- reflected in the grouping when the tab loads or the zone changes.
    -- Clicking a row updates it in-place (no re-sort), so there is no
    -- jumping while the user is actively editing priorities.
    table.sort(list, function(a, b)
        local ra = PRI_RANK[a.eff] or 3
        local rb = PRI_RANK[b.eff] or 3
        if ra ~= rb then return ra < rb end
        local sa = GetSubSortRank(a.effSub)
        local sb = GetSubSortRank(b.effSub)
        if sa ~= sb then return sa < sb end
        return a.name < b.name
    end)

    for i, entry in ipairs(list) do
        if i > MAX_MOB_ROWS then break end
        local row = mobRows[i]
        local col = PRI_COL[entry.eff] or PRI_COL.MEDIUM

        row._priFS:SetText(entry.eff)
        row._priFS:SetTextColor(col[1], col[2], col[3], 1)
        row._nameFS:SetText(entry.name)
        row.mobName     = entry.name
        row.basePri     = entry.basePri
        row.isUserAdded = entry.isUserAdded
        row.zoneKey     = zoneName
        row._subBtn.isUserAdded = entry.isUserAdded

        -- Brighter name for mobs with an active user change.
        local hasChange = entry.isUserAdded or ovr[entry.name] or rem[entry.name] or subs[entry.name]
        row._dBtn.mobName     = entry.name
        row._dBtn.zoneKey     = zoneName
        row._dBtn.isUserAdded = entry.isUserAdded
        ApplyRowChangeState(row, hasChange)
        UpdateRowSubPriorityDisplay(row, zoneName, entry.name, entry.eff)

        row._altRow = (i % 2 == 0)
        if row._altRow then
            row._bg:SetVertexColor(1, 1, 1, 0.03)
        else
            row._bg:SetVertexColor(0, 0, 0, 0)
        end

        row:SetPoint("TOPLEFT", mobChild, "TOPLEFT", 0, -(i - 1) * ROW_H)
        row:Show()
    end
    mobChild:SetHeight(math.max(200, #list * ROW_H + 10))
end  -- PopulateDBMobs

-- RefreshDBTab: called by mob row OnClick and AMA.RefreshConfigFrame.
RefreshDBTab = function()
    if dbTabCurrentZone then
        local sv = dbTabMobScroll:GetVerticalScroll()
        PopulateDBMobs(dbTabCurrentZone)
        dbTabMobScroll:SetVerticalScroll(sv)
    end
end

-- Build the zone button list on the left panel
local dbZones = {}
if AutoMarkAssist_MobDB then
    for zone in pairs(AutoMarkAssist_MobDB) do dbZones[#dbZones + 1] = zone end
    table.sort(dbZones)
end

do  -- zone button construction scope
    local ZW = DB_LEFT_W - 24
    local zy = 0

    -- Build expansion-grouped zone list from AutoMarkAssist_ExpansionOrder
    -- (defined in the DB file). Falls back to flat alphabetical when absent.
    local groups = {}
    local placed = {}
    if AutoMarkAssist_ExpansionOrder then
        for _, exp in ipairs(AutoMarkAssist_ExpansionOrder) do
            local filtered = {}
            for _, z in ipairs(exp.zones) do
                if AutoMarkAssist_MobDB[z] then
                    filtered[#filtered + 1] = z
                    placed[z] = true
                end
            end
            if #filtered > 0 then
                groups[#groups + 1] = { name = exp.name, zones = filtered }
            end
        end
    end
    -- Collect zones not covered by any expansion group.
    local ungrouped = {}
    for _, z in ipairs(dbZones) do
        if not placed[z] then ungrouped[#ungrouped + 1] = z end
    end
    if #ungrouped > 0 then
        groups[#groups + 1] = { name = "Other", zones = ungrouped }
    end
    -- Fallback: no expansion order at all -> single flat group.
    if #groups == 0 and #dbZones > 0 then
        groups[#groups + 1] = { name = nil, zones = dbZones }
    end

    -- Reverse expansion groups so the latest (current) expansion appears
    -- at the top of the list.  Keep "Other" pinned at the bottom.
    local otherGroup
    if #groups > 0 and groups[#groups].name == "Other" then
        otherGroup = table.remove(groups)
    end
    local reversed = {}
    for i = #groups, 1, -1 do reversed[#reversed + 1] = groups[i] end
    if otherGroup then reversed[#reversed + 1] = otherGroup end
    groups = reversed

    for gi, group in ipairs(groups) do
        -- Expansion header row (skip for unnamed fallback group).
        if group.name then
            if gi > 1 then zy = zy + 6 end
            local hdr = dbTabZoneChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            hdr:SetPoint("TOPLEFT", dbTabZoneChild, "TOPLEFT", 2, -zy)
            hdr:SetWidth(ZW - 4)
            hdr:SetJustifyH("LEFT")
            hdr:SetText(group.name)
            hdr:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 0.9)
            zy = zy + 18
        end

        for _, zone in ipairs(group.zones) do
            local zBtn = CreateFrame("Button", nil, dbTabZoneChild)
            zBtn:SetSize(ZW, 20)
            zBtn:SetPoint("TOPLEFT", dbTabZoneChild, "TOPLEFT", 0, -zy)

            local zbBg = zBtn:CreateTexture(nil, "BACKGROUND")
            zbBg:SetTexture(W8); zbBg:SetAllPoints()
            zbBg:SetVertexColor(0, 0, 0, 0); zBtn._bg = zbBg

            local zbFS = zBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            zbFS:SetPoint("LEFT", zBtn, "LEFT", 4, 0)
            zbFS:SetWidth(ZW - 8); zbFS:SetJustifyH("LEFT")
            zbFS:SetText(zone); zbFS:SetTextColor(0.80, 0.80, 0.80, 1)
            zBtn._lbl = zbFS

            local capturedZone = zone
            zBtn:SetScript("OnClick", function(self)
                if dbTabActiveZoneBtn then
                    dbTabActiveZoneBtn._bg:SetVertexColor(0, 0, 0, 0)
                    dbTabActiveZoneBtn._lbl:SetTextColor(0.80, 0.80, 0.80, 1)
                end
                dbTabActiveZoneBtn = self
                dbTabCurrentZone   = capturedZone
                self._bg:SetVertexColor(E.BTN_A[1], E.BTN_A[2], E.BTN_A[3], 1)
                self._lbl:SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
                if dbResetZoneBtn then
                    dbResetZoneBtn:Enable()
                    dbResetZoneBtn:GetFontString():SetTextColor(1, 1, 1, 1)
                end
                PopulateDBMobs(capturedZone)
            end)
            zBtn:SetScript("OnEnter", function(self)
                if self ~= dbTabActiveZoneBtn then
                    self._bg:SetVertexColor(E.BTN_H[1], E.BTN_H[2], E.BTN_H[3], 0.6)
                end
            end)
            zBtn:SetScript("OnLeave", function(self)
                if self ~= dbTabActiveZoneBtn then
                    self._bg:SetVertexColor(0, 0, 0, 0)
                end
            end)
            zy = zy + 22
        end
    end
    dbTabZoneChild:SetHeight(math.max(200, zy + 10))
end  -- zone button construction scope

-- ---- BOTTOM TOOLBAR: Add Mob -------------------------------------------
do  -- toolbar construction scope
    local ADD_BTN_W   = 90
    local PRI_BTN_GAP = 4

    local toolbar = CreateFrame("Frame", nil, t5)
    toolbar:SetPoint("BOTTOMLEFT",  t5, "BOTTOMLEFT",  DB_LEFT_W + 4, 4)
    toolbar:SetPoint("BOTTOMRIGHT", t5, "BOTTOMRIGHT",            -4, 4)
    toolbar:SetHeight(TOOLBAR_H)

    -- Thin separator at the top of the toolbar
    local tsep = toolbar:CreateTexture(nil, "ARTWORK")
    tsep:SetTexture(W8); tsep:SetHeight(1)
    tsep:SetPoint("TOPLEFT",  toolbar, "TOPLEFT",  0, 0)
    tsep:SetPoint("TOPRIGHT", toolbar, "TOPRIGHT", 0, 0)
    tsep:SetVertexColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 0.6)

    -- Row 1: mob name input + Add button
    -- Label anchored left, Add button anchored right, edit box stretches between.
    local mobNameLabel = E.Label(toolbar, "Mob Name:", 4, -8)
    local addBtn = E.Btn(toolbar, "Add to Zone", ADD_BTN_W, 20)
    addBtn:SetPoint("TOPRIGHT", toolbar, "TOPRIGHT", -2, -6)

    dbAddMobEB = E.EditBox(toolbar, 120, 20)
    dbAddMobEB:SetPoint("LEFT",  mobNameLabel, "RIGHT", 12, 0)
    dbAddMobEB:SetPoint("RIGHT", addBtn,       "LEFT", -6, 0)
    dbAddMobEB:SetAutoFocus(false); dbAddMobEB:SetMaxLetters(64)

    -- Row 2: priority selector buttons (disabled until mob name is entered)
    -- Buttons stretch evenly across the available toolbar width so they
    -- never overflow regardless of resolution or UI scale.
    local priorityLabel = E.Label(toolbar, "Priority:", 4, -32)
    local addPriOptions = { "BOSS", "HIGH", "CC", "MEDIUM", "LOW", "SKIP" }
    dbAddMobPriSel  = "HIGH"
    dbAddMobPriBtns = {}

    -- Container frame for the priority buttons so they can fill the space
    -- between the label and the toolbar right edge evenly.
    local priRow = CreateFrame("Frame", nil, toolbar)
    priRow:SetHeight(18)
    priRow:SetPoint("LEFT",  priorityLabel, "RIGHT", 12, 0)
    priRow:SetPoint("RIGHT", toolbar,       "RIGHT", -2, 0)
    priRow:SetPoint("TOP",   toolbar,       "TOP",    0, -30)

    local NUM_PRI = #addPriOptions
    for pi, pname in ipairs(addPriOptions) do
        local pb = E.Btn(priRow, pname, 40, 18)
        -- Anchor each button as a fractional slice of the container width.
        local leftFrac  = (pi - 1) / NUM_PRI
        local rightFrac = pi / NUM_PRI
        if pi == 1 then
            pb:SetPoint("TOPLEFT", priRow, "TOPLEFT", 0, 0)
        else
            pb:SetPoint("LEFT", priRow, "LEFT", leftFrac * priRow:GetWidth(), 0)
            -- Use relative anchoring: left edge at fraction of parent width.
            pb:ClearAllPoints()
            pb:SetPoint("TOPLEFT", priRow, "TOPLEFT",
                leftFrac * 1000, 0)  -- placeholder; OnSizeChanged fixes it
        end
        pb:SetScript("OnClick", function()
            dbAddMobPriSel = pname
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        end)
        dbAddMobPriBtns[pname] = pb
        pb._priIndex = pi
    end

    -- Dynamically size and position the priority buttons whenever the
    -- container is resized (resolution change, UI scale change, etc.).
    local function LayoutPriBtns()
        local totalW = priRow:GetWidth()
        if not totalW or totalW < 10 then return end
        local gap    = PRI_BTN_GAP
        local avail  = totalW - (gap * (NUM_PRI - 1))
        local btnW   = math.floor(avail / NUM_PRI)
        for _, pname in ipairs(addPriOptions) do
            local pb = dbAddMobPriBtns[pname]
            if pb then
                local idx = pb._priIndex
                local x   = (idx - 1) * (btnW + gap)
                pb:ClearAllPoints()
                pb:SetPoint("TOPLEFT", priRow, "TOPLEFT", x, 0)
                pb:SetSize(btnW, 18)
            end
        end
    end
    priRow:SetScript("OnSizeChanged", LayoutPriBtns)
    -- Initial layout pass after the frame is fully constructed.
    priRow:SetScript("OnShow", function(self)
        LayoutPriBtns()
        self:SetScript("OnShow", nil)  -- only needed once
    end)

    -- Helper: enable/disable priority buttons and Add button based on mob name input.
    local function UpdateToolbarState()
        local hasText = dbAddMobEB:GetText() ~= ""
        for _, pb in pairs(dbAddMobPriBtns) do
            if hasText then pb:Enable() else pb:Disable() end
            pb:GetFontString():SetTextColor(hasText and 1 or 0.35, hasText and 1 or 0.35, hasText and 1 or 0.35, 1)
        end
        if hasText then addBtn:Enable() else addBtn:Disable() end
        addBtn:GetFontString():SetTextColor(hasText and 1 or 0.35, hasText and 1 or 0.35, hasText and 1 or 0.35, 1)
    end

    dbAddMobEB:SetScript("OnTextChanged", function() UpdateToolbarState() end)

    -- Initial disabled state
    UpdateToolbarState()

    addBtn:SetScript("OnClick", function()
        if not dbTabCurrentZone then AMA.Print("Select a zone first."); return end
        local name = dbAddMobEB:GetText()
        if not name or name == "" then AMA.Print("Enter a mob name."); return end
        if not AutoMarkAssistDB then return end
        AutoMarkAssistDB.zoneAdditions = AutoMarkAssistDB.zoneAdditions or {}
        AutoMarkAssistDB.zoneAdditions[dbTabCurrentZone] =
            AutoMarkAssistDB.zoneAdditions[dbTabCurrentZone] or {}
        AutoMarkAssistDB.zoneAdditions[dbTabCurrentZone][name] = dbAddMobPriSel
        dbAddMobEB:SetText("")
        RebuildLiveZoneDB()
        AMA.Print(string.format(
            "Added |cFFFFFFFF%s|r to |cFFFFD700%s|r as |cFF00FF00%s|r",
            name, dbTabCurrentZone, dbAddMobPriSel))
        RefreshDBTab()
    end)
end  -- toolbar construction scope

-- Auto-refresh the mob list whenever this tab is made visible.
t5:SetScript("OnShow", function()
    if dbTabCurrentZone and RefreshDBTab then RefreshDBTab() end
end)

end  -- Database tab construction scope

-- ================================================================
-- TAB 5 -- ABOUT
-- ================================================================

local t6 = tabContents[5]

local function AboutLine(text, y, font, justify)
    local fs = t6:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    fs:SetPoint("TOP", t6, "TOP", 0, y); fs:SetText(text)
    fs:SetJustifyH(justify or "CENTER")
    return fs
end

-- Helper: two-column command row with clear separation.
-- Columns shifted right so the visual mass of the block
-- (long descriptions, short commands) appears centred under the title.
local function AboutCmd(desc, cmd, y)
    local dfs = t6:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dfs:SetPoint("TOPRIGHT", t6, "TOP", 5, y)
    dfs:SetText(desc)
    dfs:SetJustifyH("RIGHT"); dfs:SetWidth(200)
    local cfs = t6:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cfs:SetPoint("TOPLEFT", t6, "TOP", 25, y)
    cfs:SetText("|cFFAAAAAA" .. cmd .. "|r")
    cfs:SetJustifyH("LEFT"); cfs:SetWidth(200)
end

local function AboutSep(y, width)
    local s = t6:CreateTexture(nil, "ARTWORK")
    s:SetTexture(W8); s:SetHeight(1); s:SetWidth(width or 340)
    s:SetPoint("TOP", t6, "TOP", 0, y)
    s:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 0.35)
end

-- ── Title ──
local logoFS = t6:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
logoFS:SetPoint("TOP", t6, "TOP", 0, -16)
logoFS:SetText("|cFF1A9EC0AutoMarkAssist|r")

AboutLine("|cFFAAAAAA" .. "v" .. AMA.VERSION .. "|r", -34, "GameFontHighlightSmall")

-- accent bar under title
local logoSep = t6:CreateTexture(nil, "ARTWORK")
logoSep:SetTexture(W8); logoSep:SetHeight(1); logoSep:SetWidth(200)
logoSep:SetPoint("TOP", t6, "TOP", 0, -46)
logoSep:SetVertexColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 0.6)

local whatsNewBtn = E.Btn(t6, "Show What's New", 132, 20)
whatsNewBtn:SetPoint("TOP", t6, "TOP", 0, -54)
whatsNewBtn:SetScript("OnClick", ShowLatestWhatsNew)

-- ── What it does ──
AboutLine("|cFF1A9EC0Overview|r", -90, "GameFontHighlight")
AboutLine("Marks enemies from mouseover or proximity using a zone-aware priority", -108, "GameFontHighlightSmall")
AboutLine("database, then assigns icons from your configured mark pools.", -122, "GameFontHighlightSmall")
AboutLine("Dynamic mode can upgrade surviving mobs into better icons as pulls change.", -136, "GameFontHighlightSmall")
AboutLine("Manual mode lets you preview and apply marks with the scroll wheel.", -150, "GameFontHighlightSmall")
AboutLine("Unknown zones fall back to your configured pools until you add entries.", -164, "GameFontHighlightSmall")

local lastExp = AutoMarkAssist_ExpansionOrder[#AutoMarkAssist_ExpansionOrder]
local zoneCount = 0
for _ in pairs(AutoMarkAssist_MobDB) do zoneCount = zoneCount + 1 end
local editionStr = "|cFF00CCFF" .. (lastExp and lastExp.name or "Classic") .. " Classic|r edition  --  " .. zoneCount .. " supported instances"
AboutLine(editionStr, -180, "GameFontHighlightSmall")

AboutSep(-196)

-- ── Commands ──
AboutLine("|cFF1A9EC0Common Commands|r", -212, "GameFontHighlight")
AboutCmd("open config panel",          "/ama",           -230)
AboutCmd("show full command list",     "/ama help",      -244)
AboutCmd("enable auto-marking",        "/ama enable",    -258)
AboutCmd("disable auto-marking",       "/ama disable",   -272)
AboutCmd("reset local mark tracking",  "/ama reset",     -286)
AboutCmd("toggle manual mark mode",    "/ama manual",    -300)
AboutCmd("announce legend to group",   "/ama announce",  -314)
AboutCmd("preview legend in chat",     "/ama preview",   -328)
AboutCmd("repeat dungeon CC to party", "/ama ccannounce", -342)
AboutCmd("toggle auto dungeon CC",     "/ama ccauto",    -356)
AboutCmd("open Database tab",          "/ama db",        -370)
AboutCmd("show latest update notes",   "/ama whatsnew",  -384)

AboutSep(-400, 280)

-- ── Attribution ──
AboutLine("|cFFFFD700" .. AMA.AUTHOR .. "|r  |cFF444444--|r  |cFF6AABBCGRUUL INTENTIONS|r  |cFF444444--|r  |cFF6AABBCTHUNDERSTRIKE|r", -418)

end  -- Config frame construction scope

-- ================================================================
-- REFRESH
-- Called after any DB write; keeps every widget in sync with the DB.
-- ================================================================

local function SyncAllCheckboxes()
    if not AutoMarkAssistDB then return end
    for _, ref in ipairs(checkboxRefs) do
        local box, dbKey = ref[1], ref[2]
        if box and box.SetCheckedState then
            box:SetCheckedState(not not AutoMarkAssistDB[dbKey])
        end
    end
end

-- Sync checkbox states every time the frame becomes visible so they
-- reflect the actual DB state regardless of how settings were changed.
cfgFrame:SetScript("OnShow", function()
    if ApplyResponsiveConfigLayout then ApplyResponsiveConfigLayout() end
    SyncAllCheckboxes()
    if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
end)

function AMA.RefreshConfigFrame()
    if not cfgFrame or not cfgFrame:IsShown() then return end
    local db = AutoMarkAssistDB
    if not db then return end

    if ApplyResponsiveConfigLayout then ApplyResponsiveConfigLayout() end

    SyncAllCheckboxes()

    -- Pool icon buttons (three states: active / available / owned-by-other-tier)
    local pools = db.markPools or AMA.PRIORITY_POOLS
    -- Build reverse lookup: mark -> owning tier key
    local markTierOwner = {}
    for _, tdef in ipairs(TIER_DEFS) do
        for _, mi in ipairs(pools[tdef.key] or {}) do
            markTierOwner[mi] = tdef.key
        end
    end
    for _, tdef in ipairs(TIER_DEFS) do
        local btnRow = poolBtnsMap and poolBtnsMap[tdef.key]
        if btnRow then
            for mi = 1, 8 do
                local btn = btnRow[mi]
                if btn then
                    local owner = markTierOwner[mi]
                    if owner == tdef.key then
                        -- Active in this tier
                        btn.icon:SetAlpha(1.0); btn.highlight:Show()
                        if btn._cell and btn._cell.SetBackdropBorderColor then
                            btn._cell:SetBackdropBorderColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
                        end
                    elseif owner then
                        -- Owned by another tier - unavailable
                        btn.icon:SetAlpha(0.12); btn.highlight:Hide()
                        local col = TIER_COL and TIER_COL[owner] or { E.BORDER[1], E.BORDER[2], E.BORDER[3] }
                        if btn._cell and btn._cell.SetBackdropBorderColor then
                            btn._cell:SetBackdropBorderColor(col[1], col[2], col[3], 0.5)
                        end
                    else
                        -- Not assigned to any tier - available
                        btn.icon:SetAlpha(0.30); btn.highlight:Hide()
                        if btn._cell and btn._cell.SetBackdropBorderColor then
                            btn._cell:SetBackdropBorderColor(E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
                        end
                    end
                end
            end
        end
    end

    -- Shared helper: paint a toggle button as active (teal tint) or normal.
    local function PaintBtn(btn, active)
        if not btn then return end
        if btn.SetActive then
            btn:SetActive(active)
        elseif active then
            btn:GetFontString():SetTextColor(E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
            btn._bg:SetVertexColor(E.BTN_A[1], E.BTN_A[2], E.BTN_A[3], 1)
        else
            btn:GetFontString():SetTextColor(1, 1, 1, 1)
            btn._bg:SetVertexColor(E.BTN_N[1], E.BTN_N[2], E.BTN_N[3], 1)
        end
    end

    if proxBtns then
        local pr = db.proximityRange or 4
        for ri, btn in pairs(proxBtns) do PaintBtn(btn, ri == pr) end
    end

    if ccLimitBtns then
        local cl = db.ccLimit or 0
        for cv, btn in pairs(ccLimitBtns) do PaintBtn(btn, cv == cl) end
    end

    if moRangeBtns then
        local mr = db.mouseoverRange or 4
        for ri, btn in pairs(moRangeBtns) do PaintBtn(btn, ri == mr) end
    end

    if modBtns then
        local sel = db.manualModifier or "ALT"
        for mod, btn in pairs(modBtns) do PaintBtn(btn, mod == sel) end
    end

    -- Refresh scroll-order cells (Manual Mode reorder widget).
    if scrollOrderCells then
        local order = AMA.GetManualScrollOrder and AMA.GetManualScrollOrder()
            or {8, 7, 3, 4, 5, 6, 2, 1}
        for slot = 1, 8 do
            local cell = scrollOrderCells[slot]
            if cell then
                local markIdx = order[slot]
                if markIdx then
                    cell._icon:SetTexture(
                        "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. markIdx)
                end
                cell._icon:SetAlpha(1.0)
                if cell.SetBackdropBorderColor then
                    cell:SetBackdropBorderColor(
                        E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
                end
            end
        end
    end

    if invertScrollBtn then
        invertScrollBtn:SetText(
            AMA.GetManualScrollDirectionLabel and AMA.GetManualScrollDirectionLabel()
                or "Scroll Down Starts Left")
    end

    if announceChannelBtns then
        local ch = db.announceChannel or "PARTY"
        for key, btn in pairs(announceChannelBtns) do PaintBtn(btn, key == ch) end
    end

    if announceFormatBtns then
        local lineByLine = db.announceLineByLine ~= false
        for key, btn in pairs(announceFormatBtns) do
            PaintBtn(btn, key == lineByLine)
        end
    end

    if announcePrefixEdit and not (announcePrefixEdit.HasFocus and announcePrefixEdit:HasFocus()) then
        local prefixText = (AMA.GetAnnouncementPrefixText and AMA.GetAnnouncementPrefixText())
            or (db.announcePrefixText or "")
        announcePrefixEdit:SetText(prefixText)
    end

    -- Refresh the reset-marks keybind button label.
    if resetKeyBtn then
        local FRIENDLY_NAMES = {
            BUTTON3 = "Middle Mouse", BUTTON4 = "Mouse 4", BUTTON5 = "Mouse 5",
        }
        local k = db.resetMarksKey
        if not k or k == "" then
            resetKeyBtn:SetText("(none)")
        else
            resetKeyBtn:SetText(FRIENDLY_NAMES[k] or k)
        end
    end

    -- When manual mode is active, disable automatic marking controls because
    -- they are mutually exclusive with manual scroll-wheel marking.
    local manualOn = db.manualMode and true or false
    local proximityRangeDisabled = manualOn or not db.proximityMode
    local mouseoverDisabled = manualOn or db.mouseoverMode == false
    local mouseoverRangeDisabled = mouseoverDisabled or not db.mouseoverRangeEnabled
    local repeatDungeonCCDisabled = manualOn or not db.enabled or not db.smartDungeonCC
    if cbDynamic  then cbDynamic:SetDisabled(manualOn)  end
    if cbCombatLock then cbCombatLock:SetDisabled(manualOn) end
    if cbRebal    then cbRebal:SetDisabled(manualOn)    end
    if cbSkip     then cbSkip:SetDisabled(manualOn)     end
    if cbCrit     then cbCrit:SetDisabled(manualOn)     end
    if cbProx     then cbProx:SetDisabled(manualOn)     end
    if cbMouseover then cbMouseover:SetDisabled(manualOn) end
    if cbMoRange then cbMoRange:SetDisabled(mouseoverDisabled) end
    if cbSmartDungeonCC then cbSmartDungeonCC:SetDisabled(manualOn) end
    if cbAutoDungeonCC then cbAutoDungeonCC:SetDisabled(manualOn) end
    if repeatDungeonCCBtn then repeatDungeonCCBtn:SetDisabled(repeatDungeonCCDisabled) end
    if ccLimitBtns then
        for _, btn in pairs(ccLimitBtns) do
            if btn.SetDisabled then btn:SetDisabled(manualOn) end
        end
    end
    if proxBtns then
        for _, btn in pairs(proxBtns) do
            if btn.SetDisabled then btn:SetDisabled(proximityRangeDisabled) end
        end
    end
    if moRangeBtns then
        for _, btn in pairs(moRangeBtns) do
            if btn.SetDisabled then btn:SetDisabled(mouseoverRangeDisabled) end
        end
    end

    if legendBoxes then
        local legend = db.markLegend or {}
        for mi = 1, 8 do
            if legendBoxes[mi] then legendBoxes[mi]:SetText(legend[mi] or "") end
        end
    end

    if smartCCRoleMarkBtns then
        local roleMarks = (AMA.GetSmartCCRoleMarks and AMA.GetSmartCCRoleMarks())
            or (db.smartCCRoleMarks or {})
        for classTag, buttons in pairs(smartCCRoleMarkBtns) do
            local selectedMark = roleMarks[classTag]
            for markIdx, btn in pairs(buttons) do
                local active = markIdx == selectedMark
                if btn.highlight then
                    if active then btn.highlight:Show() else btn.highlight:Hide() end
                end
                if btn.icon then
                    btn.icon:SetAlpha(active and 1.0 or 0.30)
                end
                if btn._cell and btn._cell.SetBackdropBorderColor then
                    if active then
                        btn._cell:SetBackdropBorderColor(
                            E.ACCENT[1], E.ACCENT[2], E.ACCENT[3], 1)
                    else
                        btn._cell:SetBackdropBorderColor(
                            E.BORDER[1], E.BORDER[2], E.BORDER[3], 1)
                    end
                end
            end
        end
    end

    -- Paint add-mob priority selector buttons in DB tab
    if dbAddMobPriBtns and dbAddMobPriSel then
        for pn, btn in pairs(dbAddMobPriBtns) do PaintBtn(btn, pn == dbAddMobPriSel) end
    end

    -- Keep the Database tab in sync when it is the active tab
    if currentTab == 4 and RefreshDBTab then RefreshDBTab() end
end

-- ================================================================
-- OPEN / CLOSE API
-- ================================================================

function AMA.OpenConfigFrame(tabIndex)
    if ApplyResponsiveConfigLayout then ApplyResponsiveConfigLayout() end
    cfgFrame:Show()
    ShowTab(tabIndex or currentTab)
    if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
end

-- AMA.OpenDBFrame: redirect to the embedded Database tab (tab 4) inside
-- the config frame.  The separate popup window has been retired.
function AMA.OpenDBFrame()
    AMA.OpenConfigFrame(4)
end

-- Global aliases for macro and external-addon compatibility.
AutoMarkAssist_OpenConfig = function() AMA.OpenConfigFrame() end
AutoMarkAssist_OpenDB     = function() AMA.OpenDBFrame()     end
