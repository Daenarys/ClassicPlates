if ClassicPlates_OptionsPanel == nil then ClassicPlates_OptionsPanel = {} end

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
lpcheckbox.Text:SetText("Larger Plates")

lpcheckbox:SetScript('OnShow', function(self)
    self:SetChecked(ClassicPlatesDB.largerPlates)
end)

lpcheckbox:SetScript('OnClick', function(self)
    local enabled = self:GetChecked()
    ClassicPlatesDB.largerPlates = enabled
end)

-- smaller castbar text
local sctcheckbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
sctcheckbox:SetPoint("TOPLEFT", 16, -48)
sctcheckbox.Text:SetFontObject('GameFontNormal')
sctcheckbox.Text:SetText("Smaller CastBar Text")

sctcheckbox:SetScript('OnShow', function(self)
    self:SetChecked(ClassicPlatesDB.smallerCastBarText)
end)

sctcheckbox:SetScript('OnClick', function(self)
    local enabled = self:GetChecked()
    ClassicPlatesDB.smallerCastBarText = enabled
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