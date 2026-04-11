-- AutoMarkAssist_Events.lua
-- Zone tracking, event handling, proximity scanner, and slash commands.
-- Loaded last (after AutoMarkAssist_Config.lua).

local AMA = AutoMarkAssist

-- ============================================================
-- FILE-SCOPE CONSTANTS
-- ============================================================

local PRIORITY_HIGH   = "HIGH"
local PRIORITY_CC     = "CC"
local PRIORITY_MEDIUM = "MEDIUM"
local PRIORITY_LOW    = "LOW"

local SCAN_INTERVAL   = 0.5   -- seconds between proximity scans
local showWhatsNewOnWorldEnter = false
local showAutomationDefaultsMigrationNoticeOnWorldEnter = false
local pendingDungeonCCAnnouncementAt = nil
local lastDungeonCCAnnouncementKey = nil

local function IsAutoDungeonCCAnnouncementEnabled()
    if not AutoMarkAssistDB or not AutoMarkAssistDB.enabled then
        return false
    end
    if AutoMarkAssistDB.manualMode then
        return false
    end
    if not (AMA.IsAutoDungeonCCAnnouncementEnabled
        and AMA.IsAutoDungeonCCAnnouncementEnabled()) then
        return false
    end
    if not (AMA.IsDungeonSmartCCEnabled and AMA.IsDungeonSmartCCEnabled()) then
        return false
    end
    if AMA.CanMarkReason then
        local canMark = AMA.CanMarkReason()
        if not canMark then
            return false
        end
    end
    return true
end

local function BuildDungeonCCAnnouncementKey()
    if not IsAutoDungeonCCAnnouncementEnabled() then
        return nil
    end

    local zoneName = AMA.currentZoneName or GetRealZoneText() or ""
    if zoneName == "" then
        return nil
    end

    local members = {}
    for _, groupToken in ipairs({ "player", "party1", "party2", "party3", "party4" }) do
        if UnitExists(groupToken) then
            local name = UnitName(groupToken)
            local _, classTag = UnitClass(groupToken)
            if name and name ~= "" then
                members[#members + 1] = string.format("%s:%s", name, classTag or "?")
            end
        end
    end

    if #members == 0 then
        return nil
    end

    local configuredCCPool = (AMA.GetConfiguredPool and AMA.GetConfiguredPool(PRIORITY_CC)) or {}
    local poolParts = {}
    for _, markIdx in ipairs(configuredCCPool) do
        poolParts[#poolParts + 1] = tostring(markIdx)
    end

    return string.format(
        "%s|%d|%s|%s",
        zoneName,
        AutoMarkAssistDB.ccLimit or 0,
        table.concat(poolParts, ","),
        table.concat(members, ";"))
end

local function ClearDungeonCCAnnouncementState(resetLastKey)
    pendingDungeonCCAnnouncementAt = nil
    if resetLastKey then
        lastDungeonCCAnnouncementKey = nil
    end
end

local function QueueDungeonCCAnnouncement(delaySeconds)
    if not IsAutoDungeonCCAnnouncementEnabled() then
        ClearDungeonCCAnnouncementState(true)
        return
    end

    pendingDungeonCCAnnouncementAt = (GetTime and GetTime() or 0) + (delaySeconds or 1.5)
end

function AMA.RefreshDungeonCCAnnouncementQueue(delaySeconds)
    if IsAutoDungeonCCAnnouncementEnabled() then
        QueueDungeonCCAnnouncement(delaySeconds or 1.5)
    else
        ClearDungeonCCAnnouncementState(true)
    end
end

local function TryAnnouncePendingDungeonCC()
    if not pendingDungeonCCAnnouncementAt then
        return
    end
    if (GetTime and GetTime() or 0) < pendingDungeonCCAnnouncementAt then
        return
    end

    pendingDungeonCCAnnouncementAt = nil

    local announcementKey = BuildDungeonCCAnnouncementKey()
    if not announcementKey then
        return
    end
    if announcementKey == lastDungeonCCAnnouncementKey then
        return
    end

    if AMA.AnnounceDungeonSmartCCAssignments
        and AMA.AnnounceDungeonSmartCCAssignments() then
        lastDungeonCCAnnouncementKey = announcementKey
    end
end

-- ============================================================
-- UNIT TOKEN LIST
-- Populated once at load time.  All proximity and mouseover mark
-- decisions scan this list.  Nameplate tokens are included so
-- out-of-party mobs are reachable in open-world / dungeon context.
-- ============================================================

do  -- SCAN_UNIT_TOKENS construction scope
    AMA.SCAN_UNIT_TOKENS = {
        "target", "focus", "mouseover",
        "player",
        "party1",  "party2",  "party3",  "party4",
        "party1target", "party2target", "party3target", "party4target",
    }
    -- Raid roster
    for i = 1, 40 do
        AMA.SCAN_UNIT_TOKENS[#AMA.SCAN_UNIT_TOKENS + 1] = "raid" .. i
        AMA.SCAN_UNIT_TOKENS[#AMA.SCAN_UNIT_TOKENS + 1] = "raid" .. i .. "target"
    end
    -- Nameplate tokens for open-world marking
    for i = 1, 20 do
        AMA.SCAN_UNIT_TOKENS[#AMA.SCAN_UNIT_TOKENS + 1] = "nameplate" .. i
    end
end  -- SCAN_UNIT_TOKENS construction scope

-- ============================================================
-- ZONE DATABASE HELPER
-- Merges AutoMarkAssist_MobDB with user overrides/removals.
-- Stores the merged result in AMA.currentZoneMobDB so Core can
-- look up mob priorities without file-crossing function calls.
-- ============================================================

local function UpdateZone()
    local rawZone  = GetRealZoneText() or ""
    local resolved = AMA.ResolveZoneName(rawZone)

    if resolved == AMA.currentZoneName then return end   -- no change
    AMA.currentZoneName = resolved

    local merged = AMA.BuildZoneMobDB(resolved)
    if not merged then
        AMA.currentZoneMobDB = nil
        AMA.VPrint("Zone: " .. rawZone .. " (no mob DB entry)")
        return
    end
    AMA.currentZoneMobDB = merged

    AMA.VPrint(string.format(
        "Zone: |cFFFFFFFF%s|r  DB entries: |cFF00FF00%d|r",
        resolved, AMA.CountTable(merged)))
    AMA.ResetState()
end

-- ============================================================
-- EVENT FRAME
-- ============================================================

local frame = CreateFrame("Frame", "AutoMarkAssistEventFrame", UIParent)

frame:RegisterEvent("ADDON_LOADED")
-- Other events are registered in ADDON_LOADED once the DB is ready.

-- ============================================================
-- RESET MARKS KEYBIND
-- Maps the user's chosen key to a hidden button via override bindings.
-- Uses SetOverrideBindingClick (addon-safe) instead of SetBindingClick
-- to avoid tainting Blizzard's global keybinding system.
-- ============================================================

local resetKeyBtn = CreateFrame("Button", "AMA_ResetMarksButton", UIParent)
resetKeyBtn:SetSize(1, 1)
resetKeyBtn:Hide()
resetKeyBtn:RegisterForClicks("AnyUp")
resetKeyBtn:SetScript("OnClick", function()
    if AMA.ResetState then AMA.ResetState() end
end)

function AMA.ApplyResetKeybind()
    ClearOverrideBindings(resetKeyBtn)
    local key = AutoMarkAssistDB and AutoMarkAssistDB.resetMarksKey
    if key and key ~= "" then
        SetOverrideBindingClick(resetKeyBtn, true, key, "AMA_ResetMarksButton")
        AMA.VPrint("Reset-marks keybind set to: " .. key)
    end
end

-- ============================================================
-- PROXIMITY SCANNER  (OnUpdate)
-- Runs every SCAN_INTERVAL seconds while loaded.
-- Skips when auto-marking is disabled, in manual mode, or
-- the player is not in a group.
-- ============================================================

local scanElapsed = 0

frame:SetScript("OnUpdate", function(self, elapsed)
    scanElapsed = scanElapsed + elapsed
    if scanElapsed < SCAN_INTERVAL then return end
    scanElapsed = 0

    if not AutoMarkAssistDB then return end

    TryAnnouncePendingDungeonCC()

    if not AutoMarkAssistDB.enabled then return end
    if AutoMarkAssistDB.manualMode  then return end
    if not AutoMarkAssistDB.proximityMode then return end
    if AMA.IsCombatMarkLockActive and AMA.IsCombatMarkLockActive() then return end
    if not (IsInGroup() or IsInRaid()) then return end

    local canMark = AMA.CanMarkReason()
    if not canMark then return end

    if AMA.SyncVisibleMarks then
        AMA.SyncVisibleMarks()
    end

    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS) do
        if UnitExists(token) and UnitCanAttack("player", token) then
            local isDead = UnitIsDead and UnitIsDead(token)
            if not isDead then
                AMA.AssignMark(token, false, "proximity")
            end
        end
    end
end)

-- ============================================================
-- EVENT HANDLER  (OnEvent)
-- ============================================================

frame:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...

    -- ──────────────────────────────────────────────────────────
    -- ADDON_LOADED
    -- Back-fill any keys that are missing from the saved DB, then
    -- initialise UI state.
    -- ──────────────────────────────────────────────────────────
    if event == "ADDON_LOADED" and arg1 == AMA.ADDON_NAME then
        -- Ensure the saved-variable table exists.
        if not AutoMarkAssistDB then
            AutoMarkAssistDB = {}
        end

        local hadExistingSavedSettings = next(AutoMarkAssistDB) ~= nil

        -- Back-fill missing keys with defaults.
        if AMA.BackfillMissingDBDefaults then
            AMA.BackfillMissingDBDefaults(AutoMarkAssistDB)
        end

        AMA.NormalizeZoneScopedMobSettings()

        -- Migrate removed announce channels to the default.
        local ch = AutoMarkAssistDB.announceChannel
        if ch == "YELL" or ch == "LOCAL_DEF" then
            AutoMarkAssistDB.announceChannel = "PARTY"
        end

        AMA.NormalizeSavedSettings()
        local didApplyAutomationDefaultsMigration = false
        if AMA.ApplyAutomationDefaultsMigration then
            didApplyAutomationDefaultsMigration =
                AMA.ApplyAutomationDefaultsMigration()
        end
        showAutomationDefaultsMigrationNoticeOnWorldEnter =
            hadExistingSavedSettings and didApplyAutomationDefaultsMigration
        showWhatsNewOnWorldEnter = AutoMarkAssistDB.lastSeenWhatsNew ~= AMA.VERSION

        -- Register gameplay events now that the DB is present.
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        frame:RegisterEvent("GROUP_ROSTER_UPDATE")
        frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        frame:RegisterEvent("RAID_TARGET_UPDATE")

        -- Initialise minimap button position and state.
        AMA.UpdateMinimapPosition()
        AMA.UpdateMinimapState()
        if AutoMarkAssistDB.minimapHide then
            AMA.minimapButton:Hide()
        end

        AMA.Print("v" .. AMA.VERSION .. " loaded.  Type |cFFAAAAAA/ama|r for options.  |cFF444444by|r |cFFFFD700" .. AMA.AUTHOR .. "|r")

        -- Apply the user's reset-marks keybind.
        AMA.ApplyResetKeybind()

    -- ──────────────────────────────────────────────────────────
    -- PLAYER_ENTERING_WORLD
    -- ──────────────────────────────────────────────────────────
    elseif event == "PLAYER_ENTERING_WORLD" then
        AMA.currentZoneName = ""    -- force UpdateZone to re-resolve
        UpdateZone()
        AMA.ResetState()
        if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
        AMA.ApplyResetKeybind()
        AMA.RefreshDungeonCCAnnouncementQueue(1.5)
        if showAutomationDefaultsMigrationNoticeOnWorldEnter then
            showAutomationDefaultsMigrationNoticeOnWorldEnter = false
            AMA.Print("Applied the latest settings migration for this profile. Automatic marking now keeps proximity as the single default scan mode instead of enabling proximity and mouseover together.")
        end
        if showWhatsNewOnWorldEnter then
            showWhatsNewOnWorldEnter = false
            AMA.Print("What's new in v" .. AMA.VERSION .. ": open |cFFAAAAAA/ama whatsnew|r or use the About tab when you want to review the release notes.")
            AutoMarkAssistDB.lastSeenWhatsNew = AMA.VERSION
        end

    -- ──────────────────────────────────────────────────────────
    -- ZONE_CHANGED_NEW_AREA
    -- ──────────────────────────────────────────────────────────
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        AMA.currentZoneName = ""    -- force UpdateZone to re-resolve
        UpdateZone()
        AMA.ResetState()

        if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
        AMA.RefreshDungeonCCAnnouncementQueue(1.5)

    -- ──────────────────────────────────────────────────────────
    -- GROUP_ROSTER_UPDATE
    -- Rebuild party-role announcements when dungeon composition changes.
    -- ──────────────────────────────────────────────────────────
    elseif event == "GROUP_ROSTER_UPDATE" then
        if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
        AMA.RefreshDungeonCCAnnouncementQueue(1.0)

    -- ──────────────────────────────────────────────────────────
    -- RAID_TARGET_UPDATE
    -- Keep local bookkeeping aligned with marks placed by other players.
    -- ──────────────────────────────────────────────────────────
    elseif event == "RAID_TARGET_UPDATE" then
        if not (AMA.IsAddonEnabled and AMA.IsAddonEnabled()) then return end
        if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end

    -- ──────────────────────────────────────────────────────────
    -- UPDATE_MOUSEOVER_UNIT
    -- ──────────────────────────────────────────────────────────
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        if not AutoMarkAssistDB then return end
        local addonEnabled = AMA.IsAddonEnabled and AMA.IsAddonEnabled()
        if not addonEnabled and not AutoMarkAssistDB.manualMode then return end
        if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
        -- Manual mode always gets the HUD update regardless of distance;
        -- the player is explicitly choosing marks via the scroll wheel.
        if AutoMarkAssistDB.manualMode then
            AMA.ShowMarkPickerForMouseover()
            return
        end
        if not addonEnabled then
            return
        end
        if AutoMarkAssistDB.mouseoverMode == false then
            return
        end
        if AMA.IsCombatMarkLockActive and AMA.IsCombatMarkLockActive() then
            return
        end
        if AutoMarkAssistDB.enabled then
            AMA.AssignMark("mouseover", false, "mouseover")
        end

    -- ──────────────────────────────────────────────────────────
    -- COMBAT_LOG_EVENT_UNFILTERED
    -- Track unit deaths to release marks and optionally rebalance.
    -- ──────────────────────────────────────────────────────────
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not (AMA.IsAddonEnabled and AMA.IsAddonEnabled()) then return end
        local _, subevent, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
        if subevent ~= "UNIT_DIED" then return end
        if not destGUID then return end

        -- Only care about mobs we are currently tracking.
        if not AMA.markedGUIDs[destGUID] then return end

        local wasLocal = AMA.IsLocalMark and AMA.IsLocalMark(destGUID)

        AMA.ReleaseMark(destGUID)

        if wasLocal
        and AutoMarkAssistDB and AutoMarkAssistDB.rebalanceOnDeath
        and not (AMA.IsCombatMarkLockActive and AMA.IsCombatMarkLockActive()) then
            AMA.CascadeMarksAfterDeath()
        end

    -- ──────────────────────────────────────────────────────────
    -- PLAYER_REGEN_ENABLED  (left combat)
    -- Refresh visible mark state when configured to do so.
    -- ──────────────────────────────────────────────────────────
    elseif event == "PLAYER_REGEN_ENABLED" then
        if not (AMA.IsAddonEnabled and AMA.IsAddonEnabled()) then return end
        if AutoMarkAssistDB and AutoMarkAssistDB.autoReset and AMA.SyncVisibleMarks then
            AMA.SyncVisibleMarks()
            AMA.VPrint("Left combat -- preserved visible marks.")
        end
    end
end)

-- ============================================================
-- SLASH COMMANDS
-- /ama  and  /automarkassist
-- ============================================================

SLASH_AUTOMARKASSIST1 = "/ama"
SLASH_AUTOMARKASSIST2 = "/automarkassist"

SlashCmdList["AUTOMARKASSIST"] = function(msg)
    if not AutoMarkAssistDB then
        AMA.Print("Saved variables not yet loaded.  Please wait a moment.")
        return
    end

    local cmd = string.lower(string.match(msg or "", "^%s*(%S*)") or "")
    local argStr = string.match(msg or "", "^%s*%S+%s*(.-)%s*$") or ""

    if cmd == "" or cmd == "options" or cmd == "config" then
        AMA.OpenConfigFrame()

    elseif cmd == "whatsnew" or cmd == "news" then
        if AMA.ShowLatestWhatsNew then
            AMA.ShowLatestWhatsNew()
        else
            AMA.OpenConfigFrame(5)
        end

    elseif cmd == "enable" then
        AutoMarkAssistDB.enabled = true
        AMA.UpdateMinimapState()
        AMA.RefreshDungeonCCAnnouncementQueue(0.5)
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.Print("Auto-marking |cFF00FF00ENABLED|r.")

    elseif cmd == "disable" then
        AutoMarkAssistDB.enabled = false
        AMA.UpdateMinimapState()
        AMA.RefreshDungeonCCAnnouncementQueue(0.5)
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.Print("Auto-marking |cFFFF0000DISABLED|r.")

    elseif cmd == "toggle" then
        AutoMarkAssistDB.enabled = not AutoMarkAssistDB.enabled
        AMA.UpdateMinimapState()
        AMA.RefreshDungeonCCAnnouncementQueue(0.5)
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.Print("Auto-marking " .. (AutoMarkAssistDB.enabled
            and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r"))

    elseif cmd == "reset" or cmd == "clear" then
        AMA.ResetWithMessage()

    elseif cmd == "announce" then
        if AutoMarkAssist_Announce then
            AutoMarkAssist_Announce()
        else
            AMA.Print("Announce module not loaded.")
        end

    elseif cmd == "ccannounce" or cmd == "repeatcc" or cmd == "ccremind" then
        if AutoMarkAssist_AnnounceDungeonSmartCC then
            AutoMarkAssist_AnnounceDungeonSmartCC({ showFeedback = true })
        else
            AMA.Print("Dungeon CC announce module not loaded.")
        end

    elseif cmd == "ccauto" or cmd == "autocc" or cmd == "autoccannounce" then
        AutoMarkAssistDB.autoAnnounceDungeonCC =
            not AutoMarkAssistDB.autoAnnounceDungeonCC
        AMA.Print("Automatic dungeon CC announcements: "
            .. (AutoMarkAssistDB.autoAnnounceDungeonCC
                and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))
        AMA.RefreshDungeonCCAnnouncementQueue(0.5)
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end

    elseif cmd == "preview" then
        if AutoMarkAssist_Preview then
            AutoMarkAssist_Preview()
        else
            AMA.Print("Announce module not loaded.")
        end

    elseif cmd == "manual" then
        AutoMarkAssistDB.manualMode = not AutoMarkAssistDB.manualMode
        AMA.UpdateMinimapState()
        AMA.RefreshDungeonCCAnnouncementQueue(0.5)
        if AutoMarkAssistDB.manualMode then
            AMA.Print("Manual mode |cFFFFD700ON|r - hover a mob and scroll to assign marks.")
        else
            AMA.Print("Manual mode |cFF888888OFF|r - auto-marking resumed.")
        end
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end

    elseif cmd == "verbose" then
        AutoMarkAssistDB.verbose = not AutoMarkAssistDB.verbose
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.Print("Verbose output: " .. (AutoMarkAssistDB.verbose
            and "|cFFFFD700ON|r" or "|cFF888888OFF|r"))

    elseif cmd == "smartcc" or cmd == "groupcc" then
        AutoMarkAssistDB.smartDungeonCC = not AutoMarkAssistDB.smartDungeonCC
        AMA.Print("Smart dungeon CC: " .. (AutoMarkAssistDB.smartDungeonCC
            and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))
        AMA.RefreshDungeonCCAnnouncementQueue(0.5)
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end

    elseif cmd == "lock" or cmd == "combatlock" then
        AutoMarkAssistDB.lockMarksInCombat = not AutoMarkAssistDB.lockMarksInCombat
        AMA.Print("Combat mark lock: " .. (AutoMarkAssistDB.lockMarksInCombat
            and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end

    elseif cmd == "sub" then
        local mobName, subRaw = string.match(argStr, "^(.-)%s+([%-%d]+)$")
        mobName = mobName and mobName:gsub("^%s*(.-)%s*$", "%1") or nil
        local sub = tonumber(subRaw or "")
        local zoneName = AMA.currentZoneName
        if not zoneName or zoneName == "" then
            AMA.Print("No active zone. Enter a supported dungeon or raid first.")
            return
        end
        if not mobName or mobName == "" or not sub then
            AMA.Print("Usage: /ama sub <mob name> <number>")
            return
        end
        sub = math.floor(sub)
        if sub < 1 then
            AMA.Print("Sub-priority must be 1 or greater.")
            return
        end
        local subs = AMA.GetZoneMobSubPriorities(zoneName, true)
        subs[mobName] = sub
        AMA.Print(string.format(
            "Sub-priority set: |cFFFFFFFF%s|r -> |cFFFFD700%d|r (zone: %s)",
            mobName, sub, zoneName))

    elseif cmd == "subclear" then
        local mobName = argStr and argStr:gsub("^%s*(.-)%s*$", "%1") or ""
        local zoneName = AMA.currentZoneName
        if not zoneName or zoneName == "" then
            AMA.Print("No active zone. Enter a supported dungeon or raid first.")
            return
        end
        if mobName == "" then
            AMA.Print("Usage: /ama subclear <mob name>")
            return
        end
        local subs = AMA.GetZoneMobSubPriorities(zoneName, false)
        if subs then subs[mobName] = nil end
        AMA.Print(string.format(
            "Sub-priority cleared: |cFFFFFFFF%s|r (zone: %s)",
            mobName, zoneName))

    elseif cmd == "sublist" then
        local zoneName = AMA.currentZoneName
        if not zoneName or zoneName == "" then
            AMA.Print("No active zone. Enter a supported dungeon or raid first.")
            return
        end
        local subs = AMA.GetZoneMobSubPriorities(zoneName, false)
        if not subs or next(subs) == nil then
            AMA.Print("No custom sub-priorities set for " .. zoneName .. ".")
            return
        end
        AMA.Print("Custom sub-priorities for " .. zoneName .. ":")
        local names = {}
        for mobName in pairs(subs) do names[#names + 1] = mobName end
        table.sort(names, function(a, b)
            local sa = tonumber(subs[a]) or 9999
            local sb = tonumber(subs[b]) or 9999
            if sa ~= sb then return sa < sb end
            return a < b
        end)
        for _, mobName in ipairs(names) do
            AMA.Print(string.format("  |cFFFFD700%3d|r  %s", tonumber(subs[mobName]) or 0, mobName))
        end

    elseif cmd == "pools" then
        local pools = AutoMarkAssistDB.markPools or AMA.PRIORITY_POOLS
        AMA.Print("Mark pool assignments:")
        for _, pri in ipairs({ "BOSS", PRIORITY_HIGH, PRIORITY_CC, PRIORITY_MEDIUM, PRIORITY_LOW }) do
            local pool = pools[pri] or {}
            local icons = {}
            for _, idx in ipairs(pool) do
                icons[#icons+1] = AMA.MARK_ICON_COORDS[idx] or ("["..idx.."]")
            end
            if #icons > 0 then
                AMA.Print(string.format("  |cFFFFD700%-8s|r  %s", pri, table.concat(icons, " ")))
            end
        end

    elseif cmd == "show" then
        AutoMarkAssistDB.minimapHide = false
        AMA.minimapButton:Show()
        AMA.UpdateMinimapPosition()
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.Print("Minimap button shown.")

    elseif cmd == "hide" then
        AutoMarkAssistDB.minimapHide = true
        AMA.minimapButton:Hide()
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.Print("Minimap button hidden.  Use |cFFAAAAAA/ama show|r to restore.")

    elseif cmd == "db" then
        AMA.OpenDBFrame()

    elseif cmd == "rebalance" then
        AMA.RebalanceMarks()

    elseif cmd == "zone" then
        local zoneName = AMA.currentZoneName
        if not zoneName or zoneName == "" then
            AMA.Print("No zone resolved yet.")
        elseif AMA.currentZoneMobDB then
            AMA.Print(string.format(
                "Zone: |cFFFFFFFF%s|r  (%d DB entries)",
                zoneName, AMA.CountTable(AMA.currentZoneMobDB)))
        else
            AMA.Print("Zone: |cFFFFFFFF" .. zoneName ..
                "|r  (|cFFFF6600no DB entries|r)")
        end

    elseif cmd == "marks" then
        local count = AMA.CountTable(AMA.markedGUIDs)
        if count == 0 then
            AMA.Print("No marks currently tracked.")
        else
            AMA.Print("Currently tracked marks (" .. count .. "):")
            for guid, markIdx in pairs(AMA.markedGUIDs) do
                local token = AMA.markTokens[markIdx]
                local name  = token and UnitName(token) or "?"
                local icon  = AMA.MARK_ICON_COORDS[markIdx] or ""
                AMA.Print(string.format(
                    "  %s  |cFFFFFFFF%s|r  (guid %s)",
                    icon, name, guid))
            end
        end

    elseif cmd == "help" or cmd == "?" then
        AMA.Print("AutoMarkAssist v" .. AMA.VERSION .. " commands:")
        for _, line in ipairs({
            "/ama               - Open config window",
            "/ama help          - Show this command list",
            "/ama options       - Alias for /ama",
            "/ama config        - Alias for /ama",
            "/ama enable        - Enable auto-marking",
            "/ama disable       - Disable auto-marking",
            "/ama toggle        - Toggle auto-marking",
            "/ama reset         - Reset local mark tracking",
            "/ama clear         - Alias for /ama reset",
            "/ama rebalance     - Rebalance current marks",
            "/ama manual        - Toggle manual scroll-wheel mode",
            "/ama lock          - Toggle in-combat mark lock",
            "/ama combatlock    - Alias for /ama lock",
            "/ama smartcc       - Toggle dungeon Smart CC adaptation",
            "/ama groupcc       - Alias for /ama smartcc",
            "/ama ccannounce    - Repeat dungeon CC assignments to party",
            "/ama repeatcc      - Alias for /ama ccannounce",
            "/ama ccremind      - Alias for /ama ccannounce",
            "/ama ccauto        - Toggle automatic dungeon CC announcements",
            "/ama sub <mob> <n> - Set zone sub-priority tie-break",
            "/ama subclear <mob> - Clear zone sub-priority tie-break",
            "/ama sublist       - List zone sub-priority tie-breaks",
            "/ama verbose       - Toggle verbose output",
            "/ama announce      - Announce marks to group",
            "/ama preview       - Preview the current legend in chat",
            "/ama whatsnew      - Show the latest update notes",
            "/ama pools         - List mark pool assignments",
            "/ama marks         - List currently tracked marks",
            "/ama zone          - Show current zone DB info",
            "/ama show          - Show minimap button",
            "/ama hide          - Hide minimap button",
            "/ama db            - Open mob database viewer",
            "/automarkassist    - Alias for /ama",
        }) do
            DEFAULT_CHAT_FRAME:AddMessage("|cFFAAAAAA" .. line .. "|r")
        end
    else
        AMA.Print("Unknown command: |cFFFFFFFF" .. cmd ..
            "|r  Type |cFFAAAAAA/ama help|r for a command list.")
    end
end
