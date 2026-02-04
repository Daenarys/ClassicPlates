if ClassicPlates == nil then ClassicPlates = {} end

ClassicPlates.initializedAddon = false
ClassicPlates.ConfigVars = ClassicPlates_Defaults.Config

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    ClassicPlatesDB = ClassicPlatesDB or {}
    for k, v in pairs(ClassicPlates_Defaults.DefaultConfig) do
        if ClassicPlatesDB[k] == nil then
            ClassicPlatesDB[k] = v
        end
    end

    ClassicPlates.ConfigVars.largerPlates = ClassicPlatesDB.largerPlates

    ClassicPlates.initializedAddon = true
end)

local function SkinCastbar(self)
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
    frame.healthBar.barTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
    frame.healthBar.bgTexture:SetAlpha(0)
    frame.healthBar.selectedBorder:SetAlpha(0)
    frame.healthBar.deselectedOverlay:SetAlpha(0)

    if not frame.background then
        frame.background = frame:CreateTexture(nil, "BACKGROUND")
        frame.background:SetAllPoints(frame)
        frame.background:SetColorTexture(0.2, 0.2, 0.2, 0.85)
    end

    if not frame.cpBorder then
        frame.cpBorder = CreateFrame("Frame", nil, frame, "CpBorderTemplate")

        PixelUtil.SetWidth(frame.cpBorder.Left, 1, 2)
        PixelUtil.SetPoint(frame.cpBorder.Left, "TOPRIGHT", frame.cpBorder, "TOPLEFT", 0, 1, 0, 2)
        PixelUtil.SetPoint(frame.cpBorder.Left, "BOTTOMRIGHT", frame.cpBorder, "BOTTOMLEFT", 0, -1, 0, 2)

        PixelUtil.SetWidth(frame.cpBorder.Right, 1, 2)
        PixelUtil.SetPoint(frame.cpBorder.Right, "TOPLEFT", frame.cpBorder, "TOPRIGHT", 0, 1, 0, 2)
        PixelUtil.SetPoint(frame.cpBorder.Right, "BOTTOMLEFT", frame.cpBorder, "BOTTOMRIGHT", 0, -1, 0, 2)

        PixelUtil.SetHeight(frame.cpBorder.Bottom, 1, 2)
        PixelUtil.SetPoint(frame.cpBorder.Bottom, "TOPLEFT", frame.cpBorder, "BOTTOMLEFT", 0, 0)
        PixelUtil.SetPoint(frame.cpBorder.Bottom, "TOPRIGHT", frame.cpBorder, "BOTTOMRIGHT", 0, 0)

        PixelUtil.SetHeight(frame.cpBorder.Top, 1, 2)
        PixelUtil.SetPoint(frame.cpBorder.Top, "BOTTOMLEFT", frame.cpBorder, "TOPLEFT", 0, 0)
        PixelUtil.SetPoint(frame.cpBorder.Top, "BOTTOMRIGHT", frame.cpBorder, "TOPRIGHT", 0, 0)
    end

    hooksecurefunc(frame.healthBar, "UpdateSelectionBorder", function()
        local isTarget = frame.healthBar:IsTarget()

        for i, texture in ipairs(frame.cpBorder.Textures) do
            if isTarget then
                texture:SetColorTexture(1, 1, 1)
            else
                texture:SetColorTexture(0, 0, 0)
            end
        end
    end)
end

local function ShowBorder(frame)
    if frame.background then
        frame.background:Show()
    end
    if frame.cpBorder then
        frame.cpBorder:Show()
    end
end

local function HideBorder(frame)
    if frame.background then
        frame.background:Hide()
    end
    if frame.cpBorder then
        frame.cpBorder:Hide()
    end
end

local function GetSafeNameplate(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate or not nameplate.UnitFrame then return nil, nil end

    local frame = nameplate.UnitFrame
    return nameplate, frame
end

function ClassicPlates.UpdatePlates(unit)
    if ClassicPlates.initializedAddon then
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

        if UnitNameplateShowsWidgetsOnly(frame.unit) then
            HideBorder(frame.HealthBarsContainer)
        else
            ShowBorder(frame.HealthBarsContainer)
        end

        hooksecurefunc(frame, "UpdateAnchors", function()
            frame.castBar:SetHeight(12)
            frame.castBar:ClearAllPoints()
            if ClassicPlates.ConfigVars.largerPlates then
                frame.castBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
                frame.castBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
                frame.castBar.Text:SetTextHeight(14)
                frame.HealthBarsContainer:SetHeight(14)
                frame.name:SetTextHeight(14)
            else
                frame.castBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 26, 0)
                frame.castBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 0)
                frame.castBar.Text:SetTextHeight(12)
                frame.HealthBarsContainer:SetHeight(5.5)
                frame.name:SetTextHeight(10)
            end
            frame.castBar.BorderShield:SetSize(10, 12)
            frame.castBar.Icon:SetSize(14, 14)
            frame.castBar.Icon:ClearAllPoints()
            frame.castBar.Icon:SetPoint("CENTER", frame.castBar, "LEFT")
            frame.name:SetIgnoreParentScale(true)
            frame.name:SetShadowOffset(1, -1)
            frame.name:SetShadowColor(0, 0, 0, 1)
            frame.name:SetJustifyH("CENTER")
            frame.name:ClearAllPoints()
            frame.name:SetPoint("BOTTOM", frame.HealthBarsContainer, "TOP", 0, 4)
            frame.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", frame.name, "TOP", 0, 10)
        end)

        hooksecurefunc(NamePlateAurasMixin, "RefreshList", function(self)
            for auraItemFrame in self.auraItemFramePool:EnumerateActive() do
                if auraItemFrame.Cooldown then
                    local r1 = auraItemFrame.Cooldown:GetRegions()
                    if r1 and r1.GetObjectType and r1:GetObjectType() == "FontString" then
                        r1:SetAlpha(0)
                    end
                end
            end
        end)
    end
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
        ClassicPlates.UpdatePlates(unit)
    end
end)