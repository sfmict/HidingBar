local addon, L = ...
local config = CreateFrame("FRAME", addon.."ConfigAddon", InterfaceOptionsFramePanelContainer)
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
		InterfaceAddOnsList_Update()
	else
		print("Failed to load "..name..": "..tostring(reason))
	end
end)


-- ADD CATEGORY
InterfaceOptions_AddCategory(config)


-- OPEN CONFIG
function config:openConfig()
	if InterfaceOptionsFrameAddOns:IsVisible() and self:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory(addon)
		if not InterfaceOptionsFrameAddOns:IsVisible() then
			InterfaceOptionsFrame_OpenToCategory(addon)
		end
	end
end


SLASH_HIDDINGBAR1 = "/hidingbar"
SlashCmdList["HIDDINGBAR"] = function() config:openConfig() end