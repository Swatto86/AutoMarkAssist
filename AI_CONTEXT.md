# AutoMarkAssist — Agent Context

## System Overview

AutoMarkAssist is a WoW Classic-era addon that auto-marks dungeon and raid packs. It scores the visible pack, assigns Skull/Cross kill icons and roster-aware CC icons, and cascades marks on death. Clients: Classic Era, TBC, Wrath, Cata, MoP. Retail is not supported.

## Tech Stack & Architecture

Lua 5.1 (WoW Classic API). Multi-TOC loader (`AutoMarkAssist.toc` TBC, `_Vanilla`, `_Wrath`, `_Cata`, `_Mists`). SavedVariables: `AutoMarkAssistDB`. UI is an ElvUI-inspired flat dark options frame. Releases: GitHub tag → `.github/workflows/release.yml` → BigWigsMods/packager → CurseForge project 1479940.

## Component Map

- `AutoMarkAssist.lua` — namespace, `AMA.VERSION`, `CC_ASSIGNMENTS`, `DB_DEFAULTS`, migrate/backfill
- `AutoMarkAssist_Core.lua` — mark tracking, `CanMarkReason`, combat lock
- `AutoMarkAssist_MobScanning.lua` — zone DB, scoring, allocate, cascade, reset
- `AutoMarkAssist_Proximity.lua` / `_Mouseover.lua` / `_Manual.lua` — the three exclusive modes
- `AutoMarkAssist_Minimap.lua` — minimap button
- `AutoMarkAssist_Tutorial.lua` — first-run overlay (`AMA.ShowTutorialGuide`) and Tutorial tab (`AMA.BuildTutorialTab`)
- `AutoMarkAssist_DBTab.lua` — Database tab
- `AutoMarkAssist_Config.lua` — options: General / Database / Tutorial / About
- `AutoMarkAssist_Events.lua` — events, slash (`/ama tutorial`), first-run hook
- `AutoMarkAssist_DB_*.lua` — per-expansion mob data

Load order (TOC): DB modules → `AutoMarkAssist.lua` → Core → MobScanning → modes → Minimap → DBTab → Tutorial → Config → Events.

## Data Flow

Scan (0.5s proximity or mouseover) → score pack (`dangerLevel`, DB preference, tank-target tie-break) → allocate (Normal: DB → Skull → Cross → CC; Heroic: DB → Skull → CC → Cross) → `SetRaidTarget`. Death → cascade. `tutorialCompleted` in `AutoMarkAssistDB` suppresses the first-run overlay after Skip/Finish/Escape.

## Recent Context & Decisions

- 2026-09-02: v3.5.0 in-game tutorial (guided overlay + Tutorial tab). Version bumped in all TOC files and `AMA.VERSION`. Publish via `v3.5.0` tag / packager. Work stays on `main` (no feature branches) per owner request.
