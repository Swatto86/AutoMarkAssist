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
-- Trash rosters verified against the Wowhead TBC Classic database,
-- 2.4.3 creature data (types + CC-immunity masks), Wowpedia and
-- Icy Veins TBC dungeon guides.  Bosses and boss-event adds are
-- excluded.  Heroic-only CC immunities are noted in comments; the
-- runtime immunity learner picks those up on first failed CC.
-- ============================================================

-- --- Hellfire Citadel ---------------------------------

db["Hellfire Ramparts"] = {
    ["Bonechewer Beastmaster"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true },  -- calls Warhound reinforcements; cannot be CC'd
    ["Bonechewer Destroyer"]        = { mark = 5, creatureType = "Humanoid" },                 -- Mortal Strike; ideal CC target
    ["Bonechewer Hungerer"]         = { mark = 5, creatureType = "Humanoid" },                 -- Demoralizing Shout, Disarm
    ["Bonechewer Ravener"]          = { mark = 5, creatureType = "Humanoid" },                 -- Kidney Shot; Sap/Poly
    ["Bleeding Hollow Scryer"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- chain Fear + Shadow Bolt; packs of 4
    ["Bleeding Hollow Darkcaster"]  = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Rain of Fire AoE
    ["Bleeding Hollow Archer"]      = { mark = 8, creatureType = "Humanoid" },                 -- ranged turret; LoS-pull
    ["Hellfire Watcher"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Gargolmar's healers; Heal + Renew
    ["Hellfire Sentry"]             = { mark = 5, creatureType = "Humanoid" },                 -- Kidney Shot on tank
    ["Shattered Hand Warhound"]     = "SKIP",                                                  -- non-elite swarm; AoE down
}

db["The Blood Furnace"] = {
    ["Shadowmoon Summoner"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons felhounds; interrupt
    ["Shadowmoon Warlock"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Fel Power buffs Felguards +350% dmg
    ["Shadowmoon Adept"]            = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Kick; heavy tank damage; CC one
    ["Shadowmoon Technician"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- explosive charges AoE
    ["Laughing Skull Legionnaire"]  = { mark = 5, creatureType = "Humanoid" },                 -- knockback; CC works (unlike SH Legionnaire)
    ["Laughing Skull Enforcer"]     = { mark = 5, creatureType = "Humanoid" },
    ["Laughing Skull Rogue"]        = { mark = 8, creatureType = "Humanoid" },                 -- stealth ambusher
    ["Laughing Skull Warden"]       = { mark = 8, creatureType = "Humanoid" },                 -- sees through stealth
    ["Felguard Brute"]              = { mark = 4, creatureType = "Demon", dangerLevel = 2 },   -- Banish; hits ~1k
    ["Felguard Annihilator"]        = { mark = 4, creatureType = "Demon", dangerLevel = 2 },   -- Banish; Intercepts party members
    ["Nascent Fel Orc"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Concussion Blow + Stomp; snare-immune
    ["Fel Orc Neophyte"]            = "SKIP",                                                  -- Broggok gauntlet waves; AoE
    ["Felhound Manastalker"]        = "SKIP",                                                  -- summoned add; kill on spawn
    ["Seductress"]                  = "SKIP",                                                  -- summoned add; kill on spawn
}

db["The Shattered Halls"] = {
    ["Shattered Hand Legionnaire"]  = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true },  -- endless reinforcements until dead; CC/slow-immune
    ["Shadowmoon Acolyte"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- PW:Shield + heals; interrupt
    ["Shattered Hand Assassin"]     = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- stealth; Saps the tank on engage
    ["Shattered Hand Savage"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Slice and Dice + Enrage
    ["Shattered Hand Sharpshooter"] = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Scatter Shot + Incendiary; priority CC
    ["Shattered Hand Gladiator"]    = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true },  -- Mortal Strike; immune to CC (fear/slows only)
    ["Shattered Hand Champion"]     = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true },  -- heavy melee pairs; CC-immune
    ["Shattered Hand Centurion"]    = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true },  -- Sunder + Battle Shout; CC-immune
    ["Shattered Hand Houndmaster"]  = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Volley AoE; comes with warhounds
    ["Shattered Hand Archer"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- gauntlet; flame arrows + ground fire
    ["Shattered Hand Blood Guard"]  = { mark = 8, creatureType = "Humanoid" },                 -- Cleave; face away
    ["Shattered Hand Heathen"]      = { mark = 5, creatureType = "Humanoid" },                 -- hits hard; good Poly/Trap target
    ["Shattered Hand Brawler"]      = { mark = 5, creatureType = "Humanoid" },                 -- Kick; Sap target
    ["Shattered Hand Reaver"]       = { mark = 5, creatureType = "Humanoid" },                 -- Cleave + Uppercut
    ["Shattered Hand Sentry"]       = { mark = 5, creatureType = "Humanoid" },
    ["Shattered Hand Executioner"]  = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Heroic prisoner event; kill on timer
    ["Shattered Hand Scout"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- sprints off to trigger the archer gauntlet; stop it
    ["Shattered Hand Zealot"]       = "SKIP",                                                  -- gauntlet waves; AoE while pushing
    ["Fel Orc Convert"]             = "SKIP",                                                  -- Legionnaire reinforcements; cleave down
    ["Rabid Warhound"]              = "SKIP",                                                  -- non-elite; DPS kills fast
}

-- --- Coilfang Reservoir ---------------------------------

db["The Slave Pens"] = {
    ["Coilfang Scale-Healer"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Holy Nova heal/damage spam
    ["Coilfang Soothsayer"]         = { mark = 5, creatureType = "Humanoid", dangerLevel = 3 },  -- mind controls; keep CC'd to the end
    ["Coilfang Ray"]                = { mark = 2, creatureType = "Beast", dangerLevel = 2 },   -- fears a party member; Hibernate it
    ["Coilfang Champion"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true },  -- Intimidating Shout AoE fear; must be tanked
    ["Coilfang Defender"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true },  -- Spell Shield (reflects magic); must be tanked
    ["Coilfang Enchantress"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Lightning Cloud AoE + roots
    ["Coilfang Technician"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Rain of Fire
    ["Coilfang Slavehandler"]       = { mark = 8, creatureType = "Humanoid" },                 -- kill first: Wastewalkers de-aggro on death
    ["Coilfang Observer"]           = { mark = 5, creatureType = "Humanoid" },                 -- Immolate; escorts Rays
    ["Coilfang Collaborator"]       = { mark = 5, creatureType = "Humanoid" },                 -- Cripple + Enrage
    ["Bogstrok"]                    = "SKIP",                                                  -- trivial entrance trash
    ["Greater Bogstrok"]            = "SKIP",
    ["Wastewalker Slave"]           = "SKIP",                                                  -- de-aggros when Slavehandler dies
    ["Wastewalker Worker"]          = "SKIP",
}

db["The Underbog"] = {
    ["Murkblood Healer"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Prayer of Healing; interrupt
    ["Underbog Shambler"]           = { mark = 8, creatureType = "Elemental", dangerLevel = 3 },  -- Fungal Regrowth ally HoT; interrupt or Banish
    ["Underbog Lurker"]             = { mark = 8, creatureType = "Elemental", dangerLevel = 2 },  -- Wild Growth damage buff until 75% HP; Banishable
    ["Murkblood Oracle"]            = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Fireball caster; easiest CC; flees at 15%
    ["Murkblood Spearman"]          = { mark = 5, creatureType = "Humanoid" },                 -- ranged spears + Viper Sting
    ["Murkblood Tribesman"]         = { mark = 5, creatureType = "Humanoid" },
    ["Bog Giant"]                   = { mark = 8, creatureType = "Giant", ccImmune = true },   -- heavy tank damage; immune to nearly all CC
    ["Underbog Lord"]               = { mark = 8, creatureType = "Giant", dangerLevel = 2, ccImmune = true },  -- hits harder than the boss; Knock Away
    ["Fen Ray"]                     = { mark = 8, creatureType = "Beast", dangerLevel = 2, ccImmune = true },  -- Psychic Horror fear; immune to Hibernate/sleep
    ["Underbat"]                    = { mark = 2, creatureType = "Beast" },
    ["Lykul Wasp"]                  = { mark = 8 },                                            -- uncategorized type; no CC applies
    ["Lykul Stinger"]               = { mark = 8 },                                            -- uncategorized type; attack-speed frenzy
    ["Wrathfin Myrmidon"]           = { mark = 5, creatureType = "Humanoid" },
    ["Wrathfin Sentry"]             = { mark = 5, creatureType = "Humanoid" },                 -- Shield Bash interrupt
    ["Wrathfin Warrior"]            = { mark = 5, creatureType = "Humanoid" },
    ["Underbog Frenzy"]             = "SKIP",                                                  -- water piranhas; stay out of deep water
}

db["The Steamvault"] = {
    ["Coilfang Siren"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- instant AoE Fear; top kill priority
    ["Coilfang Oracle"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Heal + Sonic Burst; interrupt
    ["Coilfang Slavemaster"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- kill first: Dreghood Slaves leave combat
    ["Steamrigger Mechanic"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- repairs Mekgineer Steamrigger 25%; kill instantly
    ["Coilfang Sorceress"]          = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Frost Nova + Blizzard
    ["Coilfang Engineer"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- thrown Bomb AoE + Net
    ["Coilfang Myrmidon"]           = { mark = 5, creatureType = "Humanoid" },                 -- Cleave + Execute; face away
    ["Coilfang Warrior"]            = { mark = 5, creatureType = "Humanoid" },                 -- Mortal Blow on tank
    ["Bog Overlord"]                = { mark = 8, creatureType = "Giant", dangerLevel = 2, ccImmune = true },  -- mini-boss hits; immune to all CC
    ["Tidal Surger"]                = { mark = 4, creatureType = "Elemental", dangerLevel = 2 },  -- Frost Nova + knockback; Banish
    ["Coilfang Water Elemental"]    = { mark = 4, creatureType = "Elemental", dangerLevel = 2 },  -- Water Bolt Volley AoE; Banish
    ["Steam Surger"]                = { mark = 4, creatureType = "Elemental" },                -- non-elite packs; Banish one or AoE
    ["Second Fragment Guardian"]    = { mark = 8, creatureType = "Beast" },                    -- Heroic Karazhan key event spawn
    ["Dreghood Slave"]              = "SKIP",                                                  -- de-aggro when Slavemaster dies
    ["Coilfang Leper"]              = "SKIP",                                                  -- weak swarm casters; AoE, catch runners
    ["Naga Distiller"]              = "SKIP",                                                  -- Kalithresh fight mechanic only
}

-- --- Auchindoun ---------------------------------

db["Mana-Tombs"] = {
    ["Ethereal Priest"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Heal + Holy Nova; interrupt
    ["Ethereal Spellbinder"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons Ethereal Wraith; Counterspell
    ["Ethereal Darkcaster"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Mana Burn; wipes healer mana
    ["Ethereal Theurgist"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Polymorphs party + Blast Wave; summons on Heroic
    ["Nexus Terror"]                = { mark = 8, creatureType = "Demon", dangerLevel = 2, ccImmune = true },  -- AoE Psychic Scream; Banish-IMMUNE despite Demon type
    ["Ethereal Sorcerer"]           = { mark = 5, creatureType = "Humanoid" },                 -- Arcane Missiles; easy CC
    ["Ethereal Crypt Raider"]       = { mark = 5, creatureType = "Humanoid" },                 -- Charge + Enrage
    ["Ethereal Scavenger"]          = { mark = 5, creatureType = "Humanoid" },
    ["Nexus Stalker"]               = { mark = 8, creatureType = "Humanoid" },                 -- stealth; jumps casters
    ["Ethereal Wraith"]             = { mark = 4, creatureType = "Elemental", dangerLevel = 2 },  -- Spellbinder summon; Shadow Bolt Volley; Banish
    ["Mana Leech"]                  = "SKIP",                                                  -- swarm; Arcane Explosion on death
}

db["Auchenai Crypts"] = {
    ["Phantasmal Possessor"]        = { mark = 8, creatureType = "Undead", dangerLevel = 3, ccImmune = true },  -- mind controls until victim at 50% HP; even Shackle-immune
    ["Auchenai Soulpriest"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons a spirit add; Falter AoE
    ["Auchenai Necromancer"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Shadow Mend heal + Seed of Corruption; interrupt
    ["Auchenai Vindicator"]         = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- summons a spirit add; Shadowguard
    ["Auchenai Monk"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true },  -- Polymorph/Banish-immune (Sap and stuns still land)
    ["Phasing Cleric"]              = { mark = 8, creatureType = "Undead", dangerLevel = 3 },  -- Major Heal; Shackle or kill first
    ["Phasing Sorcerer"]            = { mark = 1, creatureType = "Undead", dangerLevel = 2 },  -- Blast Wave AoE; Shackle
    ["Phasing Soldier"]             = { mark = 1, creatureType = "Undead" },
    ["Phasing Stalker"]             = { mark = 1, creatureType = "Undead" },                   -- ranged; LoS-pull
    ["Unliving Cleric"]             = { mark = 8, creatureType = "Undead", dangerLevel = 3 },  -- summoned healer; kill first
    ["Unliving Sorcerer"]           = { mark = 1, creatureType = "Undead", dangerLevel = 2 },  -- summoned; Blast Wave
    ["Unliving Soldier"]            = { mark = 1, creatureType = "Undead" },
    ["Unliving Stalker"]            = { mark = 1, creatureType = "Undead" },
    ["Raging Skeleton"]             = { mark = 1, creatureType = "Undead" },                   -- assembles from bone piles
    ["Angered Skeleton"]            = { mark = 1, creatureType = "Undead" },
    ["Reanimated Bones"]            = "SKIP",                                                  -- huge low-HP swarms; AoE
    ["Raging Soul"]                 = "SKIP",                                                  -- charges in and despawns; CC-immune
}

db["Sethekk Halls"] = {
    ["Sethekk Shaman"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons Dark Vortex; interrupt
    ["Time-Lost Controller"]        = { mark = 8, creatureType = "Undead", dangerLevel = 3 },  -- summons mind-control totem; kill first
    ["Time-Lost Scryer"]            = { mark = 8, creatureType = "Undead", dangerLevel = 3 },  -- Flash Heal 6k; Shackle or kill
    ["Time-Lost Shadowmage"]        = { mark = 1, creatureType = "Undead", dangerLevel = 2 },  -- shadow caster; Shackle
    ["Sethekk Ravenguard"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Bloodthirst + Enrage; CC-immune on Heroic
    ["Sethekk Talon Lord"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Avenger's Shield stun/silence on tank
    ["Sethekk Prophet"]             = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- AoE Fear; Poly and kill LAST (death spawns spirit)
    ["Sethekk Oracle"]              = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Arcane Lightning chain
    ["Cobalt Serpent"]              = { mark = 8, creatureType = "Beast", dangerLevel = 2 },   -- chain lightning; Hibernate Normal only (Heroic CC-immune)
    ["Sethekk Guard"]               = { mark = 5, creatureType = "Humanoid" },                 -- Thunderclap; CC Normal only (Heroic Poly-immune)
    ["Sethekk Initiate"]            = { mark = 5, creatureType = "Humanoid" },                 -- Spell Reflection
    ["Avian Darkhawk"]              = { mark = 2, creatureType = "Beast" },
    ["Avian Warhawk"]               = { mark = 2, creatureType = "Beast" },
    ["Dark Vortex"]                 = { mark = 4, creatureType = "Elemental" },                -- Shaman summon; Banish
    ["Avian Ripper"]                = "SKIP",                                                  -- low-HP swarm; AoE
    ["Charming Totem"]              = "SKIP",                                                  -- kill instantly; trivial HP, don't waste a mark
    ["Sethekk Spirit"]              = "SKIP",                                                  -- Prophet death-spirit; untargetable, run away
}

db["Shadow Labyrinth"] = {
    ["Cabal Acolyte"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- 10-12k heals; kill first or Poly
    ["Cabal Summoner"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons Acolyte/Deathsworn; interrupt
    ["Cabal Spellbinder"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Brain Wash mind control; interrupt
    ["Cabal Executioner"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Whirlwind + Execute; first melee kill
    ["Cabal Fanatic"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Fixates random target; can't be tanked
    ["Cabal Ritualist"]             = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- multi-school caster + Dispel Magic
    ["Cabal Shadow Priest"]         = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Mind Flay/SW:P (no heals)
    ["Cabal Warlock"]               = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Seed of Corruption AoE
    ["Cabal Assassin"]              = { mark = 8, creatureType = "Humanoid" },                 -- stealth ambushes near entrance
    ["Cabal Cultist"]               = { mark = 5, creatureType = "Humanoid" },
    ["Cabal Deathsworn"]            = { mark = 5, creatureType = "Humanoid" },                 -- Black Cleave; face away
    ["Cabal Zealot"]                = { mark = 5, creatureType = "Humanoid" },                 -- Poly before it shapeshifts
    ["Fel Overseer"]                = { mark = 8, creatureType = "Demon", dangerLevel = 2, ccImmune = true },  -- mini-boss; AoE fear + Mortal Strike; pull alone
    ["Malicious Instructor"]        = { mark = 8, creatureType = "Demon", dangerLevel = 2, ccImmune = true },  -- mini-boss; Shadow Nova AoE
    ["Maiden of Discipline"]        = { mark = 4, creatureType = "Demon", dangerLevel = 2 },   -- Seduction; Banish
    ["Fel Guardhound"]              = { mark = 4, creatureType = "Demon" },                    -- Spell Lock on casters; Banish
    ["Cabal Familiar"]              = "SKIP",                                                  -- non-elite imps; AoE
    ["Tortured Skeleton"]           = "SKIP",                                                  -- bone-pile swarm before Murmur
}

-- --- Tempest Keep ---------------------------------

db["The Botanica"] = {
    ["Bloodwarder Mender"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Greater Heal 9-11k; kill first or Poly
    ["Sunseeker Botanist"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Regrowth + heals plant mobs
    ["Bloodwarder Falconer"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- commands Bloodfalcon pets
    ["Sunseeker Harvester"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Polymorphs party; summons Fleshlashers
    ["Sunseeker Herbalist"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons Fleshlashers
    ["Bloodwarder Steward"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Arcane Flurry melee burst
    ["Sunseeker Channeler"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- channeled beam + AoE aura pulse
    ["Sunseeker Geomancer"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Arcane Explosion; CC-immune on Heroic
    ["Sunseeker Gene-Splicer"]      = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Death and Decay AoE
    ["Sunseeker Chemist"]           = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- poison cloud + fire-breath cone
    ["Sunseeker Researcher"]        = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- shock rotation caster
    ["Bloodwarder Greenkeeper"]     = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Impending Coma sleep
    ["Bloodwarder Protector"]       = { mark = 5, creatureType = "Humanoid" },                 -- Intervene + Spell Reflection
    ["Tempest-Forge Peacekeeper"]   = { mark = 8, creatureType = "Mechanical", dangerLevel = 2, ccImmune = true },  -- arcane golem; AoE volleys
    ["Mutate Fear-Shrieker"]        = { mark = 8, creatureType = "Beast", dangerLevel = 2, ccImmune = true },  -- AoE Fear; Poly/Hibernate-immune (only Trap/stuns land)
    ["Mutate Horror"]               = { mark = 8, creatureType = "Beast", ccImmune = true },   -- Corrode Armor; Poly/Hibernate-immune
    ["Nethervine Inciter"]          = { mark = 4, creatureType = "Demon" },                    -- poisons + Kidney Shot; Banish
    ["Nethervine Reaper"]           = { mark = 4, creatureType = "Demon" },                    -- Cleave; Banish, face away
    ["Nethervine Trickster"]        = { mark = 4, creatureType = "Demon" },                    -- stealth; Banish
    ["Bloodfalcon"]                 = "SKIP",                                                  -- Falconer pets; AoE/Trap
    ["Frayer"]                      = "SKIP",                                                  -- non-elite; kill before they enrage
    ["Frayer Wildling"]             = "SKIP",
    ["Greater Frayer"]              = "SKIP",
    ["Mutate Fleshlasher"]          = "SKIP",                                                  -- non-elite swarm/summons
    ["Thorn Lasher"]                = "SKIP",                                                  -- event spawns near Laj
    ["Thorn Flayer"]                = "SKIP",
}

db["The Mechanar"] = {
    ["Bloodwarder Physician"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- heals + Holy Shock; kill first or Poly
    ["Sunseeker Netherbinder"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- summons 2 Arcane Servants; dispels CC
    ["Bloodwarder Slayer"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Whirlwind + 300% Solar Strike
    ["Sunseeker Astromage"]         = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Fire Shield ticks melee (spellsteal it)
    ["Sunseeker Engineer"]          = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Death Ray nuke; interrupt
    ["Bloodwarder Centurion"]       = { mark = 5, creatureType = "Humanoid" },                 -- don't dispel its Unstable Affliction
    ["Mechanar Wrecker"]            = { mark = 4, creatureType = "Demon", dangerLevel = 2 },   -- Pound AoE + fuel globs; robots are Demon-type: Banish works
    ["Mechanar Crusher"]            = { mark = 4, creatureType = "Demon" },                    -- Banishable robot
    ["Mechanar Driller"]            = { mark = 4, creatureType = "Demon" },                    -- shreds tank armor; Banish
    ["Arcane Servant"]              = { mark = 4, creatureType = "Elemental", dangerLevel = 2 },  -- Netherbinder summon; Arcane Explosion; Banish
    ["Tempest-Forge Destroyer"]     = { mark = 8, creatureType = "Mechanical", dangerLevel = 2, ccImmune = true },  -- mini-boss; triple Power Slam AoE
    ["Tempest-Forge Patroller"]     = { mark = 8, creatureType = "Mechanical", ccImmune = true },  -- solo patrols; arcane missiles + knockdown
    ["Mechanar Tinkerer"]           = "SKIP",                                                  -- non-elite swarm; suicide-explodes at 50% HP
}

db["The Arcatraz"] = {
    ["Negaton Warp-Master"]         = { mark = 8, creatureType = "Demon", dangerLevel = 3 },   -- places Negaton Field that heals/buffs void mobs
    ["Protean Nightmare"]           = { mark = 8, dangerLevel = 3 },                           -- Incubation spawns adds; uncategorized type, no CC
    ["Spiteful Temptress"]          = { mark = 4, creatureType = "Demon", dangerLevel = 3 },   -- mind control + taunt-immune; Banish
    ["Skulking Witch"]              = { mark = 8, creatureType = "Demon", dangerLevel = 2 },   -- invisible; 4.7k Chastise openers
    ["Negaton Screamer"]            = { mark = 4, creatureType = "Demon", dangerLevel = 2 },   -- AoE fear; absorbs/reflects one spell school; Banish
    ["Eredar Deathbringer"]         = { mark = 8, creatureType = "Demon", dangerLevel = 2 },   -- Unholy Aura AoE + knockback cleave
    ["Eredar Soul-Eater"]           = { mark = 8, creatureType = "Demon", dangerLevel = 2 },   -- Soul Steal/Soul Chill
    ["Unbound Devastator"]          = { mark = 8, creatureType = "Demon", dangerLevel = 2 },   -- Deafening Roar AoE; tank against wall
    ["Unchained Doombringer"]       = { mark = 8, creatureType = "Demon", dangerLevel = 2 },   -- War Stomp; Heroic Berserker Charge
    ["Gargantuan Abyssal"]          = { mark = 8, creatureType = "Demon", dangerLevel = 2, ccImmune = true },  -- Banish-immune; stack to split Meteor
    ["Soul Devourer"]               = { mark = 4, creatureType = "Demon", dangerLevel = 2 },   -- Enrage + Fel Breath; Banish
    ["Death Watcher"]               = { mark = 8, dangerLevel = 2 },                           -- Death Count at 50% = DPS race; pull alone
    ["Entropic Eye"]                = { mark = 8, dangerLevel = 2 },                           -- Chaos Breath frontal cone; face away
    ["Arcatraz Sentinel"]           = { mark = 8, creatureType = "Mechanical", dangerLevel = 2, ccImmune = true },  -- plays dead; explodes on death
    ["Arcatraz Defender"]           = { mark = 5, creatureType = "Humanoid" },                 -- blood elf; fully CC-able
    ["Arcatraz Warder"]             = { mark = 5, creatureType = "Humanoid" },                 -- ranged; Wing Clip root
    ["Protean Horror"]              = "SKIP",                                                  -- non-elite swarm; some feign death
    ["Protean Spawn"]               = "SKIP",                                                  -- Incubation spawns; AoE
    ["Sightless Eye"]               = "SKIP",                                                  -- non-elite; AoE down
    ["Negaton Field"]               = "SKIP",                                                  -- void pillar; kill Warp-Master instead
}

-- --- Caverns of Time ---------------------------------

db["Old Hillsbrad Foothills"] = {
    ["Durnholde Warden"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- heals + AoE fear; kill first
    ["Tarren Mill Protector"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Holy Light; interrupt
    ["Tarren Mill Guardsman"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Mortal Strike on tank
    ["Durnholde Rifleman"]          = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Stun Shot can lock the healer; Trap/Poly
    ["Durnholde Mage"]              = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Fireball/Cone of Cold
    ["Durnholde Veteran"]           = { mark = 5, creatureType = "Humanoid" },                 -- Kidney Shot; Sap
    ["Durnholde Sentry"]            = { mark = 5, creatureType = "Humanoid" },
    ["Tarren Mill Lookout"]         = { mark = 5, creatureType = "Humanoid" },                 -- hunter-type; Concussive Shot
    ["Durnholde Tracking Hound"]    = { mark = 2, creatureType = "Beast" },                    -- sees through stealth; Hibernate
    ["Infinite Defiler"]            = { mark = 8, creatureType = "Dragonkin", dangerLevel = 2 },  -- escort-wave warlock; kill first (no Poly/Sap on Dragonkin)
    ["Infinite Saboteur"]           = { mark = 8, creatureType = "Dragonkin", dangerLevel = 2 },  -- stealth; jumps the healer
    ["Infinite Slayer"]             = { mark = 6, creatureType = "Dragonkin" },                -- Trap/Hibernate only
    ["Lordaeron Watchman"]          = "SKIP",                                                  -- neutral road patrol; don't aggro
    ["Lordaeron Sentry"]            = "SKIP",
}

db["The Black Morass"] = {
    ["Rift Keeper"]                 = { mark = 8, creatureType = "Dragonkin", dangerLevel = 3, ccImmune = true },  -- portal guardian; must die to close rift
    ["Rift Lord"]                   = { mark = 8, creatureType = "Dragonkin", dangerLevel = 3, ccImmune = true },  -- portal guardian; Mortal Strike + knockback
    ["Infinite Assassin"]           = { mark = 7, creatureType = "Dragonkin", dangerLevel = 2 },  -- Kidney Shots healer/Medivh; kill fast
    ["Infinite Chronomancer"]       = { mark = 8, creatureType = "Dragonkin", dangerLevel = 2 },  -- nukes Medivh if ignored
    ["Infinite Vanquisher"]         = { mark = 8, creatureType = "Dragonkin", dangerLevel = 2 },  -- caster; waves 13+
    ["Infinite Executioner"]        = { mark = 6, creatureType = "Dragonkin" },                -- Cleave; waves 6+
    ["Infinite Whelp"]              = "SKIP",                                                  -- swarm; AoE at Medivh's shield
    ["Sable Jaguar"]                = "SKIP",                                                  -- trivial pre-event trash
    ["Darkwater Crocolisk"]         = "SKIP",
    ["Blackfang Tarantula"]         = "SKIP",
}

-- --- Isle of Quel'Danas ---------------------------------

db["Magisters' Terrace"] = {
    ["Sunblade Blood Knight"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Holy Light heals; interrupt or MC it
    ["Sunblade Physician"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Prayer of Mending healer
    ["Sister of Torment"]           = { mark = 4, creatureType = "Demon", dangerLevel = 3 },   -- Deadly Embrace mind control; Banish on sight
    ["Ethereum Smuggler"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- teleports + chain Arcane Explosion; CC or kill first
    ["Sunblade Sentinel"]           = { mark = 8, creatureType = "Mechanical", dangerLevel = 2, ccImmune = true },  -- fel golem patrol; chain Fel Lightning
    ["Sunblade Mage Guard"]         = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Glaive Throw + dampening field
    ["Sunblade Magister"]           = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Arcane Nova burst
    ["Sunblade Warlock"]            = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Incinerate; runs with imps
    ["Sunblade Keeper"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Shadow Bolt Volley; banishes a player
    ["Coilskar Witch"]              = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- Forked Lightning cone
    ["Wretched Bruiser"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Wretched Strike ~3k on Heroic; purge Fel Infusion
    ["Wretched Husk"]               = { mark = 5, creatureType = "Humanoid", dangerLevel = 2 },  -- fire/frost caster
    ["Wretched Skulker"]            = { mark = 5, creatureType = "Humanoid" },                 -- fast patrol packs
    ["Sunblade Imp"]                = "SKIP",                                                  -- demon swarm; AoE or Enslave
    ["Brightscale Wyrm"]            = "SKIP",                                                  -- mana-wyrm swarm before Vexallus
    ["Fel Crystal"]                 = "SKIP",                                                  -- Selin Fireheart fight object
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
