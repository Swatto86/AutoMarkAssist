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
    ["Twilight Flame Caller"]       = "HIGH",   -- fire caster; interrupt
    ["Twilight Zealot"]             = "MEDIUM",
    ["Twilight Torturer"]           = "HIGH",   -- shadow damage + chains
    ["Twilight Obsidian Borer"]     = "MEDIUM",
    ["Twilight Sadist"]             = "HIGH",   -- damage caster
    ["Mad Prisoner"]                = "CC",     -- humanoid, CC-able
    ["Twilight Element Warden"]     = "HIGH",   -- summons elementals
    ["Evolved Twilight Zealot"]     = "MEDIUM",
    ["Incendiary Spark"]            = "SKIP",   -- spark filler
}

db["Throne of the Tides"] = {
    ["Naz'jar Tempest Witch"]       = "HIGH",   -- frost + lightning caster
    ["Naz'jar Sentinel"]            = "MEDIUM",
    ["Naz'jar Honor Guard"]         = "MEDIUM",
    ["Naz'jar Spiritmender"]        = "HIGH",   -- healer
    ["Tainted Sentry"]              = "MEDIUM",
    ["Faceless Watcher"]            = "HIGH",   -- shadow damage + mind flay
    ["Gilgoblin Aquamage"]          = "HIGH",   -- water caster
    ["Gilgoblin Hunter"]            = "CC",     -- humanoid, CC-able
    ["Deep Murloc Drudge"]          = "SKIP",   -- mass murloc filler
}

db["The Stonecore"] = {
    ["Stonecore Berserker"]         = "MEDIUM",
    ["Stonecore Bruiser"]           = "MEDIUM",
    ["Stonecore Earthshaper"]       = "HIGH",   -- earth caster + ground AoE
    ["Stonecore Flayer"]            = "MEDIUM",
    ["Stonecore Magmalord"]         = "HIGH",   -- fire caster; interrupt
    ["Stonecore Rift Conjurer"]     = "HIGH",   -- summons voidwalkers
    ["Stonecore Warbringer"]        = "MEDIUM",
    ["Millhouse Manastorm"]         = "HIGH",   -- arcane caster (as trash)
    ["IMP"]                         = "SKIP",   -- summoned imp filler
}

db["The Vortex Pinnacle"] = {
    ["Gust Soldier"]                = "MEDIUM",
    ["Lurking Tempest"]             = "HIGH",   -- lightning caster
    ["Minister of Air"]             = "HIGH",   -- chain lightning + heal
    ["Servant of Asaad"]            = "MEDIUM",
    ["Temple Adept"]                = "HIGH",   -- healer
    ["Turbulent Squall"]            = "HIGH",   -- lightning caster
    ["Wild Vortex"]                 = "CC",     -- elemental, banishable
    ["Young Storm Dragon"]          = "CC",     -- dragonkin, CC-able
    ["Howling Gale"]                = "SKIP",   -- environmental filler
}

db["Lost City of the Tol'vir"] = {
    ["Neferset Darkcaster"]         = "HIGH",   -- shadow caster
    ["Neferset Plaguebringer"]      = "HIGH",   -- disease + shadow damage
    ["Oathsworn Captain"]           = "MEDIUM",
    ["Oathsworn Myrmidon"]          = "MEDIUM",
    ["Oathsworn Pathfinder"]        = "HIGH",   -- ranged + multishot
    ["Oathsworn Skinner"]           = "CC",     -- humanoid, CC-able
    ["Oathsworn Wanderer"]          = "MEDIUM",
    ["Pygmy Brute"]                 = "LOW",
    ["Pygmy Scout"]                 = "SKIP",   -- pygmy filler
}

db["Halls of Origination"] = {
    ["Temple Runecaster"]           = "HIGH",   -- rune caster; interrupt
    ["Temple Shadowlancer"]         = "HIGH",   -- stealth + shadow damage
    ["Temple Fireshaper"]           = "HIGH",   -- fire caster
    ["Temple Swiftstalker"]         = "HIGH",   -- ranged + rapid shot
    ["Air Warden"]                  = "CC",     -- elemental, banishable
    ["Earth Warden"]                = "MEDIUM",
    ["Flame Warden"]                = "CC",     -- elemental, banishable
    ["Water Warden"]                = "HIGH",   -- healer elemental
    ["Temple Guardian"]             = "MEDIUM",
    ["Stone Trogg Brute"]           = "MEDIUM",
    ["Stone Trogg Pillager"]        = "LOW",
}

db["Grim Batol"] = {
    ["Twilight Armsmaster"]         = "MEDIUM",
    ["Twilight Beguiler"]           = "HIGH",   -- mind control + shadow
    ["Twilight Drake"]              = "MEDIUM",
    ["Twilight Earthcaller"]        = "HIGH",   -- earth caster; summons
    ["Twilight Firecatcher"]        = "HIGH",   -- fire caster
    ["Twilight Shadow Weaver"]      = "HIGH",   -- shadow bolt volley
    ["Twilight Stormbreaker"]       = "HIGH",   -- chain lightning
    ["Twilight Thundercaller"]      = "HIGH",   -- lightning + storm caster
    ["Twilight War-Mage"]           = "HIGH",   -- polymorph + fireball
    ["Twilight Wyrmcaller"]         = "HIGH",   -- calls drake adds
    ["Azureborne Seer"]             = "HIGH",   -- twilight caster
    ["Enslaved Gronn Brute"]        = "MEDIUM",
    ["Trogg Dweller"]               = "LOW",
}

db["Zul'Aman"] = {
    ["Amani'shi Flame Caster"]      = "HIGH",   -- fire caster
    ["Amani'shi Medicine Man"]      = "HIGH",   -- healer + hex
    ["Amani'shi Scout"]             = "HIGH",   -- calls reinforcements
    ["Amani'shi Beast Tamer"]       = "HIGH",   -- beast caller
    ["Amani'shi Warrior"]           = "MEDIUM",
    ["Amani'shi Protector"]         = "MEDIUM",
    ["Amani'shi Guardian"]          = "CC",     -- humanoid, CC-able
    ["Amani Lynx"]                  = "CC",     -- beast, trappable
    ["Forest Frog"]                 = "SKIP",   -- hex target filler
}

db["Zul'Gurub"] = {
    ["Gurubashi Shadow Hunter"]     = "HIGH",   -- shadow bolt + hex
    ["Gurubashi Blood Drinker"]     = "HIGH",   -- life drain caster
    ["Gurubashi Berserker"]         = "MEDIUM",
    ["Gurubashi Cauldron Mixer"]    = "HIGH",   -- poison caster
    ["Gurubashi Master Chef"]       = "MEDIUM",
    ["Tiki Lord Zim'wae"]           = "HIGH",   -- fire caster + totems
    ["Florawing Hive Queen"]        = "HIGH",   -- poison + summons
    ["Venomancer T'Kulu"]           = "HIGH",   -- poison caster
    ["Zanzili Zombie"]              = "SKIP",   -- mass zombie filler
}

db["End Time"] = {
    ["Time-Twisted Breaker"]        = "MEDIUM",
    ["Time-Twisted Drake"]          = "MEDIUM",
    ["Time-Twisted Geist"]          = "CC",     -- undead, shackleable
    ["Time-Twisted Nightsaber"]     = "CC",     -- beast, trappable
    ["Time-Twisted Priest"]         = "HIGH",   -- healer
    ["Time-Twisted Rifleman"]       = "HIGH",   -- ranged; multishot
    ["Time-Twisted Scourge Beast"]  = "MEDIUM",
    ["Time-Twisted Seer"]           = "HIGH",   -- arcane caster
    ["Time-Twisted Sorceress"]      = "HIGH",   -- frost + fire caster
    ["Infinite Warden"]             = "MEDIUM",
}

db["Well of Eternity"] = {
    ["Dreadlord Defender"]          = "HIGH",   -- shadow damage + fear
    ["Enchanted Highmistress"]      = "HIGH",   -- arcane caster
    ["Eternal Champion"]            = "MEDIUM",
    ["Eye of the Legion"]           = "HIGH",   -- shadow beam
    ["Fel Crystal"]                 = "SKIP",   -- crystal filler
    ["Legion Demon"]                = "CC",     -- demon, banishable
    ["Shadowbat"]                   = "CC",     -- beast, trappable
    ["Var'azun"]                    = "HIGH",   -- shadow caster
}

db["Hour of Twilight"] = {
    ["Twilight Assassin"]           = "HIGH",   -- stealth + garrote
    ["Twilight Bruiser"]            = "MEDIUM",
    ["Twilight Ranger"]             = "HIGH",   -- ranged + ice trap
    ["Twilight Shadow Knight"]      = "MEDIUM",
    ["Twilight Thug"]               = "MEDIUM",
    ["Faceless Brute"]              = "MEDIUM",
    ["Faceless Shadow Weaver"]      = "HIGH",   -- shadow + void
    ["Crystalline Elemental"]       = "CC",     -- elemental, banishable
    ["Frozen Servitor"]             = "LOW",
}

-- ============================================================
-- CATACLYSM RAIDS
-- ============================================================

db["Blackwing Descent"] = {
    ["Arcanotron"]                  = "HIGH",   -- Omnotron target caller
    ["Electron"]                    = "HIGH",   -- Omnotron target caller
    ["Magmatron"]                   = "HIGH",   -- Omnotron target caller
    ["Toxitron"]                    = "HIGH",   -- Omnotron target caller
    ["Aberration"]                  = "HIGH",   -- Maloriak add
    ["Prime Subject"]               = "HIGH",   -- Maloriak add
    ["Lava Parasite"]               = "HIGH",   -- Magmaw add
    ["Blazing Bone Construct"]      = "HIGH",   -- Nefarian add
    ["Animated Bone Warrior"]       = "MEDIUM",
    ["Drakonid Chainwielder"]       = "HIGH",
    ["Drakonid Drudge"]             = "MEDIUM",
    ["Drakonid Slayer"]             = "MEDIUM",
    ["Drakeadon Mongrel"]           = "MEDIUM",
    ["Golem Sentry"]                = "MEDIUM",
    ["Magmaw"]                      = "LOW",
    ["Maloriak"]                    = "LOW",
    ["Atramedes"]                   = "LOW",
    ["Chimaeron"]                   = "LOW",
    ["Nefarian"]                    = "LOW",
    ["Onyxia"]                      = "LOW",
}

db["The Bastion of Twilight"] = {
    ["Chosen Seer"]                 = "HIGH",   -- healer/caster trash
    ["Twilight Dark Mender"]        = "HIGH",   -- healer
    ["Twilight Shadow Mender"]      = "HIGH",   -- healer
    ["Twilight Elementalist"]       = "HIGH",   -- dangerous caster trash
    ["Twilight Soul Blade"]         = "HIGH",   -- dangerous melee burst
    ["Twilight Shadow Knight"]      = "MEDIUM",
    ["Twilight Brute"]              = "MEDIUM",
    ["Azureborne Destroyer"]        = "MEDIUM",
    ["Faceless Guardian"]           = "HIGH",
    ["Corrupting Adherent"]         = "HIGH",   -- Cho'gall add
    ["Darkened Creation"]           = "HIGH",   -- Cho'gall add
    ["Blood of the Old God"]        = "HIGH",   -- Cho'gall add
    ["Spiked Tentacle"]             = "HIGH",   -- Sinestra add
    ["Elementium Monstrosity"]      = "HIGH",   -- Ascendant Council fusion target
    ["Halfus Wyrmbreaker"]          = "LOW",
    ["Valiona"]                     = "LOW",
    ["Theralion"]                   = "LOW",
    ["Cho'gall"]                    = "LOW",
    ["Sinestra"]                    = "LOW",
    ["Feludius"]                    = "LOW",
    ["Ignacious"]                   = "LOW",
    ["Arion"]                       = "LOW",
    ["Terrastra"]                   = "LOW",
}

db["Throne of the Four Winds"] = {
    ["Ravenous Creeper"]            = "HIGH",   -- Anshal add
    ["Stormling"]                   = "HIGH",   -- Al'Akir add
    ["Anshal"]                      = "LOW",
    ["Nezir"]                       = "LOW",
    ["Rohash"]                      = "LOW",
    ["Al'Akir"]                     = "LOW",
}

db["Baradin Hold"] = {
    ["Disciple of Hate"]            = "HIGH",   -- Alizabal add
    ["Eye of Occu'thar"]            = "HIGH",   -- Occu'thar add
    ["Argaloth"]                    = "LOW",
    ["Occu'thar"]                   = "LOW",
    ["Alizabal"]                    = "LOW",
}

db["Firelands"] = {
    ["Flamewaker Cauterizer"]       = "HIGH",   -- healer
    ["Flamewaker Subjugator"]       = "HIGH",   -- dangerous caster
    ["Flamewaker Pathfinder"]       = "HIGH",
    ["Flamewaker Beast Handler"]    = "HIGH",
    ["Flamewaker Hound Master"]     = "HIGH",
    ["Flamewaker Animator"]         = "HIGH",
    ["Flamewaker Sentinel"]         = "MEDIUM",
    ["Flamewaker Overseer"]         = "MEDIUM",
    ["Unbound Pyrelord"]            = "HIGH",
    ["Unbound Smoldering Elemental"] = "CC",    -- elemental, banishable
    ["Molten Lord"]                 = "HIGH",
    ["Molten Surger"]               = "MEDIUM",
    ["Ancient Core Hound"]          = "CC",     -- beast, trappable
    ["Cinderweb Spinner"]           = "HIGH",
    ["Cinderweb Drone"]             = "MEDIUM",
    ["Cinderweb Spiderling"]        = "SKIP",   -- filler spiderlings
    ["Blazing Talon Initiate"]      = "HIGH",
    ["Voracious Hatchling"]         = "HIGH",
    ["Harbinger of Flame"]          = "HIGH",
    ["Druid of the Flame"]          = "HIGH",
    ["Fire Scorpion"]               = "MEDIUM",
    ["Rageface"]                    = "HIGH",   -- Shannox dog
    ["Riplimb"]                     = "HIGH",   -- Shannox dog
    ["Beth'tilac"]                  = "LOW",
    ["Alysrazor"]                   = "LOW",
    ["Baleroc"]                     = "LOW",
    ["Lord Rhyolith"]               = "LOW",
    ["Majordomo Staghelm"]          = "LOW",
    ["Ragnaros"]                    = "LOW",
    ["Shannox"]                     = "LOW",
}

db["Dragon Soul"] = {
    ["Twilight Elite Dreadblade"]   = "HIGH",
    ["Twilight Elite Slayer"]       = "HIGH",
    ["Twilight Frost Evoker"]       = "HIGH",
    ["Twilight Siege Captain"]      = "HIGH",
    ["Twilight Siege Breaker"]      = "MEDIUM",
    ["Twilight Sapper"]             = "HIGH",   -- Warmaster add
    ["Twilight Assault Drake"]      = "MEDIUM",
    ["Harbinger of Twilight"]       = "HIGH",
    ["Harbinger of Destruction"]    = "HIGH",
    ["Faceless Corruptor"]          = "HIGH",
    ["Ancient Water Lord"]          = "HIGH",
    ["Stormbinder Adept"]           = "HIGH",
    ["Stormborn Myrmidon"]          = "MEDIUM",
    ["Elementium Bolt"]             = "HIGH",
    ["Elementium Terror"]           = "HIGH",
    ["Mutated Corruption"]          = "HIGH",
    ["Wing Tentacle"]               = "HIGH",
    ["Claw of Go'rath"]             = "HIGH",
    ["Eye of Go'rath"]              = "HIGH",
    ["Flail of Go'rath"]            = "HIGH",
    ["Blistering Tentacle"]         = "HIGH",
    ["Hideous Amalgamation"]        = "HIGH",
    ["Burning Tendons"]             = "HIGH",
    ["Congealing Blood"]            = "HIGH",
    ["Morchok"]                     = "LOW",
    ["Warlord Zon'ozz"]             = "LOW",
    ["Yor'sahj the Unsleeping"]     = "LOW",
    ["Hagara the Stormbinder"]      = "LOW",
    ["Ultraxion"]                   = "LOW",
    ["Warmaster Blackhorn"]         = "LOW",
    ["Deathwing"]                   = "LOW",
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

table.insert(order, { name = "Cataclysm", zones = {
    "Blackrock Caverns", "Throne of the Tides", "The Stonecore",
    "The Vortex Pinnacle", "Lost City of the Tol'vir", "Halls of Origination",
    "Grim Batol", "Zul'Aman", "Zul'Gurub",
    "End Time", "Well of Eternity", "Hour of Twilight",
    "Blackwing Descent", "The Bastion of Twilight", "Throne of the Four Winds",
    "Baradin Hold", "Firelands", "Dragon Soul",
}})
