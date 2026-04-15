-- AutoMarkAssist_DB_TBC.lua
-- The Burning Crusade dungeon and raid entries.  Loaded AFTER AutoMarkAssist_DB_Classic.lua.
-- Merges TBC dungeon and raid zones into the shared database tables.

local db      = AutoMarkAssist_MobDB
local aliases = AutoMarkAssist_ZoneAliases
local order   = AutoMarkAssist_ExpansionOrder

-- ============================================================
-- THE BURNING CRUSADE DUNGEONS
-- ============================================================

-- --- Hellfire Citadel ---------------------------------

db["Hellfire Ramparts"] = {
    ["Hellfire Channeler"]          = 8,   -- channels empowerment on bosses
    ["Bonechewer Beastmaster"]      = 8,   -- has a pet; pet dies when master dies
    ["Bonechewer Blood Drinker"]    = 8,   -- life-drain caster
    ["Hellfire Watcher"]            = 5,     -- ranged, can be crowd-controlled
    ["Hellfire Watchtower"]         = 5,
    ["Bonechewer Hungerer"]         = "SKIP",   -- Beastmaster pet filler
}

db["The Blood Furnace"] = {
    ["Bleeding Hollow Scryer"]      = 8,   -- healer/caster
    ["Laughing Skull Warden"]       = 8,   -- healer
    ["Laughing Skull Rogue"]        = 8,   -- stealths, opens with heavy burst
    ["Fel Orc Convert"]             = 5,
    ["Bleeding Hollow Torturer"]    = 8,   -- interruption-worthy pain spells
    ["Bleeding Hollow Skulker"]     = 8,   -- stealth + ambush
    ["Fel Orc Neophyte"]            = "SKIP",   -- cage event filler
}

db["The Shattered Halls"] = {
    ["Shattered Hand Zealot"]       = 8,   -- executes low-HP players (Gloat)
    ["Shattered Hand Assassin"]     = 8,   -- stealths, Garrote + burst
    ["Shattered Hand Heathen"]      = 8,   -- Blood Surge heal on self
    ["Shattered Hand Reaver"]       = 5,
    ["Shattered Hand Savage"]       = 5,     -- beast, trappable
    ["Shattered Hand Berserker"]    = 8,   -- Enrage + whirlwind
    ["Shattered Hand Warhound"]     = "SKIP",   -- handler dog pack filler
}

-- --- Coilfang Reservoir ---------------------------------

db["The Slave Pens"] = {
    ["Coilfang Collaborator"]       = 8,   -- healer, top priority
    ["Coilfang Observer"]           = 8,   -- caster, Chain Lightning
    ["Coilfang Slavehandler"]       = 8,   -- has enslaved adds
    ["Coilfang Water Elemental"]    = 5,     -- banishable
    ["Underbat"]                    = 5,     -- beast, trappable
    ["Wastewalker Slave"]           = "SKIP",   -- Slavehandler pack filler
}

db["The Underbog"] = {
    ["Lykul Bloodseeker"]           = 8,   -- fast-hitting, dangerous burst
    ["Underbog Colossus"]           = 8,   -- Stomp AoE stun
    ["Underbog Shambler"]           = 5,     -- undead, shackleable
    ["Lykul Wasp"]                  = 5,     -- beast, trappable
    ["Spore Bat"]                   = 5,
    ["Black Stalker Spawn"]         = 5,
}

db["The Steamvault"] = {
    ["Coilfang Oracle"]             = 8,   -- healer; must die first
    ["Coilfang Technician"]         = 8,   -- repairs mechanical adds mid-fight
    ["Coilfang Engineer"]           = 8,   -- AoE chain-pull abilities
    ["Coilfang Myrmidon"]           = 5,
    ["Spore Bat"]                   = 8,   -- Steamvault opener should use kill-order, not CC marks
    ["Steam Surger"]                = 8,   -- ranged lightning; kill before Thespia
    ["Tidal Surger"]                = 8,   -- kill before Thespia
    ["Steamrigger Mechanic"]        = 8,   -- repairs Mekgineer; must die ASAP
    ["Coilfang Leper"]              = "SKIP",   -- gnome slave filler
}

-- --- Auchindoun ---------------------------------

db["Mana-Tombs"] = {
    ["Ethereal Theurgist"]          = 8,   -- caster, dangerous spells
    ["Ethereal Darkcaster"]         = 8,   -- Shadow Bolt Volley
    ["Ethereal Sorcerer"]           = 8,   -- Mana Burn
    ["Ethereal Spellbinder"]        = 8,   -- binds random party member
    ["Haunt"]                       = 5,     -- undead, shackleable
    ["Mana Leech"]                  = 8,   -- drains mana aggressively
    ["Nexus Stalker"]               = 5,     -- can be trapped
    ["Ethereal Priest"]             = 8,   -- healer
    ["Ethereal Assassin"]           = 8,   -- stealth + burst
    ["Ethereal Summoned Warrior"]   = "SKIP",   -- summoned filler
}

db["Auchenai Crypts"] = {
    ["Auchenai Monk"]               = 8,   -- healer
    ["Auchenai Soulpriest"]         = 8,   -- fear + shadow damage caster
    ["Ghostly Philanthropist"]      = 5,     -- undead, shackleable
    ["Worshipper of Eternos"]       = 5,
    ["Cultist Shard Watcher"]       = 8,   -- spawns shards
    ["Death's Head Cultist"]        = 8,   -- shadow damage caster
    ["Angered Skeleton"]            = "SKIP",   -- mass skeleton filler
}

db["Sethekk Halls"] = {
    ["Arakkoa Diviner"]             = 8,   -- healer + fear caster
    ["Time-Lost Controller"]        = 8,   -- mind controls party members
    ["Time-Lost Scryer"]            = 8,   -- dangerous AoE arcane
    ["Cobalt Serpent"]              = 5,     -- beast, trappable
    ["Avian Darkhawk"]              = 5,     -- beast, trappable
    ["Avian Warhawk"]               = 8,   -- bleeds + fast attack speed
    ["Sethekk Oracle"]              = 8,   -- healer
    ["Sethekk Ravenguard"]          = 8,
    ["Avian Flitter"]               = "SKIP",   -- flock filler
    ["Raven Hatchling"]             = "SKIP",   -- hatchling filler
}

db["Shadow Labyrinth"] = {
    ["Cabal Shadow Priest"]         = 8,   -- top priority: Mind Blast, heals self
    ["Cabal Hexer"]                 = 8,   -- polymorph + powerful hexes
    ["Cabal Cultist"]               = 8,   -- dangerous caster
    ["Cabal Soldier"]               = 5,
    ["Cabal Assassin"]              = 8,   -- stealth + heavy burst
    ["Cabal Rogue"]                 = 8,   -- stealth + cheap shot
    ["Cabal Warlock"]               = 8,   -- DoTs + summons demons
    ["Cabal Deathsworn"]            = 8,   -- execute-range finishers
    ["Fel Overseer"]                = 8,   -- whirlwind + charge
    ["Void Traveler"]               = 8,   -- walks to Vorpil; heals him on contact
    ["Shadow Imp"]                  = "SKIP",   -- spawned by Cabal Warlock; filler
}

-- --- Tempest Keep ---------------------------------

db["The Botanica"] = {
    ["Bloodwarder Mender"]          = 8,   -- healer; skull always
    ["Bloodwarder Physician"]       = 8,   -- healer
    ["Sunseeker Chemist"]           = 8,   -- toxic flasks; very high tank damage
    ["Sunseeker Researcher"]        = 8,   -- polymorphs + casts
    ["Sunseeker Botanist"]          = 5,     -- humanoid, sheepable
    ["Bloodwarder Protector"]       = 5,
    ["Sunseeker Gene-Splicer"]      = 8,   -- mutates adds mid-fight
    ["Vicious Thornshoots"]         = 5,     -- plant, incapacitateable
    ["Treant"]                      = 5,
    ["Sunseeker Bloodhawk"]         = "SKIP",   -- bird flock filler
    ["Bloodpetal Lasher"]           = "SKIP",   -- plant filler
    ["Bloodpetal Flayer"]           = "SKIP",   -- plant filler
    ["Bloodpetal Thorn"]            = "SKIP",   -- plant filler
    ["Mutant Bloodpetal"]           = "SKIP",   -- mutated plant filler
    ["Nether Tendril"]              = "SKIP",   -- tendril filler
}

db["The Arcatraz"] = {
    ["Eredar Deathbringer"]         = 8,   -- shadow damage + AoE silence
    ["Eredar Soul Eater"]           = 8,   -- soul drain on party
    ["Blazing Trickster"]           = 8,   -- AoE fire; interrupt priority
    ["Entrapped Berserker"]         = 8,   -- Enrage + AoE slam
    ["Neg'Jin Shackler"]            = 8,   -- shackles party members
    ["Arcatraz Warder"]             = 5,     -- humanoid, sheepable
    ["Protean Horror"]              = 5,     -- can be feared/banished
    ["Dalliah's Devotee"]           = 8,
    ["Void Spawner"]                = "SKIP",   -- spawned filler
    ["Soul Fragment"]               = "SKIP",   -- soul fragment filler
}

db["The Mechanar"] = {
    ["Sunseeker Astromage"]         = 8,   -- AoE Arcane Explosion
    ["Sunseeker Netherbinder"]      = 8,   -- healer + silence
    ["Sunseeker Gene-Splicer"]      = 8,   -- dangerous caster
    ["Blood Elf Reclaimer"]         = 8,   -- reclaims constructs mid-fight
    ["Blood Elf Surveyor"]          = 5,     -- humanoid, sheepable
    ["Nether Wraith"]               = 8,   -- banishable but dangerous if not
    ["Mechanar Tinkerer"]           = 8,   -- repairs other mobs
    ["Sunseeker Overseer"]          = 8,   -- buffs nearby mobs
    ["Tempest-Forge Destroyer"]     = 8,   -- AoE shock + stun
    ["Nether Spark"]                = "SKIP",   -- arcane filler
    ["Arcane Bomb"]                 = "SKIP",   -- bomb filler
}

-- --- Caverns of Time ---------------------------------

db["Old Hillsbrad Foothills"] = {
    ["Syndicate Assassin"]          = 8,   -- stealth + burst on healer
    ["Syndicate Watchman"]          = 8,   -- calls for backup
    ["Syndicate Shadow-Mage"]       = 8,   -- AoE shadow
    ["Hillsbrad Watchman"]          = 5,     -- humanoid, sheepable
    ["Durnholde Veteran"]           = 8,   -- veteran melee burst
    ["Durnholde Tracking Hound"]    = 5,     -- beast, trappable
    ["Durnholde War Horse"]         = "SKIP",   -- riderless mount filler
}

db["The Black Morass"] = {
    ["Rift Keeper"]                 = 8,   -- healer for Rift Lord; kill first
    ["Rift Lord"]                   = 8,   -- extremely dangerous melee
    ["Infinite Assassin"]           = 5,     -- targets Medivh directly
    ["Infinite Executioner"]        = 5,     -- executes low-HP units
    ["Infinite Saboteur"]           = 5,     -- disables defensive cooldowns
    ["Infinite Chrono-Sentinel"]    = 5,     -- interrupts Medivh's shield
    ["Rift Spawner"]                = "SKIP",   -- between-wave filler
}

-- --- Isle of Quel'Danas ---------------------------------

db["Magisters' Terrace"] = {
    ["Sunblade Physician"]          = 8,   -- healer; skull always
    ["Sunblade Blood Knight"]       = 8,   -- holy healer with bubble
    ["Sunblade Arch Mage"]          = 8,   -- AoE arcane + polymorph
    ["Sunblade Magister"]           = 8,   -- pyroblast spam caster
    ["Sunblade Warlock"]            = 8,   -- DoTs + summons felguard
    ["Sunblade Imp Handler"]        = 8,   -- kill to despawn imp packs
    ["Sunblade Imp"]                = 5,     -- banishable; dangerous in numbers
    ["Felguard Legionnaire"]        = 5,     -- banishable demon
    ["Sunblade Vindicator"]         = 8,   -- self-heals; must be interrupted
    ["Sunblade Imp Swarm"]          = "SKIP",   -- swarm filler
    ["Mana Tap Imp"]                = "SKIP",   -- mana-drain imp filler
}

-- ============================================================
-- THE BURNING CRUSADE RAIDS
-- ============================================================

db["Karazhan"] = {
    ["Arcane Anomaly"]              = 8,
    ["Astral Flare"]                = 8,
    ["Chaotic Sentience"]           = 8,
    ["Conjured Water Elemental"]    = 8,
    ["Doomguard"]                   = 8,
    ["Ethereal Spellfilcher"]       = 8,
    ["Ethereal Thief"]              = 8,
    ["Ghastly Haunt"]               = 8,
    ["Human Cleric"]                = 8,
    ["Human Conjurer"]              = 8,
    ["Kil'rek"]                     = 8,
    ["Mana Warp"]                   = 8,
    ["Orc Necrolyte"]               = 8,
    ["Orc Warlock"]                 = 8,
    ["Sorcerous Shade"]             = 8,
    ["Spell Shade"]                 = 8,
    ["Spectral Apprentice"]         = 8,
    ["Spectral Servant"]            = 8,
    ["Zealous Consort"]             = 8,
    ["Zealous Paramour"]            = 8,
    ["Coldmist Stalker"]            = 5,
    ["Coldmist Widow"]              = 5,
    ["Mana Feeder"]                 = 5,
    ["Phase Hound"]                 = 5,
    ["Shadowbat"]                   = 5,
    ["Vampiric Shadowbat"]          = 5,
    ["Dancing Flames"]              = "SKIP",
    ["Rat"]                         = "SKIP",
    ["Spider"]                      = "SKIP",
}

db["Gruul's Lair"] = {
    ["Blindeye the Seer"]           = 8,
    ["Kiggler the Crazed"]          = 8,
    ["Krosh Firehand"]              = 8,
    ["Olm the Summoner"]            = 8,
    ["Gronn-Priest"]                = 8,
    ["Wild Fel Stalker"]            = 5,
}

db["Magtheridon's Lair"] = {
    ["Hellfire Channeler"]          = 8,
    ["Burning Abyssal"]             = 5,
}

db["Serpentshrine Cavern"] = {
    ["Coilfang Ambusher"]           = 8,
    ["Coilfang Beast-Tamer"]        = 8,
    ["Coilfang Fathom-Witch"]       = 8,
    ["Coilfang Hate-Screamer"]      = 8,
    ["Coilfang Priestess"]          = 8,
    ["Fathom-Guard Caribdis"]       = 8,
    ["Fathom-Guard Sharkkis"]       = 8,
    ["Fathom-Guard Tidalvess"]      = 8,
    ["Greyheart Nether-Mage"]       = 8,
    ["Greyheart Spellbinder"]       = 8,
    ["Greyheart Technician"]        = 8,
    ["Greyheart Tidecaller"]        = 8,
    ["Serpentshrine Tidecaller"]    = 8,
    ["Tainted Elemental"]           = 8,
    ["Tainted Water Elemental"]     = 8,
    ["Tidewalker Depth-Seer"]       = 8,
    ["Tidewalker Hydromancer"]      = 8,
    ["Tidewalker Shaman"]           = 8,
    ["Coilfang Frenzy"]             = 5,
    ["Coilfang Strider"]            = 5,
    ["Fathom Sporebat"]             = 5,
    ["Serpentshrine Sporebat"]      = 5,
}

db["The Eye"] = {
    ["Astromancer"]                 = 8,
    ["Astromancer Lord"]            = 8,
    ["Bloodwarder Vindicator"]      = 8,
    ["Cosmic Infuser"]              = 8,
    ["Crimson Hand Battle Mage"]    = 8,
    ["Crimson Hand Blood Knight"]   = 8,
    ["Crimson Hand Inquisitor"]     = 8,
    ["Crystalcore Mechanic"]        = 8,
    ["Grand Astromancer Capernian"] = 8,
    ["Infinity Blade"]              = 8,   -- Kael weapon phase add
    ["Master Engineer Telonicus"]   = 8,
    ["Nether Scryer"]               = 8,
    ["Netherstrand Longbow"]        = 8,   -- Kael weapon phase add
    ["Novice Astromancer"]          = 8,
    ["Phaseshift Bulwark"]          = 8,
    ["Phoenix Egg"]                 = 8,   -- must die promptly during Kael/Al'ar style phoenix cycles
    ["Solarium Priest"]             = 8,
    ["Staff of Disintegration"]     = 8,   -- Kael weapon phase add
    ["Star Scryer"]                 = 8,
    ["Tempest Falconer"]            = 8,
    ["Tempest-Smith"]               = 8,
    ["Thaladred the Darkener"]      = 8,
    ["Warp Slicer"]                 = 8,   -- Kael weapon phase add
    ["Phoenix-Hawk"]                = 5,
    ["Phoenix-Hawk Hatchling"]      = 5,
}

db["Hyjal Summit"] = {
    ["Banshee"]                     = 8,
    ["Frost Wyrm"]                  = 8,
    ["Giant Infernal"]              = 8,
    ["Lesser Doomguard"]            = 8,
    ["Necromancer"]                 = 8,
}

db["Black Temple"] = {
    ["Ashtongue Elementalist"]      = 8,
    ["Ashtongue Mystic"]            = 8,
    ["Ashtongue Primalist"]         = 8,
    ["Ashtongue Sorcerer"]          = 8,
    ["Ashtongue Spiritbinder"]      = 8,
    ["Ashtongue Stormcaller"]       = 8,
    ["Bonechewer Blood Prophet"]    = 8,
    ["Bonechewer Taskmaster"]       = 8,
    ["Coilskar Sea-Caller"]         = 8,
    ["Coilskar Soothsayer"]         = 8,
    ["Dragonmaw Wyrmcaller"]        = 8,
    ["Flame of Azzinoth"]           = 8,   -- Illidan phase add that should keep a strong control/kill mark
    ["Hand of Gorefiend"]           = 8,
    ["Illidari Archon"]             = 8,
    ["Illidari Assassin"]           = 8,
    ["Illidari Battle-mage"]        = 8,
    ["Illidari Blood Lord"]         = 8,
    ["Illidari Fearbringer"]        = 8,
    ["Illidari Nightlord"]          = 8,
    ["Shadowmoon Blood Mage"]       = 8,
    ["Shadowmoon Deathshaper"]      = 8,
    ["Shadowmoon Houndmaster"]      = 8,
    ["Temple Acolyte"]              = 8,
    ["Aqueous Spawn"]               = 5,
    ["Aqueous Surger"]              = 5,
    ["Leviathan"]                   = 5,
    ["Mutant War Hound"]            = 5,
    ["Shadowmoon Riding Hound"]     = 5,
    ["Storm Fury"]                  = 5,
}

db["Zul'Aman"] = {
    ["Amani Healing Ward"]          = 8,
    ["Amani Protective Ward"]       = 8,
    ["Amani'shi Beast Tamer"]       = 8,
    ["Amani'shi Flame Caster"]      = 8,
    ["Amani'shi Handler"]           = 8,
    ["Amani'shi Hatcher"]           = 8,
    ["Amani'shi Medicine Man"]      = 8,
    ["Amani'shi Scout"]             = 8,
    ["Amani'shi Tempest"]           = 8,
    ["Amani'shi Warbringer"]        = 8,
    ["Amani'shi Wind Walker"]       = 8,
    ["Darkheart"]                   = 8,
    ["Gazakroth"]                   = 8,
    ["Koragg"]                      = 8,
    ["Lord Raadan"]                 = 8,
    ["Amani Bear"]                  = 5,
    ["Amani Bear Mount"]            = 5,
    ["Amani Dragonhawk"]            = 5,
    ["Amani Elder Lynx"]            = 5,
    ["Amani Lynx"]                  = 5,
    ["Slither"]                     = 5,
    ["Soaring Eagle"]               = 5,
    ["Forest Frog"]                 = "SKIP",
}

db["Sunwell Plateau"] = {
    ["Apocalypse Guard"]            = 8,
    ["Chaos Gazer"]                 = 8,
    ["Doomfire Destroyer"]          = 8,
    ["Hand of the Deceiver"]        = 8,
    ["Oblivion Mage"]               = 8,
    ["Painbringer"]                 = 8,
    ["Priestess of Torment"]        = 8,
    ["Shield Orb"]                  = 8,
    ["Shadowsword Assassin"]        = 8,
    ["Shadowsword Deathbringer"]    = 8,
    ["Shadowsword Fury Mage"]       = 8,
    ["Shadowsword Lifeshaper"]      = 8,
    ["Shadowsword Manafiend"]       = 8,
    ["Shadowsword Soulbinder"]      = 8,
    ["Sinister Reflection"]         = 8,
    ["Sunblade Arch Mage"]          = 8,
    ["Sunblade Cabalist"]           = 8,
    ["Sunblade Dawn Priest"]        = 8,
    ["Sunblade Dusk Priest"]        = 8,
    ["Sunblade Scout"]              = 8,
    ["Sunblade Vindicator"]         = 8,
    ["Void Sentinel"]               = 8,
    ["Cataclysm Hound"]             = 5,
    ["Sunblade Dragonhawk"]         = 5,
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
