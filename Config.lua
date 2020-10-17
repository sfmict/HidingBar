local addon, L = ...
local config = CreateFrame("FRAME", addon.."ConfigAddon", InterfaceOptionsFramePanelContainer)
config.noIcon = config:CreateTexture()
config.noIcon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
config.noIcon:SetTexCoord(.05, .95, .05, .95)
config.noIcon:Hide()
config.name = addon
config.buttons, config.mbuttons = {}, {}


config.optionsPanelBackdrop = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 14,
	edgeSize = 14,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}


config.editBoxBackdrop = {
	bgFile = "Interface/ChatFrame/ChatFrameBackground",
	edgeFile = "Interface/ChatFrame/ChatFrameBackground",
	tile = true, edgeSize = 1, tileSize = 5,
}


config.colorButtonBackdrop = {
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


config:SetScript("OnShow", function(self)
	self:SetScript("OnShow", nil)

	-- DIALOGS
	self.addonName = ("%s_ADDON_"):format(addon:upper())
	StaticPopupDialogs[self.addonName.."GET_RELOAD"] = {
		text = addon..": "..L["RELOAD_INTERFACE_QUESTION"],
		button1 = YES,
		button2 = NO,
		hideOnEscape = 1,
		whileDead = 1,
		OnAccept = function() ReloadUI() end,
	}
	StaticPopupDialogs[self.addonName.."ADD_IGNORE_MBTN"] = {
		text = addon..": "..L["ADD_IGNORE_MBTN_QUESTION"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hideOnEscape = 1,
		whileDead = 1,
		OnAccept = function(self, cb) self:Hide() cb() end,
	}
	StaticPopupDialogs[self.addonName.."REMOVE_IGNORE_MBTN"] = {
		text = addon..": "..L["REMOVE_IGNORE_MBTN_QUESTION"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hideOnEscape = 1,
		whileDead = 1,
		OnAccept = function(self, cb) self:Hide() cb() end,
	}

	-- ADDON INFO
	local info = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	info:SetPoint("TOPRIGHT", -16, 16)
	info:SetTextColor(.5, .5, .5, 1)
	info:SetJustifyH("RIGHT")
	info:SetText(("%s %s: %s"):format(GetAddOnMetadata(addon, "Version"), L["author"], GetAddOnMetadata(addon, "Author")))

	-- TITLE
	local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetText(L["%s Configuration"]:format(addon))

	-- GENERAL TAB PANEL
	self.generalPanel = CreateFrame("FRAME", nil, self, "HidingBarAddonOptionsPanel")
	self.generalPanel:SetPoint("TOPLEFT", 8, -58)
	self.generalPanel:SetPoint("BOTTOMRIGHT", self, -8, 275)

	self.tabGeneral = CreateFrame("BUTTON", nil, self, "HidingBarAddonTabTemplate")
	self.tabGeneral:SetPoint("BOTTOMLEFT", self.generalPanel, "TOPLEFT", 3, -1)
	self.tabGeneral:SetText(L["General"])
	self.tabGeneral:SetWidth(self.tabGeneral:GetTextWidth() + 48)
	self.tabGeneral:Disable()
	self.tabGeneral:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		self.generalPanel:Show()
		self.buttonSettingsPanel:Hide()
		self.tabGeneral:Disable()
		self.tabButtonSettings:Enable()
	end)

	-- DESCRIPTION
	local hexColor = toHex(self.config.lineColor)
	local description = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	description:SetPoint("TOPLEFT", 8, -10)
	description:SetJustifyH("LEFT")
	description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))

	-- LINE COLOR
	local lineColor = CreateFrame("BUTTON", nil, self.generalPanel, "HidingBarAddonColorButton")
	lineColor:SetPoint("TOPRIGHT", -8, -8)
	lineColor.color:SetColorTexture(unpack(self.config.lineColor))
	local lineColorText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	lineColorText:SetPoint("RIGHT", lineColor, "LEFT", -3, 0)
	lineColorText:SetJustifyH("RIGHT")
	lineColorText:SetText(L["Line"])

	lineColor.swatchFunc = function()
		self.config.lineColor = {ColorPickerFrame:GetColorRGB()}
		self.hidingBar.drag.bg:SetColorTexture(ColorPickerFrame:GetColorRGB())
		local hexColor = toHex(self.config.lineColor)
		description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))
		self.fade.Text:SetText(L["Fade out line"]:format(hexColor))
		self.lineWidth.text:SetText(L["Line width"]:format(hexColor))
		lineColor.color:SetColorTexture(ColorPickerFrame:GetColorRGB())
		self.hidingBar:enter()
		self.hidingBar:leave()
	end
	lineColor.cancelFunc = function(color)
		self.config.lineColor = {color.r, color.g, color.b}
		self.hidingBar.drag.bg:SetColorTexture(color.r, color.g, color.b)
		local hexColor = toHex(self.config.lineColor)
		description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))
		self.fade.Text:SetText(L["Fade out line"]:format(hexColor))
		self.lineWidth.text:SetText(L["Line width"]:format(hexColor))
		lineColor.color:SetColorTexture(color.r, color.g, color.b)
		self.hidingBar:enter()
		self.hidingBar:leave()
	end
	lineColor:SetScript("OnClick", function(btn)
		if ColorPickerFrame:IsShown() and ColorPickerFrame.cancelFunc then
			ColorPickerFrame.cancelFunc(ColorPickerFrame.previousValues)
			HideUIPanel(ColorPickerFrame)
		end
		btn.r, btn.g, btn.b = unpack(self.config.lineColor)
		OpenColorPicker(btn)
	end)

	-- BACKGROUND COLOR
	local bgColor = CreateFrame("BUTTON", nil, self.generalPanel, "HidingBarAddonColorButton")
	bgColor:SetPoint("TOPRIGHT", lineColor, "BOTTOMRIGHT", 0, -3)
	bgColor.color:SetColorTexture(unpack(self.config.bgColor))
	local bgColorText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	bgColorText:SetPoint("RIGHT", bgColor, "LEFT", -3, 0)
	bgColorText:SetJustifyH("RIGHT")
	bgColorText:SetText(L["Background"])

	bgColor.hasOpacity = true
	bgColor.swatchFunc = function()
		self.config.bgColor[1], self.config.bgColor[2], self.config.bgColor[3] = ColorPickerFrame:GetColorRGB()
		self.hidingBar.bg:SetVertexColor(unpack(self.config.bgColor))
		self.buttonPanel.bg:SetVertexColor(unpack(self.config.bgColor))
		bgColor.color:SetColorTexture(unpack(self.config.bgColor))
		self.hidingBar:enter()
		self.hidingBar:leave()
	end
	bgColor.opacityFunc = function()
		self.config.bgColor[4] = OpacitySliderFrame:GetValue()
		self.hidingBar.bg:SetVertexColor(unpack(self.config.bgColor))
		self.buttonPanel.bg:SetVertexColor(unpack(self.config.bgColor))
		bgColor.color:SetColorTexture(unpack(self.config.bgColor))
		self.hidingBar:enter()
		self.hidingBar:leave()
	end
	bgColor.cancelFunc = function(color)
		self.config.bgColor[1] = color.r
		self.config.bgColor[2] = color.g
		self.config.bgColor[3] = color.b
		self.config.bgColor[4] = color.opacity
		self.hidingBar.bg:SetVertexColor(unpack(self.config.bgColor))
		self.buttonPanel.bg:SetVertexColor(unpack(self.config.bgColor))
		bgColor.color:SetColorTexture(unpack(self.config.bgColor))
		self.hidingBar:enter()
		self.hidingBar:leave()
	end
	bgColor:SetScript("OnClick", function(btn)
		if ColorPickerFrame:IsShown() and ColorPickerFrame.cancelFunc then
			ColorPickerFrame.cancelFunc(ColorPickerFrame.previousValues)
			HideUIPanel(ColorPickerFrame)
		end
		btn.r, btn.g, btn.b, btn.opacity = unpack(self.config.bgColor)
		OpenColorPicker(btn)
	end)

		-- ORIENTATION TEXT
	local orientationText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	orientationText:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -23)
	orientationText:SetText(L["Orientation"])

	-- ORIENTATION COMBOBOX
	local orientationCombobox = CreateFrame("FRAME", "HidingBarAddonOrientation", self.generalPanel, "UIDropDownMenuTemplate")
	orientationCombobox:SetPoint("LEFT", orientationText, "RIGHT", -12, 0)
	UIDropDownMenu_SetWidth(orientationCombobox, 100)

	local function orientationChange(btn)
		UIDropDownMenu_SetSelectedValue(orientationCombobox, btn.value)
		self.config.orientation = btn.value
		self:hidingBarUpdate()
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
	UIDropDownMenu_SetSelectedValue(orientationCombobox, self.config.orientation)

	-- FRAME STARTA TEXT
	local fsText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	fsText:SetPoint("LEFT", orientationCombobox, "RIGHT", -5, 0)
	fsText:SetText(L["Panel level"])

	-- FRAME STRATA COMBOBOX
	local fsCombobox =  CreateFrame("FRAME", "HidingBarAddonFrameStrata", self.generalPanel, "UIDropDownMenuTemplate")
	fsCombobox:SetPoint("LEFT", fsText, "RIGHT", -12, 0)
	UIDropDownMenu_SetWidth(fsCombobox, 100)

	local function fsChange(btn)
		UIDropDownMenu_SetSelectedValue(fsCombobox, btn.value)
		self.config.frameStrata = btn.value
		self.hidingBar:setFrameStrata()
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
	UIDropDownMenu_SetSelectedValue(fsCombobox, self.config.frameStrata)

	-- LOCK
	self.lock = CreateFrame("CheckButton", nil, self.generalPanel, "HidingBarAddonCheckButtonTemplate")
	self.lock:SetPoint("TOPLEFT", orientationText, "BOTTOMLEFT", 0, -7)
	self.lock.Text:SetText(L["Lock the bar's location"])
	self.lock:SetChecked(self.config.lock)
	self.lock:SetScript("OnClick", function(btn)
		local checked = btn:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		self.config.lock = checked
		self.hidingBar:refreshShown()
	end)

	-- FADE
	self.fade = CreateFrame("CheckButton", nil, self.generalPanel, "HidingBarAddonCheckButtonTemplate")
	self.fade:SetPoint("TOPLEFT", self.lock, "BOTTOMLEFT", 0, 0)
	self.fade.Text:SetText(L["Fade out line"]:format(hexColor))
	self.fade:SetChecked(self.config.fade)
	self.fade:SetScript("OnClick", function(btn)
		local checked = btn:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		self.config.fade = checked
		self.fadeOpacity:SetEnabled(checked)
		if checked then
			UIFrameFadeOut(self.hidingBar.drag, 1.5, self.hidingBar.drag:GetAlpha(), self.config.fadeOpacity)
		else
			UIFrameFadeRemoveFrame(self.hidingBar.drag)
			self.hidingBar.drag:SetAlpha(1)
		end
		self.hidingBar:applyLayout()
	end)

	-- FADE OPACITY
	self.fadeOpacity = CreateFrame("SLIDER", nil, self.generalPanel, "HidingBarAddonSliderTemplate")
	self.fadeOpacity:SetPoint("LEFT", self.fade.Text, "RIGHT", 20, 0)
	self.fadeOpacity:SetPoint("RIGHT", -30, 0)
	self.fadeOpacity:SetMinMaxValues(0, .9)
	self.fadeOpacity.text:SetText(L["Opacity"])
	self.fadeOpacity:SetValue(self.config.fadeOpacity)
	self.fadeOpacity.label:SetText(self.config.fadeOpacity)
	self.fadeOpacity:SetEnabled(self.config.fade)
	self.fadeOpacity:SetScript("OnValueChanged", function(slider, value)
		value = math.floor(value * 10 + .5) / 10
		config.config.fadeOpacity = value
		slider.label:SetText(value)
		slider:SetValue(value)
		UIFrameFadeRemoveFrame(self.hidingBar.drag)
		self.hidingBar.drag:SetAlpha(value)
	end)

	-- LINE WIDTH
	self.lineWidth = CreateFrame("SLIDER", nil, self.generalPanel, "HidingBarAddonSliderTemplate")
	self.lineWidth:SetPoint("TOPLEFT", self.fade, "BOTTOMLEFT", 0, -15)
	self.lineWidth:SetPoint("RIGHT", -30, 0)
	self.lineWidth:SetMinMaxValues(4, 10)
	self.lineWidth.text:SetText(L["Line width"]:format(hexColor))
	self.lineWidth:SetValue(self.config.lineWidth)
	self.lineWidth.label:SetText(self.config.lineWidth)
	self.lineWidth:SetScript("OnValueChanged", function(slider, value)
		value = math.floor(value * 10 + .5) / 10
		config.config.lineWidth = value
		slider.label:SetText(value)
		slider:SetValue(value)
		self.hidingBar.drag:SetSize(value, value)
	end)

	-- SHOW HANDLER TEXT
	local showHandlerText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	showHandlerText:SetPoint("TOPLEFT", self.lineWidth, "BOTTOMLEFT", 0, -18)
	showHandlerText:SetText(L["Show on"])

	-- SHOW HANDLER
	local showHandlerCombobox = CreateFrame("FRAME", "HidingBarAddonShowHandler", self.generalPanel, "UIDropDownMenuTemplate")
	showHandlerCombobox:SetPoint("LEFT", showHandlerText, "RIGHT", -12, 0)
	UIDropDownMenu_SetWidth(showHandlerCombobox, 100)

	local function updateShowHandler(btn)
		UIDropDownMenu_SetSelectedValue(showHandlerCombobox, btn.value)
		self.config.showHandler = btn.value
		self.hidingBar.drag:setShowHandler()
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
	UIDropDownMenu_SetSelectedValue(showHandlerCombobox, self.config.showHandler)

	-- DELAY TO SHOW
	local delayToShowText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	delayToShowText:SetPoint("LEFT", showHandlerCombobox, "RIGHT", -5, 0)
	delayToShowText:SetText(L["Delay to show"])

	local delayToShowEditBox = CreateFrame("EditBox", nil, self.generalPanel, "HidingBarAddonDecimalTextBox")
	delayToShowEditBox:SetPoint("LEFT", delayToShowText, "RIGHT", 2, 0)
	delayToShowEditBox:SetNumber(self.config.showDelay)
	delayToShowEditBox:SetCursorPosition(0)
	delayToShowEditBox:SetScript("OnTextChanged", function(editBox, userInput)
		if userInput then
			local int, dec = editBox:GetText():gsub(",", "."):match("(%d*)(%.?%d*)")
			if int == "" and dec ~= "" then int = "0" end
			local decimalText = int..dec
			editBox:SetNumber(decimalText)
			self.config.showDelay = tonumber(decimalText) or 0
		end
	end)
	delayToShowEditBox:SetScript("OnEditFocusLost", function(editBox)
		editBox:SetNumber(self.config.showDelay)
		editBox:HighlightText(0, 0)
	end)

	-- DELAY TO HIDE
	local delayToHideText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	delayToHideText:SetPoint("LEFT", delayToShowEditBox, "RIGHT", 10, 0)
	delayToHideText:SetText(L["Delay to hide"])

	local delayToHideEditBox = CreateFrame("EditBox", nil, self.generalPanel, "HidingBarAddonDecimalTextBox")
	delayToHideEditBox:SetPoint("LEFT", delayToHideText, "RIGHT", 2, 0)
	delayToHideEditBox:SetNumber(self.config.hideDelay)
	delayToHideEditBox:SetCursorPosition(0)
	delayToHideEditBox:SetScript("OnTextChanged", function(editBox, userInput)
		if userInput then
			local int, dec = editBox:GetText():gsub(",", "."):match("(%d*)(%.?%d*)")
			if int == "" and dec ~= "" then int = "0" end
			local decimalText = int..dec
			editBox:SetNumber(decimalText)
			self.config.hideDelay = tonumber(decimalText) or 0
		end
	end)
	delayToHideEditBox:SetScript("OnEditFocusLost", function(editBox)
		editBox:SetNumber(self.config.hideDelay)
		editBox:HighlightText(0, 0)
	end)

	-- MINIMAP TAB PANEL
	self.buttonSettingsPanel = CreateFrame("FRAME", nil, self, "HidingBarAddonOptionsPanel")
	self.buttonSettingsPanel:SetPoint("TOPLEFT", 8, -58)
	self.buttonSettingsPanel:SetPoint("BOTTOMRIGHT", self, -8, 275)
	self.buttonSettingsPanel:Hide()

	self.tabButtonSettings = CreateFrame("BUTTON", nil, self, "HidingBarAddonTabTemplate")
	self.tabButtonSettings:SetPoint("LEFT", self.tabGeneral, "RIGHT", -16, 0)
	self.tabButtonSettings:SetText(L["Button settings"])
	self.tabButtonSettings:SetWidth(self.tabButtonSettings:GetTextWidth() + 48)
	self.tabButtonSettings:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		self.generalPanel:Hide()
		self.buttonSettingsPanel:Show()
		self.tabGeneral:Enable()
		self.tabButtonSettings:Disable()
	end)

	-- GRAB DEFAULT BUTTONS
	self.grabDefault = CreateFrame("CheckButton", nil, self.buttonSettingsPanel, "HidingBarAddonCheckButtonTemplate")
	self.grabDefault:SetPoint("TOPLEFT", 8, -8)
	self.grabDefault.Text:SetText(L["Grab default buttons on minimap"])
	self.grabDefault:SetChecked(self.config.grabDefMinimap)
	self.grabDefault:SetScript("OnClick", function(btn)
		self.config.grabDefMinimap = btn:GetChecked()
		StaticPopup_Show(self.addonName.."GET_RELOAD")
	end)

	-- GRAB ADDONS BUTTONS
	self.grab = CreateFrame("CheckButton", nil, self.buttonSettingsPanel, "HidingBarAddonCheckButtonTemplate")
	self.grab:SetPoint("TOPLEFT", self.grabDefault, "BOTTOMLEFT", 0, 0)
	self.grab.Text:SetText(L["Grab addon buttons on minimap"])
	self.grab:SetChecked(self.config.grabMinimap)
	self.grab:SetScript("OnClick", function(btn)
		local checked = btn:GetChecked()
		self.config.grabMinimap = checked
		self.grabAfter:SetEnabled(checked)
		self.grabWithoutName:SetEnabled(checked)
		StaticPopup_Show(self.addonName.."GET_RELOAD")
	end)

	-- GRAB AFTER N SECOND
	self.grabAfter = CreateFrame("CheckButton", nil, self.buttonSettingsPanel, "HidingBarAddonCheckButtonTemplate")
	self.grabAfter:SetPoint("TOPLEFT", self.grab, "BOTTOMLEFT", 20, 0)
	self.grabAfter.Text:SetText(L["Try to grab after"])
	self.grabAfter:SetHitRectInsets(0, -self.grabAfter.Text:GetWidth(), 0, 0)
	self.grabAfter:SetChecked(self.config.grabMinimapAfter)
	self.grabAfter:SetScript("OnClick", function(btn)
		self.config.grabMinimapAfter = btn:GetChecked()
		StaticPopup_Show(self.addonName.."GET_RELOAD")
	end)

	self.afterNumber = CreateFrame("EditBox", nil, self.buttonSettingsPanel, "HidingBarAddonNumberTextBox")
	self.afterNumber:SetPoint("LEFT", self.grabAfter.Text, "RIGHT", 3, 0)
	self.afterNumber:SetText(self.config.grabMinimapAfterN)
	self.afterNumber:SetScript("OnTextChanged", function(editBox, userInput)
		if userInput then
			local n = tonumber(editBox:GetText()) or 1
			if n < 1 then n = 1 end
			editBox:SetText(n)
			self.config.grabMinimapAfterN = n
			editBox:HighlightText()
		end
	end)

	self.grabAfterTextSec = self.buttonSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	self.grabAfterTextSec:SetPoint("LEFT", self.afterNumber, "RIGHT", 3, 0)
	self.grabAfterTextSec:SetText(L["sec."])

	self.grabAfter:HookScript("OnEnable", function(btn)
		self.afterNumber:Enable()
		self.grabAfterTextSec:SetTextColor(btn.Text:GetTextColor())
	end)
	self.grabAfter:HookScript("OnDisable", function(btn)
		self.afterNumber:Disable()
		self.grabAfterTextSec:SetTextColor(btn.Text:GetTextColor())
	end)
	self.grabAfter:SetEnabled(self.config.grabMinimap)

	-- GRAB WITHOUT NAME
	self.grabWithoutName = CreateFrame("CheckButton", nil, self.buttonSettingsPanel, "HidingBarAddonCheckButtonTemplate")
	self.grabWithoutName:SetPoint("TOPLEFT", self.grabAfter, "BOTTOMLEFT", 0, 0)
	self.grabWithoutName.Text:SetText(L["Grab buttons without a name"])
	self.grabWithoutName:SetEnabled(self.config.grabMinimap)
	self.grabWithoutName:SetChecked(self.config.grabMinimapWithoutName)
	self.grabWithoutName:SetScript("OnClick", function(btn)
		self.config.grabMinimapWithoutName = btn:GetChecked()
		StaticPopup_Show(self.addonName.."GET_RELOAD")
	end)

	-- SLIDER NUMBER BUTTONS IN ROW
	local buttonNumber = CreateFrame("SLIDER", nil, self.buttonSettingsPanel, "HidingBarAddonSliderTemplate")
	buttonNumber:SetPoint("TOPLEFT", self.grabWithoutName, "BOTTOMLEFT", -20, -20)
	buttonNumber:SetPoint("RIGHT", -30, 0)
	buttonNumber:SetMinMaxValues(1, 30)
	buttonNumber.text:SetText(L["Number of buttons"])
	buttonNumber:SetValue(self.config.size)
	buttonNumber.label:SetText(self.config.size)
	buttonNumber:SetScript("OnValueChanged", function(slider, value)
		value = math.floor(value + .5)
		slider:SetValue(value)
		if self.config.size ~= value then
			self.config.size = value
			slider.label:SetText(value)
			self:applyLayout()
			self:hidingBarUpdate()
		end
	end)

	-- SLIDER BUTTONS SIZE
	local buttonSize = CreateFrame("SLIDER", nil, self.buttonSettingsPanel, "HidingBarAddonSliderTemplate")
	buttonSize:SetPoint("TOPLEFT", buttonNumber, "BOTTOMLEFT", 0, -15)
	buttonSize:SetPoint("RIGHT", -30, 0)
	buttonSize:SetPoint("RIGHT", -30, 0)
	buttonSize:SetMinMaxValues(16, 64)
	buttonSize.text:SetText(L["Button Size"])
	buttonSize:SetValue(self.config.buttonSize)
	buttonSize.label:SetText(self.config.buttonSize)
	buttonSize:SetScript("OnValueChanged", function(slider, value)
		value = math.floor(value + .5)
		slider:SetValue(value)
		if self.config.buttonSize ~= value then
			self.config.buttonSize = value
			slider.label:SetText(value)
			self:setButtonSize()
			self:applyLayout()
			self.hidingBar:setButtonSize()
			self:hidingBarUpdate()
		end
	end)

	-- BUTTONS TAB PANEL
	self.buttonsTabPanel = CreateFrame("FRAME", nil, self, "HidingBarAddonOptionsPanel")
	self.buttonsTabPanel:SetPoint("TOPLEFT", self.generalPanel, "BOTTOMLEFT", 0, -25)
	self.buttonsTabPanel:SetPoint("BOTTOMRIGHT", self, -8, 8)

	local buttonsTabPanelScroll = CreateFrame("ScrollFrame", nil, self.buttonsTabPanel, "UIPanelScrollFrameTemplate")
	buttonsTabPanelScroll:SetPoint("TOPLEFT", self.buttonsTabPanel, 4, -6)
	buttonsTabPanelScroll:SetPoint("BOTTOMRIGHT", self.buttonsTabPanel, -26, 5)
	buttonsTabPanelScroll.ScrollBar.bg = buttonsTabPanelScroll.ScrollBar:CreateTexture(nil, "BACKGROUND")
	buttonsTabPanelScroll.ScrollBar.bg:SetAllPoints()
	buttonsTabPanelScroll.ScrollBar.bg:SetTexture("interface/buttons/white8x8")
	buttonsTabPanelScroll.ScrollBar.bg:SetVertexColor(0, 0, 0, .2)
	buttonsTabPanelScroll.child = CreateFrame("FRAME")
	buttonsTabPanelScroll.child:SetSize(1, 1)
	buttonsTabPanelScroll:SetScrollChild(buttonsTabPanelScroll.child)

	self.tabButtons = CreateFrame("BUTTON", nil, self, "HidingBarAddonTabTemplate")
	self.tabButtons:SetPoint("BOTTOMLEFT", self.buttonsTabPanel, "TOPLEFT", 3, -1)
	self.tabButtons:SetText(L["Buttons"])
	self.tabButtons:SetWidth(self.tabButtons:GetTextWidth() + 48)
	self.tabButtons:Disable()
	self.tabButtons:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		self.buttonsTabPanel:Show()
		self.ignoreTabPanel:Hide()
		self.tabButtons:Disable()
		self.tabIgnore:Enable()
	end)

	-- BUTTON PANEL DESCRIPTION
	local buttonPanelDescription = buttonsTabPanelScroll.child:CreateFontString("ARTWORK", nil, "GameFontHighlight")
	buttonPanelDescription:SetPoint("TOPLEFT", buttonsTabPanelScroll.child, "BOTTOMLEFT", 8, -5)
	buttonPanelDescription:SetText(L["BUTTON_PANEL_DESCRIPTION"])
	buttonPanelDescription:SetJustifyH("LEFT")

	-- BUTTON PANEL
	self.buttonPanel = CreateFrame("Frame", nil, buttonsTabPanelScroll.child, "HidingBarAddonPanel")
	self.buttonPanel:SetPoint("TOPLEFT", buttonPanelDescription, "BOTTOMLEFT", 0, -5)
	self.buttonPanel:SetSize(20, 20)
	self.buttonPanel.bg:SetVertexColor(unpack(self.config.bgColor))

	-- IGNORE TAB PANEL
	self.ignoreTabPanel = CreateFrame("FRAME", nil, self, "HidingBarAddonOptionsPanel")
	self.ignoreTabPanel:SetPoint("TOPLEFT", self.generalPanel, "BOTTOMLEFT", 0, -25)
	self.ignoreTabPanel:SetPoint("BOTTOMRIGHT", self, -8, 8)
	self.ignoreTabPanel:Hide()

	self.tabIgnore = CreateFrame("BUTTON", nil, self, "HidingBarAddonTabTemplate")
	self.tabIgnore:SetPoint("LEFT", self.tabButtons, "RIGHT", -16, 0)
	self.tabIgnore:SetText(L["Ignore list"])
	self.tabIgnore:SetWidth(self.tabIgnore:GetTextWidth() + 48)
	self.tabIgnore:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		self.buttonsTabPanel:Hide()
		self.ignoreTabPanel:Show()
		self.tabButtons:Enable()
		self.tabIgnore:Disable()
	end)

	-- RELOAD BUTTON
	local reloadBtn = CreateFrame("BUTTON", nil, self, "UIPanelButtonTemplate")
	reloadBtn:SetSize(96, 22)
	reloadBtn:SetPoint("BOTTOMRIGHT", self.ignoreTabPanel, "TOPRIGHT")
	reloadBtn:SetText(RELOADUI)
	reloadBtn:SetScript("OnClick", function()
		ReloadUI()
	end)

	-- ADD IGNORE TEXT
	local editBoxIgnore = CreateFrame("EditBox", nil, self.ignoreTabPanel, "HidingBarAddonAddTextBox")
	editBoxIgnore:SetPoint("TOPLEFT", self.ignoreTabPanel, 10, -5)
	editBoxIgnore:SetScript("OnTextChanged", function(editBox)
		local textExists = editBox:GetText() ~= ""
		self.ignoreBtn:SetEnabled(textExists)
		editBox.clearButton:SetShown(editBox:HasFocus() or textExists)
	end)
	editBoxIgnore:SetScript("OnEnterPressed", function(editBox)
		local text = editBox:GetText()
		if text ~= "" then
			self:addIgnoreName(text)
			editBox:SetText("")
		end
		EditBox_ClearFocus(editBox)
	end)

	-- ADD IGNORE BUTTON
	self.ignoreBtn = CreateFrame("BUTTON", nil, self.ignoreTabPanel, "UIPanelButtonTemplate")
	self.ignoreBtn:SetSize(80, 22)
	self.ignoreBtn:SetPoint("LEFT", editBoxIgnore, "RIGHT")
	self.ignoreBtn:SetText(ADD)
	self.ignoreBtn:Disable()
	self.ignoreBtn:SetScript("OnClick", function()
		local text = editBoxIgnore:GetText()
		if text ~= "" then
			self:addIgnoreName(text)
			editBoxIgnore:SetText("")
		end
		EditBox_ClearFocus(editBoxIgnore)
	end)

	-- IGNORE SCROLL
	self.ignoreScroll = CreateFrame("ScrollFrame", nil, self.ignoreTabPanel, "HidingBarAddonHybridScrollTemplate")
	self.ignoreScroll.scrollBar.doNotHide = true
	self.ignoreScroll:SetSize(300, 200)
	self.ignoreScroll:SetPoint("TOPLEFT", editBoxIgnore, "BOTTOMLEFT", -2, -2)
	self.ignoreScroll.update = function(scroll)
		local offset = HybridScrollFrame_GetOffset(scroll)
		local numButtons = #self.config.ignoreMBtn

		for i, btn in ipairs(scroll.buttons) do
			local index = i + offset
			if index <= numButtons then
				btn:SetText(self.config.ignoreMBtn[index]:gsub("%%([%(%)%.%%%+%-%*%?%[%^%$])", "%1"))
				btn.removeButton:SetScript("OnClick", function()
					self:removeIgnoreName(index)
				end)
				btn:Enable()
			else
				btn:SetText(EMPTY)
				btn:Disable()
			end
		end

		HybridScrollFrame_Update(scroll, scroll.buttonHeight * numButtons, scroll:GetHeight())
	end
	HybridScrollFrame_CreateButtons(self.ignoreScroll, "HidingBarAddonIgnoreButtonTemplate")
	self.ignoreScroll:update()

	-- IGNORE DESCRIPTION
	local ignoreDescription = self.ignoreTabPanel:CreateFontString("ARTWORK", nil, "GameFontHighlight")
	ignoreDescription:SetPoint("TOPLEFT", self.ignoreBtn, "TOPRIGHT", 5, 0)
	ignoreDescription:SetPoint("BOTTOMRIGHT", self.ignoreTabPanel, -5, 5)
	ignoreDescription:SetJustifyH("LEFT")
	ignoreDescription:SetText(L["IGNORE_DESCRIPTION"])

	-- INIT
	C_Timer.After(.1, function()
		self:initButtons()
		self:initMButtons()
		self:setButtonSize()
		self:applyLayout()
	end)
end)


function config:addIgnoreName(name)
	name = name:gsub("[%(%)%.%%%+%-%*%?%[%^%$]", "%%%1")
	for _, n in ipairs(self.config.ignoreMBtn) do
		if name == n then return end
	end
	tinsert(self.config.ignoreMBtn, name)
	sort(self.config.ignoreMBtn)
	self.ignoreScroll:update()
end


function config:removeIgnoreName(index)
	local name = self.config.ignoreMBtn[index]
	StaticPopup_Show(self.addonName.."REMOVE_IGNORE_MBTN", NORMAL_FONT_COLOR_CODE..name:gsub("%%([%(%)%.%%%+%-%*%?%[%^%$])", "%1")..FONT_COLOR_CODE_CLOSE, nil, function()
		for i = 1, #self.config.ignoreMBtn do
			if name == self.config.ignoreMBtn[i] then
				tremove(self.config.ignoreMBtn, i)
				break
			end
		end
		self.ignoreScroll:update()
		StaticPopup_Show(self.addonName.."GET_RELOAD")
	end)
end


function config:hidingBarUpdate()
	self.hidingBar:enter()
	self.hidingBar:applyLayout()
	self.hidingBar:leave()
end


function config:dragBtn(btn)
	local scale = btn:GetScale()
	local x = btn:GetLeft() - (self.buttonPanel:GetLeft() + 4) / scale
	local y = (self.buttonPanel:GetTop() - 4 - btn.offset) / scale - btn:GetTop()
	local buttonSize = self.config.buttonSize / scale
	local row, column = math.floor(y / buttonSize + .5), math.floor(x / buttonSize + .5) + 1
	if row < 0 then row = 0 end
	if row > btn.maxRow then row = btn.maxRow end
	if column < 1 then column = 1 end
	if column > btn.maxColumn then column = btn.maxColumn end
	local order = row * self.size + column
	if order > #btn.btnList then order = #btn.btnList end

	local step = order > btn.settings[2] and 1 or -1
	for i = btn.settings[2], order - step, step do
		local button = btn.btnList[i + step]
		btn.btnList[i] = button
		button.settings[2] = i
		self:setPointBtn(button, 4, 4 + btn.offset, i, .1)
	end
	btn.btnList[order] = btn
	btn.settings[2] = order
end


function config:dragStart(btn, offset)
	btn.isDrag = true
	for i = 1, #btn.btnList do
		btn.btnList[i].settings[2] = i
	end
	if not btn.level then btn.level = btn:GetFrameLevel() end
	btn:SetFrameLevel(btn.level + 2)
	btn.offset = offset or 0
	btn.maxColumn = #btn.btnList
	btn.maxRow = math.floor((btn.maxColumn - 1) / self.size)
	if btn.maxColumn > self.size then btn.maxColumn = self.size end
	btn:SetScript("OnUpdate", function(btn) self:dragBtn(btn) end)
	btn:StartMoving()
end


function config:dragStop(btn)
	btn.isDrag = nil
	btn:SetFrameLevel(btn.level)
	btn:SetScript("OnUpdate", nil)
	btn:StopMovingOrSizing()
	self:setPointBtn(btn, 4, 4 + btn.offset, btn.settings[2], .3)
	self.hidingBar:sort()
	self:hidingBarUpdate()
end


function config:sort(buttons)
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
		config:hidingBarUpdate()
	end

	function config:createButton(name, button, update)
		if not self.buttonPanel or buttonsByName[name] then return end
		local btn = CreateFrame("CheckButton", nil, self.buttonPanel, "HidingBarAddonConfigButtonTemplate")
		btn.name = name
		if button.iconTex then
			btn.icon:SetTexture(button.iconTex)
			if button.iconCoords then
				btn.icon:SetTexCoord(unpack(button.iconCoords))
			end
			btn.icon:SetVertexColor(button.iconR or 1, button.iconG or 1, button.iconB or 1)
		end
		btn.color = {btn.icon:GetVertexColor()}
		btn.iconDesaturated = button.iconDesaturated
		btn.btnList = self.buttons
		btn:HookScript("OnClick", btnClick)
		btn:SetScript("OnDragStart", function(btn) self:dragStart(btn) end)
		btn:SetScript("OnDragStop", function(btn) self:dragStop(btn) end)
		btn.settings = self.config.btnSettings[name]
		btn:SetChecked(btn.settings[1])
		buttonsByName[name] = btn
		tinsert(self.buttons, btn)
		if update then
			self:sort(self.buttons)
			self:applyLayout()
		end
	end
end


do
	local buttonsByName = {}

	local function btnClick(self, button)
		if button == "LeftButton" then
			self.settings[1] = self:GetChecked()
			config:hidingBarUpdate()
		elseif button == "RightButton" then
			self:SetChecked(not self:GetChecked())
			StaticPopup_Show(config.addonName.."ADD_IGNORE_MBTN", NORMAL_FONT_COLOR_CODE..self.name..FONT_COLOR_CODE_CLOSE, nil, function()
				config:addIgnoreName(self.name)
				StaticPopup_Show(config.addonName.."GET_RELOAD")
			end)
		end
	end

	function config:createMButton(name, icon)
		if type(name) ~= "string" or buttonsByName[name] then return end
		local btn = CreateFrame("CheckButton", nil, self.buttonPanel, "HidingBarAddonConfigMButtonTemplate")
		btn.name = name
		btn.title = name:gsub("LibDBIcon10_", "")
		btn.icon:SetTexture(icon:GetTexture())
		btn.icon:SetTexCoord(icon:GetTexCoord())
		btn.color = {icon:GetVertexColor()}
		btn.btnList = self.mbuttons
		btn:HookScript("OnClick", btnClick)
		btn:SetScript("OnDragStart", function(btn) self:dragStart(btn, math.ceil(#self.buttons / self.size) * self.config.buttonSize) end)
		btn:SetScript("OnDragStop", function(btn) self:dragStop(btn) end)
		btn.settings = self.config.mbtnSettings[name]
		btn:SetChecked(btn.settings[1])
		buttonsByName[name] = btn
		tinsert(self.mbuttons, btn)
	end
end


function config:initButtons()
	for _, button in ipairs(self.hidingBar.createdButtons) do
		self:createButton(button.name, button)
	end
end


function config:initMButtons()
	for _, button in ipairs(self.hidingBar.minimapButtons) do
		local name = button:GetName()
		if name then
			local icon = button.icon
						 or button.Icon
						 or _G[name.."icon"]
						 or _G[name.."Icon"]
						 or button.texture
						 or button.Texture
						 or button.background
						 or button.Background
			if not icon or not icon.GetTexture then
				icon = self.noIcon
			end
			self:createMButton(name, icon)
		end
	end
end


function config:setButtonSize()
	for _, button in ipairs(self.buttons) do
		button:SetScale(self.config.buttonSize / button:GetWidth())
	end
	for _, button in ipairs(self.mbuttons) do
		button:SetScale(self.config.buttonSize / button:GetWidth())
	end
end


local function setPosAnimated(btn, elapsed)
	local scale = btn:GetScale()
	btn.timer = btn.timer - elapsed
	if btn.timer <= 0 then
		btn:SetPoint("TOPLEFT", btn.x, btn.y)
		btn:SetScript("OnUpdate", nil)
	else
		local k = btn.timer / btn.delay
		btn:SetPoint("TOPLEFT", btn.x - btn.deltaX * k, btn.y - btn.deltaY * k)
	end
end


function config:setPointBtn(btn, offsetX, offsetY, order, delay)
	if btn.isDrag then return end
	local scale = btn:GetScale()
	order = order - 1
	btn.x = (order % self.size * self.config.buttonSize + offsetX) / scale
	btn.y = (-math.floor(order / self.size) * self.config.buttonSize - offsetY) / scale

	if delay then
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


function config:applyLayout()
	local maxColumns = math.floor(560 / self.config.buttonSize)
	self.size = self.config.size
	if self.size > maxColumns then self.size = maxColumns end

	for i, btn in ipairs(self.buttons) do
		self:setPointBtn(btn, 4, 4, i)
	end
	local rows = math.ceil(#self.buttons / self.size)
	local offsetY = rows * self.config.buttonSize + 4
	for i, btn in ipairs(self.mbuttons) do
		self:setPointBtn(btn, 4, offsetY, i)
	end

	rows = rows + math.ceil(#self.mbuttons / self.size)
	self.buttonPanel:SetSize(self.size * self.config.buttonSize + 8, rows * self.config.buttonSize + 8)
end


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