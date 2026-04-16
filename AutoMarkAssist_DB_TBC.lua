-- AutoMarkAssist_DB_TBC.lua
-- The Burning Crusade dungeon and raid entries.  Loaded AFTER AutoMarkAssist_DB_Classic.lua.
-- Merges TBC dungeon and raid zones into the shared database tables.
--
-- Format:  mobName = { mark = N, creatureType = "Type", dangerLevel = N }
--   mark 8 = kill priority (Skull/Cross),  mark 1-6 = CC preference
--   dangerLevel 3 = healer / summoner / calls reinforcements (kill first)
--   dangerLevel 2 = AoE, fear, interrupt priority (high danger)
--   dangerLevel absent / 0 = standard target
--   "SKIP" = ignore this mob entirely
--   ccImmune = true for mobs immune to CC despite matching creature type

local db      = AutoMarkAssist_MobDB
local aliases = AutoMarkAssist_ZoneAliases
local order   = AutoMarkAssist_ExpansionOrder

-- ============================================================
-- THE BURNING CRUSADE DUNGEONS
-- ============================================================

-- --- Hellfire Citadel ---------------------------------

db["Hellfire Ramparts"] = {
    ["Hellfire Channeler"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- AoE fire; Hellfire channel
    ["Bonechewer Beastmaster"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons Bonechewer Destroyers
    ["Bonechewer Blood Drinker"]    = { mark = 8, creatureType = "Humanoid" },
    ["Hellfire Watcher"]            = { mark = 5, creatureType = "Humanoid" },
    ["Hellfire Watchtower"]         = { mark = 5, creatureType = "Humanoid" },
    ["Bonechewer Hungerer"]         = "SKIP",
}

db["The Blood Furnace"] = {
    ["Bleeding Hollow Scryer"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- shadow AoE caster
    ["Laughing Skull Warden"]       = { mark = 8, creatureType = "Humanoid" },
    ["Laughing Skull Rogue"]        = { mark = 8, creatureType = "Humanoid" },
    ["Fel Orc Convert"]             = { mark = 5, creatureType = "Humanoid" },
    ["Bleeding Hollow Torturer"]    = { mark = 8, creatureType = "Humanoid" },
    ["Bleeding Hollow Skulker"]     = { mark = 8, creatureType = "Humanoid" },
    ["Fel Orc Neophyte"]            = "SKIP",
}

db["The Shattered Halls"] = {
    ["Shattered Hand Zealot"]       = { mark = 8, creatureType = "Humanoid" },
    ["Shattered Hand Assassin"]     = { mark = 8, creatureType = "Humanoid" },
    ["Shattered Hand Heathen"]      = { mark = 8, creatureType = "Humanoid" },
    ["Shattered Hand Reaver"]       = { mark = 5, creatureType = "Humanoid" },
    ["Shattered Hand Savage"]       = { mark = 5, creatureType = "Humanoid" },
    ["Shattered Hand Berserker"]    = { mark = 8, creatureType = "Humanoid" },
    ["Shattered Hand Warhound"]     = "SKIP",
}

-- --- Coilfang Reservoir ---------------------------------

db["The Slave Pens"] = {
    ["Coilfang Collaborator"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- arcane AoE caster
    ["Coilfang Observer"]           = { mark = 8, creatureType = "Humanoid" },
    ["Coilfang Slavehandler"]       = { mark = 8, creatureType = "Humanoid" },
    ["Coilfang Water Elemental"]    = { mark = 5, creatureType = "Elemental" },
    ["Underbat"]                    = { mark = 5, creatureType = "Beast" },
    ["Wastewalker Slave"]           = "SKIP",
}

db["The Underbog"] = {
    ["Lykul Bloodseeker"]           = { mark = 8, creatureType = "Beast" },
    ["Underbog Colossus"]           = { mark = 8, creatureType = "Giant" },
    ["Underbog Shambler"]           = { mark = 5, creatureType = "Elemental" },
    ["Lykul Wasp"]                  = { mark = 5, creatureType = "Beast" },
    ["Spore Bat"]                   = { mark = 5, creatureType = "Beast" },
    ["Black Stalker Spawn"]         = { mark = 5, creatureType = "Beast" },
}

db["The Steamvault"] = {
    ["Coilfang Oracle"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Coilfang Technician"]         = { mark = 8, creatureType = "Humanoid" },
    ["Coilfang Engineer"]           = { mark = 8, creatureType = "Humanoid" },
    ["Coilfang Myrmidon"]           = { mark = 5, creatureType = "Humanoid" },
    ["Spore Bat"]                   = { mark = 8, creatureType = "Beast" },
    ["Steam Surger"]                = { mark = 8, creatureType = "Elemental" },
    ["Tidal Surger"]                = { mark = 8, creatureType = "Elemental" },
    ["Steamrigger Mechanic"]        = { mark = 8, creatureType = "Humanoid" },
    ["Coilfang Leper"]              = "SKIP",
}

-- --- Auchindoun ---------------------------------

db["Mana-Tombs"] = {
    ["Ethereal Theurgist"]          = { mark = 8, creatureType = "Humanoid" },
    ["Ethereal Darkcaster"]         = { mark = 8, creatureType = "Humanoid" },
    ["Ethereal Sorcerer"]           = { mark = 8, creatureType = "Humanoid" },
    ["Ethereal Spellbinder"]        = { mark = 8, creatureType = "Humanoid" },
    ["Haunt"]                       = { mark = 5, creatureType = "Undead" },
    ["Mana Leech"]                  = { mark = 8, creatureType = "Beast" },
    ["Nexus Stalker"]               = { mark = 5, creatureType = "Humanoid" },
    ["Ethereal Priest"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Ethereal Assassin"]           = { mark = 8, creatureType = "Humanoid" },
    ["Ethereal Summoned Warrior"]   = "SKIP",
}

db["Auchenai Crypts"] = {
    ["Auchenai Monk"]               = { mark = 8, creatureType = "Humanoid" },
    ["Auchenai Soulpriest"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Ghostly Philanthropist"]      = { mark = 5, creatureType = "Undead" },
    ["Worshipper of Eternos"]       = { mark = 5, creatureType = "Humanoid" },
    ["Cultist Shard Watcher"]       = { mark = 8, creatureType = "Humanoid" },
    ["Death's Head Cultist"]        = { mark = 8, creatureType = "Humanoid" },
    ["Angered Skeleton"]            = "SKIP",
}

db["Sethekk Halls"] = {
    ["Arakkoa Diviner"]             = { mark = 8, creatureType = "Humanoid" },
    ["Time-Lost Controller"]        = { mark = 8, creatureType = "Humanoid" },
    ["Time-Lost Scryer"]            = { mark = 8, creatureType = "Humanoid" },
    ["Cobalt Serpent"]              = { mark = 5, creatureType = "Beast" },
    ["Avian Darkhawk"]              = { mark = 5, creatureType = "Beast" },
    ["Avian Warhawk"]               = { mark = 8, creatureType = "Beast" },
    ["Sethekk Oracle"]              = { mark = 8, creatureType = "Humanoid" },
    ["Sethekk Ravenguard"]          = { mark = 8, creatureType = "Humanoid" },
    ["Avian Flitter"]               = "SKIP",
    ["Raven Hatchling"]             = "SKIP",
}

db["Shadow Labyrinth"] = {
    ["Cabal Shadow Priest"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer + shadow mend
    ["Cabal Hexer"]                 = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- hex; sleep/fear effects
    ["Cabal Cultist"]               = { mark = 8, creatureType = "Humanoid" },
    ["Cabal Soldier"]               = { mark = 5, creatureType = "Humanoid" },
    ["Cabal Assassin"]              = { mark = 8, creatureType = "Humanoid" },
    ["Cabal Rogue"]                 = { mark = 8, creatureType = "Humanoid" },
    ["Cabal Warlock"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summoner; calls demons
    ["Cabal Deathsworn"]            = { mark = 8, creatureType = "Humanoid" },
    ["Fel Overseer"]                = { mark = 8, creatureType = "Demon" },
    ["Void Traveler"]               = { mark = 8, creatureType = "Demon", ccImmune = true },
    ["Shadow Imp"]                  = "SKIP",
}

-- --- Tempest Keep ---------------------------------

db["The Botanica"] = {
    ["Bloodwarder Mender"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Bloodwarder Physician"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Sunseeker Chemist"]           = { mark = 8, creatureType = "Humanoid" },
    ["Sunseeker Researcher"]        = { mark = 8, creatureType = "Humanoid" },
    ["Sunseeker Botanist"]          = { mark = 5, creatureType = "Humanoid" },
    ["Bloodwarder Protector"]       = { mark = 5, creatureType = "Humanoid" },
    ["Sunseeker Gene-Splicer"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- AoE + mutation abilities
    ["Vicious Thornshoots"]         = { mark = 5, creatureType = "Elemental" },
    ["Treant"]                      = { mark = 5, creatureType = "Elemental" },
    ["Sunseeker Bloodhawk"]         = "SKIP",
    ["Bloodpetal Lasher"]           = "SKIP",
    ["Bloodpetal Flayer"]           = "SKIP",
    ["Bloodpetal Thorn"]            = "SKIP",
    ["Mutant Bloodpetal"]           = "SKIP",
    ["Nether Tendril"]              = "SKIP",
}

db["The Arcatraz"] = {
    ["Eredar Deathbringer"]         = { mark = 8, creatureType = "Demon" },
    ["Eredar Soul Eater"]           = { mark = 8, creatureType = "Demon" },
    ["Blazing Trickster"]           = { mark = 8, creatureType = "Demon" },
    ["Entrapped Berserker"]         = { mark = 8, creatureType = "Humanoid" },
    ["Neg'Jin Shackler"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- shackles party members
    ["Arcatraz Warder"]             = { mark = 5, creatureType = "Humanoid" },
    ["Protean Horror"]              = { mark = 5, creatureType = "Aberration" },
    ["Dalliah's Devotee"]           = { mark = 8, creatureType = "Humanoid" },
    ["Void Spawner"]                = "SKIP",
    ["Soul Fragment"]               = "SKIP",
}

db["The Mechanar"] = {
    ["Sunseeker Astromage"]         = { mark = 8, creatureType = "Humanoid" },
    ["Sunseeker Netherbinder"]      = { mark = 8, creatureType = "Humanoid" },
    ["Sunseeker Gene-Splicer"]      = { mark = 8, creatureType = "Humanoid" },
    ["Blood Elf Reclaimer"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- heals/repairs Mechanar constructs
    ["Blood Elf Surveyor"]          = { mark = 5, creatureType = "Humanoid" },
    ["Nether Wraith"]               = { mark = 8, creatureType = "Undead" },
    ["Mechanar Tinkerer"]           = { mark = 8, creatureType = "Humanoid" },
    ["Sunseeker Overseer"]          = { mark = 8, creatureType = "Humanoid" },
    ["Tempest-Forge Destroyer"]     = { mark = 8, creatureType = "Mechanical" },
    ["Nether Spark"]                = "SKIP",
    ["Arcane Bomb"]                 = "SKIP",
}

-- --- Caverns of Time ---------------------------------

db["Old Hillsbrad Foothills"] = {
    ["Syndicate Assassin"]          = { mark = 8, creatureType = "Humanoid" },
    ["Syndicate Watchman"]          = { mark = 8, creatureType = "Humanoid" },
    ["Syndicate Shadow-Mage"]       = { mark = 8, creatureType = "Humanoid" },
    ["Hillsbrad Watchman"]          = { mark = 5, creatureType = "Humanoid" },
    ["Durnholde Veteran"]           = { mark = 8, creatureType = "Humanoid" },
    ["Durnholde Tracking Hound"]    = { mark = 5, creatureType = "Beast" },
    ["Durnholde War Horse"]         = "SKIP",
}

db["The Black Morass"] = {
    ["Rift Keeper"]                 = { mark = 8, creatureType = "Dragonkin" },
    ["Rift Lord"]                   = { mark = 8, creatureType = "Dragonkin" },
    ["Infinite Assassin"]           = { mark = 5, creatureType = "Dragonkin" },
    ["Infinite Executioner"]        = { mark = 5, creatureType = "Dragonkin" },
    ["Infinite Saboteur"]           = { mark = 5, creatureType = "Dragonkin" },
    ["Infinite Chrono-Sentinel"]    = { mark = 5, creatureType = "Dragonkin" },
    ["Rift Spawner"]                = "SKIP",
}

-- --- Isle of Quel'Danas ---------------------------------

db["Magisters' Terrace"] = {
    ["Sunblade Physician"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Sunblade Blood Knight"]       = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Arch Mage"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- AoE arcane caster
    ["Sunblade Magister"]           = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Warlock"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons Sunblade Imps
    ["Sunblade Imp Handler"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons and controls imps
    ["Sunblade Imp"]                = { mark = 5, creatureType = "Demon" },
    ["Felguard Legionnaire"]        = { mark = 5, creatureType = "Demon" },
    ["Sunblade Vindicator"]         = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Imp Swarm"]          = "SKIP",
    ["Mana Tap Imp"]                = "SKIP",
}

-- ============================================================
-- THE BURNING CRUSADE RAIDS
-- ============================================================

db["Karazhan"] = {
    ["Arcane Anomaly"]              = { mark = 8, creatureType = "Elemental" },
    ["Astral Flare"]                = { mark = 8, creatureType = "Elemental" },
    ["Chaotic Sentience"]           = { mark = 8, creatureType = "Demon" },
    ["Conjured Water Elemental"]    = { mark = 8, creatureType = "Elemental" },
    ["Doomguard"]                   = { mark = 8, creatureType = "Demon" },
    ["Ethereal Spellfilcher"]       = { mark = 8, creatureType = "Humanoid" },
    ["Ethereal Thief"]              = { mark = 8, creatureType = "Humanoid" },
    ["Ghastly Haunt"]               = { mark = 8, creatureType = "Undead" },
    ["Human Cleric"]                = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Human Conjurer"]              = { mark = 8, creatureType = "Humanoid" },
    ["Kil'rek"]                     = { mark = 8, creatureType = "Demon" },
    ["Mana Warp"]                   = { mark = 8, creatureType = "Elemental" },
    ["Orc Necrolyte"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer; Shadow Mend
    ["Orc Warlock"]                 = { mark = 8, creatureType = "Humanoid" },
    ["Sorcerous Shade"]             = { mark = 8, creatureType = "Undead" },
    ["Spell Shade"]                 = { mark = 8, creatureType = "Undead" },
    ["Spectral Apprentice"]         = { mark = 8, creatureType = "Undead" },
    ["Spectral Servant"]            = { mark = 8, creatureType = "Undead" },
    ["Zealous Consort"]             = { mark = 8, creatureType = "Undead" },
    ["Zealous Paramour"]            = { mark = 8, creatureType = "Undead" },
    ["Coldmist Stalker"]            = { mark = 5, creatureType = "Undead" },
    ["Coldmist Widow"]              = { mark = 5, creatureType = "Beast" },
    ["Mana Feeder"]                 = { mark = 5, creatureType = "Elemental" },
    ["Phase Hound"]                 = { mark = 5, creatureType = "Beast" },
    ["Shadowbat"]                   = { mark = 5, creatureType = "Beast" },
    ["Vampiric Shadowbat"]          = { mark = 5, creatureType = "Beast" },
    ["Dancing Flames"]              = "SKIP",
    ["Rat"]                         = "SKIP",
    ["Spider"]                      = "SKIP",
}

db["Gruul's Lair"] = {
    ["Blindeye the Seer"]           = { mark = 8, creatureType = "Giant", dangerLevel = 3 },     -- healer; Prayer of Healing
    ["Kiggler the Crazed"]          = { mark = 8, creatureType = "Giant" },
    ["Krosh Firehand"]              = { mark = 8, creatureType = "Giant" },
    ["Olm the Summoner"]            = { mark = 8, creatureType = "Giant", dangerLevel = 3 },     -- summons felhunters; Death Coil fear
    ["Gronn-Priest"]                = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Wild Fel Stalker"]            = { mark = 5, creatureType = "Demon" },
}

db["Magtheridon's Lair"] = {
    ["Hellfire Channeler"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- channels Magtheridon; must die simultaneously
    ["Burning Abyssal"]             = { mark = 5, creatureType = "Elemental" },
}

db["Serpentshrine Cavern"] = {
    ["Coilfang Ambusher"]           = { mark = 8, creatureType = "Humanoid" },
    ["Coilfang Beast-Tamer"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons and controls beasts
    ["Coilfang Fathom-Witch"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- frost/shadow AoE
    ["Coilfang Hate-Screamer"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- fear screech
    ["Coilfang Priestess"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Fathom-Guard Caribdis"]       = { mark = 8, creatureType = "Humanoid" },
    ["Fathom-Guard Sharkkis"]       = { mark = 8, creatureType = "Humanoid" },
    ["Fathom-Guard Tidalvess"]      = { mark = 8, creatureType = "Humanoid" },
    ["Greyheart Nether-Mage"]       = { mark = 8, creatureType = "Humanoid" },
    ["Greyheart Spellbinder"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- spell-binds/interrupts casters
    ["Greyheart Technician"]        = { mark = 8, creatureType = "Humanoid" },
    ["Greyheart Tidecaller"]        = { mark = 8, creatureType = "Humanoid" },
    ["Serpentshrine Tidecaller"]    = { mark = 8, creatureType = "Humanoid" },
    ["Tainted Elemental"]           = { mark = 8, creatureType = "Elemental" },
    ["Tainted Water Elemental"]     = { mark = 8, creatureType = "Elemental" },
    ["Tidewalker Depth-Seer"]       = { mark = 8, creatureType = "Humanoid" },
    ["Tidewalker Hydromancer"]      = { mark = 8, creatureType = "Humanoid" },
    ["Tidewalker Shaman"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Coilfang Frenzy"]             = { mark = 5, creatureType = "Beast" },
    ["Coilfang Strider"]            = { mark = 5, creatureType = "Beast" },
    ["Fathom Sporebat"]             = { mark = 5, creatureType = "Beast" },
    ["Serpentshrine Sporebat"]      = { mark = 5, creatureType = "Beast" },
}

db["The Eye"] = {
    ["Astromancer"]                 = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- AoE arcane caster
    ["Astromancer Lord"]            = { mark = 8, creatureType = "Humanoid" },
    ["Bloodwarder Vindicator"]      = { mark = 8, creatureType = "Humanoid" },
    ["Cosmic Infuser"]              = { mark = 8, creatureType = "Mechanical" },
    ["Crimson Hand Battle Mage"]    = { mark = 8, creatureType = "Humanoid" },
    ["Crimson Hand Blood Knight"]   = { mark = 8, creatureType = "Humanoid" },
    ["Crimson Hand Inquisitor"]     = { mark = 8, creatureType = "Humanoid" },
    ["Crystalcore Mechanic"]        = { mark = 8, creatureType = "Humanoid" },
    ["Grand Astromancer Capernian"] = { mark = 8, creatureType = "Humanoid" },
    ["Infinity Blade"]              = { mark = 8, creatureType = "Mechanical" },
    ["Master Engineer Telonicus"]   = { mark = 8, creatureType = "Humanoid" },
    ["Nether Scryer"]               = { mark = 8, creatureType = "Humanoid" },
    ["Netherstrand Longbow"]        = { mark = 8, creatureType = "Mechanical" },
    ["Novice Astromancer"]          = { mark = 8, creatureType = "Humanoid" },
    ["Phaseshift Bulwark"]          = { mark = 8, creatureType = "Mechanical" },
    ["Phoenix Egg"]                 = { mark = 8, creatureType = "Elemental" },
    ["Solarium Priest"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Staff of Disintegration"]     = { mark = 8, creatureType = "Mechanical" },
    ["Star Scryer"]                 = { mark = 8, creatureType = "Humanoid" },
    ["Tempest Falconer"]            = { mark = 8, creatureType = "Humanoid" },
    ["Tempest-Smith"]               = { mark = 8, creatureType = "Humanoid" },
    ["Thaladred the Darkener"]      = { mark = 8, creatureType = "Humanoid" },
    ["Warp Slicer"]                 = { mark = 8, creatureType = "Mechanical" },
    ["Phoenix-Hawk"]                = { mark = 5, creatureType = "Beast" },
    ["Phoenix-Hawk Hatchling"]      = { mark = 5, creatureType = "Beast" },
}

db["Hyjal Summit"] = {
    ["Banshee"]                     = { mark = 8, creatureType = "Undead", dangerLevel = 2 },    -- fear wail + silence
    ["Frost Wyrm"]                  = { mark = 8, creatureType = "Undead" },
    ["Giant Infernal"]              = { mark = 8, creatureType = "Demon" },
    ["Lesser Doomguard"]            = { mark = 8, creatureType = "Demon" },
    ["Necromancer"]                 = { mark = 8, creatureType = "Undead", dangerLevel = 3 },    -- raises dead adds
}

db["Black Temple"] = {
    ["Ashtongue Elementalist"]      = { mark = 8, creatureType = "Humanoid" },
    ["Ashtongue Mystic"]            = { mark = 8, creatureType = "Humanoid" },
    ["Ashtongue Primalist"]         = { mark = 8, creatureType = "Humanoid" },
    ["Ashtongue Sorcerer"]          = { mark = 8, creatureType = "Humanoid" },
    ["Ashtongue Spiritbinder"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- spirit binding; heals allies
    ["Ashtongue Stormcaller"]       = { mark = 8, creatureType = "Humanoid" },
    ["Bonechewer Blood Prophet"]    = { mark = 8, creatureType = "Humanoid" },
    ["Bonechewer Taskmaster"]       = { mark = 8, creatureType = "Humanoid" },
    ["Coilskar Sea-Caller"]         = { mark = 8, creatureType = "Humanoid" },
    ["Coilskar Soothsayer"]         = { mark = 8, creatureType = "Humanoid" },
    ["Dragonmaw Wyrmcaller"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons drakes
    ["Flame of Azzinoth"]           = { mark = 8, creatureType = "Demon" },
    ["Hand of Gorefiend"]           = { mark = 8, creatureType = "Undead" },
    ["Illidari Archon"]             = { mark = 8, creatureType = "Humanoid" },
    ["Illidari Assassin"]           = { mark = 8, creatureType = "Humanoid" },
    ["Illidari Battle-mage"]        = { mark = 8, creatureType = "Humanoid" },
    ["Illidari Blood Lord"]         = { mark = 8, creatureType = "Humanoid" },
    ["Illidari Fearbringer"]        = { mark = 8, creatureType = "Demon", dangerLevel = 2 },     -- fear
    ["Illidari Nightlord"]          = { mark = 8, creatureType = "Humanoid" },
    ["Shadowmoon Blood Mage"]       = { mark = 8, creatureType = "Humanoid" },
    ["Shadowmoon Deathshaper"]      = { mark = 8, creatureType = "Humanoid" },
    ["Shadowmoon Houndmaster"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons riding hounds
    ["Temple Acolyte"]              = { mark = 8, creatureType = "Humanoid" },
    ["Aqueous Spawn"]               = { mark = 5, creatureType = "Elemental" },
    ["Aqueous Surger"]              = { mark = 5, creatureType = "Elemental" },
    ["Leviathan"]                   = { mark = 5, creatureType = "Beast" },
    ["Mutant War Hound"]            = { mark = 5, creatureType = "Beast" },
    ["Shadowmoon Riding Hound"]     = { mark = 5, creatureType = "Beast" },
    ["Storm Fury"]                  = { mark = 5, creatureType = "Elemental" },
}

db["Zul'Aman"] = {
    ["Amani Healing Ward"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Amani Protective Ward"]       = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Beast Tamer"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- beast caller
    ["Amani'shi Flame Caster"]      = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Handler"]           = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Hatcher"]           = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Medicine Man"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer + hex
    ["Amani'shi Scout"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- calls reinforcements
    ["Amani'shi Tempest"]           = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Warbringer"]        = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Wind Walker"]       = { mark = 8, creatureType = "Humanoid" },
    ["Darkheart"]                   = { mark = 8, creatureType = "Beast" },
    ["Gazakroth"]                   = { mark = 8, creatureType = "Demon" },
    ["Koragg"]                      = { mark = 8, creatureType = "Humanoid" },
    ["Lord Raadan"]                 = { mark = 8, creatureType = "Beast" },
    ["Amani Bear"]                  = { mark = 5, creatureType = "Beast" },
    ["Amani Bear Mount"]            = { mark = 5, creatureType = "Beast" },
    ["Amani Dragonhawk"]            = { mark = 5, creatureType = "Beast" },
    ["Amani Elder Lynx"]            = { mark = 5, creatureType = "Beast" },
    ["Amani Lynx"]                  = { mark = 5, creatureType = "Beast" },
    ["Slither"]                     = { mark = 5, creatureType = "Beast" },
    ["Soaring Eagle"]               = { mark = 5, creatureType = "Beast" },
    ["Forest Frog"]                 = "SKIP",
}

db["Sunwell Plateau"] = {
    ["Apocalypse Guard"]            = { mark = 8, creatureType = "Demon" },
    ["Chaos Gazer"]                 = { mark = 8, creatureType = "Demon" },
    ["Doomfire Destroyer"]          = { mark = 8, creatureType = "Demon" },
    ["Hand of the Deceiver"]        = { mark = 8, creatureType = "Humanoid" },
    ["Oblivion Mage"]               = { mark = 8, creatureType = "Humanoid" },
    ["Painbringer"]                 = { mark = 8, creatureType = "Demon" },
    ["Priestess of Torment"]        = { mark = 8, creatureType = "Demon" },
    ["Shield Orb"]                  = { mark = 8, creatureType = "Demon" },
    ["Shadowsword Assassin"]        = { mark = 8, creatureType = "Humanoid" },
    ["Shadowsword Deathbringer"]    = { mark = 8, creatureType = "Humanoid" },
    ["Shadowsword Fury Mage"]       = { mark = 8, creatureType = "Humanoid" },
    ["Shadowsword Lifeshaper"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Shadowsword Manafiend"]       = { mark = 8, creatureType = "Humanoid" },
    ["Shadowsword Soulbinder"]      = { mark = 8, creatureType = "Humanoid" },
    ["Sinister Reflection"]         = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Arch Mage"]          = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Cabalist"]           = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Dawn Priest"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Sunblade Dusk Priest"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Sunblade Scout"]              = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Vindicator"]         = { mark = 8, creatureType = "Humanoid" },
    ["Void Sentinel"]               = { mark = 8, creatureType = "Demon" },
    ["Cataclysm Hound"]             = { mark = 5, creatureType = "Demon" },
    ["Sunblade Dragonhawk"]         = { mark = 5, creatureType = "Beast" },
    ["Dancing Flames"]              = "SKIP",
}

-- ============================================================
-- ZONE ALIASES  (merged into the shared table)
-- ============================================================

local newAliases = {
    ["Ramparts"]                        = "Hellfire Ramparts",
    ["Hellfire Ramparts"]               = "Hellfire Ramparts",
    ["Blood Furnace"]                   = "The Blood Furnace",
    ["The Blood Furnace"]               = "The Blood Furnace",
    ["Shattered Halls"]                 = "The Shattered Halls",
    ["The Shattered Halls"]             = "The Shattered Halls",
    ["Slave Pens"]                      = "The Slave Pens",
    ["The Slave Pens"]                  = "The Slave Pens",
    ["Underbog"]                        = "The Underbog",
    ["The Underbog"]                    = "The Underbog",
    ["Steamvault"]                      = "The Steamvault",
    ["The Steamvault"]                  = "The Steamvault",
    ["Mana Tombs"]                      = "Mana-Tombs",
    ["Mana-Tombs"]                      = "Mana-Tombs",
    ["Auchenai Crypts"]                 = "Auchenai Crypts",
    ["Sethekk Halls"]                   = "Sethekk Halls",
    ["Shadow Labyrinth"]                = "Shadow Labyrinth",
    ["Botanica"]                        = "The Botanica",
    ["The Botanica"]                    = "The Botanica",
    ["Arcatraz"]                        = "The Arcatraz",
    ["The Arcatraz"]                    = "The Arcatraz",
    ["Mechanar"]                        = "The Mechanar",
    ["The Mechanar"]                    = "The Mechanar",
    ["Old Hillsbrad"]                   = "Old Hillsbrad Foothills",
    ["Old Hillsbrad Foothills"]         = "Old Hillsbrad Foothills",
    ["Escape from Durnholde Keep"]      = "Old Hillsbrad Foothills",
    ["Black Morass"]                    = "The Black Morass",
    ["The Black Morass"]                = "The Black Morass",
    ["Opening of the Dark Portal"]      = "The Black Morass",
    ["Magisters' Terrace"]              = "Magisters' Terrace",
    ["Magister's Terrace"]              = "Magisters' Terrace",
    ["Karazhan"]                        = "Karazhan",
    ["Kara"]                            = "Karazhan",
    ["Gruul's Lair"]                    = "Gruul's Lair",
    ["Gruul"]                           = "Gruul's Lair",
    ["Gruuls"]                          = "Gruul's Lair",
    ["Magtheridon's Lair"]              = "Magtheridon's Lair",
    ["Magtheridon"]                     = "Magtheridon's Lair",
    ["Mags"]                            = "Magtheridon's Lair",
    ["Mag's"]                           = "Magtheridon's Lair",
    ["Serpentshrine Cavern"]            = "Serpentshrine Cavern",
    ["Serpentshrine"]                   = "Serpentshrine Cavern",
    ["SSC"]                             = "Serpentshrine Cavern",
    ["The Eye"]                         = "The Eye",
    ["Tempest Keep"]                    = "The Eye",
    ["TK"]                              = "The Eye",
    ["Hyjal Summit"]                    = "Hyjal Summit",
    ["Battle for Mount Hyjal"]          = "Hyjal Summit",
    ["The Battle for Mount Hyjal"]      = "Hyjal Summit",
    ["Mount Hyjal"]                     = "Hyjal Summit",
    ["Hyjal"]                           = "Hyjal Summit",
    ["Black Temple"]                    = "Black Temple",
    ["BT"]                              = "Black Temple",
    ["Zul'Aman"]                        = "Zul'Aman",
    ["ZA"]                              = "Zul'Aman",
    ["Sunwell Plateau"]                 = "Sunwell Plateau",
    ["Sunwell"]                         = "Sunwell Plateau",
    ["SWP"]                             = "Sunwell Plateau",
}
for k, v in pairs(newAliases) do aliases[k] = v end

-- ============================================================
-- EXPANSION ORDER  (appended to the shared table)
-- ============================================================

table.insert(order, { name = "The Burning Crusade", dungeons = {
    "Hellfire Ramparts", "The Blood Furnace", "The Shattered Halls",
    "The Slave Pens", "The Underbog", "The Steamvault",
    "Mana-Tombs", "Auchenai Crypts", "Sethekk Halls", "Shadow Labyrinth",
    "The Mechanar", "The Botanica", "The Arcatraz",
    "Old Hillsbrad Foothills", "The Black Morass", "Magisters' Terrace",
}, raids = {
    "Karazhan", "Gruul's Lair", "Magtheridon's Lair",
    "Serpentshrine Cavern", "The Eye", "Hyjal Summit", "Black Temple",
    "Zul'Aman", "Sunwell Plateau",
}})
