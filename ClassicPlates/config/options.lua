local AddonName, Addon = ...

------------------------------------
-- Options Panel
------------------------------------
local panel = CreateFrame("Frame")
panel.name = "|A:gmchat-icon-blizz:16:16|aClassic |cff00c0ffPlates|r"

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
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

------------------------------------
-- Slash Chat Command
------------------------------------
SLASH_CLASSICPLATES1 = "/cp"
SLASH_CLASSICPLATES2 = "/classicplates"

SlashCmdList["CLASSICPLATES"] = function()
    if InCombatLockdown() then
        print("|A:gmchat-icon-blizz:16:16|aClassic |cff00c0ffPlates|r:", _G.ERR_NOT_IN_COMBAT)
        return
    end

    Settings.OpenToCategory(panel.categoryID)
end