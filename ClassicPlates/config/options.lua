local AddonName, Addon = ...

------------------------------------
-- Options Panel
------------------------------------
local panel = CreateFrame("Frame")
panel.name = AddonName

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
Settings.RegisterAddOnCategory(category)
panel.categoryID = category:GetID()

-- larger plates
local lpcheckbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
lpcheckbox:SetPoint("TOPLEFT", 16, -16)
lpcheckbox.Text:SetFontObject('GameFontNormal')
lpcheckbox.Text:SetText(UNIT_NAMEPLATES_MAKE_LARGER)
lpcheckbox:SetHitRectInsets(0, -lpcheckbox.Text:GetStringWidth(), 0, 0)

lpcheckbox:SetScript('OnShow', function(self)
	self:SetChecked(ClassicPlatesDB.largerPlates)
end)

lpcheckbox:SetScript('OnClick', function(self)
	local enabled = self:GetChecked()
	ClassicPlatesDB.largerPlates = enabled
end)

lpcheckbox:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:SetText(OPTION_TOOLTIP_UNIT_NAMEPLATES_MAKE_LARGER)
end)

lpcheckbox:SetScript('OnLeave', function(self)
	GameTooltip:Hide()
end)

-- old castbars
local occheckbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
occheckbox:SetPoint("TOPLEFT", 16, -48)
occheckbox.Text:SetFontObject('GameFontNormal')
occheckbox.Text:SetText("Classic Castbar")
occheckbox:SetHitRectInsets(0, -occheckbox.Text:GetStringWidth(), 0, 0)

occheckbox:SetScript('OnShow', function(self)
	self:SetChecked(ClassicPlatesDB.oldCastbar)
end)

occheckbox:SetScript('OnClick', function(self)
	local enabled = self:GetChecked()
	ClassicPlatesDB.oldCastbar = enabled
end)

occheckbox:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:SetText("Use the pre 10.x castbar style.")
end)

occheckbox:SetScript('OnLeave', function(self)
	GameTooltip:Hide()
end)

------------------------------------
-- Slash Chat Command
------------------------------------
SLASH_CLASSICPLATES1 = "/cp"
SLASH_CLASSICPLATES2 = "/classicplates"

SlashCmdList["CLASSICPLATES"] = function()
	if InCombatLockdown() then
		print("|cff33ff99Classic Plates|r:", _G.ERR_NOT_IN_COMBAT)
		return
	end

	Settings.OpenToCategory(panel.categoryID)
end