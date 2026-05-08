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

	for aura in self.auraItemFramePool:EnumerateActive() do
		if aura.Cooldown then
			aura.Cooldown:SetHideCountdownNumbers(true)
		end
	end
end)

hooksecurefunc(NamePlateAurasMixin, "UpdateEnemyPlayerAuraFrames", function(self)
	if self:IsForbidden() then return end

	if self.CrowdControlListFrame then
		self.CrowdControlListFrame:SetShown(true)
	end
end)

hooksecurefunc(NamePlateClassificationFrameMixin, "UpdateClassificationIndicator", function(self)
	if self:IsForbidden() then return end

	if (self.classificationIndicator) then
		local classification = self:GetClassification()
		if classification == "elite" or classification == "worldboss" then
			self.classificationIndicator:SetTexture("Interface\\AddOns\\ClassicPlates\\icons\\nameplates")
			self.classificationIndicator:SetTexCoord(0.00390625, 0.148438, 0.234375, 0.507812)
		elseif classification == "rareelite" or classification == "rare" then
			self.classificationIndicator:SetTexture("Interface\\AddOns\\ClassicPlates\\icons\\nameplates")
			self.classificationIndicator:SetTexCoord(0.00390625, 0.148438, 0.523438, 0.796875)
		else
			self.classificationIndicator:SetAtlas(self.classificationAtlasElement)
		end
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

		hooksecurefunc(self, 'UpdateShownState', function()
			self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
			self.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			self.Spark:SetSize(16, 16)
			self.Spark:SetBlendMode("ADD")
			if self.channeling then
				self.Spark:Hide()
			end
			local FadeOutAnim = self.FadeOutAnim:CreateAnimation("Alpha") 
			FadeOutAnim:SetDuration(0.2)
			FadeOutAnim:SetFromAlpha(1)
			FadeOutAnim:SetToAlpha(0)
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

		hooksecurefunc(self, 'GetTypeInfo', function()
			if UnitCastingInfo(self.unit) then
				local _, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(self.unit)
				self:GetStatusBarTexture():SetVertexColorFromBoolean(notInterruptible, castbarColors.Uninterruptable, castbarColors.Standard)
			elseif UnitChannelInfo(self.unit) then
				local _, _, _, _, _, _, notInterruptible = UnitChannelInfo(self.unit)
				self:GetStatusBarTexture():SetVertexColorFromBoolean(notInterruptible, castbarColors.Uninterruptable, castbarColors.Channel)
			end
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

	frame.healthBar.background = frame.healthBar:CreateTexture(nil, "BACKGROUND")
	frame.healthBar.background:SetAllPoints(frame.healthBar)
	frame.healthBar.background:SetColorTexture(0.2, 0.2, 0.2, 0.85)

	frame.healthBar.border = CreateFrame("Frame", nil, frame.healthBar, "NamePlateFullBorderTemplate")
	frame.healthBar.border:UpdateSizes()

	if isTarget then
		frame.healthBar.border:SetVertexColor(1, 1, 1, 0.9)
	else
		frame.healthBar.border:SetVertexColor(0, 0, 0, 1)
	end

	hooksecurefunc(frame.healthBar, "UpdateSelectionBorder", function()
		local isTarget = frame.healthBar:IsTarget()

		if isTarget then
			frame.healthBar.border:SetVertexColor(1, 1, 1, 0.9)
		else
			frame.healthBar.border:SetVertexColor(0, 0, 0, 1)
		end
	end)
end

local function GetSafeNameplate(unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if not nameplate or not nameplate.UnitFrame then return nil, nil end

	local frame = nameplate.UnitFrame
	return nameplate, frame
end

local function HandleNamePlateAdded(unit)
	local nameplate, frame = GetSafeNameplate(unit)
	if not frame or frame.skinned then return end

	SkinCastbar(frame.castBar)
	SkinHealthBar(frame.HealthBarsContainer)

	if frame.behindCameraIcon then
		frame.behindCameraIcon:SetAlpha(0)
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
			frame.castBar:SetHeight(22)
			PixelUtil.SetPoint(frame.castBar, "BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
			PixelUtil.SetPoint(frame.castBar, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
			frame.castBar.BorderShield:SetSize(16, 18)
			frame.castBar.Icon:SetSize(18, 18)
			frame.castBar.Text:SetTextHeight(14)
			PixelUtil.SetHeight(frame.HealthBarsContainer, 15)
			frame.name:SetFontObject("CpSystemFont_LargeNamePlate")
			frame.ClassificationFrame:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT", -2, 0)
		else
			frame.castBar:SetHeight(12)
			PixelUtil.SetPoint(frame.castBar, "BOTTOMLEFT", frame, "BOTTOMLEFT", 26, 0)
			PixelUtil.SetPoint(frame.castBar, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 0)
			frame.castBar.BorderShield:SetSize(10, 12)
			frame.castBar.Icon:SetSize(14, 14)
			frame.castBar.Text:SetTextHeight(12)
			PixelUtil.SetHeight(frame.HealthBarsContainer, 6)
			frame.name:SetFontObject("CpSystemFont_NamePlate")
			frame.ClassificationFrame:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT")
		end
		frame.castBar.Icon:ClearAllPoints()
		PixelUtil.SetPoint(frame.castBar.Icon, "CENTER", frame.castBar, "LEFT", 0, 0)
		frame.ClassificationFrame:SetScale(1.4)
		frame.ClassificationFrame:SetSize(14, 13)
		frame.ClassificationFrame.classificationIndicator:SetSize(14, 13)
		frame.HealthBarsContainer:ClearAllPoints()
		PixelUtil.SetPoint(frame.HealthBarsContainer, "BOTTOMLEFT", frame.castBar, "TOPLEFT", 0, 2.5)
		PixelUtil.SetPoint(frame.HealthBarsContainer, "BOTTOMRIGHT", frame.castBar, "TOPRIGHT", 0, 2.5)
		frame.name:SetIgnoreParentScale(true)
		frame.name:SetJustifyH("CENTER")
		frame.name:ClearAllPoints()
		PixelUtil.SetPoint(frame.name, "BOTTOM", frame.HealthBarsContainer, "TOP", 0, 4)
		if frame.AurasFrame.DebuffListFrame then
			if frame.HealthBarsContainer.healthBar:IsTarget() or frame.name:IsShown() then
				frame.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", frame.name, "TOP", 0, 10)
			else
				frame.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", frame.name, "TOP", 0, -18)
			end
		end
		if frame.AurasFrame.BuffListFrame then
			frame.AurasFrame.BuffListFrame:SetAlpha(0)
		end
	end)

	frame.skinned = true
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