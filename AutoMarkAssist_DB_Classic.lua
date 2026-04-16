-- AutoMarkAssist_DB_Classic.lua
-- Mob mark-preference database for Classic (Vanilla) dungeons and raids.
-- This is the FIRST DB module loaded -- it creates the global tables.
-- Subsequent expansion modules merge into these tables.
--
-- NOTE: Mob names reflect post-Cataclysm revamps where applicable.
-- Classic Era and TBC/WotLK Classic servers may use original pre-Cata names
-- for some mobs.  Unknown mobs are marked via FCFS; adjust entries
-- in-game via the Database tab or by editing this file directly.
--
-- Mark values:
--   8        -> Skull (priority kill target)
--   5        -> Moon  (CC preference, e.g. Polymorph)
--   1-7      -> Any specific mark preference
--   "SKIP"   -> Never mark this mob.
--
-- Adjust via the in-game Database tab or by editing this file directly.

-- Creates the global database tables that subsequent expansion modules merge into.

AutoMarkAssist_MobDB = {

    -- ============================================================
    -- CLASSIC DUNGEONS
    -- ============================================================

    ["Ragefire Chasm"] = {
        ["Corrupted Houndmaster"]       = 8,   -- calls beasts; kill first
        ["Dark Shaman Acolyte"]         = 8,   -- flame shock caster
        ["Molten Elemental"]            = 5,     -- elemental, banishable
    },

    ["Wailing Caverns"] = {
        ["Druid of the Fang"]           = 8,   -- healer + lightning bolt caster
        ["Deviate Viper"]               = 5,     -- beast, trappable
        ["Deviate Adder"]               = 5,     -- beast, trappable
        ["Serpentbloom Snake"]          = "SKIP",   -- ambient filler
    },

    ["The Deadmines"] = {
        ["Defias Blood Wizard"]         = 8,   -- fire caster; interrupt priority
        ["Defias Squallshaper"]         = 8,   -- frost caster + heal
        ["Defias Envoker"]              = 8,   -- holy fire caster
        ["Defias Pirate"]               = 5,     -- humanoid, CC-able
        ["Defias Taskmaster"]           = 8,   -- buffs nearby adds
    },

    ["Shadowfang Keep"] = {
        ["Tormented Officer"]           = 8,   -- forsaken caster
        ["Wailing Guardsman"]           = 8,   -- screaming strikes + fear
        ["Unstable Ravager"]            = 8,   -- volatile damage
        ["Dark Creeper"]                = 5,     -- stealth mob, CC-able
        ["Corpse Eater"]                = 5,     -- beast, trappable
    },

    ["The Stockade"] = {
        ["Defias Captive"]              = { mark = 7, creatureType = "Humanoid" },
        ["Defias Prisoner"]             = { mark = 5, creatureType = "Humanoid" },
        ["Defias Insurgent"]            = { mark = 8, creatureType = "Humanoid" },
        ["Riverpaw Mystic"]             = { mark = 8, creatureType = "Humanoid" },
    },

    ["Blackfathom Deeps"] = {
        ["Twilight Aquamancer"]         = 8,   -- frost caster
        ["Twilight Shadowmage"]         = 8,   -- shadow bolt volley
        ["Blackfathom Tide Priestess"]  = 8,   -- healer
        ["Murkshallow Snapclaw"]        = 5,     -- beast, trappable
        ["Fallenroot Rogue"]            = 5,     -- stealth, humanoid CC-able
    },

    ["Gnomeregan"] = {
        ["Arcane Nullifier X-21"]       = 8,   -- silences and counterspells
        ["Leprous Technician"]          = 8,   -- disease caster
        ["Leprous Gnome"]               = 5,     -- humanoid, CC-able
        ["Caverndeep Burrower"]         = 5,     -- beast, trappable
        ["Mobile Alert System"]         = 8,   -- calls reinforcements
        ["Dark Iron Agent"]             = 8,   -- stealth + sabotage
    },

    ["Razorfen Kraul"] = {
        ["Razorfen Dustweaver"]         = 8,   -- lightning + heal
        ["Razorfen Geomancer"]          = 8,   -- earth caster
        ["Death's Head Seer"]           = 8,   -- shadow bolt volley
        ["Death's Head Cultist"]        = 8,   -- shadow caster
        ["Razorfen Servitor"]           = 5,     -- humanoid, CC-able
        ["Razorfen Beastmaster"]        = 8,   -- beast caller
        ["Kraul Bat"]                   = "SKIP",   -- ambient beast filler
    },

    ["Razorfen Downs"] = {
        ["Death's Head Necromancer"]    = 8,   -- raises undead
        ["Death's Head Sage"]           = 8,   -- shadow caster + heal
        ["Withered Quilguard"]          = 5,     -- can be CC'd
        ["Frozen Soul"]                 = 5,     -- undead, shackleable
    },

    ["Scarlet Halls"] = {
        ["Scarlet Evoker"]              = 8,   -- fire caster; flamestrike
        ["Scarlet Treasurer"]           = 8,   -- healer
        ["Scarlet Scholar"]             = 8,   -- arcane caster
        ["Scarlet Cannoneer"]           = 8,   -- ranged; interrupt priority
        ["Master Dog Trainer"]          = 8,   -- beast caller
        ["Scarlet Evangelist"]          = 5,     -- humanoid, CC-able
        ["Hound"]                       = "SKIP",   -- pet filler; kill trainer
    },

    ["Scarlet Monastery"] = {
        ["Scarlet Zealot"]              = 8,   -- fanatical self-buffer
        ["Scarlet Chaplain"]            = 8,   -- healer; must die first
        ["Scarlet Judicator"]           = 8,   -- holy caster + judgement
        ["Scarlet Fanatic"]             = 5,     -- humanoid, CC-able
        ["Scarlet Friar"]               = 8,   -- healer
        ["Scarlet Purifier"]            = 8,   -- consecration + holy fire
    },

    ["Zul'Farrak"] = {
        ["Sandfury Witch Doctor"]       = 8,   -- healer + hex
        ["Sandfury Shadowcaster"]       = 8,   -- shadow bolt volley
        ["Sandfury Firecaller"]         = 8,   -- fire nova + fireball
        ["Sandfury Blood Drinker"]      = 8,   -- life drain caster
        ["Sandfury Zealot"]             = 5,     -- humanoid, CC-able
        ["Troll Totem"]                 = "SKIP",   -- totem filler
    },

    ["Maraudon"] = {
        ["Celebras Elementalist"]       = 8,   -- nature caster
        ["Barbed Lasher"]               = 5,     -- plant, incapacitateable
        ["Putrid Shrieker"]             = 8,   -- fear + disease
        ["Vile Larva"]                  = "SKIP",   -- swarm filler
        ["Centaur Pariah"]              = 8,   -- caster
    },

    ["Dire Maul"] = {
        ["Gordok Ogre-Mage"]            = 8,   -- arcane caster
        ["Gordok Warlock"]              = 8,   -- shadow bolt + summons
        ["Gordok Mage-Lord"]            = 8,   -- polymorph + blizzard
        ["Gordok Bushwacker"]           = 5,     -- humanoid, CC-able
        ["Wildspawn Imp"]               = 5,     -- demon, banishable
        ["Wildspawn Shadowstalker"]     = 8,   -- stealth + backstab
        ["Wildspawn Felsworn"]          = 8,   -- fel caster
        ["Warpwood Treant"]             = 5,     -- nature mob, incapacitateable
        ["Felvine Shard"]               = "SKIP",   -- environmental filler
    },

    ["Stratholme"] = {
        ["Risen Sorcerer"]              = 8,   -- shadow caster
        ["Risen Priest"]                = 8,   -- healer
        ["Crimson Sorcerer"]            = 8,   -- fire mage caster
        ["Crimson Priest"]              = 8,   -- healer
        ["Crimson Gallant"]             = 5,     -- humanoid, CC-able
        ["Thuzadin Necromancer"]        = 8,   -- raises undead
        ["Thuzadin Shadowcaster"]       = 8,   -- shadow caster
        ["Mindless Skeleton"]           = "SKIP",   -- mass undead filler
        ["Plagued Rat"]                 = "SKIP",   -- ambient filler
    },

    ["Scholomance"] = {
        ["Scholomance Acolyte"]         = 8,   -- shadow caster
        ["Scholomance Necrolyte"]       = 8,   -- healer + raises adds
        ["Scholomance Neophyte"]        = 5,     -- humanoid, CC-able
        ["Boneweaver"]                  = 8,   -- bone caster
        ["Candlestick Mage"]            = 8,   -- fire caster
        ["Reanimated Corpse"]           = "SKIP",   -- mass raise filler
    },

    ["The Temple of Atal'Hakkar"] = {
        ["Atal'ai Deathwalker"]         = 8,   -- shadow damage caster
        ["Atal'ai Priest"]              = 8,   -- healer
        ["Atal'ai Witch Doctor"]        = 8,   -- hex + heal
        ["Atal'ai Slave"]               = 5,     -- humanoid, CC-able
        ["Gaseous Lurker"]              = 5,     -- elemental, banishable
        ["Jade Ooze"]                   = "SKIP",   -- environmental filler
    },

    ["Blackrock Depths"] = {
        ["Shadowforge Surveyor"]        = 8,   -- ranged caster
        ["Shadowforge Flame Keeper"]    = 8,   -- fire damage + buff
        ["Shadowforge Sharpshooter"]    = 8,   -- ranged multishot
        ["Dark Iron Medic"]             = 8,   -- healer
        ["Shadowforge Senator"]         = 8,   -- fireball + flamestrike
        ["Dark Iron Tastetester"]       = 5,     -- humanoid, CC-able
        ["Anvilrage Officer"]           = 8,   -- rallies nearby mobs
    },

    ["Lower Blackrock Spire"] = {
        ["Blackhand Summoner"]          = 8,   -- fire caster + demon summons
        ["Blackhand Incarcerator"]      = 8,   -- stuns party members
        ["Smolderthorn Shadow Priest"]  = 8,   -- healer + shadow damage
        ["Smolderthorn Witch Doctor"]   = 8,   -- healer + hex
        ["Smolderthorn Seer"]           = 8,   -- lightning bolt caster
        ["Smolderthorn Headhunter"]     = 5,     -- humanoid, CC-able
        ["Scarshield Warlock"]          = 8,   -- demon summoner
        ["Scarshield Spellbinder"]      = 8,   -- counterspell + arcane
        ["Spirestone Mystic"]           = 8,   -- caster
        ["Spirestone Ogre Magus"]       = 8,   -- frostbolt + polymorph
        ["Spirestone Battle Mage"]      = 5,     -- humanoid, CC-able
    },

    -- ============================================================
    -- CLASSIC RAIDS
    -- ============================================================

    ["Molten Core"] = {
        ["Firelord"]                    = 8,
        ["Flamewaker Healer"]          = 8,
        ["Flamewaker Priest"]          = 8,
        ["Firesworn"]                  = 8,
        ["Son of Flame"]               = 8,
        ["Ancient Core Hound"]         = 5,
        ["Core Hound"]                 = 5,
        ["Lava Elemental"]             = 5,
        ["Lava Surger"]                = 5,
        ["Primal Flame Elemental"]     = 5,
        ["Flame Imp"]                  = "SKIP",
        ["Lava Spawn"]                 = "SKIP",
    },

    ["Onyxia's Lair"] = {
        ["Onyxian Warder"]             = 8,
    },

    ["Blackwing Lair"] = {
        ["Grethok the Controller"]     = 8,
        ["Blackwing Mage"]             = 8,
        ["Blackwing Spellbinder"]      = 8,
        ["Blackwing Taskmaster"]       = 8,
        ["Blackwing Warlock"]          = 8,
        ["Death Talon Captain"]        = 8,
        ["Death Talon Flamescale"]     = 8,
        ["Death Talon Hatcher"]        = 8,
        ["Death Talon Overseer"]       = 8,
        ["Master Elemental Shaper Krixix"] = 8,
        ["Enraged Felguard"]           = 5,
        ["Black Whelp"]                = "SKIP",
        ["Blue Whelp"]                 = "SKIP",
        ["Bronze Whelp"]               = "SKIP",
        ["Corrupted Blue Whelp"]       = "SKIP",
        ["Corrupted Bronze Whelp"]     = "SKIP",
        ["Corrupted Green Whelp"]      = "SKIP",
        ["Corrupted Red Whelp"]        = "SKIP",
        ["Green Whelp"]                = "SKIP",
        ["Red Whelp"]                  = "SKIP",
    },

    ["Zul'Gurub"] = {
        ["Gurubashi Bat Rider"]        = 8,
        ["Gurubashi Blood Drinker"]    = 8,
        ["Hakkari Blood Priest"]       = 8,
        ["Hakkari Priest"]             = 8,
        ["Hakkari Shadow Hunter"]      = 8,
        ["Hakkari Shadowcaster"]       = 8,
        ["Hakkari Witch Doctor"]       = 8,
        ["Mad Servant"]                = 8,
        ["Ohgan"]                      = 8,
        ["Powerful Healing Ward"]      = 8,
        ["Son of Hakkar"]              = 8,
        ["Zanza the Restless"]         = 8,
        ["Zealot Lor'Khan"]            = 8,
        ["Mad Voidwalker"]             = 5,
        ["Razzashi Adder"]             = 5,
        ["Razzashi Cobra"]             = 5,
        ["Razzashi Raptor"]            = 5,
        ["Razzashi Serpent"]           = 5,
        ["Razzashi Venombrood"]        = 5,
        ["Zulian Guardian"]            = 5,
        ["Zulian Panther"]             = 5,
        ["Zulian Stalker"]             = 5,
        ["Zulian Tiger"]               = 5,
        ["Frog"]                       = "SKIP",
        ["Jungle Toad"]                = "SKIP",
        ["Parasitic Serpent"]          = "SKIP",
        ["Snake"]                      = "SKIP",
        ["Spider"]                     = "SKIP",
        ["Toad"]                       = "SKIP",
    },

    ["Ruins of Ahn'Qiraj"] = {
        ["Anubisath Guardian"]         = 8,
        ["Anubisath Swarmguard"]       = 8,
        ["Colonel Zerran"]             = 8,
        ["Hive'Zara Hornet"]           = 8,
        ["Hive'Zara Stinger"]          = 8,
        ["Mana Fiend"]                 = 8,
        ["Major Yeggeth"]              = 8,
        ["Obsidian Destroyer"]         = 8,
        ["Spitting Scarab"]            = 8,
        ["Swarmguard Needler"]         = 8,
        ["Beetle"]                     = "SKIP",
        ["Buru Egg"]                   = "SKIP",
        ["Canal Frenzy"]               = "SKIP",
        ["Hive'Zara Larva"]            = "SKIP",
        ["Scorpion"]                   = "SKIP",
        ["Silicate Feeder"]            = "SKIP",
    },

    ["Temple of Ahn'Qiraj"] = {
        ["Anubisath Defender"]         = 8,
        ["Anubisath Sentinel"]         = 8,
        ["Eye Tentacle"]               = 8,
        ["Giant Eye Tentacle"]         = 8,
        ["Obsidian Eradicator"]        = 8,
        ["Obsidian Nullifier"]         = 8,
        ["Qiraji Brainwasher"]         = 8,
        ["Qiraji Mindslayer"]          = 8,
        ["Spawn of Fankriss"]          = 8,
        ["Vekniss Stinger"]            = 8,
        ["Vekniss Borer"]              = 5,
        ["Vekniss Wasp"]               = 5,
        ["Beetle"]                     = "SKIP",
        ["Dark Blue Qiraji Battle Tank"] = "SKIP",
        ["Gilded Scarab"]              = "SKIP",
        ["Glob of Viscidus"]           = "SKIP",
        ["Light Blue Qiraji Battle Tank"] = "SKIP",
        ["Light Green Qiraji Battle Tank"] = "SKIP",
        ["Orange Qiraji Battle Tank"]  = "SKIP",
        ["Scorpion"]                   = "SKIP",
        ["Twilight Qiraji Battle Tank"] = "SKIP",
    },

    ["Naxxramas"] = {
        ["Bile Retcher"]               = 8,
        ["Deathknight Captain"]        = 8,
        ["Deathknight Cavalier"]       = 8,
        ["Eye Stalk"]                  = 8,
        ["Mad Scientist"]             = 8,
        ["Naxxramas Acolyte"]          = 8,
        ["Naxxramas Cultist"]          = 8,
        ["Necro Knight"]               = 8,
        ["Necropolis Acolyte"]         = 8,
        ["Shade of Naxxramas"]         = 8,
        ["Skeletal Smith"]             = 8,
        ["Soul Weaver"]                = 8,
        ["Spectral Deathknight"]       = 8,
        ["Spectral Rider"]             = 8,
        ["Spirit of Naxxramas"]        = 8,
        ["Stoneskin Gargoyle"]         = 8,
        ["Surgical Assistant"]         = 8,
        ["Unholy Staff"]               = 8,
        ["Unrelenting Deathknight"]    = 8,
        ["Unrelenting Rider"]          = 8,
        ["Carrion Spinner"]            = 5,
        ["Dread Creeper"]              = 5,
        ["Frenzied Bat"]               = 5,
        ["Infectious Skitterer"]       = 5,
        ["Plagued Bat"]                = 5,
        ["Plagued Deathhound"]         = 5,
        ["Venom Stalker"]              = 5,
        ["Bile Sludge"]                = "SKIP",
        ["Corpse Scarab"]              = "SKIP",
        ["Larva"]                      = "SKIP",
        ["Maggot"]                     = "SKIP",
        ["Plague Slime"]               = "SKIP",
        ["Rat"]                        = "SKIP",
        ["Spider"]                     = "SKIP",
        ["Spore"]                      = "SKIP",
        ["Web Wrap"]                   = "SKIP",
    },
}

-- ============================================================
-- ZONE ALIASES
-- Maps alternate / partial zone name strings to canonical DB keys.
-- Subsequent expansion modules merge into this table.
-- ============================================================

AutoMarkAssist_ZoneAliases = {
    ["Ragefire Chasm"]                  = "Ragefire Chasm",
    ["Ragefire"]                        = "Ragefire Chasm",
    ["Wailing Caverns"]                 = "Wailing Caverns",
    ["Deadmines"]                       = "The Deadmines",
    ["The Deadmines"]                   = "The Deadmines",
    ["Shadowfang Keep"]                 = "Shadowfang Keep",
    ["Shadowfang"]                      = "Shadowfang Keep",
    ["The Stockade"]                    = "The Stockade",
    ["Stockade"]                        = "The Stockade",
    ["Stormwind Stockade"]              = "The Stockade",
    ["Blackfathom Deeps"]               = "Blackfathom Deeps",
    ["Blackfathom"]                     = "Blackfathom Deeps",
    ["Gnomeregan"]                      = "Gnomeregan",
    ["Razorfen Kraul"]                  = "Razorfen Kraul",
    ["Razorfen Downs"]                  = "Razorfen Downs",
    ["Scarlet Halls"]                   = "Scarlet Halls",
    ["Scarlet Monastery"]               = "Scarlet Monastery",
    ["Zul'Farrak"]                      = "Zul'Farrak",
    ["Maraudon"]                        = "Maraudon",
    ["Dire Maul"]                       = "Dire Maul",
    ["Stratholme"]                      = "Stratholme",
    ["Scholomance"]                     = "Scholomance",
    ["Temple of Atal'Hakkar"]           = "The Temple of Atal'Hakkar",
    ["The Temple of Atal'Hakkar"]       = "The Temple of Atal'Hakkar",
    ["Sunken Temple"]                   = "The Temple of Atal'Hakkar",
    ["Blackrock Depths"]                = "Blackrock Depths",
    ["Lower Blackrock Spire"]           = "Lower Blackrock Spire",
    ["LBRS"]                            = "Lower Blackrock Spire",
    ["Molten Core"]                     = "Molten Core",
    ["MC"]                              = "Molten Core",
    ["Onyxia's Lair"]                   = "Onyxia's Lair",
    ["Onyxias Lair"]                    = "Onyxia's Lair",
    ["Onyxia"]                          = "Onyxia's Lair",
    ["Ony"]                             = "Onyxia's Lair",
    ["Blackwing Lair"]                  = "Blackwing Lair",
    ["Blackwing"]                       = "Blackwing Lair",
    ["BWL"]                             = "Blackwing Lair",
    ["Zul'Gurub"]                       = "Zul'Gurub",
    ["ZG"]                              = "Zul'Gurub",
    ["Ruins of Ahn'Qiraj"]              = "Ruins of Ahn'Qiraj",
    ["Ruins of AhnQiraj"]               = "Ruins of Ahn'Qiraj",
    ["AQ20"]                            = "Ruins of Ahn'Qiraj",
    ["AQ 20"]                           = "Ruins of Ahn'Qiraj",
    ["Temple of Ahn'Qiraj"]             = "Temple of Ahn'Qiraj",
    ["Temple of AhnQiraj"]              = "Temple of Ahn'Qiraj",
    ["AQ40"]                            = "Temple of Ahn'Qiraj",
    ["AQ 40"]                           = "Temple of Ahn'Qiraj",
    ["Naxxramas"]                       = "Naxxramas",
    ["Naxx"]                            = "Naxxramas",
}

-- ============================================================
-- EXPANSION ORDER
-- Defines the display order for the Database tab zone grouping.
-- Subsequent expansion modules append to this table.
-- ============================================================

AutoMarkAssist_ExpansionOrder = {
    { name = "Classic", dungeons = {
        "Ragefire Chasm", "Wailing Caverns", "The Deadmines", "Shadowfang Keep",
        "The Stockade", "Blackfathom Deeps", "Gnomeregan", "Razorfen Kraul",
        "Razorfen Downs", "Scarlet Halls", "Scarlet Monastery", "Zul'Farrak",
        "Maraudon", "Dire Maul", "Stratholme", "Scholomance",
        "The Temple of Atal'Hakkar", "Blackrock Depths", "Lower Blackrock Spire",
    }, raids = {
        "Molten Core", "Onyxia's Lair", "Blackwing Lair", "Zul'Gurub",
        "Ruins of Ahn'Qiraj", "Temple of Ahn'Qiraj", "Naxxramas",
    }},
}
