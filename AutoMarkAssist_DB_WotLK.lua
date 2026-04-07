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
    ["Dragonflayer Runecaster"]     = "HIGH",   -- rune caster; interrupt
    ["Dragonflayer Spiritualist"]   = "HIGH",   -- healer
    ["Dragonflayer Heartsplitter"]  = "HIGH",   -- ranged; multishot
    ["Dragonflayer Strategist"]     = "HIGH",   -- rallies nearby vrykul
    ["Dragonflayer Ironhelm"]       = "MEDIUM",
    ["Dragonflayer Bonecrusher"]    = "MEDIUM",
    ["Dragonflayer Weaponsmith"]    = "MEDIUM",
    ["Tunneling Ghoul"]             = "CC",     -- undead, shackleable
    ["Enslaved Proto-Drake"]        = "CC",     -- dragonkin, CC-able
    ["Dragonflayer Metalworker"]    = "LOW",
}

db["The Nexus"] = {
    ["Azure Magus"]                 = "HIGH",   -- arcane missiles + polymorph
    ["Azure Warder"]                = "HIGH",   -- mana burn + arcane torrent
    ["Mage Hunter Initiate"]        = "HIGH",   -- spellsteal + caster
    ["Mage Hunter Ascendant"]       = "HIGH",   -- anti-caster; dangerous
    ["Crystalline Frayer"]          = "MEDIUM",
    ["Crystalline Protector"]       = "MEDIUM",
    ["Alliance Ranger"]             = "CC",     -- humanoid, CC-able
    ["Horde Ranger"]                = "CC",     -- humanoid, CC-able
    ["Chaotic Rift"]                = "HIGH",   -- spawns adds
    ["Crystalline Keeper"]          = "LOW",
}

db["Azjol-Nerub"] = {
    ["Anubar Crypt Fiend"]          = "MEDIUM",
    ["Anubar Skirmisher"]           = "MEDIUM",
    ["Anubar Champion"]             = "MEDIUM",
    ["Anubar Shadowcaster"]         = "HIGH",   -- shadow bolt volley caster
    ["Anubar Venomancer"]           = "HIGH",   -- poison + web venom
    ["Skittering Swarmer"]          = "SKIP",   -- mass swarm filler
    ["Skittering Infector"]         = "CC",     -- beast, trappable
    ["Anubar Crusher"]              = "MEDIUM",
    ["Watcher Gashra"]              = "HIGH",   -- web wrap + poison
}

db["Ahn'kahet: The Old Kingdom"] = {
    ["Twilight Apostle"]            = "HIGH",   -- healer + shadow mend
    ["Twilight Darkcaster"]         = "HIGH",   -- shadow bolt volley
    ["Twilight Necromancer"]        = "HIGH",   -- raises undead adds
    ["Twilight Worshipper"]         = "CC",     -- humanoid, CC-able
    ["Ahn'kahar Guardian"]          = "MEDIUM",
    ["Ahn'kahar Spell Flinger"]     = "HIGH",   -- shadow + insanity caster
    ["Frostbringer"]                = "HIGH",   -- frost caster
    ["Bonegrinder"]                 = "MEDIUM",
    ["Forgotten One"]               = "MEDIUM",
    ["Plague Walker"]               = "LOW",
}

db["Drak'Tharon Keep"] = {
    ["Drakkari Shaman"]             = "HIGH",   -- healer + lightning bolt
    ["Drakkari Medicine Man"]       = "HIGH",   -- healer
    ["Drakkari Commander"]          = "HIGH",   -- battle shout + whirlwind
    ["Drakkari Warrior"]            = "MEDIUM",
    ["Drakkari Guardian"]           = "MEDIUM",
    ["Risen Shadowcaster"]          = "HIGH",   -- shadow caster
    ["Fetid Troll Corpse"]          = "CC",     -- undead, shackleable
    ["Drakkari Bat"]                = "CC",     -- beast, trappable
    ["Scourge Brute"]               = "MEDIUM",
    ["Wretched Belcher"]            = "LOW",
}

db["The Violet Hold"] = {
    ["Azure Captain"]               = "HIGH",   -- rallies invaders
    ["Azure Sorceress"]             = "HIGH",   -- arcane caster
    ["Azure Raider"]                = "MEDIUM",
    ["Azure Stalker"]               = "HIGH",   -- stealth + burst
    ["Azure Invader"]               = "MEDIUM",
    ["Azure Binder"]                = "HIGH",   -- portal channeler
    ["Azure Mage Slayer"]           = "CC",     -- humanoid, CC-able
    ["Azure Scale Binder"]          = "HIGH",   -- dragonkin caster
    ["Portal Keeper"]               = "HIGH",   -- must die to close portal
    ["Portal Guardian"]             = "MEDIUM",
}

db["Gundrak"] = {
    ["Drakkari Elemental"]          = "CC",     -- elemental, banishable
    ["Drakkari Colossus"]           = "MEDIUM",
    ["Drakkari Golem"]              = "MEDIUM",
    ["Drakkari Medicine Man"]       = "HIGH",   -- healer
    ["Living Mojo"]                 = "CC",     -- elemental, banishable
    ["Drakkari Fire Weaver"]        = "HIGH",   -- fire caster
    ["Drakkari Rhino"]              = "MEDIUM",
    ["Spitting Cobra"]              = "CC",     -- beast, trappable
    ["Drakkari Lancer"]             = "MEDIUM",
    ["Drakkari Earthshaker"]        = "HIGH",   -- AoE stomp caster
}

db["Halls of Stone"] = {
    ["Dark Rune Theurgist"]         = "HIGH",   -- lightning bolt caster
    ["Dark Rune Stormcaller"]       = "HIGH",   -- chain lightning
    ["Dark Rune Scholar"]           = "HIGH",   -- shadow caster
    ["Dark Rune Elementalist"]      = "HIGH",   -- summons elementals
    ["Dark Rune Giant"]             = "MEDIUM",
    ["Dark Rune Warrior"]           = "MEDIUM",
    ["Dark Rune Protector"]         = "CC",     -- humanoid, CC-able
    ["Iron Trogg"]                  = "MEDIUM",
    ["Iron Golem Custodian"]        = "MEDIUM",
    ["Dark Rune Worker"]            = "LOW",
}

db["Halls of Lightning"] = {
    ["Stormforged Sentinel"]        = "MEDIUM",
    ["Stormforged Tactician"]       = "HIGH",   -- tactical strike + charge
    ["Stormforged Mender"]          = "HIGH",   -- healer; top priority
    ["Stormforged Construct"]       = "MEDIUM",
    ["Stormfury Revenant"]          = "HIGH",   -- lightning caster
    ["Slag"]                        = "CC",     -- elemental, banishable
    ["Hardened Steel Berserker"]     = "HIGH",   -- Enrage + whirlwind
    ["Hardened Steel Reaver"]       = "MEDIUM",
    ["Lightning Construct"]         = "MEDIUM",
    ["Titanium Vanguard"]           = "LOW",
}

db["The Oculus"] = {
    ["Azure Ring Guardian"]         = "MEDIUM",
    ["Azure Ley-Whelp"]            = "CC",     -- dragonkin, CC-able
    ["Centrifuge Construct"]        = "MEDIUM",
    ["Mage-Lord Urom"]             = "HIGH",   -- caster boss (not auto-detected in trash form)
    ["Phantasmal Mammoth"]          = "MEDIUM",
    ["Phantasmal Cloudscraper"]     = "MEDIUM",
    ["Constructed Arcane Wraith"]   = "HIGH",   -- arcane caster
    ["Phantasmal Air"]              = "CC",     -- elemental, banishable
}

db["Culling of Stratholme"] = {
    ["Crypt Fiend"]                 = "MEDIUM",
    ["Tomb Stalker"]                = "MEDIUM",
    ["Dark Necromancer"]            = "HIGH",   -- raises undead
    ["Bile Golem"]                  = "MEDIUM",
    ["Enraged Ghoul"]               = "CC",     -- undead, shackleable
    ["Acolyte"]                     = "HIGH",   -- caster + shadow
    ["Master Necromancer"]          = "HIGH",   -- raises undead; interrupt
    ["Infinite Corruptor Agent"]    = "HIGH",   -- optional timed boss add
    ["Ghoul"]                       = "SKIP",   -- mass zombie filler
    ["Risen Zombie"]                = "SKIP",   -- mass zombie filler
}

db["Utgarde Pinnacle"] = {
    ["Dragonflayer Seer"]           = "HIGH",   -- healer + lightning
    ["Ymirjar Witch Doctor"]        = "HIGH",   -- healer + shadow bolt
    ["Ymirjar Berserker"]           = "HIGH",   -- Enrage + heavy melee
    ["Ymirjar Warrior"]             = "MEDIUM",
    ["Ymirjar Harpooner"]           = "HIGH",   -- ranged; harpoon pull
    ["Dragonflayer Deathseeker"]    = "MEDIUM",
    ["Savage Worg"]                 = "CC",     -- beast, trappable
    ["Scourge Hulk"]                = "MEDIUM",
    ["Ymirjar Dusk Shaman"]         = "HIGH",   -- shadow caster
    ["Dragonflayer Fanatic"]        = "CC",     -- humanoid, CC-able
}

db["Trial of the Champion"] = {
    ["Argent Confessor"]            = "HIGH",   -- healer
    ["Argent Lightwielder"]         = "HIGH",   -- holy caster + heal
    ["Argent Monk"]                 = "MEDIUM",
    ["Argent Priestess"]            = "HIGH",   -- healer
    ["Memory of Past Foe"]          = "MEDIUM",
    ["Risen Champion"]              = "MEDIUM",
    ["Black Knight's Ghoul"]        = "SKIP",   -- summoned filler
}

db["The Forge of Souls"] = {
    ["Spectral Warden"]             = "MEDIUM",
    ["Soulguard Animator"]          = "HIGH",   -- raises dead; shadow caster
    ["Soulguard Adept"]             = "HIGH",   -- shadow caster
    ["Soulguard Reaper"]            = "MEDIUM",
    ["Soulguard Bonecaster"]        = "HIGH",   -- bone volley caster
    ["Soulguard Watchman"]          = "MEDIUM",
    ["Soul Horror"]                 = "CC",     -- undead, shackleable
    ["Spiteful Apparition"]         = "SKIP",   -- mass spirit filler
}

db["Pit of Saron"] = {
    ["Deathwhisper Necrolyte"]      = "HIGH",   -- healer + shadow
    ["Deathwhisper Shadowcaster"]   = "HIGH",   -- shadow bolt volley
    ["Deathwhisper Torturer"]       = "HIGH",   -- curse + pain caster
    ["Ymirjar Deathbringer"]        = "MEDIUM",
    ["Ymirjar Wrathbringer"]        = "MEDIUM",
    ["Ymirjar Skycaller"]           = "HIGH",   -- frost + lightning caster
    ["Ymirjar Flamebearer"]         = "HIGH",   -- fire caster
    ["Fallen Warrior"]              = "CC",     -- undead, shackleable
    ["Wrathbone Skeleton"]          = "MEDIUM",
    ["Hungering Ghoul"]             = "LOW",
}

db["Halls of Reflection"] = {
    ["Phantom Mage"]                = "HIGH",   -- fireball + flamestrike
    ["Tortured Rifleman"]           = "HIGH",   -- ranged; shoot + curse
    ["Shadowy Mercenary"]           = "HIGH",   -- stealth + backstab
    ["Spectral Footman"]            = "MEDIUM",
    ["Ghostly Priest"]              = "HIGH",   -- healer
    ["Dark Ranger"]                 = "HIGH",   -- ranged + magic
    ["Frostsworn General"]          = "MEDIUM",
}

-- ============================================================
-- WRATH OF THE LICH KING RAIDS
-- ============================================================

db["Vault of Archavon"] = {
    ["Tempest Minion"]              = "HIGH",   -- Emalon add; kill on Overcharge
    ["Tempest Warder"]              = "HIGH",   -- dangerous caster support
    ["Archavon Warder"]             = "MEDIUM",
    ["Flame Warder"]                = "MEDIUM",
    ["Frost Warder"]                = "MEDIUM",
    ["Archavon the Stone Watcher"]  = "LOW",
    ["Emalon the Storm Watcher"]    = "LOW",
    ["Koralon the Flame Watcher"]   = "LOW",
    ["Toravon the Ice Watcher"]     = "LOW",
}

db["The Obsidian Sanctum"] = {
    ["Acolyte of Shadron"]          = "HIGH",   -- portal add; kill quickly
    ["Acolyte of Vesperon"]         = "HIGH",   -- portal add; kill quickly
    ["Disciple of Shadron"]         = "HIGH",   -- twilight add support
    ["Disciple of Vesperon"]        = "HIGH",   -- twilight add support
    ["Onyx Blaze Mistress"]         = "HIGH",   -- caster trash
    ["Onyx Flight Captain"]         = "HIGH",   -- dangerous dragonkin support
    ["Onyx Sanctum Guardian"]       = "MEDIUM",
    ["Onyx Brood General"]          = "MEDIUM",
    ["Lava Blaze"]                  = "MEDIUM",
    ["Tenebron"]                    = "LOW",
    ["Shadron"]                     = "LOW",
    ["Vesperon"]                    = "LOW",
    ["Sartharion"]                  = "LOW",
}

db["The Eye of Eternity"] = {
    ["Power Spark"]                 = "HIGH",   -- must die before it reaches Malygos
    ["Nexus Lord"]                  = "HIGH",   -- caster add
    ["Scion of Eternity"]           = "HIGH",   -- ranged dragon phase add
    ["Malygos"]                     = "LOW",
}

db["Ulduar"] = {
    ["Dark Rune Acolyte"]           = "HIGH",   -- healer trash
    ["Dark Rune Champion"]          = "HIGH",   -- dangerous melee + whirlwind
    ["Dark Rune Evoker"]            = "HIGH",   -- caster trash
    ["Dark Rune Guardian"]          = "MEDIUM",
    ["Dark Rune Ravager"]           = "MEDIUM",
    ["Dark Rune Sentinel"]          = "MEDIUM",
    ["Dark Rune Thunderer"]         = "HIGH",   -- chain lightning trash
    ["Dark Rune Watcher"]           = "HIGH",   -- dangerous ranged trash
    ["Dark Rune Warbringer"]        = "MEDIUM",
    ["Ancient Rune Giant"]          = "MEDIUM",
    ["Runic Colossus"]              = "MEDIUM",
    ["Iron Honor Guard"]            = "MEDIUM",
    ["Iron Mender"]                 = "HIGH",   -- healer support on the gauntlet
    ["Lightning Charged Iron Dwarf"] = "HIGH",  -- dangerous caster add
    ["Molten Colossus"]             = "MEDIUM",
    ["Forge Construct"]             = "HIGH",   -- dangerous forge trash
    ["Ancient Conservator"]         = "HIGH",   -- silence aura; kill quickly
    ["Guardian of Life"]            = "HIGH",
    ["Nature's Blade"]              = "HIGH",
    ["Snaplasher"]                  = "HIGH",
    ["Ancient Water Spirit"]        = "HIGH",
    ["Storm Lasher"]                = "HIGH",
    ["Sanctum Sentry"]              = "HIGH",   -- Auriaya pull add
    ["Feral Defender"]              = "HIGH",   -- Auriaya add
    ["Assault Bot"]                 = "HIGH",   -- Mimiron priority add
    ["Runemaster Molgeim"]          = "HIGH",   -- Iron Council focus target
    ["Stormcaller Brundir"]         = "HIGH",   -- Iron Council focus target
    ["Steelbreaker"]                = "HIGH",   -- Iron Council focus target
    ["Corruptor Tentacle"]          = "HIGH",
    ["Crusher Tentacle"]            = "HIGH",
    ["Constrictor Tentacle"]        = "HIGH",
    ["Guardian of Yogg-Saron"]      = "HIGH",
    ["Deathsworn Zealot"]           = "HIGH",   -- General Vezax add
    ["Faceless Horror"]             = "MEDIUM",
    ["Saronite Animus"]             = "HIGH",   -- General Vezax hard mode add
    ["Immortal Guardian"]           = "HIGH",   -- Yogg-Saron phase 3 add
    ["Auriaya"]                     = "LOW",
    ["Freya"]                       = "LOW",
    ["General Vezax"]               = "LOW",
    ["Mimiron"]                     = "LOW",
    ["Yogg-Saron"]                  = "LOW",
}

db["Trial of the Crusader"] = {
    ["Snobold Vassal"]              = "HIGH",   -- Gormok add
    ["Mistress of Pain"]            = "HIGH",   -- Jaraxxus add
    ["Felflame Infernal"]           = "HIGH",   -- Jaraxxus add
    ["Nether Portal"]               = "HIGH",   -- spawns Mistress of Pain
    ["Infernal Volcano"]            = "HIGH",   -- spawns infernals
    ["Nerubian Burrower"]           = "HIGH",   -- Anub'arak add
    ["Swarm Scarab"]                = "SKIP",   -- filler scarabs during Anub'arak
    ["Gormok the Impaler"]          = "LOW",
    ["Acidmaw"]                     = "LOW",
    ["Dreadscale"]                  = "LOW",
    ["Icehowl"]                     = "LOW",
    ["Lord Jaraxxus"]               = "LOW",
    ["Fjola Lightbane"]             = "LOW",
    ["Eydis Darkbane"]              = "LOW",
    ["Anub'arak"]                   = "LOW",
}

db["Icecrown Citadel"] = {
    ["Ancient Skeletal Soldier"]    = "MEDIUM",
    ["Blazing Skeleton"]            = "HIGH",   -- Valithria add
    ["Blighted Abomination"]        = "MEDIUM",
    ["Blood Beast"]                 = "HIGH",   -- Saurfang add
    ["Cult Adherent"]               = "HIGH",   -- Deathwhisper caster add
    ["Cult Fanatic"]                = "HIGH",   -- Deathwhisper melee add
    ["Darkfallen Archmage"]         = "HIGH",   -- Blood wing caster trash
    ["Darkfallen Blood Knight"]     = "HIGH",   -- dangerous self-healing melee
    ["Darkfallen Commander"]        = "MEDIUM",
    ["Darkfallen Lieutenant"]       = "MEDIUM",
    ["Darkfallen Tactician"]        = "HIGH",
    ["Deathbound Ward"]             = "MEDIUM",
    ["Deathspeaker Attendant"]      = "HIGH",
    ["Deathspeaker Disciple"]       = "HIGH",
    ["Deathspeaker High Priest"]    = "HIGH",
    ["Deathspeaker Zealot"]         = "MEDIUM",
    ["Nerub'ar Broodkeeper"]        = "HIGH",
    ["Nerub'ar Champion"]           = "MEDIUM",
    ["Nerub'ar Webweaver"]          = "HIGH",
    ["Plague Scientist"]            = "HIGH",
    ["Pustulating Horror"]          = "HIGH",
    ["Shambling Horror"]            = "HIGH",   -- Lich King phase 1 add
    ["Raging Spirit"]               = "HIGH",   -- Lich King transition add
    ["Servant of the Throne"]       = "HIGH",
    ["Val'kyr Herald"]              = "HIGH",
    ["Val'kyr Shadowguard"]         = "HIGH",
    ["Vampiric Fiend"]              = "HIGH",
    ["Volatile Ooze"]               = "HIGH",   -- Putricide add
    ["Gas Cloud"]                   = "HIGH",   -- Putricide add
    ["Rotting Frost Giant"]         = "MEDIUM",
    ["Spire Frostwyrm"]             = "MEDIUM",
    ["Spire Gargoyle"]              = "MEDIUM",
    ["Frostwarden Sorceress"]       = "HIGH",
    ["Frostwarden Warrior"]         = "MEDIUM",
    ["Ymirjar Deathbringer"]        = "MEDIUM",
    ["Ymirjar Frostbinder"]         = "HIGH",
    ["Ymirjar Huntress"]            = "HIGH",
    ["Ymirjar Warlord"]             = "MEDIUM",
    ["Lady Deathwhisper"]           = "LOW",
    ["Deathbringer Saurfang"]       = "LOW",
    ["Professor Putricide"]         = "LOW",
    ["Blood-Queen Lana'thel"]       = "LOW",
    ["Sindragosa"]                  = "LOW",
    ["The Lich King"]               = "LOW",
}

db["The Ruby Sanctum"] = {
    ["Charscale Commander"]         = "HIGH",   -- dangerous trash caster/support
    ["Charscale Invoker"]           = "HIGH",   -- dangerous trash caster/support
    ["Onyx Flamecaller"]            = "HIGH",   -- dangerous dragonkin caster
    ["Charscale Assaulter"]         = "MEDIUM",
    ["Charscale Elite"]             = "MEDIUM",
    ["Saviana Ragefire"]            = "LOW",
    ["Baltharus the Warborn"]       = "LOW",
    ["General Zarithrian"]          = "LOW",
    ["Halion"]                      = "LOW",
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

table.insert(order, { name = "Wrath of the Lich King", zones = {
    "Utgarde Keep", "The Nexus", "Azjol-Nerub", "Ahn'kahet: The Old Kingdom",
    "Drak'Tharon Keep", "The Violet Hold", "Gundrak",
    "Halls of Stone", "Halls of Lightning", "The Oculus",
    "Culling of Stratholme", "Utgarde Pinnacle", "Trial of the Champion",
    "The Forge of Souls", "Pit of Saron", "Halls of Reflection",
    "Vault of Archavon", "The Obsidian Sanctum", "The Eye of Eternity",
    "Ulduar", "Trial of the Crusader", "Icecrown Citadel", "The Ruby Sanctum",
}})
