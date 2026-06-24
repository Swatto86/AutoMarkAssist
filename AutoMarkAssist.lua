-- AutoMarkAssist.lua
-- Namespace, shared constants, saved-variable defaults, utility helpers.
-- Loaded first after the DB modules.

AutoMarkAssist = AutoMarkAssist or {}
local AMA = AutoMarkAssist

-- ============================================================
-- IDENTITY
-- ============================================================

AMA.ADDON_NAME = "AutoMarkAssist"
AMA.VERSION    = "3.4.19"
AMA.AUTHOR     = "Swatto"

-- ============================================================
-- MARK INDEX CONSTANTS
-- ============================================================

AMA.MARK_STAR     = 1
AMA.MARK_CIRCLE   = 2
AMA.MARK_DIAMOND  = 3
AMA.MARK_TRIANGLE = 4
AMA.MARK_MOON     = 5
AMA.MARK_SQUARE   = 6
AMA.MARK_CROSS    = 7
AMA.MARK_SKULL    = 8
AMA.MARK_NONE     = 0

AMA.MARK_NAMES = {
    [1] = "Star",     [2] = "Circle",   [3] = "Diamond",  [4] = "Triangle",
    [5] = "Moon",     [6] = "Square",   [7] = "Cross",    [8] = "Skull",
}

AMA.MARK_ICON_COORDS = {
    [8] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16:16|t",
    [7] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16:16|t",
    [6] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16:16|t",
    [5] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16:16|t",
    [4] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16:16|t",
    [3] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16:16|t",
    [2] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16:16|t",
    [1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16:16|t",
}

-- Display order: kill marks first, then CC marks.
AMA.ALL_MARKS_ORDERED = { 8, 7, 5, 3, 4, 1, 2, 6 }

-- ============================================================
-- FIXED CC ASSIGNMENTS
-- Each CC class has a fixed mark, label, and creature type filter.
-- The addon detects group composition and only uses CC marks for
-- classes actually present.
-- ============================================================

AMA.CC_ASSIGNMENTS = {
    MAGE    = { mark = 5, label = "Polymorph",  creatureTypes = { Humanoid = true, Beast = true, Critter = true } },
    ROGUE   = { mark = 3, label = "Sap",        creatureTypes = { Humanoid = true } },
    WARLOCK = { mark = 4, label = "Banish",     creatureTypes = { Demon = true, Elemental = true } },
    PRIEST  = { mark = 1, label = "Shackle",    creatureTypes = { Undead = true } },
    DRUID   = { mark = 2, label = "Hibernate",  creatureTypes = { Beast = true, Dragonkin = true } },
    HUNTER  = { mark = 6, label = "Trap",       creatureTypes = { Humanoid = true, Beast = true, Demon = true, Dragonkin = true, Giant = true, Undead = true } },
    -- Paladin Repentance (TBC+): shares Moon with Mage since there are only
    -- six non-kill raid icons.  When both a Mage and a Paladin are present
    -- the Mage owns Moon (Polymorph has broader creature-type coverage);
    -- solo-Paladin groups still get Moon allocated to Repentance.
    PALADIN = { mark = 5, label = "Repentance", creatureTypes = { Humanoid = true, Demon = true, Dragonkin = true, Giant = true, Undead = true } },
}

-- Ordered list for predictable iteration.  PALADIN comes last so Mage wins
-- the shared Moon slot when both classes are in the group (first-wins in
-- AMA.BuildCCPlan); a Paladin sharing with a Mage then borrows a spare icon.
AMA.CC_CLASS_ORDER = { "MAGE", "ROGUE", "WARLOCK", "PRIEST", "DRUID", "HUNTER", "PALADIN" }

-- Reverse lookup: mark index → class tag (e.g. 5 → "MAGE").
AMA.CC_MARK_TO_CLASS = {}
for classTag, cc in pairs(AMA.CC_ASSIGNMENTS) do
    AMA.CC_MARK_TO_CLASS[cc.mark] = classTag
end

-- Kill marks are always Skull first, Cross second.
AMA.KILL_MARKS = { 8, 7 }

-- Danger levels stored in DB entries to refine holistic mark priority.
-- Mobs with higher dangerLevel receive marks before equally-tiered mobs.
AMA.DANGER_LEVEL = {
    CRITICAL = 3,  -- Healer, summoner, mass-fear caster: kill or CC first
    HIGH     = 2,  -- Dangerous caster, interrupt priority, AoE, fear effect
    NORMAL   = 1,  -- Explicit kill/CC target with no special role signal
    -- 0 = unset (default; sorts equal to other unset mobs within the same tier)
}

-- ============================================================
-- DIFFICULTY DETECTION
-- Heroic dungeons prioritise CC over Cross.
-- ============================================================

AMA.isHeroicInstance = false

-- Classic-only difficulty IDs where CC is typically valuable (prioritise CC
-- over second kill).  Retail-only difficulties (Mythic+, scenarios, etc.)
-- are intentionally omitted -- this addon targets Classic clients only.
--   2 = 5-man Heroic (all Classic expansions)
--   8 = MoP Challenge Mode (MoP Classic)
AMA.HEROIC_DIFFICULTY_IDS = {
    [2] = true,
    [8] = true,
}

function AMA.RefreshDifficulty()
    local inInstance = IsInInstance()
    if not inInstance then
        AMA.isHeroicInstance = false
        return
    end
    local _, _, difficultyID = GetInstanceInfo()
    AMA.isHeroicInstance = AMA.HEROIC_DIFFICULTY_IDS[difficultyID] == true
    AMA.VPrint("Difficulty: " .. tostring(difficultyID) .. (AMA.isHeroicInstance and " (heroic)" or " (normal)"))
end

function AMA.IsHeroicDifficulty()
    return AMA.isHeroicInstance
end

-- Fixed human-readable descriptions for each mark.
AMA.MARK_DESCRIPTIONS = {
    [8] = "First Kill",
    [7] = "Second Kill",
    [5] = "Polymorph",
    [3] = "Sap",
    [4] = "Banish",
    [1] = "Shackle",
    [2] = "Hibernate",
    [6] = "Trap",
}

-- ============================================================
-- PROXIMITY RANGE LABELS
-- Classic uses CheckInteractDistance() index values.
-- ============================================================

AMA.PROXIMITY_RANGE_LABELS = {
    [2] = "~11 yd (Broken)", -- Kept for legacy DB mapping
    [3] = "~10 yd (Short)",
    [4] = "~28 yd (Long)",
}

-- Mouseover range gating.  0 disables the range check entirely so any
-- hovered unit is eligible; 3 and 4 use the same CheckInteractDistance
-- index values as proximity mode.
AMA.MOUSEOVER_RANGE_LABELS = {
    [0] = "Unlimited",
    [3] = "~10 yd (Short)",
    [4] = "~28 yd (Long)",
}

-- ============================================================
-- SAVED VARIABLE DEFAULTS
-- ============================================================

AMA.DB_DEFAULTS = {
    enabled         = true,
    verbose         = false,
    autoReset       = true,
    minimapAngle    = 225,
    minimapHide     = false,
    enabledMarks    = {
        [8] = true,   -- Skull: First Kill
        [7] = true,   -- Cross: Second Kill
        [5] = true,   -- Moon: Polymorph
        [3] = true,   -- Diamond: Sap
        [4] = true,   -- Triangle: Banish
        [1] = true,   -- Star: Shackle
        [2] = true,   -- Circle: Hibernate
        [6] = true,   -- Square: Trap
    },
    announceChannel    = "PARTY",
    announcePrefixText = "AutoMarkAssist",
    announceOnEntry    = true,
    silentMode         = false,
    lockMarksInCombat  = false,
    rebalanceOnDeath   = true,
    skipCritters       = true,
    markingMode        = "proximity",   -- "proximity" | "mouseover" | "manual"
    proximityRange     = 4,
    mouseoverRange     = 0,   -- 0 = unlimited, 3 = ~10 yd, 4 = ~28 yd
    manualModifier     = "ALT",
    manualScrollOrder  = { 8, 7, 3, 4, 5, 6, 2, 1 },
    invertScroll       = true,
    mobMarks           = {},
    resetMarksKey      = "",
    -- configWidth / configHeight: persisted config-window size.  Absent until
    -- the user resizes the window; Config falls back to its design size.
}

-- ============================================================
-- UTILITY HELPERS
-- ============================================================

function AMA.Print(msg)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFF1A9EC0AutoMarkAssist|r: " .. tostring(msg))
    end
end

function AMA.VPrint(msg)
    if AutoMarkAssistDB and AutoMarkAssistDB.verbose then
        AMA.Print("|cFF888888" .. tostring(msg) .. "|r")
    end
end

-- Returns true if `key` is a bare mouse-button / mouse-wheel binding
-- (optionally prefixed with ALT-/CTRL-/SHIFT-).  Mouse buttons must not be
-- used for the reset keybind: the binder is captured through OnKeyDown which
-- is meant for keyboard input, and a stray mouse click should never wipe
-- raid marks.
function AMA.IsMouseButtonKey(key)
    if type(key) ~= "string" or key == "" then return false end
    local stripped = key
    stripped = stripped:gsub("^ALT%-", "")
    stripped = stripped:gsub("^CTRL%-", "")
    stripped = stripped:gsub("^SHIFT%-", "")
    if stripped == "MIDDLEMOUSE"
    or stripped == "MOUSEWHEELUP"
    or stripped == "MOUSEWHEELDOWN" then
        return true
    end
    if stripped:match("^BUTTON%d+$") then return true end
    return false
end

function AMA.CountTable(t)
    local count = 0
    if type(t) == "table" then
        for _ in pairs(t) do count = count + 1 end
    end
    return count
end

function AMA.IsAddonEnabled()
    return AutoMarkAssistDB and AutoMarkAssistDB.enabled
end

function AMA.GetMarkingMode()
    return AutoMarkAssistDB and AutoMarkAssistDB.markingMode or "proximity"
end

function AMA.SetMarkingMode(mode)
    if not AutoMarkAssistDB then return false end
    if mode ~= "proximity" and mode ~= "mouseover" and mode ~= "manual" then
        return false
    end
    if AutoMarkAssistDB.markingMode == mode then return false end
    AutoMarkAssistDB.markingMode = mode
    return true
end

function AMA.IsMarkEnabled(markIdx)
    if markIdx == 8 or markIdx == 7 then return true end
    if not AutoMarkAssistDB or not AutoMarkAssistDB.enabledMarks then
        return true
    end
    return AutoMarkAssistDB.enabledMarks[markIdx] ~= false
end

-- Returns true if a mark is both user-enabled AND available given the current
-- group composition.  Kill marks (Skull, Cross) are always available when
-- enabled.  CC marks are only available when the corresponding CC class is
-- present in the group.
function AMA.IsMarkAvailable(markIdx, reservedCCMarks)
    if not AMA.IsMarkEnabled(markIdx) then return false end
    local ccClass = AMA.CC_MARK_TO_CLASS[markIdx]
    if not ccClass then return true end -- not a CC mark
    if not reservedCCMarks then
        reservedCCMarks = AMA.GetReservedCCMarks()
    end
    return reservedCCMarks[markIdx] ~= nil
end

-- Returns every CC-capable player currently in the group -- one entry PER
-- PLAYER (not deduped by class) so two Mages produce two entries -- ordered by
-- CC_CLASS_ORDER and then roster discovery order.  Each entry: { classTag,
-- playerName }.  Only includes classes whose canonical CC mark is user-enabled.
function AMA.GetGroupCCCasters()
    local tokens = {}
    if IsInRaid and IsInRaid() then
        for i = 1, 40 do
            local token = "raid" .. i
            if UnitExists(token) then tokens[#tokens + 1] = token end
        end
    else
        for _, token in ipairs({ "player", "party1", "party2", "party3", "party4" }) do
            if UnitExists(token) then tokens[#tokens + 1] = token end
        end
    end

    -- Bucket casters by class, preserving roster order within each class.
    local byClass = {}
    for _, token in ipairs(tokens) do
        local _, unitClass = UnitClass(token)
        local cc = unitClass and AMA.CC_ASSIGNMENTS[unitClass]
        if cc and AMA.IsMarkEnabled(cc.mark) then
            local bucket = byClass[unitClass]
            if not bucket then bucket = {}; byClass[unitClass] = bucket end
            bucket[#bucket + 1] = { classTag = unitClass, playerName = UnitName(token) }
        end
    end

    -- Flatten in canonical class order so primary-mark claiming is deterministic.
    local casters = {}
    for _, classTag in ipairs(AMA.CC_CLASS_ORDER) do
        local bucket = byClass[classTag]
        if bucket then
            for _, caster in ipairs(bucket) do casters[#casters + 1] = caster end
        end
    end
    return casters
end

-- CC marks in canonical display order (kill marks excluded).  Used as the
-- borrow-pool ordering when extra casters need a spare icon.  Built lazily so
-- it picks up ALL_MARKS_ORDERED after this file has finished loading.
local ccMarksOrdered
local function GetCCMarksOrdered()
    if ccMarksOrdered then return ccMarksOrdered end
    ccMarksOrdered = {}
    for _, m in ipairs(AMA.ALL_MARKS_ORDERED) do
        if m ~= AMA.MARK_SKULL and m ~= AMA.MARK_CROSS then
            ccMarksOrdered[#ccMarksOrdered + 1] = m
        end
    end
    return ccMarksOrdered
end

-- Builds the crowd-control assignment plan for the current group.
--
-- Each present CC class claims its canonical mark first (the "primary").  When
-- a group brings MORE than one caster of a class -- two Mages, two Warlocks --
-- the surplus casters borrow a spare CC icon (one whose owning class is absent
-- and which is user-enabled) so a second Polymorph / Banish target gets marked
-- instead of the icon going to waste.  Classes that share a canonical mark
-- (Mage Polymorph and Paladin Repentance both on Moon) behave the same way:
-- the first owner takes Moon and the other borrows a spare.
--
-- Returns an ordered list, primaries first:
--   { mark, classTag, playerName, label, creatureTypes, borrowed }
function AMA.BuildCCPlan()
    local casters = AMA.GetGroupCCCasters()

    local plan = {}
    local markClaimed = {}    -- [markIdx] = true
    local classClaimed = {}   -- [classTag] = true (claimed its OWN canonical mark)
    local borrowQueue = {}    -- casters still awaiting an icon

    -- Pass 1: each caster tries to claim its class's canonical mark.
    for _, caster in ipairs(casters) do
        local cc = AMA.CC_ASSIGNMENTS[caster.classTag]
        local primary = cc and cc.mark
        if primary and AMA.IsMarkEnabled(primary)
            and not markClaimed[primary] and not classClaimed[caster.classTag] then
            markClaimed[primary] = true
            classClaimed[caster.classTag] = true
            plan[#plan + 1] = {
                mark          = primary,
                classTag      = caster.classTag,
                playerName    = caster.playerName,
                label         = cc.label,
                creatureTypes = cc.creatureTypes,
                borrowed      = false,
            }
        else
            -- A surplus caster of a class that already owns its mark, or a class
            -- whose canonical mark is owned by another present class (Mage /
            -- Paladin Moon sharing).  Both queue for a borrowed icon.
            borrowQueue[#borrowQueue + 1] = caster
        end
    end

    -- Pass 2: hand out spare CC icons (enabled, not claimed as a primary).
    if #borrowQueue > 0 then
        local spares = {}
        for _, m in ipairs(GetCCMarksOrdered()) do
            if not markClaimed[m] and AMA.IsMarkEnabled(m) then
                spares[#spares + 1] = m
            end
        end
        local si = 1
        for _, caster in ipairs(borrowQueue) do
            local spare = spares[si]
            if not spare then break end   -- pool exhausted; extra casters go unmarked
            si = si + 1
            markClaimed[spare] = true
            local cc = AMA.CC_ASSIGNMENTS[caster.classTag]
            plan[#plan + 1] = {
                mark          = spare,
                classTag      = caster.classTag,
                playerName    = caster.playerName,
                label         = cc.label,
                creatureTypes = cc.creatureTypes,
                borrowed      = true,
            }
        end
    end

    return plan
end

-- Returns a set of mark indices reserved for CC based on the current plan:
--   { [markIdx] = { classTag, playerName, mark, label, creatureTypes } }
-- Each reserved mark carries a private copy of its CC ability's creature-type
-- filter so the allocator only applies it to compatible mobs (and so callers
-- never mutate the shared CC_ASSIGNMENTS tables).
function AMA.GetReservedCCMarks()
    local reserved = {}
    for _, entry in ipairs(AMA.BuildCCPlan()) do
        local merged = {
            classTag      = entry.classTag,
            playerName    = entry.playerName,
            mark          = entry.mark,
            label         = entry.label,
            creatureTypes = {},
        }
        for t, v in pairs(entry.creatureTypes or {}) do
            if v then merged.creatureTypes[t] = true end
        end
        reserved[entry.mark] = merged
    end
    return reserved
end

-- ============================================================
-- ANNOUNCEMENT HELPERS
-- ============================================================

local function NormalizePrefixText(prefixText)
    if prefixText == nil then
        prefixText = (AMA.DB_DEFAULTS and AMA.DB_DEFAULTS.announcePrefixText) or ""
    end
    prefixText = tostring(prefixText):gsub("^%s+", ""):gsub("%s+$", "")
    local bracketed = prefixText:match("^%[(.*)%]$")
    if bracketed then
        prefixText = bracketed:gsub("^%s+", ""):gsub("%s+$", "")
    end
    return prefixText
end

function AMA.GetAnnouncementPrefixText()
    return NormalizePrefixText(
        AutoMarkAssistDB and AutoMarkAssistDB.announcePrefixText)
end

function AMA.BuildAnnouncementPrefix()
    local text = AMA.GetAnnouncementPrefixText()
    if text == "" then return "" end
    return string.format("[%s] ", text)
end

-- ============================================================
-- SAVED VARIABLE MANAGEMENT
-- ============================================================

local function DeepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do
        copy[DeepCopy(k)] = DeepCopy(v)
    end
    return copy
end

function AMA.BackfillDefaults(db)
    if type(db) ~= "table" then return end
    for key, default in pairs(AMA.DB_DEFAULTS) do
        if db[key] == nil then
            db[key] = DeepCopy(default)
        end
    end
end

function AMA.MigrateFromOldVersion(db)
    if type(db) ~= "table" then return end

    -- Migrate from separate mode booleans to single markingMode.
    if db.proximityMode ~= nil or db.mouseoverMode ~= nil or db.manualMode ~= nil then
        if db.manualMode then
            db.markingMode = "manual"
        elseif db.mouseoverMode then
            db.markingMode = "mouseover"
        else
            db.markingMode = "proximity"
        end
        db.proximityMode = nil
        db.mouseoverMode = nil
        db.manualMode = nil
    end

    -- Migrate announceOnEntry from old autoAnnounceDungeonCC flag.
    if db.announceOnEntry == nil and db.autoAnnounceDungeonCC ~= nil then
        db.announceOnEntry = db.autoAnnounceDungeonCC
    end

    -- Scrub any accidentally-saved mouse-button reset binding.  Earlier
    -- versions exposed this through a key-capture field that could pick up
    -- things like MIDDLEMOUSE or BUTTON3 in certain clients, resulting in
    -- raid marks being wiped every time the user middle-clicked.
    if AMA.IsMouseButtonKey and AMA.IsMouseButtonKey(db.resetMarksKey) then
        db.resetMarksKey = ""
    end

    -- Migrate old priority-string DB format (mobOverrides/mobRemovals/zoneAdditions)
    -- into the new mobMarks table.
    local PRIORITY_MAP = { HIGH = 8, CC = 5 }
    if not db.mobMarks then db.mobMarks = {} end

    if type(db.mobOverrides) == "table" then
        for zone, mobs in pairs(db.mobOverrides) do
            if type(mobs) == "table" then
                db.mobMarks[zone] = db.mobMarks[zone] or {}
                for mob, val in pairs(mobs) do
                    if type(val) == "string" and PRIORITY_MAP[val] then
                        db.mobMarks[zone][mob] = PRIORITY_MAP[val]
                    elseif type(val) == "number" or val == "SKIP" then
                        db.mobMarks[zone][mob] = val
                    end
                end
            end
        end
    end
    if type(db.mobRemovals) == "table" then
        for zone, mobs in pairs(db.mobRemovals) do
            if type(mobs) == "table" then
                db.mobMarks[zone] = db.mobMarks[zone] or {}
                for mob in pairs(mobs) do
                    db.mobMarks[zone][mob] = "SKIP"
                end
            end
        end
    end
    if type(db.zoneAdditions) == "table" then
        for zone, mobs in pairs(db.zoneAdditions) do
            if type(mobs) == "table" then
                db.mobMarks[zone] = db.mobMarks[zone] or {}
                for mob, val in pairs(mobs) do
                    if type(val) == "string" and PRIORITY_MAP[val] then
                        db.mobMarks[zone][mob] = PRIORITY_MAP[val]
                    elseif type(val) == "number" or val == "SKIP" then
                        db.mobMarks[zone][mob] = val
                    end
                end
            end
        end
    end

    -- Remove obsolete keys.
    db.mobOverrides = nil
    db.mobRemovals = nil
    db.zoneAdditions = nil
    db.markPools = nil
    db.smartCCRoleMarks = nil
    db.ccLimit = nil
    db.mobSubPriorities = nil
    db.skipFillerMobs = nil
    db.mouseoverRangeEnabled = nil
    -- Coerce any legacy mouseoverRange value into the supported set
    -- (0 = unlimited, 3 = short, 4 = long).  Anything else falls back to 0.
    if db.mouseoverRange ~= nil
        and db.mouseoverRange ~= 0
        and db.mouseoverRange ~= 3
        and db.mouseoverRange ~= 4
    then
        db.mouseoverRange = 0
    end
    db.announceLineByLine = nil
    db.smartDungeonCC = nil
    db.autoAnnounceDungeonCC = nil
    db.lastSeenWhatsNew = nil
    db.automationDefaultsMigrationVersion = nil
    db.squareMinimap = nil
    db.manualMarkPrefs = nil
    db.markLegend = nil
end

function AMA.ResetSettingsToDefaults()
    if not AutoMarkAssistDB then return end
    for key, default in pairs(AMA.DB_DEFAULTS) do
        AutoMarkAssistDB[key] = DeepCopy(default)
    end
end

-- ============================================================
-- MANUAL SCROLL ORDER
-- ============================================================

function AMA.GetDefaultManualScrollOrder()
    return DeepCopy(AMA.DB_DEFAULTS.manualScrollOrder or { 8, 7, 3, 4, 5, 6, 2, 1 })
end

function AMA.NormalizeManualScrollOrder(order)
    local normalized = {}
    local seen = {}
    if type(order) == "table" then
        for _, raw in ipairs(order) do
            local m = tonumber(raw)
            if m then m = math.floor(m) end
            if m and m >= 1 and m <= 8 and not seen[m] then
                normalized[#normalized + 1] = m
                seen[m] = true
            end
        end
    end
    for _, default in ipairs(AMA.GetDefaultManualScrollOrder()) do
        if not seen[default] then
            normalized[#normalized + 1] = default
            seen[default] = true
        end
    end
    return normalized
end

function AMA.GetManualScrollOrder()
    local order = AMA.NormalizeManualScrollOrder(
        AutoMarkAssistDB and AutoMarkAssistDB.manualScrollOrder)
    if AutoMarkAssistDB then
        AutoMarkAssistDB.manualScrollOrder = order
    end
    return order
end

function AMA.GetActiveManualScrollOrder()
    local active = {}
    for _, markIdx in ipairs(AMA.GetManualScrollOrder()) do
        if AMA.IsMarkEnabled(markIdx) then
            active[#active + 1] = markIdx
        end
    end
    -- Fallback strategy if all marks are disabled: just return Skull
    if #active == 0 then
        active[1] = 8
    end
    return active
end
