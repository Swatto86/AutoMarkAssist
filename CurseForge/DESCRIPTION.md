# AutoMarkAssist

AutoMarkAssist is a Classic-only World of Warcraft addon for fast, repeatable raid-target assignment. It can auto-mark or manual-mark enemies in parties and raids, using a built-in zone-aware mob database, your configured mark pools, and live pull state to keep kill order clear. The built-in database now covers all supported dungeons and raids through MoP Classic when those expansion modules are loaded. It was built around TBC Classic Anniversary first, then expanded into a multi-TOC addon that also supports Classic Era, Wrath Classic, Cata Classic, and MoP Classic from the same folder.

The addon only works when your character is actually allowed to place raid icons. In practice that means party marking follows the live client rules for 5-player groups, and raids still require leader or assistant permissions. AutoMarkAssist will not bypass Blizzard restrictions.

## What it does

- Automatically assigns raid icons from a built-in per-zone mob database covering supported dungeons and raids through MoP Classic.
- Works in both parties and raids, and respects visible icons already placed by other players instead of wiping or stealing them.
- Supports proximity-based or mouseover-based auto-marking, with proximity scanning as the single default automatic mode for new profiles.
- Lets you switch to manual mouseover marking whenever you want full control.
- Saves manual choices back into the zone database so later auto-marking follows the marks you taught it.
- Keeps marks stable between pulls instead of clearing everything when combat ends.

## Auto-marking behavior

- Priority-based auto marking driven by a built-in mob database plus your own per-zone overrides.
- Configurable mark pools for HIGH, CC, MEDIUM, and LOW priority mobs.
- Dynamic bump-marking so higher-priority mobs can claim stronger icons when a better target appears.
- Optional combat mark lock so auto-marks stay stable while you are in combat.
- Optional death rebalance and cascade logic to keep kill order tidy as pulls change.
- CC limit controls so only the number of crowd-control marks you want are assigned.
- Smart Group CC is enabled by default for new profiles, locks skull and cross as the primary kill-order marks, then only uses the remaining CC icons your current party or raid can realistically support for each target's creature type.
- Pull-wide Smart Group CC matching now gives limited CC options to the mobs that actually need them first, while Smart Group CC role-mark preferences still let sheep, sap, trap, shackle, banish, and hibernate use your group's preferred icons.
- Fallback keyword heuristics for unknown mobs when no exact zone database match exists.
- Between-pull refresh that preserves visible icons instead of clearing the next pack when combat ends.

## Manual marking

- Manual mouseover marking with a modifier key plus mouse wheel.
- Choose any icon, including one already in use, then close the picker or move to a different target to apply it.
- Manual choices are saved per zone so auto mode can learn the marks you use most often.
- Configurable manual scroll order with drag-to-reorder UI.
- Explicit wheel-direction choice so players can decide whether scroll up or scroll down starts at the left-most icon.
- Floating mark picker HUD that shows current selection and which icons are already taken.
- Reset-mark keybind support for clearing tracking instantly during a run.

## Database and planning tools

- In-game Database tab for per-zone mob priority editing.
- Add, remove, or override mobs per zone without editing Lua files.
- Sub-priority tie-break editor so mobs inside the same main tier can still compete for better icons in a predictable order.
- Simple in-game help explains that sub-priority only matters when two mobs share the same main priority.
- Mark legend editor plus manual announce and preview output for communicating kill and crowd-control plans.
- Configurable announcement style with line-by-line or single-line chat output and a customizable prefix that can also be left blank.
- CC limit controls so the announced plan matches the marks the addon will actually assign.
- Optional automatic smart group CC reminders, with manual `/ama ccannounce` repeats whenever you want them instead.
- Built-in encounter-aware rules for specific pulls, plus user overrides when you want different behavior.

## Quality-of-life features

- Minimap button with status indicator, tooltip summary, drag repositioning that follows the actual minimap shape, and quick actions.
- Mouseover range and proximity range controls.
- Announcement tools now suppress party or raid chat reminders when you do not currently have permission to place raid markers.
- General-tab reset-to-defaults control for restoring the shipped settings and Database behavior.
- First-load What's New popup after updates, with a button in the About tab and `/ama whatsnew` to re-open the latest notes.
- Verbose debug mode for troubleshooting.
- Slash commands for quick control without opening the full options window.

## Slash commands

- /ama
- /automarkassist
- /ama options
- /ama config
- /ama enable
- /ama disable
- /ama toggle
- /ama reset
- /ama clear
- /ama rebalance
- /ama announce
- /ama preview
- /ama ccannounce
- /ama repeatcc
- /ama ccremind
- /ama ccauto
- /ama manual
- /ama lock
- /ama combatlock
- /ama smartcc
- /ama groupcc
- /ama whatsnew
- /ama verbose
- /ama db
- /ama zone
- /ama marks
- /ama pools
- /ama sub <mob> <number>
- /ama subclear <mob>
- /ama sublist
- /ama show
- /ama hide
- /ama help

## Good fit for

- Tanks or pull leaders who want consistent kill order without manually re-marking every pack.
- Groups running Classic dungeons or raids where the same dangerous mobs appear repeatedly.
- Players who want manual control first, then want the addon to learn their preferred marks over time.

## Notes and limitations

- The built-in database now covers supported dungeons and raids through MoP Classic, but you can still add Database tab entries or manual teaching when you want different marks for your group.
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