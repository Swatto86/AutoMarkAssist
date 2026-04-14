# AutoMarkAssist

[![GitHub release](https://img.shields.io/github/v/release/Swatto86/AutoMarkAssist?display_name=tag&sort=semver)](https://github.com/Swatto86/AutoMarkAssist/releases)
[![Package Release](https://github.com/Swatto86/AutoMarkAssist/actions/workflows/release.yml/badge.svg)](https://github.com/Swatto86/AutoMarkAssist/actions/workflows/release.yml)
[![CurseForge](https://img.shields.io/badge/CurseForge-AutoMarkAssist-f16436?logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/automarkassist)

AutoMarkAssist is a WoW Classic addon that automatically marks mobs in dungeons and raids using a fast, First-Come-First-Serve (FCFS) architecture. It detects your group composition and intelligently assigns CC marks to the right targets. When high-value targets die, marks will dynamically cascade (e.g., when Skull dies, Cross becomes the new Skull, leaving Cross open for another CC mark). 

Downloads:

- [GitHub Releases](https://github.com/Swatto86/AutoMarkAssist/releases)
- [CurseForge Project](https://www.curseforge.com/wow/addons/automarkassist)

## Install

1. Download the latest release zip from GitHub Releases or CurseForge.
2. Extract the \AutoMarkAssist\ folder into \World of Warcraft/_anniversary_/Interface/AddOns\.
3. Restart the game or reload the UI.

## Mark Assignments

| Mark | Icon | Role |
|------|------|------|
| Skull | :skull: | First Kill |
| Cross | :x: | Second Kill |
| Moon | :crescent_moon: | Polymorph (Mage) |
| Diamond | :gem: | Sap (Rogue) |
| Triangle | :small_red_triangle: | Banish (Warlock) |
| Star | :star: | Shackle (Priest) |
| Circle | :orange_circle: | Hibernate (Druid) |
| Square | :blue_square: | Trap (Hunter) — disabled by default |

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

Type \/ama\ or \/automarkassist\ to open the configuration panel.

Other commands:
- \/ama show\
- \/ama hide\
- \/ama help\
- \/ama reset\ - Manually clear marks assigned by the addon.

## Source layout

- \AutoMarkAssist.lua\ - shared constants, defaults, utility helpers, and release-facing version metadata.
- \AutoMarkAssist_Core.lua\ - mark allocation, rebalance, release, FCFS handling, and waterfall mark cascading.
- \AutoMarkAssist_Events.lua\ - zone updates, slash commands, scanners, and gameplay event flow.
- \AutoMarkAssist_Config.lua\ - options UI, announcement tools, and About/help content.
- \AutoMarkAssist_Minimap.lua\ - minimap launcher, HUD, and manual scroll-wheel marking flow.
