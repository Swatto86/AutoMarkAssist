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
    ["Dragonflayer Runecaster"]     = 8,   -- rune caster; interrupt
    ["Dragonflayer Spiritualist"]   = 8,   -- healer
    ["Dragonflayer Heartsplitter"]  = 8,   -- ranged; multishot
    ["Dragonflayer Strategist"]     = 8,   -- rallies nearby vrykul
    ["Tunneling Ghoul"]             = 5,     -- undead, shackleable
    ["Enslaved Proto-Drake"]        = 5,     -- dragonkin, CC-able
}

db["The Nexus"] = {
    ["Azure Magus"]                 = 8,   -- arcane missiles + polymorph
    ["Azure Warder"]                = 8,   -- mana burn + arcane torrent
    ["Mage Hunter Initiate"]        = 8,   -- spellsteal + caster
    ["Mage Hunter Ascendant"]       = 8,   -- anti-caster; dangerous
    ["Alliance Ranger"]             = 5,     -- humanoid, CC-able
    ["Horde Ranger"]                = 5,     -- humanoid, CC-able
    ["Chaotic Rift"]                = 8,   -- spawns adds
}

db["Azjol-Nerub"] = {
    ["Anubar Shadowcaster"]         = 8,   -- shadow bolt volley caster
    ["Anubar Venomancer"]           = 8,   -- poison + web venom
    ["Skittering Swarmer"]          = "SKIP",   -- mass swarm filler
    ["Skittering Infector"]         = 5,     -- beast, trappable
    ["Watcher Gashra"]              = 8,   -- web wrap + poison
}

db["Ahn'kahet: The Old Kingdom"] = {
    ["Twilight Apostle"]            = 8,   -- healer + shadow mend
    ["Twilight Darkcaster"]         = 8,   -- shadow bolt volley
    ["Twilight Necromancer"]        = 8,   -- raises undead adds
    ["Twilight Worshipper"]         = 5,     -- humanoid, CC-able
    ["Ahn'kahar Spell Flinger"]     = 8,   -- shadow + insanity caster
    ["Frostbringer"]                = 8,   -- frost caster
}

db["Drak'Tharon Keep"] = {
    ["Drakkari Shaman"]             = 8,   -- healer + lightning bolt
    ["Drakkari Medicine Man"]       = 8,   -- healer
    ["Drakkari Commander"]          = 8,   -- battle shout + whirlwind
    ["Risen Shadowcaster"]          = 8,   -- shadow caster
    ["Fetid Troll Corpse"]          = 5,     -- undead, shackleable
    ["Drakkari Bat"]                = 5,     -- beast, trappable
}

db["The Violet Hold"] = {
    ["Azure Captain"]               = 8,   -- rallies invaders
    ["Azure Sorceress"]             = 8,   -- arcane caster
    ["Azure Stalker"]               = 8,   -- stealth + burst
    ["Azure Binder"]                = 8,   -- portal channeler
    ["Azure Mage Slayer"]           = 5,     -- humanoid, CC-able
    ["Azure Scale Binder"]          = 8,   -- dragonkin caster
    ["Portal Keeper"]               = 8,   -- must die to close portal
}

db["Gundrak"] = {
    ["Drakkari Elemental"]          = 5,     -- elemental, banishable
    ["Drakkari Medicine Man"]       = 8,   -- healer
    ["Living Mojo"]                 = 5,     -- elemental, banishable
    ["Drakkari Fire Weaver"]        = 8,   -- fire caster
    ["Spitting Cobra"]              = 5,     -- beast, trappable
    ["Drakkari Earthshaker"]        = 8,   -- AoE stomp caster
}

db["Halls of Stone"] = {
    ["Dark Rune Theurgist"]         = 8,   -- lightning bolt caster
    ["Dark Rune Stormcaller"]       = 8,   -- chain lightning
    ["Dark Rune Scholar"]           = 8,   -- shadow caster
    ["Dark Rune Elementalist"]      = 8,   -- summons elementals
    ["Dark Rune Protector"]         = 5,     -- humanoid, CC-able
}

db["Halls of Lightning"] = {
    ["Stormforged Tactician"]       = 8,   -- tactical strike + charge
    ["Stormforged Mender"]          = 8,   -- healer; top priority
    ["Stormfury Revenant"]          = 8,   -- lightning caster
    ["Slag"]                        = 5,     -- elemental, banishable
    ["Hardened Steel Berserker"]     = 8,   -- Enrage + whirlwind
}

db["The Oculus"] = {
    ["Azure Ley-Whelp"]            = 5,     -- dragonkin, CC-able
    ["Mage-Lord Urom"]             = 8,   -- caster boss (not auto-detected in trash form)
    ["Constructed Arcane Wraith"]   = 8,   -- arcane caster
    ["Phantasmal Air"]              = 5,     -- elemental, banishable
}

db["Culling of Stratholme"] = {
    ["Dark Necromancer"]            = 8,   -- raises undead
    ["Enraged Ghoul"]               = 5,     -- undead, shackleable
    ["Acolyte"]                     = 8,   -- caster + shadow
    ["Master Necromancer"]          = 8,   -- raises undead; interrupt
    ["Infinite Corruptor Agent"]    = 8,   -- optional timed boss add
    ["Ghoul"]                       = "SKIP",   -- mass zombie filler
    ["Risen Zombie"]                = "SKIP",   -- mass zombie filler
}

db["Utgarde Pinnacle"] = {
    ["Dragonflayer Seer"]           = 8,   -- healer + lightning
    ["Ymirjar Witch Doctor"]        = 8,   -- healer + shadow bolt
    ["Ymirjar Berserker"]           = 8,   -- Enrage + heavy melee
    ["Ymirjar Harpooner"]           = 8,   -- ranged; harpoon pull
    ["Savage Worg"]                 = 5,     -- beast, trappable
    ["Ymirjar Dusk Shaman"]         = 8,   -- shadow caster
    ["Dragonflayer Fanatic"]        = 5,     -- humanoid, CC-able
}

db["Trial of the Champion"] = {
    ["Argent Confessor"]            = 8,   -- healer
    ["Argent Lightwielder"]         = 8,   -- holy caster + heal
    ["Argent Priestess"]            = 8,   -- healer
    ["Black Knight's Ghoul"]        = "SKIP",   -- summoned filler
}

db["The Forge of Souls"] = {
    ["Soulguard Animator"]          = 8,   -- raises dead; shadow caster
    ["Soulguard Adept"]             = 8,   -- shadow caster
    ["Soulguard Bonecaster"]        = 8,   -- bone volley caster
    ["Soul Horror"]                 = 5,     -- undead, shackleable
    ["Spiteful Apparition"]         = "SKIP",   -- mass spirit filler
}

db["Pit of Saron"] = {
    ["Deathwhisper Necrolyte"]      = 8,   -- healer + shadow
    ["Deathwhisper Shadowcaster"]   = 8,   -- shadow bolt volley
    ["Deathwhisper Torturer"]       = 8,   -- curse + pain caster
    ["Ymirjar Skycaller"]           = 8,   -- frost + lightning caster
    ["Ymirjar Flamebearer"]         = 8,   -- fire caster
    ["Fallen Warrior"]              = 5,     -- undead, shackleable
}

db["Halls of Reflection"] = {
    ["Phantom Mage"]                = 8,   -- fireball + flamestrike
    ["Tortured Rifleman"]           = 8,   -- ranged; shoot + curse
    ["Shadowy Mercenary"]           = 8,   -- stealth + backstab
    ["Ghostly Priest"]              = 8,   -- healer
    ["Dark Ranger"]                 = 8,   -- ranged + magic
}

-- ============================================================
-- WRATH OF THE LICH KING RAIDS
-- ============================================================

db["Vault of Archavon"] = {
    ["Tempest Minion"]              = 8,   -- Emalon add; kill on Overcharge
    ["Tempest Warder"]              = 8,   -- dangerous caster support
}

db["The Obsidian Sanctum"] = {
    ["Acolyte of Shadron"]          = 8,   -- portal add; kill quickly
    ["Acolyte of Vesperon"]         = 8,   -- portal add; kill quickly
    ["Disciple of Shadron"]         = 8,   -- twilight add support
    ["Disciple of Vesperon"]        = 8,   -- twilight add support
    ["Onyx Blaze Mistress"]         = 8,   -- caster trash
    ["Onyx Flight Captain"]         = 8,   -- dangerous dragonkin support
}

db["The Eye of Eternity"] = {
    ["Power Spark"]                 = 8,   -- must die before it reaches Malygos
    ["Nexus Lord"]                  = 8,   -- caster add
    ["Scion of Eternity"]           = 8,   -- ranged dragon phase add
}

db["Ulduar"] = {
    ["Dark Rune Acolyte"]           = 8,   -- healer trash
    ["Dark Rune Champion"]          = 8,   -- dangerous melee + whirlwind
    ["Dark Rune Evoker"]            = 8,   -- caster trash
    ["Dark Rune Thunderer"]         = 8,   -- chain lightning trash
    ["Dark Rune Watcher"]           = 8,   -- dangerous ranged trash
    ["Iron Mender"]                 = 8,   -- healer support on the gauntlet
    ["Lightning Charged Iron Dwarf"] = 8,  -- dangerous caster add
    ["Forge Construct"]             = 8,   -- dangerous forge trash
    ["Ancient Conservator"]         = 8,   -- silence aura; kill quickly
    ["Guardian of Life"]            = 8,
    ["Nature's Blade"]              = 8,
    ["Snaplasher"]                  = 8,
    ["Ancient Water Spirit"]        = 8,
    ["Storm Lasher"]                = 8,
    ["Sanctum Sentry"]              = 8,   -- Auriaya pull add
    ["Feral Defender"]              = 8,   -- Auriaya add
    ["Assault Bot"]                 = 8,   -- Mimiron priority add
    ["Runemaster Molgeim"]          = 8,   -- Iron Council focus target
    ["Stormcaller Brundir"]         = 8,   -- Iron Council focus target
    ["Steelbreaker"]                = 8,   -- Iron Council focus target
    ["Corruptor Tentacle"]          = 8,
    ["Crusher Tentacle"]            = 8,
    ["Constrictor Tentacle"]        = 8,
    ["Guardian of Yogg-Saron"]      = 8,
    ["Deathsworn Zealot"]           = 8,   -- General Vezax add
    ["Saronite Animus"]             = 8,   -- General Vezax hard mode add
    ["Immortal Guardian"]           = 8,   -- Yogg-Saron phase 3 add
}

db["Trial of the Crusader"] = {
    ["Snobold Vassal"]              = 8,   -- Gormok add
    ["Mistress of Pain"]            = 8,   -- Jaraxxus add
    ["Felflame Infernal"]           = 8,   -- Jaraxxus add
    ["Nether Portal"]               = 8,   -- spawns Mistress of Pain
    ["Infernal Volcano"]            = 8,   -- spawns infernals
    ["Nerubian Burrower"]           = 8,   -- Anub'arak add
    ["Swarm Scarab"]                = "SKIP",   -- filler scarabs during Anub'arak
}

db["Icecrown Citadel"] = {
    ["Blazing Skeleton"]            = 8,   -- Valithria add
    ["Blood Beast"]                 = 8,   -- Saurfang add
    ["Cult Adherent"]               = 8,   -- Deathwhisper caster add
    ["Cult Fanatic"]                = 8,   -- Deathwhisper melee add
    ["Darkfallen Archmage"]         = 8,   -- Blood wing caster trash
    ["Darkfallen Blood Knight"]     = 8,   -- dangerous self-healing melee
    ["Darkfallen Tactician"]        = 8,
    ["Deathspeaker Attendant"]      = 8,
    ["Deathspeaker Disciple"]       = 8,
    ["Deathspeaker High Priest"]    = 8,
    ["Nerub'ar Broodkeeper"]        = 8,
    ["Nerub'ar Webweaver"]          = 8,
    ["Plague Scientist"]            = 8,
    ["Pustulating Horror"]          = 8,
    ["Shambling Horror"]            = 8,   -- Lich King phase 1 add
    ["Raging Spirit"]               = 8,   -- Lich King transition add
    ["Servant of the Throne"]       = 8,
    ["Val'kyr Herald"]              = 8,
    ["Val'kyr Shadowguard"]         = 8,
    ["Vampiric Fiend"]              = 8,
    ["Volatile Ooze"]               = 8,   -- Putricide add
    ["Gas Cloud"]                   = 8,   -- Putricide add
    ["Frostwarden Sorceress"]       = 8,
    ["Ymirjar Frostbinder"]         = 8,
    ["Ymirjar Huntress"]            = 8,
}

db["The Ruby Sanctum"] = {
    ["Charscale Commander"]         = 8,   -- dangerous trash caster/support
    ["Charscale Invoker"]           = 8,   -- dangerous trash caster/support
    ["Onyx Flamecaller"]            = 8,   -- dangerous dragonkin caster
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
