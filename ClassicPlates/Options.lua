if ClassicPlates_OptionsPanel == nil then ClassicPlates_OptionsPanel = {} end

------------------------------------
-- Options Panel
------------------------------------
local panel = CreateFrame("Frame")
panel.name = "Classic Plates"

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
Settings.RegisterAddOnCategory(category)
panel.categoryID = category:GetID()

local checkbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
checkbox:SetPoint("TOPLEFT", 16, -16)
checkbox.Text:SetFontObject('GameFontNormal')
checkbox.Text:SetText("Larger Plates")

checkbox:SetScript('OnShow', function(self)
    self:SetChecked(ClassicPlatesDB.largerPlates)
end)

checkbox:SetScript('OnClick', function(self)
    local enabled = self:GetChecked()
    ClassicPlatesDB.largerPlates = enabled
end)

------------------------------------
-- Slash Chat Command
------------------------------------
SLASH_CLASSICPLATES1 = "/cp"
SLASH_CLASSICPLATES2 = "/classicplates"

SlashCmdList["CLASSICPLATES"] = function()
    if InCombatLockdown() then
        print(_G.ERR_NOT_IN_COMBAT)
        return
    end
    Settings.OpenToCategory(panel.categoryID)
end