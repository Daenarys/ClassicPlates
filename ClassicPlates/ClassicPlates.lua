local AddonName, Addon = ...
local CURRENT_VERSION = C_AddOns.GetAddOnMetadata(AddonName, 'Version')

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function()
    ClassicPlatesDB = ClassicPlatesDB or {}
    for k, v in pairs(Addon.Defaults) do
        if ClassicPlatesDB[k] == nil then
            ClassicPlatesDB[k] = v
        end
    end

    --version update
    if ClassicPlatesVersion then
        if ClassicPlatesVersion ~= CURRENT_VERSION then
            Addon:UpdateVersion()
        end
    else
        ClassicPlatesVersion = CURRENT_VERSION
    end
end)

function Addon:UpdateVersion()
    ClassicPlatesVersion = CURRENT_VERSION

    print("|cff33ff99Classic Plates|r: Updated to v" .. ClassicPlatesVersion)
end

hooksecurefunc(NamePlateAurasMixin, "RefreshList", function(self)
    if self:IsForbidden() then return end

    if self.BuffListFrame then
        self.BuffListFrame:SetAlpha(0)
    end

    for auraItemFrame in self.auraItemFramePool:EnumerateActive() do
        if not auraItemFrame.Border then
            auraItemFrame.Border = auraItemFrame:CreateTexture(nil, "BACKGROUND")
            auraItemFrame.Border:SetAllPoints(auraItemFrame)
            auraItemFrame.Border:SetColorTexture(0, 0, 0, 1)
        end
        if auraItemFrame.Cooldown then
            auraItemFrame.Cooldown:SetHideCountdownNumbers(true)
        end
        auraItemFrame:HookScript("OnEnter", function()
            local tooltip = GetAppropriateTooltip()
            tooltip:SetOwner(auraItemFrame, "ANCHOR_LEFT")
            auraItemFrame:RefreshTooltip()
        end)
    end
end)

local castbarColors = {}
castbarColors.Standard = CreateColor(1.0, 0.7, 0.0, 1)
castbarColors.Channel = CreateColor(0.0, 1.0, 0.0, 1)
castbarColors.Uninterruptable = CreateColor(0.7, 0.7, 0.7, 1)
castbarColors.Interrupted = CreateColor(1, 0, 0, 1)

local function SkinCastbar(self)
    if self:IsForbidden() then return end

    if ClassicPlatesDB.oldCastbar then
        if self.Background then
            self.Background:SetColorTexture(0.2, 0.2, 0.2, 0.85)
        end

        hooksecurefunc(self, 'GetTypeInfo', function()
            if UnitCastingInfo(self.unit) then
                local _, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(self.unit)
                self:GetStatusBarTexture():SetVertexColorFromBoolean(notInterruptible, castbarColors.Uninterruptable, castbarColors.Standard)
            elseif UnitChannelInfo(self.unit) then
                local _, _, _, _, _, _, notInterruptible = UnitChannelInfo(self.unit)
                self:GetStatusBarTexture():SetVertexColorFromBoolean(notInterruptible, castbarColors.Uninterruptable, castbarColors.Channel)
            end
        end)

        hooksecurefunc(self, 'UpdateShownState', function()
            self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            self.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
            if ClassicPlatesDB.largerPlates then
                self.Spark:SetSize(32, 32)
            else
                self.Spark:SetSize(16, 16)
            end
            self.Spark:SetBlendMode("ADD")
            if self.channeling then
                self.Spark:Hide()
            end
        end)

        hooksecurefunc(self, 'PlayInterruptAnims', function()
            self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            self:GetStatusBarTexture():SetVertexColor(castbarColors.Interrupted:GetRGBA())
            self:SetValue(self.maxValue)
            self.Spark:Hide()
        end)

        hooksecurefunc(self, 'PlayFinishAnim', function()
            self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            self.Flash:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
            self.Flash:SetVertexColor(self:GetStatusBarColor())
            self.Flash:ClearAllPoints()
            self.Flash:SetAllPoints()
            if not self.NewFlash then
                self.NewFlash = self.Flash:CreateAnimationGroup()
                self.NewFlash:SetToFinalAlpha(true)
                local FlashAnim = self.NewFlash:CreateAnimation("Alpha") 
                FlashAnim:SetDuration(0.2)
                FlashAnim:SetFromAlpha(1)
                FlashAnim:SetToAlpha(0)
            end
            self.NewFlash:Play()
        end)
    end

    if self.Text then
        self.Text:ClearAllPoints()
        self.Text:SetPoint("TOPLEFT")
        self.Text:SetPoint("BOTTOMRIGHT")
    end

    hooksecurefunc(self, 'HandleInterruptOrSpellFailed', function(_, event)
        if ( self.Text ) then
            if ( event == "UNIT_SPELLCAST_FAILED" ) then
                self.Text:SetText(FAILED)
            else
                self.Text:SetText(INTERRUPTED)
            end
        end
    end)

    hooksecurefunc(self, 'SetIsHighlightedCastTarget', function()
        if self.CastTargetIndicator then
            self.CastTargetIndicator:Hide()
        end
    end)

    hooksecurefunc(self, 'SetIsHighlightedImportantCast', function()
        if self.ImportantCastIndicator then
            self.ImportantCastIndicator:Hide()
        end

        if self.ImportantCastFlashAnim then
            self.ImportantCastFlashAnim:SetPlaying(false)
        end
    end)
end

local function SkinHealthBar(frame)
    local isTarget = frame.healthBar:IsTarget()

    frame.healthBar.barTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
    frame.healthBar.bgTexture:SetAlpha(0)
    frame.healthBar.selectedBorder:SetAlpha(0)
    frame.healthBar.deselectedOverlay:SetAlpha(0)

    if not frame.healthBar.background then
        frame.healthBar.background = frame.healthBar:CreateTexture(nil, "BACKGROUND")
        frame.healthBar.background:SetAllPoints(frame.healthBar)
        frame.healthBar.background:SetColorTexture(0.2, 0.2, 0.2, 0.85)
    end

    if not frame.healthBar.border then
        frame.healthBar.border = CreateFrame("Frame", nil, frame.healthBar, "CpBorderTemplate")

        PixelUtil.SetWidth(frame.healthBar.border.Left, 1, 2)
        PixelUtil.SetPoint(frame.healthBar.border.Left, "TOPRIGHT", frame.healthBar.border, "TOPLEFT", 0, 1, 0, 2)
        PixelUtil.SetPoint(frame.healthBar.border.Left, "BOTTOMRIGHT", frame.healthBar.border, "BOTTOMLEFT", 0, -1, 0, 2)

        PixelUtil.SetWidth(frame.healthBar.border.Right, 1, 2)
        PixelUtil.SetPoint(frame.healthBar.border.Right, "TOPLEFT", frame.healthBar.border, "TOPRIGHT", 0, 1, 0, 2)
        PixelUtil.SetPoint(frame.healthBar.border.Right, "BOTTOMLEFT", frame.healthBar.border, "BOTTOMRIGHT", 0, -1, 0, 2)

        PixelUtil.SetHeight(frame.healthBar.border.Bottom, 1, 2)
        PixelUtil.SetPoint(frame.healthBar.border.Bottom, "TOPLEFT", frame.healthBar.border, "BOTTOMLEFT", 0, 0)
        PixelUtil.SetPoint(frame.healthBar.border.Bottom, "TOPRIGHT", frame.healthBar.border, "BOTTOMRIGHT", 0, 0)

        PixelUtil.SetHeight(frame.healthBar.border.Top, 1, 2)
        PixelUtil.SetPoint(frame.healthBar.border.Top, "BOTTOMLEFT", frame.healthBar.border, "TOPLEFT", 0, 0)
        PixelUtil.SetPoint(frame.healthBar.border.Top, "BOTTOMRIGHT", frame.healthBar.border, "TOPRIGHT", 0, 0)
    end

    for i, texture in ipairs(frame.healthBar.border.Textures) do
        if isTarget then
            texture:SetColorTexture(1, 1, 1, 0.9)
        else
            texture:SetColorTexture(0, 0, 0, 1)
        end
    end

    hooksecurefunc(frame.healthBar, "UpdateSelectionBorder", function()
        local isTarget = frame.healthBar:IsTarget()

        for i, texture in ipairs(frame.healthBar.border.Textures) do
            if isTarget then
                texture:SetColorTexture(1, 1, 1, 0.9)
            else
                texture:SetColorTexture(0, 0, 0, 1)
            end
        end
    end)
end

local function ShowBorder(frame)
    if frame.healthBar.background then
        frame.healthBar.background:Show()
    end
    if frame.healthBar.border then
        frame.healthBar.border:Show()
    end
end

local function HideBorder(frame)
    if frame.healthBar.background then
        frame.healthBar.background:Hide()
    end
    if frame.healthBar.border then
        frame.healthBar.border:Hide()
    end
end

local function GetSafeNameplate(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate or not nameplate.UnitFrame then return nil, nil end

    local frame = nameplate.UnitFrame
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
        SkinHealthBar(frame.HealthBarsContainer)
        frame.HealthBarsContainer.skinned = true
    end

    if UnitNameplateShowsWidgetsOnly(unit) then
        HideBorder(frame.HealthBarsContainer)
    else
        ShowBorder(frame.HealthBarsContainer)
    end

    if frame.selectionHighlight then
        frame.selectionHighlight:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        frame.selectionHighlight:SetAlpha(0.25)
        frame.selectionHighlight:SetBlendMode("ADD")
        frame.selectionHighlight:SetAllPoints(frame.HealthBarsContainer)
    end

    hooksecurefunc(frame, "UpdateAnchors", function()
        frame.castBar:ClearAllPoints()
        frame.ClassificationFrame:ClearAllPoints()
        if ClassicPlatesDB.largerPlates then
            frame.castBar:SetHeight(20)
            PixelUtil.SetPoint(frame.castBar, "BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
            PixelUtil.SetPoint(frame.castBar, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
            frame.castBar.BorderShield:SetSize(16, 18)
            frame.castBar.Icon:SetSize(18, 18)
            frame.castBar.Text:SetTextHeight(14)
            PixelUtil.SetHeight(frame.HealthBarsContainer, 15)
            frame.name:SetFontObject("CpSystemFont_LargeNamePlate")
            frame.ClassificationFrame:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT", -4, 0)
            if (frame.ClassificationFrame.classificationIndicator) then
                frame.ClassificationFrame.classificationIndicator:SetScale(1.4)
            end
        else
            frame.castBar:SetHeight(12)
            PixelUtil.SetPoint(frame.castBar, "BOTTOMLEFT", frame, "BOTTOMLEFT", 26, 0)
            PixelUtil.SetPoint(frame.castBar, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 0)
            frame.castBar.BorderShield:SetSize(10, 12)
            frame.castBar.Icon:SetSize(14, 14)
            frame.castBar.Text:SetTextHeight(12)
            PixelUtil.SetHeight(frame.HealthBarsContainer, 6)
            frame.name:SetFontObject("CpSystemFont_NamePlate")
            frame.ClassificationFrame:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT", -1, 0)
            if (frame.ClassificationFrame.classificationIndicator) then
                frame.ClassificationFrame.classificationIndicator:SetScale(1)
            end
        end
        frame.castBar.Icon:ClearAllPoints()
        frame.castBar.Icon:SetPoint("CENTER", frame.castBar, "LEFT")
        frame.name:SetIgnoreParentScale(true)
        frame.name:SetJustifyH("CENTER")
        frame.name:ClearAllPoints()
        PixelUtil.SetPoint(frame.name, "BOTTOM", frame.HealthBarsContainer, "TOP", 0, 4)
        if frame.HealthBarsContainer.healthBar:IsTarget() or frame.name:IsShown() then
            frame.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", frame.name, "TOP", 0, 10)
        else
            frame.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", frame.name, "TOP", 0, -18)
        end
        frame.AurasFrame.CrowdControlListFrame:SetPoint("LEFT", frame.AurasFrame.DebuffListFrame, "RIGHT")
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