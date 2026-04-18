-- AutoMarkAssist_DB_Cata.lua
-- Cataclysm dungeon and raid entries.
-- Loaded AFTER AutoMarkAssist_DB_WotLK.lua; merges 18 Cata zones.

local db      = AutoMarkAssist_MobDB
local aliases = AutoMarkAssist_ZoneAliases
local order   = AutoMarkAssist_ExpansionOrder

-- ============================================================
-- CATACLYSM DUNGEONS
-- ============================================================

db["Blackrock Caverns"] = {
    ["Twilight Flame Caller"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
    ["Twilight Torturer"]           = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Sadist"]             = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Obsidian Borer"]     = { mark = 5, creatureType = "Beast" },
    ["Twilight Element Warden"]     = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Twilight Loyalist"]           = { mark = 5, creatureType = "Humanoid" },
    ["Mad Prisoner"]                = { mark = 5, creatureType = "Humanoid" },
    ["Crazed Mage"]                 = { mark = 8, creatureType = "Humanoid" },
    ["Conflagration"]               = { mark = 5, creatureType = "Elemental" },
    ["Incendiary Spark"]            = "SKIP",
    ["Conflagrous Fume"]            = "SKIP",
}

db["Throne of the Tides"] = {
    ["Naz'jar Tempest Witch"]       = { mark = 8, creatureType = "Humanoid" },
    ["Naz'jar Spiritmender"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Naz'jar Honor Guard"]         = { mark = 5, creatureType = "Humanoid" },
    ["Naz'jar Invader"]             = { mark = 5, creatureType = "Humanoid" },
    ["Naz'jar Myrmidon"]            = { mark = 5, creatureType = "Humanoid" },
    ["Naz'jar Sentinel"]            = { mark = 5, creatureType = "Humanoid" },
    ["Faceless Watcher"]            = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Gilgoblin Aquamage"]          = { mark = 8, creatureType = "Humanoid" },
    ["Gilgoblin Hunter"]            = { mark = 5, creatureType = "Humanoid" },
    ["Unyielding Behemoth"]         = { mark = 8, creatureType = "Elemental" },
    ["Vicious Mindlasher"]          = { mark = 8, creatureType = "Aberration" },
    ["Deep Attendant"]              = { mark = 5, creatureType = "Beast" },
    ["Deep Murloc Drudge"]          = "SKIP",
}

db["The Stonecore"] = {
    ["Stonecore Earthshaper"]       = { mark = 8, creatureType = "Humanoid" },
    ["Stonecore Magmalord"]         = { mark = 8, creatureType = "Humanoid" },
    ["Stonecore Rift Conjurer"]     = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Stonecore Flayer"]            = { mark = 5, creatureType = "Humanoid" },
    ["Stonecore Berserker"]         = { mark = 5, creatureType = "Humanoid" },
    ["Stonecore Warbringer"]        = { mark = 5, creatureType = "Humanoid" },
    ["Stonecore Bruiser"]           = { mark = 5, creatureType = "Humanoid" },
    ["Millhouse Manastorm"]         = { mark = 8, creatureType = "Humanoid" },
    ["Crystalspawn Giant"]          = { mark = 5, creatureType = "Elemental" },
    ["Twilight Excavator"]          = { mark = 5, creatureType = "Humanoid" },
    ["Twilight Hammerer"]           = { mark = 5, creatureType = "Humanoid" },
    ["Twilight Inciter"]            = { mark = 8, creatureType = "Humanoid" },
    ["Impaling Shards"]             = "SKIP",
    ["Shadowy Tendril"]             = { mark = 5, creatureType = "Elemental" },
    ["IMP"]                         = "SKIP",
}

db["The Vortex Pinnacle"] = {
    ["Lurking Tempest"]             = { mark = 8, creatureType = "Elemental" },
    ["Minister of Air"]             = { mark = 8, creatureType = "Elemental" },
    ["Temple Adept"]                = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Turbulent Squall"]            = { mark = 8, creatureType = "Elemental" },
    ["Empyrean Assassin"]           = { mark = 8, creatureType = "Humanoid" },
    ["Skyfall Star"]                = { mark = 5, creatureType = "Elemental" },
    ["Wild Vortex"]                 = { mark = 4, creatureType = "Elemental" },
    ["Young Storm Dragon"]          = { mark = 5, creatureType = "Dragonkin" },
    ["Grounding Field"]             = "SKIP",
    ["Howling Gale"]                = "SKIP",
    ["Executor of the Caliph"]      = { mark = 8, creatureType = "Elemental" },
    ["Servant of Asaad"]            = { mark = 5, creatureType = "Elemental" },
}

db["Lost City of the Tol'vir"] = {
    ["Neferset Darkcaster"]         = { mark = 8, creatureType = "Humanoid" },
    ["Neferset Plaguebringer"]      = { mark = 8, creatureType = "Humanoid" },
    ["Neferset Theurgist"]          = { mark = 8, creatureType = "Humanoid" },
    ["Neferset Overseer"]           = { mark = 5, creatureType = "Humanoid" },
    ["Neferset Footsoldier"]        = { mark = 5, creatureType = "Humanoid" },
    ["Neferset Guardian"]           = { mark = 5, creatureType = "Humanoid" },
    ["Oathsworn Pathfinder"]        = { mark = 8, creatureType = "Humanoid" },
    ["Oathsworn Skinner"]           = { mark = 5, creatureType = "Humanoid" },
    ["Oathsworn Axe Master"]        = { mark = 5, creatureType = "Humanoid" },
    ["Oathsworn Wavecaller"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Oathsworn Captain"]           = { mark = 8, creatureType = "Humanoid" },
    ["Oathsworn Myrmidon"]          = { mark = 5, creatureType = "Humanoid" },
    ["Oathsworn Rifleman"]          = { mark = 8, creatureType = "Humanoid" },
    ["Pygmy Scout"]                 = "SKIP",
    ["Venomblood Scorpid"]          = { mark = 5, creatureType = "Beast" },
}

db["Halls of Origination"] = {
    ["Temple Runecaster"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
    ["Temple Shadowlancer"]         = { mark = 8, creatureType = "Humanoid" },
    ["Temple Fireshaper"]           = { mark = 8, creatureType = "Humanoid" },
    ["Temple Swiftstalker"]         = { mark = 8, creatureType = "Humanoid" },
    ["Jeweled Scarab"]              = "SKIP",
    ["Jeweled Camel"]               = "SKIP",
    ["Sun-Touched Scarab"]          = { mark = 5, creatureType = "Beast" },
    ["Sun-Touched Scout"]           = { mark = 5, creatureType = "Humanoid" },
    ["Sun-Touched Rockshaper"]      = { mark = 8, creatureType = "Humanoid" },
    ["Sun-Touched Servant"]         = { mark = 5, creatureType = "Humanoid" },
    ["Sun-Touched Sandguard"]       = { mark = 5, creatureType = "Humanoid" },
    ["Sun-Touched Sandstalker"]     = { mark = 5, creatureType = "Humanoid" },
    ["Sun-Touched Sandweaver"]      = { mark = 8, creatureType = "Humanoid" },
    ["Sun-Touched Speaker"]         = { mark = 8, creatureType = "Humanoid" },
    ["Sun-Touched Warden"]          = { mark = 5, creatureType = "Humanoid" },
    ["Air Warden"]                  = { mark = 4, creatureType = "Elemental" },
    ["Flame Warden"]                = { mark = 4, creatureType = "Elemental" },
    ["Water Warden"]                = { mark = 8, creatureType = "Elemental", dangerLevel = 3 },
    ["Earth Warden"]                = { mark = 5, creatureType = "Elemental" },
}

db["Grim Batol"] = {
    ["Twilight Beguiler"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
    ["Twilight Earthcaller"]        = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Firecatcher"]        = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Shadow Weaver"]      = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Stormbreaker"]       = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Thundercaller"]      = { mark = 8, creatureType = "Humanoid" },
    ["Twilight War-Mage"]           = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Wyrmcaller"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Twilight Dragonspawn"]        = { mark = 5, creatureType = "Dragonkin" },
    ["Twilight Drakonaar"]          = { mark = 5, creatureType = "Dragonkin" },
    ["Azureborne Seer"]             = { mark = 8, creatureType = "Humanoid" },
    ["Azureborne Destroyer"]        = { mark = 5, creatureType = "Dragonkin" },
    ["Valiona's Aspect"]            = { mark = 8, creatureType = "Dragonkin" },
    ["Ghastly Miner"]               = { mark = 5, creatureType = "Undead" },
}

db["Zul'Aman"] = {
    ["Amani'shi Flame Caster"]      = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Medicine Man"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Amani'shi Scout"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Amani'shi Beast Tamer"]       = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Guardian"]          = { mark = 5, creatureType = "Humanoid" },
    ["Amani'shi Warbringer"]        = { mark = 5, creatureType = "Humanoid" },
    ["Amani'shi Savage"]            = { mark = 5, creatureType = "Humanoid" },
    ["Amani'shi Reinforcement"]     = { mark = 5, creatureType = "Humanoid" },
    ["Amani'shi Tempest"]           = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Wind Walker"]       = { mark = 5, creatureType = "Humanoid" },
    ["Amani Lynx"]                  = { mark = 5, creatureType = "Beast" },
    ["Amani Bear"]                  = { mark = 5, creatureType = "Beast" },
    ["Amani Dragonhawk"]            = { mark = 5, creatureType = "Beast" },
    ["Amani Eagle"]                 = { mark = 5, creatureType = "Beast" },
    ["Hatching Egg"]                = "SKIP",
    ["Forest Frog"]                 = "SKIP",
}

db["Zul'Gurub"] = {
    ["Gurubashi Shadow Hunter"]     = { mark = 8, creatureType = "Humanoid" },
    ["Gurubashi Blood Drinker"]     = { mark = 8, creatureType = "Humanoid" },
    ["Gurubashi Cauldron Mixer"]    = { mark = 8, creatureType = "Humanoid" },
    ["Gurubashi Berserker"]         = { mark = 5, creatureType = "Humanoid" },
    ["Gurubashi Headhunter"]        = { mark = 5, creatureType = "Humanoid" },
    ["Gurubashi Warrior"]           = { mark = 5, creatureType = "Humanoid" },
    ["Gurubashi Master Chef"]       = { mark = 8, creatureType = "Humanoid" },
    ["Tiki Lord Zim'wae"]           = { mark = 8, creatureType = "Humanoid" },
    ["Florawing Hive Queen"]        = { mark = 8, creatureType = "Beast" },
    ["Florawing Needler"]           = "SKIP",
    ["Venomancer T'Kulu"]           = { mark = 8, creatureType = "Humanoid" },
    ["Zanzili Witch Doctor"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Zanzili Zombie"]              = "SKIP",
    ["Zanzili Naga"]                = { mark = 5, creatureType = "Humanoid" },
    ["Zanzili Berserker"]           = { mark = 5, creatureType = "Humanoid" },
}

db["End Time"] = {
    ["Time-Twisted Geist"]          = { mark = 5, creatureType = "Undead" },
    ["Time-Twisted Nightsaber"]     = { mark = 5, creatureType = "Beast" },
    ["Time-Twisted Priest"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Time-Twisted Rifleman"]       = { mark = 8, creatureType = "Humanoid" },
    ["Time-Twisted Seer"]           = { mark = 8, creatureType = "Humanoid" },
    ["Time-Twisted Sorceress"]      = { mark = 8, creatureType = "Humanoid" },
    ["Time-Twisted Druid"]          = { mark = 8, creatureType = "Humanoid" },
    ["Time-Twisted Ranger"]         = { mark = 8, creatureType = "Humanoid" },
    ["Echo of Tyrande"]             = { mark = 8, creatureType = "Humanoid" },
    ["Echo of Sylvanas"]            = { mark = 8, creatureType = "Undead" },
    ["Echo of Baine"]               = { mark = 8, creatureType = "Humanoid" },
    ["Echo of Jaina"]               = { mark = 8, creatureType = "Humanoid" },
}

db["Well of Eternity"] = {
    ["Dreadlord Defender"]          = { mark = 8, creatureType = "Demon", dangerLevel = 2 },
    ["Enchanted Highmistress"]      = { mark = 8, creatureType = "Humanoid" },
    ["Highborne Lightwielder"]      = { mark = 8, creatureType = "Humanoid" },
    ["Highborne Elementalist"]      = { mark = 8, creatureType = "Humanoid" },
    ["Highborne Guardsman"]         = { mark = 5, creatureType = "Humanoid" },
    ["Eye of the Legion"]           = { mark = 8, creatureType = "Demon" },
    ["Fel Crystal"]                 = "SKIP",
    ["Legion Demon"]                = { mark = 4, creatureType = "Demon" },
    ["Doomguard Commander"]         = { mark = 4, creatureType = "Demon" },
    ["Wrathguard Legionnaire"]      = { mark = 4, creatureType = "Demon" },
    ["Abyssal"]                     = { mark = 4, creatureType = "Demon" },
    ["Shadowbat"]                   = { mark = 5, creatureType = "Beast" },
    ["Corrupted Arcanist"]          = { mark = 8, creatureType = "Humanoid" },
    ["Var'azun"]                    = { mark = 8, creatureType = "Humanoid" },
}

db["Hour of Twilight"] = {
    ["Twilight Assassin"]           = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Ranger"]             = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Pounder"]            = { mark = 5, creatureType = "Humanoid" },
    ["Twilight Elite Commander"]    = { mark = 5, creatureType = "Humanoid" },
    ["Faceless Shadow Weaver"]      = { mark = 8, creatureType = "Aberration" },
    ["Crystalline Elemental"]       = { mark = 4, creatureType = "Elemental" },
    ["Lesser Aspect of Ruin"]       = { mark = 8, creatureType = "Elemental" },
    ["Burning Tendril"]             = { mark = 5, creatureType = "Elemental" },
}

-- ============================================================
-- CATACLYSM RAIDS
-- ============================================================

db["Blackwing Descent"] = {
    ["Arcanotron"]                  = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Electron"]                    = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Magmatron"]                   = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Toxitron"]                    = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Aberration"]                  = { mark = 8, creatureType = "Undead" },
    ["Prime Subject"]               = { mark = 8, creatureType = "Undead" },
    ["Lava Parasite"]               = { mark = 8, creatureType = "Beast" },
    ["Blazing Bone Construct"]      = { mark = 8, creatureType = "Undead" },
    ["Drakonid Chainwielder"]       = { mark = 8, creatureType = "Dragonkin" },
    ["Drakonid Drake-Rider"]        = { mark = 8, creatureType = "Dragonkin" },
    ["Chromatic Drakonid"]          = { mark = 5, creatureType = "Dragonkin" },
    ["Chromatic Sculptor"]          = { mark = 8, creatureType = "Humanoid" },
    ["Chromatic Enforcer"]          = { mark = 5, creatureType = "Humanoid" },
    ["Experimental Chromatic Behemoth"] = { mark = 8, creatureType = "Dragonkin" },
    ["Blackwing Mage"]              = { mark = 8, creatureType = "Humanoid" },
}

db["The Bastion of Twilight"] = {
    ["Chosen Seer"]                 = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Dark Mender"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Twilight Shadow Mender"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Twilight Elementalist"]       = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Soul Blade"]         = { mark = 8, creatureType = "Humanoid" },
    ["Chosen Warrior"]              = { mark = 5, creatureType = "Humanoid" },
    ["Chosen Assassin"]             = { mark = 5, creatureType = "Humanoid" },
    ["Faceless Guardian"]           = { mark = 8, creatureType = "Aberration" },
    ["Corrupting Adherent"]         = { mark = 8, creatureType = "Humanoid" },
    ["Darkened Creation"]           = { mark = 8, creatureType = "Aberration" },
    ["Blood of the Old God"]        = { mark = 8, creatureType = "Aberration" },
    ["Spiked Tentacle"]             = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Elementium Monstrosity"]      = { mark = 8, creatureType = "Elemental" },
    ["Twilight Drake"]              = { mark = 8, creatureType = "Dragonkin" },
    ["Twilight Archers"]            = { mark = 5, creatureType = "Humanoid" },
}

db["Throne of the Four Winds"] = {
    ["Ravenous Creeper"]            = { mark = 8, creatureType = "Beast" },
    ["Stormling"]                   = { mark = 8, creatureType = "Elemental" },
    ["Squall Line"]                 = "SKIP",
}

db["Baradin Hold"] = {
    ["Disciple of Hate"]            = { mark = 8, creatureType = "Demon" },
    ["Eye of Occu'thar"]            = { mark = 8, creatureType = "Demon", ccImmune = true },
}

db["Firelands"] = {
    ["Flamewaker Cauterizer"]       = { mark = 8, creatureType = "Elemental", dangerLevel = 3 },
    ["Flamewaker Subjugator"]       = { mark = 8, creatureType = "Elemental" },
    ["Flamewaker Pathfinder"]       = { mark = 8, creatureType = "Elemental" },
    ["Flamewaker Beast Handler"]    = { mark = 8, creatureType = "Elemental" },
    ["Flamewaker Hound Master"]     = { mark = 8, creatureType = "Elemental" },
    ["Flamewaker Animator"]         = { mark = 8, creatureType = "Elemental" },
    ["Flamewaker Elite"]            = { mark = 5, creatureType = "Elemental" },
    ["Unbound Pyrelord"]            = { mark = 8, creatureType = "Elemental" },
    ["Unbound Smoldering Elemental"] = { mark = 4, creatureType = "Elemental" },
    ["Molten Lord"]                 = { mark = 8, creatureType = "Elemental" },
    ["Molten Behemoth"]             = { mark = 8, creatureType = "Elemental" },
    ["Ancient Core Hound"]          = { mark = 5, creatureType = "Beast" },
    ["Cinderweb Spinner"]           = { mark = 8, creatureType = "Beast" },
    ["Cinderweb Creeper"]           = { mark = 5, creatureType = "Beast" },
    ["Cinderweb Spiderling"]        = "SKIP",
    ["Blazing Talon Initiate"]      = { mark = 8, creatureType = "Humanoid" },
    ["Blazing Talon Clawshaper"]    = { mark = 8, creatureType = "Humanoid" },
    ["Blazing Monstrosity"]         = { mark = 8, creatureType = "Elemental" },
    ["Voracious Hatchling"]         = { mark = 8, creatureType = "Dragonkin" },
    ["Harbinger of Flame"]          = { mark = 8, creatureType = "Elemental" },
    ["Druid of the Flame"]          = { mark = 8, creatureType = "Humanoid" },
    ["Rageface"]                    = { mark = 8, creatureType = "Beast" },
    ["Riplimb"]                     = { mark = 8, creatureType = "Beast" },
}

db["Dragon Soul"] = {
    ["Twilight Elite Dreadblade"]   = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Elite Slayer"]       = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Frost Evoker"]       = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Shadow Gazer"]       = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Earth Bender"]       = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Siege Captain"]      = { mark = 8, creatureType = "Humanoid" },
    ["Twilight Sapper"]             = { mark = 8, creatureType = "Humanoid" },
    ["Harbinger of Twilight"]       = { mark = 8, creatureType = "Elemental" },
    ["Harbinger of Destruction"]    = { mark = 8, creatureType = "Elemental" },
    ["Faceless Corruptor"]          = { mark = 8, creatureType = "Aberration" },
    ["Ancient Water Lord"]          = { mark = 8, creatureType = "Elemental" },
    ["Stormbinder Adept"]           = { mark = 8, creatureType = "Humanoid" },
    ["Elementium Bolt"]             = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Elementium Terror"]           = { mark = 8, creatureType = "Elemental" },
    ["Mutated Corruption"]          = { mark = 8, creatureType = "Aberration" },
    ["Wing Tentacle"]               = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Claw of Go'rath"]             = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Eye of Go'rath"]              = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Flail of Go'rath"]            = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Blistering Tentacle"]         = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Hideous Amalgamation"]        = { mark = 8, creatureType = "Aberration" },
    ["Burning Tendons"]             = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Congealing Blood"]            = { mark = 8, creatureType = "Aberration" },
    ["Corrupted Parasite"]          = "SKIP",
}

-- ============================================================
-- ZONE ALIASES  (merged into the shared table)
-- ============================================================

local newAliases = {
    ["Blackrock Caverns"]               = "Blackrock Caverns",
    ["Throne of the Tides"]             = "Throne of the Tides",
    ["The Stonecore"]                   = "The Stonecore",
    ["Stonecore"]                       = "The Stonecore",
    ["The Vortex Pinnacle"]             = "The Vortex Pinnacle",
    ["Vortex Pinnacle"]                 = "The Vortex Pinnacle",
    ["Lost City of the Tol'vir"]        = "Lost City of the Tol'vir",
    ["Halls of Origination"]            = "Halls of Origination",
    ["Grim Batol"]                      = "Grim Batol",
    ["Zul'Aman"]                        = "Zul'Aman",
    ["Zul'Gurub"]                       = "Zul'Gurub",
    ["End Time"]                        = "End Time",
    ["Well of Eternity"]                = "Well of Eternity",
    ["Hour of Twilight"]                = "Hour of Twilight",
    ["Blackwing Descent"]               = "Blackwing Descent",
    ["BWD"]                             = "Blackwing Descent",
    ["The Bastion of Twilight"]         = "The Bastion of Twilight",
    ["Bastion of Twilight"]             = "The Bastion of Twilight",
    ["BoT"]                             = "The Bastion of Twilight",
    ["BOT"]                             = "The Bastion of Twilight",
    ["Throne of the Four Winds"]        = "Throne of the Four Winds",
    ["TotFW"]                           = "Throne of the Four Winds",
    ["TOTFW"]                           = "Throne of the Four Winds",
    ["Baradin Hold"]                    = "Baradin Hold",
    ["BH"]                              = "Baradin Hold",
    ["Firelands"]                       = "Firelands",
    ["FL"]                              = "Firelands",
    ["Dragon Soul"]                     = "Dragon Soul",
    ["DS"]                              = "Dragon Soul",
}
for k, v in pairs(newAliases) do aliases[k] = v end

-- ============================================================
-- EXPANSION ORDER  (appended to the shared table)
-- ============================================================

table.insert(order, { name = "Cataclysm", dungeons = {
    "Blackrock Caverns", "Throne of the Tides", "The Stonecore",
    "The Vortex Pinnacle", "Lost City of the Tol'vir", "Halls of Origination",
    "Grim Batol", "Zul'Aman", "Zul'Gurub",
    "End Time", "Well of Eternity", "Hour of Twilight",
}, raids = {
    "Blackwing Descent", "The Bastion of Twilight", "Throne of the Four Winds",
    "Baradin Hold", "Firelands", "Dragon Soul",
}})
