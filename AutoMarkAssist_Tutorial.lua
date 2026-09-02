-- AutoMarkAssist_Tutorial.lua
-- In-game guided walkthrough overlay and Tutorial options tab.
-- Loaded after AutoMarkAssist_DBTab.lua, before AutoMarkAssist_Config.lua.

local AMA = AutoMarkAssist

-- ============================================================
-- SHARED SKIN
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
local BG     = { 0.06, 0.06, 0.06, 0.97 }
local BG2    = { 0.04, 0.04, 0.04, 0.98 }
local BTN_N  = { 0.12, 0.12, 0.12, 1.00 }
local BTN_H  = { 0.22, 0.22, 0.22, 1.00 }
local BTN_P  = { 0.07, 0.07, 0.07, 1.00 }
local BTN_A  = { 0.08, 0.25, 0.30, 1.00 }

local function Skin(f)
    if not f.SetBackdrop then return end
    f:SetBackdrop(FLAT_BD)
    f:SetBackdropColor(BG[1], BG[2], BG[3], BG[4])
    f:SetBackdropBorderColor(BORDER[1], BORDER[2], BORDER[3], 1)
end

local function MakeBtn(parent, text, w, h)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(w or 90, h or 22)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(W8)
    bg:SetAllPoints()
    bg:SetVertexColor(BTN_N[1], BTN_N[2], BTN_N[3], 1)
    btn._bg = bg
    if BackdropTemplateMixin then
        local bd = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        bd:SetAllPoints()
        bd:SetFrameLevel(btn:GetFrameLevel())
        bd:SetBackdrop({
            bgFile = nil, edgeFile = W8, tile = false, edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        bd:SetBackdropBorderColor(BORDER[1], BORDER[2], BORDER[3], 1)
        btn._bd = bd
    end
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("CENTER")
    fs:SetText(text or "")
    fs:SetTextColor(1, 1, 1, 1)
    btn:SetFontString(fs)
    btn._fs = fs
    btn._active = false

    local function Apply(state)
        if btn._active then
            fs:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
        else
            fs:SetTextColor(1, 1, 1, 1)
        end
        if state == "down" then
            bg:SetVertexColor(BTN_P[1], BTN_P[2], BTN_P[3], 1)
        elseif state == "hover" and not btn._active then
            bg:SetVertexColor(BTN_H[1], BTN_H[2], BTN_H[3], 1)
        elseif btn._active then
            bg:SetVertexColor(BTN_A[1], BTN_A[2], BTN_A[3], 1)
        else
            bg:SetVertexColor(BTN_N[1], BTN_N[2], BTN_N[3], 1)
        end
    end

    btn:SetScript("OnEnter", function() Apply("hover") end)
    btn:SetScript("OnLeave", function() Apply("normal") end)
    btn:SetScript("OnMouseDown", function() Apply("down") end)
    btn:SetScript("OnMouseUp", function() Apply("hover") end)
    btn.SetActive = function(_, active)
        btn._active = active and true or false
        Apply("normal")
    end
    return btn
end

-- ============================================================
-- TUTORIAL CONTENT
-- ============================================================

-- Guided overlay: short, sequential, first-run friendly.
local GUIDE_STEPS = {
    {
        title = "Welcome to AutoMarkAssist",
        body = "This addon marks dungeon and raid packs for you. It scores every visible mob, then assigns kill and crowd-control icons in priority order so the group always has a clear Skull.\n\nThis short walkthrough covers how it works. You can replay it any time with /ama tutorial, or read the full reference on the Tutorial tab in options.",
    },
    {
        title = "The mark key",
        body = "Skull and Cross are always kill targets. The other six icons are crowd control, and only light up when that class is in your group.",
        marks = {
            { 8, "Skull", "First kill" },
            { 7, "Cross", "Second kill" },
            { 5, "Moon", "Polymorph (Mage) / Repentance (Paladin)" },
            { 3, "Diamond", "Sap (Rogue)" },
            { 4, "Triangle", "Banish (Warlock)" },
            { 1, "Star", "Shackle (Priest)" },
            { 2, "Circle", "Hibernate (Druid)" },
            { 6, "Square", "Trap (Hunter)" },
        },
    },
    {
        title = "Pick a marking mode",
        body = "Only one mode is active at a time. Switch them in options (/ama) or with /ama mode <name>.\n\nProximity (default) — scans hostiles in range every 0.5s and marks the whole pack automatically. Best for tanks.\n\nMouseover — marks the mob under your cursor, still using the same kill/CC priority so a filler mob does not steal Skull.\n\nManual — hold a modifier (or NONE) and scroll the mouse wheel over a target to pick an icon yourself. Inside instances those choices are saved for later auto-marking.",
    },
    {
        title = "How a pack is marked",
        body = "On each scan the addon:\n\n1. Collects visible hostile mobs in range.\n2. Scores them by database preference, danger (healers and summoners first), elite status, and a small bonus for your current target.\n3. Sorts the pack highest to lowest.\n4. Allocates icons in order.\n\nNormal dungeons: database preference → Skull → Cross → CC.\nHeroic dungeons: database preference → Skull → CC → Cross, so dangerous mobs get locked down before the second kill icon is spent.\n\nCC-immune mobs never receive a CC icon.",
    },
    {
        title = "Crowd control follows the group",
        body = "The addon reads the roster and only uses CC icons for classes that are actually present:\n\n• Mage → Polymorph on Humanoid, Beast, Critter\n• Rogue → Sap on Humanoid\n• Warlock → Banish on Demon, Elemental\n• Priest → Shackle on Undead\n• Druid → Hibernate on Beast, Dragonkin\n• Hunter → Trap on most types except Elemental\n• Paladin (TBC+) → Repentance, sharing Moon with Mage\n\nWhen two classes can hit the same creature type, the more specific ability wins (Sap beats Polymorph beats Trap).\n\nTwo of the same class get two CC targets: the first keeps the usual icon, extras borrow a spare icon from a CC class that is not in the group.",
    },
    {
        title = "Deaths, resets, and combat",
        body = "When a marked mob dies, icons cascade. Skull dying promotes Cross to Skull, then the highest-scoring surviving CC target can promote to Cross. A mob still locked down with more than 3 seconds of CC left is not promoted, so the group does not break a fresh sheep.\n\n/ama reset (or your Clear All Marks keybind) wipes all eight icons and the addon's tracking, so the next scan starts clean.\n\nAuto-Reset After Combat only clears marks this addon placed. Lock Marks in Combat pauses auto changes until the fight ends.",
    },
    {
        title = "The Database tab",
        body = "Every Classic-through-MoP dungeon and raid ships with preferred marks, creature types, danger ratings, and CC-immunity flags.\n\nOpen the Database tab to browse any zone, left-click a mob to cycle its mark (including SKIP), and right-click to clear your override. Hover a row to read the full NPC name.\n\nThe database also learns as you play: missing creature types are captured live, CC spells that hit IMMUNE flag that mob forever, and Manual-mode marks inside an instance are saved as your preference.",
    },
    {
        title = "Talking to the group",
        body = "On dungeon entry (and when you enable the addon mid-party) AutoMarkAssist can post the mark plan to chat so everyone knows Skull, Cross, and who is on which CC.\n\nUse Announce Now or /ama announce to send it again, and Preview to see it only in your chat.\n\nSilent Mode blocks every party/raid/say announcement. You still need raid-marker permission (anyone in a party; raid leader or assistant in a raid) or the addon cannot place icons.",
    },
    {
        title = "Controls and commands",
        body = "Minimap button: left-click toggles marking on/off (green = on, red = off, gold = manual). Right-click opens options.\n\nType /ama for options. Useful commands:\n\n/ama tutorial — this walkthrough\n/ama enable | disable | toggle\n/ama mode proximity | mouseover | manual\n/ama reset — clear all marks\n/ama mark skull (or cross, moon, …) — stamp your target\n/ama announce | preview | cc | help\n\nDrag the grip in the bottom-right of the options window to resize it. The size is remembered.",
    },
    {
        title = "You're ready",
        body = "Default setup is already the recommended one: Proximity mode, long range, all CC icons enabled, announce on dungeon entry.\n\nQueue a dungeon, stay in range of the pack, and Skull will land on the most dangerous mob. Open the Tutorial tab any time for the full reference, or run /ama tutorial to replay this walkthrough.\n\nRetail is not supported. If Blizzard will not let your character place raid icons, the addon cannot mark.",
        last = true,
    },
}

-- Full reference chapters for the Tutorial options tab.
local CHAPTERS = {
    {
        id = "start",
        title = "Getting started",
        blocks = {
            { kind = "p", text = "AutoMarkAssist is a Classic-era dungeon and raid marker. It evaluates the whole visible pack, scores every mob, and assigns kill and crowd-control icons in priority order. When high-value targets die, marks cascade so the group always has a Skull." },
            { kind = "p", text = "Install, enable the addon, and type /ama (or right-click the minimap Skull) to open options. Marking is on by default in Proximity mode. You do not need to configure anything before your first dungeon." },
            { kind = "h", text = "First five minutes" },
            { kind = "bullet", text = "Confirm the minimap button is green (marking enabled). Left-click toggles it." },
            { kind = "bullet", text = "Stay in party — anyone can mark in a 5-man. In a raid you must be leader or assistant." },
            { kind = "bullet", text = "Pull. Proximity scans every 0.5s and places Skull, Cross, and any matching CC." },
            { kind = "bullet", text = "On a wipe or a messy pack, /ama reset (or your Clear All Marks keybind) wipes all eight icons." },
            { kind = "bullet", text = "Replay this guided tour any time with /ama tutorial." },
        },
    },
    {
        id = "marks",
        title = "The mark key",
        blocks = {
            { kind = "p", text = "Skull and Cross are always kill targets and cannot be turned off. CC icons can be toggled on the General tab; a disabled CC class will never be assigned." },
            { kind = "mark", idx = 8, name = "Skull", role = "First kill. Highest-scoring mob in the pack." },
            { kind = "mark", idx = 7, name = "Cross", role = "Second kill. Promotes to Skull when Skull dies." },
            { kind = "mark", idx = 5, name = "Moon", role = "Polymorph (Mage). Paladin Repentance shares this icon on TBC+; Mage keeps Moon when both are present." },
            { kind = "mark", idx = 3, name = "Diamond", role = "Sap (Rogue) — Humanoid only." },
            { kind = "mark", idx = 4, name = "Triangle", role = "Banish (Warlock) — Demon and Elemental." },
            { kind = "mark", idx = 1, name = "Star", role = "Shackle (Priest) — Undead." },
            { kind = "mark", idx = 2, name = "Circle", role = "Hibernate (Druid) — Beast and Dragonkin." },
            { kind = "mark", idx = 6, name = "Square", role = "Trap (Hunter) — Humanoid, Beast, Demon, Dragonkin, Giant, Undead." },
        },
    },
    {
        id = "modes",
        title = "Marking modes",
        blocks = {
            { kind = "p", text = "Exactly one mode is active. Switching modes does not clear existing marks." },
            { kind = "h", text = "Proximity (default)" },
            { kind = "p", text = "Automatic. Every 0.5 seconds the addon scans hostile mobs in the selected range (~10 yd short or ~28 yd long), scores the whole pack, and assigns marks. This is the set-and-forget tank mode." },
            { kind = "h", text = "Mouseover" },
            { kind = "p", text = "Marks the unit under your cursor. Range can be short, long, or unlimited. The hovered mob is allocated with the normal priority (database preference, then Skull / Cross / CC) so a filler mob does not steal Skull just because you hovered it first." },
            { kind = "h", text = "Manual" },
            { kind = "p", text = "No automatic logic. Hold the configured modifier (ALT / SHIFT / CTRL, or NONE) and scroll over a hostile to open the mark picker HUD. Invert Scroll Direction lives on the General tab. Inside an instance, each manual assignment is written to your personal database so Proximity/Mouseover will reuse it later." },
            { kind = "p", text = "Slash: /ama mode proximity | mouseover | manual. /ama manual toggles Manual against Proximity." },
        },
    },
    {
        id = "scan",
        title = "How packs are scored",
        blocks = {
            { kind = "p", text = "Proximity and Mouseover both evaluate the pack as a whole before any icon is placed. The result is stable, repeatable marking rather than first-come-first-served." },
            { kind = "h", text = "Scoring" },
            { kind = "bullet", text = "Database kill preference and dangerLevel: Critical (healers, summoners, callers) outrank High (AoE / fear / kick targets) outrank Normal." },
            { kind = "bullet", text = "SKIP entries are never marked (trivial swarms, event-only adds, de-aggroing slaves)." },
            { kind = "bullet", text = "Your current target gets a tie-break bonus so Skull prefers whatever the tank is already on, without jumping on every tab-target." },
            { kind = "bullet", text = "Mind-controlled friendlies and player-controlled units are ignored." },
            { kind = "h", text = "Allocation order" },
            { kind = "p", text = "Normal dungeon: database preference → Skull → Cross → CC matching creature type and group composition." },
            { kind = "p", text = "Heroic dungeon (and MoP Challenge Mode): database preference → Skull → CC → Cross, so lock-downs are placed before the second kill icon." },
            { kind = "p", text = "A mob flagged ccImmune, or learned as immune from the combat log, never receives a CC icon." },
        },
    },
    {
        id = "cc",
        title = "Crowd control",
        blocks = {
            { kind = "p", text = "CC icons activate only when that class is in the group, the icon is enabled, the mob's creature type matches, and the mob is not CC-immune." },
            { kind = "h", text = "Specificity" },
            { kind = "p", text = "When several CC classes can handle the same creature, the narrowest ability wins. Sap (Humanoid only) beats Polymorph (Humanoid / Beast / Critter) beats Trap (six types). Banish and Shackle only contest their own types." },
            { kind = "h", text = "Stacked classes" },
            { kind = "p", text = "Two Mages get two Polymorph targets, two Warlocks two Banishes, and so on. Each class claims its usual icon first. Every extra caster borrows a spare icon that belongs to a CC class who is not in the group and whose icon is still enabled. /ama cc, Preview, and the announced mark plan list every caster with the icon they were actually given. Extra casters beyond the six CC icons are left unmarked." },
            { kind = "h", text = "Paladin Repentance (TBC+)" },
            { kind = "p", text = "Moon is shared with Mage. If both are present, Mage keeps Moon. A Paladin in a Mage-less group gets Moon for Repentance against Humanoid, Demon, Dragonkin, Giant, and Undead. If Moon is already taken, the Paladin borrows a spare like any other extra caster." },
        },
    },
    {
        id = "cascade",
        title = "Cascade, reset, and lock",
        blocks = {
            { kind = "p", text = "When a locally-marked mob dies and Rebalance Marks on Death is on, the addon promotes remaining targets:" },
            { kind = "bullet", text = "Skull dies → Cross promotes to Skull." },
            { kind = "bullet", text = "Cross empty → highest-scoring living CC-marked mob promotes to Cross, unless it still has more than 3 seconds of CC remaining." },
            { kind = "h", text = "Reset" },
            { kind = "p", text = "/ama reset and the Clear All Marks keybind steal every raid icon (even ones you cannot see) by bouncing them through the player, then wipe tracking so the next scan starts from scratch. Mouse buttons cannot be bound to reset." },
            { kind = "p", text = "Auto-Reset After Combat is gentler: it only clears marks this addon placed, leaving icons another player set on the next pack." },
            { kind = "h", text = "Combat lock" },
            { kind = "p", text = "Lock Marks in Combat freezes auto assignment and cascade until you leave combat. Use it if you want icons glued for the whole pull." },
        },
    },
    {
        id = "db",
        title = "Database and learning",
        blocks = {
            { kind = "p", text = "Built-in data covers Classic, TBC, Wrath, Cataclysm, and Mists dungeons and raids. Each entry can store a preferred mark, creature type, ccImmune flag, and dangerLevel." },
            { kind = "p", text = "The Database tab is a zone browser grouped by expansion → Dungeons / Raids. You do not need to be inside the instance to edit it. Left-click cycles the mark (Skull through Square, then none, then SKIP). Right-click removes your override. Tick Edit next to Type to cycle creature types. Hover a truncated name for a tooltip." },
            { kind = "h", text = "Self-learning" },
            { kind = "bullet", text = "Missing creature types are read from the live unit and stored in your personal overlay." },
            { kind = "bullet", text = "A tracked CC spell resisted as IMMUNE permanently flags that NPC as ccImmune (player targets are ignored so PvP names never enter the DB)." },
            { kind = "bullet", text = "Manual marks inside an instance are saved and used the next time auto-marking runs that zone." },
            { kind = "p", text = "Your mobMarks table always wins over the shipped database. Danger ratings from the shipped data are preserved when you only override the icon." },
        },
    },
    {
        id = "announce",
        title = "Announcements",
        blocks = {
            { kind = "p", text = "Announce Mark Plan on Dungeon Entry posts Skull, Cross, and every assigned CC caster (with the icon they actually received) to the configured channel after you zone in. Enabling the addon while already in a formed group also announces, so a leader who turns it on after entering still shares the key." },
            { kind = "p", text = "Announcements fire when the roster grows or the zone changes, not when someone leaves — that used to spam the remaining party at the end of a run." },
            { kind = "bullet", text = "Channel: SAY, PARTY, or RAID (PARTY/RAID fall back to whatever group you are actually in)." },
            { kind = "bullet", text = "Prefix is customisable and saves when the box loses focus. Leave it blank for no prefix." },
            { kind = "bullet", text = "Silent Mode suppresses every outgoing announcement, including Announce Now." },
            { kind = "bullet", text = "/ama announce sends immediately (respects Silent Mode unless you use the Options button, which is treated as a manual send). /ama preview prints locally." },
            { kind = "p", text = "If you cannot place raid icons, announcements are blocked so chat never implies marks that did not happen." },
        },
    },
    {
        id = "commands",
        title = "Commands and UI",
        blocks = {
            { kind = "p", text = "/ama or /automarkassist opens options. Other commands:" },
            { kind = "bullet", text = "/ama tutorial — guided walkthrough overlay (this tour)." },
            { kind = "bullet", text = "/ama enable | disable | toggle — master switch." },
            { kind = "bullet", text = "/ama mode proximity | mouseover | manual" },
            { kind = "bullet", text = "/ama reset or /ama clear — wipe all eight icons." },
            { kind = "bullet", text = "/ama mark <skull|cross|moon|diamond|triangle|square|star|circle|0> — stamp current target. Aliases: /ama skull, /ama cross, /ama unmark." },
            { kind = "bullet", text = "/ama announce | preview | cc | marks | zone" },
            { kind = "bullet", text = "/ama verbose | lock | show | hide | defaults | help" },
            { kind = "h", text = "Minimap" },
            { kind = "p", text = "Left-click toggles enabled. Right-click opens options. Drag to reposition. Green = on, red = off, gold = manual. /ama hide removes the button; /ama show restores it." },
            { kind = "h", text = "Options window" },
            { kind = "p", text = "Drag the title to move. Drag the bottom-right grip to resize; width and height are saved. The Database name column grows with the window." },
        },
    },
    {
        id = "tips",
        title = "Tips and limits",
        blocks = {
            { kind = "bullet", text = "Retail is not supported. Classic Era, TBC, Wrath, Cata, and MoP Classic are." },
            { kind = "bullet", text = "Nameplates help Proximity find nearby hostiles, especially on clients where CheckInteractDistance returns nothing for enemies." },
            { kind = "bullet", text = "Skip Critters keeps pigeons and similar trash unmarked." },
            { kind = "bullet", text = "If Skull is on the wrong mob, target the one you want before the first scan, or /ama skull to override without leaving auto mode." },
            { kind = "bullet", text = "Disable unused CC icons on the General tab if you never want Trap or Hibernate in the plan." },
            { kind = "bullet", text = "The addon never places icons when Blizzard denies raid-marker permission." },
            { kind = "bullet", text = "Verbose Mode prints debug lines to chat; leave it off unless you are diagnosing a pack." },
            { kind = "p", text = "Source and issues: github.com/Swatto86/AutoMarkAssist" },
        },
    },
}

-- ============================================================
-- GUIDED OVERLAY
-- ============================================================

local guideFrame
local guideIndex = 1
local pendingFirstRun

local function MarkTutorialCompleted()
    if AutoMarkAssistDB then
        AutoMarkAssistDB.tutorialCompleted = true
    end
end

local function HideGuide()
    if guideFrame then guideFrame:Hide() end
end

local function LayoutGuide()
    if not guideFrame then return end
    local step = GUIDE_STEPS[guideIndex]
    if not step then return end

    guideFrame._title:SetText(step.title)
    guideFrame._body:SetText(step.body)
    guideFrame._progress:SetText(string.format("%d / %d", guideIndex, #GUIDE_STEPS))

    local bodyH = guideFrame._body:GetStringHeight() or 80
    local contentW = guideFrame._scrollChild and guideFrame._scrollChild:GetWidth() or 480
    if contentW < 80 then contentW = 480 end
    guideFrame._body:SetWidth(contentW)

    -- Mark rows (only on the mark-key step).
    local marks = step.marks
    local y = -8
    for i, row in ipairs(guideFrame._markRows) do
        local info = marks and marks[i]
        if info then
            row:Show()
            row._icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. info[1])
            row._fs:SetText(string.format("|cFFFFFFFF%s|r  |cFFAAAAAA%s|r", info[2], info[3]))
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", guideFrame._markHost, "TOPLEFT", 0, y)
            row:SetPoint("TOPRIGHT", guideFrame._markHost, "TOPRIGHT", 0, y)
            y = y - 20
        else
            row:Hide()
        end
    end

    local markH = 1
    if marks then
        markH = -y
        guideFrame._markHost:SetHeight(markH)
        guideFrame._markHost:Show()
        guideFrame._markHost:ClearAllPoints()
        guideFrame._markHost:SetPoint("TOPLEFT", guideFrame._body, "BOTTOMLEFT", 0, -10)
        guideFrame._markHost:SetPoint("TOPRIGHT", guideFrame._body, "BOTTOMRIGHT", 0, -10)
    else
        guideFrame._markHost:SetHeight(1)
        guideFrame._markHost:Hide()
    end

    local contentH = 4 + bodyH
    if marks then
        contentH = contentH + 10 + markH
    end
    if guideFrame._scrollChild then
        guideFrame._scrollChild:SetHeight(math.max(1, contentH + 8))
    end
    if guideFrame._scroll then
        guideFrame._scroll:SetVerticalScroll(0)
    end

    guideFrame._back:SetDisabled(guideIndex <= 1)
    if step.last then
        guideFrame._next:SetText("Finish")
    else
        guideFrame._next:SetText("Next")
    end
end

local function BuildGuideFrame()
    if guideFrame then return guideFrame end

    local overlay = CreateFrame("Frame", "AutoMarkAssistTutorialGuide", UIParent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    overlay:SetAllPoints(UIParent)
    overlay:SetFrameStrata("FULLSCREEN_DIALOG")
    overlay:SetFrameLevel(200)
    overlay:EnableMouse(true)
    overlay:EnableMouseWheel(true)
    overlay:Hide()
    if overlay.SetBackdrop then
        overlay:SetBackdrop({ bgFile = W8 })
        overlay:SetBackdropColor(0, 0, 0, 0.55)
    else
        local dim = overlay:CreateTexture(nil, "BACKGROUND")
        dim:SetAllPoints()
        dim:SetTexture(W8)
        dim:SetVertexColor(0, 0, 0, 0.55)
    end

    local card = CreateFrame("Frame", nil, overlay,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    card:SetSize(520, 520)
    card:SetPoint("CENTER", overlay, "CENTER", 0, 20)
    Skin(card)

    local accent = card:CreateTexture(nil, "ARTWORK")
    accent:SetTexture(W8)
    accent:SetHeight(2)
    accent:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
    accent:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, 0)
    accent:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)

    local kicker = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    kicker:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -14)
    kicker:SetText("|cFF1A9EC0AutoMarkAssist|r  tutorial")

    local progress = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    progress:SetPoint("TOPRIGHT", card, "TOPRIGHT", -40, -14)
    progress:SetTextColor(0.6, 0.6, 0.6, 1)

    local close = CreateFrame("Button", nil, card)
    close:SetSize(16, 16)
    close:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -10)
    local cFS = close:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cFS:SetPoint("CENTER", close, "CENTER", 0, 1)
    cFS:SetText("X")
    cFS:SetTextColor(0.55, 0.55, 0.55, 1)
    close:SetScript("OnEnter", function() cFS:SetTextColor(1, 1, 1, 1) end)
    close:SetScript("OnLeave", function() cFS:SetTextColor(0.55, 0.55, 0.55, 1) end)
    close:SetScript("OnClick", function()
        MarkTutorialCompleted()
        HideGuide()
    end)

    local title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -40)
    title:SetPoint("TOPRIGHT", card, "TOPRIGHT", -16, -40)
    title:SetJustifyH("LEFT")
    title:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)

    local footer = CreateFrame("Frame", nil, card)
    footer:SetHeight(36)
    footer:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 12, 10)
    footer:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -12, 10)

    local scroll = CreateFrame("ScrollFrame", nil, card)
    scroll:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    scroll:SetPoint("BOTTOMRIGHT", footer, "TOPRIGHT", -4, 8)
    scroll:EnableMouseWheel(true)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
    child:SetWidth(480)
    scroll:SetScrollChild(child)

    scroll:SetScript("OnMouseWheel", function(self, delta)
        local max = self:GetVerticalScrollRange() or 0
        local pos = (self:GetVerticalScroll() or 0) - delta * 36
        if pos < 0 then pos = 0 end
        if pos > max then pos = max end
        self:SetVerticalScroll(pos)
    end)
    overlay:SetScript("OnMouseWheel", function(_, delta)
        local handler = scroll:GetScript("OnMouseWheel")
        if handler then handler(scroll, delta) end
    end)

    local body = child:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
    body:SetPoint("TOPRIGHT", child, "TOPRIGHT", 0, 0)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetSpacing(3)
    if body.SetWordWrap then body:SetWordWrap(true) end
    if body.SetNonSpaceWrap then body:SetNonSpaceWrap(true) end

    local markHost = CreateFrame("Frame", nil, child)
    markHost:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 0, -10)
    markHost:SetPoint("TOPRIGHT", body, "BOTTOMRIGHT", 0, -10)
    markHost:SetHeight(1)

    local markRows = {}
    for i = 1, 8 do
        local row = CreateFrame("Frame", nil, markHost)
        row:SetHeight(18)
        local ic = row:CreateTexture(nil, "ARTWORK")
        ic:SetSize(14, 14)
        ic:SetPoint("LEFT", row, "LEFT", 0, 0)
        local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("LEFT", ic, "RIGHT", 8, 0)
        fs:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        fs:SetJustifyH("LEFT")
        row._icon = ic
        row._fs = fs
        markRows[i] = row
    end

    local skip = MakeBtn(footer, "Skip", 70, 24)
    skip:SetPoint("LEFT", footer, "LEFT", 0, 0)
    skip:SetScript("OnClick", function()
        MarkTutorialCompleted()
        HideGuide()
        AMA.Print("Tutorial skipped. Open it any time with |cFFAAAAAA/ama tutorial|r or the Tutorial tab.")
    end)

    local tabBtn = MakeBtn(footer, "Open Tutorial tab", 130, 24)
    tabBtn:SetPoint("LEFT", skip, "RIGHT", 8, 0)
    tabBtn:SetScript("OnClick", function()
        MarkTutorialCompleted()
        HideGuide()
        if AMA.OpenConfigFrame then AMA.OpenConfigFrame(3) end
    end)

    local nextBtn = MakeBtn(footer, "Next", 80, 24)
    nextBtn:SetPoint("RIGHT", footer, "RIGHT", 0, 0)
    nextBtn:SetScript("OnClick", function()
        if guideIndex >= #GUIDE_STEPS then
            MarkTutorialCompleted()
            HideGuide()
            AMA.Print("Tutorial complete. Type |cFFAAAAAA/ama|r for options, or |cFFAAAAAA/ama tutorial|r to replay.")
            return
        end
        guideIndex = guideIndex + 1
        LayoutGuide()
    end)
    nextBtn.SetDisabled = function(_, disabled)
        nextBtn:EnableMouse(not disabled)
        if disabled then
            nextBtn._fs:SetTextColor(0.4, 0.4, 0.4, 1)
        end
    end

    local back = MakeBtn(footer, "Back", 70, 24)
    back:SetPoint("RIGHT", nextBtn, "LEFT", -8, 0)
    back:SetScript("OnClick", function()
        if guideIndex > 1 then
            guideIndex = guideIndex - 1
            LayoutGuide()
        end
    end)
    back.SetDisabled = function(_, disabled)
        back:EnableMouse(not disabled)
        if disabled then
            back._fs:SetTextColor(0.4, 0.4, 0.4, 1)
            back._bg:SetVertexColor(BTN_N[1], BTN_N[2], BTN_N[3], 0.5)
        else
            back._fs:SetTextColor(1, 1, 1, 1)
            back._bg:SetVertexColor(BTN_N[1], BTN_N[2], BTN_N[3], 1)
        end
    end

    -- Keep the card readable on small UI scales and size the scroll child.
    overlay:SetScript("OnShow", function()
        local uiH = (UIParent and UIParent:GetHeight()) or 800
        local scale = math.max(0.7, math.min(1, (uiH - 80) / 560))
        card:SetScale(scale)
        local w = scroll:GetWidth()
        if w and w > 50 then child:SetWidth(w) end
        LayoutGuide()
    end)
    scroll:SetScript("OnSizeChanged", function(self, w)
        if w and w > 50 then child:SetWidth(w) end
    end)

    overlay._title = title
    overlay._body = body
    overlay._progress = progress
    overlay._markHost = markHost
    overlay._markRows = markRows
    overlay._next = nextBtn
    overlay._back = back
    overlay._card = card
    overlay._scroll = scroll
    overlay._scrollChild = child

    -- Escape closes and counts as completed so it does not re-popup every login.
    overlay:EnableKeyboard(true)
    overlay:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            MarkTutorialCompleted()
            HideGuide()
            if self.SetPropagateKeyboardInput then
                self:SetPropagateKeyboardInput(false)
            end
            return
        end
        if self.SetPropagateKeyboardInput then
            self:SetPropagateKeyboardInput(true)
        end
    end)

    guideFrame = overlay
    return overlay
end

function AMA.ShowTutorialGuide(startIndex)
    guideIndex = tonumber(startIndex) or 1
    if guideIndex < 1 then guideIndex = 1 end
    if guideIndex > #GUIDE_STEPS then guideIndex = #GUIDE_STEPS end
    BuildGuideFrame()
    LayoutGuide()
    guideFrame:Show()
end

function AMA.HideTutorialGuide()
    HideGuide()
end

function AMA.IsTutorialGuideShown()
    return guideFrame and guideFrame:IsShown()
end

-- First login (or first login after this feature shipped): show the guide
-- once, but never in combat.  If the player is fighting, wait until regen.
function AMA.MaybeShowFirstRunTutorial()
    if not AutoMarkAssistDB then return end
    if AutoMarkAssistDB.tutorialCompleted then return end
    if AMA.IsTutorialGuideShown and AMA.IsTutorialGuideShown() then return end
    if pendingFirstRun then return end
    pendingFirstRun = true

    local function tryShow()
        if AutoMarkAssistDB and AutoMarkAssistDB.tutorialCompleted then
            pendingFirstRun = false
            return
        end
        if InCombatLockdown and InCombatLockdown() then
            if C_Timer and C_Timer.After then
                C_Timer.After(1.5, tryShow)
            end
            return
        end
        pendingFirstRun = false
        AMA.ShowTutorialGuide(1)
        AMA.Print("First-run tutorial opened. Skip it any time, or replay with |cFFAAAAAA/ama tutorial|r.")
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(2.0, tryShow)
    else
        tryShow()
    end
end

-- ============================================================
-- TUTORIAL OPTIONS TAB
-- ============================================================

local tabState = {
    selected = 1,
    navBtns = {},
    blockPool = {},
}

local function GetBlock(parent, index)
    local block = tabState.blockPool[index]
    if block then return block end

    block = CreateFrame("Frame", nil, parent)
    block:SetHeight(20)

    local header = block:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    header:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", block, "TOPRIGHT", 0, 0)
    header:SetJustifyH("LEFT")
    header:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    block._header = header

    local body = block:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    body:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
    body:SetPoint("TOPRIGHT", block, "TOPRIGHT", 0, 0)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetSpacing(2)
    if body.SetWordWrap then body:SetWordWrap(true) end
    block._body = body

    local icon = block:CreateTexture(nil, "ARTWORK")
    icon:SetSize(14, 14)
    icon:SetPoint("TOPLEFT", block, "TOPLEFT", 0, -1)
    block._icon = icon

    tabState.blockPool[index] = block
    return block
end

local function RenderChapter(scrollChild, width)
    local chapter = CHAPTERS[tabState.selected]
    if not chapter or not scrollChild then return end

    for _, block in ipairs(tabState.blockPool) do
        block:Hide()
        block._header:SetText("")
        block._body:SetText("")
        block._icon:Hide()
    end

    local y = -4
    local innerW = math.max(120, width - 8)
    for i, spec in ipairs(chapter.blocks) do
        local block = GetBlock(scrollChild, i)
        block:ClearAllPoints()
        block:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 4, y)
        block:SetWidth(innerW)
        block._header:Hide()
        block._body:Hide()
        block._icon:Hide()

        local height = 16
        if spec.kind == "h" then
            block._header:SetWidth(innerW)
            block._header:SetText(spec.text)
            block._header:Show()
            height = (block._header:GetStringHeight() or 14) + 8
        elseif spec.kind == "mark" then
            block._icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. spec.idx)
            block._icon:Show()
            block._body:ClearAllPoints()
            block._body:SetPoint("TOPLEFT", block, "TOPLEFT", 20, 0)
            block._body:SetPoint("TOPRIGHT", block, "TOPRIGHT", 0, 0)
            block._body:SetWidth(innerW - 20)
            block._body:SetText(string.format("|cFFFFFFFF%s|r  %s", spec.name, spec.role))
            block._body:Show()
            height = math.max(18, (block._body:GetStringHeight() or 14) + 6)
        elseif spec.kind == "bullet" then
            block._body:ClearAllPoints()
            block._body:SetPoint("TOPLEFT", block, "TOPLEFT", 10, 0)
            block._body:SetPoint("TOPRIGHT", block, "TOPRIGHT", 0, 0)
            block._body:SetWidth(innerW - 10)
            block._body:SetText("|cFF1A9EC0•|r  " .. spec.text)
            block._body:Show()
            height = (block._body:GetStringHeight() or 14) + 6
        else
            block._body:ClearAllPoints()
            block._body:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
            block._body:SetPoint("TOPRIGHT", block, "TOPRIGHT", 0, 0)
            block._body:SetWidth(innerW)
            block._body:SetText(spec.text)
            block._body:Show()
            height = (block._body:GetStringHeight() or 14) + 10
        end

        block:SetHeight(height)
        block:Show()
        y = y - height
    end

    local contentH = math.max(1, -y + 12)
    scrollChild:SetHeight(contentH)
end

function AMA.BuildTutorialTab(parent)
    if not parent then return end

    local replay = MakeBtn(parent, "Replay walkthrough", 140, 22)
    replay:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -6)
    replay:SetScript("OnClick", function()
        AMA.ShowTutorialGuide(1)
    end)

    local hint = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("LEFT", replay, "RIGHT", 10, 0)
    hint:SetText("or type /ama tutorial")

    local nav = CreateFrame("Frame", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    nav:SetWidth(150)
    nav:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -32)
    nav:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 4, 4)
    Skin(nav)
    if nav.SetBackdropColor then
        nav:SetBackdropColor(BG2[1], BG2[2], BG2[3], 1)
    end

    for i, chapter in ipairs(CHAPTERS) do
        local btn = MakeBtn(nav, chapter.title, 142, 20)
        btn:SetPoint("TOPLEFT", nav, "TOPLEFT", 4, -6 - (i - 1) * 22)
        btn:SetScript("OnClick", function()
            tabState.selected = i
            if AMA._RefreshTutorialTab then AMA._RefreshTutorialTab() end
        end)
        tabState.navBtns[i] = btn
    end

    local bodyWrap = CreateFrame("Frame", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    bodyWrap:SetPoint("TOPLEFT", nav, "TOPRIGHT", 6, 0)
    bodyWrap:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -4, 4)
    Skin(bodyWrap)

    local scroll = CreateFrame("ScrollFrame", "AMA_TutorialScroll", bodyWrap)
    scroll:SetPoint("TOPLEFT", bodyWrap, "TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", bodyWrap, "BOTTOMRIGHT", -18, 6)
    scroll:EnableMouseWheel(true)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
    child:SetWidth(1)
    scroll:SetScrollChild(child)

    local bar = CreateFrame("Slider", nil, bodyWrap,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    bar:SetWidth(10)
    bar:SetPoint("TOPRIGHT", bodyWrap, "TOPRIGHT", -4, -6)
    bar:SetPoint("BOTTOMRIGHT", bodyWrap, "BOTTOMRIGHT", -4, 6)
    bar:SetOrientation("VERTICAL")
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    Skin(bar)
    local thumb = bar:CreateTexture(nil, "OVERLAY")
    thumb:SetTexture(W8)
    thumb:SetSize(8, 24)
    thumb:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.9)
    bar:SetThumbTexture(thumb)

    local function ClampScroll(val)
        local max = scroll:GetVerticalScrollRange() or 0
        if max < 0 then max = 0 end
        if val < 0 then val = 0 end
        if val > max then val = max end
        scroll:SetVerticalScroll(val)
        bar:SetMinMaxValues(0, max > 0 and max or 1)
        bar:SetValue(val)
        if max <= 0 then bar:Hide() else bar:Show() end
    end

    scroll:SetScript("OnMouseWheel", function(_, delta)
        ClampScroll((scroll:GetVerticalScroll() or 0) - delta * 36)
    end)
    bar:SetScript("OnValueChanged", function(_, value)
        scroll:SetVerticalScroll(value)
    end)

    local function Refresh()
        for i, btn in ipairs(tabState.navBtns) do
            btn:SetActive(i == tabState.selected)
        end
        local w = scroll:GetWidth()
        if not w or w < 50 then w = 320 end
        child:SetWidth(w)
        RenderChapter(child, w)
        ClampScroll(0)
    end

    AMA._RefreshTutorialTab = Refresh
    parent:SetScript("OnShow", Refresh)
    scroll:SetScript("OnSizeChanged", function()
        if parent:IsShown() then Refresh() end
    end)
end
