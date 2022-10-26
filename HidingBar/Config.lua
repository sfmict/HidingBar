local addon, L = ...


local function onShow(self)
	self:SetPoint("TOPLEFT", -12, 8)
end


local function loadOptions(self)
	self:SetPoint("TOPLEFT", -12, 8)

	local name = addon.."_Options"
	if IsAddOnLoaded(name) then
		self:SetScript("OnShow", onShow)
		return
	end
	if select(5, GetAddOnInfo(name)) == "DISABLED" then
		EnableAddOn(name)
	end
	local loaded, reason = LoadAddOn(name)
	if loaded then
		self:SetScript("OnShow", onShow)
		-- SettingsPanel:GetCategoryList():CreateCategories()
	else
		print("Failed to load "..name..": "..tostring(reason))
	end
end


-- MAIN
local config = CreateFrame("FRAME", addon.."ConfigAddon")
config.name = addon
config:Hide()
config.L = L
config.noIcon = config:CreateTexture()
config:SetScript("OnShow", loadOptions)


-- ADD CATEGORY
local category, layout = Settings.RegisterCanvasLayoutCategory(config, addon)
category.ID = addon
-- layout:AddAnchorPoint("TOPLEFT", -12, 8)
-- layout:AddAnchorPoint("BOTTOMRIGHT", 0, 0)
Settings.RegisterAddOnCategory(category)


-- ABOUT
local aboutConfig = CreateFrame("FRAME", addon.."ConfigAbout")
aboutConfig:Hide()
aboutConfig:SetScript("OnShow", loadOptions)


-- ADD SUBCATEGORY
local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, aboutConfig,  L["About"])
subcategory.ID = L["About"]
Settings.RegisterAddOnCategory(subcategory)


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