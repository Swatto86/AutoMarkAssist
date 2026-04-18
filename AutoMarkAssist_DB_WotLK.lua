-- AutoMarkAssist_DB_WotLK.lua
-- Wrath of the Lich King dungeon and raid entries.
-- Loaded AFTER AutoMarkAssist_DB_TBC.lua; merges 23 WotLK zones.

local db      = AutoMarkAssist_MobDB
local aliases = AutoMarkAssist_ZoneAliases
local order   = AutoMarkAssist_ExpansionOrder

-- ============================================================
-- WRATH OF THE LICH KING DUNGEONS
-- ============================================================

db["Utgarde Keep"] = {
    ["Dragonflayer Runecaster"]     = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
    ["Dragonflayer Spiritualist"]   = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Dragonflayer Heartsplitter"]  = { mark = 8, creatureType = "Humanoid" },
    ["Dragonflayer Strategist"]     = { mark = 8, creatureType = "Humanoid" },
    ["Dragonflayer Ironhelm"]       = { mark = 5, creatureType = "Humanoid" },
    ["Dragonflayer Weaponmaster"]   = { mark = 5, creatureType = "Humanoid" },
    ["Dragonflayer Forge Master"]   = { mark = 5, creatureType = "Humanoid" },
    ["Dragonflayer Bonecrusher"]    = { mark = 5, creatureType = "Humanoid" },
    ["Tunneling Ghoul"]             = { mark = 5, creatureType = "Undead" },
    ["Savage Worg"]                 = { mark = 5, creatureType = "Beast" },
    ["Proto-Drake Handler"]         = { mark = 8, creatureType = "Humanoid" },
    ["Enslaved Proto-Drake"]        = { mark = 5, creatureType = "Dragonkin" },
}

db["The Nexus"] = {
    ["Azure Magus"]                 = { mark = 8, creatureType = "Humanoid" },
    ["Azure Warder"]                = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
    ["Mage Hunter Initiate"]        = { mark = 8, creatureType = "Humanoid" },
    ["Mage Hunter Ascendant"]       = { mark = 8, creatureType = "Humanoid" },
    ["Alliance Ranger"]             = { mark = 5, creatureType = "Humanoid" },
    ["Alliance Commander"]          = { mark = 5, creatureType = "Humanoid" },
    ["Alliance Berserker"]          = { mark = 5, creatureType = "Humanoid" },
    ["Alliance Cleric"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Horde Ranger"]                = { mark = 5, creatureType = "Humanoid" },
    ["Horde Commander"]             = { mark = 5, creatureType = "Humanoid" },
    ["Horde Berserker"]             = { mark = 5, creatureType = "Humanoid" },
    ["Horde Shaman"]                = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Chaotic Rift"]                = { mark = 8, creatureType = "Elemental", ccImmune = true },
}

db["Azjol-Nerub"] = {
    ["Anubar Shadowcaster"]         = { mark = 8, creatureType = "Humanoid" },
    ["Anubar Venomancer"]           = { mark = 8, creatureType = "Humanoid" },
    ["Anub'ar Warrior"]             = { mark = 5, creatureType = "Humanoid" },
    ["Anub'ar Crypt Fiend"]         = { mark = 5, creatureType = "Humanoid" },
    ["Anub'ar Champion"]            = { mark = 5, creatureType = "Humanoid" },
    ["Anub'ar Crusher"]             = { mark = 5, creatureType = "Humanoid" },
    ["Anub'ar Necromancer"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Skittering Swarmer"]          = "SKIP",
    ["Skittering Infector"]         = { mark = 5, creatureType = "Beast" },
    ["Watcher Gashra"]              = { mark = 8, creatureType = "Humanoid" },
    ["Watcher Narjil"]              = { mark = 8, creatureType = "Humanoid" },
    ["Watcher Silthik"]             = { mark = 8, creatureType = "Humanoid" },
}

db["Ahn'kahet: The Old Kingdom"] = {
    ["Twilight Apostle"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Twilight Darkcaster"]         = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Necromancer"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Twilight Worshipper"]         = { mark = 5, creatureType = "Humanoid" },
    ["Twilight Elementalist"]       = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Keeper Havunth"]     = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Keeper Exeter"]      = { mark = 8, creatureType = "Humanoid" },
    ["Ahn'kahar Spell Flinger"]     = { mark = 8, creatureType = "Humanoid" },
    ["Ahn'kahar Guardian"]          = { mark = 5, creatureType = "Humanoid" },
    ["Ahn'kahar Tunneler"]          = { mark = 5, creatureType = "Humanoid" },
    ["Ahn'kahar Swarmer"]           = "SKIP",
    ["Frostbringer"]                = { mark = 8, creatureType = "Humanoid" },
    ["Faceless Watcher"]            = { mark = 8, creatureType = "Aberration", ccImmune = true },
}

db["Drak'Tharon Keep"] = {
    ["Drakkari Shaman"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Drakkari Medicine Man"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Drakkari Guardian"]           = { mark = 5, creatureType = "Humanoid" },
    ["Drakkari Rhino Rider"]        = { mark = 5, creatureType = "Humanoid" },
    ["Drakkari Frost Rager"]        = { mark = 5, creatureType = "Humanoid" },
    ["Drakkari Gutripper"]          = { mark = 5, creatureType = "Humanoid" },
    ["Drakkari Invader"]            = { mark = 5, creatureType = "Humanoid" },
    ["Risen Shadowcaster"]          = { mark = 8, creatureType = "Undead" },
    ["Risen Drakkari Warrior"]      = { mark = 5, creatureType = "Undead" },
    ["Risen Drakkari Soldier"]      = { mark = 5, creatureType = "Undead" },
    ["Fetid Troll Corpse"]          = { mark = 5, creatureType = "Undead" },
    ["Scourge Brute"]               = { mark = 5, creatureType = "Undead" },
    ["Drakkari Bat"]                = { mark = 5, creatureType = "Beast" },
    ["Drakkari Bat Rider"]          = { mark = 8, creatureType = "Humanoid" },
    ["Raptor Rider"]                = { mark = 8, creatureType = "Humanoid" },
}

db["The Violet Hold"] = {
    ["Azure Captain"]               = { mark = 8, creatureType = "Humanoid" },
    ["Azure Sorceress"]             = { mark = 8, creatureType = "Humanoid" },
    ["Azure Stalker"]               = { mark = 8, creatureType = "Humanoid" },
    ["Azure Binder"]                = { mark = 8, creatureType = "Humanoid" },
    ["Azure Raider"]                = { mark = 5, creatureType = "Humanoid" },
    ["Azure Spellbreaker"]          = { mark = 8, creatureType = "Humanoid" },
    ["Azure Invader"]               = { mark = 5, creatureType = "Humanoid" },
    ["Azure Mage Slayer"]           = { mark = 5, creatureType = "Humanoid" },
    ["Azure Scale Binder"]          = { mark = 8, creatureType = "Dragonkin" },
    ["Azure Dragonspawn"]           = { mark = 5, creatureType = "Dragonkin" },
    ["Azure Drake"]                 = { mark = 8, creatureType = "Dragonkin" },
    ["Azure Whelp"]                 = "SKIP",
    ["Portal Keeper"]               = { mark = 8, creatureType = "Humanoid", ccImmune = true },
    ["Portal Guardian"]             = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Crystalline Frost Reaver"]    = { mark = 5, creatureType = "Elemental" },
    ["Ethereal Sorcerer"]           = { mark = 8, creatureType = "Elemental" },
    ["Ethereal Wraith"]             = { mark = 5, creatureType = "Elemental" },
    ["Arcane Sentry"]               = { mark = 8, creatureType = "Mechanical", ccImmune = true },
}

db["Gundrak"] = {
    ["Drakkari Elemental"]          = { mark = 4, creatureType = "Elemental" },
    ["Drakkari Medicine Man"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Drakkari Fire Weaver"]        = { mark = 8, creatureType = "Humanoid" },
    ["Drakkari Earthshaker"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
    ["Drakkari Frostweaver"]        = { mark = 8, creatureType = "Humanoid" },
    ["Drakkari Guardian"]           = { mark = 5, creatureType = "Humanoid" },
    ["Drakkari Scout"]              = { mark = 5, creatureType = "Humanoid" },
    ["Drakkari Impaler"]            = { mark = 5, creatureType = "Humanoid" },
    ["Drakkari Battlerider"]        = { mark = 5, creatureType = "Humanoid" },
    ["Gundrak Savage"]              = { mark = 5, creatureType = "Humanoid" },
    ["Gundrak Mauler"]              = { mark = 5, creatureType = "Humanoid" },
    ["Living Mojo"]                 = { mark = 4, creatureType = "Elemental" },
    ["Spitting Cobra"]              = { mark = 5, creatureType = "Beast" },
}

db["Halls of Stone"] = {
    ["Dark Rune Theurgist"]         = { mark = 8, creatureType = "Humanoid" },
    ["Dark Rune Stormcaller"]       = { mark = 8, creatureType = "Humanoid" },
    ["Dark Rune Scholar"]           = { mark = 8, creatureType = "Humanoid" },
    ["Dark Rune Elementalist"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Dark Rune Protector"]         = { mark = 5, creatureType = "Humanoid" },
    ["Dark Rune Warden"]            = { mark = 5, creatureType = "Humanoid" },
    ["Dark Rune Worker"]            = { mark = 5, creatureType = "Humanoid" },
    ["Dark Rune Shaper"]            = { mark = 5, creatureType = "Humanoid" },
    ["Iron Golem Custodian"]        = { mark = 5, creatureType = "Mechanical", ccImmune = true },
    ["Dark Matter"]                 = { mark = 5, creatureType = "Elemental" },
    ["Tribunal Arbiter"]            = { mark = 8, creatureType = "Humanoid", ccImmune = true },
    ["Seething Revenant"]           = { mark = 5, creatureType = "Elemental" },
}

db["Halls of Lightning"] = {
    ["Stormforged Tactician"]       = { mark = 8, creatureType = "Humanoid" },
    ["Stormforged Mender"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Stormforged Eradicator"]      = { mark = 5, creatureType = "Humanoid" },
    ["Stormforged Lieutenant"]      = { mark = 5, creatureType = "Humanoid" },
    ["Stormforged Sentinel"]        = { mark = 5, creatureType = "Humanoid" },
    ["Stormforged Soldier"]         = { mark = 5, creatureType = "Humanoid" },
    ["Stormforged Infiltrator"]     = { mark = 8, creatureType = "Humanoid" },
    ["Stormforged Peacekeeper"]     = { mark = 5, creatureType = "Humanoid" },
    ["Stormfury Revenant"]          = { mark = 5, creatureType = "Elemental" },
    ["Titanium Vanguard"]           = { mark = 5, creatureType = "Mechanical", ccImmune = true },
    ["Slag"]                        = { mark = 5, creatureType = "Elemental" },
    ["Molten Golem"]                = { mark = 5, creatureType = "Elemental" },
    ["Hardened Steel Berserker"]    = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
}

db["The Oculus"] = {
    ["Azure Ley-Whelp"]             = { mark = 5, creatureType = "Dragonkin" },
    ["Greater Ley-Whelp"]           = { mark = 5, creatureType = "Dragonkin" },
    ["Centrifuge Core"]             = { mark = 5, creatureType = "Elemental", ccImmune = true },
    ["Unbound Emanation"]           = { mark = 5, creatureType = "Elemental" },
    ["Mage-Lord Urom"]              = { mark = 8, creatureType = "Humanoid" },
    ["Phantasmal Mage"]             = { mark = 8, creatureType = "Elemental" },
    ["Phantasmal Cloud Scraper"]    = { mark = 8, creatureType = "Elemental" },
    ["Phantasmal Ambusher"]         = { mark = 5, creatureType = "Elemental" },
    ["Constructed Arcane Wraith"]   = { mark = 8, creatureType = "Elemental" },
    ["Phantasmal Air"]              = { mark = 4, creatureType = "Elemental" },
    ["Phantasmal Water"]            = { mark = 5, creatureType = "Elemental" },
    ["Phantasmal Flamewaker"]       = { mark = 5, creatureType = "Elemental" },
}

db["Culling of Stratholme"] = {
    ["Dark Necromancer"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Master Necromancer"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Acolyte"]                     = { mark = 8, creatureType = "Humanoid" },
    ["Cultist"]                     = { mark = 5, creatureType = "Humanoid" },
    ["Enraged Ghoul"]               = { mark = 5, creatureType = "Undead" },
    ["Scourge Hulk"]                = { mark = 8, creatureType = "Undead" },
    ["Tomb Horror"]                 = { mark = 8, creatureType = "Undead" },
    ["Tomb Guardian"]               = { mark = 5, creatureType = "Undead" },
    ["Infinite Adversary"]          = { mark = 8, creatureType = "Humanoid" },
    ["Infinite Agent"]              = { mark = 8, creatureType = "Humanoid" },
    ["Infinite Hunter"]             = { mark = 8, creatureType = "Humanoid" },
    ["Infinite Assassin"]           = { mark = 8, creatureType = "Humanoid" },
    ["Infinite Corruptor Agent"]    = { mark = 8, creatureType = "Humanoid" },
    ["Infinite Chrono-Lord"]        = { mark = 8, creatureType = "Humanoid" },
    ["Ghoul"]                       = "SKIP",
    ["Risen Zombie"]                = "SKIP",
    ["Zombie"]                      = "SKIP",
}

db["Utgarde Pinnacle"] = {
    ["Dragonflayer Seer"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Dragonflayer Runecaster"]     = { mark = 8, creatureType = "Humanoid" },
    ["Dragonflayer Fanatic"]        = { mark = 5, creatureType = "Humanoid" },
    ["Dragonflayer Ironhelm"]       = { mark = 5, creatureType = "Humanoid" },
    ["Dragonflayer Impaler"]        = { mark = 5, creatureType = "Humanoid" },
    ["Dragonflayer Forge Master"]   = { mark = 5, creatureType = "Humanoid" },
    ["Ymirjar Witch Doctor"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Ymirjar Berserker"]           = { mark = 8, creatureType = "Humanoid" },
    ["Ymirjar Harpooner"]           = { mark = 8, creatureType = "Humanoid" },
    ["Ymirjar Dusk Shaman"]         = { mark = 8, creatureType = "Humanoid" },
    ["Ymirjar Deathbringer"]        = { mark = 5, creatureType = "Humanoid" },
    ["Savage Worg"]                 = { mark = 5, creatureType = "Beast" },
    ["Frenzied Worg"]               = { mark = 5, creatureType = "Beast" },
    ["Gortok Palehoof"]             = { mark = 8, creatureType = "Humanoid" },
}

db["Trial of the Champion"] = {
    ["Argent Confessor"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Argent Lightwielder"]         = { mark = 8, creatureType = "Humanoid" },
    ["Argent Priestess"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Argent Monk"]                 = { mark = 5, creatureType = "Humanoid" },
    ["Black Knight's Ghoul"]        = "SKIP",
    ["Risen Jaeren Sunsworn"]       = { mark = 8, creatureType = "Undead" },
    ["Risen Arelas Brightstar"]     = { mark = 8, creatureType = "Undead" },
}

db["The Forge of Souls"] = {
    ["Soulguard Animator"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Soulguard Adept"]             = { mark = 8, creatureType = "Humanoid" },
    ["Soulguard Bonecaster"]        = { mark = 8, creatureType = "Humanoid" },
    ["Soulguard Commander"]         = { mark = 5, creatureType = "Humanoid" },
    ["Soulguard Reaper"]            = { mark = 5, creatureType = "Humanoid" },
    ["Soulguard Enforcer"]          = { mark = 5, creatureType = "Humanoid" },
    ["Soul Horror"]                 = { mark = 5, creatureType = "Undead" },
    ["Tortured Soul"]               = { mark = 5, creatureType = "Undead" },
    ["Spiteful Apparition"]         = "SKIP",
}

db["Pit of Saron"] = {
    ["Deathwhisper Necrolyte"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Deathwhisper Shadowcaster"]   = { mark = 8, creatureType = "Humanoid" },
    ["Deathwhisper Torturer"]       = { mark = 8, creatureType = "Humanoid" },
    ["Ymirjar Skycaller"]           = { mark = 8, creatureType = "Humanoid" },
    ["Ymirjar Flamebearer"]         = { mark = 8, creatureType = "Humanoid" },
    ["Ymirjar Wrathbringer"]        = { mark = 5, creatureType = "Humanoid" },
    ["Fallen Warrior"]              = { mark = 5, creatureType = "Undead" },
    ["Wrathbone Coldwraith"]        = { mark = 8, creatureType = "Undead" },
    ["Wrathbone Laborer"]           = { mark = 5, creatureType = "Undead" },
    ["Wrathbone Sorcerer"]          = { mark = 8, creatureType = "Undead" },
    ["Iron Dwarf Overseer"]         = { mark = 5, creatureType = "Humanoid" },
    ["Plagueborn Horror"]           = { mark = 5, creatureType = "Undead" },
    ["Plagueborn Thrasher"]         = { mark = 5, creatureType = "Undead" },
}

db["Halls of Reflection"] = {
    ["Phantom Mage"]                = { mark = 8, creatureType = "Undead" },
    ["Tortured Rifleman"]           = { mark = 8, creatureType = "Undead" },
    ["Shadowy Mercenary"]           = { mark = 8, creatureType = "Undead" },
    ["Ghostly Priest"]              = { mark = 8, creatureType = "Undead", dangerLevel = 3 },
    ["Dark Ranger"]                 = { mark = 8, creatureType = "Undead" },
    ["Spectral Footman"]            = { mark = 5, creatureType = "Undead" },
    ["Risen Witch Doctor"]          = { mark = 8, creatureType = "Undead" },
}

-- ============================================================
-- WRATH OF THE LICH KING RAIDS
-- ============================================================

db["Vault of Archavon"] = {
    ["Tempest Minion"]              = { mark = 8, creatureType = "Elemental" },
    ["Tempest Warder"]              = { mark = 8, creatureType = "Elemental" },
    ["Unyielding Construct"]        = { mark = 8, creatureType = "Elemental" },
    ["Cyanigosa"]                   = { mark = 8, creatureType = "Dragonkin" },
}

db["The Obsidian Sanctum"] = {
    ["Acolyte of Shadron"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Acolyte of Vesperon"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Disciple of Shadron"]         = { mark = 8, creatureType = "Humanoid" },
    ["Disciple of Vesperon"]        = { mark = 8, creatureType = "Humanoid" },
    ["Onyx Blaze Mistress"]         = { mark = 8, creatureType = "Humanoid" },
    ["Onyx Flight Captain"]         = { mark = 8, creatureType = "Dragonkin" },
    ["Onyxian Whelp"]               = "SKIP",
    ["Black Dragonspawn"]           = { mark = 5, creatureType = "Dragonkin" },
    ["Twilight Drake"]              = { mark = 8, creatureType = "Dragonkin" },
}

db["The Eye of Eternity"] = {
    ["Power Spark"]                 = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Nexus Lord"]                  = { mark = 8, creatureType = "Humanoid" },
    ["Scion of Eternity"]           = { mark = 8, creatureType = "Humanoid" },
}

db["Ulduar"] = {
    ["Dark Rune Acolyte"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Dark Rune Champion"]          = { mark = 8, creatureType = "Humanoid" },
    ["Dark Rune Evoker"]            = { mark = 8, creatureType = "Humanoid" },
    ["Dark Rune Thunderer"]         = { mark = 8, creatureType = "Humanoid" },
    ["Dark Rune Watcher"]           = { mark = 8, creatureType = "Humanoid" },
    ["Dark Rune Warbringer"]        = { mark = 5, creatureType = "Humanoid" },
    ["Dark Rune Guardian"]          = { mark = 5, creatureType = "Humanoid" },
    ["Iron Mender"]                 = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Lightning Charged Iron Dwarf"] = { mark = 8, creatureType = "Humanoid" },
    ["Forge Construct"]             = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Iron Vrykul"]                 = { mark = 5, creatureType = "Humanoid" },
    ["Winter Jormungar"]            = { mark = 5, creatureType = "Beast" },
    ["Jormungar Behemoth"]          = { mark = 5, creatureType = "Beast" },
    ["Flash Freeze"]                = "SKIP",
    ["Ancient Conservator"]         = { mark = 8, creatureType = "Elemental" },
    ["Guardian of Life"]            = { mark = 8, creatureType = "Elemental" },
    ["Nature's Blade"]              = { mark = 8, creatureType = "Elemental" },
    ["Snaplasher"]                  = { mark = 8, creatureType = "Elemental" },
    ["Ancient Water Spirit"]        = { mark = 8, creatureType = "Elemental" },
    ["Storm Lasher"]                = { mark = 8, creatureType = "Elemental" },
    ["Sanctum Sentry"]              = { mark = 8, creatureType = "Beast" },
    ["Feral Defender"]              = { mark = 8, creatureType = "Beast" },
    ["Swarming Guardian"]           = { mark = 5, creatureType = "Elemental" },
    ["Assault Bot"]                 = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Junk Bot"]                    = { mark = 5, creatureType = "Mechanical", ccImmune = true },
    ["Boom Bot"]                    = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Bomb Bot"]                    = "SKIP",
    ["Emergency Fire Bot"]          = { mark = 5, creatureType = "Mechanical", ccImmune = true },
    ["Runemaster Molgeim"]          = { mark = 8, creatureType = "Humanoid" },
    ["Stormcaller Brundir"]         = { mark = 8, creatureType = "Humanoid" },
    ["Steelbreaker"]                = { mark = 8, creatureType = "Humanoid" },
    ["Corruptor Tentacle"]          = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Crusher Tentacle"]            = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Constrictor Tentacle"]        = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Guardian of Yogg-Saron"]      = { mark = 8, creatureType = "Aberration" },
    ["Deathsworn Zealot"]           = { mark = 8, creatureType = "Humanoid" },
    ["Faceless Horror"]             = { mark = 8, creatureType = "Aberration" },
    ["Saronite Animus"]             = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Saronite Vapors"]             = "SKIP",
    ["Immortal Guardian"]           = { mark = 8, creatureType = "Humanoid" },
}

db["Trial of the Crusader"] = {
    ["Snobold Vassal"]              = { mark = 8, creatureType = "Humanoid" },
    ["Mistress of Pain"]            = { mark = 8, creatureType = "Demon" },
    ["Felflame Infernal"]           = { mark = 8, creatureType = "Elemental" },
    ["Nether Portal"]               = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Infernal Volcano"]            = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Nerubian Burrower"]           = { mark = 8, creatureType = "Humanoid" },
    ["Swarm Scarab"]                = "SKIP",
}

db["Icecrown Citadel"] = {
    ["Blazing Skeleton"]            = { mark = 8, creatureType = "Undead" },
    ["Blood Beast"]                 = { mark = 8, creatureType = "Undead" },
    ["Cult Adherent"]               = { mark = 8, creatureType = "Humanoid" },
    ["Deformed Fanatic"]            = { mark = 5, creatureType = "Humanoid" },
    ["Cult Fanatic"]                = { mark = 8, creatureType = "Humanoid" },
    ["Reanimated Adherent"]         = { mark = 8, creatureType = "Undead" },
    ["Reanimated Fanatic"]          = { mark = 8, creatureType = "Undead" },
    ["Empowered Adherent"]          = { mark = 8, creatureType = "Humanoid" },
    ["Darkfallen Noble"]            = { mark = 8, creatureType = "Undead" },
    ["Darkfallen Archmage"]         = { mark = 8, creatureType = "Undead" },
    ["Darkfallen Blood Knight"]     = { mark = 8, creatureType = "Undead", dangerLevel = 2 },
    ["Darkfallen Tactician"]        = { mark = 8, creatureType = "Undead" },
    ["Darkfallen Commander"]        = { mark = 5, creatureType = "Undead" },
    ["Darkfallen Lieutenant"]       = { mark = 5, creatureType = "Undead" },
    ["Darkfallen Advisor"]          = { mark = 8, creatureType = "Undead" },
    ["Deathspeaker Attendant"]      = { mark = 8, creatureType = "Humanoid" },
    ["Deathspeaker Disciple"]       = { mark = 8, creatureType = "Humanoid" },
    ["Deathspeaker High Priest"]    = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Deathspeaker Zealot"]         = { mark = 5, creatureType = "Humanoid" },
    ["Nerub'ar Broodkeeper"]        = { mark = 8, creatureType = "Humanoid" },
    ["Nerub'ar Webweaver"]          = { mark = 8, creatureType = "Humanoid" },
    ["Plague Scientist"]            = { mark = 8, creatureType = "Humanoid" },
    ["Pustulating Horror"]          = { mark = 8, creatureType = "Undead" },
    ["Stinky"]                      = { mark = 8, creatureType = "Undead" },
    ["Precious"]                    = { mark = 8, creatureType = "Undead" },
    ["Shambling Horror"]            = { mark = 8, creatureType = "Undead" },
    ["Raging Spirit"]               = { mark = 8, creatureType = "Undead" },
    ["Risen Archmage"]              = { mark = 8, creatureType = "Undead" },
    ["Servant of the Throne"]       = { mark = 5, creatureType = "Undead" },
    ["Val'kyr Herald"]              = { mark = 8, creatureType = "Undead" },
    ["Val'kyr Shadowguard"]         = { mark = 8, creatureType = "Undead" },
    ["Vampiric Fiend"]              = { mark = 5, creatureType = "Undead" },
    ["Volatile Ooze"]               = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Gas Cloud"]                   = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Frostwarden Sorceress"]       = { mark = 8, creatureType = "Humanoid" },
    ["Frostwarden Handler"]         = { mark = 5, creatureType = "Humanoid" },
    ["Frostwarden Warrior"]         = { mark = 5, creatureType = "Humanoid" },
    ["Ymirjar Frostbinder"]         = { mark = 8, creatureType = "Humanoid" },
    ["Ymirjar Huntress"]            = { mark = 8, creatureType = "Humanoid" },
    ["Ymirjar Battle-Maiden"]       = { mark = 5, creatureType = "Humanoid" },
    ["Ymirjar Warlord"]             = { mark = 5, creatureType = "Humanoid" },
    ["Broken Frostwing Whelp"]      = "SKIP",
    ["Dragonflayer Ironhelm"]       = { mark = 5, creatureType = "Humanoid" },
    ["Icy Ghoul"]                   = "SKIP",
}

db["The Ruby Sanctum"] = {
    ["Charscale Commander"]         = { mark = 8, creatureType = "Humanoid" },
    ["Charscale Invoker"]           = { mark = 8, creatureType = "Humanoid" },
    ["Charscale Bruiser"]           = { mark = 5, creatureType = "Humanoid" },
    ["Charscale Hatchling"]         = "SKIP",
    ["Onyx Flamecaller"]            = { mark = 8, creatureType = "Dragonkin" },
    ["Onyx Warder"]                 = { mark = 5, creatureType = "Dragonkin" },
}

-- ============================================================
-- ZONE ALIASES  (merged into the shared table)
-- ============================================================

local newAliases = {
    ["Utgarde Keep"]                    = "Utgarde Keep",
    ["Utgarde"]                         = "Utgarde Keep",
    ["The Nexus"]                       = "The Nexus",
    ["Nexus"]                           = "The Nexus",
    ["Azjol-Nerub"]                     = "Azjol-Nerub",
    ["Ahn'kahet: The Old Kingdom"]      = "Ahn'kahet: The Old Kingdom",
    ["Ahn'kahet"]                       = "Ahn'kahet: The Old Kingdom",
    ["Old Kingdom"]                     = "Ahn'kahet: The Old Kingdom",
    ["Drak'Tharon Keep"]                = "Drak'Tharon Keep",
    ["Drak'Tharon"]                     = "Drak'Tharon Keep",
    ["The Violet Hold"]                 = "The Violet Hold",
    ["Violet Hold"]                     = "The Violet Hold",
    ["Gundrak"]                         = "Gundrak",
    ["Halls of Stone"]                  = "Halls of Stone",
    ["Halls of Lightning"]              = "Halls of Lightning",
    ["The Oculus"]                      = "The Oculus",
    ["Oculus"]                          = "The Oculus",
    ["Culling of Stratholme"]           = "Culling of Stratholme",
    ["The Culling of Stratholme"]       = "Culling of Stratholme",
    ["Utgarde Pinnacle"]                = "Utgarde Pinnacle",
    ["Trial of the Champion"]           = "Trial of the Champion",
    ["The Forge of Souls"]              = "The Forge of Souls",
    ["Forge of Souls"]                  = "The Forge of Souls",
    ["Pit of Saron"]                    = "Pit of Saron",
    ["Halls of Reflection"]             = "Halls of Reflection",
    ["Vault of Archavon"]               = "Vault of Archavon",
    ["VoA"]                             = "Vault of Archavon",
    ["The Obsidian Sanctum"]            = "The Obsidian Sanctum",
    ["Obsidian Sanctum"]                = "The Obsidian Sanctum",
    ["OS"]                              = "The Obsidian Sanctum",
    ["The Eye of Eternity"]             = "The Eye of Eternity",
    ["Eye of Eternity"]                 = "The Eye of Eternity",
    ["EoE"]                             = "The Eye of Eternity",
    ["Ulduar"]                          = "Ulduar",
    ["Trial of the Crusader"]           = "Trial of the Crusader",
    ["Trial of the Grand Crusader"]     = "Trial of the Crusader",
    ["ToC"]                             = "Trial of the Crusader",
    ["TOC"]                             = "Trial of the Crusader",
    ["ToGC"]                            = "Trial of the Crusader",
    ["TOGC"]                            = "Trial of the Crusader",
    ["Icecrown Citadel"]                = "Icecrown Citadel",
    ["ICC"]                             = "Icecrown Citadel",
    ["The Ruby Sanctum"]                = "The Ruby Sanctum",
    ["Ruby Sanctum"]                    = "The Ruby Sanctum",
    ["RS"]                              = "The Ruby Sanctum",
}
for k, v in pairs(newAliases) do aliases[k] = v end

-- ============================================================
-- EXPANSION ORDER  (appended to the shared table)
-- ============================================================

table.insert(order, { name = "Wrath of the Lich King", dungeons = {
    "Utgarde Keep", "The Nexus", "Azjol-Nerub", "Ahn'kahet: The Old Kingdom",
    "Drak'Tharon Keep", "The Violet Hold", "Gundrak",
    "Halls of Stone", "Halls of Lightning", "The Oculus",
    "Culling of Stratholme", "Utgarde Pinnacle", "Trial of the Champion",
    "The Forge of Souls", "Pit of Saron", "Halls of Reflection",
}, raids = {
    "Vault of Archavon", "The Obsidian Sanctum", "The Eye of Eternity",
    "Ulduar", "Trial of the Crusader", "Icecrown Citadel", "The Ruby Sanctum",
}})
