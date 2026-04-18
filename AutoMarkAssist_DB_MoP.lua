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
    ["Fallen Waterspeaker"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Haunting Sha"]                = { mark = 8, creatureType = "Elemental", dangerLevel = 2 },
    ["Depraved Mistweaver"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Minion of Doubt"]             = { mark = 5, creatureType = "Elemental" },
    ["Shambling Infester"]          = { mark = 5, creatureType = "Aberration" },
    ["Inky Conjurer"]               = { mark = 8, creatureType = "Humanoid" },
    ["Reflection of Doubt"]         = { mark = 5, creatureType = "Elemental" },
    ["Corrupt Living Water"]        = { mark = 5, creatureType = "Elemental" },
    ["Sha of Doubt"]                = { mark = 8, creatureType = "Elemental" },
    ["Sha Puddle"]                  = "SKIP",
    ["Corrupted Scroll"]            = "SKIP",
}

db["Stormstout Brewery"] = {
    ["Hozen Party Animal"]          = { mark = 5, creatureType = "Humanoid" },
    ["Hoptallus' Crony"]            = { mark = 5, creatureType = "Humanoid" },
    ["Hozen Bouncer"]               = { mark = 5, creatureType = "Humanoid" },
    ["Inflamed Hozen Brawler"]      = { mark = 8, creatureType = "Humanoid" },
    ["Drunken Hozen Brawler"]       = { mark = 5, creatureType = "Humanoid" },
    ["Bopper"]                      = { mark = 5, creatureType = "Humanoid" },
    ["Sprayer"]                     = { mark = 8, creatureType = "Humanoid" },
    ["Habanero Brew"]               = "SKIP",
    ["Bubbling Brew Alemental"]     = { mark = 8, creatureType = "Elemental" },
    ["Yeasty Brew Alemental"]       = { mark = 4, creatureType = "Elemental" },
    ["Sudsy Brew Alemental"]        = "SKIP",
    ["Fizzy Brew Alemental"]        = { mark = 5, creatureType = "Elemental" },
    ["Bloated Brew Alemental"]      = { mark = 5, creatureType = "Elemental" },
}

db["Gate of the Setting Sun"] = {
    ["Krik'thik Infiltrator"]       = { mark = 8, creatureType = "Humanoid" },
    ["Krik'thik Demolisher"]        = { mark = 8, creatureType = "Humanoid" },
    ["Krik'thik Bombardier"]        = { mark = 8, creatureType = "Humanoid" },
    ["Krik'thik Wind Shaper"]       = { mark = 8, creatureType = "Humanoid" },
    ["Krik'thik Warrior"]           = { mark = 5, creatureType = "Humanoid" },
    ["Krik'thik Pincer"]            = { mark = 5, creatureType = "Humanoid" },
    ["Krik'thik Swarmer"]           = "SKIP",
    ["Krik'thik Saboteur"]          = { mark = 8, creatureType = "Humanoid" },
    ["Krik'thik Mine"]              = "SKIP",
    ["Shal'Weaver"]                 = { mark = 8, creatureType = "Humanoid" },
}

db["Shado-Pan Monastery"] = {
    ["Shado-Pan Archery Target"]    = "SKIP",
    ["Hateful Essence"]             = { mark = 8, creatureType = "Elemental" },
    ["Residual Hatred"]             = { mark = 8, creatureType = "Elemental" },
    ["Consuming Sha"]               = { mark = 5, creatureType = "Elemental" },
    ["Ethereal Sha"]                = { mark = 8, creatureType = "Elemental" },
    ["Shado-Pan Novice"]            = { mark = 5, creatureType = "Humanoid" },
    ["Shado-Pan Disciple"]          = { mark = 5, creatureType = "Humanoid" },
    ["Shado-Pan Ambusher"]          = { mark = 8, creatureType = "Humanoid" },
    ["Shado-Pan Initiate"]          = { mark = 5, creatureType = "Humanoid" },
    ["Shado-Pan Geomancer"]         = { mark = 8, creatureType = "Humanoid" },
    ["Shado-Pan Monk"]              = { mark = 5, creatureType = "Humanoid" },
    ["Fragment of Hatred"]          = "SKIP",
    ["Snow Drift"]                  = "SKIP",
}

db["Siege of Niuzao Temple"] = {
    ["Sik'thik Amber Weaver"]       = { mark = 8, creatureType = "Humanoid" },
    ["Sik'thik Venomspitter"]       = { mark = 8, creatureType = "Humanoid" },
    ["Sik'thik Warrior"]            = { mark = 5, creatureType = "Humanoid" },
    ["Sik'thik Lancer"]             = { mark = 5, creatureType = "Humanoid" },
    ["Sik'thik Fieldmender"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Sik'thik Engineer"]           = { mark = 8, creatureType = "Humanoid" },
    ["Sik'thik Oil Slinger"]        = { mark = 8, creatureType = "Humanoid" },
    ["Sik'thik Wind Scythe"]        = { mark = 8, creatureType = "Humanoid" },
    ["Resin Flake"]                 = "SKIP",
    ["Volatile Amber"]              = "SKIP",
    ["Sik'thik Swarmer"]            = "SKIP",
    ["Amber Encaser"]               = { mark = 8, creatureType = "Humanoid" },
}

db["Mogu'shan Palace"] = {
    ["Glintrok Skulker"]            = { mark = 8, creatureType = "Humanoid" },
    ["Glintrok Oracle"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Glintrok Hexxer"]             = { mark = 8, creatureType = "Humanoid" },
    ["Glintrok Ironhide"]           = { mark = 5, creatureType = "Humanoid" },
    ["Glintrok Pathfinder"]         = { mark = 5, creatureType = "Humanoid" },
    ["Kargesh Grunt"]               = { mark = 5, creatureType = "Humanoid" },
    ["Kargesh Hopebreaker"]         = { mark = 8, creatureType = "Humanoid" },
    ["Quilen Guardian"]             = { mark = 5, creatureType = "Beast" },
    ["Mogu Shadow Ritualist"]       = { mark = 8, creatureType = "Humanoid" },
    ["Trail Hunter"]                = { mark = 5, creatureType = "Humanoid" },
    ["Ming the Cunning"]            = { mark = 8, creatureType = "Humanoid" },
    ["Kuai the Brute"]              = { mark = 8, creatureType = "Humanoid" },
    ["Haiyan the Unstoppable"]      = { mark = 8, creatureType = "Humanoid" },
}

-- ============================================================
-- MISTS OF PANDARIA RAIDS
-- ============================================================

db["Mogu'shan Vaults"] = {
    ["Mogu'shan Arcanist"]          = { mark = 8, creatureType = "Humanoid" },
    ["Mogu'shan Secret-Keeper"]     = { mark = 8, creatureType = "Humanoid" },
    ["Mogu'shan Warden"]            = { mark = 5, creatureType = "Humanoid" },
    ["Mogu'shan Ritualist"]         = { mark = 8, creatureType = "Humanoid" },
    ["Mogu Archer"]                 = { mark = 8, creatureType = "Humanoid" },
    ["Sorcerer Mogu"]               = { mark = 8, creatureType = "Humanoid" },
    ["Zandalari Fire-Dancer"]       = { mark = 8, creatureType = "Humanoid" },
    ["Zandalari Infiltrator"]       = { mark = 8, creatureType = "Humanoid" },
    ["Zandalari Pterror Wing"]      = { mark = 5, creatureType = "Beast" },
    ["Zandalari Terror Rider"]      = { mark = 8, creatureType = "Humanoid" },
    ["Zandalari War Wyvern"]        = { mark = 5, creatureType = "Beast" },
    ["Undying Shadows"]             = { mark = 8, creatureType = "Elemental" },
    ["Emperor's Rage"]              = { mark = 8, creatureType = "Elemental" },
    ["Titan Spark"]                 = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Energy Charge"]               = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Celestial Protector"]         = { mark = 8, creatureType = "Humanoid" },
    ["Amethyst Guardian"]           = { mark = 8, creatureType = "Elemental" },
    ["Cobalt Guardian"]             = { mark = 8, creatureType = "Elemental" },
    ["Jade Guardian"]               = { mark = 8, creatureType = "Elemental" },
    ["Jasper Guardian"]             = { mark = 8, creatureType = "Elemental" },
    ["Jasper Fragment"]             = "SKIP",
}

db["Heart of Fear"] = {
    ["Kor'thik Elite Blademaster"]  = { mark = 8, creatureType = "Humanoid" },
    ["Kor'thik Extremist"]          = { mark = 8, creatureType = "Humanoid" },
    ["Kor'thik Warsinger"]          = { mark = 8, creatureType = "Humanoid" },
    ["Kor'thik Wind-Blade"]         = { mark = 5, creatureType = "Humanoid" },
    ["Sra'thik Ambercaller"]        = { mark = 8, creatureType = "Humanoid" },
    ["Sra'thik Amber-Trapper"]      = { mark = 8, creatureType = "Humanoid" },
    ["Sra'thik Pincer"]             = { mark = 5, creatureType = "Humanoid" },
    ["Zar'thik Battle-Mender"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Zar'thik Augurer"]            = { mark = 8, creatureType = "Humanoid" },
    ["Zar'thik Zealot"]             = { mark = 5, creatureType = "Humanoid" },
    ["Set'thik Gale-Slicer"]        = { mark = 8, creatureType = "Humanoid" },
    ["Set'thik Tempest"]            = { mark = 8, creatureType = "Humanoid" },
    ["Set'thik Zephyrian"]          = { mark = 8, creatureType = "Humanoid" },
    ["Set'thik Windblade"]          = { mark = 5, creatureType = "Humanoid" },
    ["Amber Monstrosity"]           = { mark = 8, creatureType = "Aberration" },
    ["Living Amber"]                = { mark = 8, creatureType = "Elemental" },
    ["Garalon's Leg"]               = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Kor'thik Swarmer"]            = "SKIP",
}

db["Terrace of Endless Spring"] = {
    ["Corrupted Protector"]         = { mark = 8, creatureType = "Humanoid" },
    ["Corrupted Waters"]            = { mark = 8, creatureType = "Elemental" },
    ["Apparition of Fear"]          = { mark = 8, creatureType = "Elemental" },
    ["Apparition of Terror"]        = { mark = 8, creatureType = "Elemental" },
    ["Embodied Terror"]             = { mark = 8, creatureType = "Elemental" },
    ["Terror Spawn"]                = { mark = 5, creatureType = "Elemental" },
    ["Dread Spawn"]                 = { mark = 8, creatureType = "Elemental" },
    ["Night Terror"]                = { mark = 8, creatureType = "Elemental" },
    ["Unstable Sha"]                = { mark = 8, creatureType = "Elemental" },
}

db["Throne of Thunder"] = {
    ["Amani'shi Beast Shaman"]      = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Flame Caster"]      = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Flame Chanter"]     = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Blade Master"]      = { mark = 5, creatureType = "Humanoid" },
    ["Drakkari Frost Warden"]       = { mark = 8, creatureType = "Humanoid" },
    ["Drakkari Frozen Warlord"]     = { mark = 5, creatureType = "Humanoid" },
    ["Farraki Sand Conjurer"]       = { mark = 8, creatureType = "Humanoid" },
    ["Farraki Wastewalker"]         = { mark = 5, creatureType = "Humanoid" },
    ["Gurubashi Bloodlord"]         = { mark = 8, creatureType = "Humanoid" },
    ["Gurubashi Venom Priest"]      = { mark = 8, creatureType = "Humanoid" },
    ["Zandalari Dinomancer"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Zandalari High Priest"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Zandalari Prophet"]           = { mark = 8, creatureType = "Humanoid" },
    ["Zandalari Storm-Caller"]      = { mark = 8, creatureType = "Humanoid" },
    ["Zandalari Water-Binder"]      = { mark = 8, creatureType = "Humanoid" },
    ["Zandalari Warbringer"]        = { mark = 5, creatureType = "Humanoid" },
    ["Zandalari Beast Ward"]        = { mark = 5, creatureType = "Humanoid" },
    ["Massive Anima Golem"]         = { mark = 8, creatureType = "Elemental" },
    ["Lesser Anima Golem"]          = { mark = 5, creatureType = "Elemental" },
    ["Spirit Flayer"]               = { mark = 8, creatureType = "Elemental" },
    ["Amani Warbear"]               = { mark = 5, creatureType = "Beast" },
    ["Ancient Python"]              = { mark = 5, creatureType = "Beast" },
    ["Vampiric Cave Bat"]           = { mark = 5, creatureType = "Beast" },
    ["Beast of Nightmares"]         = { mark = 8, creatureType = "Beast" },
    ["War-God Jalak"]               = { mark = 8, creatureType = "Humanoid" },
    ["Venomous Effusion"]           = { mark = 8, creatureType = "Elemental" },
    ["Ball Lightning"]              = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Diffused Lightning"]          = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Lesser Diffused Lightning"]   = { mark = 5, creatureType = "Elemental", ccImmune = true },
    ["Greater Diffused Lightning"]  = { mark = 8, creatureType = "Elemental", ccImmune = true },
    ["Crackling Stalker"]           = { mark = 8, creatureType = "Elemental" },
    ["Mindbender Kaartish"]         = { mark = 8, creatureType = "Humanoid" },
}

db["Siege of Orgrimmar"] = {
    ["Tormented Initiate"]          = { mark = 8, creatureType = "Humanoid" },
    ["Fallen Pool Tender"]          = { mark = 8, creatureType = "Humanoid" },
    ["Lesser Sha Puddle"]           = "SKIP",
    ["Embodied Misery"]             = { mark = 8, creatureType = "Elemental" },
    ["Embodied Sorrow"]             = { mark = 8, creatureType = "Elemental" },
    ["Embodied Gloom"]              = { mark = 8, creatureType = "Elemental" },
    ["Embodied Anguish"]            = { mark = 8, creatureType = "Elemental" },
    ["Embodied Despair"]            = { mark = 8, creatureType = "Elemental" },
    ["Embodied Desperation"]        = { mark = 8, creatureType = "Elemental" },
    ["Despair Spawn"]               = { mark = 5, creatureType = "Elemental" },
    ["Manifestation of Corruption"] = { mark = 8, creatureType = "Aberration" },
    ["Essence of Corruption"]       = { mark = 8, creatureType = "Aberration" },
    ["Titanic Corruption"]          = { mark = 8, creatureType = "Aberration" },
    ["Manifestation of Pride"]      = { mark = 8, creatureType = "Elemental" },
    ["Reflection"]                  = { mark = 8, creatureType = "Humanoid" },
    ["Dragonmaw Bonecrusher"]       = { mark = 5, creatureType = "Humanoid" },
    ["Dragonmaw Tidal Shaman"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Dragonmaw Flameslinger"]      = { mark = 8, creatureType = "Humanoid" },
    ["Dragonmaw Ebon Stalker"]      = { mark = 8, creatureType = "Humanoid" },
    ["Dragonmaw War Runner"]        = { mark = 5, creatureType = "Humanoid" },
    ["Kor'kron Demolisher"]         = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Crawler Mine"]                = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Blind Blademaster"]           = { mark = 8, creatureType = "Humanoid" },
    ["Kor'kron Shadowmage"]         = { mark = 8, creatureType = "Humanoid" },
    ["Kor'kron Arcweaver"]          = { mark = 8, creatureType = "Humanoid" },
    ["Kor'kron Assassin"]           = { mark = 8, creatureType = "Humanoid" },
    ["Kor'kron Warshaman"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
    ["Kor'kron Dark Farseer"]       = { mark = 8, creatureType = "Humanoid" },
    ["Kor'kron Reaver"]             = { mark = 5, creatureType = "Humanoid" },
    ["Kor'kron Trooper"]            = { mark = 5, creatureType = "Humanoid" },
    ["Corrupted Skullsplitter"]     = { mark = 8, creatureType = "Humanoid" },
    ["Living Corruption"]           = { mark = 8, creatureType = "Aberration" },
    ["Kor'kron Machinist"]          = { mark = 8, creatureType = "Humanoid" },
    ["Kor'kron Shredder"]           = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Automated Shredder"]          = { mark = 8, creatureType = "Mechanical", ccImmune = true },
    ["Blackfuse Engineer"]          = { mark = 8, creatureType = "Humanoid" },
    ["Harbinger of Y'Shaarj"]       = { mark = 8, creatureType = "Aberration" },
    ["Manifestation"]               = { mark = 8, creatureType = "Elemental" },
    ["Ichor of Y'Shaarj"]           = { mark = 8, creatureType = "Aberration" },
    ["Sra'thik Amber-Master"]       = { mark = 8, creatureType = "Humanoid" },
    ["Desecrated Weapon"]           = { mark = 8, creatureType = "Aberration", ccImmune = true },
    ["Kor'kron Warbringer"]         = { mark = 8, creatureType = "Humanoid" },
    ["Farseer Wolf Rider"]          = { mark = 8, creatureType = "Humanoid" },
    ["Siege Engineer"]              = { mark = 8, creatureType = "Humanoid" },
    ["Manifestation of Rage"]       = { mark = 8, creatureType = "Elemental" },
    ["Minion of Y'Shaarj"]          = { mark = 8, creatureType = "Aberration" },
    ["Saurok Stalker"]              = { mark = 5, creatureType = "Humanoid" },
    ["Iron Juggernaut"]             = { mark = 8, creatureType = "Mechanical", ccImmune = true },
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
