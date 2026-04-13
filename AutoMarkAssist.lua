-- AutoMarkAssist.lua
-- Namespace initialisation, shared constants, runtime state, and utility helpers.
-- Loaded second (after AutoMarkAssist_DB.lua); every subsequent file begins with:
--   local AMA = AutoMarkAssist

-- ============================================================
-- NAMESPACE
-- ============================================================

AutoMarkAssist = AutoMarkAssist or {}
local AMA      = AutoMarkAssist

-- ============================================================
-- IDENTITY
-- ============================================================

AMA.ADDON_NAME = "AutoMarkAssist"
AMA.VERSION    = "2.7.17"
AMA.AUTHOR     = "Swatto"
AMA.AUTOMATION_DEFAULTS_MIGRATION_VERSION = "2.7.10-automation-modes"

AMA.LATEST_WHATS_NEW = {
    "Fixed the Options panel crash caused by the retired Legend-tab helper path.",
    "Removed the Legend tab and locked Smart Group CC to fixed icons: Moon for Polymorph, Diamond for Sap, Square for Trap, Star for Shackle, Circle for Hibernate, and Triangle for Banish.",
    "Mark plan announce and preview now only label CC icons for classes actually present in the live party or raid roster, and the remaining active icons fall back to later kill-order lines.",
}

-- ============================================================
-- MARK INDEX CONSTANTS
-- Human-readable aliases for the 8 raid target icon indices.
-- Also declared as file-scope locals in Core/Minimap/Config for
-- readable patterns like:  if markIdx == MARK_SKULL then ...
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

-- Human-readable labels used in chat output and tooltips across all files.
AMA.MARK_NAMES = {
    [1]="Star", [2]="Circle", [3]="Diamond", [4]="Triangle",
    [5]="Moon",  [6]="Square", [7]="Cross",   [8]="Skull",
}

-- ============================================================
-- MARK ICON TEXTURE STRINGS
-- Used by Announce (Config), Config slot buttons, and the HUD.
-- ============================================================

AMA.ALL_MARKS_ORDERED = {8, 7, 6, 5, 4, 3, 2, 1}

AMA.MARK_ICON_COORDS = {
    [8]="|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16:16|t",
    [7]="|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16:16|t",
    [6]="|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16:16|t",
    [5]="|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16:16|t",
    [4]="|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16:16|t",
    [3]="|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16:16|t",
    [2]="|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16:16|t",
    [1]="|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16:16|t",
}

-- ============================================================
-- PRIORITY TIER CONSTANTS
-- String keys used as tier identifiers throughout the codebase.
-- Also declared as file-scope locals in files that need them.
-- ============================================================

AMA.PRIORITY_BOSS   = "BOSS"
AMA.PRIORITY_HIGH   = "HIGH"
AMA.PRIORITY_CC     = "CC"
AMA.PRIORITY_MEDIUM = "MEDIUM"
AMA.PRIORITY_LOW    = "LOW"

-- Compile-time default mark pools.  User-configured pools live in
-- AutoMarkAssistDB.markPools and take precedence at runtime.
AMA.PRIORITY_POOLS = {
    HIGH   = { 8, 7             },   -- Skull, Cross
    CC     = { 5, 3, 6, 1, 2, 4 },   -- Moon, Diamond, Square, Star, Circle, Triangle
    MEDIUM = {                  },
    LOW    = {                  },
}

-- Human-readable labels for proximity range settings.
-- Classic uses CheckInteractDistance() index values:
--   2 = ~11 yd (Trade range)
--   3 = ~10 yd (Duel range)
--   4 = ~28 yd (Follow range)
AMA.PROXIMITY_RANGE_LABELS = {
    [2] = "~11 yd (Trade range)",
    [3] = "~10 yd (Duel range)",
    [4] = "~28 yd (Follow range)",
}

-- ============================================================
-- KEYWORD HEURISTICS
-- Used by Core to classify mobs not present in the zone database.
-- ============================================================

AMA.HIGH_KEYWORDS = {
    "healer", "priest", "mage", "warlock", "shaman", "sorcerer",
    "channeler", "scryer", "theurgist", "darkcaster", "physician",
    "mender", "oracle", "hexer", "cultist", "assassin", "infiltrator",
    "saboteur", "necromancer", "shadowcaster", "warden",
}

AMA.CC_KEYWORDS = {
    "beast", "animal", "hound", "wolf", "serpent", "hawk", "bat", "whelp",
}

AMA.DUNGEON_SMART_CC_ROLE_DEFS = {
    { classTag = "MAGE", label = "Polymorph" },
    { classTag = "ROGUE", label = "Sap" },
    { classTag = "HUNTER", label = "Trap" },
    { classTag = "PRIEST", label = "Shackle" },
    { classTag = "WARLOCK", label = "Banish" },
    { classTag = "DRUID", label = "Hibernate" },
}

-- ============================================================
-- SAVED VARIABLE DEFAULTS
-- Applied in ADDON_LOADED (AutoMarkAssist_Events) where missing keys
-- are back-filled.  Stored on AMA so Events does not embed the table.
-- ============================================================

AMA.DB_DEFAULTS = {
    enabled       = true,
    verbose       = false,
    autoReset     = true,
    minimapAngle  = 225,
    minimapHide   = false,
    enabledMarks = {
        [8] = true, -- Skull: First Kill
        [7] = true, -- Cross: Second Kill
        [6] = false, -- Square (Unused by default)
        [5] = true, -- Moon: Sheep
        [4] = true, -- Triangle: Banish
        [3] = true, -- Diamond: Sap
        [2] = true, -- Circle: Hibernate
        [1] = true, -- Star: Shackle
    },
    markLegend = {
        [8] = "Priority Kill",
        [7] = "Secondary Kill",
        [6] = "Trap",
        [5] = "Polymorph",
        [4] = "Banish",
        [3] = "Sap",
        [2] = "Hibernate",
        [1] = "Shackle",
    },
    smartCCRoleMarks = {
        MAGE = 5,
        ROGUE = 3,
        HUNTER = 6,
        PRIEST = 1,
        WARLOCK = 4,
        DRUID = 2,
    },
    announceChannel  = "PARTY",
    announcePrefixText = "AutoMarkAssist",
    announceLineByLine = true,
    dynamicMarking   = true,
    lockMarksInCombat = false,
    rebalanceOnDeath = true,
    skipFillerMobs   = true,
    skipCritters     = true,
    ccLimit          = 0,
    smartDungeonCC   = true,
    autoAnnounceDungeonCC = true,
    proximityMode    = true,
    proximityRange   = 4,
    mouseoverMode    = false,
    mouseoverRangeEnabled = true,
    mouseoverRange   = 4,
    manualMode       = false,
    manualModifier   = "ALT",
    manualScrollOrder = {8, 7, 3, 4, 5, 6, 2, 1},
    invertScroll  = true,
    mobOverrides    = {},
    mobRemovals     = {},
    mobSubPriorities = {},
    zoneAdditions   = {},
    manualMarkPrefs = {},
    resetMarksKey   = "BUTTON3",
}

local MARK_POOL_KEYS = { "HIGH", "CC", "MEDIUM", "LOW" }
local SMART_CC_ROLE_KEYS = {}

for _, roleDef in ipairs(AMA.DUNGEON_SMART_CC_ROLE_DEFS or {}) do
    SMART_CC_ROLE_KEYS[#SMART_CC_ROLE_KEYS + 1] = roleDef.classTag
end

local function DeepCopyValue(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, childValue in pairs(value) do
        copy[DeepCopyValue(key)] = DeepCopyValue(childValue)
    end
    return copy
end

local function CopyArray(src)
    local copy = {}
    if type(src) ~= "table" then
        return copy
    end
    for i, value in ipairs(src) do
        copy[i] = value
    end
    return copy
end

local function NormalizeAnnouncementPrefixText(prefixText)
    if prefixText == nil then
        prefixText = (AMA.DB_DEFAULTS and AMA.DB_DEFAULTS.announcePrefixText) or ""
    end

    prefixText = tostring(prefixText)
    prefixText = prefixText:gsub("^%s+", ""):gsub("%s+$", "")

    local bracketed = prefixText:match("^%[(.*)%]$")
    if bracketed then
        prefixText = bracketed:gsub("^%s+", ""):gsub("%s+$", "")
    end

    return prefixText
end

local function IsReservedKillOrderMark(markIdx)
    return markIdx == AMA.MARK_SKULL or markIdx == AMA.MARK_CROSS
end

function AMA.BackfillMissingDBDefaults(db)
    if type(db) ~= "table" then return end

    for key, defaultValue in pairs(AMA.DB_DEFAULTS or {}) do
        if db[key] == nil then
            db[key] = DeepCopyValue(defaultValue)
        end
    end
end

function AMA.GetDefaultMarkPools()
    local defaults = (AMA.DB_DEFAULTS and AMA.DB_DEFAULTS.markPools) or AMA.PRIORITY_POOLS
    local copy = {}
    for _, key in ipairs(MARK_POOL_KEYS) do
        copy[key] = CopyArray((defaults and defaults[key]) or AMA.PRIORITY_POOLS[key] or {})
    end
    return copy
end

function AMA.NormalizeMarkPools(pools)
    if type(pools) ~= "table" then
        return AMA.GetDefaultMarkPools()
    end

    local normalized = {
        HIGH = { AMA.MARK_SKULL, AMA.MARK_CROSS },
        CC = {},
        MEDIUM = {},
        LOW = {},
    }
    local seenMarks = {
        [AMA.MARK_SKULL] = true,
        [AMA.MARK_CROSS] = true,
    }
    local sawBucket = false

    for _, key in ipairs(MARK_POOL_KEYS) do
        local bucket = pools[key]
        if type(bucket) == "table" then
            sawBucket = true
            for _, rawMark in ipairs(bucket) do
                local markIdx = tonumber(rawMark)
                if markIdx then
                    markIdx = math.floor(markIdx)
                end
                if markIdx and markIdx >= 1 and markIdx <= 8
                and not seenMarks[markIdx]
                and (key == "HIGH" or not IsReservedKillOrderMark(markIdx)) then
                    normalized[key][#normalized[key] + 1] = markIdx
                    seenMarks[markIdx] = true
                end
            end
        end
    end

    if not sawBucket then
        return AMA.GetDefaultMarkPools()
    end

    return normalized
end

function AMA.GetDefaultManualScrollOrder()
    return CopyArray((AMA.DB_DEFAULTS and AMA.DB_DEFAULTS.manualScrollOrder)
        or {8, 7, 3, 4, 5, 6, 2, 1})
end

function AMA.GetDefaultSmartCCRoleMarks()
    local defaults = (AMA.DB_DEFAULTS and AMA.DB_DEFAULTS.smartCCRoleMarks) or {}
    local copy = {}

    for _, classTag in ipairs(SMART_CC_ROLE_KEYS) do
        copy[classTag] = defaults[classTag]
    end

    return copy
end

function AMA.NormalizeSmartCCRoleMarks(roleMarks)
    return AMA.GetDefaultSmartCCRoleMarks()
end

function AMA.GetSmartCCRoleMarks()
    local normalized = AMA.NormalizeSmartCCRoleMarks(
        AutoMarkAssistDB and AutoMarkAssistDB.smartCCRoleMarks)

    if AutoMarkAssistDB then
        AutoMarkAssistDB.smartCCRoleMarks = normalized
        return AutoMarkAssistDB.smartCCRoleMarks
    end

    return normalized
end

function AMA.NormalizeManualScrollOrder(order)
    local normalized = {}
    local seenMarks = {}

    if type(order) == "table" then
        for _, rawMark in ipairs(order) do
            local markIdx = tonumber(rawMark)
            if markIdx then
                markIdx = math.floor(markIdx)
            end
            if markIdx and markIdx >= 1 and markIdx <= 8 and not seenMarks[markIdx] then
                normalized[#normalized + 1] = markIdx
                seenMarks[markIdx] = true
            end
        end
    end

    for _, defaultMark in ipairs(AMA.GetDefaultManualScrollOrder()) do
        if not seenMarks[defaultMark] then
            normalized[#normalized + 1] = defaultMark
            seenMarks[defaultMark] = true
        end
    end

    return normalized
end

function AMA.GetManualScrollOrder()
    local normalized = AMA.NormalizeManualScrollOrder(
        AutoMarkAssistDB and AutoMarkAssistDB.manualScrollOrder)

    if AutoMarkAssistDB then
        AutoMarkAssistDB.manualScrollOrder = normalized
        return AutoMarkAssistDB.manualScrollOrder
    end

    return normalized
end

function AMA.NormalizeAutoMarkModes(db, preferredMode)
    if type(db) ~= "table" then
        return false
    end

    local proximityOn = db.proximityMode == true
    local mouseoverOn = db.mouseoverMode == true

    if proximityOn and mouseoverOn then
        if preferredMode == "mouseover" then
            db.proximityMode = false
        else
            db.mouseoverMode = false
        end
        return true
    end

    return false
end

function AMA.SetAutoMarkMode(mode, enabled)
    if not AutoMarkAssistDB then
        return false
    end

    enabled = enabled and true or false
    local changed = false

    if mode == "proximity" then
        if AutoMarkAssistDB.proximityMode ~= enabled then
            AutoMarkAssistDB.proximityMode = enabled
            changed = true
        end
        if enabled and AutoMarkAssistDB.mouseoverMode then
            AutoMarkAssistDB.mouseoverMode = false
            changed = true
        end
    elseif mode == "mouseover" then
        if AutoMarkAssistDB.mouseoverMode ~= enabled then
            AutoMarkAssistDB.mouseoverMode = enabled
            changed = true
        end
        if enabled and AutoMarkAssistDB.proximityMode then
            AutoMarkAssistDB.proximityMode = false
            changed = true
        end
    end

    return changed
end

function AMA.NormalizeSavedSettings()
    if not AutoMarkAssistDB then return end
    AutoMarkAssistDB.markPools = AMA.NormalizeMarkPools(AutoMarkAssistDB.markPools)
    AutoMarkAssistDB.smartCCRoleMarks = AMA.NormalizeSmartCCRoleMarks(
        AutoMarkAssistDB.smartCCRoleMarks)
    AutoMarkAssistDB.manualScrollOrder = AMA.NormalizeManualScrollOrder(
        AutoMarkAssistDB.manualScrollOrder)
    AutoMarkAssistDB.announcePrefixText =
        NormalizeAnnouncementPrefixText(AutoMarkAssistDB.announcePrefixText)
    AMA.NormalizeAutoMarkModes(AutoMarkAssistDB, "proximity")
    AutoMarkAssistDB.squareMinimap = nil
end

function AMA.GetAnnouncementPrefixText()
    local prefixText = NormalizeAnnouncementPrefixText(
        AutoMarkAssistDB and AutoMarkAssistDB.announcePrefixText)

    if AutoMarkAssistDB then
        AutoMarkAssistDB.announcePrefixText = prefixText
    end

    return prefixText
end

function AMA.BuildAnnouncementPrefix()
    local prefixText = AMA.GetAnnouncementPrefixText()
    if prefixText == "" then
        return ""
    end
    return string.format("[%s] ", prefixText)
end

function AMA.IsLineByLineAnnouncementsEnabled()
    return not AutoMarkAssistDB or AutoMarkAssistDB.announceLineByLine ~= false
end

function AMA.IsAutoDungeonCCAnnouncementEnabled()
    return AutoMarkAssistDB and AutoMarkAssistDB.autoAnnounceDungeonCC ~= false
end

function AMA.ResetSettingsToDefaults()
    if not AutoMarkAssistDB then return end

    for key, defaultValue in pairs(AMA.DB_DEFAULTS or {}) do
        AutoMarkAssistDB[key] = DeepCopyValue(defaultValue)
    end

    AutoMarkAssistDB.automationDefaultsMigrationVersion =
        AMA.AUTOMATION_DEFAULTS_MIGRATION_VERSION

    AMA.NormalizeSavedSettings()
end

function AMA.ApplyAutomationDefaultsMigration()
    if not AutoMarkAssistDB then
        return false
    end

    if AutoMarkAssistDB.automationDefaultsMigrationVersion
            == AMA.AUTOMATION_DEFAULTS_MIGRATION_VERSION then
        return false
    end

    local changed = false

    if AMA.NormalizeAutoMarkModes
            and AMA.NormalizeAutoMarkModes(AutoMarkAssistDB, "proximity") then
        changed = true
    end

    AutoMarkAssistDB.automationDefaultsMigrationVersion =
        AMA.AUTOMATION_DEFAULTS_MIGRATION_VERSION

    return changed
end

-- ============================================================
-- RUNTIME STATE
-- All mutable tracking state lives here so every file can access
-- it through the AMA table without upvalue chains across files.
-- ============================================================

AMA.markedGUIDs      = {}    -- guid  -> markIdx   (all currently tracked mobs)
AMA.markOwners       = {}    -- markIdx -> guid     (mob holding each slot)
AMA.markTokens       = {}    -- markIdx -> unit token used when mark was set
AMA.guidPriority     = {}    -- guid  -> priority string  (all tracked mobs)
AMA.guidSubPriority  = {}    -- guid  -> integer sub-priority (within same tier)
AMA.guidMarkSource   = {}    -- guid  -> "local" or "observed"
AMA.pullMarkCount    = 0     -- local marks assigned in the current tracking window
AMA.currentZoneMobDB = nil   -- merged zone DB (base + overrides - removals)
AMA.currentZoneName  = ""    -- raw zone name from GetRealZoneText()
AMA.SCAN_UNIT_TOKENS = {}    -- populated by AutoMarkAssist_Events at load time
AMA.lastBlockWarnTime = 0    -- rate-limits repeated "cannot mark" verbose message

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

-- Primary chat output, always visible.
function AMA.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cFF00CCFFAutoMarkAssist:|r " .. tostring(msg))
end

-- Verbose/debug output, shown only when AutoMarkAssistDB.verbose is true.
function AMA.VPrint(msg)
    if AutoMarkAssistDB and AutoMarkAssistDB.verbose then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFF888888[AMA]|r " .. tostring(msg))
    end
end

function AMA.GetLatestWhatsNewTitle()
    return "What's New in v" .. tostring(AMA.VERSION or "")
end

function AMA.GetLatestWhatsNewText()
    local lines = {}
    for _, line in ipairs(AMA.LATEST_WHATS_NEW or {}) do
        lines[#lines + 1] = "- " .. tostring(line)
    end
    return table.concat(lines, "\n")
end

function AMA.IsManualScrollInverted()
    if AutoMarkAssistDB and AutoMarkAssistDB.invertScroll ~= nil then
        return AutoMarkAssistDB.invertScroll
    end
    return AMA.DB_DEFAULTS.invertScroll ~= false
end

function AMA.GetManualScrollDirectionLabel()
    if AMA.IsManualScrollInverted() then
        return "Scroll Down Starts Left"
    end
    return "Scroll Up Starts Left"
end

function AMA.GetManualScrollDirectionHint()
    if AMA.IsManualScrollInverted() then
        return "Down = left to right, Up = right to left"
    end
    return "Up = left to right, Down = right to left"
end

function AMA.IsAddonEnabled()
    return AutoMarkAssistDB and AutoMarkAssistDB.enabled == true
end

-- Returns the number of entries in a table.
function AMA.CountTable(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

-- Resolves a raw zone name through the alias table when one exists.
-- AutoMarkAssist_ZoneAliases is defined in AutoMarkAssist_DB.lua.
function AMA.ResolveZoneName(raw)
    if AutoMarkAssist_ZoneAliases and AutoMarkAssist_ZoneAliases[raw] then
        return AutoMarkAssist_ZoneAliases[raw]
    end
    return raw
end

-- Returns the set of zones whose base DB contains mobName.
-- Built lazily so legacy flat override tables can be migrated once at load.
local mobZoneIndex = nil

local function GetMobZoneIndex()
    if mobZoneIndex then return mobZoneIndex end
    mobZoneIndex = {}
    if not AutoMarkAssist_MobDB then return mobZoneIndex end
    for zoneName, zoneDB in pairs(AutoMarkAssist_MobDB) do
        for mobName in pairs(zoneDB) do
            mobZoneIndex[mobName] = mobZoneIndex[mobName] or {}
            mobZoneIndex[mobName][#mobZoneIndex[mobName] + 1] = zoneName
        end
    end
    return mobZoneIndex
end

-- Returns the zone-scoped sub-table inside root for zoneName.
-- root is expected to be AutoMarkAssistDB.mobOverrides or mobRemovals.
function AMA.GetZoneScopedMobTable(root, zoneName, create)
    if type(root) ~= "table" then return nil end
    local resolved = AMA.ResolveZoneName(zoneName or "")
    if resolved == "" then return nil end
    local bucket = root[resolved]
    if bucket == nil and create then
        bucket = {}
        root[resolved] = bucket
    end
    if type(bucket) ~= "table" then
        if not create then return nil end
        bucket = {}
        root[resolved] = bucket
    end
    return bucket
end

function AMA.GetZoneMobOverrides(zoneName, create)
    if not AutoMarkAssistDB then return nil end
    AutoMarkAssistDB.mobOverrides = AutoMarkAssistDB.mobOverrides or {}
    return AMA.GetZoneScopedMobTable(AutoMarkAssistDB.mobOverrides, zoneName, create)
end

function AMA.GetZoneMobRemovals(zoneName, create)
    if not AutoMarkAssistDB then return nil end
    AutoMarkAssistDB.mobRemovals = AutoMarkAssistDB.mobRemovals or {}
    return AMA.GetZoneScopedMobTable(AutoMarkAssistDB.mobRemovals, zoneName, create)
end

function AMA.GetZoneMobSubPriorities(zoneName, create)
    if not AutoMarkAssistDB then return nil end
    AutoMarkAssistDB.mobSubPriorities = AutoMarkAssistDB.mobSubPriorities or {}
    return AMA.GetZoneScopedMobTable(AutoMarkAssistDB.mobSubPriorities, zoneName, create)
end

-- Builds the effective mob DB for the requested zone by merging the base DB,
-- zone-scoped overrides/removals, then zone-specific additions.
function AMA.BuildZoneMobDB(zoneName)
    local resolved = AMA.ResolveZoneName(zoneName or "")
    if resolved == "" then return nil end
    local baseDB = AutoMarkAssist_MobDB and AutoMarkAssist_MobDB[resolved]
    if not baseDB then return nil end

    local merged = {}
    for k, v in pairs(baseDB) do merged[k] = v end

    if AutoMarkAssistDB then
        local overrides = AMA.GetZoneMobOverrides(resolved, false)
        local removals = AMA.GetZoneMobRemovals(resolved, false)
        local additions = AutoMarkAssistDB.zoneAdditions and AutoMarkAssistDB.zoneAdditions[resolved]

        if overrides then
            for k, v in pairs(overrides) do merged[k] = v end
        end
        if removals then
            for k in pairs(removals) do merged[k] = nil end
        end
        if additions then
            for k, v in pairs(additions) do merged[k] = v end
        end
    end

    return merged
end

-- Migrates legacy flat mobOverrides/mobRemovals tables into zone-scoped maps.
-- Ambiguous mob names are copied into every matching zone to preserve intent.
function AMA.NormalizeZoneScopedMobSettings()
    if not AutoMarkAssistDB then return end

    local index = GetMobZoneIndex()

    local function NormalizeMap(key)
        local raw = AutoMarkAssistDB[key]
        if type(raw) ~= "table" then
            AutoMarkAssistDB[key] = {}
            return
        end

        local normalized = {}
        for zoneName, bucket in pairs(raw) do
            if type(bucket) == "table" then
                normalized[zoneName] = {}
                for mobName, value in pairs(bucket) do
                    normalized[zoneName][mobName] = value
                end
            end
        end

        for mobName, value in pairs(raw) do
            if type(value) ~= "table" then
                local matches = index[mobName]
                if matches and #matches > 0 then
                    for _, zoneName in ipairs(matches) do
                        normalized[zoneName] = normalized[zoneName] or {}
                        normalized[zoneName][mobName] = value
                    end
                elseif AMA.currentZoneName and AMA.currentZoneName ~= "" then
                    local fallbackZone = AMA.ResolveZoneName(AMA.currentZoneName)
                    normalized[fallbackZone] = normalized[fallbackZone] or {}
                    normalized[fallbackZone][mobName] = value
                end
            end
        end

        AutoMarkAssistDB[key] = normalized
    end

    NormalizeMap("mobOverrides")
    NormalizeMap("mobRemovals")
    NormalizeMap("mobSubPriorities")
    if type(AutoMarkAssistDB.zoneAdditions) ~= "table" then
        AutoMarkAssistDB.zoneAdditions = {}
    end
end
