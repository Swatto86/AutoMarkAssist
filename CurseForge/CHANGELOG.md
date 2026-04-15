# AutoMarkAssist Changelog

## 3.1.0

### New Features
- **Per-Mob Mark Database:** Replaced the old priority string system (HIGH/MEDIUM/LOW/CC) with concrete mark assignments per mob. Every mob in the database now maps directly to a specific mark index (e.g., Skull, Moon) or SKIP.
- **Database Config Tab:** New "Database" tab in the config panel. Browse all mobs for the current zone, see their assigned marks, left-click to cycle through marks, right-click to revert player overrides. Add custom mobs or reset the zone to defaults.
- **Manual Mode Learning:** In manual mode, marking a mob inside an instance automatically saves your preference to the database. Future pulls will use your learned marks.
- **Smart Mark Allocation:** New allocation chain — DB preference → kill marks (Skull/Cross FCFS) → CC by creature type and group composition → any remaining enabled mark → spill into reserved CC marks.
- **CC Creature Type Matching:** CC marks are only assigned to mobs whose creature type matches the CC ability (e.g., Moon only on Humanoids/Beasts for Polymorph, Star only on Undead for Shackle).

### Bug Fixes
- **Auto-Reset Respects Other Players:** Leaving combat now only clears marks the addon set locally. Marks placed by other players (e.g., another tank marking the next pack) are preserved. Explicit user actions (`/ama reset`, keybind) still clear everything.
- **Removed Player-Bounce Fallback:** The reset logic no longer bounces marks through the player frame to force-clear orphaned marks. This prevented a race condition where bouncing could accidentally strip marks set by other players on mobs outside your scanning range.
- **ForgetTrackedMark State Consistency:** Fixed a minor state desync where clearing a mark that belonged to a different GUID could incorrectly nil the token reference for the actual owner.
- **Manual Mode Clear Return Value:** `CommitPendingManualMark` now correctly returns false when clearing a mark fails, instead of always returning true.
- **Removed Dead Code:** Cleaned up unused `pullMarkCount` tracking field and removed stale `NormalizeZoneScopedMobSettings()` call from the event handler.

### Migration
- Existing saved variables are automatically migrated. Old `mobOverrides` (HIGH→Skull, CC→Moon), `mobRemovals` (→SKIP), and `zoneAdditions` are converted to the new `mobMarks` format.

## 3.0.5
### Bug Fixes
- **Orphaned Mark Leaks (Ghost Marks):** Resolved a critical state desync bug where marks owned by despawned or out-of-range mobs were never reclaimed. Skull and Cross could be permanently locked by a "ghost" owner from a previous pack, causing subsequent packs to receive incorrect marks (e.g. Triangle instead of Cross).
- **Stale State in AllocateMark:** `AllocateMark` and `FindCCMark` previously trusted `markOwners` blindly. These now call a new `IsMarkSlotFree()` helper which validates that the recorded owner GUID is still alive and visible before accepting the slot as taken. Dead or invisible owners are immediately evicted.
- **SyncVisibleMarks Stale-Owner Sweep:** After scanning all visible tokens, the sync now compares every tracked GUID against what was actually seen alive. Any GUID not found in the world is purged from all tracking tables, eliminating orphaned entries that missed their death events (e.g. mobs dying beyond the 50-yard combat log range).
- **ResetState Spam Fix:** Rewrote reset to iterate mark *indices* rather than GUIDs, clearing each mark via a visible token first and only bouncing the remainder through the player. This prevents redundant `SetRaidTarget` calls that triggered "too many group actions" throttle messages.
- **CascadeMarksAfterDeath Token Validation:** Promotion logic now uses a new `ResolveToken()` helper to re-validate cached unit tokens before use. If a cached token points to a different mob or a corpse, it falls back to a full live scan. Stale slots are reclaimed automatically during cascade.

## 3.0.4
### Architecture Changes
- **First-Come-First-Serve (FCFS) System:** Transitioned from a strict database priority system to a dynamic FCFS marking framework. The obsolete Database tab has been removed from the Configuration UI.
- **Waterfall Cascading Marks:** Added dynamic mark cascading upon target death. When the Skull target dies, the Cross target promotes to Skull, and the next available CC mark seamlessly promotes to Cross.

### Enhancements
- **Reset Marks Keybind:** Re-engineered the frame handling for the "Reset Marks" functionality to ensure hardware input is cleanly captured. The default keybind is now 'F'. Pressing it correctly clears all marks explicitly assigned by the user.
- **Manual Mode 'NONE' Modifier:** You can now configure the Manual Marking mode to use "NONE" as the modifier key. Mouseover targets will immediately activate the scroll-wheel mark selector.
- **Environment Targeting:** Validated seamless support for _anniversary_ (Classic) client environments.

# AutoMarkAssist Changelog

## 3.0.3
### Bug Fixes
- **Verbose Mode Consistency:** Fully integrated Verbose mode across all remaining slash commands and GUI configuration toggles. The chat frame will only alert you of changes you make via the GUI or chat commands if Verbose mode is properly toggled on!

### Enhancements
- **Tooltips Added:** Added comprehensive descriptor tooltips to the checkboxes inside the configuration GUI. 
- **DB Saving:** Added a new checkbox toggle to explicitly save manual marks you assign directly to the addon's memory database!

## 3.0.2
### Bug Fixes
- **Config UI Elements:** Increased configuration window height to properly fit Announce Now and Preview buttons.
- **Manual Mode Flickering:** Fixed a bug where releasing the modifier key did not dismiss the underlying scroll listener, causing the mark selector HUD to flicker aggressively.
- **Manual Mode Key States:** Reworked manual mode to accurately respect the modifier key being pressed while already hovering over an enemy, instantly activating the mark selector.
- **Preview & Announce Accuracy:** Reverted behavior so Preview and Announce buttons accurately announce only marks enabled *and* that have a suitable class in the current group.
- **Reset Notification:** The "All marks cleared" chat message now properly respects the Verbose option.

### Quality of Life
- **No Modifier Option:** Added a "NONE" option for the Manual modifier key, allowing you to cycle marks on hover via scroll wheel without holding any extra keys.
- **Invert Scroll Options:** Added a toggle to invert the scroll wheel direction in Manual marking mode.

## 3.0.0

### Major Rewrite & Simplification
The entire architecture of AutoMarkAssist has been vastly simplified, dramatically reducing the codebase size to provide a leaner, more performant, and smarter marking experience.

### New Features & Improvements
- **Smart Group CC Recognition**: CC assignments are now intelligently detected based on your *active group composition*. If you enter a dungeon and do not have a Mage, Moon (Polymorph) will not be assigned as a CC, and instead dynamically rolls over to serve as an extra Kill target.
- **Three Distinct Modes**: Marking modes have been streamlined into `Proximity` (default), `Mouseover`, and `Manual` targeting. These function mutually exclusively to prevent confusing overlapping behaviors.
- **Filter-Aware Manual Scrolling**: The Manual marking mode now precisely respects your disabled marks (for instance, skipping Square if you have it disabled in options) when using the scroll-wheel bindings.
- **Refined Priority System**: Removed the overly-complex configurable pool systems. Marks are now allocated in a fixed, logical order: Kill marks prioritize highest, followed directly by CC marks matching the specific `CreatureType` to your group's present classes.
- **Revamped Configuration UI**: The config panel has been thoroughly rebuilt.
  - **General Tab**: A spacious, organized interface for mode selection, proximity range, announcement settings, and per-mark toggles.
  - **Database Tab**: Browse the internal zone registry—now neatly grouped by Expansion categories—and assign priority overwrites directly. The list dynamically scales to fit longer target names.
  - **About Tab**: Quick reference for commands and the fixed CC mark mapping layout.
- **Auto-Announce on Entry**: The addon will automatically post a well-formatted kill and CC plan to your party chat upon zoning into an instance based on exactly who is in your group.

### Cleaned Up & Removed
- Removed the confusing multi-tier pool system, pool editors, and encounter-specific rule sets.
- Stripped out "skip filler mobs" complexity in favor of a straightforward "Skip Critters/Trivia" toggle.
- Removed legacy sub-priority systems and manual zone-preference bloat.
- Built-in seamless migration: Your old saved variables will be automatically upgraded, converting relevant options while purging obsolete legacy data.

- Removed the Legend tab and fixed Smart Group CC to a single shipped icon layout.

### Bug fixes

- Fixed the Options panel crash caused by the retired Legend-tab helper path.
- Fixed config navigation and related help text after collapsing to four tabs.
- Fixed mark-plan announce and preview so they only show CC labels for classes actually present.
# AutoMarkAssist Changelog

## 2.7.17 (2026-04-13)

### Changed

- Removed the Legend tab and fixed Smart Group CC to a single shipped icon layout: Moon for Polymorph, Diamond for Sap, Square for Trap, Star for Shackle, Circle for Hibernate, and Triangle for Banish.

### Bug fixes

- Fixed the Options panel crash caused by the retired Legend-tab helper path still being referenced during refresh.
- Fixed config navigation and related help text after collapsing the options window back to four tabs.
- Fixed mark-plan announce and preview so they only show CC labels for classes actually present in the live party or raid roster, with the remaining active icons falling back to later kill-order lines.

## 2.7.16 (2026-04-13)

### Bug fixes

- Fixed the Smart Group CC helper block in Core so later runtime functions such as reset, mouseover auto-marking, and live assignment load correctly again.
- Fixed the new visible-pull kill-order and Smart Group CC selection helpers so they no longer leave later Core functions nested or unavailable at runtime.

## 2.7.15 (2026-04-13)

### Changed

- Extended Smart Group CC so the same roster-aware crowd-control solver now works in raid instances as well as 5-player dungeons.
- Locked Skull and Cross as fixed kill-order marks, removed them from Smart Group CC role preferences, and tightened the Legend tab so only active non-CC marks remain editable.

### Bug fixes

- Fixed auto marking so remembered manual icon preferences only apply when they still fit the mob's current tier and the player's active pools.
- Fixed mark preview and announce output so they only list marks that are active in the current pools, which keeps presets like Kill Only aligned with live marking behavior.
- Fixed pool editor updates so Smart Group CC reminders refresh immediately after pool changes instead of waiting for the next group or zone event.

## 2.7.14 (2026-04-13)

### Bug fixes

- Fixed 5-player Smart Dungeon CC so pulls that fit inside the configured kill-order pool use those primary marks first before any dedicated CC icons are assigned.
- Fixed rebalance and death-cascade passes so they now follow the same kill-order-first Smart Dungeon CC rules as the initial mark assignment.
- Updated the Smart Dungeon CC help text so the in-game UI now explains the kill-order-first behavior for small pulls.

## 2.7.13 (2026-04-12)

### Changed

- Added Legend-tab Smart Dungeon CC role-mark preferences so groups can choose which icon each CC type prefers, such as moon for sheep or diamond for sap.

### Bug fixes

- Made the party permission gate explicit so AutoMarkAssist never treats 5-player groups as leader-gated and only applies raid leader or assistant checks inside raids.
- Fixed automatic dungeon CC announcement refresh so changing Smart Dungeon CC role-mark preferences invalidates the cached party-assignment state immediately.
- Fixed Steamvault Spore Bats so they use kill-order marks instead of falling through to the generic bat crowd-control heuristic.
- Corrected release-facing permission messaging so the addon no longer claims party leadership is required where the live client allows party-wide marking.

## 2.7.12 (2026-04-12)

### Changed

- Enabled any party member to mark in 5 man groups.

## 2.7.11 (2026-04-11)

### Changed

- Added a General-tab note that explains proximity and mouseover are mutually exclusive automatic scan modes, while Manual Mode pauses automatic scanning without clearing the preferred automatic mode.

### Bug fixes

- Fixed Manual Mode so it still works when auto-marking is disabled instead of appearing enabled while the HUD and scroll-wheel catcher remain inert.
- Fixed the mouseover update flow so the manual mark picker still opens while auto-marking is off, but automatic mouseover marking remains gated by the enabled toggle.
- Fixed the shared mark-permission check so manual scroll-wheel marking can bypass the auto-marking enabled gate without bypassing raid-marker permission rules.

## 2.7.10 (2026-04-11)

### Changed

- Automatic marking now defaults to proximity as the single active scan mode, and enabling mouseover auto-marking turns proximity off automatically.

### Bug fixes

- Fixed dynamic bump-marking so displaced mobs are re-evaluated with the correct source-specific range rules instead of falling back to generic proximity behavior.
- Fixed rebalance and death-cascade fill passes so mouseover-only setups no longer backfill extra marks through proximity-style scans when proximity mode is disabled.
- Fixed automatic range enforcement so proximity and mouseover marking each respect the player-selected interact-distance option for that specific mode.

## 2.7.9 (2026-04-11)

### Changed

- Added a dedicated mouseover auto-mark toggle so mouseover and proximity scanning can be enabled independently.
- The config window now remembers its last position between sessions.

### Bug fixes

- Fixed automatic mark assignment so configured HIGH, CC, MEDIUM, and LOW pools are respected before any Skull/Cross fallback is considered.
- Fixed shared range checks so disabling proximity no longer breaks mouseover auto-marking, and mouseover range limits only apply to mouseover-driven marking.
- Fixed stale settings state between slash commands, the minimap popup, and the General tab so the visible controls now reflect the real addon state immediately.
- Fixed the Repeat Party CC button state so it no longer appears available while the addon is disabled or Manual Mode is active.
- Fixed manual scroll-order drag-and-drop so dropping icons lands in the correct slot even when the options frame is scaled down.

## 2.7.8 (2026-04-07)

### Changed

- Updated the automated packaging label template again so newly published CurseForge files use the hyphenated `AutoMarkAssist-vX.Y.Z` format.
- Refreshed the CurseForge project description so it now points to the public GitHub repository and issue tracker for source browsing and bug reports.

## 2.7.7 (2026-04-07)

### Changed

- Updated the automated GitHub and CurseForge packaging label so published CurseForge files now include the addon name instead of showing only the raw version number.

## 2.7.6 (2026-04-07)

### New features

- Added announcement formatting controls so mark and dungeon CC reminders can be posted line-by-line or as a single chat line.
- Added a customizable chat prefix for announcements, including the option to leave it blank and remove the prefix entirely.
- Added a General-tab toggle and `/ama ccauto` command so automatic dungeon Smart CC reminders can be disabled while keeping manual `/ama ccannounce` repeats available.
- Added public GitHub packaging metadata and a tag-driven release workflow for automated CurseForge uploads.

### Bug fixes

- Fixed raid-marker permission checks so party auto-marking only runs for the actual party leader, while raids still require leader or assistant permissions.
- Suppressed mark and dungeon CC announcements when the player cannot place raid markers, preventing chat from implying active marks when Blizzard blocks icon placement.

## 2.7.5 (2026-04-06)

### Bug fixes

- Fixed Smart Dungeon CC so dungeon CC marks now match the party's actual CC-capable classes instead of being assigned greedily by party order.
- Smart Dungeon CC now respects kill-only CC pool setups and no longer announces dedicated CC roles when no dedicated CC marks are configured.
- Dungeon CC reminders now refresh automatically when the party roster changes inside a dungeon.
- Disabling the addon now suppresses announcements, Smart CC behavior, and runtime mark-maintenance actions until the addon is re-enabled.

## 2.7.4 (2026-04-06)

### Bug fixes

- Fixed the reset-defaults helper text anchor so it now sits below the Reset Addon Settings to Defaults button instead of overlapping it.
- Kept the earlier General-tab spacing fixes in place so the settings dialog now has stable vertical spacing across the full tab.

## 2.7.3 (2026-04-06)

### Bug fixes

- Fixed the Manual Mode wheel-direction row so the Scroll Down Starts Left control no longer clips against the next section.
- Added more bottom spacing in the General tab so the reset-defaults helper text stays fully visible at the bottom of the options window.

## 2.7.2 (2026-04-06)

### Bug fixes

- Fixed the General-tab Smart Dungeon CC row so the checkbox label no longer collides with the Repeat Party CC and How It Works buttons.
- Gave the wrapped Smart Dungeon CC helper text and reset-defaults helper text more reserved space so they stay fully visible in the settings dialog.
- Added extra bottom padding to the General tab scroll child so the reset-defaults note is no longer cut off at the bottom edge.

## 2.7.1 (2026-04-06)

### Changed

- Login no longer auto-opens the About or What's New dialog. Release notes remain available from the About tab or with /ama whatsnew.
- Existing profiles now get a one-time chat confirmation when the automated-defaults migration runs.

### Bug fixes

- Fixed the General-tab layout so wrapped Smart Dungeon CC and reset note text no longer overlap nearby controls.

## 2.7.0 (2026-04-06)

### New features

- Dungeon Smart CC can now announce party CC responsibilities in party chat after the initial dungeon-entry group scan.
- Added repeat reminder controls for dungeon CC assignments in the General tab, the minimap menu, and with /ama ccannounce, /ama repeatcc, or /ama ccremind.

### Changed

- Updated the Smart Dungeon CC help text and General-tab messaging so the automatic announcement and reminder flow is documented in the addon UI.

## 2.6.0 (2026-04-06)

### New features

- Expanded the built-in mob database so every supported Classic raid through MoP now has shipped coverage, including new Wrath, Cataclysm, and Mists raid zone entries plus their aliases and Database tab ordering.

### Changed

- Reviewed the new later-expansion raid priorities again and kept the shipped data conservative by focusing on dangerous trash, key encounter adds, and useful boss fallback targets.
- New profiles now default to proximity marking and Smart Dungeon CC so the addon starts in its most automated mode without extra setup.
- Existing profiles now receive a one-time migration that turns on proximity marking and Smart Dungeon CC to match the new automated defaults.
- The General-tab reset-to-defaults action now restores clean copied defaults and reapplies the related runtime state safely.
- Updated Wrath, Cataclysm, and MoP TOC metadata plus the in-addon What's New text so the release-facing coverage descriptions match the data each client actually loads.

## 2.5.0 (2026-04-06)

### New features

- Expanded the built-in mob database so every supported Classic raid through MoP now has shipped coverage, including new Wrath, Cataclysm, and Mists raid zone entries plus their aliases and Database tab ordering.
- Added a first-load What's New popup for new versions, with the latest notes re-openable from the About tab or with /ama whatsnew.
- Added optional Smart Dungeon CC in 5-player dungeons that adapts CC marks to party composition and creature type, with a General-tab toggle/help button plus /ama smartcc and /ama groupcc.

### Changed

- Reviewed dungeon and raid priority data again and kept the later-expansion raid entries conservative by focusing on dangerous trash, key encounter adds, and useful boss fallback targets.
- Announce and preview output now follows the active CC pool so Smart Dungeon CC and CC-limit messaging match live assignment behavior.
- Updated addon wording, TOC notes, README, and CurseForge docs so each client now advertises the full dungeon and raid coverage it actually loads.

## 2.4.9 (2026-04-05)

### New features

- Added an optional Smart Dungeon CC mode that adapts CC-mark assignment to the current 5-player group composition and the target's creature type.
- Added `/ama smartcc` and `/ama groupcc` slash toggles plus a General-tab help button for the new dungeon-only CC behavior.

### Changed

- Reviewed dungeon and raid priority data again and kept the highest-confidence encounter-specific TBC raid add handling, with clarifying database comments where the priorities are intentional.
- Legend preview and announce output now use the active CC pool so Smart Dungeon CC and CC-limit messaging stay aligned with live assignment behavior.

## 2.4.8 (2026-04-05)

### New features

- Added built-in mob database coverage for every Classic raid and every TBC raid, including aliases and Database tab ordering for the new instance entries.
- Added a first-load What's New popup for new versions, with the latest notes re-openable from the About tab or `/ama whatsnew`.

### Changed

- Updated the About tab, slash-command guidance, and TOC metadata so the addon now describes supported instances instead of dungeon-only coverage.
- Refreshed the addon documentation and added a root README to reflect raid coverage through TBC.
- Performed a second-pass raid data review and kept Hyjal Summit entries to the highest-confidence trash names pending live in-game verification.

## 2.4.7 (2026-04-03)

- Removed the redundant square minimap positioning toggle from the General tab and minimap tooltip. The minimap button now follows the actual minimap shape automatically.
- Renamed the Legend tab preview action to make it clear that preview is local chat output, not a group-channel announcement.
- Tightened the About tab overview and command section so the visible slash-command list only shows commands that actually exist in the addon.

## 2.4.6 (2026-04-03)

### New features
- Raid-safe mark syncing across party and raid target tokens.
- Added in-game help popups for sub-priority and manual mark saving.
- Added a General-tab toggle for square minimap button positioning.

### Changed
- Between-pull refresh now preserves visible raid icons when combat ends.
- Manual mouseover marking now previews any icon and applies on close or target switch.
- Manual mode help text and picker hints were clarified.

### Bug fixes
- Raid leader and assistant permissions are respected before setting icons.
- Local cleanup and rebalance no longer clear or steal icons from other players.
- Fixed stale manual picker state after moving a mark from one mob to another.

## 2.4.5 (2026-03-24)

### New features

- In-game sub-priority editor in the Database tab. Each mob row now includes a dedicated Sub tie-break column so you can set custom per-zone sub-priorities without slash commands. Left-click cycles 1-9; right-click clears the custom value.

### Changed

- Database tab sorting now honours effective sub-priority inside each main tier, so custom and built-in tie-breaks are visible in the editor.
- Reset/delete actions in the Database tab now clear stored sub-priority overrides as well as priority overrides/removals.

## 2.4.4 (2026-03-19)

### New features

- Sub-priority tie-break support inside each tier. Auto-marking now supports an optional per-mob sub-priority (1 = highest) to break ties when multiple mobs share the same main tier (HIGH/CC/MEDIUM/LOW). Lower sub-priority mobs now claim better icons first, including dynamic bumping and death rebalancing/cascade.
- In-combat mark lock toggle. Added "Lock existing auto-marks while in combat" in General -> Dynamic Marking and slash alias /ama lock (or /ama combatlock). When enabled, auto marking/reassignment is paused during combat so Skull/Cross stay stable unless you mark manually.

### Changed

- Added built-in Shadow Labyrinth tie-break defaults for high-threat casters (Cabal Shadow Priest before Cabal Hexer, then Cabal Warlock, then Cabal Cultist).
- Minimap tooltip now shows the current Combat mark lock status.

## 2.4.3 (2026-03-15)

### Bug fixes

- Fixed option buttons not retaining visible selected state. Range and CC limit buttons now keep their active highlight after mouse hover/leave transitions, so the selected value remains obvious in the UI.
- Fixed inconsistent proximity fallback range. Runtime proximity checks and minimap tooltip fallback now default to ~28 yd when a saved proximityRange value is missing, matching UI/default DB behavior instead of falling back to ~10 yd.
- Fixed combat-log death parsing race window. COMBAT_LOG_EVENT_UNFILTERED now reads CombatLogGetCurrentEventInfo() once per event, avoiding potential field desync under heavy combat log throughput.

## 2.4.2 (2026-03-14)

### New features

- CC Limit setting. A new "CC Limit" row in the Dynamic Marking section of the General tab lets you cap how many mobs receive CC (crowd control) marks per pull. Choose from No Limit (default), 1, 2, or 3. When the limit is reached, additional CC-priority mobs are automatically downgraded to kill-order marks. Example: set to 2 when you have two Mages in the group, and only 2 mobs will receive CC marks while the rest get kill-order icons.
- Announce / Preview honours CC Limit. The /ama announce chat output and the Legend tab preview now omit CC-pool marks that exceed the configured CC limit, so the announced plan matches what the addon will actually assign.

### Bug fixes

- Fixed mouseover marking silently disabled when proximity mode is ON. The UPDATE_MOUSEOVER_UNIT handler contained a not proximityMode guard that blocked all mouseover auto-marks whenever the proximity scanner was also enabled. Because the UI presents the two features as independent toggles, users enabling both got only proximity marking while mouseover appeared broken. The guard was redundant - AssignMark already skips mobs tracked in markedGUIDs, preventing double-assignment. Removed the proximity guard so both modes now coexist correctly.

## 2.4.1 (2026-03-11)

### Bug fixes

- Fixed mark picker HUD freezing in manual mode. The mouseover range gate was evaluated before the manual-mode check in the UPDATE_MOUSEOVER_UNIT handler. When a mob was beyond the configured interact distance, the handler returned early and ShowMarkPickerForMouseover() was never called - the HUD stayed frozen on the previous target and could not be dismissed. The range gate now only applies to auto-marking modes; manual mode always updates the picker regardless of distance.

## 2.4.0 (2026-03-10)

### Changed

- Database tab zone list reversed. Expansion groups now display with the latest (current) expansion at the top, so the dungeons you are actually running are immediately visible. "Other" (user-added) zones remain at the bottom.

### Bug fixes

- Fixed priority cycle not reaching BOSS/HIGH/CC. Left-clicking a mob in the Database tab now wraps the priority cycle from REMOVED back to BOSS instead of resetting to the base priority. Previously, mobs with a base priority of MEDIUM or lower could never be overridden to HIGH, CC, or BOSS - the cycle only advanced forward and then snapped back to the base value.

## 2.3.0 (2026-03-10)

### New features

- Mouseover range limit. A new "Mouseover Range" section on the General tab lets you cap the distance at which mouseover marking triggers. Choose from ~11 yd, ~10 yd, or ~28 yd (default). Prevents accidental marks on mobs visible across the map. The setting applies to both auto and manual mouseover modes. Enabled by default at ~28 yd (follow range).

## 2.2.0 (2026-03-10)

### Changed

- Dropped Retail (Mainline) support. Blizzard made SetRaidTarget and other marking APIs fully protected in Patch 12.0.0 (Midnight), making it impossible for addons to apply raid target icons during combat. After four rounds of workarounds (v2.1.2-v2.1.5) that could not resolve the "blocked from an action" popups, Retail support has been removed. AutoMarkAssist is now a Classic-only addon.

### Removed

- Deleted AutoMarkAssist_Mainline.toc and AutoMarkAssist_DB_Retail.lua.
- Removed all Retail code paths: IS_RETAIL/IS_CLASSIC flags, GameSetRaidTarget wrapper, SecureActionButtonTemplate workaround, combat-lockdown helpers, "Apply Mark Keybind" config section, nameplate-range proximity branch, and Retail edition string.
- All mark calls now use pcall(SetRaidTarget, ...) directly.
- Updated all documentation to reflect Classic-only status.

## 2.1.x (2.1.0 - 2.1.5)

### 2.1.0 - Classic variant support (2026-03-09)

- Five Classic variants from a single addon folder. Classic Era (Vanilla), TBC Classic, WotLK Classic, Cata Classic, and MoP Classic each get their own TOC file. WoW's multi-TOC loader selects the correct one automatically.
- Cumulative dungeon coverage. Each variant loads its expansion's dungeons plus all earlier ones: Vanilla 19, TBC 35, WotLK 51, Cata 63, MoP 69.
- Modular database architecture. Per-expansion modules (_DB_Classic.lua through _DB_MoP.lua) loaded cumulatively by each TOC.
- Dynamic edition string. The About tab auto-detects the loaded expansion range and dungeon count.

### 2.1.1 - 2.1.5 - Retail workarounds (superseded by 2.2.0)

- Updated TOC interface versions for Midnight and all Classic variants.
- Attempted four rounds of Retail taint/combat-lockdown fixes (custom popup menu, taint-free scroll frames, SecureActionButtonTemplate keybind approach, InCombatLockdown() guards). All superseded by the full Retail removal in v2.2.0.

## 2.0.0 (2026-03-09)

- Expansion-grouped Database tab. Zone list grouped by expansion with teal header labels. User-added zones under "Other".

## 1.9.0 (2026-03-09)

- Unified packaging. package.ps1 produces a single release zip covering all supported game versions.

## 1.8.5 (2026-03-09)

- Invert Mouse Scroll toggle for manual mode.
- Manual mark chat messages moved to verbose only.
- Database tab priority button order: BOSS first.
- Fixed Database tab toolbar overflow on small resolutions.

## 1.8.4 (2026-03-08)

- General and Database rows use relative anchoring.
- Fixed responsive config clamping on small UI sizes.
- Fixed manual mark HUD overflow on tiny screens.

## 1.8.3 (2026-03-08)

- Fixed reset marks keybind firing twice per press.
- Removed "Mark tracking reset." chat notification.

## 1.8.2 (2026-03-08)

- Hide minimap button checkbox in Core Settings.
- Fixed General tab content overflowing the config window.

## 1.8.1 (2026-03-08)

- Reset Marks keybind (General tab). Defaults to Middle Mouse.
- Middle-click minimap resets marks. /ama clear alias added.
- Pools/Legend tabs reordered Skull-first. Preview Legend uses configured channel.
- Fixed Preview Legend not picking up unsaved edits.

## 1.8.0 (2026-03-09)

- Mark legend and announce overhaul with chat-safe tokens.
- Reset All Settings button. Redesigned mark pools (exclusive-assignment grid).
- Chat feedback on every toggle. Expanded minimap tooltip.
- Removed requireLeader and markOnTarget features. Manual tab merged into General.
- Database tab integrated into config window. About tab redesigned.
- Fixed checkboxes always appearing ON, click region not responding, SendChatMessage escape codes, dead zone-keyed DB lookups.

<details>
<summary>Earlier versions (1.0.0 - 1.7.2)</summary>

### 1.7.2

- Mob database moved inside Options window as the "Database" tab.

### 1.7.1

- Fixed General tab overflow. Rebuilt Mob Database viewer.

### 1.7.0 - Architecture overhaul

- Six-file module split. Single AutoMarkAssist global table. DB defaults back-fill on load.

### 1.6.x (1.6.0 - 1.6.9)

- Configurable scroll wheel mark order. Proximity mode defaults to OFF.
- Minimap dot rendering fixes. Scroll wheel camera zoom fix. Config overflow fix.

### 1.5.x (1.5.0 - 1.5.9)

- Manual mode (scroll-wheel marking) with modifier key and mark picker HUD.
- Auto-mark reproduces manual assignments as zone preferences.

### 1.4.x (1.4.0 - 1.4.9)

- Minimap status indicator. Encounter intelligence for "adds first" bosses.
- Three-pass mark reset. Rebalance on death defaults to ON.

### 1.3.x (1.3.0 - 1.3.9)

- PRIORITY_BOSS tier. Dynamic bump-marking cascade on mob death.
- All 16 TBC Anniversary dungeons populated. "Skip pack filler mobs" option.

### 1.2.0

- Dynamic bump-marking, rebalance on death, Skull/Cross guarantee.

### 1.1.0

- Mob database editor, proximity mode, full configuration UI.

### 1.0.0

- Initial release. Priority-based proximity marking for TBC Anniversary dungeons.

</details>


