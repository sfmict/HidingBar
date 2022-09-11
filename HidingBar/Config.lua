local addon, L = ...
local config = CreateFrame("FRAME", addon.."ConfigAddon")
config.name = addon
config:Hide()
config.L = L
config.noIcon = config:CreateTexture()


config:SetScript("OnShow", function(self)
	local name = addon.."_Options"
	if IsAddOnLoaded(name) then
		self:SetScript("OnShow", nil)
		return
	end
	if select(5, GetAddOnInfo(name)) == "DISABLED" then
		EnableAddOn(name)
	end
	local loaded, reason = LoadAddOn(name)
	if loaded then
		self:SetScript("OnShow", nil)
		SettingsPanel:GetCategoryList():CreateCategories()
	else
		print("Failed to load "..name..": "..tostring(reason))
	end
end)


-- ADD CATEGORY
local category, layout = Settings.RegisterCanvasLayoutCategory(config, addon)
Settings.RegisterAddOnCategory(category)


-- OPEN CONFIG
function config:openConfig()
	if SettingsPanel:IsVisible() and self:IsVisible() then
		HideUIPanel(SettingsPanel)
	else
		Settings.OpenToCategory(addon, true)
	end
end


SLASH_HIDDINGBAR1 = "/hidingbar"
SlashCmdList["HIDDINGBAR"] = function() config:openConfig() end