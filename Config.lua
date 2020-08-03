local addon, L = ...
local config = CreateFrame("FRAME", addon.."ConfigAddon", InterfaceOptionsFramePanelContainer)
config.noIcon = config:CreateTexture()
config.noIcon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
config.noIcon:SetTexCoord(.05, .95, .05, .95)
config.noIcon:Hide()
config.name = addon
config.buttons, config.mbuttons = {}, {}


config:SetScript("OnShow", function(self)
	self.addonName = ("%s_ADDON_"):format(addon:upper())
	StaticPopupDialogs[self.addonName.."SET_GRAB"] = {
		text = addon..": "..L["RELOAD_INTERFACE_QUESTION"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hideOnEscape = 1,
		whileDead = 1,
		OnAccept = function(_, data) data.accept() end,
		OnCancel = function(self) self.data.cancel() end,
	}
	StaticPopupDialogs[self.addonName.."ADD_IGNORE_MBTN"] = {
		text = addon..": "..L["ADD_IGNORE_MBTN_QUESTION"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hideOnEscape = 1,
		whileDead = 1,
		OnAccept = function(_, cb) cb() end,
	}
	StaticPopupDialogs[self.addonName.."REMOVE_IGNORE_MBTN"] = {
		text = addon..": "..L["REMOVE_IGNORE_MBTN_QUESTION"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hideOnEscape = 1,
		whileDead = 1,
		OnAccept = function(_, cb) cb() end,
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

	-- OPTION PANEL
	local optionPanel = CreateFrame("FRAME", nil, self, "HidingBarAddonOptionsPanel")
	optionPanel:SetPoint("TOPLEFT", 8, -40)
	optionPanel:SetPoint("BOTTOMRIGHT", self, -8, 265)

	-- DESCRIPTION
	local description = optionPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	description:SetPoint("TOPLEFT", 8, -10)
	description:SetJustifyH("LEFT")
	description:SetText(L["SETTINGS_DESCRIPTION"])

		-- LOCK
	self.lock = CreateFrame("CheckButton", nil, optionPanel, "HidingBarAddonCheckButtonTemplate")
	self.lock:SetPoint("TOPLEFT", description, "TOPRIGHT", 30, -28)
	self.lock.Text:SetText(L["Lock the bar's location"])
	self.lock:SetChecked(self.config.lock)
	self.lock:SetScript("OnClick", function(btn)
		local checked = btn:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		self.config.lock = checked
	end)

	-- FADE
	local fade = CreateFrame("CheckButton", nil, optionPanel, "HidingBarAddonCheckButtonTemplate")
	fade:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -12)
	fade.Text:SetText(L["Fade out yellow line"])
	fade:SetChecked(self.config.fade)
	fade:SetScript("OnClick", function(btn)
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
	self.fadeOpacity = CreateFrame("SLIDER", nil, optionPanel, "HidingBarAddonSliderTemplate")
	self.fadeOpacity:SetPoint("LEFT", fade, "RIGHT", 200, 0)
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

	-- ORIENTATION TEXT
	local orientationText = optionPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	orientationText:SetPoint("TOPLEFT", fade, "BOTTOMLEFT", 0, -15)
	orientationText:SetText(L["Orientation"]..":")

	-- ORIENTATION COMBOBOX
	local orientationCombobox = CreateFrame("FRAME", "MountsJournalModifier", optionPanel, "UIDropDownMenuTemplate")
	orientationCombobox:SetPoint("LEFT", orientationText, "RIGHT", -5, 0)
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

	-- GRAB
	self.grab = CreateFrame("CheckButton", nil, optionPanel, "HidingBarAddonCheckButtonTemplate")
	self.grab:SetPoint("TOPLEFT", orientationText, "BOTTOMLEFT", 0, -15)
	self.grab.Text:SetText(L["Grab addon buttons on minimap"])
	self.grab:SetChecked(self.config.grabMinimap)
	self.grab:SetScript("OnClick", function(btn)
		StaticPopup_Show(self.addonName.."SET_GRAB", nil, nil, {
			accept = function()
				self.config.grabMinimap = not self.config.grabMinimap
				ReloadUI()
			end,
			cancel = function()
				btn:SetChecked(self.config.grabMinimap)
			end,
		})
	end)

	-- GRAB WITHOUT NAME
	self.grabWithoutName = CreateFrame("CheckButton", nil, optionPanel, "HidingBarAddonCheckButtonTemplate")
	self.grabWithoutName:SetPoint("TOPLEFT", self.grab, "BOTTOMLEFT", 20, 0)
	self.grabWithoutName.Text:SetText(L["Grab buttons without a name"])
	self.grabWithoutName:SetEnabled(self.config.grabMinimap)
	self.grabWithoutName:SetChecked(self.config.grabMinimapWithoutName)
	self.grabWithoutName:SetScript("OnClick", function(btn)
		StaticPopup_Show(self.addonName.."SET_GRAB", nil, nil, {
			accept = function()
				self.config.grabMinimapWithoutName = not self.config.grabMinimapWithoutName
				ReloadUI()
			end,
			cancel = function()
				btn:SetChecked(self.config.grabMinimapWithoutName)
			end,
		})
	end)

	-- SLIDER NUMBER BUTTONS IN ROW
	local buttonNumber = CreateFrame("SLIDER", nil, optionPanel, "HidingBarAddonSliderTemplate")
	buttonNumber:SetPoint("TOPLEFT", self.grabWithoutName, "BOTTOMLEFT", -20, -15)
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
	local buttonSize = CreateFrame("SLIDER", nil, optionPanel, "HidingBarAddonSliderTemplate")
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
	self.buttonsTabPanel:SetPoint("TOPLEFT", optionPanel, "BOTTOMLEFT", 0, -25)
	self.buttonsTabPanel:SetPoint("BOTTOMRIGHT", self, -8, 8)

	local buttonsTabPanelScroll = CreateFrame("ScrollFrame", nil, self.buttonsTabPanel, "UIPanelScrollFrameTemplate")
	buttonsTabPanelScroll:SetPoint("TOPLEFT", self.buttonsTabPanel, 4, -6)
	buttonsTabPanelScroll:SetPoint("BOTTOMRIGHT", self.buttonsTabPanel, -26, 5)
	buttonsTabPanelScroll.ScrollBar:SetBackdrop({bgFile='interface/buttons/white8x8'})
	buttonsTabPanelScroll.ScrollBar:SetBackdropColor(0,0,0,.2)
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

	-- IGNORE TAB PANEL
	self.ignoreTabPanel = CreateFrame("FRAME", nil, self, "HidingBarAddonOptionsPanel")
	self.ignoreTabPanel:SetPoint("TOPLEFT", optionPanel, "BOTTOMLEFT", 0, -25)
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
	C_Timer.After(.1, function() self:initButtons() end)

	-- RESET ONSHOW
	self:SetScript("OnShow", nil)
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
	local function btnClick(self, button)
		if button == "LeftButton" then
			self.settings[1] = self:GetChecked()
			config:hidingBarUpdate()
		elseif button == "RightButton" then
			self:SetChecked(not self:GetChecked())
			StaticPopup_Show(config.addonName.."ADD_IGNORE_MBTN", NORMAL_FONT_COLOR_CODE..self.name..FONT_COLOR_CODE_CLOSE, nil, function()
				config:addIgnoreName(self.name)
			end)
		end
	end

	function config:createMButton(name, icon)
		if type(name) ~= "string" then return end
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
		tinsert(self.mbuttons, btn)
	end
end


function config:initButtons()
	for _, button in ipairs(self.hidingBar.createdButtons) do
		self:createButton(button.name, button)
	end
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
	self:setButtonSize()
	self:applyLayout()
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