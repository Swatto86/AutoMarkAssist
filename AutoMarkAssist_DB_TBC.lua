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
    ["Hellfire Channeler"]          = "HIGH",   -- channels empowerment on bosses
    ["Bonechewer Beastmaster"]      = "HIGH",   -- has a pet; pet dies when master dies
    ["Bonechewer Blood Drinker"]    = "HIGH",   -- life-drain caster
    ["Bonechewer Ravener"]          = "MEDIUM",
    ["Bonechewer Ripper"]           = "MEDIUM",
    ["Bonechewer Destroyer"]        = "MEDIUM",
    ["Hellfire Sentry"]             = "MEDIUM",
    ["Hellfire Watcher"]            = "CC",     -- ranged, can be crowd-controlled
    ["Hellfire Watchtower"]         = "CC",
    ["Bonechewer Combatant"]        = "LOW",
    ["Bonechewer Hungerer"]         = "SKIP",   -- Beastmaster pet filler
}

db["The Blood Furnace"] = {
    ["Bleeding Hollow Scryer"]      = "HIGH",   -- healer/caster
    ["Laughing Skull Warden"]       = "HIGH",   -- healer
    ["Laughing Skull Rogue"]        = "HIGH",   -- stealths, opens with heavy burst
    ["Laughing Skull Enforcer"]     = "MEDIUM",
    ["Fel Orc Convert"]             = "CC",
    ["Nascent Fel Orc"]             = "MEDIUM",
    ["Bleeding Hollow Torturer"]    = "HIGH",   -- interruption-worthy pain spells
    ["Bleeding Hollow Skulker"]     = "HIGH",   -- stealth + ambush
    ["Fel Orc Neophyte"]            = "SKIP",   -- cage event filler
}

db["The Shattered Halls"] = {
    ["Shattered Hand Zealot"]       = "HIGH",   -- executes low-HP players (Gloat)
    ["Shattered Hand Assassin"]     = "HIGH",   -- stealths, Garrote + burst
    ["Shattered Hand Heathen"]      = "HIGH",   -- Blood Surge heal on self
    ["Shattered Hand Legionnaire"]  = "MEDIUM",
    ["Shattered Hand Centurion"]    = "MEDIUM",
    ["Shattered Hand Champion"]     = "MEDIUM",
    ["Shattered Hand Reaver"]       = "CC",
    ["Shattered Hand Savage"]       = "CC",     -- beast, trappable
    ["Shattered Hand Gladiator"]    = "MEDIUM",
    ["Shattered Hand Berserker"]    = "HIGH",   -- Enrage + whirlwind
    ["Shattered Hand Brawler"]      = "LOW",
    ["Shattered Hand Warhound"]     = "SKIP",   -- handler dog pack filler
}

-- --- Coilfang Reservoir ---------------------------------

db["The Slave Pens"] = {
    ["Coilfang Collaborator"]       = "HIGH",   -- healer, top priority
    ["Coilfang Observer"]           = "HIGH",   -- caster, Chain Lightning
    ["Coilfang Shatterer"]          = "MEDIUM",
    ["Coilfang Defender"]           = "MEDIUM",
    ["Coilfang Slavehandler"]       = "HIGH",   -- has enslaved adds
    ["Coilfang Water Elemental"]    = "CC",     -- banishable
    ["Underbat"]                    = "CC",     -- beast, trappable
    ["Bog Giant"]                   = "MEDIUM",
    ["Naga Shaleskin"]              = "LOW",
    ["Wastewalker Slave"]           = "SKIP",   -- Slavehandler pack filler
}

db["The Underbog"] = {
    ["Lykul Bloodseeker"]           = "HIGH",   -- fast-hitting, dangerous burst
    ["Underbog Lurker"]             = "MEDIUM",
    ["Underbog Frenzy"]             = "MEDIUM",
    ["Underbog Colossus"]           = "HIGH",   -- Stomp AoE stun
    ["Underbog Shambler"]           = "CC",     -- undead, shackleable
    ["Bog Overlord"]                = "MEDIUM",
    ["Lykul Wasp"]                  = "CC",     -- beast, trappable
    ["Vinewrap Drifter"]            = "LOW",
    ["Spore Bat"]                   = "CC",
    ["Black Stalker Spawn"]         = "CC",
}

db["The Steamvault"] = {
    ["Coilfang Oracle"]             = "HIGH",   -- healer; must die first
    ["Coilfang Technician"]         = "HIGH",   -- repairs mechanical adds mid-fight
    ["Coilfang Engineer"]           = "HIGH",   -- AoE chain-pull abilities
    ["Coilfang Strider"]            = "MEDIUM",
    ["Coilfang Warrior"]            = "MEDIUM",
    ["Coilfang Myrmidon"]           = "CC",
    ["Naga Shaleskin"]              = "LOW",
    ["Steam Surger"]                = "HIGH",   -- ranged lightning; kill before Thespia
    ["Tidal Surger"]                = "HIGH",   -- kill before Thespia
    ["Hydromancer Thespia"]         = "LOW",    -- BOSS: kill Steam/Tidal Surgers first
    ["Mekgineer Steamrigger"]       = "LOW",    -- BOSS: kill Mechanics first
    ["Steamrigger Mechanic"]        = "HIGH",   -- repairs Mekgineer; must die ASAP
    ["Coilfang Leper"]              = "SKIP",   -- gnome slave filler
}

-- --- Auchindoun ---------------------------------

db["Mana-Tombs"] = {
    ["Ethereal Theurgist"]          = "HIGH",   -- caster, dangerous spells
    ["Ethereal Darkcaster"]         = "HIGH",   -- Shadow Bolt Volley
    ["Ethereal Sorcerer"]           = "HIGH",   -- Mana Burn
    ["Ethereal Spellbinder"]        = "HIGH",   -- binds random party member
    ["Ethereal Crypt Raider"]       = "MEDIUM",
    ["Haunt"]                       = "CC",     -- undead, shackleable
    ["Mana Leech"]                  = "HIGH",   -- drains mana aggressively
    ["Nexus Stalker"]               = "CC",     -- can be trapped
    ["Ethereal Priest"]             = "HIGH",   -- healer
    ["Ethereal Assassin"]           = "HIGH",   -- stealth + burst
    ["Ethereal Summoned Warrior"]   = "SKIP",   -- summoned filler
}

db["Auchenai Crypts"] = {
    ["Auchenai Monk"]               = "HIGH",   -- healer
    ["Auchenai Soulpriest"]         = "HIGH",   -- fear + shadow damage caster
    ["Auchenai Defender"]           = "MEDIUM",
    ["Auchenai Guard"]              = "MEDIUM",
    ["Ghostly Philanthropist"]      = "CC",     -- undead, shackleable
    ["Worshipper of Eternos"]       = "CC",
    ["Cultist Shard Watcher"]       = "HIGH",   -- spawns shards
    ["Death's Head Cultist"]        = "HIGH",   -- shadow damage caster
    ["Raging Skeleton"]             = "MEDIUM",
    ["Angered Skeleton"]            = "SKIP",   -- mass skeleton filler
}

db["Sethekk Halls"] = {
    ["Arakkoa Diviner"]             = "HIGH",   -- healer + fear caster
    ["Time-Lost Controller"]        = "HIGH",   -- mind controls party members
    ["Time-Lost Scryer"]            = "HIGH",   -- dangerous AoE arcane
    ["Cobalt Serpent"]              = "CC",     -- beast, trappable
    ["Avian Darkhawk"]              = "CC",     -- beast, trappable
    ["Avian Ripper"]                = "MEDIUM",
    ["Avian Warhawk"]               = "HIGH",   -- bleeds + fast attack speed
    ["Hawk Guard"]                  = "MEDIUM",
    ["Sethekk Initiate"]            = "MEDIUM",
    ["Sethekk Oracle"]              = "HIGH",   -- healer
    ["Sethekk Ravenguard"]          = "HIGH",
    ["Avian Flitter"]               = "SKIP",   -- flock filler
    ["Raven Hatchling"]             = "SKIP",   -- hatchling filler
}

db["Shadow Labyrinth"] = {
    ["Cabal Shadow Priest"]         = "HIGH",   -- top priority: Mind Blast, heals self
    ["Cabal Hexer"]                 = "HIGH",   -- polymorph + powerful hexes
    ["Cabal Cultist"]               = "HIGH",   -- dangerous caster
    ["Cabal Soldier"]               = "CC",
    ["Cabal Assassin"]              = "HIGH",   -- stealth + heavy burst
    ["Cabal Rogue"]                 = "HIGH",   -- stealth + cheap shot
    ["Cabal Zealot"]                = "MEDIUM",
    ["Cabal Warlock"]               = "HIGH",   -- DoTs + summons demons
    ["Cabal Deathsworn"]            = "HIGH",   -- execute-range finishers
    ["Fel Overseer"]                = "HIGH",   -- whirlwind + charge
    ["Grandmaster Vorpil"]          = "LOW",    -- BOSS: kill Void Travelers first
    ["Void Traveler"]               = "HIGH",   -- walks to Vorpil; heals him on contact
    ["Shadow Imp"]                  = "SKIP",   -- spawned by Cabal Warlock; filler
}

-- --- Tempest Keep ---------------------------------

db["The Botanica"] = {
    ["Bloodwarder Mender"]          = "HIGH",   -- healer; skull always
    ["Bloodwarder Physician"]       = "HIGH",   -- healer
    ["Sunseeker Chemist"]           = "HIGH",   -- toxic flasks; very high tank damage
    ["Sunseeker Researcher"]        = "HIGH",   -- polymorphs + casts
    ["Sunseeker Botanist"]          = "CC",     -- humanoid, sheepable
    ["Bloodwarder Greenkeeper"]     = "MEDIUM",
    ["Bloodwarder Slayer"]          = "MEDIUM",
    ["Bloodwarder Protector"]       = "CC",
    ["Sunseeker Gene-Splicer"]      = "HIGH",   -- mutates adds mid-fight
    ["Vicious Thornshoots"]         = "CC",     -- plant, incapacitateable
    ["Treant"]                      = "CC",
    ["Sunseeker Bloodhawk"]         = "SKIP",   -- bird flock filler
    ["Bloodpetal Lasher"]           = "SKIP",   -- plant filler
    ["Bloodpetal Flayer"]           = "SKIP",   -- plant filler
    ["Bloodpetal Thorn"]            = "SKIP",   -- plant filler
    ["Mutant Bloodpetal"]           = "SKIP",   -- mutated plant filler
    ["Nether Tendril"]              = "SKIP",   -- tendril filler
}

db["The Arcatraz"] = {
    ["Eredar Deathbringer"]         = "HIGH",   -- shadow damage + AoE silence
    ["Eredar Soul Eater"]           = "HIGH",   -- soul drain on party
    ["Blazing Trickster"]           = "HIGH",   -- AoE fire; interrupt priority
    ["Arcatraz Sentinel"]           = "MEDIUM",
    ["Arcatraz Warden"]             = "MEDIUM",
    ["Entrapped Berserker"]         = "HIGH",   -- Enrage + AoE slam
    ["Neg'Jin Shackler"]            = "HIGH",   -- shackles party members
    ["Arcatraz Warder"]             = "CC",     -- humanoid, sheepable
    ["Protean Horror"]              = "CC",     -- can be feared/banished
    ["Arcatraz Defender"]           = "LOW",
    ["Dalliah's Devotee"]           = "HIGH",
    ["Void Spawner"]                = "SKIP",   -- spawned filler
    ["Soul Fragment"]               = "SKIP",   -- soul fragment filler
}

db["The Mechanar"] = {
    ["Sunseeker Astromage"]         = "HIGH",   -- AoE Arcane Explosion
    ["Sunseeker Netherbinder"]      = "HIGH",   -- healer + silence
    ["Sunseeker Gene-Splicer"]      = "HIGH",   -- dangerous caster
    ["Blood Elf Reclaimer"]         = "HIGH",   -- reclaims constructs mid-fight
    ["Blood Elf Surveyor"]          = "CC",     -- humanoid, sheepable
    ["Nether Wraith"]               = "HIGH",   -- banishable but dangerous if not
    ["Mechanar Wrecker"]            = "MEDIUM",
    ["Mechanar Tinkerer"]           = "HIGH",   -- repairs other mobs
    ["Sunseeker Overseer"]          = "HIGH",   -- buffs nearby mobs
    ["Mechanar Driller"]            = "MEDIUM",
    ["Tempest-Forge Destroyer"]     = "HIGH",   -- AoE shock + stun
    ["Tempest-Forge Patroller"]     = "MEDIUM",
    ["Nether Spark"]                = "SKIP",   -- arcane filler
    ["Arcane Bomb"]                 = "SKIP",   -- bomb filler
}

-- --- Caverns of Time ---------------------------------

db["Old Hillsbrad Foothills"] = {
    ["Syndicate Assassin"]          = "HIGH",   -- stealth + burst on healer
    ["Syndicate Watchman"]          = "HIGH",   -- calls for backup
    ["Syndicate Shadow-Mage"]       = "HIGH",   -- AoE shadow
    ["Hillsbrad Sentry"]            = "MEDIUM",
    ["Hillsbrad Watchman"]          = "CC",     -- humanoid, sheepable
    ["Hillsbrad Farmhand"]          = "LOW",
    ["Lieutenant Drake's Guard"]    = "MEDIUM",
    ["Durnholde Veteran"]           = "HIGH",   -- veteran melee burst
    ["Durnholde Sentry"]            = "MEDIUM",
    ["Durnholde Tracking Hound"]    = "CC",     -- beast, trappable
    ["Durnholde War Horse"]         = "SKIP",   -- riderless mount filler
}

db["The Black Morass"] = {
    ["Rift Keeper"]                 = "HIGH",   -- healer for Rift Lord; kill first
    ["Rift Lord"]                   = "HIGH",   -- extremely dangerous melee
    ["Infinite Assassin"]           = "CC",     -- targets Medivh directly
    ["Infinite Executioner"]        = "CC",     -- executes low-HP units
    ["Infinite Saboteur"]           = "CC",     -- disables defensive cooldowns
    ["Infinite Chrono-Sentinel"]    = "CC",     -- interrupts Medivh's shield
    ["Rift Stalker"]                = "MEDIUM",
    ["Infinite Whelp"]              = "LOW",
    ["Rift Spawner"]                = "SKIP",   -- between-wave filler
}

-- --- Isle of Quel'Danas ---------------------------------

db["Magisters' Terrace"] = {
    ["Sunblade Physician"]          = "HIGH",   -- healer; skull always
    ["Sunblade Blood Knight"]       = "HIGH",   -- holy healer with bubble
    ["Sunblade Arch Mage"]          = "HIGH",   -- AoE arcane + polymorph
    ["Sunblade Magister"]           = "HIGH",   -- pyroblast spam caster
    ["Sunblade Warlock"]            = "HIGH",   -- DoTs + summons felguard
    ["Sunblade Imp Handler"]        = "HIGH",   -- kill to despawn imp packs
    ["Sunblade Mage Guard"]         = "MEDIUM",
    ["Sunblade Imp"]                = "CC",     -- banishable; dangerous in numbers
    ["Felguard Legionnaire"]        = "CC",     -- banishable demon
    ["Sunblade Vindicator"]         = "HIGH",   -- self-heals; must be interrupted
    ["Sunblade Protector"]          = "MEDIUM",
    ["Sunblade Imp Swarm"]          = "SKIP",   -- swarm filler
    ["Mana Tap Imp"]                = "SKIP",   -- mana-drain imp filler
}

-- ============================================================
-- THE BURNING CRUSADE RAIDS
-- ============================================================

db["Karazhan"] = {
    ["Arcane Anomaly"]              = "HIGH",
    ["Astral Flare"]                = "HIGH",
    ["Chaotic Sentience"]           = "HIGH",
    ["Conjured Water Elemental"]    = "HIGH",
    ["Doomguard"]                   = "HIGH",
    ["Ethereal Spellfilcher"]       = "HIGH",
    ["Ethereal Thief"]              = "HIGH",
    ["Ghastly Haunt"]               = "HIGH",
    ["Human Cleric"]                = "HIGH",
    ["Human Conjurer"]              = "HIGH",
    ["Kil'rek"]                     = "HIGH",
    ["Mana Warp"]                   = "HIGH",
    ["Orc Necrolyte"]               = "HIGH",
    ["Orc Warlock"]                 = "HIGH",
    ["Sorcerous Shade"]             = "HIGH",
    ["Spell Shade"]                 = "HIGH",
    ["Spectral Apprentice"]         = "HIGH",
    ["Spectral Servant"]            = "HIGH",
    ["Zealous Consort"]             = "HIGH",
    ["Zealous Paramour"]            = "HIGH",
    ["Coldmist Stalker"]            = "CC",
    ["Coldmist Widow"]              = "CC",
    ["Mana Feeder"]                 = "CC",
    ["Phase Hound"]                 = "CC",
    ["Shadowbat"]                   = "CC",
    ["Vampiric Shadowbat"]          = "CC",
    ["Dreadbeast"]                  = "MEDIUM",
    ["Fleshbeast"]                  = "MEDIUM",
    ["Greater Fleshbeast"]          = "MEDIUM",
    ["Phantom Guardsman"]           = "MEDIUM",
    ["Phantom Stagehand"]           = "MEDIUM",
    ["Phantom Valet"]               = "MEDIUM",
    ["Shadowbeast"]                 = "MEDIUM",
    ["Skeletal Usher"]              = "MEDIUM",
    ["Spectral Charger"]            = "MEDIUM",
    ["Spectral Stable Hand"]        = "MEDIUM",
    ["Spectral Stallion"]           = "MEDIUM",
    ["Trapped Soul"]                = "MEDIUM",
    ["Astral Spark"]                = "LOW",
    ["Fiendish Imp"]                = "LOW",
    ["Dancing Flames"]              = "SKIP",
    ["Rat"]                         = "SKIP",
    ["Spider"]                      = "SKIP",
}

db["Gruul's Lair"] = {
    ["Blindeye the Seer"]           = "HIGH",
    ["Kiggler the Crazed"]          = "HIGH",
    ["Krosh Firehand"]              = "HIGH",
    ["Olm the Summoner"]            = "HIGH",
    ["Gronn-Priest"]                = "HIGH",
    ["Wild Fel Stalker"]            = "CC",
    ["Lair Brute"]                  = "MEDIUM",
    ["High King Maulgar"]           = "LOW",    -- let council-style adds keep the main icons
}

db["Magtheridon's Lair"] = {
    ["Hellfire Channeler"]          = "HIGH",
    ["Burning Abyssal"]             = "CC",
    ["Hellfire Warder"]             = "MEDIUM",
    ["Magtheridon"]                 = "LOW",    -- channelers stay ahead of the boss during the opener
}

db["Serpentshrine Cavern"] = {
    ["Coilfang Ambusher"]           = "HIGH",
    ["Coilfang Beast-Tamer"]        = "HIGH",
    ["Coilfang Fathom-Witch"]       = "HIGH",
    ["Coilfang Hate-Screamer"]      = "HIGH",
    ["Coilfang Priestess"]          = "HIGH",
    ["Fathom-Guard Caribdis"]       = "HIGH",
    ["Fathom-Guard Sharkkis"]       = "HIGH",
    ["Fathom-Guard Tidalvess"]      = "HIGH",
    ["Greyheart Nether-Mage"]       = "HIGH",
    ["Greyheart Spellbinder"]       = "HIGH",
    ["Greyheart Technician"]        = "HIGH",
    ["Greyheart Tidecaller"]        = "HIGH",
    ["Serpentshrine Tidecaller"]    = "HIGH",
    ["Tainted Elemental"]           = "HIGH",
    ["Tainted Water Elemental"]     = "HIGH",
    ["Tidewalker Depth-Seer"]       = "HIGH",
    ["Tidewalker Hydromancer"]      = "HIGH",
    ["Tidewalker Shaman"]           = "HIGH",
    ["Coilfang Frenzy"]             = "CC",
    ["Coilfang Strider"]            = "CC",
    ["Fathom Sporebat"]             = "CC",
    ["Serpentshrine Sporebat"]      = "CC",
    ["Coilfang Elite"]              = "MEDIUM",
    ["Coilfang Guardian"]           = "MEDIUM",
    ["Coilfang Serpentguard"]       = "MEDIUM",
    ["Coilfang Shatterer"]          = "MEDIUM",
    ["Colossus Lurker"]             = "MEDIUM",
    ["Colossus Rager"]              = "MEDIUM",
    ["Fathom Lurker"]               = "MEDIUM",
    ["Pure Spawn of Hydross"]       = "MEDIUM",
    ["Tainted Spawn of Hydross"]    = "MEDIUM",
    ["Tidewalker Harpooner"]        = "MEDIUM",
    ["Tidewalker Lurker"]           = "MEDIUM",
    ["Tidewalker Warrior"]          = "MEDIUM",
    ["Underbog Colossus"]           = "MEDIUM",
    ["Vashj'ir Honor Guard"]        = "MEDIUM",
    ["Fathom-Lord Karathress"]      = "LOW",    -- keep council guards ahead of the boss
    ["Lady Vashj"]                  = "LOW",    -- striders and tainted elementals should retain top marks
    ["Toxic Sporebat"]              = "LOW",    -- nuisance add on Vashj; not a primary CC or kill-order target
}

db["The Eye"] = {
    ["Astromancer"]                 = "HIGH",
    ["Astromancer Lord"]            = "HIGH",
    ["Bloodwarder Vindicator"]      = "HIGH",
    ["Cosmic Infuser"]              = "HIGH",
    ["Crimson Hand Battle Mage"]    = "HIGH",
    ["Crimson Hand Blood Knight"]   = "HIGH",
    ["Crimson Hand Inquisitor"]     = "HIGH",
    ["Crystalcore Mechanic"]        = "HIGH",
    ["Grand Astromancer Capernian"] = "HIGH",
    ["Infinity Blade"]              = "HIGH",   -- Kael weapon phase add
    ["Master Engineer Telonicus"]   = "HIGH",
    ["Nether Scryer"]               = "HIGH",
    ["Netherstrand Longbow"]        = "HIGH",   -- Kael weapon phase add
    ["Novice Astromancer"]          = "HIGH",
    ["Phaseshift Bulwark"]          = "HIGH",
    ["Phoenix Egg"]                 = "HIGH",   -- must die promptly during Kael/Al'ar style phoenix cycles
    ["Solarium Priest"]             = "HIGH",
    ["Staff of Disintegration"]     = "HIGH",   -- Kael weapon phase add
    ["Star Scryer"]                 = "HIGH",
    ["Tempest Falconer"]            = "HIGH",
    ["Tempest-Smith"]               = "HIGH",
    ["Thaladred the Darkener"]      = "HIGH",
    ["Warp Slicer"]                 = "HIGH",   -- Kael weapon phase add
    ["Phoenix-Hawk"]                = "CC",
    ["Phoenix-Hawk Hatchling"]      = "CC",
    ["Bloodwarder Legionnaire"]     = "MEDIUM",
    ["Bloodwarder Marshal"]         = "MEDIUM",
    ["Bloodwarder Squire"]          = "MEDIUM",
    ["Crimson Hand Centurion"]      = "MEDIUM",
    ["Devastation"]                 = "MEDIUM",
    ["Lord Sanguinar"]              = "MEDIUM",
    ["Ember of Al'ar"]              = "LOW",
    ["Kael'thas Sunstrider"]        = "LOW",    -- advisor phase threats should keep icons first
    ["Phoenix"]                     = "LOW",
}

db["Hyjal Summit"] = {
    ["Banshee"]                     = "HIGH",
    ["Frost Wyrm"]                  = "HIGH",
    ["Giant Infernal"]              = "HIGH",
    ["Lesser Doomguard"]            = "HIGH",
    ["Necromancer"]                 = "HIGH",
    ["Abomination"]                 = "MEDIUM",
    ["Crypt Fiend"]                 = "MEDIUM",
    ["Gargoyle"]                    = "MEDIUM",
    ["Ghoul"]                       = "LOW",
}

db["Black Temple"] = {
    ["Ashtongue Elementalist"]      = "HIGH",
    ["Ashtongue Mystic"]            = "HIGH",
    ["Ashtongue Primalist"]         = "HIGH",
    ["Ashtongue Sorcerer"]          = "HIGH",
    ["Ashtongue Spiritbinder"]      = "HIGH",
    ["Ashtongue Stormcaller"]       = "HIGH",
    ["Bonechewer Blood Prophet"]    = "HIGH",
    ["Bonechewer Taskmaster"]       = "HIGH",
    ["Coilskar Sea-Caller"]         = "HIGH",
    ["Coilskar Soothsayer"]         = "HIGH",
    ["Dragonmaw Wyrmcaller"]        = "HIGH",
    ["Flame of Azzinoth"]           = "HIGH",   -- Illidan phase add that should keep a strong control/kill mark
    ["Hand of Gorefiend"]           = "HIGH",
    ["Illidari Archon"]             = "HIGH",
    ["Illidari Assassin"]           = "HIGH",
    ["Illidari Battle-mage"]        = "HIGH",
    ["Illidari Blood Lord"]         = "HIGH",
    ["Illidari Fearbringer"]        = "HIGH",
    ["Illidari Nightlord"]          = "HIGH",
    ["Shadowmoon Blood Mage"]       = "HIGH",
    ["Shadowmoon Deathshaper"]      = "HIGH",
    ["Shadowmoon Houndmaster"]      = "HIGH",
    ["Temple Acolyte"]              = "HIGH",
    ["Aqueous Spawn"]               = "CC",
    ["Aqueous Surger"]              = "CC",
    ["Leviathan"]                   = "CC",
    ["Mutant War Hound"]            = "CC",
    ["Shadowmoon Riding Hound"]     = "CC",
    ["Storm Fury"]                  = "CC",
    ["Ashtongue Battlelord"]        = "MEDIUM",
    ["Ashtongue Channeler"]         = "MEDIUM",
    ["Ashtongue Defender"]          = "MEDIUM",
    ["Ashtongue Rogue"]             = "MEDIUM",
    ["Ashtongue Stalker"]           = "MEDIUM",
    ["Bonechewer Behemoth"]         = "MEDIUM",
    ["Bonechewer Blade Fury"]       = "MEDIUM",
    ["Bonechewer Brawler"]          = "MEDIUM",
    ["Bonechewer Combatant"]        = "MEDIUM",
    ["Bonechewer Shield Disciple"]  = "MEDIUM",
    ["Coilskar General"]            = "MEDIUM",
    ["Coilskar Harpooner"]          = "MEDIUM",
    ["Coilskar Wrangler"]           = "MEDIUM",
    ["Illidari Boneslicer"]         = "MEDIUM",
    ["Illidari Centurion"]          = "MEDIUM",
    ["Illidari Defiler"]            = "MEDIUM",
    ["Illidari Elite"]              = "MEDIUM",
    ["Shadowmoon Champion"]         = "MEDIUM",
    ["Shadowmoon Grunt"]            = "MEDIUM",
    ["Shadowmoon Reaver"]           = "MEDIUM",
    ["Shadowmoon Soldier"]          = "MEDIUM",
    ["Shadowmoon Weapon Master"]    = "MEDIUM",
    ["Shadowy Construct"]           = "MEDIUM",
    ["Wrathbone Flayer"]            = "MEDIUM",
    ["Angered Soul Fragment"]       = "LOW",
    ["Ashtongue Broken"]            = "LOW",
    ["Bonechewer Spectator"]        = "LOW",
    ["Bonechewer Worker"]           = "LOW",
    ["Hungering Soul Fragment"]     = "LOW",
    ["Parasitic Shadowfiend"]       = "LOW",
    ["Suffering Soul Fragment"]     = "LOW",
}

db["Zul'Aman"] = {
    ["Amani Healing Ward"]          = "HIGH",
    ["Amani Protective Ward"]       = "HIGH",
    ["Amani'shi Beast Tamer"]       = "HIGH",
    ["Amani'shi Flame Caster"]      = "HIGH",
    ["Amani'shi Handler"]           = "HIGH",
    ["Amani'shi Hatcher"]           = "HIGH",
    ["Amani'shi Medicine Man"]      = "HIGH",
    ["Amani'shi Scout"]             = "HIGH",
    ["Amani'shi Tempest"]           = "HIGH",
    ["Amani'shi Warbringer"]        = "HIGH",
    ["Amani'shi Wind Walker"]       = "HIGH",
    ["Darkheart"]                   = "HIGH",
    ["Gazakroth"]                   = "HIGH",
    ["Koragg"]                      = "HIGH",
    ["Lord Raadan"]                 = "HIGH",
    ["Amani Bear"]                  = "CC",
    ["Amani Bear Mount"]            = "CC",
    ["Amani Dragonhawk"]            = "CC",
    ["Amani Elder Lynx"]            = "CC",
    ["Amani Lynx"]                  = "CC",
    ["Slither"]                     = "CC",
    ["Soaring Eagle"]               = "CC",
    ["Amani'shi Axe Thrower"]       = "MEDIUM",
    ["Amani'shi Berserker"]         = "MEDIUM",
    ["Amani'shi Guardian"]          = "MEDIUM",
    ["Amani'shi Lookout"]           = "MEDIUM",
    ["Amani'shi Protector"]         = "MEDIUM",
    ["Amani'shi Reinforcement"]     = "MEDIUM",
    ["Amani'shi Trainer"]           = "MEDIUM",
    ["Amani'shi Tribesman"]         = "MEDIUM",
    ["Amani'shi Warrior"]           = "MEDIUM",
    ["Amani Dragonhawk Hatchling"]  = "LOW",
    ["Amani Lynx Cub"]              = "LOW",
    ["Amani'shi Savage"]            = "LOW",
    ["Forest Frog"]                 = "SKIP",
}

db["Sunwell Plateau"] = {
    ["Apocalypse Guard"]            = "HIGH",
    ["Chaos Gazer"]                 = "HIGH",
    ["Doomfire Destroyer"]          = "HIGH",
    ["Hand of the Deceiver"]        = "HIGH",
    ["Oblivion Mage"]               = "HIGH",
    ["Painbringer"]                 = "HIGH",
    ["Priestess of Torment"]        = "HIGH",
    ["Shield Orb"]                  = "HIGH",
    ["Shadowsword Assassin"]        = "HIGH",
    ["Shadowsword Deathbringer"]    = "HIGH",
    ["Shadowsword Fury Mage"]       = "HIGH",
    ["Shadowsword Lifeshaper"]      = "HIGH",
    ["Shadowsword Manafiend"]       = "HIGH",
    ["Shadowsword Soulbinder"]      = "HIGH",
    ["Sinister Reflection"]         = "HIGH",
    ["Sunblade Arch Mage"]          = "HIGH",
    ["Sunblade Cabalist"]           = "HIGH",
    ["Sunblade Dawn Priest"]        = "HIGH",
    ["Sunblade Dusk Priest"]        = "HIGH",
    ["Sunblade Scout"]              = "HIGH",
    ["Sunblade Vindicator"]         = "HIGH",
    ["Void Sentinel"]               = "HIGH",
    ["Cataclysm Hound"]             = "CC",
    ["Sunblade Dragonhawk"]         = "CC",
    ["Doomfire Shard"]              = "MEDIUM",
    ["Shadowsword Berserker"]       = "MEDIUM",
    ["Shadowsword Commander"]       = "MEDIUM",
    ["Shadowsword Vanquisher"]      = "MEDIUM",
    ["Sunblade Slayer"]             = "MEDIUM",
    ["Unyielding Dead"]             = "MEDIUM",
    ["Volatile Felfire Fiend"]      = "MEDIUM",
    ["Volatile Fiend"]              = "MEDIUM",
    ["Dark Fiend"]                  = "LOW",
    ["Fire Fiend"]                  = "LOW",
    ["Void Spawn"]                  = "LOW",
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

table.insert(order, { name = "The Burning Crusade", zones = {
    "Hellfire Ramparts", "The Blood Furnace", "The Shattered Halls",
    "The Slave Pens", "The Underbog", "The Steamvault",
    "Mana-Tombs", "Auchenai Crypts", "Sethekk Halls", "Shadow Labyrinth",
    "The Mechanar", "The Botanica", "The Arcatraz",
    "Old Hillsbrad Foothills", "The Black Morass", "Magisters' Terrace",
    "Karazhan", "Gruul's Lair", "Magtheridon's Lair",
    "Serpentshrine Cavern", "The Eye", "Hyjal Summit", "Black Temple",
    "Zul'Aman", "Sunwell Plateau",
}})
