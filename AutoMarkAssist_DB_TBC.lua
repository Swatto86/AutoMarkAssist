-- AutoMarkAssist_DB_TBC.lua
-- The Burning Crusade dungeon and raid entries.  Loaded AFTER AutoMarkAssist_DB_Classic.lua.
-- Merges TBC dungeon and raid zones into the shared database tables.
--
-- Format:  mobName = { mark = N, creatureType = "Type", dangerLevel = N }
--   mark 8 = kill priority (Skull/Cross),  mark 1-6 = CC preference
--   dangerLevel 3 = healer / summoner / calls reinforcements (kill first)
--   dangerLevel 2 = AoE, fear, interrupt priority (high danger)
--   dangerLevel absent / 0 = standard target
--   "SKIP" = ignore this mob entirely
--   ccImmune = true for mobs immune to CC despite matching creature type

local db      = AutoMarkAssist_MobDB
local aliases = AutoMarkAssist_ZoneAliases
local order   = AutoMarkAssist_ExpansionOrder

-- ============================================================
-- THE BURNING CRUSADE DUNGEONS
-- ============================================================

-- --- Hellfire Citadel ---------------------------------

db["Hellfire Ramparts"] = {
    ["Hellfire Watcher"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer flanking Watchkeeper Gargolmar
    ["Bonechewer Beastmaster"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true },  -- summons Shattered Hand Warhounds; Poly/Trap immune
    ["Bleeding Hollow Scryer"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- fear-casting caster, comes in packs of four
    ["Bonechewer Ravener"]          = { mark = 8, creatureType = "Humanoid" },  -- Kidney Shot on the tank; snare immune
    ["Bonechewer Hungerer"]         = { mark = 8, creatureType = "Humanoid" },
    ["Hellfire Sentry"]             = { mark = 8, creatureType = "Humanoid" },  -- killing the bridge pair starts Vazruden
    ["Bonechewer Destroyer"]        = { mark = 5, creatureType = "Humanoid" },  -- Mortal Strike; prime CC target on heroic
    ["Bleeding Hollow Darkcaster"]  = { mark = 5, creatureType = "Humanoid" },  -- warlock caster; good Polymorph
    ["Shattered Hand Warhound"]     = "SKIP",  -- non-elite hounds; cleave down on the tank
}

db["The Blood Furnace"] = {
    ["Shadowmoon Summoner"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons felhound/seductress pets
    ["Shadowmoon Technician"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- proximity bombs + long silence
    ["Nascent Fel Orc"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- stuns the tank; Broggok waves and cells
    ["Felguard Annihilator"]        = { mark = 4, creatureType = "Demon", dangerLevel = 3 },  -- drops threat + Intercepts party; Banish or kill first
    ["Felguard Brute"]              = { mark = 4, creatureType = "Demon" },  -- Mortal Strike
    ["Felhound Manastalker"]        = { mark = 8, creatureType = "Demon" },  -- summoned; kill immediately
    ["Laughing Skull Warden"]       = { mark = 8, creatureType = "Humanoid" },  -- Battle Shout; hits very hard on heroic
    ["Laughing Skull Legionnaire"]  = { mark = 8, creatureType = "Humanoid" },  -- knockback melee
    ["Laughing Skull Rogue"]        = { mark = 8, creatureType = "Humanoid" },  -- stealthed; opens on rear party members
    ["Laughing Skull Enforcer"]     = { mark = 5, creatureType = "Humanoid" },
    ["Shadowmoon Adept"]            = { mark = 5, creatureType = "Humanoid" },
    ["Hellfire Imp"]                = "SKIP",  -- low HP; cleave down
    ["Fel Orc Neophyte"]            = "SKIP",  -- Broggok wave filler; AoE
}

db["The Shattered Halls"] = {
    ["Shattered Hand Legionnaire"]  = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true },  -- calls endless reinforcements until dead; kill first in every pack
    ["Shadowmoon Acolyte"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer (Heal, PW: Shield)
    ["Shattered Hand Scout"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- heroic only; sprints to trigger the archer gauntlet
    ["Shattered Hand Savage"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- attack-speed enrage; skull when no Legionnaire present
    ["Shattered Hand Sharpshooter"] = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- ranged; will not walk to the tank
    ["Shattered Hand Archer"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- gauntlet volleys
    ["Shattered Hand Assassin"]     = { mark = 8, creatureType = "Humanoid" },  -- stealthed entrance packs; Saps a party member
    ["Shattered Hand Centurion"]    = { mark = 8, creatureType = "Humanoid" },
    ["Shattered Hand Reaver"]       = { mark = 8, creatureType = "Humanoid" },  -- high-damage berserker
    ["Shattered Hand Houndmaster"]  = { mark = 8, creatureType = "Humanoid" },  -- paired with Rabid Warhounds
    ["Shadowmoon Darkcaster"]       = { mark = 5, creatureType = "Humanoid" },  -- warlock caster; Polymorph or LoS-pull
    ["Shattered Hand Heathen"]      = { mark = 5, creatureType = "Humanoid" },
    ["Shattered Hand Brawler"]      = { mark = 5, creatureType = "Humanoid" },
    ["Shattered Hand Gladiator"]    = { mark = 5, creatureType = "Humanoid" },  -- O'mrogg arena ring
    ["Shattered Hand Sentry"]       = { mark = 5, creatureType = "Humanoid" },
    ["Shattered Hand Zealot"]       = "SKIP",  -- weak Legionnaire escorts; AoE after the skull dies
    ["Rabid Warhound"]              = "SKIP",  -- non-elite hounds; cleave down first
}

-- --- Coilfang Reservoir ---------------------------------

db["The Slave Pens"] = {
    ["Coilfang Soothsayer"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Mind Control + AoE intellect drain
    ["Coilfang Scale-Healer"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Greater Heal / Holy Nova
    ["Coilfang Slavehandler"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- killing him frees the enslaved Wastewalkers
    ["Coilfang Champion"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Intimidating Shout (AoE fear)
    ["Coilfang Ray"]                = { mark = 2, creatureType = "Beast", dangerLevel = 2 },  -- Psychic Horror on non-tanks; Hibernate it
    ["Coilfang Observer"]           = { mark = 8, creatureType = "Humanoid" },  -- Immolate; escorts the Rays
    ["Coilfang Tempest"]            = { mark = 8, creatureType = "Humanoid" },  -- storm caster
    ["Coilfang Enchantress"]        = { mark = 5, creatureType = "Humanoid" },  -- frost + roots caster
    ["Coilfang Technician"]         = { mark = 5, creatureType = "Humanoid" },  -- Rain of Fire
    ["Coilfang Defender"]           = { mark = 5, creatureType = "Humanoid" },
    ["Coilfang Collaborator"]       = { mark = 5, creatureType = "Humanoid" },  -- enrages; stun or CC
    ["Wastewalker Slave"]           = "SKIP",  -- freed when the Slavehandler dies
    ["Wastewalker Worker"]          = "SKIP",
    ["Bogstrok"]                    = "SKIP",
    ["Greater Bogstrok"]            = "SKIP",
}

db["The Underbog"] = {
    ["Murkblood Healer"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Prayer of Healing heals the whole pack
    ["Underbog Lord"]               = { mark = 8, creatureType = "Giant", dangerLevel = 3 },  -- pre-Black Stalker pair; hits harder than the boss
    ["Underbog Shambler"]           = { mark = 4, creatureType = "Elemental", dangerLevel = 3 },  -- Fungal Regrowth mass heal; Banish or kill first
    ["Underbog Lurker"]             = { mark = 4, creatureType = "Elemental", dangerLevel = 2 },  -- Wild Growth: +50% physical damage
    ["Bog Giant"]                   = { mark = 8, creatureType = "Giant", dangerLevel = 2 },  -- heavy tank damage; no CC
    ["Murkblood Oracle"]            = { mark = 8, creatureType = "Humanoid" },  -- Amplify Damage caster
    ["Murkblood Spearman"]          = { mark = 5, creatureType = "Humanoid" },  -- Viper Sting mana drain
    ["Murkblood Tribesman"]         = { mark = 5, creatureType = "Humanoid" },
    ["Wrathfin Myrmidon"]           = { mark = 5, creatureType = "Humanoid" },
    ["Wrathfin Sentry"]             = { mark = 5, creatureType = "Humanoid" },
    ["Wrathfin Warrior"]            = { mark = 5, creatureType = "Humanoid" },
    -- Fen Ray is a Beast but immune to Hibernate / sleep effects (verified
    -- in-game, v3.4.13); force a kill mark so Circle never lands on one.
    ["Fen Ray"]                     = { mark = 8, creatureType = "Beast", ccImmune = true },
    ["Lykul Wasp"]                  = { mark = 8, creatureType = "Beast", ccImmune = true },  -- immune to CC
    ["Lykul Stinger"]               = { mark = 8, creatureType = "Beast", ccImmune = true },  -- immune to CC
    ["Underbat"]                    = { mark = 2, creatureType = "Beast" },
    ["Underbog Frenzy"]             = "SKIP",  -- trivial fish in the water passage
}

db["The Steamvault"] = {
    ["Coilfang Oracle"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer + instant AoE silence
    ["Coilfang Slavemaster"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- killing him frees the Dreghood slaves
    ["Bog Overlord"]                = { mark = 8, creatureType = "Giant", dangerLevel = 3 },  -- enrage + poison; brutal on heroic, no CC
    ["Coilfang Siren"]              = { mark = 5, creatureType = "Humanoid", dangerLevel = 3 },  -- instant AoE fear; Polymorph or kill first
    ["Coilfang Engineer"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- heavy AoE bombs
    ["Coilfang Water Elemental"]    = { mark = 4, creatureType = "Elemental", dangerLevel = 2 },  -- Banish; never tank two at once
    ["Tidal Surger"]                = { mark = 4, creatureType = "Elemental", dangerLevel = 2 },  -- Frost Nova + knockback; frost immune
    ["Steam Surger"]                = { mark = 4, creatureType = "Elemental" },  -- low HP; Banish or burn
    ["Coilfang Myrmidon"]           = { mark = 8, creatureType = "Humanoid" },  -- heavy cleave; face away from party
    ["Coilfang Sorceress"]          = { mark = 5, creatureType = "Humanoid" },
    ["Coilfang Warrior"]            = { mark = 5, creatureType = "Humanoid" },  -- Battle Shout
    ["Steamrigger Mechanic"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- boss adds; repair Mekgineer Steamrigger
    ["Dreghood Slave"]              = "SKIP",  -- freed when the Slavemaster dies
    ["Coilfang Leper"]              = "SKIP",
}

-- --- Auchindoun ---------------------------------

db["Mana-Tombs"] = {
    ["Ethereal Priest"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer (Heal, Holy Nova, PW: Shield)
    ["Ethereal Darkcaster"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Mana Burn drains the healer
    ["Ethereal Sorcerer"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- summons Arcane Fiends if left up
    ["Nexus Terror"]                = { mark = 8, creatureType = "Demon", dangerLevel = 2 },  -- Psychic Scream; pull solo so fears don't chain
    ["Ethereal Wraith"]             = { mark = 8, dangerLevel = 2 },  -- Spellbinder summon; Shadow Bolt Volley
    ["Ethereal Theurgist"]          = { mark = 5, creatureType = "Humanoid" },  -- Blast Wave + random Polymorph
    ["Ethereal Spellbinder"]        = { mark = 5, creatureType = "Humanoid" },  -- CC to stop the wraith summon
    ["Ethereal Crypt Raider"]       = { mark = 5, creatureType = "Humanoid" },  -- Charge; best CC target
    ["Nexus Stalker"]               = { mark = 5, creatureType = "Humanoid" },  -- Gouge swaps it onto DPS/healer
    ["Mana Leech"]                  = "SKIP",  -- explodes on death; ranged-kill spread out
    ["Arcane Fiend"]                = "SKIP",  -- summoned filler; AoE
}

db["Auchenai Crypts"] = {
    ["Auchenai Soulpriest"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- shadow priest; CC before pull prevents its spirit add
    ["Phantasmal Possessor"]        = { mark = 8, creatureType = "Undead", dangerLevel = 3 },  -- mind-controls a player; kill the instant it spawns
    ["Auchenai Necromancer"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
    ["Auchenai Monk"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true },  -- high burst; tank facing away
    ["Unliving Cleric"]             = { mark = 8, creatureType = "Undead", dangerLevel = 2 },  -- healer spirit
    ["Unliving Sorcerer"]           = { mark = 8, creatureType = "Undead" },  -- caster spirit; interrupt
    ["Auchenai Vindicator"]         = { mark = 5, creatureType = "Humanoid" },  -- CC before pull prevents its spirit add
    ["Unliving Stalker"]            = { mark = 1, creatureType = "Undead" },
    ["Unliving Soldier"]            = { mark = 1, creatureType = "Undead" },
    ["Raging Skeleton"]             = { mark = 1, creatureType = "Undead" },  -- entrance swarm; Shackle one on heroic, AoE the rest
}

db["Sethekk Halls"] = {
    ["Time-Lost Controller"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Charming Totem mind control
    ["Sethekk Ravenguard"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true },  -- enrages; burn before healing falls behind
    ["Time-Lost Scryer"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- heal + Arcane Destruction buff
    ["Sethekk Oracle"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Arcane Lightning chain silence
    ["Sethekk Shaman"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Earth Shock + summons Dark Vortex
    ["Time-Lost Shadowmage"]        = { mark = 8, creatureType = "Humanoid" },
    ["Sethekk Talon Lord"]          = { mark = 8, creatureType = "Humanoid" },  -- stuns the tank; dispel it
    ["Sethekk Prophet"]             = { mark = 5, creatureType = "Humanoid" },  -- fear; CC and kill LAST, then avoid its death spirit
    ["Sethekk Guard"]               = { mark = 5, creatureType = "Humanoid" },
    ["Sethekk Initiate"]            = { mark = 5, creatureType = "Humanoid" },  -- Spell Reflection
    ["Avian Darkhawk"]              = { mark = 2, creatureType = "Beast" },  -- Sonic Charge onto squishies
    ["Avian Ripper"]                = { mark = 2, creatureType = "Beast" },
    ["Avian Warhawk"]               = { mark = 2, creatureType = "Beast" },
    ["Cobalt Serpent"]              = { mark = 2, creatureType = "Beast" },
    ["Charming Totem"]              = "SKIP",  -- one-hit the totem; don't waste a mark
    ["Sethekk Spirit"]              = "SKIP",  -- Prophet death-spirit; run away, don't fight it
}

db["Shadow Labyrinth"] = {
    ["Cabal Shadow Priest"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Mind Flay / SW: Pain pressure
    ["Cabal Summoner"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons an Acolyte AND a Deathsworn while alive
    ["Fel Overseer"]                = { mark = 4, creatureType = "Demon", dangerLevel = 3 },  -- Mortal Strike + AoE fear; Banish on heroic
    ["Cabal Acolyte"]               = { mark = 5, creatureType = "Humanoid", dangerLevel = 3 },  -- healer; CC the whole fight or kill first
    ["Cabal Executioner"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true },  -- can one-shot non-tanks
    ["Cabal Spellbinder"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Murmur-hall channelers
    ["Malicious Instructor"]        = { mark = 8, creatureType = "Demon", dangerLevel = 2 },  -- Mark of Malice; tank facing away
    ["Cabal Deathsworn"]            = { mark = 8, creatureType = "Humanoid" },  -- Knockdown bruiser
    ["Cabal Assassin"]              = { mark = 8, creatureType = "Humanoid" },  -- stealthed patrols; kill on appearance
    ["Cabal Fanatic"]               = { mark = 6, creatureType = "Humanoid" },  -- attacks random players; trap it
    ["Cabal Zealot"]                = { mark = 5, creatureType = "Humanoid" },  -- Shape of the Beast at low HP; purge it
    ["Cabal Cultist"]               = { mark = 5, creatureType = "Humanoid" },  -- Kick; keep off the healer
    ["Cabal Ritualist"]             = { mark = 5, creatureType = "Humanoid" },  -- multi-school caster; good CC filler
}

-- --- Tempest Keep ---------------------------------

db["The Mechanar"] = {
    ["Bloodwarder Physician"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer + Anesthetic sleep
    ["Mechanar Tinkerer"]           = { mark = 8, creatureType = "Mechanical", dangerLevel = 3 },  -- netherbomb spam + suicide charge; kill instantly
    ["Sunseeker Astromage"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Fire Shield burns melee (spellsteal/purge it)
    ["Sunseeker Netherbinder"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- summons two Arcane Servants
    ["Bloodwarder Slayer"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Whirlwind + healing debuff; tank away from group
    ["Tempest-Forge Patroller"]     = { mark = 8, creatureType = "Mechanical" },  -- calls nearby mobs; pull it back
    ["Tempest-Forge Destroyer"]     = { mark = 8, creatureType = "Mechanical" },  -- Charged Smash AoE slams
    ["Mechanar Crusher"]            = { mark = 8, creatureType = "Mechanical" },
    ["Mechanar Driller"]            = { mark = 8, creatureType = "Mechanical" },
    ["Mechanar Wrecker"]            = { mark = 8, creatureType = "Mechanical" },
    ["Bloodwarder Centurion"]       = { mark = 3, creatureType = "Humanoid" },  -- Sap on pull
    ["Sunseeker Engineer"]          = { mark = 5, creatureType = "Humanoid" },
    ["Arcane Servant"]              = { mark = 4, creatureType = "Elemental" },  -- Netherbinder summon; Banish
}

db["The Botanica"] = {
    ["Bloodwarder Mender"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer; interrupt Greater Heal
    ["Sunseeker Gene-Splicer"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- lethal ground void zone
    ["Mutate Fear-Shrieker"]        = { mark = 8, dangerLevel = 3, ccImmune = true },  -- AoE fear, immune to CC
    ["Sunseeker Geomancer"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true },  -- AoE arcane; immune to CC
    ["Sunseeker Botanist"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- caster that can heal
    ["Frayer"]                      = { mark = 8, dangerLevel = 2 },  -- Geomancer escort; grows/enrages on a timer, kill first
    ["Bloodwarder Falconer"]        = { mark = 8, creatureType = "Humanoid" },  -- Multi-Shot; comes with Bloodfalcons
    ["Bloodwarder Greenkeeper"]     = { mark = 8, creatureType = "Humanoid" },  -- high-burst pairs
    ["Nethervine Trickster"]        = { mark = 8 },  -- stealthed plant; not humanoid, no Sap/Poly
    ["Nethervine Reaper"]           = { mark = 8 },
    ["Mutate Horror"]               = { mark = 8, ccImmune = true },
    ["Sunseeker Herbalist"]         = { mark = 5, creatureType = "Humanoid" },  -- Entangling Roots spam
    ["Sunseeker Researcher"]        = { mark = 5, creatureType = "Humanoid" },  -- Poison Shield (purge it)
    ["Sunseeker Chemist"]           = { mark = 5, creatureType = "Humanoid" },  -- poison cloud + frontal fire breath
    ["Sunseeker Channeler"]         = { mark = 5, creatureType = "Humanoid" },
    ["Sunseeker Harvester"]         = { mark = 5, creatureType = "Humanoid" },
    ["Bloodwarder Protector"]       = { mark = 3, creatureType = "Humanoid" },
    ["Bloodwarder Steward"]         = { mark = 3, creatureType = "Humanoid" },
    ["Bloodfalcon"]                 = "SKIP",  -- bird swarm; cleave or Hibernate
    ["Frayer Wildling"]             = "SKIP",  -- ramp filler before Laj
    ["Mutate Fleshlasher"]          = "SKIP",  -- non-elite swarm
}

db["The Arcatraz"] = {
    ["Death Watcher"]               = { mark = 8, dangerLevel = 3 },  -- at 50% applies a debuff: it must die within seconds
    ["Ethereum Life-Binder"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Skulking Witch"]              = { mark = 8, creatureType = "Demon", dangerLevel = 3 },  -- stealthed; opens on the healer
    ["Spiteful Temptress"]          = { mark = 4, creatureType = "Demon", dangerLevel = 3 },  -- Domination mind control; taunt immune, Banish it
    ["Negaton Warp-Master"]         = { mark = 4, creatureType = "Elemental", dangerLevel = 3 },  -- heals itself from shadow pools; Banish or drag it out
    ["Arcatraz Sentinel"]           = { mark = 8, creatureType = "Mechanical", dangerLevel = 2 },  -- explodes near death; taunt immune
    ["Arcatraz Defender"]           = { mark = 8, dangerLevel = 2 },  -- Flaming Weapon + Immolate; brutal on heroic
    ["Ethereum Wave-Caster"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Sonic Boom; Polymorphs on heroic
    ["Protean Nightmare"]           = { mark = 8, dangerLevel = 2 },  -- Incubation spawns adds; kill before it finishes
    ["Entropic Eye"]                = { mark = 8, dangerLevel = 2 },  -- frontal tentacle cleave + Chaos Breath
    ["Negaton Screamer"]            = { mark = 4, creatureType = "Elemental", dangerLevel = 2 },  -- fears; resists the first spell school used on it
    ["Soul Devourer"]               = { mark = 4, creatureType = "Demon" },  -- Fel Breath; face away, summons a Sightless Eye
    ["Eredar Deathbringer"]         = { mark = 4, creatureType = "Demon" },  -- AoE knockback aura
    ["Eredar Soul-Eater"]           = { mark = 4, creatureType = "Demon" },
    ["Unbound Devastator"]          = { mark = 4, creatureType = "Demon" },
    ["Unchained Doombringer"]       = { mark = 4, creatureType = "Demon" },
    ["Gargantuan Abyssal"]          = { mark = 4, creatureType = "Demon" },  -- fire AoE; stack to handle it
    ["Arcatraz Warder"]             = { mark = 5 },  -- ranged gunner; LoS-pull to the tank
    ["Ethereum Slayer"]             = { mark = 5, creatureType = "Humanoid" },
    ["Protean Horror"]              = "SKIP",  -- non-elite corpse swarm (some feign dead)
    ["Protean Spawn"]               = "SKIP",
    ["Sightless Eye"]               = "SKIP",  -- summoned; kill on sight without a mark
}

-- --- Caverns of Time ---------------------------------

db["Old Hillsbrad Foothills"] = {
    ["Durnholde Warden"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- priest: Heal, Psychic Scream, dispels your CC
    ["Tarren Mill Protector"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Flash Heal; first kill in every Tarren Mill pull
    ["Durnholde Lookout"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true },  -- runs to call reinforcements; immune to CC
    ["Infinite Defiler"]            = { mark = 8, creatureType = "Dragonkin", dangerLevel = 2 },  -- Epoch Hunter wave caster; decurse Curse of Mending
    ["Durnholde Mage"]              = { mark = 8, creatureType = "Humanoid" },
    ["Tarren Mill Lookout"]         = { mark = 8, creatureType = "Humanoid" },  -- ranged hunter
    ["Lordaeron Watchman"]          = { mark = 8, creatureType = "Humanoid" },  -- guards Thrall's lever; required kill
    ["Infinite Saboteur"]           = { mark = 8, creatureType = "Dragonkin" },  -- Shadow Step burst
    ["Durnholde Rifleman"]          = { mark = 5, creatureType = "Humanoid" },  -- Stun Shot can stun the healer
    ["Durnholde Veteran"]           = { mark = 5, creatureType = "Humanoid" },
    ["Durnholde Sentry"]            = { mark = 5, creatureType = "Humanoid" },
    ["Tarren Mill Guardsman"]       = { mark = 5, creatureType = "Humanoid" },
    ["Infinite Slayer"]             = { mark = 2, creatureType = "Dragonkin" },  -- Hibernate/Trap only (dragonkin)
    ["Durnholde Tracking Hound"]    = "SKIP",  -- non-elite dog packs; cleave
}

db["The Black Morass"] = {
    -- Every wave mob is Dragonkin: no Polymorph/Sap/Banish/Shackle.
    -- Hibernate and Freezing Trap are the only CC that works on the adds.
    ["Rift Keeper"]                 = { mark = 8, creatureType = "Dragonkin", dangerLevel = 3 },  -- portal guardian (caster); burn to close the rift
    ["Rift Lord"]                   = { mark = 8, creatureType = "Dragonkin", dangerLevel = 3 },  -- portal guardian (melee); MS/knockback or Thunderclap
    ["Infinite Assassin"]           = { mark = 8, creatureType = "Dragonkin", dangerLevel = 2 },  -- stealthed; beelines for Medivh
    ["Infinite Chronomancer"]       = { mark = 8, creatureType = "Dragonkin", dangerLevel = 1 },  -- Sleep caster; hurts Medivh's shield from range
    ["Infinite Vanquisher"]         = { mark = 8, creatureType = "Dragonkin", dangerLevel = 1 },  -- strongest add (waves 13+)
    ["Infinite Executioner"]        = { mark = 8, creatureType = "Dragonkin" },
    ["Infinite Whelp"]              = "SKIP",  -- non-elite packs of three; AoE at Medivh
}

-- --- Isle of Quel'Danas ---------------------------------

db["Magisters' Terrace"] = {
    ["Sunblade Blood Knight"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Holy Light healer; kill or hard-CC every time
    ["Sister of Torment"]           = { mark = 4, creatureType = "Demon", dangerLevel = 3 },  -- Deadly Embrace mind control; Banish or kill first
    ["Ethereum Smuggler"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- teleports to players + Arcane Explosion; ignores the tank
    ["Sunblade Sentinel"]           = { mark = 8, creatureType = "Demon", dangerLevel = 2, ccImmune = true },  -- fel construct; chain Fel Lightning
    ["Sunblade Warlock"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Incinerate; dispel Immolate, cleave its imp
    ["Sunblade Magister"]           = { mark = 8, creatureType = "Humanoid" },  -- arcane burst caster
    ["Sunblade Slayer"]             = { mark = 8, creatureType = "Humanoid" },  -- ranged physical
    ["Coilskar Witch"]              = { mark = 5, creatureType = "Humanoid" },  -- Forked Lightning; CC or LoS-pull
    ["Sunblade Mage Guard"]         = { mark = 5, creatureType = "Humanoid" },  -- Glaive Throw + caster-silencing field; comes to the tank
    ["Sunblade Imp"]                = "SKIP",  -- non-elite; cleave instantly
    ["Wretched Skulker"]            = "SKIP",
    ["Wretched Bruiser"]            = "SKIP",
    ["Wretched Husk"]               = "SKIP",
    ["Brightscale Wyrm"]            = "SKIP",  -- garden filler; gather and AoE
}

-- ============================================================
-- THE BURNING CRUSADE RAIDS
-- ============================================================

db["Karazhan"] = {
    ["Arcane Anomaly"]              = { mark = 8, creatureType = "Elemental" },
    ["Astral Flare"]                = { mark = 8, creatureType = "Elemental" },
    ["Chaotic Sentience"]           = { mark = 8, creatureType = "Demon" },
    ["Conjured Water Elemental"]    = { mark = 8, creatureType = "Elemental" },
    ["Doomguard"]                   = { mark = 8, creatureType = "Demon" },
    ["Ethereal Spellfilcher"]       = { mark = 8, creatureType = "Humanoid" },
    ["Ethereal Thief"]              = { mark = 8, creatureType = "Humanoid" },
    ["Ghastly Haunt"]               = { mark = 8, creatureType = "Undead" },
    ["Human Cleric"]                = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Human Conjurer"]              = { mark = 8, creatureType = "Humanoid" },
    ["Kil'rek"]                     = { mark = 8, creatureType = "Demon" },
    ["Mana Warp"]                   = { mark = 8, creatureType = "Elemental" },
    ["Orc Necrolyte"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer; Shadow Mend
    ["Orc Warlock"]                 = { mark = 8, creatureType = "Humanoid" },
    ["Sorcerous Shade"]             = { mark = 8, creatureType = "Undead" },
    ["Spell Shade"]                 = { mark = 8, creatureType = "Undead" },
    ["Spectral Apprentice"]         = { mark = 8, creatureType = "Undead" },
    ["Spectral Servant"]            = { mark = 8, creatureType = "Undead" },
    ["Zealous Consort"]             = { mark = 8, creatureType = "Undead" },
    ["Zealous Paramour"]            = { mark = 8, creatureType = "Undead" },
    ["Coldmist Stalker"]            = { mark = 5, creatureType = "Undead" },
    ["Coldmist Widow"]              = { mark = 5, creatureType = "Beast" },
    ["Mana Feeder"]                 = { mark = 5, creatureType = "Elemental" },
    ["Phase Hound"]                 = { mark = 5, creatureType = "Beast" },
    ["Shadowbat"]                   = { mark = 5, creatureType = "Beast" },
    ["Vampiric Shadowbat"]          = { mark = 5, creatureType = "Beast" },
    ["Dancing Flames"]              = "SKIP",
    ["Rat"]                         = "SKIP",
    ["Spider"]                      = "SKIP",
}

db["Gruul's Lair"] = {
    ["Blindeye the Seer"]           = { mark = 8, creatureType = "Giant", dangerLevel = 3 },     -- healer; Prayer of Healing
    ["Kiggler the Crazed"]          = { mark = 8, creatureType = "Giant" },
    ["Krosh Firehand"]              = { mark = 8, creatureType = "Giant" },
    ["Olm the Summoner"]            = { mark = 8, creatureType = "Giant", dangerLevel = 3 },     -- summons felhunters; Death Coil fear
    ["Gronn-Priest"]                = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Wild Fel Stalker"]            = { mark = 5, creatureType = "Demon" },
}

db["Magtheridon's Lair"] = {
    ["Hellfire Channeler"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- channels Magtheridon; must die simultaneously
    ["Burning Abyssal"]             = { mark = 5, creatureType = "Elemental" },
}

db["Serpentshrine Cavern"] = {
    ["Coilfang Ambusher"]           = { mark = 8, creatureType = "Humanoid" },
    ["Coilfang Beast-Tamer"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons and controls beasts
    ["Coilfang Fathom-Witch"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- frost/shadow AoE
    ["Coilfang Hate-Screamer"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- fear screech
    ["Coilfang Priestess"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Fathom-Guard Caribdis"]       = { mark = 8, creatureType = "Humanoid" },
    ["Fathom-Guard Sharkkis"]       = { mark = 8, creatureType = "Humanoid" },
    ["Fathom-Guard Tidalvess"]      = { mark = 8, creatureType = "Humanoid" },
    ["Greyheart Nether-Mage"]       = { mark = 8, creatureType = "Humanoid" },
    ["Greyheart Spellbinder"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- spell-binds/interrupts casters
    ["Greyheart Technician"]        = { mark = 8, creatureType = "Humanoid" },
    ["Greyheart Tidecaller"]        = { mark = 8, creatureType = "Humanoid" },
    ["Serpentshrine Tidecaller"]    = { mark = 8, creatureType = "Humanoid" },
    ["Tainted Elemental"]           = { mark = 8, creatureType = "Elemental" },
    ["Tainted Water Elemental"]     = { mark = 8, creatureType = "Elemental" },
    ["Tidewalker Depth-Seer"]       = { mark = 8, creatureType = "Humanoid" },
    ["Tidewalker Hydromancer"]      = { mark = 8, creatureType = "Humanoid" },
    ["Tidewalker Shaman"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Coilfang Frenzy"]             = { mark = 5, creatureType = "Beast" },
    ["Coilfang Strider"]            = { mark = 5, creatureType = "Beast" },
    ["Fathom Sporebat"]             = { mark = 5, creatureType = "Beast" },
    ["Serpentshrine Sporebat"]      = { mark = 5, creatureType = "Beast" },
}

db["The Eye"] = {
    ["Astromancer"]                 = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- AoE arcane caster
    ["Astromancer Lord"]            = { mark = 8, creatureType = "Humanoid" },
    ["Bloodwarder Vindicator"]      = { mark = 8, creatureType = "Humanoid" },
    ["Cosmic Infuser"]              = { mark = 8, creatureType = "Mechanical" },
    ["Crimson Hand Battle Mage"]    = { mark = 8, creatureType = "Humanoid" },
    ["Crimson Hand Blood Knight"]   = { mark = 8, creatureType = "Humanoid" },
    ["Crimson Hand Inquisitor"]     = { mark = 8, creatureType = "Humanoid" },
    ["Crystalcore Mechanic"]        = { mark = 8, creatureType = "Humanoid" },
    ["Grand Astromancer Capernian"] = { mark = 8, creatureType = "Humanoid" },
    ["Infinity Blade"]              = { mark = 8, creatureType = "Mechanical" },
    ["Master Engineer Telonicus"]   = { mark = 8, creatureType = "Humanoid" },
    ["Nether Scryer"]               = { mark = 8, creatureType = "Humanoid" },
    ["Netherstrand Longbow"]        = { mark = 8, creatureType = "Mechanical" },
    ["Novice Astromancer"]          = { mark = 8, creatureType = "Humanoid" },
    ["Phaseshift Bulwark"]          = { mark = 8, creatureType = "Mechanical" },
    ["Phoenix Egg"]                 = { mark = 8, creatureType = "Elemental" },
    ["Solarium Priest"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Staff of Disintegration"]     = { mark = 8, creatureType = "Mechanical" },
    ["Star Scryer"]                 = { mark = 8, creatureType = "Humanoid" },
    ["Tempest Falconer"]            = { mark = 8, creatureType = "Humanoid" },
    ["Tempest-Smith"]               = { mark = 8, creatureType = "Humanoid" },
    ["Thaladred the Darkener"]      = { mark = 8, creatureType = "Humanoid" },
    ["Warp Slicer"]                 = { mark = 8, creatureType = "Mechanical" },
    ["Phoenix-Hawk"]                = { mark = 5, creatureType = "Beast" },
    ["Phoenix-Hawk Hatchling"]      = { mark = 5, creatureType = "Beast" },
}

db["Hyjal Summit"] = {
    ["Banshee"]                     = { mark = 8, creatureType = "Undead", dangerLevel = 2 },    -- fear wail + silence
    ["Frost Wyrm"]                  = { mark = 8, creatureType = "Undead" },
    ["Giant Infernal"]              = { mark = 8, creatureType = "Demon" },
    ["Lesser Doomguard"]            = { mark = 8, creatureType = "Demon" },
    ["Necromancer"]                 = { mark = 8, creatureType = "Undead", dangerLevel = 3 },    -- raises dead adds
}

db["Black Temple"] = {
    ["Ashtongue Elementalist"]      = { mark = 8, creatureType = "Humanoid" },
    ["Ashtongue Mystic"]            = { mark = 8, creatureType = "Humanoid" },
    ["Ashtongue Primalist"]         = { mark = 8, creatureType = "Humanoid" },
    ["Ashtongue Sorcerer"]          = { mark = 8, creatureType = "Humanoid" },
    ["Ashtongue Spiritbinder"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- spirit binding; heals allies
    ["Ashtongue Stormcaller"]       = { mark = 8, creatureType = "Humanoid" },
    ["Bonechewer Blood Prophet"]    = { mark = 8, creatureType = "Humanoid" },
    ["Bonechewer Taskmaster"]       = { mark = 8, creatureType = "Humanoid" },
    ["Coilskar Sea-Caller"]         = { mark = 8, creatureType = "Humanoid" },
    ["Coilskar Soothsayer"]         = { mark = 8, creatureType = "Humanoid" },
    ["Dragonmaw Wyrmcaller"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons drakes
    ["Flame of Azzinoth"]           = { mark = 8, creatureType = "Demon" },
    ["Hand of Gorefiend"]           = { mark = 8, creatureType = "Undead" },
    ["Illidari Archon"]             = { mark = 8, creatureType = "Humanoid" },
    ["Illidari Assassin"]           = { mark = 8, creatureType = "Humanoid" },
    ["Illidari Battle-mage"]        = { mark = 8, creatureType = "Humanoid" },
    ["Illidari Blood Lord"]         = { mark = 8, creatureType = "Humanoid" },
    ["Illidari Fearbringer"]        = { mark = 8, creatureType = "Demon", dangerLevel = 2 },     -- fear
    ["Illidari Nightlord"]          = { mark = 8, creatureType = "Humanoid" },
    ["Shadowmoon Blood Mage"]       = { mark = 8, creatureType = "Humanoid" },
    ["Shadowmoon Deathshaper"]      = { mark = 8, creatureType = "Humanoid" },
    ["Shadowmoon Houndmaster"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons riding hounds
    ["Temple Acolyte"]              = { mark = 8, creatureType = "Humanoid" },
    ["Aqueous Spawn"]               = { mark = 5, creatureType = "Elemental" },
    ["Aqueous Surger"]              = { mark = 5, creatureType = "Elemental" },
    ["Leviathan"]                   = { mark = 5, creatureType = "Beast" },
    ["Mutant War Hound"]            = { mark = 5, creatureType = "Beast" },
    ["Shadowmoon Riding Hound"]     = { mark = 5, creatureType = "Beast" },
    ["Storm Fury"]                  = { mark = 5, creatureType = "Elemental" },
}

db["Zul'Aman"] = {
    ["Amani Healing Ward"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Amani Protective Ward"]       = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Beast Tamer"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- beast caller
    ["Amani'shi Flame Caster"]      = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Handler"]           = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Hatcher"]           = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Medicine Man"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer + hex
    ["Amani'shi Scout"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- calls reinforcements
    ["Amani'shi Tempest"]           = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Warbringer"]        = { mark = 8, creatureType = "Humanoid" },
    ["Amani'shi Wind Walker"]       = { mark = 8, creatureType = "Humanoid" },
    ["Darkheart"]                   = { mark = 8, creatureType = "Beast" },
    ["Gazakroth"]                   = { mark = 8, creatureType = "Demon" },
    ["Koragg"]                      = { mark = 8, creatureType = "Humanoid" },
    ["Lord Raadan"]                 = { mark = 8, creatureType = "Beast" },
    ["Amani Bear"]                  = { mark = 5, creatureType = "Beast" },
    ["Amani Bear Mount"]            = { mark = 5, creatureType = "Beast" },
    ["Amani Dragonhawk"]            = { mark = 5, creatureType = "Beast" },
    ["Amani Elder Lynx"]            = { mark = 5, creatureType = "Beast" },
    ["Amani Lynx"]                  = { mark = 5, creatureType = "Beast" },
    ["Slither"]                     = { mark = 5, creatureType = "Beast" },
    ["Soaring Eagle"]               = { mark = 5, creatureType = "Beast" },
    ["Forest Frog"]                 = "SKIP",
}

db["Sunwell Plateau"] = {
    ["Apocalypse Guard"]            = { mark = 8, creatureType = "Demon" },
    ["Chaos Gazer"]                 = { mark = 8, creatureType = "Demon" },
    ["Doomfire Destroyer"]          = { mark = 8, creatureType = "Demon" },
    ["Hand of the Deceiver"]        = { mark = 8, creatureType = "Humanoid" },
    ["Oblivion Mage"]               = { mark = 8, creatureType = "Humanoid" },
    ["Painbringer"]                 = { mark = 8, creatureType = "Demon" },
    ["Priestess of Torment"]        = { mark = 8, creatureType = "Demon" },
    ["Shield Orb"]                  = { mark = 8, creatureType = "Demon" },
    ["Shadowsword Assassin"]        = { mark = 8, creatureType = "Humanoid" },
    ["Shadowsword Deathbringer"]    = { mark = 8, creatureType = "Humanoid" },
    ["Shadowsword Fury Mage"]       = { mark = 8, creatureType = "Humanoid" },
    ["Shadowsword Lifeshaper"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Shadowsword Manafiend"]       = { mark = 8, creatureType = "Humanoid" },
    ["Shadowsword Soulbinder"]      = { mark = 8, creatureType = "Humanoid" },
    ["Sinister Reflection"]         = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Arch Mage"]          = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Cabalist"]           = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Dawn Priest"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Sunblade Dusk Priest"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
    ["Sunblade Scout"]              = { mark = 8, creatureType = "Humanoid" },
    ["Sunblade Vindicator"]         = { mark = 8, creatureType = "Humanoid" },
    ["Void Sentinel"]               = { mark = 8, creatureType = "Demon" },
    ["Cataclysm Hound"]             = { mark = 5, creatureType = "Demon" },
    ["Sunblade Dragonhawk"]         = { mark = 5, creatureType = "Beast" },
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
