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
    ["Fallen Waterspeaker"]         = "HIGH",   -- healer + water caster
    ["Haunting Sha"]                = "HIGH",   -- shadow damage + fear
    ["Jiang"]                       = "MEDIUM",
    ["Jade Guardian"]               = "MEDIUM",
    ["Sha-Touched Guardian"]        = "MEDIUM",
    ["Depraved Mistweaver"]         = "HIGH",   -- healer
    ["Minion of Doubt"]             = "CC",     -- sha spawn, CC-able
    ["Shambling Infester"]          = "CC",     -- undead-type, CC-able
    ["Corrupted Scroll"]            = "SKIP",   -- scroll filler
}

db["Stormstout Brewery"] = {
    ["Hozen Bouncer"]               = "MEDIUM",
    ["Hozen Party Animal"]          = "CC",     -- humanoid, CC-able
    ["Sodden Hozen Brawler"]        = "MEDIUM",
    ["Inflamed Hozen Brawler"]      = "HIGH",   -- fire damage + enrage
    ["Habanero Brew"]               = "SKIP",   -- environmental filler
    ["Bloated Brew Alemental"]      = "MEDIUM",
    ["Bubbling Brew Alemental"]     = "HIGH",   -- AoE damage
    ["Yeasty Brew Alemental"]       = "CC",     -- elemental, banishable
    ["Stout Brew Alemental"]        = "LOW",
    ["Sudsy Brew Alemental"]        = "SKIP",   -- filler
}

db["Gate of the Setting Sun"] = {
    ["Krik'thik Striker"]           = "MEDIUM",
    ["Krik'thik Infiltrator"]       = "HIGH",   -- stealth + sabotage
    ["Krik'thik Demolisher"]        = "HIGH",   -- siege damage + AoE
    ["Krik'thik Bombardier"]        = "HIGH",   -- ranged AoE
    ["Krik'thik Wind Shaper"]       = "HIGH",   -- wind caster
    ["Krik'thik Swarmer"]           = "SKIP",   -- mass swarm filler
    ["Krik'thik Engulfer"]          = "MEDIUM",
    ["Krik'thik Saboteur"]          = "HIGH",   -- bomb planter; kill ASAP
    ["Serpent Spine Defender"]       = "LOW",
}

db["Shado-Pan Monastery"] = {
    ["Shado-Pan Disciple"]          = "MEDIUM",
    ["Shado-Pan Archery Target"]    = "SKIP",   -- target filler
    ["Hateful Essence"]             = "HIGH",   -- shadow caster
    ["Residual Hatred"]             = "HIGH",   -- shadow damage + stacking
    ["Consuming Sha"]               = "CC",     -- sha spawn, CC-able
    ["Ethereal Sha"]                = "HIGH",   -- shadow caster
    ["Shado-Pan Novice"]            = "CC",     -- possessed humanoid
    ["Sha-Infested Stalwart"]       = "MEDIUM",
    ["Fragment of Hatred"]          = "SKIP",   -- sha fragment filler
}

db["Siege of Niuzao Temple"] = {
    ["Sik'thik Amber Weaver"]       = "HIGH",   -- amber caster; encases allies
    ["Sik'thik Venomspitter"]       = "HIGH",   -- poison volley
    ["Sik'thik Warrior"]            = "MEDIUM",
    ["Sik'thik Bladedancer"]        = "MEDIUM",
    ["Krik'thik Infiltrator"]       = "HIGH",   -- stealth + sabotage
    ["Resin Flake"]                 = "SKIP",   -- amber filler
    ["Volatile Amber"]              = "SKIP",   -- environmental filler
    ["Sik'thik Swarmer"]            = "SKIP",   -- mass swarm filler
    ["Amber Encaser"]               = "HIGH",   -- encases party members
}

db["Mogu'shan Palace"] = {
    ["Glintrok Skulker"]            = "HIGH",   -- stealth + backstab
    ["Glintrok Oracle"]             = "HIGH",   -- healer
    ["Glintrok Hexxer"]             = "HIGH",   -- hex + shadow damage
    ["Glintrok Ironhide"]           = "MEDIUM",
    ["Glintrok Pillager"]           = "MEDIUM",
    ["Kargesh Ribcrusher"]          = "MEDIUM",
    ["Kargesh Grunt"]               = "CC",     -- humanoid, CC-able
    ["Quilen Guardian"]             = "CC",     -- beast, CC-able
    ["Ming the Cunning"]            = "HIGH",   -- magnetic field + AoE
}

-- ============================================================
-- MISTS OF PANDARIA RAIDS
-- ============================================================

db["Mogu'shan Vaults"] = {
    ["Mogu'shan Arcanist"]          = "HIGH",   -- caster trash
    ["Mogu'shan Secret-Keeper"]     = "HIGH",   -- caster trash
    ["Mogu'shan Warden"]            = "MEDIUM",
    ["Mogu Archer"]                 = "HIGH",
    ["Sorcerer Mogu"]               = "HIGH",
    ["Mounted Mogu"]                = "MEDIUM",
    ["Enormous Stone Quilen"]       = "MEDIUM",
    ["Stone Quilen"]                = "MEDIUM",
    ["Cursed Mogu Sculpture"]       = "MEDIUM",
    ["Zandalari Fire-Dancer"]       = "HIGH",
    ["Zandalari Infiltrator"]       = "HIGH",
    ["Zandalari Pterror Wing"]      = "CC",     -- beast, trappable
    ["Zandalari Skullcharger"]      = "MEDIUM",
    ["Zandalari Terror Rider"]      = "HIGH",
    ["Zandalari War Wyvern"]        = "CC",     -- beast, trappable
    ["Undying Shadows"]             = "HIGH",   -- Gara'jal add
    ["Emperor's Courage"]           = "MEDIUM",
    ["Emperor's Rage"]              = "HIGH",
    ["Emperor's Strength"]          = "MEDIUM",
    ["Titan Spark"]                 = "HIGH",
    ["Energy Charge"]               = "HIGH",
    ["Celestial Protector"]         = "HIGH",
    ["Amethyst Guardian"]           = "HIGH",
    ["Cobalt Guardian"]             = "HIGH",
    ["Jade Guardian"]               = "HIGH",
    ["Jasper Guardian"]             = "HIGH",
    ["Feng the Accursed"]           = "LOW",
    ["Gara'jal the Spiritbinder"]   = "LOW",
    ["Elegon"]                      = "LOW",
}

db["Heart of Fear"] = {
    ["Kor'thik Elite Blademaster"]  = "HIGH",
    ["Kor'thik Extremist"]          = "HIGH",
    ["Kor'thik Warsinger"]          = "HIGH",
    ["Sra'thik Ambercaller"]        = "HIGH",
    ["Sra'thik Amber-Trapper"]      = "HIGH",
    ["Sra'thik Shield Master"]      = "MEDIUM",
    ["Zar'thik Battle-Mender"]      = "HIGH",   -- healer
    ["Zar'thik Augurer"]            = "HIGH",
    ["Zar'thik Zealot"]             = "MEDIUM",
    ["Set'thik Gale-Slicer"]        = "HIGH",
    ["Set'thik Swiftblade"]         = "MEDIUM",
    ["Set'thik Tempest"]            = "HIGH",
    ["Set'thik Windblade"]          = "MEDIUM",
    ["Set'thik Zephyrian"]          = "HIGH",
    ["Amber Monstrosity"]           = "HIGH",
    ["Living Amber"]                = "HIGH",
    ["Coagulated Amber"]            = "MEDIUM",
    ["Garalon's Leg"]               = "HIGH",   -- boss limb target
    ["Kor'thik Swarmer"]            = "SKIP",   -- filler swarmers
    ["Kor'thik Swarmguard"]         = "MEDIUM",
    ["Imperial Vizier Zor'lok"]     = "LOW",
    ["Blade Lord Ta'yak"]           = "LOW",
    ["Garalon"]                     = "LOW",
    ["Wind Lord Mel'jarak"]         = "LOW",
    ["Amber-Shaper Un'sok"]         = "LOW",
    ["Grand Empress Shek'zeer"]     = "LOW",
}

db["Terrace of Endless Spring"] = {
    ["Corrupted Protector"]         = "HIGH",
    ["Corrupted Waters"]            = "HIGH",
    ["Animated Protector"]          = "MEDIUM",
    ["Apparition of Fear"]          = "HIGH",
    ["Apparition of Terror"]        = "HIGH",
    ["Embodied Terror"]             = "HIGH",
    ["Terror Spawn"]                = "HIGH",
    ["Dread Spawn"]                 = "HIGH",
    ["Night Terror"]                = "HIGH",
    ["Minion of Fear"]              = "MEDIUM",
    ["Unstable Sha"]                = "HIGH",
    ["Protector Kaolan"]            = "LOW",
    ["Elder Asani"]                 = "LOW",
    ["Elder Regail"]                = "LOW",
    ["Tsulong"]                     = "LOW",
    ["Lei Shi"]                     = "LOW",
    ["Sha of Fear"]                 = "LOW",
}

db["Throne of Thunder"] = {
    ["Amani'shi Beast Shaman"]      = "HIGH",
    ["Amani'shi Flame Caster"]      = "HIGH",
    ["Amani'shi Flame Chanter"]     = "HIGH",
    ["Amani'shi Protector"]         = "MEDIUM",
    ["Drakkari Frost Warden"]       = "HIGH",
    ["Drakkari Frozen Warlord"]     = "MEDIUM",
    ["Farraki Sand Conjurer"]       = "HIGH",
    ["Farraki Skirmisher"]          = "MEDIUM",
    ["Farraki Wastewalker"]         = "MEDIUM",
    ["Gurubashi Bloodlord"]         = "HIGH",
    ["Gurubashi Venom Priest"]      = "HIGH",
    ["Zandalari Dinomancer"]        = "HIGH",
    ["Zandalari High Priest"]       = "HIGH",
    ["Zandalari Prophet"]           = "HIGH",
    ["Zandalari Storm-Caller"]      = "HIGH",
    ["Zandalari Water-Binder"]      = "HIGH",
    ["Zandalari Prelate"]           = "MEDIUM",
    ["Zandalari Warlord"]           = "MEDIUM",
    ["Anima Golem"]                 = "MEDIUM",
    ["Large Anima Golem"]           = "MEDIUM",
    ["Massive Anima Golem"]         = "HIGH",
    ["Spirit Flayer"]               = "HIGH",
    ["Amani Warbear"]               = "CC",     -- beast, trappable
    ["Ancient Python"]              = "CC",     -- beast, trappable
    ["Vampiric Cave Bat"]           = "CC",     -- beast, trappable
    ["Beast of Nightmares"]         = "HIGH",
    ["War-God Jalak"]               = "HIGH",   -- Horridon add
    ["Venomous Effusion"]           = "HIGH",
    ["Ball Lightning"]              = "HIGH",
    ["Diffused Lightning"]          = "HIGH",
    ["Lesser Diffused Lightning"]   = "HIGH",
    ["Greater Diffused Lightning"]  = "HIGH",
    ["Crackling Stalker"]           = "HIGH",
    ["Horridon"]                    = "LOW",
    ["Dark Animus"]                 = "LOW",
    ["Ji-Kun"]                      = "LOW",
    ["Primordius"]                  = "LOW",
    ["Durumu the Forgotten"]        = "LOW",
    ["Tortos"]                      = "LOW",
    ["Iron Qon"]                    = "LOW",
    ["Lei Shen"]                    = "LOW",
    ["Ra-den"]                      = "LOW",
}

db["Siege of Orgrimmar"] = {
    ["Tormented Initiate"]          = "HIGH",
    ["Fallen Pool Tender"]          = "HIGH",
    ["Lesser Sha Puddle"]           = "SKIP",   -- filler puddles on Immerseus
    ["Aqueous Defender"]            = "MEDIUM",
    ["Embodied Misery"]             = "HIGH",
    ["Embodied Sorrow"]             = "HIGH",
    ["Embodied Gloom"]              = "HIGH",
    ["Embodied Anguish"]            = "HIGH",
    ["Embodied Despair"]            = "HIGH",
    ["Embodied Desperation"]        = "HIGH",
    ["Despair Spawn"]               = "HIGH",
    ["Manifestation of Corruption"] = "HIGH",
    ["Essence of Corruption"]       = "HIGH",
    ["Titanic Corruption"]          = "HIGH",
    ["Manifestation of Pride"]      = "HIGH",
    ["Reflection"]                  = "HIGH",
    ["Lingering Corruption"]        = "MEDIUM",
    ["Dragonmaw Bonecrusher"]       = "HIGH",
    ["Dragonmaw Tidal Shaman"]      = "HIGH",
    ["Dragonmaw Flameslinger"]      = "HIGH",
    ["Dragonmaw Ebon Stalker"]      = "HIGH",
    ["Dragonmaw Proto-Drake"]       = "MEDIUM",
    ["Kor'kron Demolisher"]         = "HIGH",
    ["Crawler Mine"]                = "HIGH",
    ["Blind Blademaster"]           = "HIGH",
    ["Kor'kron Shadowmage"]         = "HIGH",
    ["Kor'kron Ironblade"]          = "MEDIUM",
    ["Kor'kron Arcweaver"]          = "HIGH",
    ["Kor'kron Assassin"]           = "HIGH",
    ["Kor'kron Warshaman"]          = "HIGH",
    ["Orgrimmar Faithful"]          = "MEDIUM",
    ["Kor'kron Blood Axe"]          = "MEDIUM",
    ["Kor'kron Dark Farseer"]       = "HIGH",
    ["Corrupted Skullsplitter"]     = "HIGH",
    ["Living Corruption"]           = "HIGH",
    ["Kor'kron Machinist"]          = "HIGH",
    ["Kor'kron Shredder"]           = "HIGH",
    ["Automated Shredder"]          = "HIGH",
    ["Blackfuse Engineer"]          = "HIGH",
    ["Blackfuse Sellsword"]         = "MEDIUM",
    ["Kor'kron Reaper"]             = "MEDIUM",
    ["Harbinger of Y'Shaarj"]       = "HIGH",
    ["Manifestation"]               = "HIGH",
    ["Ichor of Y'Shaarj"]           = "HIGH",
    ["Sra'thik Amber-Master"]       = "HIGH",
    ["Kor'thik Honor Guard"]        = "MEDIUM",
    ["Klaxxi Skirmisher"]           = "MEDIUM",
    ["Desecrated Weapon"]           = "HIGH",
    ["Kor'kron Warbringer"]         = "HIGH",
    ["Farseer Wolf Rider"]          = "HIGH",
    ["Siege Engineer"]              = "HIGH",
    ["Manifestation of Rage"]       = "HIGH",
    ["Minion of Y'Shaarj"]          = "HIGH",
    ["Immerseus"]                   = "LOW",
    ["Rook Stonetoe"]               = "LOW",
    ["He Softfoot"]                 = "LOW",
    ["Sun Tenderheart"]             = "LOW",
    ["Norushen"]                    = "LOW",
    ["Sha of Pride"]                = "LOW",
    ["Galakras"]                    = "LOW",
    ["Iron Juggernaut"]             = "LOW",
    ["Earthbreaker Haromm"]         = "LOW",
    ["Wavebinder Kardris"]          = "LOW",
    ["General Nazgrim"]             = "LOW",
    ["Malkorok"]                    = "LOW",
    ["Secured Stockpile of Pandaren Spoils"] = "LOW",
    ["Thok the Bloodthirsty"]       = "LOW",
    ["Siegecrafter Blackfuse"]      = "LOW",
    ["Skeer the Bloodseeker"]       = "LOW",
    ["Hisek the Swarmkeeper"]       = "LOW",
    ["Ka'roz the Locust"]           = "LOW",
    ["Korven the Prime"]            = "LOW",
    ["Kaz'tik the Manipulator"]     = "LOW",
    ["Rik'kal the Dissector"]       = "LOW",
    ["Iyyokuk the Lucid"]           = "LOW",
    ["Kil'ruk the Wind-Reaver"]     = "LOW",
    ["Xaril the Poisoned Mind"]     = "LOW",
    ["Garrosh Hellscream"]          = "LOW",
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

table.insert(order, { name = "Mists of Pandaria", zones = {
    "Temple of the Jade Serpent", "Stormstout Brewery",
    "Gate of the Setting Sun", "Shado-Pan Monastery",
    "Siege of Niuzao Temple", "Mogu'shan Palace",
    "Mogu'shan Vaults", "Heart of Fear", "Terrace of Endless Spring",
    "Throne of Thunder", "Siege of Orgrimmar",
}})
