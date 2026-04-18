-- AutoMarkAssist.lua
-- Namespace, shared constants, saved-variable defaults, utility helpers.
-- Loaded first after the DB modules.

AutoMarkAssist = AutoMarkAssist or {}
local AMA = AutoMarkAssist

-- ============================================================
-- IDENTITY
-- ============================================================

AMA.ADDON_NAME = "AutoMarkAssist"
AMA.VERSION    = "3.4.4"
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
    MAGE    = { mark = 5, label = "Polymorph", creatureTypes = { Humanoid = true, Beast = true, Critter = true } },
    ROGUE   = { mark = 3, label = "Sap",       creatureTypes = { Humanoid = true } },
    WARLOCK = { mark = 4, label = "Banish",     creatureTypes = { Demon = true, Elemental = true } },
    PRIEST  = { mark = 1, label = "Shackle",    creatureTypes = { Undead = true } },
    DRUID   = { mark = 2, label = "Hibernate",  creatureTypes = { Beast = true, Dragonkin = true } },
    HUNTER  = { mark = 6, label = "Trap",       creatureTypes = { Humanoid = true, Beast = true, Demon = true, Dragonkin = true, Giant = true, Undead = true } },
}

-- Ordered list for predictable iteration.
AMA.CC_CLASS_ORDER = { "MAGE", "ROGUE", "WARLOCK", "PRIEST", "DRUID", "HUNTER" }

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
    manualModifier     = "ALT",
    manualScrollOrder  = { 8, 7, 3, 4, 5, 6, 2, 1 },
    invertScroll       = true,
    mobMarks           = {},
    resetMarksKey      = "",
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

-- Returns a list of CC abilities available in the current group.
-- Each entry: { classTag, playerName, mark, label, creatureTypes }
-- Only includes CC for classes present AND whose mark is enabled.
function AMA.GetGroupCCAbilities()
    local abilities = {}
    local seen = {}

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

    for _, classTag in ipairs(AMA.CC_CLASS_ORDER) do
        local cc = AMA.CC_ASSIGNMENTS[classTag]
        if cc and AMA.IsMarkEnabled(cc.mark) then
            for _, token in ipairs(tokens) do
                local name = UnitName(token)
                local _, unitClass = UnitClass(token)
                if unitClass == classTag and not seen[classTag] then
                    seen[classTag] = true
                    abilities[#abilities + 1] = {
                        classTag = classTag,
                        playerName = name,
                        mark = cc.mark,
                        label = cc.label,
                        creatureTypes = cc.creatureTypes,
                    }
                    break
                end
            end
        end
    end

    return abilities
end

-- Returns a set of mark indices reserved for CC based on group composition.
function AMA.GetReservedCCMarks()
    local reserved = {}
    local abilities = AMA.GetGroupCCAbilities()
    for _, ability in ipairs(abilities) do
        if AMA.IsMarkEnabled(ability.mark) then
            reserved[ability.mark] = ability
        end
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
    db.mouseoverRange = nil
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
