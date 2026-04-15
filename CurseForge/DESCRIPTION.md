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

The addon includes a built-in database covering Classic, TBC, WotLK, Cata, and MoP dungeons and raids. Each mob has a preferred mark (e.g., Skull for high-threat targets, Moon for polymorphable humanoids). The allocation priority is:

1. **Database preference** — If the mob has a stored mark and it's available, use it.
2. **Kill marks (FCFS)** — Skull first, then Cross.
3. **CC by creature type** — Match the mob's creature type to your group's CC abilities.
4. **Any remaining enabled mark** — Fill non-CC marks first, then spill into CC marks if needed.

You can customise per-mob marks in the **Database tab** of the config panel. The tab features a full zone browser organised by expansion and instance type (Dungeons / Raids), so you can browse and edit marks for any zone without being inside it. Manual mode also learns your preferences inside instances.

## Three Marking Modes

- **Proximity** (default) — Auto-marks hostile mobs within range on a 0.5s scan timer.
- **Mouseover** — Marks when you hover over a mob.
- **Manual** — Hold a modifier key (or choose "NONE") and scroll your mouse wheel over a target to pick marks. Inside instances, your choices are saved to the database for future pulls.

Only one mode is active at a time.

## Smart CC Detection

The addon reads your group roster and activates CC marks for present classes:

- Mage → Polymorph (Moon)
- Rogue → Sap (Diamond)
- Warlock → Banish (Triangle)
- Priest → Shackle (Star)
- Druid → Hibernate (Circle)
- Hunter → Trap (Square)

Creature type matters — a Mage's Moon mark will only be assigned to Humanoids, Beasts, and Critters, not to Undead or Demons.

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
