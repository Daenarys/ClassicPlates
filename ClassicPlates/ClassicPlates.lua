hooksecurefunc(NamePlateClassificationFrameMixin, "UpdateClassificationIndicator", function(frame)
    if (frame.classificationIndicator) then
        local classification = frame:GetClassification()
        if (classification == "rare") then
            frame.classificationIndicator:SetAtlas("nameplates-icon-elite-silver")
        end
    end
end)

hooksecurefunc(NamePlateAurasMixin, "RefreshList", function(self)
    if self:IsForbidden() then return end

    for auraItemFrame in self.auraItemFramePool:EnumerateActive() do
        if auraItemFrame.Cooldown then
            local r1 = auraItemFrame.Cooldown:GetRegions()
            if r1 and r1.GetObjectType and r1:GetObjectType() == "FontString" then
                r1:SetAlpha(0)
            end
        end
    end
end)

local function SkinCastbar(self)
    if self:IsForbidden() then return end

    if self.Text then
        self.Text:ClearAllPoints()
        self.Text:SetPoint("TOPLEFT")
        self.Text:SetPoint("BOTTOMRIGHT")
    end

    hooksecurefunc(self, 'SetIsHighlightedCastTarget', function()
        if self.CastTargetIndicator then
            self.CastTargetIndicator:Hide()
        end
    end)
end

local function CreateBorder(frame, r, g, b, a)
    local border
    if frame.CreateTexture then
        border = frame:CreateTexture(nil, "OVERLAY", nil, -1)
    else
        border = frame:GetParent():CreateTexture(nil, "OVERLAY", nil, -1)
    end
    border:SetColorTexture(r, g, b, a)
    border:SetIgnoreParentScale(true)
    return border
end

local function SkinBorder(frame)
    frame.healthBar.barTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
    frame.healthBar.bgTexture:SetAlpha(0)
    frame.healthBar.selectedBorder:SetAlpha(0)
    frame.healthBar.deselectedOverlay:SetAlpha(0)

    if not frame.background then
        frame.background = frame:CreateTexture(nil, "BACKGROUND")
        frame.background:SetAllPoints(frame)
        frame.background:SetColorTexture(0.2, 0.2, 0.2, 0.85)
    end

    -- Create borders
    local borderTop = CreateBorder(frame, 0, 0, 0, 1)
    local borderBottom = CreateBorder(frame, 0, 0, 0, 1)
    local borderLeft = CreateBorder(frame, 0, 0, 0, 1)
    local borderRight = CreateBorder(frame, 0, 0, 0, 1)

    -- Store borders in a table
    frame["Textures"] = {borderTop, borderBottom, borderLeft, borderRight}

    -- Initial border thickness
    local borderThickness = 1.1
    local minPixels = 1

    -- Define the SizeBorders function to use PixelUtil
    local function SizeBorders(borderThickness)
        PixelUtil.SetHeight(borderTop, borderThickness, minPixels)
        PixelUtil.SetHeight(borderBottom, borderThickness, minPixels)
        PixelUtil.SetWidth(borderLeft, borderThickness, minPixels)
        PixelUtil.SetWidth(borderRight, borderThickness, minPixels)

        -- Adjust border positions to grow outward
        borderTop:ClearAllPoints()
        PixelUtil.SetPoint(borderTop, "BOTTOMLEFT", frame, "TOPLEFT", 0, 0)
        PixelUtil.SetPoint(borderTop, "BOTTOMRIGHT", frame, "TOPRIGHT", 0, 0)

        borderBottom:ClearAllPoints()
        PixelUtil.SetPoint(borderBottom, "TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
        PixelUtil.SetPoint(borderBottom, "TOPRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        borderLeft:ClearAllPoints()
        PixelUtil.SetPoint(borderLeft, "TOPLEFT", frame, "TOPLEFT", -borderThickness, borderThickness)
        PixelUtil.SetPoint(borderLeft, "BOTTOMLEFT", frame, "BOTTOMLEFT", -borderThickness, -borderThickness)

        borderRight:ClearAllPoints()
        PixelUtil.SetPoint(borderRight, "TOPRIGHT", frame, "TOPRIGHT", borderThickness, borderThickness)
        PixelUtil.SetPoint(borderRight, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", borderThickness, -borderThickness)
    end

    SizeBorders(borderThickness)

    hooksecurefunc(frame.healthBar, "UpdateSelectionBorder", function()
        local isTarget = frame.healthBar:IsTarget()

        for _, border in ipairs(frame.Textures) do
            if isTarget then
                border:SetColorTexture(1, 1, 1)
            else
                border:SetColorTexture(0, 0, 0)
            end
        end
    end)
end

local function ShowBorders(frame)
    if not frame.Textures then return end
    for _, tex in ipairs(frame.Textures) do
        tex:Show()
    end
    if frame.background then
        frame.background:Show()
    end
end

local function HideBorders(frame)
    if not frame.Textures then return end
    for _, tex in ipairs(frame.Textures) do
        tex:Hide()
    end
    if frame.background then
        frame.background:Hide()
    end
end

local function GetSafeNameplate(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    -- If there's no nameplate or the nameplate doesn't have a UnitFrame, return nils.
    if not nameplate or not nameplate.UnitFrame then return nil, nil end

    local frame = nameplate.UnitFrame
    -- If none of the above conditions are met, return both the nameplate and the frame.
    return nameplate, frame
end

local function HandleNamePlateAdded(unit)
    local nameplate, frame = GetSafeNameplate(unit)
    if not frame then return end

    if not frame.castBar.skinned then
        SkinCastbar(frame.castBar)
        frame.castBar.skinned = true
    end

    if not frame.HealthBarsContainer.skinned then
        SkinBorder(frame.HealthBarsContainer)
        frame.HealthBarsContainer.skinned = true
    end

    if UnitNameplateShowsWidgetsOnly(frame.unit) then
        HideBorders(frame.HealthBarsContainer)
    else
        ShowBorders(frame.HealthBarsContainer)
    end

    hooksecurefunc(frame, "UpdateAnchors", function()
        frame.castBar:SetHeight(12)
        frame.castBar:ClearAllPoints()
        frame.castBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 26, 0)
        frame.castBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 0)
        frame.castBar.BorderShield:SetSize(10, 12)
        frame.castBar.Icon:SetSize(14, 14)
        frame.castBar.Icon:ClearAllPoints()
        frame.castBar.Icon:SetPoint("CENTER", frame.castBar, "LEFT")
        frame.castBar.Text:SetFontObject("SystemFont_Shadow_Outline_Small")
        frame.castBar.Text:SetTextHeight(12)
        frame.HealthBarsContainer:SetHeight(6)
        frame.HealthBarsContainer:ClearAllPoints()
        frame.HealthBarsContainer:SetPoint("BOTTOMLEFT", frame.castBar, "TOPLEFT", 0, 2.5)
        frame.HealthBarsContainer:SetPoint("BOTTOMRIGHT", frame.castBar, "TOPRIGHT", 0, 2.5)
        frame.name:SetIgnoreParentScale(true)
        frame.name:SetShadowOffset(1, -1)
        frame.name:SetShadowColor(0, 0, 0, 1)
        frame.name:ClearAllPoints()
        frame.name:SetPoint("BOTTOM", frame.HealthBarsContainer, "TOP", 0, 4)
        frame.name:SetJustifyH("CENTER")
        frame.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", frame.name, "TOP", 0, 10)
    end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_LOGIN" then
        if C_CVar.GetCVar("nameplateStyle") ~= "5" then
            C_CVar.SetCVar("nameplateStyle", Enum.NamePlateStyle.Legacy)
        end
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        HandleNamePlateAdded(unit)
    end
end)