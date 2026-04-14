-- AutoMarkAssist_Events.lua
-- Zone tracking, event handling, proximity scanner, and slash commands.
-- Loaded last (after AutoMarkAssist_Config.lua).

local AMA = AutoMarkAssist

-- ============================================================
-- FILE-SCOPE CONSTANTS
-- ============================================================

local SCAN_INTERVAL = 0.5
local pendingAnnounceAt = nil
local lastAnnounceKey = nil

-- ============================================================
-- UNIT TOKEN LIST
-- ============================================================

do
    AMA.SCAN_UNIT_TOKENS = {
        "target", "focus", "mouseover",
        "player",
        "party1", "party2", "party3", "party4",
        "party1target", "party2target", "party3target", "party4target",
    }
    for i = 1, 40 do
        AMA.SCAN_UNIT_TOKENS[#AMA.SCAN_UNIT_TOKENS + 1] = "raid" .. i
        AMA.SCAN_UNIT_TOKENS[#AMA.SCAN_UNIT_TOKENS + 1] = "raid" .. i .. "target"
    end
    for i = 1, 20 do
        AMA.SCAN_UNIT_TOKENS[#AMA.SCAN_UNIT_TOKENS + 1] = "nameplate" .. i
    end
end

-- ============================================================
-- ZONE DATABASE HELPER
-- ============================================================

local function UpdateZone()
    local rawZone = GetRealZoneText() or ""
    local resolved = AMA.ResolveZoneName(rawZone)

    if resolved == AMA.currentZoneName then return end
    AMA.currentZoneName = resolved

    local merged = AMA.BuildZoneMobDB(resolved)
    if not merged then
        AMA.currentZoneMobDB = nil
        AMA.VPrint("Zone: " .. rawZone .. " (no mob DB)")
        return
    end
    AMA.currentZoneMobDB = merged
    AMA.VPrint(string.format("Zone: |cFFFFFFFF%s|r  DB entries: |cFF00FF00%d|r",
        resolved, AMA.CountTable(merged)))
    AMA.ResetState()
end

-- ============================================================
-- ANNOUNCE QUEUE
-- Delays announcement slightly after entering a dungeon so the
-- full roster is available.
-- ============================================================

local function BuildAnnounceKey()
    if not AutoMarkAssistDB or not AutoMarkAssistDB.enabled then return nil end
    if not AutoMarkAssistDB.announceOnEntry then return nil end
    if AMA.GetMarkingMode() == "manual" then return nil end

    local canMark = AMA.CanMarkReason and AMA.CanMarkReason()
    if not canMark then return nil end

    local inInstance, instanceType = IsInInstance()
    if not inInstance then return nil end
    if instanceType ~= "party" and instanceType ~= "raid" then return nil end
    if not (IsInGroup() or (IsInRaid and IsInRaid())) then return nil end

    local zone = AMA.currentZoneName or GetRealZoneText() or ""
    if zone == "" then return nil end

    -- Build a key from zone + group members to avoid duplicate announces.
    local parts = { zone }
    local tokens = {}
    if IsInRaid and IsInRaid() then
        for i = 1, 40 do
            local t = "raid" .. i
            if UnitExists(t) then tokens[#tokens + 1] = t end
        end
    else
        for _, t in ipairs({ "player", "party1", "party2", "party3", "party4" }) do
            if UnitExists(t) then tokens[#tokens + 1] = t end
        end
    end
    for _, t in ipairs(tokens) do
        local name = UnitName(t)
        local _, classTag = UnitClass(t)
        parts[#parts + 1] = (name or "") .. ":" .. (classTag or "")
    end
    return table.concat(parts, "|")
end

local function QueueAnnounce(delay)
    pendingAnnounceAt = (GetTime and GetTime() or 0) + (delay or 1.5)
end

local function TryPendingAnnounce()
    if not pendingAnnounceAt then return end
    if (GetTime and GetTime() or 0) < pendingAnnounceAt then return end
    pendingAnnounceAt = nil

    local key = BuildAnnounceKey()
    if not key then return end
    if key == lastAnnounceKey then return end

    if AMA.AutoAnnounceOnEntry and AMA.AutoAnnounceOnEntry() then
        lastAnnounceKey = key
    end
end

function AMA.RefreshAnnounceQueue(delay)
    if BuildAnnounceKey() then
        QueueAnnounce(delay or 1.5)
    else
        pendingAnnounceAt = nil
        lastAnnounceKey = nil
    end
end

-- ============================================================
-- EVENT FRAME
-- ============================================================

local frame = CreateFrame("Frame", "AutoMarkAssistEventFrame", UIParent)
frame:RegisterEvent("ADDON_LOADED")

-- ============================================================
-- RESET MARKS KEYBIND
-- ============================================================

local resetKeyBtn = CreateFrame("Button", "AMA_ResetMarksButton", UIParent)
resetKeyBtn:SetSize(1, 1)
resetKeyBtn:SetAlpha(0)
resetKeyBtn:RegisterForClicks("AnyUp", "AnyDown")
resetKeyBtn:SetScript("OnClick", function()
    if AMA.ResetWithMessage then AMA.ResetWithMessage() end
end)

function AMA.ApplyResetKeybind()
    ClearOverrideBindings(resetKeyBtn)
    local key = AutoMarkAssistDB and AutoMarkAssistDB.resetMarksKey
    if key and key ~= "" then
        SetOverrideBindingClick(resetKeyBtn, true, key, "AMA_ResetMarksButton")
        AMA.VPrint("Reset keybind: " .. key)
    end
end

-- ============================================================
-- PROXIMITY SCANNER (OnUpdate)
-- ============================================================

local scanElapsed = 0

frame:SetScript("OnUpdate", function(self, elapsed)
    scanElapsed = scanElapsed + elapsed
    if scanElapsed < SCAN_INTERVAL then return end
    scanElapsed = 0

    if not AutoMarkAssistDB then return end

    TryPendingAnnounce()

    if not AutoMarkAssistDB.enabled then return end
    if AMA.GetMarkingMode() ~= "proximity" then return end
    if AMA.IsCombatMarkLockActive and AMA.IsCombatMarkLockActive() then return end

    local canMark = AMA.CanMarkReason()
    if not canMark then return end

    if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end

    for _, token in ipairs(AMA.SCAN_UNIT_TOKENS) do
        if UnitExists(token) and UnitCanAttack("player", token) then
            if not (UnitIsDead and UnitIsDead(token)) then
                AMA.AssignMark(token, false, "proximity")
            end
        end
    end
end)

-- ============================================================
-- EVENT HANDLER
-- ============================================================

frame:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...

    if event == "ADDON_LOADED" and arg1 == AMA.ADDON_NAME then
        if not AutoMarkAssistDB then
            AutoMarkAssistDB = {}
        end

        -- Migrate from old version.
        AMA.MigrateFromOldVersion(AutoMarkAssistDB)

        -- Backfill missing defaults.
        AMA.BackfillDefaults(AutoMarkAssistDB)
        AMA.NormalizeZoneScopedMobSettings()

        -- Register gameplay events.
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        frame:RegisterEvent("GROUP_ROSTER_UPDATE")
        frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        frame:RegisterEvent("RAID_TARGET_UPDATE")
        frame:RegisterEvent("MODIFIER_STATE_CHANGED")

        -- Initialise minimap.
        AMA.UpdateMinimapPosition()
        AMA.UpdateMinimapState()
        if AutoMarkAssistDB.minimapHide then
            AMA.minimapButton:Hide()
        end

        AMA.Print("v" .. AMA.VERSION .. " loaded.  Type |cFFAAAAAA/ama|r for options.  |cFF444444by|r |cFFFFD700" .. AMA.AUTHOR .. "|r")
        AMA.ApplyResetKeybind()

    elseif event == "PLAYER_ENTERING_WORLD" then
        AMA.currentZoneName = ""
        UpdateZone()
        AMA.ResetState()
        if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
        AMA.ApplyResetKeybind()
        AMA.RefreshAnnounceQueue(1.5)

    elseif event == "ZONE_CHANGED_NEW_AREA" then
        AMA.currentZoneName = ""
        UpdateZone()
        AMA.ResetState()
        if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
        AMA.RefreshAnnounceQueue(1.5)

    elseif event == "GROUP_ROSTER_UPDATE" then
        if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
        AMA.RefreshAnnounceQueue(1.0)

    elseif event == "RAID_TARGET_UPDATE" then
        if not AMA.IsAddonEnabled() then return end
        if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end

    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        if not AutoMarkAssistDB then return end
        local mode = AMA.GetMarkingMode()

        if mode == "manual" then
            AMA.ShowMarkPickerForMouseover()
            return
        end

        if not AMA.IsAddonEnabled() then return end
        if mode ~= "mouseover" then return end
        if AMA.IsCombatMarkLockActive and AMA.IsCombatMarkLockActive() then return end
        if AMA.SyncVisibleMarks then AMA.SyncVisibleMarks() end
        AMA.AssignMark("mouseover", false, "mouseover")

    elseif event == "MODIFIER_STATE_CHANGED" then
        if not AutoMarkAssistDB then return end
        if AMA.GetMarkingMode() == "manual" then
            AMA.ShowMarkPickerForMouseover()
        end

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not AMA.IsAddonEnabled() then return end
        local _, subevent, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
        if subevent ~= "UNIT_DIED" then return end
        if not destGUID then return end
        if not AMA.markedGUIDs[destGUID] then return end

        local wasLocal = AMA.IsLocalMark and AMA.IsLocalMark(destGUID)
        AMA.ReleaseMark(destGUID)

        if wasLocal
        and AutoMarkAssistDB and AutoMarkAssistDB.rebalanceOnDeath
        and not (AMA.IsCombatMarkLockActive and AMA.IsCombatMarkLockActive()) then
            AMA.CascadeMarksAfterDeath()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        if not AMA.IsAddonEnabled() then return end
        if AutoMarkAssistDB and AutoMarkAssistDB.autoReset and AMA.ResetWithMessage then
            AMA.ResetWithMessage()
        elseif AMA.SyncVisibleMarks then
            AMA.SyncVisibleMarks()
            AMA.VPrint("Left combat -- synced marks.")
        end
    end
end)

-- ============================================================
-- SLASH COMMANDS
-- ============================================================

SLASH_AUTOMARKASSIST1 = "/ama"
SLASH_AUTOMARKASSIST2 = "/automarkassist"

SlashCmdList["AUTOMARKASSIST"] = function(msg)
    if not AutoMarkAssistDB then
        AMA.Print("Saved variables not yet loaded.")
        return
    end

    local cmd = string.lower(string.match(msg or "", "^%s*(%S*)") or "")
    local argStr = string.match(msg or "", "^%s*%S+%s*(.-)%s*$") or ""

    if cmd == "" or cmd == "options" or cmd == "config" then
        if AMA.OpenConfigFrame then AMA.OpenConfigFrame() end

    elseif cmd == "enable" then
        AutoMarkAssistDB.enabled = true
        AMA.UpdateMinimapState()
        AMA.RefreshAnnounceQueue(0.5)
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.VPrint("Auto-marking |cFF00FF00ENABLED|r.")

    elseif cmd == "disable" then
        AutoMarkAssistDB.enabled = false
        AMA.UpdateMinimapState()
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.VPrint("Auto-marking |cFFFF0000DISABLED|r.")

    elseif cmd == "toggle" then
        AutoMarkAssistDB.enabled = not AutoMarkAssistDB.enabled
        AMA.UpdateMinimapState()
        AMA.RefreshAnnounceQueue(0.5)
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.VPrint("Auto-marking " .. (AutoMarkAssistDB.enabled
            and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r"))

    elseif cmd == "reset" or cmd == "clear" then
        AMA.ResetWithMessage()

    elseif cmd == "announce" then
        AMA.AnnounceMarkPlan()

    elseif cmd == "preview" then
        AMA.PreviewMarkPlan()

    elseif cmd == "mode" then
        local mode = argStr:lower()
        if mode == "proximity" or mode == "mouseover" or mode == "manual" then
            AMA.SetMarkingMode(mode)
            AMA.UpdateMinimapState()
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
            AMA.VPrint("Marking mode: |cFFFFD700" .. mode .. "|r")
        else
            AMA.VPrint("Usage: /ama mode <proximity|mouseover|manual>")
            AMA.VPrint("Current mode: |cFFFFD700" .. AMA.GetMarkingMode() .. "|r")
        end

    elseif cmd == "manual" then
        local current = AMA.GetMarkingMode()
        if current == "manual" then
            AMA.SetMarkingMode("proximity")
            AMA.VPrint("Manual mode |cFF888888OFF|r - proximity marking resumed.")
        else
            AMA.SetMarkingMode("manual")
            AMA.VPrint("Manual mode |cFFFFD700ON|r - hover a mob and scroll to assign marks.")
        end
        AMA.UpdateMinimapState()
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end

    elseif cmd == "verbose" then
        AutoMarkAssistDB.verbose = not AutoMarkAssistDB.verbose
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.Print("Verbose: " .. (AutoMarkAssistDB.verbose
            and "|cFFFFD700ON|r" or "|cFF888888OFF|r"))

    elseif cmd == "lock" or cmd == "combatlock" then
        AutoMarkAssistDB.lockMarksInCombat = not AutoMarkAssistDB.lockMarksInCombat
        AMA.VPrint("Combat lock: " .. (AutoMarkAssistDB.lockMarksInCombat
            and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end

    elseif cmd == "show" then
        AutoMarkAssistDB.minimapHide = false
        AMA.minimapButton:Show()
        AMA.VPrint("Minimap button shown.")

    elseif cmd == "hide" then
        AutoMarkAssistDB.minimapHide = true
        AMA.minimapButton:Hide()
        AMA.VPrint("Minimap button hidden. Use /ama show to restore.")

    elseif cmd == "cc" then
        local abilities = AMA.GetGroupCCAbilities()
        if #abilities == 0 then
            AMA.Print("No CC classes detected in group.")
        else
            AMA.Print("Available CC in group:")
            for _, ab in ipairs(abilities) do
                local icon = AMA.MARK_ICON_COORDS[ab.mark] or ""
                AMA.Print(string.format("  %s %s - %s (%s)",
                    icon, ab.label, ab.playerName or "?", ab.classTag))
            end
        end

    elseif cmd == "marks" then
        AMA.Print("Current marks:")
        local count = 0
        for guid, markIdx in pairs(AMA.markedGUIDs) do
            local token = AMA.markTokens[markIdx]
            local name = token and UnitName(token) or "?"
            local source = AMA.guidMarkSource[guid] or "?"
            AMA.Print(string.format("  %s %s - %s (%s)",
                AMA.MARK_ICON_COORDS[markIdx] or "",
                AMA.MARK_NAMES[markIdx] or "?",
                name, source))
            count = count + 1
        end
        if count == 0 then
            AMA.Print("  No mobs currently marked.")
        end

    elseif cmd == "zone" then
        local zone = AMA.currentZoneName or "none"
        local count = AMA.currentZoneMobDB and AMA.CountTable(AMA.currentZoneMobDB) or 0
        AMA.Print(string.format("Zone: |cFFFFFFFF%s|r  DB entries: |cFF00FF00%d|r",
            zone, count))

    elseif cmd == "defaults" or cmd == "resetdefaults" then
        AMA.ResetSettingsToDefaults()
        AMA.UpdateMinimapState()
        if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
        AMA.Print("Settings reset to defaults.")

    elseif cmd == "help" then
        AMA.Print("Commands:")
        AMA.Print("  /ama - Open options")
        AMA.Print("  /ama enable | disable | toggle")
        AMA.Print("  /ama reset - Clear all marks")
        AMA.Print("  /ama announce - Send mark plan")
        AMA.Print("  /ama preview - Preview locally")
        AMA.Print("  /ama mode <proximity|mouseover|manual>")
        AMA.Print("  /ama manual - Toggle manual mode")
        AMA.Print("  /ama cc - Show group CC abilities")
        AMA.Print("  /ama marks - Show current marks")
        AMA.Print("  /ama zone - Show current zone info")
        AMA.Print("  /ama verbose - Toggle debug output")
        AMA.Print("  /ama lock - Toggle combat lock")
        AMA.Print("  /ama show | hide - Minimap button")
        AMA.Print("  /ama defaults - Reset all settings")

    else
        AMA.Print("Unknown command: |cFFFF6666" .. cmd .. "|r. Type |cFFAAAAAA/ama help|r for a list.")
    end
end
