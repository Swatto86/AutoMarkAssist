-- AutoMarkAssist_DB_MoP.lua
-- Mists of Pandaria dungeon and raid entries.
-- Loaded AFTER AutoMarkAssist_DB_Cata.lua; merges 11 MoP zones.

local db      = AutoMarkAssist_MobDB
local aliases = AutoMarkAssist_ZoneAliases
local order   = AutoMarkAssist_ExpansionOrder

-- ============================================================
-- MISTS OF PANDARIA DUNGEONS
-- ============================================================

db["Temple of the Jade Serpent"] = {
    ["Fallen Waterspeaker"]         = 8,   -- healer + water caster
    ["Haunting Sha"]                = 8,   -- shadow damage + fear
    ["Depraved Mistweaver"]         = 8,   -- healer
    ["Minion of Doubt"]             = 5,     -- sha spawn, CC-able
    ["Shambling Infester"]          = 5,     -- undead-type, CC-able
    ["Corrupted Scroll"]            = "SKIP",   -- scroll filler
}

db["Stormstout Brewery"] = {
    ["Hozen Party Animal"]          = 5,     -- humanoid, CC-able
    ["Inflamed Hozen Brawler"]      = 8,   -- fire damage + enrage
    ["Habanero Brew"]               = "SKIP",   -- environmental filler
    ["Bubbling Brew Alemental"]     = 8,   -- AoE damage
    ["Yeasty Brew Alemental"]       = 5,     -- elemental, banishable
    ["Sudsy Brew Alemental"]        = "SKIP",   -- filler
}

db["Gate of the Setting Sun"] = {
    ["Krik'thik Infiltrator"]       = 8,   -- stealth + sabotage
    ["Krik'thik Demolisher"]        = 8,   -- siege damage + AoE
    ["Krik'thik Bombardier"]        = 8,   -- ranged AoE
    ["Krik'thik Wind Shaper"]       = 8,   -- wind caster
    ["Krik'thik Swarmer"]           = "SKIP",   -- mass swarm filler
    ["Krik'thik Saboteur"]          = 8,   -- bomb planter; kill ASAP
}

db["Shado-Pan Monastery"] = {
    ["Shado-Pan Archery Target"]    = "SKIP",   -- target filler
    ["Hateful Essence"]             = 8,   -- shadow caster
    ["Residual Hatred"]             = 8,   -- shadow damage + stacking
    ["Consuming Sha"]               = 5,     -- sha spawn, CC-able
    ["Ethereal Sha"]                = 8,   -- shadow caster
    ["Shado-Pan Novice"]            = 5,     -- possessed humanoid
    ["Fragment of Hatred"]          = "SKIP",   -- sha fragment filler
}

db["Siege of Niuzao Temple"] = {
    ["Sik'thik Amber Weaver"]       = 8,   -- amber caster; encases allies
    ["Sik'thik Venomspitter"]       = 8,   -- poison volley
    ["Krik'thik Infiltrator"]       = 8,   -- stealth + sabotage
    ["Resin Flake"]                 = "SKIP",   -- amber filler
    ["Volatile Amber"]              = "SKIP",   -- environmental filler
    ["Sik'thik Swarmer"]            = "SKIP",   -- mass swarm filler
    ["Amber Encaser"]               = 8,   -- encases party members
}

db["Mogu'shan Palace"] = {
    ["Glintrok Skulker"]            = 8,   -- stealth + backstab
    ["Glintrok Oracle"]             = 8,   -- healer
    ["Glintrok Hexxer"]             = 8,   -- hex + shadow damage
    ["Kargesh Grunt"]               = 5,     -- humanoid, CC-able
    ["Quilen Guardian"]             = 5,     -- beast, CC-able
    ["Ming the Cunning"]            = 8,   -- magnetic field + AoE
}

-- ============================================================
-- MISTS OF PANDARIA RAIDS
-- ============================================================

db["Mogu'shan Vaults"] = {
    ["Mogu'shan Arcanist"]          = 8,   -- caster trash
    ["Mogu'shan Secret-Keeper"]     = 8,   -- caster trash
    ["Mogu Archer"]                 = 8,
    ["Sorcerer Mogu"]               = 8,
    ["Zandalari Fire-Dancer"]       = 8,
    ["Zandalari Infiltrator"]       = 8,
    ["Zandalari Pterror Wing"]      = 5,     -- beast, trappable
    ["Zandalari Terror Rider"]      = 8,
    ["Zandalari War Wyvern"]        = 5,     -- beast, trappable
    ["Undying Shadows"]             = 8,   -- Gara'jal add
    ["Emperor's Rage"]              = 8,
    ["Titan Spark"]                 = 8,
    ["Energy Charge"]               = 8,
    ["Celestial Protector"]         = 8,
    ["Amethyst Guardian"]           = 8,
    ["Cobalt Guardian"]             = 8,
    ["Jade Guardian"]               = 8,
    ["Jasper Guardian"]             = 8,
}

db["Heart of Fear"] = {
    ["Kor'thik Elite Blademaster"]  = 8,
    ["Kor'thik Extremist"]          = 8,
    ["Kor'thik Warsinger"]          = 8,
    ["Sra'thik Ambercaller"]        = 8,
    ["Sra'thik Amber-Trapper"]      = 8,
    ["Zar'thik Battle-Mender"]      = 8,   -- healer
    ["Zar'thik Augurer"]            = 8,
    ["Set'thik Gale-Slicer"]        = 8,
    ["Set'thik Tempest"]            = 8,
    ["Set'thik Zephyrian"]          = 8,
    ["Amber Monstrosity"]           = 8,
    ["Living Amber"]                = 8,
    ["Garalon's Leg"]               = 8,   -- boss limb target
    ["Kor'thik Swarmer"]            = "SKIP",   -- filler swarmers
}

db["Terrace of Endless Spring"] = {
    ["Corrupted Protector"]         = 8,
    ["Corrupted Waters"]            = 8,
    ["Apparition of Fear"]          = 8,
    ["Apparition of Terror"]        = 8,
    ["Embodied Terror"]             = 8,
    ["Terror Spawn"]                = 8,
    ["Dread Spawn"]                 = 8,
    ["Night Terror"]                = 8,
    ["Unstable Sha"]                = 8,
}

db["Throne of Thunder"] = {
    ["Amani'shi Beast Shaman"]      = 8,
    ["Amani'shi Flame Caster"]      = 8,
    ["Amani'shi Flame Chanter"]     = 8,
    ["Drakkari Frost Warden"]       = 8,
    ["Farraki Sand Conjurer"]       = 8,
    ["Gurubashi Bloodlord"]         = 8,
    ["Gurubashi Venom Priest"]      = 8,
    ["Zandalari Dinomancer"]        = 8,
    ["Zandalari High Priest"]       = 8,
    ["Zandalari Prophet"]           = 8,
    ["Zandalari Storm-Caller"]      = 8,
    ["Zandalari Water-Binder"]      = 8,
    ["Massive Anima Golem"]         = 8,
    ["Spirit Flayer"]               = 8,
    ["Amani Warbear"]               = 5,     -- beast, trappable
    ["Ancient Python"]              = 5,     -- beast, trappable
    ["Vampiric Cave Bat"]           = 5,     -- beast, trappable
    ["Beast of Nightmares"]         = 8,
    ["War-God Jalak"]               = 8,   -- Horridon add
    ["Venomous Effusion"]           = 8,
    ["Ball Lightning"]              = 8,
    ["Diffused Lightning"]          = 8,
    ["Lesser Diffused Lightning"]   = 8,
    ["Greater Diffused Lightning"]  = 8,
    ["Crackling Stalker"]           = 8,
}

db["Siege of Orgrimmar"] = {
    ["Tormented Initiate"]          = 8,
    ["Fallen Pool Tender"]          = 8,
    ["Lesser Sha Puddle"]           = "SKIP",   -- filler puddles on Immerseus
    ["Embodied Misery"]             = 8,
    ["Embodied Sorrow"]             = 8,
    ["Embodied Gloom"]              = 8,
    ["Embodied Anguish"]            = 8,
    ["Embodied Despair"]            = 8,
    ["Embodied Desperation"]        = 8,
    ["Despair Spawn"]               = 8,
    ["Manifestation of Corruption"] = 8,
    ["Essence of Corruption"]       = 8,
    ["Titanic Corruption"]          = 8,
    ["Manifestation of Pride"]      = 8,
    ["Reflection"]                  = 8,
    ["Dragonmaw Bonecrusher"]       = 8,
    ["Dragonmaw Tidal Shaman"]      = 8,
    ["Dragonmaw Flameslinger"]      = 8,
    ["Dragonmaw Ebon Stalker"]      = 8,
    ["Kor'kron Demolisher"]         = 8,
    ["Crawler Mine"]                = 8,
    ["Blind Blademaster"]           = 8,
    ["Kor'kron Shadowmage"]         = 8,
    ["Kor'kron Arcweaver"]          = 8,
    ["Kor'kron Assassin"]           = 8,
    ["Kor'kron Warshaman"]          = 8,
    ["Kor'kron Dark Farseer"]       = 8,
    ["Corrupted Skullsplitter"]     = 8,
    ["Living Corruption"]           = 8,
    ["Kor'kron Machinist"]          = 8,
    ["Kor'kron Shredder"]           = 8,
    ["Automated Shredder"]          = 8,
    ["Blackfuse Engineer"]          = 8,
    ["Harbinger of Y'Shaarj"]       = 8,
    ["Manifestation"]               = 8,
    ["Ichor of Y'Shaarj"]           = 8,
    ["Sra'thik Amber-Master"]       = 8,
    ["Desecrated Weapon"]           = 8,
    ["Kor'kron Warbringer"]         = 8,
    ["Farseer Wolf Rider"]          = 8,
    ["Siege Engineer"]              = 8,
    ["Manifestation of Rage"]       = 8,
    ["Minion of Y'Shaarj"]          = 8,
}

-- ============================================================
-- ZONE ALIASES  (merged into the shared table)
-- ============================================================

local newAliases = {
    ["Temple of the Jade Serpent"]      = "Temple of the Jade Serpent",
    ["Jade Serpent"]                     = "Temple of the Jade Serpent",
    ["Stormstout Brewery"]              = "Stormstout Brewery",
    ["Gate of the Setting Sun"]         = "Gate of the Setting Sun",
    ["Shado-Pan Monastery"]             = "Shado-Pan Monastery",
    ["Siege of Niuzao Temple"]          = "Siege of Niuzao Temple",
    ["Mogu'shan Palace"]                = "Mogu'shan Palace",
    ["Mogu'shan Vaults"]                = "Mogu'shan Vaults",
    ["MSV"]                             = "Mogu'shan Vaults",
    ["Heart of Fear"]                   = "Heart of Fear",
    ["HoF"]                             = "Heart of Fear",
    ["Terrace of Endless Spring"]       = "Terrace of Endless Spring",
    ["ToES"]                            = "Terrace of Endless Spring",
    ["TOES"]                            = "Terrace of Endless Spring",
    ["Throne of Thunder"]               = "Throne of Thunder",
    ["ToT"]                             = "Throne of Thunder",
    ["TOT"]                             = "Throne of Thunder",
    ["Siege of Orgrimmar"]              = "Siege of Orgrimmar",
    ["SoO"]                             = "Siege of Orgrimmar",
    ["SOO"]                             = "Siege of Orgrimmar",
}
for k, v in pairs(newAliases) do aliases[k] = v end

-- ============================================================
-- EXPANSION ORDER  (appended to the shared table)
-- ============================================================

table.insert(order, { name = "Mists of Pandaria", dungeons = {
    "Temple of the Jade Serpent", "Stormstout Brewery",
    "Gate of the Setting Sun", "Shado-Pan Monastery",
    "Siege of Niuzao Temple", "Mogu'shan Palace",
}, raids = {
    "Mogu'shan Vaults", "Heart of Fear", "Terrace of Endless Spring",
    "Throne of Thunder", "Siege of Orgrimmar",
}})
