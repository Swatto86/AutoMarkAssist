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
- Smart Group CC that keeps skull and cross as the primary kill-order marks, then adapts CC icons to party or raid composition and creature type inside instances.
- Pull-wide CC matching so mobs with fewer compatible CC options are assigned intelligently before more flexible targets, while still using your group's preferred sheep, sap, trap, and other CC icons.
- Manual-only or automatic smart CC reminders, with `/ama ccannounce` available for on-demand reposts.
- Announcement output that can be posted line-by-line or as a single line, with a customizable or removable prefix.
- Announcement and marking suppression when Blizzard does not allow the player to place raid markers in the current group.
- Manual mouseover marking with scroll-wheel selection and persistent teaching back into the zone database.
- Reset-to-defaults support, verbose debug mode, minimap tools, and a first-load What's New view.

## Useful commands

- `/ama` - open the config window.
- `/ama announce` - announce the current mark legend.
- `/ama preview` - preview the current legend locally in chat.
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