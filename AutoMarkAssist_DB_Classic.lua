-- AutoMarkAssist_DB_Classic.lua
-- Mob kill-priority database for Classic (Vanilla) dungeons and raids.
-- This is the FIRST DB module loaded -- it creates the global tables.
-- Subsequent expansion modules merge into these tables.
--
-- NOTE: Mob names reflect post-Cataclysm revamps where applicable.
-- Classic Era and TBC/WotLK Classic servers may use original pre-Cata names
-- for some mobs.  The addon falls back to MEDIUM for unknown mobs; adjust
-- entries in-game via the Database tab or by editing this file directly.
--
-- Priority values:
--   "HIGH"   -> Skull/Cross pool  (healers, interruptible casters, most dangerous)
--   "CC"     -> Square/Moon/Diamond pool  (crowd-control targets)
--   "MEDIUM" -> Triangle/Circle pool  (standard dangerous mobs)
--   "LOW"    -> Star pool  (least threatening)
--   "SKIP"   -> Never mark this mob.
--
-- Adjust via the in-game Database tab or by editing this file directly.

-- Creates the global database tables that subsequent expansion modules merge into.

AutoMarkAssist_MobDB = {

    -- ============================================================
    -- CLASSIC DUNGEONS
    -- ============================================================

    ["Ragefire Chasm"] = {
        ["Corrupted Houndmaster"]       = "HIGH",   -- calls beasts; kill first
        ["Dark Shaman Acolyte"]         = "HIGH",   -- flame shock caster
        ["Searing Blade Cultist"]       = "MEDIUM",
        ["Searing Blade Enforcer"]      = "MEDIUM",
        ["Molten Elemental"]            = "CC",     -- elemental, banishable
        ["Corrupted Whelp"]             = "LOW",
    },

    ["Wailing Caverns"] = {
        ["Druid of the Fang"]           = "HIGH",   -- healer + lightning bolt caster
        ["Deviate Ravager"]             = "MEDIUM",
        ["Deviate Viper"]               = "CC",     -- beast, trappable
        ["Deviate Shambler"]            = "MEDIUM",
        ["Deviate Guardian"]            = "MEDIUM",
        ["Deviate Adder"]               = "CC",     -- beast, trappable
        ["Evolving Ectoplasm"]          = "LOW",
        ["Serpentbloom Snake"]          = "SKIP",   -- ambient filler
    },

    ["The Deadmines"] = {
        ["Defias Blood Wizard"]         = "HIGH",   -- fire caster; interrupt priority
        ["Defias Squallshaper"]         = "HIGH",   -- frost caster + heal
        ["Defias Envoker"]              = "HIGH",   -- holy fire caster
        ["Defias Reaper"]               = "MEDIUM",
        ["Defias Overseer"]             = "MEDIUM",
        ["Defias Miner"]                = "LOW",
        ["Defias Digger"]               = "LOW",
        ["Defias Pirate"]               = "CC",     -- humanoid, CC-able
        ["Goblin Woodcarver"]           = "MEDIUM",
        ["Defias Taskmaster"]           = "HIGH",   -- buffs nearby adds
    },

    ["Shadowfang Keep"] = {
        ["Tormented Officer"]           = "HIGH",   -- forsaken caster
        ["Wailing Guardsman"]           = "HIGH",   -- screaming strikes + fear
        ["Unstable Ravager"]            = "HIGH",   -- volatile damage
        ["Fetid Ghoul"]                 = "MEDIUM",
        ["Mindless Horror"]             = "MEDIUM",
        ["Dark Creeper"]                = "CC",     -- stealth mob, CC-able
        ["Corpse Eater"]                = "CC",     -- beast, trappable
        ["Deathsworn Captain"]          = "MEDIUM",
        ["Haunted Servitor"]            = "LOW",
    },

    ["The Stockade"] = {
        ["Petty Criminal"]              = "LOW",
        ["Defias Convict"]              = "MEDIUM",
        ["Defias Prisoner"]             = "CC",     -- humanoid, CC-able
        ["Defias Inmate"]               = "MEDIUM",
        ["Defias Insurgent"]            = "HIGH",   -- rallying cry buffs nearby
        ["Riverpaw Mystic"]             = "HIGH",   -- caster; lightning bolt
        ["Riverpaw Gnoll"]              = "MEDIUM",
    },

    ["Blackfathom Deeps"] = {
        ["Twilight Aquamancer"]         = "HIGH",   -- frost caster
        ["Twilight Shadowmage"]         = "HIGH",   -- shadow bolt volley
        ["Blackfathom Tide Priestess"]  = "HIGH",   -- healer
        ["Twilight Reaver"]             = "MEDIUM",
        ["Murkshallow Snapclaw"]        = "CC",     -- beast, trappable
        ["Fallenroot Rogue"]            = "CC",     -- stealth, humanoid CC-able
        ["Blackfathom Myrmidon"]        = "MEDIUM",
        ["Aku'mai Snapjaw"]             = "LOW",
    },

    ["Gnomeregan"] = {
        ["Mechanized Sentry"]           = "MEDIUM",
        ["Mechanized Guardian"]         = "MEDIUM",
        ["Arcane Nullifier X-21"]       = "HIGH",   -- silences and counterspells
        ["Leprous Technician"]          = "HIGH",   -- disease caster
        ["Leprous Gnome"]               = "CC",     -- humanoid, CC-able
        ["Caverndeep Burrower"]         = "CC",     -- beast, trappable
        ["Irradiated Invader"]          = "MEDIUM",
        ["Mobile Alert System"]         = "HIGH",   -- calls reinforcements
        ["Dark Iron Agent"]             = "HIGH",   -- stealth + sabotage
        ["Irradiated Pillager"]         = "LOW",
    },

    ["Razorfen Kraul"] = {
        ["Razorfen Quilguard"]          = "MEDIUM",
        ["Razorfen Dustweaver"]         = "HIGH",   -- lightning + heal
        ["Razorfen Geomancer"]          = "HIGH",   -- earth caster
        ["Death's Head Seer"]           = "HIGH",   -- shadow bolt volley
        ["Death's Head Cultist"]        = "HIGH",   -- shadow caster
        ["Razorfen Servitor"]           = "CC",     -- humanoid, CC-able
        ["Razorfen Handler"]            = "MEDIUM",
        ["Razorfen Beastmaster"]        = "HIGH",   -- beast caller
        ["Razorfen Groundshaker"]       = "MEDIUM",
        ["Kraul Bat"]                   = "SKIP",   -- ambient beast filler
    },

    ["Razorfen Downs"] = {
        ["Death's Head Necromancer"]    = "HIGH",   -- raises undead
        ["Death's Head Sage"]           = "HIGH",   -- shadow caster + heal
        ["Withered Spearhide"]          = "MEDIUM",
        ["Withered Warrior"]            = "MEDIUM",
        ["Withered Quilguard"]          = "CC",     -- can be CC'd
        ["Withered Reaver"]             = "MEDIUM",
        ["Frozen Soul"]                 = "CC",     -- undead, shackleable
        ["Boneflayer Ghoul"]            = "LOW",
    },

    ["Scarlet Halls"] = {
        ["Scarlet Evoker"]              = "HIGH",   -- fire caster; flamestrike
        ["Scarlet Treasurer"]           = "HIGH",   -- healer
        ["Scarlet Defender"]            = "MEDIUM",
        ["Scarlet Myrmidon"]            = "MEDIUM",
        ["Scarlet Scholar"]             = "HIGH",   -- arcane caster
        ["Scarlet Cannoneer"]           = "HIGH",   -- ranged; interrupt priority
        ["Master Dog Trainer"]          = "HIGH",   -- beast caller
        ["Scarlet Evangelist"]          = "CC",     -- humanoid, CC-able
        ["Scarlet Hall Guardian"]       = "MEDIUM",
        ["Hound"]                       = "SKIP",   -- pet filler; kill trainer
    },

    ["Scarlet Monastery"] = {
        ["Scarlet Zealot"]              = "HIGH",   -- fanatical self-buffer
        ["Scarlet Chaplain"]            = "HIGH",   -- healer; must die first
        ["Scarlet Judicator"]           = "HIGH",   -- holy caster + judgement
        ["Scarlet Centurion"]           = "MEDIUM",
        ["Scarlet Crusader"]            = "MEDIUM",
        ["Scarlet Fanatic"]             = "CC",     -- humanoid, CC-able
        ["Scarlet Friar"]               = "HIGH",   -- healer
        ["Scarlet Purifier"]            = "HIGH",   -- consecration + holy fire
        ["Scarlet Monk"]                = "MEDIUM",
        ["Scarlet Initiate"]            = "LOW",
    },

    ["Zul'Farrak"] = {
        ["Sandfury Witch Doctor"]       = "HIGH",   -- healer + hex
        ["Sandfury Shadowcaster"]       = "HIGH",   -- shadow bolt volley
        ["Sandfury Firecaller"]         = "HIGH",   -- fire nova + fireball
        ["Sandfury Executioner"]        = "MEDIUM",
        ["Sandfury Guardian"]           = "MEDIUM",
        ["Sandfury Blood Drinker"]      = "HIGH",   -- life drain caster
        ["Sandfury Zealot"]             = "CC",     -- humanoid, CC-able
        ["Sandfury Slave"]              = "LOW",
        ["Sandfury Cretin"]             = "LOW",
        ["Troll Totem"]                 = "SKIP",   -- totem filler
    },

    ["Maraudon"] = {
        ["Celebras Elementalist"]       = "HIGH",   -- nature caster
        ["Primordial Behemoth"]         = "MEDIUM",
        ["Barbed Lasher"]               = "CC",     -- plant, incapacitateable
        ["Cavern Shambler"]             = "MEDIUM",
        ["Putrid Shrieker"]             = "HIGH",   -- fear + disease
        ["Vile Larva"]                  = "SKIP",   -- swarm filler
        ["Centaur Pariah"]              = "HIGH",   -- caster
        ["Thessala Hydra"]              = "MEDIUM",
        ["Living Decay"]                = "LOW",
    },

    ["Dire Maul"] = {
        ["Gordok Ogre-Mage"]            = "HIGH",   -- arcane caster
        ["Gordok Warlock"]              = "HIGH",   -- shadow bolt + summons
        ["Gordok Mage-Lord"]            = "HIGH",   -- polymorph + blizzard
        ["Gordok Brute"]                = "MEDIUM",
        ["Gordok Enforcer"]             = "MEDIUM",
        ["Gordok Captain"]              = "MEDIUM",
        ["Gordok Bushwacker"]           = "CC",     -- humanoid, CC-able
        ["Wildspawn Imp"]               = "CC",     -- demon, banishable
        ["Wildspawn Shadowstalker"]     = "HIGH",   -- stealth + backstab
        ["Wildspawn Felsworn"]          = "HIGH",   -- fel caster
        ["Warpwood Treant"]             = "CC",     -- nature mob, incapacitateable
        ["Petrified Guardian"]          = "LOW",
        ["Felvine Shard"]               = "SKIP",   -- environmental filler
    },

    ["Stratholme"] = {
        ["Crypt Crawler"]               = "MEDIUM",
        ["Plague Ghoul"]                = "MEDIUM",
        ["Risen Sorcerer"]              = "HIGH",   -- shadow caster
        ["Risen Priest"]                = "HIGH",   -- healer
        ["Black Guard Sentry"]          = "MEDIUM",
        ["Crimson Sorcerer"]            = "HIGH",   -- fire mage caster
        ["Crimson Priest"]              = "HIGH",   -- healer
        ["Crimson Defender"]            = "MEDIUM",
        ["Crimson Gallant"]             = "CC",     -- humanoid, CC-able
        ["Thuzadin Necromancer"]        = "HIGH",   -- raises undead
        ["Thuzadin Shadowcaster"]       = "HIGH",   -- shadow caster
        ["Mindless Skeleton"]           = "SKIP",   -- mass undead filler
        ["Plagued Rat"]                 = "SKIP",   -- ambient filler
    },

    ["Scholomance"] = {
        ["Risen Guard"]                 = "MEDIUM",
        ["Scholomance Acolyte"]         = "HIGH",   -- shadow caster
        ["Scholomance Necrolyte"]       = "HIGH",   -- healer + raises adds
        ["Scholomance Neophyte"]        = "CC",     -- humanoid, CC-able
        ["Boneweaver"]                  = "HIGH",   -- bone caster
        ["Flesh Horror"]                = "MEDIUM",
        ["Rattlegore Animated"]         = "MEDIUM",
        ["Candlestick Mage"]            = "HIGH",   -- fire caster
        ["Meat Golem"]                  = "LOW",
        ["Reanimated Corpse"]           = "SKIP",   -- mass raise filler
    },

    ["The Temple of Atal'Hakkar"] = {
        ["Atal'ai Deathwalker"]         = "HIGH",   -- shadow damage caster
        ["Atal'ai Priest"]              = "HIGH",   -- healer
        ["Atal'ai Witch Doctor"]        = "HIGH",   -- hex + heal
        ["Atal'ai Warrior"]             = "MEDIUM",
        ["Atal'ai Slave"]               = "CC",     -- humanoid, CC-able
        ["Mummified Atal'ai"]           = "MEDIUM",
        ["Gaseous Lurker"]              = "CC",     -- elemental, banishable
        ["Atal'ai Corpse Eater"]        = "LOW",
        ["Jade Ooze"]                   = "SKIP",   -- environmental filler
    },

    ["Blackrock Depths"] = {
        ["Shadowforge Surveyor"]        = "HIGH",   -- ranged caster
        ["Shadowforge Flame Keeper"]    = "HIGH",   -- fire damage + buff
        ["Shadowforge Sharpshooter"]    = "HIGH",   -- ranged multishot
        ["Dark Iron Medic"]             = "HIGH",   -- healer
        ["Shadowforge Senator"]         = "HIGH",   -- fireball + flamestrike
        ["Dark Iron Tastetester"]       = "CC",     -- humanoid, CC-able
        ["Dark Iron Slaver"]            = "MEDIUM",
        ["Dark Iron Taskmaster"]        = "MEDIUM",
        ["Dark Iron Steelbreaker"]      = "MEDIUM",
        ["Anvilrage Soldier"]           = "MEDIUM",
        ["Anvilrage Officer"]           = "HIGH",   -- rallies nearby mobs
        ["Fireguard Destroyer"]         = "MEDIUM",
        ["Shadowforge Peasant"]         = "LOW",
    },

    ["Lower Blackrock Spire"] = {
        ["Blackhand Summoner"]          = "HIGH",   -- fire caster + demon summons
        ["Blackhand Incarcerator"]      = "HIGH",   -- stuns party members
        ["Blackhand Veteran"]           = "MEDIUM",
        ["Smolderthorn Shadow Priest"]  = "HIGH",   -- healer + shadow damage
        ["Smolderthorn Witch Doctor"]   = "HIGH",   -- healer + hex
        ["Smolderthorn Seer"]           = "HIGH",   -- lightning bolt caster
        ["Smolderthorn Berserker"]      = "MEDIUM",
        ["Smolderthorn Headhunter"]     = "CC",     -- humanoid, CC-able
        ["Scarshield Warlock"]          = "HIGH",   -- demon summoner
        ["Scarshield Spellbinder"]      = "HIGH",   -- counterspell + arcane
        ["Spirestone Mystic"]           = "HIGH",   -- caster
        ["Spirestone Ogre Magus"]       = "HIGH",   -- frostbolt + polymorph
        ["Spirestone Battle Mage"]      = "CC",     -- humanoid, CC-able
        ["Spirestone Warlord"]          = "MEDIUM",
    },

    -- ============================================================
    -- CLASSIC RAIDS
    -- ============================================================

    ["Molten Core"] = {
        ["Firelord"]                    = "HIGH",
        ["Flamewaker Healer"]          = "HIGH",
        ["Flamewaker Priest"]          = "HIGH",
        ["Firesworn"]                  = "HIGH",
        ["Son of Flame"]               = "HIGH",
        ["Ancient Core Hound"]         = "CC",
        ["Core Hound"]                 = "CC",
        ["Lava Elemental"]             = "CC",
        ["Lava Surger"]                = "CC",
        ["Primal Flame Elemental"]     = "CC",
        ["Flameguard"]                 = "MEDIUM",
        ["Flamewaker"]                 = "MEDIUM",
        ["Flamewaker Elite"]           = "MEDIUM",
        ["Flamewaker Protector"]       = "MEDIUM",
        ["Firewalker"]                 = "MEDIUM",
        ["Lava Annihilator"]           = "MEDIUM",
        ["Lava Reaver"]                = "MEDIUM",
        ["Molten Destroyer"]           = "MEDIUM",
        ["Molten Giant"]               = "MEDIUM",
        ["Core Rager"]                 = "LOW",
        ["Magmakin"]                   = "LOW",
        ["Majordomo Executus"]         = "LOW",    -- let Firesworn take primary kill-order marks first
        ["Flame Imp"]                  = "SKIP",
        ["Lava Spawn"]                 = "SKIP",
    },

    ["Onyxia's Lair"] = {
        ["Onyxian Warder"]             = "HIGH",
        ["Onyxian Lair Guard"]         = "MEDIUM",
        ["Onyxian Whelp"]              = "LOW",
        ["Onyxia"]                     = "LOW",    -- keeps whelps and warders ahead of the boss when they are active
    },

    ["Blackwing Lair"] = {
        ["Grethok the Controller"]     = "HIGH",
        ["Blackwing Mage"]             = "HIGH",
        ["Blackwing Spellbinder"]      = "HIGH",
        ["Blackwing Taskmaster"]       = "HIGH",
        ["Blackwing Warlock"]          = "HIGH",
        ["Death Talon Captain"]        = "HIGH",
        ["Death Talon Flamescale"]     = "HIGH",
        ["Death Talon Hatcher"]        = "HIGH",
        ["Death Talon Overseer"]       = "HIGH",
        ["Master Elemental Shaper Krixix"] = "HIGH",
        ["Enraged Felguard"]           = "CC",
        ["Black Drakonid"]             = "MEDIUM",
        ["Blackwing Guardsman"]        = "MEDIUM",
        ["Blackwing Legionnaire"]      = "MEDIUM",
        ["Blackwing Technician"]       = "LOW",
        ["Blue Drakonid"]              = "MEDIUM",
        ["Bone Construct"]             = "LOW",
        ["Bronze Drakonid"]            = "MEDIUM",
        ["Chromatic Drakonid"]         = "MEDIUM",
        ["Death Talon Dragonspawn"]    = "MEDIUM",
        ["Death Talon Seether"]        = "MEDIUM",
        ["Death Talon Wyrmguard"]      = "MEDIUM",
        ["Death Talon Wyrmkin"]        = "MEDIUM",
        ["Green Drakonid"]             = "MEDIUM",
        ["Red Drakonid"]               = "MEDIUM",
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
        ["Gurubashi Bat Rider"]        = "HIGH",
        ["Gurubashi Blood Drinker"]    = "HIGH",
        ["Hakkari Blood Priest"]       = "HIGH",
        ["Hakkari Priest"]             = "HIGH",
        ["Hakkari Shadow Hunter"]      = "HIGH",
        ["Hakkari Shadowcaster"]       = "HIGH",
        ["Hakkari Witch Doctor"]       = "HIGH",
        ["Mad Servant"]                = "HIGH",
        ["Ohgan"]                      = "HIGH",
        ["Powerful Healing Ward"]      = "HIGH",
        ["Son of Hakkar"]              = "HIGH",
        ["Zanza the Restless"]         = "HIGH",
        ["Zealot Lor'Khan"]            = "HIGH",
        ["Mad Voidwalker"]             = "CC",
        ["Razzashi Adder"]             = "CC",
        ["Razzashi Cobra"]             = "CC",
        ["Razzashi Raptor"]            = "CC",
        ["Razzashi Serpent"]           = "CC",
        ["Razzashi Venombrood"]        = "CC",
        ["Zulian Guardian"]            = "CC",
        ["Zulian Panther"]             = "CC",
        ["Zulian Stalker"]             = "CC",
        ["Zulian Tiger"]               = "CC",
        ["Gurubashi Axe Thrower"]      = "MEDIUM",
        ["Gurubashi Berserker"]        = "MEDIUM",
        ["Gurubashi Champion"]         = "MEDIUM",
        ["Gurubashi Headhunter"]       = "MEDIUM",
        ["Voodoo Slave"]               = "MEDIUM",
        ["Zealot Zath"]                = "MEDIUM",
        ["Bloodseeker Bat"]            = "LOW",
        ["Frenzied Bloodseeker Bat"]   = "LOW",
        ["Spawn of Mar'li"]            = "LOW",
        ["Zulian Cub"]                 = "LOW",
        ["Frog"]                       = "SKIP",
        ["Jungle Toad"]                = "SKIP",
        ["Parasitic Serpent"]          = "SKIP",
        ["Snake"]                      = "SKIP",
        ["Spider"]                     = "SKIP",
        ["Toad"]                       = "SKIP",
    },

    ["Ruins of Ahn'Qiraj"] = {
        ["Anubisath Guardian"]         = "HIGH",
        ["Anubisath Swarmguard"]       = "HIGH",
        ["Colonel Zerran"]             = "HIGH",
        ["Hive'Zara Hornet"]           = "HIGH",
        ["Hive'Zara Stinger"]          = "HIGH",
        ["Mana Fiend"]                 = "HIGH",
        ["Major Yeggeth"]              = "HIGH",
        ["Obsidian Destroyer"]         = "HIGH",
        ["Spitting Scarab"]            = "HIGH",
        ["Swarmguard Needler"]         = "HIGH",
        ["Anubisath Warrior"]          = "MEDIUM",
        ["Captain Drenn"]              = "MEDIUM",
        ["Captain Qeez"]               = "MEDIUM",
        ["Captain Tuubid"]             = "MEDIUM",
        ["Captain Xurrem"]             = "MEDIUM",
        ["Flesh Hunter"]               = "MEDIUM",
        ["Hive'Zara Collector"]        = "MEDIUM",
        ["Hive'Zara Drone"]            = "MEDIUM",
        ["Hive'Zara Sandstalker"]      = "MEDIUM",
        ["Hive'Zara Soldier"]          = "MEDIUM",
        ["Hive'Zara Tail Lasher"]      = "MEDIUM",
        ["Hive'Zara Wasp"]             = "MEDIUM",
        ["Major Pakkon"]               = "MEDIUM",
        ["Qiraji Gladiator"]           = "MEDIUM",
        ["Qiraji Swarmguard"]          = "MEDIUM",
        ["Qiraji Warrior"]             = "MEDIUM",
        ["Shrieker Scarab"]            = "MEDIUM",
        ["Hive'Zara Hatchling"]        = "LOW",
        ["Hive'Zara Swarmer"]          = "LOW",
        ["Vile Scarab"]                = "LOW",
        ["Beetle"]                     = "SKIP",
        ["Buru Egg"]                   = "SKIP",
        ["Canal Frenzy"]               = "SKIP",
        ["Hive'Zara Larva"]            = "SKIP",
        ["Scorpion"]                   = "SKIP",
        ["Silicate Feeder"]            = "SKIP",
    },

    ["Temple of Ahn'Qiraj"] = {
        ["Anubisath Defender"]         = "HIGH",
        ["Anubisath Sentinel"]         = "HIGH",
        ["Eye Tentacle"]               = "HIGH",
        ["Giant Eye Tentacle"]         = "HIGH",
        ["Obsidian Eradicator"]        = "HIGH",
        ["Obsidian Nullifier"]         = "HIGH",
        ["Qiraji Brainwasher"]         = "HIGH",
        ["Qiraji Mindslayer"]          = "HIGH",
        ["Spawn of Fankriss"]          = "HIGH",
        ["Vekniss Stinger"]            = "HIGH",
        ["Vekniss Borer"]              = "CC",
        ["Vekniss Wasp"]               = "CC",
        ["Anubisath Swarmguard"]       = "MEDIUM",
        ["Anubisath Warder"]           = "MEDIUM",
        ["Anubisath Warrior"]          = "MEDIUM",
        ["Claw Tentacle"]              = "MEDIUM",
        ["Giant Claw Tentacle"]        = "MEDIUM",
        ["Qiraji Champion"]            = "MEDIUM",
        ["Qiraji Lasher"]              = "MEDIUM",
        ["Qiraji Slayer"]              = "MEDIUM",
        ["Qiraji Warlord"]             = "MEDIUM",
        ["Sartura's Royal Guard"]      = "MEDIUM",
        ["Vekniss Guardian"]           = "MEDIUM",
        ["Vekniss Hive Crawler"]       = "MEDIUM",
        ["Vekniss Soldier"]            = "MEDIUM",
        ["Vekniss Warrior"]            = "MEDIUM",
        ["Ouro Scarab"]                = "LOW",
        ["Qiraji Scarab"]              = "LOW",
        ["Qiraji Scorpion"]            = "LOW",
        ["Vekniss Drone"]              = "LOW",
        ["Vekniss Hatchling"]          = "LOW",
        ["Yauj Brood"]                 = "LOW",
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
        ["Bile Retcher"]               = "HIGH",
        ["Deathknight Captain"]        = "HIGH",
        ["Deathknight Cavalier"]       = "HIGH",
        ["Eye Stalk"]                  = "HIGH",
        ["Mad Scientist"]             = "HIGH",
        ["Naxxramas Acolyte"]          = "HIGH",
        ["Naxxramas Cultist"]          = "HIGH",
        ["Necro Knight"]               = "HIGH",
        ["Necropolis Acolyte"]         = "HIGH",
        ["Shade of Naxxramas"]         = "HIGH",
        ["Skeletal Smith"]             = "HIGH",
        ["Soul Weaver"]                = "HIGH",
        ["Spectral Deathknight"]       = "HIGH",
        ["Spectral Rider"]             = "HIGH",
        ["Spirit of Naxxramas"]        = "HIGH",
        ["Stoneskin Gargoyle"]         = "HIGH",
        ["Surgical Assistant"]         = "HIGH",
        ["Unholy Staff"]               = "HIGH",
        ["Unrelenting Deathknight"]    = "HIGH",
        ["Unrelenting Rider"]          = "HIGH",
        ["Carrion Spinner"]            = "CC",
        ["Dread Creeper"]              = "CC",
        ["Frenzied Bat"]               = "CC",
        ["Infectious Skitterer"]       = "CC",
        ["Plagued Bat"]                = "CC",
        ["Plagued Deathhound"]         = "CC",
        ["Venom Stalker"]              = "CC",
        ["Abomination"]                = "MEDIUM",
        ["Bony Construct"]             = "MEDIUM",
        ["Crypt Guard"]                = "MEDIUM",
        ["Crypt Reaver"]               = "MEDIUM",
        ["Deathknight Understudy"]     = "MEDIUM",
        ["Deathknight Vindicator"]     = "MEDIUM",
        ["Infectious Ghoul"]           = "MEDIUM",
        ["Living Monstrosity"]         = "MEDIUM",
        ["Patchwork Golem"]            = "MEDIUM",
        ["Plagued Champion"]           = "MEDIUM",
        ["Plagued Construct"]          = "MEDIUM",
        ["Plagued Gargoyle"]           = "MEDIUM",
        ["Plagued Guardian"]           = "MEDIUM",
        ["Plagued Warrior"]            = "MEDIUM",
        ["Sludge Belcher"]             = "MEDIUM",
        ["Soldier of the Frozen Wastes"] = "MEDIUM",
        ["Stitched Spewer"]            = "MEDIUM",
        ["Tomb Horror"]                = "MEDIUM",
        ["Unstoppable Abomination"]    = "MEDIUM",
        ["Deathchill Servant"]         = "LOW",
        ["Maexxna Spiderling"]         = "LOW",
        ["Rotting Ghoul"]              = "LOW",
        ["Spectral Horse"]             = "LOW",
        ["Spectral Trainee"]           = "LOW",
        ["Unrelenting Trainee"]        = "LOW",
        ["Zombie Chow"]                = "LOW",
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
    { name = "Classic", zones = {
        "Ragefire Chasm", "Wailing Caverns", "The Deadmines", "Shadowfang Keep",
        "The Stockade", "Blackfathom Deeps", "Gnomeregan", "Razorfen Kraul",
        "Razorfen Downs", "Scarlet Halls", "Scarlet Monastery", "Zul'Farrak",
        "Maraudon", "Dire Maul", "Stratholme", "Scholomance",
        "The Temple of Atal'Hakkar", "Blackrock Depths", "Lower Blackrock Spire",
        "Molten Core", "Onyxia's Lair", "Blackwing Lair", "Zul'Gurub",
        "Ruins of Ahn'Qiraj", "Temple of Ahn'Qiraj", "Naxxramas",
    }},
}
