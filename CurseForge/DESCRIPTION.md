# AutoMarkAssist

AutoMarkAssist is a WoW Classic addon that automatically marks mobs in dungeons and raids using a fast, First-Come-First-Serve (FCFS) architecture. It detects your group composition and intelligently assigns CC marks to the right targets. When high-value targets die, marks will dynamically cascade (e.g., when Skull dies, Cross becomes the new Skull, leaving Cross open for another CC mark). 

## Mark Assignments

- **Skull** = First Kill
- **Cross** = Second Kill
- **Moon** = Polymorph (Mage)
- **Diamond** = Sap (Rogue)
- **Triangle** = Banish (Warlock)
- **Star** = Shackle (Priest)
- **Circle** = Hibernate (Druid)
- **Square** = Trap (Hunter) — disabled by default

Skull and Cross are always kill targets. CC marks are only used when the matching class is in your group. Unused CC marks become extra kill targets!

## Three Marking Modes

- **Proximity** (default) — Auto-marks hostile mobs within range.
- **Mouseover** — Marks when you hover over a mob.
- **Manual** — Hold a modifier key (or choose "NONE") and scroll your mouse wheel over a target to pick your own marks.

Only one mode is active at a time.

## Smart CC Detection

The addon reads your group roster and determines available CC:

- Mage -> Polymorph
- Rogue -> Sap
- Warlock -> Banish 
- Priest -> Shackle
- Druid -> Hibernate

When these classes enter your group, their corresponding marks "activate" and deploy.

## Usage

Type `/ama` or `/automarkassist` to open the configuration panel.

Other commands:
- `/ama show`
- `/ama hide`
- `/ama help`
- `/ama reset` - Manually clear marks assigned by the addon.

## Good fit for

- Tanks or pull leaders who want consistent kill order without manually re-marking every pack.
- Groups running Classic dungeons or raids where the same dangerous mobs appear repeatedly.
- Players who want manual control first, then want the addon to learn their preferred marks over time.

## Notes and limitations

- Retail is not supported.
- If Blizzard does not allow your character to place a raid icon in the current group, the addon cannot place one either, and it will now suppress group announcements that would imply active marks.

## Source and support

- GitHub repository: https://github.com/Swatto86/AutoMarkAssist
- Bug reports and feature requests: https://github.com/Swatto86/AutoMarkAssist/issues

## Supported game versions

- Classic Era / Vanilla
- TBC Classic / Anniversary
- Wrath Classic
- Cata Classic
- MoP Classic
