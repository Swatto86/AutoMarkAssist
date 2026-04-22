-- AutoMarkAssist_Minimap.lua
-- Minimap button.
-- Loaded after AutoMarkAssist_Manual.lua.

local AMA = AutoMarkAssist

-- ============================================================
-- MINIMAP BUTTON
-- ============================================================

do
    local BUTTON_SIZE = 32
    local btn = CreateFrame("Button", "AMA_MinimapButton", Minimap)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:RegisterForDrag("LeftButton")
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Background circle.
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetSize(20, 20)
    bg:SetPoint("CENTER", btn, "CENTER", 0, 0)
    bg:SetVertexColor(0, 0, 0, 0.7)

    -- Icon.
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_8")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", btn, "CENTER", 0, 0)

    -- Icon border circle.
    local border = btn:CreateTexture(nil, "BORDER")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)

    -- Status dot.
    local dot = btn:CreateTexture(nil, "OVERLAY", nil, 2)
    dot:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    dot:SetSize(10, 10)
    dot:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
    btn._dot = dot

    AMA.minimapButton = btn

    function AMA.UpdateMinimapPosition()
        local angle = AutoMarkAssistDB and AutoMarkAssistDB.minimapAngle or 225
        local rad = math.rad(angle)
        local radius = 80
        local x = math.cos(rad) * radius
        local y = math.sin(rad) * radius
        btn:ClearAllPoints()
        btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

    function AMA.UpdateMinimapState()
        local mode = AMA.GetMarkingMode()
        local enabled = AMA.IsAddonEnabled()
        
        -- Default base texture configuration
        dot:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
        dot:SetTexCoord(0, 1, 0, 1)

        if not enabled then
            dot:SetVertexColor(1, 0, 0, 1) -- Red
        elseif mode == "manual" then
            dot:SetVertexColor(1, 0.8, 0, 1) -- Gold/Yellow
        else
            dot:SetVertexColor(0, 1, 0, 1) -- Green
        end
    end

    -- Dragging to reposition around minimap.
    local isDragging = false
    btn:SetScript("OnDragStart", function()
        isDragging = true
    end)
    btn:SetScript("OnDragStop", function()
        isDragging = false
    end)
    btn:SetScript("OnUpdate", function(self)
        if not isDragging then return end
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        cx, cy = cx / scale, cy / scale
        local angle = math.deg(math.atan2(cy - my, cx - mx))
        if AutoMarkAssistDB then AutoMarkAssistDB.minimapAngle = angle end
        AMA.UpdateMinimapPosition()
    end)

    -- Click handlers.
    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if AutoMarkAssistDB then
                AutoMarkAssistDB.enabled = not AutoMarkAssistDB.enabled
            end
            AMA.UpdateMinimapState()
            if AMA.ApplyResetKeybind then AMA.ApplyResetKeybind() end
            if AMA.RefreshConfigFrame then AMA.RefreshConfigFrame() end
            AMA.Print(AutoMarkAssistDB.enabled
                and "Marking |cFF00FF00ENABLED|r."
                or "Marking |cFFFF0000DISABLED|r.")
        elseif button == "RightButton" then
            AMA.OpenConfigFrame()
        end
    end)

    -- Tooltip.
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cFF1A9EC0AutoMarkAssist|r v" .. AMA.VERSION)
        local mode = AMA.GetMarkingMode()
        local enabled = AMA.IsAddonEnabled()
        if mode == "manual" then
            GameTooltip:AddLine("Mode: |cFFFFD700Manual|r", 1, 1, 1)
        elseif enabled then
            GameTooltip:AddLine("Mode: |cFF00FF00" .. mode:sub(1, 1):upper() .. mode:sub(2) .. "|r", 1, 1, 1)
        else
            GameTooltip:AddLine("|cFFFF0000Disabled|r", 1, 1, 1)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Left-click: Toggle enabled", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Right-click: Options", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end
