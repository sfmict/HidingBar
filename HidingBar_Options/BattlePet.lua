local main = HidingBarConfigAddon
local L = main.L


-- PET BATTLE HIDE
main.petBattleHide = CreateFrame("CheckButton", nil, main.barSettingsPanel, "HidingBarAddonCheckButtonTemplate")
main.petBattleHide:SetPoint("TOPLEFT", main.fade, "BOTTOMLEFT", 0, -5)
main.petBattleHide.Text:SetText(L["Hide the bar in Pet Battle"])
main.petBattleHide:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	main.bConfig.petBattleHide = checked
	main.barFrame:refreshShown()
end)