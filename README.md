# AutoMarkAssist

[![GitHub release](https://img.shields.io/github/v/release/Swatto86/AutoMarkAssist?display_name=tag&sort=semver)](https://github.com/Swatto86/AutoMarkAssist/releases)
[![Package Release](https://github.com/Swatto86/AutoMarkAssist/actions/workflows/release.yml/badge.svg)](https://github.com/Swatto86/AutoMarkAssist/actions/workflows/release.yml)
[![CurseForge](https://img.shields.io/badge/CurseForge-AutoMarkAssist-f16436?logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/automarkassist)

AutoMarkAssist is a WoW Classic addon that automatically marks mobs in dungeons and raids based on kill priority and crowd control. It detects your group composition and intelligently assigns CC marks to the right targets, announcing the plan on entry so everyone knows what each mark means.

Downloads:

- [GitHub Releases](https://github.com/Swatto86/AutoMarkAssist/releases)
- [CurseForge Project](https://www.curseforge.com/wow/addons/automarkassist)

## Install

1. Download the latest release zip from GitHub Releases or CurseForge.
2. Extract the `AutoMarkAssist` folder into `World of Warcraft/_classic_/Interface/AddOns`.
3. Restart the game or reload the UI.

## Mark Assignments

| Mark | Icon | Role |
|------|------|------|
| Skull | 💀 | First Kill |
| Cross | ❌ | Second Kill |
| Moon | 🌙 | Polymorph (Mage) |
| Diamond | 💎 | Sap (Rogue) |
| Triangle | 🔺 | Banish (Warlock) |
| Star | ⭐ | Shackle (Priest) |
| Circle | 🟠 | Hibernate (Druid) |
| Square | 🟦 | Trap (Hunter) - disabled by default |

Skull and Cross are always kill targets. The remaining marks are assigned to CC based on which classes are actually in your group. If a CC class isn't present, their mark becomes an additional kill target instead.

## Marking Modes

AutoMarkAssist has three mutually exclusive marking modes:

- **Proximity** (default) — Automatically marks hostile mobs within range every 0.5 seconds.
- **Mouseover** — Marks a mob when you hover over it.
- **Manual** — Hold a modifier key (ALT/SHIFT/CTRL) and scroll the mouse wheel to pick a mark for the mob under your cursor.

Only one mode is active at a time.

## Smart CC Detection

The addon reads your party or raid roster and determines which CC abilities are available:

- **Mage** → Polymorph (Humanoid, Beast)
- **Rogue** → Sap (Humanoid)
- **Warlock** → Banish (Demon, Elemental)
- **Priest** → Shackle Undead (Undead)
- **Druid** → Hibernate (Beast, Dragonkin)
- **Hunter** → Trap (Beast)

When entering a dungeon or raid, the addon announces which marks mean what based on who is actually in the group. Only CC marks for classes present are announced — no confusion about marks nobody can use.

## Features

- Built-in mob database covering Classic, TBC, Wrath, Cataclysm, and Mists of Pandaria dungeons and raids.
- Automatic CC mark assignment based on creature type and group composition.
- Dynamic bump-marking: higher-priority mobs can claim better marks.
- Death cascade: marks rebalance when marked mobs die.
- Combat mark lock to prevent reassignment during combat.
- Respects existing marks placed by other players.
- Per-mark enable/disable toggles in the options panel.
- In-game database editor for per-zone mob priority overrides.
- Configurable announcement channel (SAY/PARTY/RAID) with custom prefix.
- Reset-marks keybind for instant mark clearing.
- Minimap button with status indicator (green = auto, gold = manual, red = disabled).
- Verbose debug mode for troubleshooting.

## Commands

| Command | Description |
|---------|-------------|
| `/ama` | Open options panel |
| `/ama enable` | Enable auto-marking |
| `/ama disable` | Disable auto-marking |
| `/ama toggle` | Toggle auto-marking |
| `/ama reset` | Clear all marks |
| `/ama announce` | Send mark plan to chat |
| `/ama preview` | Preview mark plan locally |
| `/ama mode <proximity\|mouseover\|manual>` | Switch marking mode |
| `/ama manual` | Toggle manual mode |
| `/ama cc` | Show available CC in group |
| `/ama marks` | Show currently marked mobs |
| `/ama zone` | Show current zone info |
| `/ama verbose` | Toggle debug output |
| `/ama lock` | Toggle combat mark lock |
| `/ama show` / `/ama hide` | Toggle minimap button |
| `/ama defaults` | Reset all settings |
| `/ama help` | Show command list |

## Supported Game Versions

| TOC File | Client | Expansion Coverage |
|----------|--------|--------------------|
| `AutoMarkAssist_Vanilla.toc` | Classic Era | Classic |
| `AutoMarkAssist.toc` | TBC Anniversary | Classic + TBC |
| `AutoMarkAssist_Wrath.toc` | Wrath Classic | Classic + TBC + WotLK |
| `AutoMarkAssist_Cata.toc` | Cata Classic | Classic + TBC + WotLK + Cata |
| `AutoMarkAssist_MoP.toc` | MoP Classic | Classic + TBC + WotLK + Cata + MoP |

## Source Layout

| File | Purpose |
|------|---------|
| `AutoMarkAssist.lua` | Namespace, constants, CC mapping, saved-variable defaults, utilities |
| `AutoMarkAssist_Core.lua` | Mark allocation, priority detection, CC matching, sync, rebalance |
| `AutoMarkAssist_Minimap.lua` | Minimap button, manual mode HUD, scroll-wheel mark picker |
| `AutoMarkAssist_Config.lua` | Announce system, ElvUI-themed options panel (General, Database, About) |
| `AutoMarkAssist_Events.lua` | Event handling, proximity scanner, zone tracking, slash commands |
| `AutoMarkAssist_DB_*.lua` | Zone mob databases per expansion |

## License

All Rights Reserved. © Swatto
# AutoMarkAssist

[![GitHub release](https://img.shields.io/github/v/release/Swatto86/AutoMarkAssist?display_name=tag&sort=semver)](https://github.com/Swatto86/AutoMarkAssist/releases)
[![Package Release](https://github.com/Swatto86/AutoMarkAssist/actions/workflows/release.yml/badge.svg)](https://github.com/Swatto86/AutoMarkAssist/actions/workflows/release.yml)
[![CurseForge](https://img.shields.io/badge/CurseForge-AutoMarkAssist-f16436?logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/automarkassist)

AutoMarkAssist is a WoW Classic addon for repeatable raid-target assignment across dungeons and raids. It combines a built-in mob-priority database, configurable mark pools, proximity or mouseover scanning, manual teaching, and live rebalance logic so groups can keep a consistent kill order without re-marking every pull by hand.

Downloads:

- [GitHub Releases](https://github.com/Swatto86/AutoMarkAssist/releases)
- [CurseForge Project](https://www.curseforge.com/wow/addons/automarkassist)

## Install

1. Download the latest release zip from GitHub Releases or CurseForge.
2. Extract the `AutoMarkAssist` folder into `World of Warcraft/_classic_/Interface/AddOns`.
3. Restart the game or reload the UI.

## What it does

AutoMarkAssist helps tanks and pull leaders keep group assignments readable and consistent. It can automatically assign raid markers by mob priority, adapt smart CC marks to the actual party or raid composition, remember manual preferences for later pulls, and announce the current plan in party or raid chat when marker permissions allow it.

## Highlights

- Built-in zone-aware mob database covering supported Classic, TBC, Wrath, Cataclysm, and Mists content.
- Configurable HIGH, CC, MEDIUM, and LOW mark pools.
- A single active automatic scan mode at a time, with proximity as the default for new profiles and optional mouseover-only marking when preferred.
- Smart Group CC that locks skull and cross as the primary kill-order marks, then adapts the remaining CC icons to party or raid composition and creature type inside instances.
- Pull-wide CC matching so mobs with fewer compatible CC options are assigned intelligently before more flexible targets, using the shipped Smart Group CC icon map: Moon Polymorph, Diamond Sap, Square Trap, Star Shackle, Circle Hibernate, Triangle Banish.
- `/ama announce` and `/ama preview` honor the live party or raid roster, only showing CC labels for classes actually present and turning the remaining active icons into later kill-order lines.
- Manual-only or automatic smart CC reminders, with `/ama ccannounce` available for on-demand reposts.
- Announcement output that can be posted line-by-line or as a single line, with a customizable or removable prefix.
- Announcement and marking suppression when Blizzard does not allow the player to place raid markers in the current group.
- Manual mouseover marking with scroll-wheel selection and persistent teaching back into the zone database.
- Reset-to-defaults support, verbose debug mode, minimap tools, and a first-load What's New view.

## Useful commands

- `/ama` - open the config window.
- `/ama announce` - announce the current mark plan.
- `/ama preview` - preview the current mark plan locally in chat.
- `/ama ccannounce` - repeat the current smart CC assignments to group chat.
- `/ama ccauto` - toggle automatic smart CC reminders.
- `/ama manual` - toggle manual scroll-wheel marking mode.
- `/ama reset` - clear local mark tracking.
- `/ama whatsnew` - show the latest update notes.

## Supported game versions

- Classic Era / Vanilla
- TBC Classic / Anniversary
- Wrath Classic
- Cata Classic
- MoP Classic

## Full command list

- `/ama`
- `/automarkassist`
- `/ama options`
- `/ama config`
- `/ama enable`
- `/ama disable`
- `/ama toggle`
- `/ama reset`
- `/ama clear`
- `/ama rebalance`
- `/ama announce`
- `/ama preview`
- `/ama ccannounce`
- `/ama repeatcc`
- `/ama ccremind`
- `/ama ccauto`
- `/ama manual`
- `/ama lock`
- `/ama combatlock`
- `/ama smartcc`
- `/ama groupcc`
- `/ama verbose`
- `/ama whatsnew`
- `/ama pools`
- `/ama marks`
- `/ama show`
- `/ama hide`
- `/ama help`
- `/ama db`
- `/ama zone`
- `/ama sub <mob> <number>`
- `/ama subclear <mob>`
- `/ama sublist`

## Source layout

- `AutoMarkAssist.lua` - shared constants, defaults, utility helpers, and release-facing version metadata.
- `AutoMarkAssist_Core.lua` - mark allocation, rebalance, release, and priority handling.
- `AutoMarkAssist_Events.lua` - zone updates, slash commands, scanners, and gameplay event flow.
- `AutoMarkAssist_Config.lua` - options UI, announcement tools, database editor, and About/help content.
- `AutoMarkAssist_Minimap.lua` - minimap launcher, HUD, and manual scroll-wheel marking flow.
- `AutoMarkAssist_DB_Classic.lua` through `AutoMarkAssist_DB_MoP.lua` - built-in per-expansion mob data.

## Support and issues

- [GitHub Issues](https://github.com/Swatto86/AutoMarkAssist/issues)
- [CurseForge Project Page](https://www.curseforge.com/wow/addons/automarkassist)

## Repository notes

The repository is intentionally kept small. The public Git history includes the addon source files, the packager metadata, the GitHub Actions workflow, and this README. Repository-only files such as this README are excluded from the final addon zip via `.pkgmeta`.

Tagged releases are packaged automatically through GitHub Actions and uploaded to both GitHub Releases and CurseForge.