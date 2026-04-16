# AutoMarkAssist

[![GitHub release](https://img.shields.io/github/v/release/Swatto86/AutoMarkAssist?display_name=tag&sort=semver)](https://github.com/Swatto86/AutoMarkAssist/releases)
[![Package Release](https://github.com/Swatto86/AutoMarkAssist/actions/workflows/release.yml/badge.svg)](https://github.com/Swatto86/AutoMarkAssist/actions/workflows/release.yml)
[![CurseForge](https://img.shields.io/badge/CurseForge-AutoMarkAssist-f16436?logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/automarkassist)

AutoMarkAssist is a WoW Classic addon that automatically marks mobs in dungeons and raids. It evaluates the entire visible pack, scores mobs by danger, and allocates kill and CC marks in priority order. It detects your group's CC composition and intelligently assigns the right marks to the right targets. When high-value targets die, marks dynamically cascade so the group always has a clear kill order. 

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
| Square | :blue_square: | Trap (Hunter) |

Skull and Cross are always kill targets. CC marks are only used when the matching class is in your group. Unused CC marks become extra kill targets!

## Three Marking Modes

- **Proximity** (default) — Auto-marks hostile mobs within range on a 0.5s scan timer. Evaluates the entire pack, scores every mob, and assigns marks in priority order.
- **Mouseover** — Marks when you hover over a mob. Reserves mark slots for higher-priority mobs so the hovered target gets the correct mark.
- **Manual** — Hold a modifier key (or choose "NONE") and scroll your mouse wheel over a target to pick your own marks via a HUD. No automatic logic runs. Inside instances, your choices are saved to the database for future auto-marking.

Only one mode is active at a time.

## Smart CC Detection

The addon reads your group roster and activates CC marks for present classes:

- Mage → Polymorph (Moon) — Humanoid, Beast, Critter
- Rogue → Sap (Diamond) — Humanoid
- Warlock → Banish (Triangle) — Demon, Elemental
- Priest → Shackle (Star) — Undead
- Druid → Hibernate (Circle) — Beast, Dragonkin
- Hunter → Trap (Square) — Humanoid, Beast, Demon, Dragonkin, Giant, Undead

When these classes enter your group, their corresponding marks activate. When multiple CC classes can handle the same creature type, the most specific ability wins.

## Usage

Type `/ama` or `/automarkassist` to open the configuration panel.

Other commands:
- `/ama show`
- `/ama hide`
- `/ama help`
- `/ama reset` - Manually clear marks assigned by the addon.

## Source layout

- `AutoMarkAssist.lua` — Namespace, shared constants, CC assignments, danger level definitions, saved-variable defaults.
- `AutoMarkAssist_Core.lua` — Mark tracking, permission checks, unit token list, combat lock.
- `AutoMarkAssist_MobScanning.lua` — Zone DB management, mob scoring, holistic pack scan, mark allocation, CC specificity, cascade-on-death, reset, sync.
- `AutoMarkAssist_Proximity.lua` — 0.5s OnUpdate scan loop for proximity mode.
- `AutoMarkAssist_Mouseover.lua` — UPDATE_MOUSEOVER_UNIT handler with context-aware soft-reservation.
- `AutoMarkAssist_Manual.lua` — Scroll-wheel mark picker HUD for manual mode.
- `AutoMarkAssist_Events.lua` — Zone tracking, event routing, slash commands, combat log immunity detection.
- `AutoMarkAssist_Config.lua` — Options UI, announcement tools, database browser.
- `AutoMarkAssist_Minimap.lua` — Minimap button.
- `AutoMarkAssist_DB_*.lua` — Per-expansion mob databases with danger classifications.
