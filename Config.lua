local addon, L = ...
local config = CreateFrame("FRAME", addon.."ConfigAddon", InterfaceOptionsFramePanelContainer)
config.noIcon = config:CreateTexture()
config.noIcon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
config.noIcon:SetTexCoord(.05, .95, .05, .95)
config.noIcon:Hide()
config.name = addon
config.buttons, config.mbuttons, config.mixedButtons = {}, {}, {}


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

	local function tabClick(tab)
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		for i = 1, #tab.tabs do
			local checked = tab == tab.tabs[i]
			tab.tabs[i]:SetEnabled(not checked)
			tab.tabs[i].panel:SetShown(checked)
		end
	end

	local function createTabPanel(tabs, name)
		local panel = CreateFrame("FRAME", nil, self, "HidingBarAddonOptionsPanel")
		local tab = CreateFrame("BUTTON", nil, self, "HidingBarAddonTabTemplate")
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
	self.generalPanel = createTabPanel(settingsTabs, L["General"])
	self.generalPanel:SetPoint("TOPLEFT", 8, -58)
	self.generalPanel:SetPoint("BOTTOMRIGHT", self, -8, 275)

	-- EXPAND TO TEXT
	local expandToText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	expandToText:SetPoint("TOPRIGHT", -10, -8)
	expandToText:SetWidth(114)
	expandToText:SetText(L["Expand to"])

	-- EXPAND TO COMBOBOX
	local expandToCombobox = CreateFrame("FRAME", "HidingBarAddonExpandTo", self.generalPanel, "UIDropDownMenuTemplate")
	expandToCombobox:SetPoint("TOPRIGHT", expandToText, "BOTTOMRIGHT", 17, -2)
	UIDropDownMenu_SetWidth(expandToCombobox, 100)

	local function updateExpandTo(btn)
		UIDropDownMenu_SetSelectedValue(expandToCombobox, btn.value)
		self.hidingBar:setBarExpand(btn.value)
		self:hidingBarUpdate()
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
	UIDropDownMenu_SetSelectedValue(expandToCombobox, self.config.expand)

	-- LINE COLOR
	local lineColor = CreateFrame("BUTTON", nil, self.generalPanel, "HidingBarAddonColorButton")
	lineColor:SetPoint("TOPRIGHT", expandToCombobox, "BOTTOMRIGHT", -18, -2)
	lineColor.color:SetColorTexture(unpack(self.config.lineColor))
	local lineColorText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	lineColorText:SetPoint("RIGHT", lineColor, "LEFT", -3, 0)
	lineColorText:SetJustifyH("RIGHT")
	lineColorText:SetText(L["Line"])

	lineColor.swatchFunc = function()
		self.hidingBar:setLineColor(ColorPickerFrame:GetColorRGB())
		local hexColor = toHex(self.config.lineColor)
		self.description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))
		self.fade.Text:SetText(L["Fade out line"]:format(hexColor))
		self.lineWidth.text:SetText(L["Line width"]:format(hexColor))
		lineColor.color:SetColorTexture(unpack(self.config.lineColor))
		self:hidingBarUpdate()
	end
	lineColor.cancelFunc = function(color)
		self.hidingBar:setLineColor(color.r, color.g, color.b)
		local hexColor = toHex(self.config.lineColor)
		self.description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))
		self.fade.Text:SetText(L["Fade out line"]:format(hexColor))
		self.lineWidth.text:SetText(L["Line width"]:format(hexColor))
		lineColor.color:SetColorTexture(unpack(self.config.lineColor))
		self:hidingBarUpdate()
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
		self.hidingBar:setBackgroundColor(ColorPickerFrame:GetColorRGB())
		self.buttonPanel.bg:SetVertexColor(unpack(self.config.bgColor))
		bgColor.color:SetColorTexture(unpack(self.config.bgColor))
		self:hidingBarUpdate()
	end
	bgColor.opacityFunc = function()
		self.hidingBar:setBackgroundColor(nil, nil, nil, OpacitySliderFrame:GetValue())
		self.buttonPanel.bg:SetVertexColor(unpack(self.config.bgColor))
		bgColor.color:SetColorTexture(unpack(self.config.bgColor))
		self:hidingBarUpdate()
	end
	bgColor.cancelFunc = function(color)
		self.hidingBar:setBackgroundColor(color.r, color.g, color.b, color.opacity)
		self.buttonPanel.bg:SetVertexColor(unpack(self.config.bgColor))
		bgColor.color:SetColorTexture(unpack(self.config.bgColor))
		self:hidingBarUpdate()
	end
	bgColor:SetScript("OnClick", function(btn)
		if ColorPickerFrame:IsShown() and ColorPickerFrame.cancelFunc then
			ColorPickerFrame.cancelFunc(ColorPickerFrame.previousValues)
			HideUIPanel(ColorPickerFrame)
		end
		btn.r, btn.g, btn.b, btn.opacity = unpack(self.config.bgColor)
		OpenColorPicker(btn)
	end)

	-- DESCRIPTION
	local hexColor = toHex(self.config.lineColor)
	self.description = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	self.description:SetPoint("TOPLEFT", 8, -10)
	self.description:SetJustifyH("LEFT")
	self.description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))

	-- ORIENTATION TEXT
	local orientationText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	orientationText:SetPoint("TOPLEFT", self.description, "BOTTOMLEFT", 0, -23)
	orientationText:SetText(L["Orientation"])

	-- ORIENTATION COMBOBOX
	local orientationCombobox = CreateFrame("FRAME", "HidingBarAddonOrientation", self.generalPanel, "UIDropDownMenuTemplate")
	orientationCombobox:SetPoint("LEFT", orientationText, "RIGHT", -12, 0)
	UIDropDownMenu_SetWidth(orientationCombobox, 100)

	local function orientationChange(btn)
		UIDropDownMenu_SetSelectedValue(orientationCombobox, btn.value)
		self.hidingBar:setOrientation(btn.value)
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
	fsText:SetText(L["Strata of panel"])

	-- FRAME STRATA COMBOBOX
	local fsCombobox = CreateFrame("FRAME", "HidingBarAddonFrameStrata", self.generalPanel, "UIDropDownMenuTemplate")
	fsCombobox:SetPoint("LEFT", fsText, "RIGHT", -12, 0)
	UIDropDownMenu_SetWidth(fsCombobox, 100)

	local function fsChange(btn)
		UIDropDownMenu_SetSelectedValue(fsCombobox, btn.value)
		self.hidingBar:setFrameStrata(btn.value)
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
		self.hidingBar:setLocked(checked)
	end)

	-- FADE
	self.fade = CreateFrame("CheckButton", nil, self.generalPanel, "HidingBarAddonCheckButtonTemplate")
	self.fade:SetPoint("TOPLEFT", self.lock, "BOTTOMLEFT", 0, 0)
	self.fade.Text:SetText(L["Fade out line"]:format(hexColor))
	self.fade:SetChecked(self.config.fade)
	self.fade:SetScript("OnClick", function(btn)
		local checked = btn:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		self.fadeOpacity:SetEnabled(checked)
		self.hidingBar:setFade(checked)
	end)

	-- FADE OPACITY
	self.fadeOpacity = CreateFrame("SLIDER", nil, self.generalPanel, "HidingBarAddonSliderTemplate")
	self.fadeOpacity:SetPoint("LEFT", self.fade.Text, "RIGHT", 20, 0)
	self.fadeOpacity:SetPoint("RIGHT", -30, 0)
	self.fadeOpacity:SetMinMaxValues(0, .95)
	self.fadeOpacity.step = 1 / .05
	self.fadeOpacity.text:SetText(L["Opacity"])
	self.fadeOpacity:SetValue(self.config.fadeOpacity)
	self.fadeOpacity.label:SetText(self.config.fadeOpacity)
	self.fadeOpacity:SetEnabled(self.config.fade)
	self.fadeOpacity:SetScript("OnValueChanged", function(slider, value)
		value = math.floor(value * slider.step + .5) / slider.step
		self.hidingBar:setFadeOpacity(value)
		slider.label:SetText(value)
		slider:SetValue(value)
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
		self.hidingBar:setLineWidth(value)
		slider.label:SetText(value)
		slider:SetValue(value)
	end)

	-- SHOW HANDLER TEXT
	local showHandlerText = self.generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	showHandlerText:SetPoint("TOPLEFT", self.lineWidth, "BOTTOMLEFT", 0, -20)
	showHandlerText:SetText(L["Show on"])

	-- SHOW HANDLER
	local showHandlerCombobox = CreateFrame("FRAME", "HidingBarAddonShowHandler", self.generalPanel, "UIDropDownMenuTemplate")
	showHandlerCombobox:SetPoint("LEFT", showHandlerText, "RIGHT", -12, 0)
	UIDropDownMenu_SetWidth(showHandlerCombobox, 100)

	local function updateShowHandler(btn)
		UIDropDownMenu_SetSelectedValue(showHandlerCombobox, btn.value)
		self.hidingBar.drag:setShowHandler(btn.value)
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

	-- BUTTON TAB PANEL
	self.buttonSettingsPanel = createTabPanel(settingsTabs, L["Button settings"])

	-- GRAB ADDONS BUTTONS
	self.grab = CreateFrame("CheckButton", nil, self.buttonSettingsPanel, "HidingBarAddonCheckButtonTemplate")
	self.grab:SetPoint("TOPLEFT", 8, -8)
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
			slider.label:SetText(value)
			self.hidingBar:setMaxButtons(value)
			self:applyLayout(.3)
			self:hidingBarUpdate()
		end
	end)

	-- SLIDER BUTTONS SIZE
	local buttonSize = CreateFrame("SLIDER", nil, self.buttonSettingsPanel, "HidingBarAddonSliderTemplate")
	buttonSize:SetPoint("TOPLEFT", buttonNumber, "BOTTOMLEFT", 0, -18)
	buttonSize:SetPoint("RIGHT", -30, 0)
	buttonSize:SetPoint("RIGHT", -30, 0)
	buttonSize:SetMinMaxValues(16, 64)
	buttonSize.text:SetText(L["Buttons Size"])
	buttonSize:SetValue(self.config.buttonSize)
	buttonSize.label:SetText(self.config.buttonSize)
	buttonSize:SetScript("OnValueChanged", function(slider, value)
		value = math.floor(value + .5)
		slider:SetValue(value)
		if self.config.buttonSize ~= value then
			self.config.buttonSize = value
			slider.label:SetText(value)
			self:setButtonSize()
			self:applyLayout(.3)
			self.hidingBar:setButtonSize(value)
			self:hidingBarUpdate()
		end
	end)

	-- POSTION OF MINIMAP BUTTON TEXT
	local mbtnPostionText = self.buttonSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	mbtnPostionText:SetPoint("TOPLEFT", buttonSize, "BOTTOMLEFT", 0, -20)
	mbtnPostionText:SetText(L["Position of minimap buttons"])

	-- POSITION OF MINIMAP BUTTON
	local mbtnPostionCombobox = CreateFrame("FRAME", "HidingBarAddonMBtnPosition", self.buttonSettingsPanel, "UIDropDownMenuTemplate")
	mbtnPostionCombobox:SetPoint("LEFT", mbtnPostionText, "RIGHT", -12, 0)
	UIDropDownMenu_SetWidth(mbtnPostionCombobox, 100)

	local function updateMBtnPostion(btn)
		UIDropDownMenu_SetSelectedValue(mbtnPostionCombobox, btn.value)
		self:applyLayout(.3)
		self.hidingBar:setMBtnPosition(btn.value)
		self:hidingBarUpdate()
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
	UIDropDownMenu_SetSelectedValue(mbtnPostionCombobox, self.config.mbtnPosition)

	-- POSITION BAR PANEL
	self.positionBarPanel = createTabPanel(settingsTabs, L["Bar position"])

	local function updateBarTypePosition()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		self.attachedToSide.check:SetShown(self.config.barTypePosition == 0)
		self.freeMove.check:SetShown(self.config.barTypePosition == 1)
		self.likeMB.check:SetShown(self.config.barTypePosition == 2)

		if self.config.barTypePosition == 1 then
			UIDropDownMenu_EnableDropDown(self.hideToCombobox)
		else
			UIDropDownMenu_DisableDropDown(self.hideToCombobox)
		end
		self.coordX:SetEnabled(self.config.barTypePosition == 1)
		self.coordY:SetEnabled(self.config.barTypePosition == 1)

		if self.config.barTypePosition == 2 then
			UIDropDownMenu_EnableDropDown(self.ombShowToCombobox)
		else
			UIDropDownMenu_DisableDropDown(self.ombShowToCombobox)
		end
		self.ombSize:SetEnabled(self.config.barTypePosition == 2)
	end

	-- BAR ATTACHED TO THE SIDE
	self.attachedToSide = CreateFrame("BUTTON", nil, self.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
	self.attachedToSide:SetPoint("TOPLEFT", 8, -8)
	self.attachedToSide.Text:SetText(L["Bar attached to the side"])
	self.attachedToSide:SetScript("OnClick", function()
		self.hidingBar:setBarCoords(nil, 0)
		self.hidingBar:setBarTypePosition(0)
		updateBarTypePosition()
		self:hidingBarUpdate()
	end)

	-- BAR MOVES FREELY
	self.freeMove = CreateFrame("BUTTON", nil, self.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
	self.freeMove:SetPoint("TOPLEFT", self.attachedToSide, "BOTTOMLEFT")
	self.freeMove.Text:SetText(L["Bar moves freely"])
	self.freeMove:SetScript("OnClick", function()
		self.hidingBar:setBarTypePosition(1)
		updateBarTypePosition()
		self:hidingBarUpdate()
	end)

	-- HIDE TO
	self.hideToCombobox = CreateFrame("FRAME", "HidingBarAddonHideTo", self.positionBarPanel , "UIDropDownMenuTemplate")
	self.hideToCombobox:SetPoint("TOPLEFT", self.freeMove, "BOTTOMLEFT", 8, 0)
	UIDropDownMenu_SetWidth(self.hideToCombobox, 100)

	local function updateBarAnchor(btn)
		UIDropDownMenu_SetSelectedValue(self.hideToCombobox, btn.value)
		self.hidingBar:setBarAnchor(btn.value)
		self:hidingBarUpdate()
	end

	UIDropDownMenu_Initialize(self.hideToCombobox, function(self, level)
		local info = UIDropDownMenu_CreateInfo()

		info.checked = nil
		info.text = L["Hiding to left"]
		info.value = "left"
		info.func = updateBarAnchor
		UIDropDownMenu_AddButton(info)

		info.checked = nil
		info.text = L["Hiding to right"]
		info.value = "right"
		info.func = updateBarAnchor
		UIDropDownMenu_AddButton(info)

		info.checked = nil
		info.text = L["Hiding to up"]
		info.value = "top"
		info.func = updateBarAnchor
		UIDropDownMenu_AddButton(info)

		info.checked = nil
		info.text = L["Hiding to down"]
		info.value = "bottom"
		info.func = updateBarAnchor
		UIDropDownMenu_AddButton(info)
	end)
	UIDropDownMenu_SetSelectedValue(self.hideToCombobox, self.config.anchor)

	-- COORD X
	self.coordXText = self.positionBarPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	self.coordXText:SetPoint("LEFT", self.hideToCombobox, "RIGHT", -5, 2)
	self.coordXText:SetText("X")

	self.coordX = CreateFrame("EditBox", nil, self.positionBarPanel, "HidingBarAddonCoordTextBox")
	self.coordX:SetPoint("LEFT", self.coordXText, "RIGHT", 1, 0)
	self.coordX:SetScript("OnTextChanged", function(editBox, userInput)
		if userInput then
			editBox:SetNumber(editBox:GetText():match("%-?%d*"))
		end
	end)
	self.coordX.setX = function(editBox, x)
		if self.config.anchor == "left" or self.config.anchor == "right" then
			self.hidingBar:setBarCoords(nil, x)
		else
			self.hidingBar:setBarCoords(x)
		end
		self.hidingBar:updateBarPosition()
	end
	self.coordX:SetScript("OnEnterPressed", function(editBox)
		editBox:setX(tonumber(editBox:GetText():match("%-?%d*")) or 0)
		editBox:ClearFocus()
	end)
	self.coordX:SetScript("OnEditFocusLost", function(editBox)
		self:updateCoords()
		editBox:HighlightText(0, 0)
	end)
	self.coordX:SetScript("OnMouseWheel", function(editBox, delta)
		if editBox:IsEnabled() then
			local int = tonumber(editBox:GetText():match("%-?%d*")) or 0
			editBox:setX(int + (delta > 0 and 1 or -1))
		end
	end)

	-- COORD Y
	self.coordYText = self.positionBarPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	self.coordYText:SetPoint("LEFT", self.coordX, "RIGHT", 5, 0)
	self.coordYText:SetText("Y")

	self.coordY = CreateFrame("EditBox", nil, self.positionBarPanel, "HidingBarAddonCoordTextBox")
	self.coordY:SetPoint("LEFT", self.coordYText, "RIGHT", 1, 0)
	self.coordY:SetScript("OnTextChanged", function(editBox, userInput)
		if userInput then
			editBox:SetNumber(editBox:GetText():match("%-?%d*"))
		end
	end)
	self.coordY.setY = function(editBox, y)
		if self.config.anchor == "left" or self.config.anchor == "right" then
			self.hidingBar:setBarCoords(y)
		else
			self.hidingBar:setBarCoords(nil, y)
		end
		self.hidingBar:updateBarPosition()
	end
	self.coordY:SetScript("OnEnterPressed", function(editBox)
		editBox:setY(tonumber(editBox:GetText():match("%-?%d*")) or 0)
		editBox:ClearFocus()
	end)
	self.coordY:SetScript("OnEditFocusLost", function(editBox)
		self:updateCoords()
		editBox:HighlightText(0, 0)
	end)
	self.coordY:SetScript("OnMouseWheel", function(editBox, delta)
		if editBox:IsEnabled() then
			local int = tonumber(editBox:GetText():match("%-?%d*")) or 0
			editBox:setY(int + (delta > 0 and 1 or -1))
		end
	end)

	-- SET COORDS
	self:updateCoords()

	-- BAR LIKE MINIMAP BUTTON
	self.likeMB = CreateFrame("BUTTON", nil, self.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
	self.likeMB:SetPoint("TOPLEFT", self.hideToCombobox, "BOTTOMLEFT", -8, 0)
	self.likeMB.Text:SetText(L["Bar like a minimap button"])
	self.likeMB:SetScript("OnClick", function()
		self.hidingBar:setBarTypePosition(2)
		updateBarTypePosition()
		self:hidingBarUpdate()
	end)

	-- MINIMAP BUTTON SHOW TO
	self.ombShowToCombobox = CreateFrame("FRAME", "HidingBarAddonMBShowTo", self.positionBarPanel, "UIDropDownMenuTemplate")
	self.ombShowToCombobox:SetPoint("TOPLEFT", self.likeMB, "BOTTOMLEFT", 8, 0)
	UIDropDownMenu_SetWidth(self.ombShowToCombobox, 100)

	local function mbShowToChange(btn)
		UIDropDownMenu_SetSelectedValue(self.ombShowToCombobox, btn.value)
		self.hidingBar:setOMBAnchor(btn.value)
		self:hidingBarUpdate()
	end

	UIDropDownMenu_Initialize(self.ombShowToCombobox, function(self, level)
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
	UIDropDownMenu_SetSelectedValue(self.ombShowToCombobox, self.config.omb.anchor)

	-- SLIDER MINIMAP BUTTON SIZE
	self.ombSize = CreateFrame("SLIDER", nil, self.positionBarPanel, "HidingBarAddonSliderTemplate")
	self.ombSize:SetPoint("LEFT", self.ombShowToCombobox, "RIGHT", -5, 0)
	self.ombSize:SetPoint("RIGHT", -30, 0)
	self.ombSize:SetMinMaxValues(16, 64)
	self.ombSize.text:SetText(L["Button Size"])
	self.ombSize:SetValue(self.config.omb.size)
	self.ombSize.label:SetText(self.config.omb.size)
	self.ombSize:SetScript("OnValueChanged", function(slider, value)
		value = math.floor(value + .5)
		slider:SetValue(value)
		if self.config.omb.size ~= value then
			slider.label:SetText(value)
			self.hidingBar:setOMBSize(value)
			self.hidingBar:setBarTypePosition()
		end
	end)

	-- UPDATE BAR TYPE POSITION OPTIONS
	updateBarTypePosition()

	-- BUTTONS TAB PANEL
	self.buttonsTabPanel = createTabPanel(buttonTabs, L["Buttons"])
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
	self.ignoreTabPanel = createTabPanel(buttonTabs, L["Ignore list"])

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
		self:sort(self.mixedButtons)
		self:setButtonSize()
		self:applyLayout()
	end)
end)


function config:updateCoords()
	if not self.coordX or not self.coordY then return end

	local x = self.hidingBar.position or 0
	local y = self.hidingBar.secondPosition or 0
	local anchor = self.config.barTypePosition == 2 and self.config.omb.anchor or self.config.anchor
	if anchor == "left" or anchor == "right" then x, y = y, x end

	self.coordX:SetNumber(math.floor(x + .5))
	self.coordY:SetNumber(math.floor(y + .5))
end


function config:addIgnoreName(name)
	name = name:gsub("[%(%)%.%%%+%-%*%?%[%^%$]", "%%%1")
	for _, n in ipairs(self.config.ignoreMBtn) do
		if name == n then return end
	end
	tinsert(self.config.ignoreMBtn, name)
	sort(self.config.ignoreMBtn)
	self.ignoreScroll:update()
	StaticPopup_Show(config.addonName.."GET_RELOAD")
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
	self.hidingBar:leave()
end


function config:dragBtn(btn)
	local scale = btn:GetScale()
	local x = btn:GetLeft() - (self.buttonPanel:GetLeft() + 4) / scale
	local y = (self.buttonPanel:GetTop() - 4) / scale - btn:GetTop()
	local buttonSize = self.config.buttonSize / scale
	local row, column = math.floor(y / buttonSize + .5), math.floor(x / buttonSize + .5) + 1
	if row < btn.minRow then row = btn.minRow
	elseif row > btn.maxRow then row = btn.maxRow end
	if column < 1 then column = 1
	elseif column > btn.maxColumn then column = btn.maxColumn end
	local order = row * self.size + column - btn.orderDelta
	if order < 1 then order = 1
	elseif order > #btn.btnList then order = #btn.btnList end

	local step = order > btn.settings[2] and 1 or -1
	for i = btn.settings[2], order - step, step do
		local button = btn.btnList[i + step]
		btn.btnList[i] = button
		button.settings[2] = i
		self:setPointBtn(button, 4, 4, i + btn.orderDelta, .1)
	end
	btn.btnList[order] = btn
	btn.settings[2] = order
end


function config:dragStart(btn, orderDelta)
	btn.isDrag = true
	btn.btnList = self.config.mbtnPosition == 2 and self.mixedButtons or btn.defBtnList
	for i = 1, #btn.btnList do
		btn.btnList[i].settings[2] = i
	end
	if not btn.level then btn.level = btn:GetFrameLevel() end
	btn:SetFrameLevel(btn.level + 2)
	btn.orderDelta = orderDelta or 0
	btn.maxColumn = #btn.btnList + btn.orderDelta
	btn.minRow = math.floor(btn.orderDelta / self.size)
	btn.maxRow = math.ceil(btn.maxColumn / self.size) - 1
	if btn.maxColumn > self.size then btn.maxColumn = self.size end
	btn:SetScript("OnUpdate", function(btn) self:dragBtn(btn) end)
	btn:StartMoving()
end


function config:dragStop(btn)
	btn.isDrag = nil
	btn:SetFrameLevel(btn.level)
	btn:SetScript("OnUpdate", nil)
	btn:StopMovingOrSizing()
	self:setPointBtn(btn, 4, 4, btn.settings[2] + btn.orderDelta, .3)
	if self.config.mbtnPosition == 2 then
		self:sort(btn.defBtnList)
	else
		self:sort(self.mixedButtons)
	end
	self.hidingBar:sort()
	self.hidingBar:applyLayout()
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
		config.hidingBar:applyLayout()
		config:hidingBarUpdate()
	end

	local function btnDragStart(btn)
		config:dragStart(btn)
	end

	local function btnDragStop(btn)
		config:dragStop(btn)
	end

	function config:createButton(name, button, update)
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
		btn.settings = self.config.btnSettings[name]
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
end


do
	local buttonsByName = {}

	local function btnClick(self, button)
		if button == "LeftButton" then
			self.settings[1] = self:GetChecked()
			config.hidingBar:applyLayout()
			config:hidingBarUpdate()
		elseif button == "RightButton" then
			self:SetChecked(not self:GetChecked())
			StaticPopup_Show(config.addonName.."ADD_IGNORE_MBTN", NORMAL_FONT_COLOR_CODE..self.name..FONT_COLOR_CODE_CLOSE, nil, function()
				config:addIgnoreName(self.name)
			end)
		end
	end

	local function btnDragStart(btn)
		config:dragStart(btn, config.orderMBtnDelta)
	end

	local function btnDragStop(btn)
		config:dragStop(btn)
	end

	function config:createMButton(name, icon, update)
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
		btn.settings = self.config.mbtnSettings[name]
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
end


function config:initButtons()
	for _, button in ipairs(self.hidingBar.createdButtons) do
		self:createButton(button.name, button)
	end
end


function config:initMButtons(update)
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
			self:createMButton(name, icon, update)
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


function config:applyLayout(delay)
	local offsetX, offsetY = 4, 4
	local maxColumns, rows = math.floor(560 / self.config.buttonSize)
	self.size = self.config.size
	if self.size > maxColumns then self.size = maxColumns end

	if self.config.mbtnPosition == 2 then
		for i, btn in ipairs(self.mixedButtons) do
			self:setPointBtn(btn, offsetX, offsetY, i, delay)
		end
		self.orderMBtnDelta = 0
		rows = math.ceil(#self.mixedButtons / self.size)
	else
		for i, btn in ipairs(self.buttons) do
			self:setPointBtn(btn, offsetX, offsetY, i, delay)
		end
		self.orderMBtnDelta = self.config.mbtnPosition == 1 and #self.buttons or math.ceil(#self.buttons / self.size) * self.size
		for i, btn in ipairs(self.mbuttons) do
			self:setPointBtn(btn, offsetX, offsetY, i + self.orderMBtnDelta, delay)
		end
		rows = math.ceil((#self.mbuttons + self.orderMBtnDelta) / self.size)
	end

	local width = self.size * self.config.buttonSize + offsetX * 2
	local height = rows * self.config.buttonSize + offsetY * 2
	self.buttonPanel:SetSize(width, height)
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