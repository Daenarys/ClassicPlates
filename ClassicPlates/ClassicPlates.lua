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

hooksecurefunc(NamePlateAuraItemMixin, "SetAura", function(self)
	if self:IsForbidden() then return end

	self:SetSize(20, 14)

	select(2, self:GetRegions()):Hide()
	select(3, self:GetRegions()):Hide()

	if not self.Border then
		self.Border = self:CreateTexture(nil, "BACKGROUND")
		self.Border:SetColorTexture(0, 0, 0)
		self.Border:SetAllPoints()
	end

	if self.Cooldown then
		self.Cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
		self.Cooldown:SetHideCountdownNumbers(true)
	end

	if self.Icon then
		self.Icon:SetSize(18, 12)
		self.Icon:ClearAllPoints()
		self.Icon:SetPoint("CENTER")
		self.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6)
	end
end)

hooksecurefunc(NamePlateAurasMixin, "RefreshAuras", function(self)
	if self:IsForbidden() then return end

	local debuffs = {}
	local ccs = {}

	for aura in self.auraItemFramePool:EnumerateActive() do
		local parent = aura:GetParent()
		if parent == self.DebuffListFrame then
			table.insert(debuffs, aura)
		elseif parent == self.CrowdControlListFrame then
			table.insert(ccs, aura)
		end
	end

	local function sortByIndex(a, b)
		return (a.layoutIndex or 0) < (b.layoutIndex or 0)
	end

	table.sort(debuffs, sortByIndex)
	table.sort(ccs, sortByIndex)

	local prevAura = nil
	for _, aura in ipairs(debuffs) do
		aura:SetScale(1)
		aura:ClearAllPoints()
		if prevAura then
			aura:SetPoint("TOPLEFT", prevAura, "TOPLEFT", 24, 0)
		else
			aura:SetPoint("TOPLEFT", self, "TOPLEFT")
		end
		prevAura = aura
	end

	for _, aura in ipairs(ccs) do
		aura:SetScale(1)
		aura:ClearAllPoints()
		if prevAura then
			aura:SetPoint("TOPLEFT", prevAura, "TOPLEFT", 24, 0)
		else
			aura:SetPoint("TOPLEFT", self, "TOPLEFT")
		end
		prevAura = aura
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

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
	if not frame or frame:IsForbidden() or not frame.unit then return end
	-- Further processing only for nameplate units
	if not frame.unit:find("nameplate") then return end

	if ( CompactUnitFrame_IsTapDenied(frame) or (UnitIsDead(frame.unit) and not UnitIsPlayer(frame.unit)) ) then
		frame.name:SetVertexColor(0.5, 0.5, 0.5)
	elseif not ( frame.optionTable.colorNameBySelection ) then
		if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) and not UnitIsFriend("player", frame.unit)  ) then
			frame.name:SetVertexColor(1.0, 0.0, 0.0)
		else
			frame.name:SetVertexColor(UnitSelectionColor(frame.unit, frame.optionTable.colorNameWithExtendedColors))
		end
	else
		frame.name:SetVertexColor(1.0, 1.0, 1.0)
	end
end)

local castbarColors = {}
castbarColors.Standard = CreateColor(1.0, 0.7, 0.0, 1)
castbarColors.Channel = CreateColor(0.0, 1.0, 0.0, 1)
castbarColors.Uninterruptable = CreateColor(0.7, 0.7, 0.7, 1)
castbarColors.Interrupted = CreateColor(1, 0, 0, 1)

local function SkinCastbar(self)
	if self:IsForbidden() then return end

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

	if self.Text then
		self.Text:ClearAllPoints()
		self.Text:SetAllPoints()
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
			frame.castBar.Text:SetTextHeight(16)
			frame.ClassificationFrame:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT", -2, 0)
			PixelUtil.SetHeight(frame.HealthBarsContainer, 15)
			frame.name:SetFontObject("CpSystemFont_LargeNamePlate")
		else
			frame.castBar:SetHeight(12)
			PixelUtil.SetPoint(frame.castBar, "BOTTOMLEFT", frame, "BOTTOMLEFT", 26, 0)
			PixelUtil.SetPoint(frame.castBar, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 0)
			frame.castBar.BorderShield:SetSize(12, 14)
			frame.castBar.Icon:SetSize(14, 14)
			frame.castBar.Text:SetTextHeight(12)
			frame.ClassificationFrame:SetPoint("RIGHT", frame.HealthBarsContainer, "LEFT")
			PixelUtil.SetHeight(frame.HealthBarsContainer, 5)
			frame.name:SetFontObject("CpSystemFont_NamePlate")
		end
		frame.castBar.BorderShield:ClearAllPoints()
		PixelUtil.SetPoint(frame.castBar.BorderShield, "CENTER", frame.castBar, "LEFT", 0, 0)
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
		if frame.AurasFrame then
			frame.AurasFrame:SetIgnoreParentScale(true)
			frame.AurasFrame:SetSize(88, 14)
			frame.AurasFrame:ClearAllPoints()
			frame.AurasFrame:SetPoint("LEFT", frame.HealthBarsContainer, "LEFT", -1, 0)
			if frame.HealthBarsContainer.healthBar:IsTarget() or frame.name:IsShown() then
				if ClassicPlatesDB.largerPlates then
					frame.AurasFrame:SetPoint("BOTTOM", frame, "TOP", 0, 20)
				else
					frame.AurasFrame:SetPoint("BOTTOM", frame, "TOP")
				end
			else
				frame.AurasFrame:SetPoint("BOTTOM", frame.HealthBarsContainer, "TOP", 0, 5)
			end
		end
		if frame.AurasFrame.BuffListFrame then
			frame.AurasFrame.BuffListFrame:SetAlpha(0)
		end
	end)

	frame.skinned = true
end

local f = CreateFrame("Frame")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:SetScript("OnEvent", function(self, event, unit)
	if event == "NAME_PLATE_UNIT_ADDED" then
		HandleNamePlateAdded(unit)
	end
end)