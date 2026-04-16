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
    ["Twilight Flame Caller"]       = { mark = 8, dangerLevel = 2 },  -- fire caster; interrupt
    ["Twilight Torturer"]           = 8,   -- shadow damage + chains
    ["Twilight Sadist"]             = 8,   -- damage caster
    ["Mad Prisoner"]                = 5,     -- humanoid, CC-able
    ["Twilight Element Warden"]     = 8,   -- summons elementals
    ["Incendiary Spark"]            = "SKIP",   -- spark filler
}

db["Throne of the Tides"] = {
    ["Naz'jar Tempest Witch"]       = 8,   -- frost + lightning caster
    ["Naz'jar Spiritmender"]        = { mark = 8, dangerLevel = 3 },  -- healer
    ["Faceless Watcher"]            = 8,   -- shadow damage + mind flay
    ["Gilgoblin Aquamage"]          = 8,   -- water caster
    ["Gilgoblin Hunter"]            = 5,     -- humanoid, CC-able
    ["Deep Murloc Drudge"]          = "SKIP",   -- mass murloc filler
}

db["The Stonecore"] = {
    ["Stonecore Earthshaper"]       = 8,   -- earth caster + ground AoE
    ["Stonecore Magmalord"]         = 8,   -- fire caster; interrupt
    ["Stonecore Rift Conjurer"]     = { mark = 8, dangerLevel = 3 },  -- summons voidwalkers
    ["Millhouse Manastorm"]         = 8,   -- arcane caster (as trash)
    ["IMP"]                         = "SKIP",   -- summoned imp filler
}

db["The Vortex Pinnacle"] = {
    ["Lurking Tempest"]             = 8,   -- lightning caster
    ["Minister of Air"]             = 8,   -- chain lightning + heal
    ["Temple Adept"]                = { mark = 8, dangerLevel = 3 },  -- healer
    ["Turbulent Squall"]            = 8,   -- lightning caster
    ["Wild Vortex"]                 = 5,     -- elemental, banishable
    ["Young Storm Dragon"]          = 5,     -- dragonkin, CC-able
    ["Howling Gale"]                = "SKIP",   -- environmental filler
}

db["Lost City of the Tol'vir"] = {
    ["Neferset Darkcaster"]         = 8,   -- shadow caster
    ["Neferset Plaguebringer"]      = 8,   -- disease + shadow damage
    ["Oathsworn Pathfinder"]        = 8,   -- ranged + multishot
    ["Oathsworn Skinner"]           = 5,     -- humanoid, CC-able
    ["Pygmy Scout"]                 = "SKIP",   -- pygmy filler
}

db["Halls of Origination"] = {
    ["Temple Runecaster"]           = { mark = 8, dangerLevel = 2 },  -- rune caster; interrupt
    ["Temple Shadowlancer"]         = 8,   -- stealth + shadow damage
    ["Temple Fireshaper"]           = 8,   -- fire caster
    ["Temple Swiftstalker"]         = 8,   -- ranged + rapid shot
    ["Air Warden"]                  = 5,     -- elemental, banishable
    ["Flame Warden"]                = 5,     -- elemental, banishable
    ["Water Warden"]                = { mark = 8, dangerLevel = 3 },  -- healer elemental
}

db["Grim Batol"] = {
    ["Twilight Beguiler"]           = { mark = 8, dangerLevel = 2 },  -- mind control + shadow
    ["Twilight Earthcaller"]        = 8,   -- earth caster; summons
    ["Twilight Firecatcher"]        = 8,   -- fire caster
    ["Twilight Shadow Weaver"]      = 8,   -- shadow bolt volley
    ["Twilight Stormbreaker"]       = 8,   -- chain lightning
    ["Twilight Thundercaller"]      = 8,   -- lightning + storm caster
    ["Twilight War-Mage"]           = 8,   -- polymorph + fireball
    ["Twilight Wyrmcaller"]         = { mark = 8, dangerLevel = 3 },  -- calls drake adds
    ["Azureborne Seer"]             = 8,   -- twilight caster
}

db["Zul'Aman"] = {
    ["Amani'shi Flame Caster"]      = 8,   -- fire caster
    ["Amani'shi Medicine Man"]      = { mark = 8, dangerLevel = 3 },  -- healer + hex
    ["Amani'shi Scout"]             = { mark = 8, dangerLevel = 3 },  -- calls reinforcements
    ["Amani'shi Beast Tamer"]       = 8,   -- beast caller
    ["Amani'shi Guardian"]          = 5,     -- humanoid, CC-able
    ["Amani Lynx"]                  = 5,     -- beast, trappable
    ["Forest Frog"]                 = "SKIP",   -- hex target filler
}

db["Zul'Gurub"] = {
    ["Gurubashi Shadow Hunter"]     = 8,   -- shadow bolt + hex
    ["Gurubashi Blood Drinker"]     = 8,   -- life drain caster
    ["Gurubashi Cauldron Mixer"]    = 8,   -- poison caster
    ["Tiki Lord Zim'wae"]           = 8,   -- fire caster + totems
    ["Florawing Hive Queen"]        = 8,   -- poison + summons
    ["Venomancer T'Kulu"]           = 8,   -- poison caster
    ["Zanzili Zombie"]              = "SKIP",   -- mass zombie filler
}

db["End Time"] = {
    ["Time-Twisted Geist"]          = 5,     -- undead, shackleable
    ["Time-Twisted Nightsaber"]     = 5,     -- beast, trappable
    ["Time-Twisted Priest"]         = { mark = 8, dangerLevel = 3 },  -- healer
    ["Time-Twisted Rifleman"]       = 8,   -- ranged; multishot
    ["Time-Twisted Seer"]           = 8,   -- arcane caster
    ["Time-Twisted Sorceress"]      = 8,   -- frost + fire caster
}

db["Well of Eternity"] = {
    ["Dreadlord Defender"]          = { mark = 8, dangerLevel = 2 },  -- shadow damage + fear
    ["Enchanted Highmistress"]      = 8,   -- arcane caster
    ["Eye of the Legion"]           = 8,   -- shadow beam
    ["Fel Crystal"]                 = "SKIP",   -- crystal filler
    ["Legion Demon"]                = 5,     -- demon, banishable
    ["Shadowbat"]                   = 5,     -- beast, trappable
    ["Var'azun"]                    = 8,   -- shadow caster
}

db["Hour of Twilight"] = {
    ["Twilight Assassin"]           = 8,   -- stealth + garrote
    ["Twilight Ranger"]             = 8,   -- ranged + ice trap
    ["Faceless Shadow Weaver"]      = 8,   -- shadow + void
    ["Crystalline Elemental"]       = 5,     -- elemental, banishable
}

-- ============================================================
-- CATACLYSM RAIDS
-- ============================================================

db["Blackwing Descent"] = {
    ["Arcanotron"]                  = 8,   -- Omnotron target caller
    ["Electron"]                    = 8,   -- Omnotron target caller
    ["Magmatron"]                   = 8,   -- Omnotron target caller
    ["Toxitron"]                    = 8,   -- Omnotron target caller
    ["Aberration"]                  = 8,   -- Maloriak add
    ["Prime Subject"]               = 8,   -- Maloriak add
    ["Lava Parasite"]               = 8,   -- Magmaw add
    ["Blazing Bone Construct"]      = 8,   -- Nefarian add
    ["Drakonid Chainwielder"]       = 8,
}

db["The Bastion of Twilight"] = {
    ["Chosen Seer"]                 = 8,   -- healer/caster trash
    ["Twilight Dark Mender"]        = { mark = 8, dangerLevel = 3 },  -- healer
    ["Twilight Shadow Mender"]      = { mark = 8, dangerLevel = 3 },  -- healer
    ["Twilight Elementalist"]       = 8,   -- dangerous caster trash
    ["Twilight Soul Blade"]         = 8,   -- dangerous melee burst
    ["Faceless Guardian"]           = 8,
    ["Corrupting Adherent"]         = 8,   -- Cho'gall add
    ["Darkened Creation"]           = 8,   -- Cho'gall add
    ["Blood of the Old God"]        = 8,   -- Cho'gall add
    ["Spiked Tentacle"]             = 8,   -- Sinestra add
    ["Elementium Monstrosity"]      = 8,   -- Ascendant Council fusion target
}

db["Throne of the Four Winds"] = {
    ["Ravenous Creeper"]            = 8,   -- Anshal add
    ["Stormling"]                   = 8,   -- Al'Akir add
}

db["Baradin Hold"] = {
    ["Disciple of Hate"]            = 8,   -- Alizabal add
    ["Eye of Occu'thar"]            = 8,   -- Occu'thar add
}

db["Firelands"] = {
    ["Flamewaker Cauterizer"]       = { mark = 8, dangerLevel = 3 },  -- healer
    ["Flamewaker Subjugator"]       = 8,   -- dangerous caster
    ["Flamewaker Pathfinder"]       = 8,
    ["Flamewaker Beast Handler"]    = 8,
    ["Flamewaker Hound Master"]     = 8,
    ["Flamewaker Animator"]         = 8,
    ["Unbound Pyrelord"]            = 8,
    ["Unbound Smoldering Elemental"] = 5,    -- elemental, banishable
    ["Molten Lord"]                 = 8,
    ["Ancient Core Hound"]          = 5,     -- beast, trappable
    ["Cinderweb Spinner"]           = 8,
    ["Cinderweb Spiderling"]        = "SKIP",   -- filler spiderlings
    ["Blazing Talon Initiate"]      = 8,
    ["Voracious Hatchling"]         = 8,
    ["Harbinger of Flame"]          = 8,
    ["Druid of the Flame"]          = 8,
    ["Rageface"]                    = 8,   -- Shannox dog
    ["Riplimb"]                     = 8,   -- Shannox dog
}

db["Dragon Soul"] = {
    ["Twilight Elite Dreadblade"]   = 8,
    ["Twilight Elite Slayer"]       = 8,
    ["Twilight Frost Evoker"]       = 8,
    ["Twilight Siege Captain"]      = 8,
    ["Twilight Sapper"]             = 8,   -- Warmaster add
    ["Harbinger of Twilight"]       = 8,
    ["Harbinger of Destruction"]    = 8,
    ["Faceless Corruptor"]          = 8,
    ["Ancient Water Lord"]          = 8,
    ["Stormbinder Adept"]           = 8,
    ["Elementium Bolt"]             = 8,
    ["Elementium Terror"]           = 8,
    ["Mutated Corruption"]          = 8,
    ["Wing Tentacle"]               = 8,
    ["Claw of Go'rath"]             = 8,
    ["Eye of Go'rath"]              = 8,
    ["Flail of Go'rath"]            = 8,
    ["Blistering Tentacle"]         = 8,
    ["Hideous Amalgamation"]        = 8,
    ["Burning Tendons"]             = 8,
    ["Congealing Blood"]            = 8,
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
