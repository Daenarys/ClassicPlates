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

hooksecurefunc(NamePlateAurasMixin, "RefreshList", function(self, listFrame)
	if self:IsForbidden() then return end

	for aura in self.auraItemFramePool:EnumerateActive() do
		aura:SetScale(1.4)
	end

	if listFrame == self.DebuffListFrame then
		local items = {}
		for aura in self.auraItemFramePool:EnumerateActive() do
			table.insert(items, aura)
		end

		table.sort(items, function(a, b) 
			return (a.layoutIndex or 0) < (b.layoutIndex or 0) 
		end)

		local prevAura = nil
		for _, aura in ipairs(items) do
			aura:ClearAllPoints()
			if prevAura then
				aura:SetPoint("TOPLEFT", prevAura, "TOPLEFT", 24, 0)
			else
				aura:SetPoint("TOPLEFT", listFrame, "TOPLEFT")
			end
			prevAura = aura
		end
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

hooksecurefunc(NamePlateUnitFrameMixin, "UpdateAnchors", function(self)
	if self:IsForbidden() then return end

	self.castBar:ClearAllPoints()
	self.ClassificationFrame:ClearAllPoints()
	if ClassicPlatesDB.largerPlates then
		self.castBar:SetHeight(22)
		PixelUtil.SetPoint(self.castBar, "BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		PixelUtil.SetPoint(self.castBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		self.castBar.BorderShield:SetSize(16, 18)
		self.castBar.Icon:SetSize(18, 18)
		self.castBar.Text:SetTextHeight(14)
		PixelUtil.SetHeight(self.HealthBarsContainer, 15)
		self.name:SetFontObject("CpSystemFont_LargeNamePlate")
		self.ClassificationFrame:SetPoint("RIGHT", self.HealthBarsContainer, "LEFT", -2, 0)
	else
		self.castBar:SetHeight(12)
		PixelUtil.SetPoint(self.castBar, "BOTTOMLEFT", self, "BOTTOMLEFT", 26, 0)
		PixelUtil.SetPoint(self.castBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -26, 0)
		self.castBar.BorderShield:SetSize(10, 12)
		self.castBar.Icon:SetSize(14, 14)
		self.castBar.Text:SetTextHeight(12)
		PixelUtil.SetHeight(self.HealthBarsContainer, 6)
		self.name:SetFontObject("CpSystemFont_NamePlate")
		self.ClassificationFrame:SetPoint("RIGHT", self.HealthBarsContainer, "LEFT")
	end
	self.castBar.Icon:ClearAllPoints()
	PixelUtil.SetPoint(self.castBar.Icon, "CENTER", self.castBar, "LEFT", 0, 0)
	self.ClassificationFrame:SetScale(1.4)
	self.ClassificationFrame:SetSize(14, 13)
	self.ClassificationFrame.classificationIndicator:SetSize(14, 13)
	self.HealthBarsContainer:ClearAllPoints()
	PixelUtil.SetPoint(self.HealthBarsContainer, "BOTTOMLEFT", self.castBar, "TOPLEFT", 0, 2.5)
	PixelUtil.SetPoint(self.HealthBarsContainer, "BOTTOMRIGHT", self.castBar, "TOPRIGHT", 0, 2.5)
	self.name:SetIgnoreParentScale(true)
	self.name:SetJustifyH("CENTER")
	self.name:ClearAllPoints()
	PixelUtil.SetPoint(self.name, "BOTTOM", self.HealthBarsContainer, "TOP", 0, 4)
	if self.AurasFrame.BuffListFrame then
		self.AurasFrame.BuffListFrame:SetAlpha(0)
	end
	if self.AurasFrame.DebuffListFrame then
		self.AurasFrame.DebuffListFrame:ClearAllPoints()
		self.AurasFrame.DebuffListFrame:SetPoint("LEFT", self.HealthBarsContainer, "LEFT", -2, 0)
		if self.HealthBarsContainer.healthBar:IsTarget() or self.name:IsShown() then
			self.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", self.name, "TOP", 0, 24)
		else
			self.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", self.name, "TOP", 0, -9)
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

local function SkinCastbar(self)
	if self:IsForbidden() then return end

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

	frame.skinned = true
end

local f = CreateFrame("Frame")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:SetScript("OnEvent", function(self, event, unit)
	if event == "NAME_PLATE_UNIT_ADDED" then
		HandleNamePlateAdded(unit)
	end
end)