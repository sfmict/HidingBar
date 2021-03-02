local main, hidingBar = HidingBarConfigAddon, HidingBarAddon
local addon, L, config = "HidingBar", main.L, hidingBar.config
main.noIcon = main:CreateTexture()
main.noIcon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
main.noIcon:SetTexCoord(.05, .95, .05, .95)
main.noIcon:Hide()
main.buttons, main.mbuttons, main.mixedButtons = {}, {}, {}
local offsetX, offsetY = 4, 4


main.optionsPanelBackdrop = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 14,
	edgeSize = 14,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}


main.editBoxBackdrop = {
	bgFile = "Interface/ChatFrame/ChatFrameBackground",
	edgeFile = "Interface/ChatFrame/ChatFrameBackground",
	tile = true, edgeSize = 1, tileSize = 5,
}


main.colorButtonBackdrop = {
	edgeFile = "Interface/ChatFrame/ChatFrameBackground",
	edgeSize = 1,
}


local function toHex(tbl)
	local str = ""
	for i = 1, #tbl do
		str = str..("%02x"):format(math.floor(tbl[i] * 255 + .5))
	end
	return str
end


local function tabClick(tab)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
	for i = 1, #tab.tabs do
		local checked = tab == tab.tabs[i]
		tab.tabs[i]:SetEnabled(not checked)
		tab.tabs[i].panel:SetShown(checked)
	end
end

local function createTabPanel(tabs, name)
	local panel = CreateFrame("FRAME", nil, main, "HidingBarAddonOptionsPanel")
	local tab = CreateFrame("BUTTON", nil, main, "HidingBarAddonTabTemplate")
	tab.panel = panel
	tab.tabs = tabs
	tab:SetText(name)
	tab:SetWidth(tab:GetTextWidth() + 48)
	tab:SetScript("OnClick", tabClick)

	if #tabs == 0 then
		tab:SetPoint("BOTTOMLEFT", panel, "TOPLEFT", 3, -1)
		tab:Disable()
	else
		local anchorTab = tabs[#tabs]
		tab:SetPoint("LEFT", anchorTab, "RIGHT", -16, 0)
		panel:SetPoint("TOPLEFT", anchorTab.panel)
		panel:SetPoint("BOTTOMRIGHT", anchorTab.panel)
		panel:Hide()
	end
	tinsert(tabs, tab)

	return panel
end

local settingsTabs, buttonTabs = {}, {}

-- DIALOGS
main.addonName = ("%s_ADDON_"):format(addon:upper())
StaticPopupDialogs[main.addonName.."GET_RELOAD"] = {
	text = addon..": "..L["RELOAD_INTERFACE_QUESTION"],
	button1 = YES,
	button2 = NO,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function() ReloadUI() end,
}
StaticPopupDialogs[main.addonName.."ADD_IGNORE_MBTN"] = {
	text = addon..": "..L["ADD_IGNORE_MBTN_QUESTION"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}
StaticPopupDialogs[main.addonName.."REMOVE_IGNORE_MBTN"] = {
	text = addon..": "..L["REMOVE_IGNORE_MBTN_QUESTION"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}

-- ADDON INFO
local info = main:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
info:SetPoint("TOPRIGHT", -16, 16)
info:SetTextColor(.5, .5, .5, 1)
info:SetJustifyH("RIGHT")
info:SetText(("%s"):format(GetAddOnMetadata(addon, "Version")))

-- TITLE
local title = main:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetJustifyH("LEFT")
title:SetText(L["%s Configuration"]:format(addon))

-- GENERAL TAB PANEL
main.generalPanel = createTabPanel(settingsTabs, L["General"])
main.generalPanel:SetPoint("TOPLEFT", 8, -58)
main.generalPanel:SetPoint("BOTTOMRIGHT", main, -8, 275)

-- EXPAND TO TEXT
local expandToText = main.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
expandToText:SetPoint("TOPRIGHT", -10, -8)
expandToText:SetWidth(114)
expandToText:SetText(L["Expand to"])

-- EXPAND TO COMBOBOX
local expandToCombobox = CreateFrame("FRAME", "HidingBarAddonExpandTo", main.generalPanel, "UIDropDownMenuTemplate")
expandToCombobox:SetPoint("TOPRIGHT", expandToText, "BOTTOMRIGHT", 17, -2)
UIDropDownMenu_SetWidth(expandToCombobox, 100)

local function updateExpandTo(btn)
	UIDropDownMenu_SetSelectedValue(expandToCombobox, btn.value)
	hidingBar:setBarExpand(btn.value)
	main:hidingBarUpdate()
end

UIDropDownMenu_Initialize(expandToCombobox, function(self, level)
	local info = UIDropDownMenu_CreateInfo()

	info.checked = nil
	info.text = L["Right / Bottom"]
	info.value = 0
	info.func = updateExpandTo
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Left / Top"]
	info.value = 1
	info.func = updateExpandTo
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Both direction"]
	info.value = 2
	info.func = updateExpandTo
	UIDropDownMenu_AddButton(info)
end)
UIDropDownMenu_SetSelectedValue(expandToCombobox, config.expand)

-- LINE COLOR
local lineColor = CreateFrame("BUTTON", nil, main.generalPanel, "HidingBarAddonColorButton")
lineColor:SetPoint("TOPRIGHT", expandToCombobox, "BOTTOMRIGHT", -18, -2)
lineColor.color:SetColorTexture(unpack(config.lineColor))
local lineColorText = main.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
lineColorText:SetPoint("RIGHT", lineColor, "LEFT", -3, 0)
lineColorText:SetJustifyH("RIGHT")
lineColorText:SetText(L["Line"])

lineColor.swatchFunc = function()
	hidingBar:setLineColor(ColorPickerFrame:GetColorRGB())
	local hexColor = toHex(config.lineColor)
	main.description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))
	main.fade.Text:SetText(L["Fade out line"]:format(hexColor))
	main.lineWidth.text:SetText(L["Line width"]:format(hexColor))
	lineColor.color:SetColorTexture(unpack(config.lineColor))
	main:hidingBarUpdate()
end
lineColor.cancelFunc = function(color)
	hidingBar:setLineColor(color.r, color.g, color.b)
	local hexColor = toHex(config.lineColor)
	main.description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))
	main.fade.Text:SetText(L["Fade out line"]:format(hexColor))
	main.lineWidth.text:SetText(L["Line width"]:format(hexColor))
	lineColor.color:SetColorTexture(unpack(config.lineColor))
	main:hidingBarUpdate()
end
lineColor:SetScript("OnClick", function(btn)
	if ColorPickerFrame:IsShown() and ColorPickerFrame.cancelFunc then
		ColorPickerFrame.cancelFunc(ColorPickerFrame.previousValues)
		HideUIPanel(ColorPickerFrame)
	end
	btn.r, btn.g, btn.b = unpack(config.lineColor)
	OpenColorPicker(btn)
end)

-- BACKGROUND COLOR
local bgColor = CreateFrame("BUTTON", nil, main.generalPanel, "HidingBarAddonColorButton")
bgColor:SetPoint("TOPRIGHT", lineColor, "BOTTOMRIGHT", 0, -3)
bgColor.color:SetColorTexture(unpack(config.bgColor))
local bgColorText = main.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
bgColorText:SetPoint("RIGHT", bgColor, "LEFT", -3, 0)
bgColorText:SetJustifyH("RIGHT")
bgColorText:SetText(L["Background"])

bgColor.hasOpacity = true
bgColor.swatchFunc = function()
	hidingBar:setBackgroundColor(ColorPickerFrame:GetColorRGB())
	main.buttonPanel.bg:SetVertexColor(unpack(config.bgColor))
	bgColor.color:SetColorTexture(unpack(config.bgColor))
	main:hidingBarUpdate()
end
bgColor.opacityFunc = function()
	hidingBar:setBackgroundColor(nil, nil, nil, OpacitySliderFrame:GetValue())
	main.buttonPanel.bg:SetVertexColor(unpack(config.bgColor))
	bgColor.color:SetColorTexture(unpack(config.bgColor))
	main:hidingBarUpdate()
end
bgColor.cancelFunc = function(color)
	hidingBar:setBackgroundColor(color.r, color.g, color.b, color.opacity)
	main.buttonPanel.bg:SetVertexColor(unpack(config.bgColor))
	bgColor.color:SetColorTexture(unpack(config.bgColor))
	main:hidingBarUpdate()
end
bgColor:SetScript("OnClick", function(btn)
	if ColorPickerFrame:IsShown() and ColorPickerFrame.cancelFunc then
		ColorPickerFrame.cancelFunc(ColorPickerFrame.previousValues)
		HideUIPanel(ColorPickerFrame)
	end
	btn.r, btn.g, btn.b, btn.opacity = unpack(config.bgColor)
	OpenColorPicker(btn)
end)

-- DESCRIPTION
local hexColor = toHex(config.lineColor)
main.description = main.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
main.description:SetPoint("TOPLEFT", 8, -10)
main.description:SetJustifyH("LEFT")
main.description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))
local locale = GetLocale()
if locale == "zhTW" or locale == "zhCN" then
	main.description:SetFont(main.description:GetFont(), 12)
end

-- ORIENTATION TEXT
local orientationText = main.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
orientationText:SetPoint("TOPLEFT", main.description, "BOTTOMLEFT", 0, -23)
orientationText:SetText(L["Orientation"])

-- ORIENTATION COMBOBOX
local orientationCombobox = CreateFrame("FRAME", "HidingBarAddonOrientation", main.generalPanel, "UIDropDownMenuTemplate")
orientationCombobox:SetPoint("LEFT", orientationText, "RIGHT", -12, 0)
UIDropDownMenu_SetWidth(orientationCombobox, 100)

local function orientationChange(btn)
	UIDropDownMenu_SetSelectedValue(orientationCombobox, btn.value)
	hidingBar:setOrientation(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

UIDropDownMenu_Initialize(orientationCombobox, function(self, level)
	local info = UIDropDownMenu_CreateInfo()

	info.checked = nil
	info.text = L["Auto"]
	info.value = 0
	info.func = orientationChange
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Horizontal"]
	info.value = 1
	info.func = orientationChange
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Vertical"]
	info.value = 2
	info.func = orientationChange
	UIDropDownMenu_AddButton(info)
end)
UIDropDownMenu_SetSelectedValue(orientationCombobox, config.orientation)

-- FRAME STARTA TEXT
local fsText = main.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
fsText:SetPoint("LEFT", orientationCombobox, "RIGHT", -5, 0)
fsText:SetText(L["Strata of panel"])

-- FRAME STRATA COMBOBOX
local fsCombobox = CreateFrame("FRAME", "HidingBarAddonFrameStrata", main.generalPanel, "UIDropDownMenuTemplate")
fsCombobox:SetPoint("LEFT", fsText, "RIGHT", -12, 0)
UIDropDownMenu_SetWidth(fsCombobox, 100)

local function fsChange(btn)
	UIDropDownMenu_SetSelectedValue(fsCombobox, btn.value)
	hidingBar:setFrameStrata(btn.value)
end

UIDropDownMenu_Initialize(fsCombobox, function(self, level)
	local info = UIDropDownMenu_CreateInfo()

	for i, v in ipairs({"MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"}) do
		info.checked = nil
		info.text = v
		info.value = i - 1
		info.func = fsChange
		UIDropDownMenu_AddButton(info)
	end
end)
UIDropDownMenu_SetSelectedValue(fsCombobox, config.frameStrata)

-- LOCK
main.lock = CreateFrame("CheckButton", nil, main.generalPanel, "HidingBarAddonCheckButtonTemplate")
main.lock:SetPoint("TOPLEFT", orientationText, "BOTTOMLEFT", 0, -7)
main.lock.Text:SetText(L["Lock the bar's location"])
main.lock:SetChecked(config.lock)
main.lock:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	hidingBar:setLocked(checked)
end)
hidingBar:on("LOCK_UPDATED", function(_, isLocked) main.lock:SetChecked(isLocked) end)

-- FADE
main.fade = CreateFrame("CheckButton", nil, main.generalPanel, "HidingBarAddonCheckButtonTemplate")
main.fade:SetPoint("TOPLEFT", main.lock, "BOTTOMLEFT", 0, 0)
main.fade.Text:SetText(L["Fade out line"]:format(hexColor))
main.fade:SetChecked(config.fade)
main.fade:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	main.fadeOpacity:SetEnabled(checked)
	hidingBar:setFade(checked)
end)

-- FADE OPACITY
main.fadeOpacity = CreateFrame("SLIDER", nil, main.generalPanel, "HidingBarAddonSliderTemplate")
main.fadeOpacity:SetPoint("LEFT", main.fade.Text, "RIGHT", 20, 0)
main.fadeOpacity:SetPoint("RIGHT", -30, 0)
main.fadeOpacity:SetMinMaxValues(0, .95)
main.fadeOpacity.step = 1 / .05
main.fadeOpacity.text:SetText(L["Opacity"])
main.fadeOpacity:SetValue(config.fadeOpacity)
main.fadeOpacity.label:SetText(config.fadeOpacity)
main.fadeOpacity:SetEnabled(config.fade)
main.fadeOpacity:SetScript("OnValueChanged", function(slider, value)
	value = math.floor(value * slider.step + .5) / slider.step
	hidingBar:setFadeOpacity(value)
	slider.label:SetText(value)
	slider:SetValue(value)
end)

-- LINE WIDTH
main.lineWidth = CreateFrame("SLIDER", nil, main.generalPanel, "HidingBarAddonSliderTemplate")
main.lineWidth:SetPoint("TOPLEFT", main.fade, "BOTTOMLEFT", 0, -15)
main.lineWidth:SetPoint("RIGHT", -30, 0)
main.lineWidth:SetMinMaxValues(4, 10)
main.lineWidth.text:SetText(L["Line width"]:format(hexColor))
main.lineWidth:SetValue(config.lineWidth)
main.lineWidth.label:SetText(config.lineWidth)
main.lineWidth:SetScript("OnValueChanged", function(slider, value)
	value = math.floor(value * 10 + .5) / 10
	hidingBar:setLineWidth(value)
	slider.label:SetText(value)
	slider:SetValue(value)
end)

-- SHOW HANDLER TEXT
local showHandlerText = main.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
showHandlerText:SetPoint("TOPLEFT", main.lineWidth, "BOTTOMLEFT", 0, -20)
showHandlerText:SetText(L["Show on"])

-- SHOW HANDLER
local showHandlerCombobox = CreateFrame("FRAME", "HidingBarAddonShowHandler", main.generalPanel, "UIDropDownMenuTemplate")
showHandlerCombobox:SetPoint("LEFT", showHandlerText, "RIGHT", -12, 0)
UIDropDownMenu_SetWidth(showHandlerCombobox, 100)

local function updateShowHandler(btn)
	UIDropDownMenu_SetSelectedValue(showHandlerCombobox, btn.value)
	hidingBar.drag:setShowHandler(btn.value)
end

UIDropDownMenu_Initialize(showHandlerCombobox, function(self, level)
	local info = UIDropDownMenu_CreateInfo()

	info.checked = nil
	info.text = L["Hover"]
	info.value = 0
	info.func = updateShowHandler
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Click"]
	info.value = 1
	info.func = updateShowHandler
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Hover or Click"]
	info.value = 2
	info.func = updateShowHandler
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Allways"]
	info.value = 3
	info.func = updateShowHandler
	UIDropDownMenu_AddButton(info)
end)
UIDropDownMenu_SetSelectedValue(showHandlerCombobox, config.showHandler)

-- DELAY TO SHOW
local delayToShowText = main.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
delayToShowText:SetPoint("LEFT", showHandlerCombobox, "RIGHT", -5, 0)
delayToShowText:SetText(L["Delay to show"])

local delayToShowEditBox = CreateFrame("EditBox", nil, main.generalPanel, "HidingBarAddonDecimalTextBox")
delayToShowEditBox:SetPoint("LEFT", delayToShowText, "RIGHT", 2, 0)
delayToShowEditBox:SetNumber(config.showDelay)
delayToShowEditBox:SetCursorPosition(0)
delayToShowEditBox:SetScript("OnTextChanged", function(editBox, userInput)
	if userInput then
		local int, dec = editBox:GetText():gsub(",", "."):match("(%d*)(%.?%d*)")
		if int == "" and dec ~= "" then int = "0" end
		local decimalText = int..dec
		editBox:SetNumber(decimalText)
		config.showDelay = tonumber(decimalText) or 0
	end
end)
delayToShowEditBox:SetScript("OnEditFocusLost", function(editBox)
	editBox:SetNumber(config.showDelay)
	editBox:HighlightText(0, 0)
end)

-- DELAY TO HIDE
local delayToHideText = main.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
delayToHideText:SetPoint("LEFT", delayToShowEditBox, "RIGHT", 10, 0)
delayToHideText:SetText(L["Delay to hide"])

local delayToHideEditBox = CreateFrame("EditBox", nil, main.generalPanel, "HidingBarAddonDecimalTextBox")
delayToHideEditBox:SetPoint("LEFT", delayToHideText, "RIGHT", 2, 0)
delayToHideEditBox:SetNumber(config.hideDelay)
delayToHideEditBox:SetCursorPosition(0)
delayToHideEditBox:SetScript("OnTextChanged", function(editBox, userInput)
	if userInput then
		local int, dec = editBox:GetText():gsub(",", "."):match("(%d*)(%.?%d*)")
		if int == "" and dec ~= "" then int = "0" end
		local decimalText = int..dec
		editBox:SetNumber(decimalText)
		config.hideDelay = tonumber(decimalText) or 0
	end
end)
delayToHideEditBox:SetScript("OnEditFocusLost", function(editBox)
	editBox:SetNumber(config.hideDelay)
	editBox:HighlightText(0, 0)
end)

-- BUTTON TAB PANEL
main.buttonSettingsPanel = createTabPanel(settingsTabs, L["Button settings"])

-- GRAB ADDONS BUTTONS
main.grab = CreateFrame("CheckButton", nil, main.buttonSettingsPanel, "HidingBarAddonCheckButtonTemplate")
main.grab:SetPoint("TOPLEFT", 8, -8)
main.grab.Text:SetText(L["Grab addon buttons on minimap"])
main.grab:SetChecked(config.grabMinimap)
main.grab:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	config.grabMinimap = checked
	main.grabAfter:SetEnabled(checked)
	main.grabWithoutName:SetEnabled(checked)
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

-- GRAB AFTER N SECOND
main.grabAfter = CreateFrame("CheckButton", nil, main.buttonSettingsPanel, "HidingBarAddonCheckButtonTemplate")
main.grabAfter:SetPoint("TOPLEFT", main.grab, "BOTTOMLEFT", 20, 0)
main.grabAfter.Text:SetText(L["Try to grab after"])
main.grabAfter:SetHitRectInsets(0, -main.grabAfter.Text:GetWidth(), 0, 0)
main.grabAfter:SetChecked(config.grabMinimapAfter)
main.grabAfter:SetScript("OnClick", function(btn)
	config.grabMinimapAfter = btn:GetChecked()
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

main.afterNumber = CreateFrame("EditBox", nil, main.buttonSettingsPanel, "HidingBarAddonNumberTextBox")
main.afterNumber:SetPoint("LEFT", main.grabAfter.Text, "RIGHT", 3, 0)
main.afterNumber:SetText(config.grabMinimapAfterN)
main.afterNumber:SetScript("OnTextChanged", function(editBox, userInput)
	if userInput then
		local n = tonumber(editBox:GetText()) or 1
		if n < 1 then n = 1 end
		editBox:SetText(n)
		config.grabMinimapAfterN = n
		editBox:HighlightText()
	end
end)

main.grabAfterTextSec = main.buttonSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
main.grabAfterTextSec:SetPoint("LEFT", main.afterNumber, "RIGHT", 3, 0)
main.grabAfterTextSec:SetText(L["sec."])

main.grabAfter:HookScript("OnEnable", function(btn)
	main.afterNumber:Enable()
	main.grabAfterTextSec:SetTextColor(btn.Text:GetTextColor())
end)
main.grabAfter:HookScript("OnDisable", function(btn)
	main.afterNumber:Disable()
	main.grabAfterTextSec:SetTextColor(btn.Text:GetTextColor())
end)
main.grabAfter:SetEnabled(config.grabMinimap)

-- GRAB WITHOUT NAME
main.grabWithoutName = CreateFrame("CheckButton", nil, main.buttonSettingsPanel, "HidingBarAddonCheckButtonTemplate")
main.grabWithoutName:SetPoint("TOPLEFT", main.grabAfter, "BOTTOMLEFT", 0, 0)
main.grabWithoutName.Text:SetText(L["Grab buttons without a name"])
main.grabWithoutName:SetEnabled(config.grabMinimap)
main.grabWithoutName:SetChecked(config.grabMinimapWithoutName)
main.grabWithoutName:SetScript("OnClick", function(btn)
	config.grabMinimapWithoutName = btn:GetChecked()
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

-- SLIDER NUMBER BUTTONS IN ROW
local buttonNumber = CreateFrame("SLIDER", nil, main.buttonSettingsPanel, "HidingBarAddonSliderTemplate")
buttonNumber:SetPoint("TOPLEFT", main.grabWithoutName, "BOTTOMLEFT", -20, -20)
buttonNumber:SetPoint("RIGHT", -30, 0)
buttonNumber:SetMinMaxValues(1, 30)
buttonNumber.text:SetText(L["Number of buttons"])
buttonNumber:SetValue(config.size)
buttonNumber.label:SetText(config.size)
buttonNumber:SetScript("OnValueChanged", function(slider, value)
	value = math.floor(value + .5)
	slider:SetValue(value)
	if config.size ~= value then
		slider.label:SetText(value)
		hidingBar:setMaxButtons(value)
		main:applyLayout(.3)
		main:hidingBarUpdate()
	end
end)

-- SLIDER BUTTONS SIZE
local buttonSize = CreateFrame("SLIDER", nil, main.buttonSettingsPanel, "HidingBarAddonSliderTemplate")
buttonSize:SetPoint("TOPLEFT", buttonNumber, "BOTTOMLEFT", 0, -18)
buttonSize:SetPoint("RIGHT", -30, 0)
buttonSize:SetPoint("RIGHT", -30, 0)
buttonSize:SetMinMaxValues(16, 64)
buttonSize.text:SetText(L["Buttons Size"])
buttonSize:SetValue(config.buttonSize)
buttonSize.label:SetText(config.buttonSize)
buttonSize:SetScript("OnValueChanged", function(slider, value)
	value = math.floor(value + .5)
	slider:SetValue(value)
	if config.buttonSize ~= value then
		slider.label:SetText(value)
		hidingBar:setButtonSize(value)
		main:setButtonSize()
		main:applyLayout(.3)
		main:hidingBarUpdate()
	end
end)

-- POSTION OF MINIMAP BUTTON TEXT
local mbtnPostionText = main.buttonSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
mbtnPostionText:SetPoint("TOPLEFT", buttonSize, "BOTTOMLEFT", 0, -20)
mbtnPostionText:SetText(L["Position of minimap buttons"])

-- POSITION OF MINIMAP BUTTON
local mbtnPostionCombobox = CreateFrame("FRAME", "HidingBarAddonMBtnPosition", main.buttonSettingsPanel, "UIDropDownMenuTemplate")
mbtnPostionCombobox:SetPoint("LEFT", mbtnPostionText, "RIGHT", -12, 0)
UIDropDownMenu_SetWidth(mbtnPostionCombobox, 100)

local function updateMBtnPostion(btn)
	UIDropDownMenu_SetSelectedValue(mbtnPostionCombobox, btn.value)
	hidingBar:setMBtnPosition(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

UIDropDownMenu_Initialize(mbtnPostionCombobox, function(self, level)
	local info = UIDropDownMenu_CreateInfo()

	info.checked = nil
	info.text = L["A new line"]
	info.value = 0
	info.func = updateMBtnPostion
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Followed"]
	info.value = 1
	info.func = updateMBtnPostion
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Mixed"]
	info.value = 2
	info.func = updateMBtnPostion
	UIDropDownMenu_AddButton(info)
end)
UIDropDownMenu_SetSelectedValue(mbtnPostionCombobox, config.mbtnPosition)

-- POSITION BAR PANEL
main.positionBarPanel = createTabPanel(settingsTabs, L["Bar position"])

local function updateBarTypePosition()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	main.attachedToSide.check:SetShown(config.barTypePosition == 0)
	main.freeMove.check:SetShown(config.barTypePosition == 1)
	main.likeMB.check:SetShown(config.barTypePosition == 2)

	if config.barTypePosition == 1 then
		UIDropDownMenu_EnableDropDown(main.hideToCombobox)
	else
		UIDropDownMenu_DisableDropDown(main.hideToCombobox)
	end
	main.coordX:SetEnabled(config.barTypePosition == 1)
	main.coordY:SetEnabled(config.barTypePosition == 1)

	if config.barTypePosition == 2 then
		UIDropDownMenu_EnableDropDown(main.ombShowToCombobox)
	else
		UIDropDownMenu_DisableDropDown(main.ombShowToCombobox)
	end
	main.ombSize:SetEnabled(config.barTypePosition == 2)
end

-- BAR ATTACHED TO THE SIDE
main.attachedToSide = CreateFrame("BUTTON", nil, main.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
main.attachedToSide:SetPoint("TOPLEFT", 8, -8)
main.attachedToSide.Text:SetText(L["Bar attached to the side"])
main.attachedToSide:SetScript("OnClick", function()
	hidingBar:setBarCoords(nil, 0)
	hidingBar:setBarTypePosition(0)
	main:applyLayout(.3)
	updateBarTypePosition()
	main:hidingBarUpdate()
end)

-- BAR MOVES FREELY
main.freeMove = CreateFrame("BUTTON", nil, main.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
main.freeMove:SetPoint("TOPLEFT", main.attachedToSide, "BOTTOMLEFT")
main.freeMove.Text:SetText(L["Bar moves freely"])
main.freeMove:SetScript("OnClick", function()
	hidingBar:setBarTypePosition(1)
	main:applyLayout(.3)
	updateBarTypePosition()
	main:hidingBarUpdate()
end)

-- HIDE TO
main.hideToCombobox = CreateFrame("FRAME", "HidingBarAddonHideTo", main.positionBarPanel , "UIDropDownMenuTemplate")
main.hideToCombobox:SetPoint("TOPLEFT", main.freeMove, "BOTTOMLEFT", 8, 0)
UIDropDownMenu_SetWidth(main.hideToCombobox, 100)

local function updateBarAnchor(btn)
	UIDropDownMenu_SetSelectedValue(main.hideToCombobox, btn.value)
	hidingBar:setBarAnchor(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

local hideToComboboxOpptions = {
	left = L["Hiding to left"],
	right = L["Hiding to right"],
	top = L["Hiding to up"],
	bottom = L["Hiding to down"],
}

UIDropDownMenu_Initialize(main.hideToCombobox, function(self, level)
	local info = UIDropDownMenu_CreateInfo()

	for value, text in pairs(hideToComboboxOpptions) do
		info.checked = nil
		info.text = text
		info.value = value
		info.func = updateBarAnchor
		UIDropDownMenu_AddButton(info)
	end
end)
UIDropDownMenu_SetSelectedValue(main.hideToCombobox, config.anchor)

hidingBar:on("ANCHOR_UPDATED", function(_, value)
	UIDropDownMenu_SetSelectedValue(main.hideToCombobox, value)
	UIDropDownMenu_SetText(main.hideToCombobox, hideToComboboxOpptions[value])
	main:applyLayout(.3)
end)

-- COORD X
main.coordXText = main.positionBarPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
main.coordXText:SetPoint("LEFT", main.hideToCombobox, "RIGHT", -5, 2)
main.coordXText:SetText("X")

main.coordX = CreateFrame("EditBox", nil, main.positionBarPanel, "HidingBarAddonCoordTextBox")
main.coordX:SetPoint("LEFT", main.coordXText, "RIGHT", 1, 0)
main.coordX:SetScript("OnTextChanged", function(editBox, userInput)
	if userInput then
		editBox:SetNumber(editBox:GetText():match("%-?%d*"))
	end
end)
main.coordX.setX = function(editBox, x)
	if config.anchor == "left" or config.anchor == "right" then
		hidingBar:setBarCoords(nil, x)
	else
		hidingBar:setBarCoords(x)
	end
	hidingBar:updateBarPosition()
end
main.coordX:SetScript("OnEnterPressed", function(editBox)
	editBox:setX(tonumber(editBox:GetText():match("%-?%d*")) or 0)
	editBox:ClearFocus()
end)
main.coordX:SetScript("OnEditFocusLost", function(editBox)
	main:updateCoords()
	editBox:HighlightText(0, 0)
end)
main.coordX:SetScript("OnMouseWheel", function(editBox, delta)
	if editBox:IsEnabled() then
		local int = tonumber(editBox:GetText():match("%-?%d*")) or 0
		editBox:setX(int + (delta > 0 and 1 or -1))
	end
end)

-- COORD Y
main.coordYText = main.positionBarPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
main.coordYText:SetPoint("LEFT", main.coordX, "RIGHT", 5, 0)
main.coordYText:SetText("Y")

main.coordY = CreateFrame("EditBox", nil, main.positionBarPanel, "HidingBarAddonCoordTextBox")
main.coordY:SetPoint("LEFT", main.coordYText, "RIGHT", 1, 0)
main.coordY:SetScript("OnTextChanged", function(editBox, userInput)
	if userInput then
		editBox:SetNumber(editBox:GetText():match("%-?%d*"))
	end
end)
main.coordY.setY = function(editBox, y)
	if config.anchor == "left" or config.anchor == "right" then
		hidingBar:setBarCoords(y)
	else
		hidingBar:setBarCoords(nil, y)
	end
	hidingBar:updateBarPosition()
end
main.coordY:SetScript("OnEnterPressed", function(editBox)
	editBox:setY(tonumber(editBox:GetText():match("%-?%d*")) or 0)
	editBox:ClearFocus()
end)
main.coordY:SetScript("OnEditFocusLost", function(editBox)
	main:updateCoords()
	editBox:HighlightText(0, 0)
end)
main.coordY:SetScript("OnMouseWheel", function(editBox, delta)
	if editBox:IsEnabled() then
		local int = tonumber(editBox:GetText():match("%-?%d*")) or 0
		editBox:setY(int + (delta > 0 and 1 or -1))
	end
end)

-- BAR LIKE MINIMAP BUTTON
main.likeMB = CreateFrame("BUTTON", nil, main.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
main.likeMB:SetPoint("TOPLEFT", main.hideToCombobox, "BOTTOMLEFT", -8, 0)
main.likeMB.Text:SetText(L["Bar like a minimap button"])
main.likeMB:SetScript("OnClick", function()
	hidingBar:setBarTypePosition(2)
	main:applyLayout(.3)
	updateBarTypePosition()
	main:hidingBarUpdate()
end)

-- MINIMAP BUTTON SHOW TO
main.ombShowToCombobox = CreateFrame("FRAME", "HidingBarAddonMBShowTo", main.positionBarPanel, "UIDropDownMenuTemplate")
main.ombShowToCombobox:SetPoint("TOPLEFT", main.likeMB, "BOTTOMLEFT", 8, 0)
UIDropDownMenu_SetWidth(main.ombShowToCombobox, 100)

local function mbShowToChange(btn)
	UIDropDownMenu_SetSelectedValue(main.ombShowToCombobox, btn.value)
	hidingBar:setOMBAnchor(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

UIDropDownMenu_Initialize(main.ombShowToCombobox, function(self, level)
	local info = UIDropDownMenu_CreateInfo()

	info.checked = nil
	info.text = L["Show to left"]
	info.value = "right"
	info.func = mbShowToChange
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Show to right"]
	info.value = "left"
	info.func = mbShowToChange
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Show to up"]
	info.value = "bottom"
	info.func = mbShowToChange
	UIDropDownMenu_AddButton(info)

	info.checked = nil
	info.text = L["Show to down"]
	info.value = "top"
	info.func = mbShowToChange
	UIDropDownMenu_AddButton(info)
end)
UIDropDownMenu_SetSelectedValue(main.ombShowToCombobox, config.omb.anchor)

-- SLIDER MINIMAP BUTTON SIZE
main.ombSize = CreateFrame("SLIDER", nil, main.positionBarPanel, "HidingBarAddonSliderTemplate")
main.ombSize:SetPoint("LEFT", main.ombShowToCombobox, "RIGHT", -5, 0)
main.ombSize:SetPoint("RIGHT", -30, 0)
main.ombSize:SetMinMaxValues(16, 64)
main.ombSize.text:SetText(L["Button Size"])
main.ombSize:SetValue(config.omb.size)
main.ombSize.label:SetText(config.omb.size)
main.ombSize:SetScript("OnValueChanged", function(slider, value)
	value = math.floor(value + .5)
	slider:SetValue(value)
	if config.omb.size ~= value then
		slider.label:SetText(value)
		hidingBar:setOMBSize(value)
		hidingBar:setBarTypePosition()
	end
end)

-- UPDATE BAR TYPE POSITION OPTIONS
updateBarTypePosition()

-- BUTTONS TAB PANEL
main.buttonsTabPanel = createTabPanel(buttonTabs, L["Buttons"])
main.buttonsTabPanel:SetPoint("TOPLEFT", main.generalPanel, "BOTTOMLEFT", 0, -25)
main.buttonsTabPanel:SetPoint("BOTTOMRIGHT", main, -8, 8)

local buttonsTabPanelScroll = CreateFrame("ScrollFrame", nil, main.buttonsTabPanel, "UIPanelScrollFrameTemplate")
buttonsTabPanelScroll:SetPoint("TOPLEFT", main.buttonsTabPanel, 4, -6)
buttonsTabPanelScroll:SetPoint("BOTTOMRIGHT", main.buttonsTabPanel, -26, 20)
buttonsTabPanelScroll.ScrollBar.bg = buttonsTabPanelScroll.ScrollBar:CreateTexture(nil, "BACKGROUND")
buttonsTabPanelScroll.ScrollBar.bg:SetAllPoints()
buttonsTabPanelScroll.ScrollBar.bg:SetTexture("interface/buttons/white8x8")
buttonsTabPanelScroll.ScrollBar.bg:SetVertexColor(0, 0, 0, .2)
buttonsTabPanelScroll.HScrollBar = CreateFrame("SLIDER", nil, buttonsTabPanelScroll)
local HScrollBar = buttonsTabPanelScroll.HScrollBar
HScrollBar:SetOrientation("horizontal")
HScrollBar:SetSize(0, 16)
HScrollBar:SetPoint("TOPLEFT", buttonsTabPanelScroll, "BOTTOMLEFT", 19, 0)
HScrollBar:SetPoint("TOPRIGHT", buttonsTabPanelScroll, "BOTTOMRIGHT", -12, 0)
HScrollBar:SetThumbTexture("Interface/Buttons/UI-ScrollBar-Knob")
HScrollBar:SetMinMaxValues(0, 0)
HScrollBar:SetValue(0)
HScrollBar.thumb = HScrollBar:GetThumbTexture()
HScrollBar.thumb:SetSize(18, 24)
HScrollBar.thumb:SetTexCoord(.20, .80, .125, 0.875)
HScrollBar.bg = HScrollBar:CreateTexture(nil, "BACKGROUND")
HScrollBar.bg:SetAllPoints()
HScrollBar.bg:SetTexture("interface/buttons/white8x8")
HScrollBar.bg:SetVertexColor(0, 0, 0, .2)
HScrollBar.leftBtn = CreateFrame("BUTTON", nil, HScrollBar, "UIPanelScrollUpButtonTemplate")
HScrollBar.leftBtn:SetPoint("RIGHT", HScrollBar, "LEFT", 0, 1)
HScrollBar.leftBtn:GetNormalTexture():SetRotation(math.pi/2)
HScrollBar.leftBtn:GetPushedTexture():SetRotation(math.pi/2)
HScrollBar.leftBtn:GetDisabledTexture():SetRotation(math.pi/2)
HScrollBar.leftBtn:GetHighlightTexture():SetRotation(math.pi/2)
HScrollBar.leftBtn:Disable()
HScrollBar.leftBtn:SetScript("OnClick", function(btn)
	local parent = btn:GetParent()
	parent:SetValue(parent:GetValue() - parent:GetWidth() / 2)
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
end)
HScrollBar.rightBtn = CreateFrame("BUTTON", nil, HScrollBar, "UIPanelScrollDownButtonTemplate")
HScrollBar.rightBtn:SetPoint("LEFT", HScrollBar, "RIGHT", 0, 1)
HScrollBar.rightBtn:GetNormalTexture():SetRotation(math.pi/2)
HScrollBar.rightBtn:GetPushedTexture():SetRotation(math.pi/2)
HScrollBar.rightBtn:GetDisabledTexture():SetRotation(math.pi/2)
HScrollBar.rightBtn:GetHighlightTexture():SetRotation(math.pi/2)
HScrollBar.rightBtn:Disable()
HScrollBar.rightBtn:SetScript("OnClick", function(btn)
	local parent = btn:GetParent()
	parent:SetValue(parent:GetValue() + parent:GetWidth() / 2)
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
end)
HScrollBar:SetScript("OnValueChanged", function(self, value)
	self:GetParent():SetHorizontalScroll(value)
end)
buttonsTabPanelScroll:HookScript("OnScrollRangeChanged", function(self, xrange)
	local hsb = self.HScrollBar
	xrange = math.floor(xrange)
	local value = math.min(xrange, hsb:GetValue())
	hsb:SetMinMaxValues(0, xrange)
	hsb:SetValue(value)

	if xrange == 0 then
		hsb.leftBtn:Disable()
		hsb.rightBtn:Disable()
	elseif xrange - value > .005 then
		hsb.rightBtn:Enable()
	else
		hsb.rightBtn:Disable()
	end
end)
buttonsTabPanelScroll:HookScript("OnHorizontalScroll", function(self, offset)
	local hsb = self.HScrollBar
	local min, max = hsb:GetMinMaxValues()
	hsb.leftBtn:SetEnabled(offset ~= 0)
	hsb.rightBtn:SetEnabled(hsb:GetValue() ~= max)
end)
buttonsTabPanelScroll.child = CreateFrame("FRAME")
buttonsTabPanelScroll.child:SetSize(1, 1)
buttonsTabPanelScroll:SetScrollChild(buttonsTabPanelScroll.child)

-- BUTTON PANEL DESCRIPTION
local buttonPanelDescription = buttonsTabPanelScroll.child:CreateFontString("ARTWORK", nil, "GameFontHighlight")
buttonPanelDescription:SetPoint("TOPLEFT", buttonsTabPanelScroll.child, "BOTTOMLEFT", 8, -5)
buttonPanelDescription:SetText(L["BUTTON_PANEL_DESCRIPTION"])
buttonPanelDescription:SetJustifyH("LEFT")

-- BUTTON PANEL
main.buttonPanel = CreateFrame("Frame", nil, buttonsTabPanelScroll.child, "HidingBarAddonPanel")
main.buttonPanel:SetPoint("TOPLEFT", buttonPanelDescription, "BOTTOMLEFT", 0, -5)
main.buttonPanel:SetSize(20, 20)
main.buttonPanel.bg:SetVertexColor(unpack(config.bgColor))

-- IGNORE TAB PANEL
main.ignoreTabPanel = createTabPanel(buttonTabs, L["Ignore list"])

-- RELOAD BUTTON
local reloadBtn = CreateFrame("BUTTON", nil, main, "UIPanelButtonTemplate")
reloadBtn:SetSize(96, 22)
reloadBtn:SetPoint("BOTTOMRIGHT", main.ignoreTabPanel, "TOPRIGHT")
reloadBtn:SetText(RELOADUI)
reloadBtn:SetScript("OnClick", function()
	ReloadUI()
end)

-- ADD IGNORE TEXT
local editBoxIgnore = CreateFrame("EditBox", nil, main.ignoreTabPanel, "HidingBarAddonAddTextBox")
editBoxIgnore:SetPoint("TOPLEFT", main.ignoreTabPanel, 10, -5)
editBoxIgnore:SetScript("OnTextChanged", function(editBox)
	local textExists = editBox:GetText() ~= ""
	main.ignoreBtn:SetEnabled(textExists)
	editBox.clearButton:SetShown(editBox:HasFocus() or textExists)
end)
editBoxIgnore:SetScript("OnEnterPressed", function(editBox)
	local text = editBox:GetText()
	if text ~= "" then
		main:addIgnoreName(text)
		editBox:SetText("")
	end
	EditBox_ClearFocus(editBox)
end)

-- ADD IGNORE BUTTON
main.ignoreBtn = CreateFrame("BUTTON", nil, main.ignoreTabPanel, "UIPanelButtonTemplate")
main.ignoreBtn:SetSize(80, 22)
main.ignoreBtn:SetPoint("LEFT", editBoxIgnore, "RIGHT")
main.ignoreBtn:SetText(ADD)
main.ignoreBtn:Disable()
main.ignoreBtn:SetScript("OnClick", function()
	local text = editBoxIgnore:GetText()
	if text ~= "" then
		main:addIgnoreName(text)
		editBoxIgnore:SetText("")
	end
	EditBox_ClearFocus(editBoxIgnore)
end)

-- IGNORE SCROLL
main.ignoreScroll = CreateFrame("ScrollFrame", nil, main.ignoreTabPanel, "HidingBarAddonHybridScrollTemplate")
main.ignoreScroll.scrollBar.doNotHide = true
main.ignoreScroll:SetSize(300, 200)
main.ignoreScroll:SetPoint("TOPLEFT", editBoxIgnore, "BOTTOMLEFT", -2, -2)
main.ignoreScroll.update = function(scroll)
	local offset = HybridScrollFrame_GetOffset(scroll)
	local numButtons = #config.ignoreMBtn

	for i, btn in ipairs(scroll.buttons) do
		local index = i + offset
		if index <= numButtons then
			btn:SetText(config.ignoreMBtn[index]:gsub("%%([%(%)%.%%%+%-%*%?%[%^%$])", "%1"))
			btn.removeButton:SetScript("OnClick", function()
				main:removeIgnoreName(index)
			end)
			btn:Enable()
		else
			btn:SetText(EMPTY)
			btn:Disable()
		end
	end

	HybridScrollFrame_Update(scroll, scroll.buttonHeight * numButtons, scroll:GetHeight())
end
HybridScrollFrame_CreateButtons(main.ignoreScroll, "HidingBarAddonIgnoreButtonTemplate")
main.ignoreScroll:update()

-- IGNORE DESCRIPTION
local ignoreDescription = main.ignoreTabPanel:CreateFontString("ARTWORK", nil, "GameFontHighlight")
ignoreDescription:SetPoint("TOPLEFT", main.ignoreBtn, "TOPRIGHT", 5, 0)
ignoreDescription:SetPoint("BOTTOMRIGHT", main.ignoreTabPanel, -5, 5)
ignoreDescription:SetJustifyH("LEFT")
ignoreDescription:SetText(L["IGNORE_DESCRIPTION"])

-- INIT
C_Timer.After(.1, function()
	main:initButtons()
	main:initMButtons()
	main:sort(main.mixedButtons)
	main:setButtonSize()
	main:applyLayout()
end)


function main:updateCoords()
	if not self.coordX or not self.coordY then return end

	local x = hidingBar.position or 0
	local y = hidingBar.secondPosition or 0
	local anchor = config.barTypePosition == 2 and config.omb.anchor or config.anchor
	if anchor == "left" or anchor == "right" then x, y = y, x end

	self.coordX:SetNumber(math.floor(x + .5))
	self.coordY:SetNumber(math.floor(y + .5))
end
main:updateCoords()
hidingBar.on(main, "COORDS_UPDATED", "updateCoords")


function main:addIgnoreName(name)
	name = name:gsub("[%(%)%.%%%+%-%*%?%[%^%$]", "%%%1")
	for _, n in ipairs(config.ignoreMBtn) do
		if name == n then return end
	end
	tinsert(config.ignoreMBtn, name)
	sort(config.ignoreMBtn)
	self.ignoreScroll:update()
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end


function main:removeIgnoreName(index)
	local name = config.ignoreMBtn[index]
	StaticPopup_Show(main.addonName.."REMOVE_IGNORE_MBTN", NORMAL_FONT_COLOR_CODE..name:gsub("%%([%(%)%.%%%+%-%*%?%[%^%$])", "%1")..FONT_COLOR_CODE_CLOSE, nil, function()
		for i = 1, #config.ignoreMBtn do
			if name == config.ignoreMBtn[i] then
				tremove(config.ignoreMBtn, i)
				break
			end
		end
		self.ignoreScroll:update()
		StaticPopup_Show(main.addonName.."GET_RELOAD")
	end)
end


function main:hidingBarUpdate()
	hidingBar:enter()
	hidingBar:leave()
end


function main:dragBtn(btn)
	local scale = btn:GetScale()
	local x = btn:GetLeft() - (self.buttonPanel:GetLeft() + offsetX) / scale
	local y = (self.buttonPanel:GetTop() - offsetY) / scale - btn:GetTop()
	if self.orientation then x, y = y, x end
	local buttonSize = config.buttonSize / scale
	local row, column = math.floor(y / buttonSize + .5), math.floor(x / buttonSize + .5) + 1
	if row < btn.minRow then row = btn.minRow
	elseif row > btn.maxRow then row = btn.maxRow end
	if column < 1 then column = 1
	elseif column > btn.maxColumn then column = btn.maxColumn end
	local order = row * config.size + column - btn.orderDelta
	if order < 1 then order = 1
	elseif order > #btn.btnList then order = #btn.btnList end

	local step = order > btn.settings[2] and 1 or -1
	for i = btn.settings[2], order - step, step do
		local button = btn.btnList[i + step]
		btn.btnList[i] = button
		button.settings[2] = i
		self:setPointBtn(button, i + btn.orderDelta, .1)
	end
	btn.btnList[order] = btn
	btn.settings[2] = order
end


function main:dragStart(btn, orderDelta)
	btn.isDrag = true
	btn.btnList = config.mbtnPosition == 2 and self.mixedButtons or btn.defBtnList
	for i = 1, #btn.btnList do
		btn.btnList[i].settings[2] = i
	end
	if not btn.level then btn.level = btn:GetFrameLevel() end
	btn:SetFrameLevel(btn.level + 2)
	btn.orderDelta = orderDelta or 0
	btn.maxColumn = #btn.btnList + btn.orderDelta
	btn.minRow = math.floor(btn.orderDelta / config.size)
	btn.maxRow = math.ceil(btn.maxColumn / config.size) - 1
	if btn.maxColumn > config.size then btn.maxColumn = config.size end
	btn:SetScript("OnUpdate", function(btn) self:dragBtn(btn) end)
	btn:StartMoving()
end


function main:dragStop(btn)
	btn.isDrag = nil
	btn:SetFrameLevel(btn.level)
	btn:SetScript("OnUpdate", nil)
	btn:StopMovingOrSizing()
	self:setPointBtn(btn, btn.settings[2] + btn.orderDelta, .3)
	if config.mbtnPosition == 2 then
		self:sort(btn.defBtnList)
	else
		self:sort(self.mixedButtons)
	end
	hidingBar:sort()
	hidingBar:applyLayout()
	self:hidingBarUpdate()
end


function main:sort(buttons)
	sort(buttons, function(a, b)
		local o1, o2 = a.settings[2], b.settings[2]
		return o1 and not o2
			 or o1 and o2 and o1 < o2
			 or o1 == o2 and a.name < b.name
	end)
end


do
	local buttonsByName = {}

	local function btnClick(self)
		self.settings[1] = self:GetChecked()
		hidingBar:applyLayout()
		main:hidingBarUpdate()
	end

	local function btnDragStart(btn)
		main:dragStart(btn)
	end

	local function btnDragStop(btn)
		main:dragStop(btn)
	end

	function main:createButton(name, button, update)
		if not self.buttonPanel or buttonsByName[name] then return end
		local btn = CreateFrame("CheckButton", nil, self.buttonPanel, "HidingBarAddonConfigButtonTemplate")
		btn.name = button:GetName()
		btn.title = name
		if button.iconTex then
			btn.icon:SetTexture(button.iconTex)
			if button.iconCoords then
				btn.icon:SetTexCoord(unpack(button.iconCoords))
			end
			btn.icon:SetVertexColor(button.iconR or 1, button.iconG or 1, button.iconB or 1)
		end
		btn.color = {btn.icon:GetVertexColor()}
		btn.iconDesaturated = button.iconDesaturated
		btn.defBtnList = self.buttons
		btn:HookScript("OnClick", btnClick)
		btn:SetScript("OnDragStart", btnDragStart)
		btn:SetScript("OnDragStop", btnDragStop)
		btn.settings = config.btnSettings[name]
		btn:SetChecked(btn.settings[1])
		buttonsByName[name] = btn
		tinsert(self.buttons, btn)
		tinsert(self.mixedButtons, btn)
		if update then
			self:sort(self.buttons)
			self:sort(self.mixedButtons)
			self:setButtonSize()
			self:applyLayout()
		end
	end
	hidingBar:on("BUTTON_ADDED", function(_, ...) main:createButton(...) end)
end


do
	local buttonsByName = {}

	local function btnClick(self, button)
		if button == "LeftButton" then
			self.settings[1] = self:GetChecked()
			hidingBar:applyLayout()
			main:hidingBarUpdate()
		elseif button == "RightButton" then
			self:SetChecked(not self:GetChecked())
			StaticPopup_Show(main.addonName.."ADD_IGNORE_MBTN", NORMAL_FONT_COLOR_CODE..self.name..FONT_COLOR_CODE_CLOSE, nil, function()
				main:addIgnoreName(self.name)
			end)
		end
	end

	local function btnDragStart(btn)
		main:dragStart(btn, main.orderMBtnDelta)
	end

	local function btnDragStop(btn)
		main:dragStop(btn)
	end

	function main:createMButton(name, icon, update)
		if not self.buttonPanel or type(name) ~= "string" or buttonsByName[name] then return end
		local btn = CreateFrame("CheckButton", nil, self.buttonPanel, "HidingBarAddonConfigMButtonTemplate")
		btn.name = name
		btn.title = name:gsub("LibDBIcon10_", "")
		btn.icon:SetTexture(icon:GetTexture())
		btn.icon:SetTexCoord(icon:GetTexCoord())
		btn.color = {icon:GetVertexColor()}
		btn.defBtnList = self.mbuttons
		btn:HookScript("OnClick", btnClick)
		btn:SetScript("OnDragStart", btnDragStart)
		btn:SetScript("OnDragStop", btnDragStop)
		btn.settings = config.mbtnSettings[name]
		btn:SetChecked(btn.settings[1])
		buttonsByName[name] = btn
		tinsert(self.mbuttons, btn)
		tinsert(self.mixedButtons, btn)
		if update then
			self:sort(self.mbuttons)
			self:sort(self.mixedButtons)
			self:setButtonSize()
			self:applyLayout()
		end
	end
	hidingBar:on("MBUTTON_ADDED", function(_, ...) main:createMButton(...) end)
end


function main:initButtons()
	for _, button in ipairs(hidingBar.createdButtons) do
		self:createButton(button.name, button)
	end
end


function main:initMButtons(update)
	for _, button in ipairs(hidingBar.minimapButtons) do
		local name = button:GetName()
		if name then
			local icon = button.icon
						 or button.Icon
						 or _G[name.."icon"]
						 or _G[name.."Icon"]
						 or button.__MSQ_Icon
						 or button.GetNormalTexture and button:GetNormalTexture()
						 or button.texture
						 or button.Texture
						 or button.background
						 or button.Background
			if not icon or not icon.GetTexture then
				icon = self.noIcon
			end
			self:createMButton(name, icon, update)
		end
	end
end
hidingBar:on("MBUTTONS_UPDATED", function() main:initButtons(true) end)


function main:setButtonSize()
	for _, button in ipairs(self.buttons) do
		button:SetScale(config.buttonSize / button:GetWidth())
	end
	for _, button in ipairs(self.mbuttons) do
		button:SetScale(config.buttonSize / button:GetWidth())
	end
end


local function setPosAnimated(btn, elapsed)
	btn.timer = btn.timer - elapsed
	if btn.timer <= 0 then
		btn:SetPoint("TOPLEFT", btn.x, btn.y)
		btn:SetScript("OnUpdate", nil)
	else
		local k = btn.timer / btn.delay
		btn:SetPoint("TOPLEFT", btn.x - btn.deltaX * k, btn.y - btn.deltaY * k)
	end
end


function main:setPointBtn(btn, order, delay)
	if btn.isDrag then return end
	local scale = btn:GetScale()
	order = order - 1
	btn.x = (order % config.size * config.buttonSize + offsetX) / scale
	btn.y = (-math.floor(order / config.size) * config.buttonSize - offsetY) / scale
	if self.orientation then btn.x, btn.y = -btn.y, -btn.x end

	if delay and btn:IsVisible() then
		btn.timer = delay
		btn.delay = delay
		btn.deltaX = btn.x - btn:GetLeft() + self.buttonPanel:GetLeft() / scale
		btn.deltaY = btn.y - btn:GetTop() + self.buttonPanel:GetTop() / scale
		btn:ClearAllPoints()
		btn:SetScript("OnUpdate", setPosAnimated)
	else
		btn:ClearAllPoints()
		btn:SetPoint("TOPLEFT", btn.x, btn.y)
	end
end


function main:applyLayout(delay)
	if not self.buttonPanel then return end
	if config.orientation == 0 then
		local anchor = config.barTypePosition == 2 and config.omb.anchor or config.anchor
		self.orientation = anchor == "top" or anchor == "bottom"
	else
		self.orientation = config.orientation == 2
	end

	local columns, rows = config.size
	if config.mbtnPosition == 2 then
		for i, btn in ipairs(self.mixedButtons) do
			self:setPointBtn(btn, i, delay)
		end
		self.orderMBtnDelta = 0
		rows = math.ceil(#self.mixedButtons / columns)
	else
		for i, btn in ipairs(self.buttons) do
			self:setPointBtn(btn, i, delay)
		end
		self.orderMBtnDelta = config.mbtnPosition == 1 and #self.buttons or math.ceil(#self.buttons / columns) * columns
		for i, btn in ipairs(self.mbuttons) do
			self:setPointBtn(btn, i + self.orderMBtnDelta, delay)
		end
		rows = math.ceil((#self.mbuttons + self.orderMBtnDelta) / columns)
	end

	local width = columns * config.buttonSize + offsetX * 2
	local height = rows * config.buttonSize + offsetY * 2
	if self.orientation then width, height = height, width end
	self.buttonPanel:SetSize(width, height)
end