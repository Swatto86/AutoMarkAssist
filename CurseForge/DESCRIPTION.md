# AutoMarkAssist

AutoMarkAssist is a WoW Classic addon that automatically marks mobs in dungeons and raids. It ships with a built-in database of dungeon and raid mobs with preferred mark assignments, detects your group's CC composition, and intelligently allocates kill and crowd-control marks. When high-value targets die, marks dynamically cascade (e.g., Skull dies → Cross promotes to Skull, freeing Cross for the next target).

## Mark Assignments

- **Skull** = First Kill
- **Cross** = Second Kill
- **Moon** = Polymorph (Mage)
- **Diamond** = Sap (Rogue)
- **Triangle** = Banish (Warlock)
- **Star** = Shackle (Priest)
- **Circle** = Hibernate (Druid)
- **Square** = Trap (Hunter) — disabled by default

Skull and Cross are always kill targets. CC marks activate only when the matching class is in your group. Unused CC marks become extra kill targets.

## Per-Mob Mark Database

The addon includes a built-in database covering Classic, TBC, WotLK, Cata, and MoP dungeons and raids. The TBC database is fully enriched with creature types for every mob, enabling precise CC validation. Each mob entry stores a preferred mark, creature type, and optional CC immunity flag.

The allocation priority adapts to dungeon difficulty:

**Normal dungeons:** DB preference → Skull → Cross → CC by creature type  
**Heroic dungeons:** DB preference → Skull → CC by creature type → Cross

CC marks are only assigned when:
- The corresponding CC class is in your group
- The mob's creature type is compatible with the CC ability
- The mob is not flagged as CC-immune

You can customise per-mob marks in the **Database tab** of the config panel. The tab features a full zone browser organised by expansion and instance type (Dungeons / Raids), so you can browse and edit marks for any zone without being inside it. A **Type** column shows each mob's creature type, and enabling the **Edit** checkbox lets you cycle types manually. Manual mode also learns your preferences inside instances.

## Three Marking Modes

- **Proximity** (default) — Auto-marks hostile mobs within range on a 0.5s scan timer.
- **Mouseover** — Marks when you hover over a mob.
- **Manual** — Hold a modifier key (or choose "NONE") and scroll your mouse wheel over a target to pick marks. Inside instances, your choices are saved to the database for future pulls.

Only one mode is active at a time.

## Smart CC Detection

The addon reads your group roster and activates CC marks for present classes:

- Mage → Polymorph (Moon) — Humanoid, Beast, Critter
- Rogue → Sap (Diamond) — Humanoid
- Warlock → Banish (Triangle) — Demon, Elemental
- Priest → Shackle (Star) — Undead
- Druid → Hibernate (Circle) — Beast, Dragonkin
- Hunter → Trap (Square) — Humanoid, Beast, Demon, Dragonkin, Giant, Undead

Creature type matters — a Mage's Moon mark will only be assigned to Humanoids, Beasts, and Critters, not to Undead or Demons. Mobs flagged as CC-immune in the database (or detected as immune at runtime via the combat log) will never receive CC marks.

## Self-Learning Database

The addon enriches its database as you play:

- **Creature type capture** — When a mob is marked and its database entry lacks a creature type, the addon reads the live value from the game and saves it.
- **CC immunity detection** — When a CC spell (Polymorph, Sap, Banish, Shackle, Hibernate, Freezing Trap) is resisted with IMMUNE, the mob is permanently flagged as CC-immune in your personal database.
- **Manual mode learning** — Marking a mob manually inside an instance saves your preference for future auto-marking.

## Usage

Type `/ama` or `/automarkassist` to open the configuration panel.

Other commands:
- `/ama enable` / `disable` / `toggle`
- `/ama reset` — Clear all marks.
- `/ama announce` — Post mark plan to party chat.
- `/ama preview` — Preview mark plan locally.
- `/ama mode <proximity|mouseover|manual>`
- `/ama verbose` — Toggle debug output.
- `/ama help`

## Good fit for

- Tanks or pull leaders who want consistent kill order without manually re-marking every pack.
- Groups running Classic dungeons or raids where the same dangerous mobs appear repeatedly.
- Players who want manual control first, then want the addon to learn their preferred marks over time.

## Notes and limitations

- Retail is not supported.
- If Blizzard does not allow your character to place a raid icon in the current group, the addon cannot mark and will suppress announcements.
- Auto-reset on leaving combat only clears marks the addon set — marks placed by other players are preserved.

## Source and support

- GitHub repository: https://github.com/Swatto86/AutoMarkAssist
- Bug reports and feature requests: https://github.com/Swatto86/AutoMarkAssist/issues

## Supported game versions

- Classic Era / Vanilla
- TBC Classic / Anniversary
- Wrath Classic
- Cata Classic
- MoP Classic
