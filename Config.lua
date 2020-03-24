local addon, L = ...
local config = CreateFrame("FRAME", addon.."ConfigAddon", InterfaceOptionsFramePanelContainer)
config.noIcon = config:CreateTexture()
config.noIcon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
config.name = addon
config.buttons, config.mbuttons = {}, {}


config:SetScript("OnShow", function(self)
	self.hidingBar = _G[addon.."Addon"]
	self.config = self.hidingBar.config

	self.addonName = format("%s_ADDON_", addon:upper())
	StaticPopupDialogs[self.addonName.."SET_GRAB"] = {
		text = addon..": "..L["RELOAD_INTERFACE_QUESTION"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hideOnEscape = 1,
		whileDead = 1,
		OnAccept = function()
			self.config.grabMinimap = not self.config.grabMinimap
			ReloadUI()
		end,
		OnCancel = function()
			self.grab:SetChecked(self.config.grabMinimap)
		end,
	}

	-- ADDON INFO
	local info = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	info:SetPoint("TOPRIGHT", -16, 16)
	info:SetTextColor(.5, .5, .5, 1)
	info:SetText(format("%s %s: %s", GetAddOnMetadata(addon, "Version"), L["author"], GetAddOnMetadata(addon, "Author")))

	-- TITLE
	local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(format(L["%s Configuration"], addon))

	-- OPTION PANEL
	local optionPanel = CreateFrame("FRAME", nil, self, "HidingBarAddonOptionsPanel")
	optionPanel:SetPoint("TOPLEFT", 8, -40)
	optionPanel:SetPoint("BOTTOMRIGHT", self, -8, 8)

	local optionPanelScroll = CreateFrame("ScrollFrame", nil, optionPanel, "UIPanelScrollFrameTemplate")
	optionPanelScroll:SetPoint("TOPLEFT", optionPanel, 4, -6)
	optionPanelScroll:SetPoint("BOTTOMRIGHT", optionPanel, -26, 5)
	optionPanelScroll.ScrollBar:SetBackdrop({bgFile='interface/buttons/white8x8'})
	optionPanelScroll.ScrollBar:SetBackdropColor(0,0,0,.2)
	optionPanelScroll.child = CreateFrame("FRAME")
	optionPanelScroll.child:SetSize(1, 1)
	optionPanelScroll:SetScrollChild(optionPanelScroll.child)

	-- DESCRIPTION
	local description = optionPanelScroll.child:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	description:SetPoint("TOPLEFT", 8, -20)
	description:SetJustifyH("LEFT")
	description:SetText(L["SETTINGS_DESCRIPTION"])

	-- FADE
	local fade = CreateFrame("CheckButton", nil, optionPanelScroll.child, "HidingBarAddonCheckButtonTemplate")
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
	end)

	-- FADE OPACITY
	self.fadeOpacity = CreateFrame("SLIDER", nil, optionPanelScroll.child, "HidingBarAddonSliderTemplate")
	self.fadeOpacity:SetWidth(300)
	self.fadeOpacity:SetPoint("LEFT", fade, "RIGHT", 200, 0)
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
	local orientationText = optionPanelScroll.child:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	orientationText:SetPoint("TOPLEFT", fade, "BOTTOMLEFT", 0, -15)
	orientationText:SetText(L["Orientation"]..":")

	-- ORIENTATION COMBOBOX
	local orientationCombobox = CreateFrame("FRAME", "MountsJournalModifier", optionPanelScroll.child, "UIDropDownMenuTemplate")
	orientationCombobox:SetPoint("LEFT", orientationText, "RIGHT", -5, 0)
	UIDropDownMenu_SetWidth(orientationCombobox, 100)

	local function orientationChange(btn)
		UIDropDownMenu_SetSelectedValue(orientationCombobox, btn.value)
		self.config.orientation = btn.value
		self:hidingBarUpdate()
	end

	UIDropDownMenu_Initialize(orientationCombobox, function(self, level, menuList)
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

	-- LOCK
	self.lock = CreateFrame("CheckButton", nil, optionPanelScroll.child, "HidingBarAddonCheckButtonTemplate")
	self.lock:SetPoint("TOPLEFT", orientationText, "BOTTOMLEFT", 0, -15)
	self.lock.Text:SetText(L["Lock the bar's location"])
	self.lock:SetChecked(self.config.lock)
	self.lock:SetScript("OnClick", function(btn)
		local checked = btn:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		self.config.lock = checked
	end)

	-- GRAB
	self.grab = CreateFrame("CheckButton", nil, optionPanelScroll.child, "HidingBarAddonCheckButtonTemplate")
	self.grab:SetPoint("TOPLEFT", self.lock, "BOTTOMLEFT")
	self.grab.Text:SetText(L["Grab addon buttons on minimap"])
	self.grab:SetChecked(self.config.grabMinimap)
	self.grab:SetScript("OnClick", function()
		StaticPopup_Show(self.addonName.."SET_GRAB")
	end)

	-- SLIDER NUMBER BUTTONS IN ROW
	local maxColumns = 17
	self.size = self.config.size
	if self.size > maxColumns then self.size = maxColumns end

	local buttonsSlider = CreateFrame("SLIDER", nil, optionPanelScroll.child, "HidingBarAddonSliderTemplate")
	buttonsSlider:SetPoint("TOPLEFT", self.grab, "BOTTOMLEFT", 0, -20)
	buttonsSlider:SetMinMaxValues(1, 30)
	buttonsSlider.text:SetText(L["Number of buttons"])
	buttonsSlider:SetValue(self.config.size)
	buttonsSlider.label:SetText(self.config.size)
	buttonsSlider:SetScript("OnValueChanged", function(slider, value)
		value = math.floor(value + .5)
		config.config.size = value
		self.size = value
		if self.size > maxColumns then self.size = maxColumns end
		slider.label:SetText(value)
		slider:SetValue(value)
		self:applyLayout()
		self:hidingBarUpdate()
	end)

	-- BUTTON PANEL DESCRIPTION
	local buttonPanelDescription = optionPanelScroll.child:CreateFontString("ARTWORK", nil, "GameFontHighlight")
	buttonPanelDescription:SetPoint("TOPLEFT", buttonsSlider, "BOTTOMLEFT", 0, -20)
	buttonPanelDescription:SetText(L["BUTTON_PANEL_DESCRIPTION"])

	-- BUTTON PANEL
	self.buttonPanel = CreateFrame("Frame", nil, optionPanelScroll.child, "HidingBarAddonPanel")
	self.buttonPanel:SetPoint("TOPLEFT", buttonPanelDescription, "BOTTOMLEFT", 0, -5)
	self.buttonPanel:SetSize(20, 20)

	-- INIT
	self:initButtons()

	-- RESET ONSHOW
	self:SetScript("OnShow", nil)
end)


function config:hidingBarUpdate()
	self.hidingBar:applyLayout()
	self.hidingBar:enter()
	self.hidingBar:leave()
end


function config:dragBtn(btn)
	local x, y = btn:GetLeft() - btn.left, btn.top - btn:GetTop()
	local row, column = math.floor(y / 32 + .5), math.floor(x / 32 + .5) + 1
	if row < 0 then row = 0 end
	if row > btn.maxRow then row = btn.maxRow end
	if column < 1 then column = 1 end
	if column > btn.maxColumn then column = btn.maxColumn end
	local order = row * self.size + column
	if order > #btn.btnList then order = #btn.btnList end

	local step = order > btn.settings[2] and 1 or -1
	for i = btn.settings[2] + step, order, step do
		self:setPointBtn(btn.btnList[i], 4, 4 + btn.offset, i - step)
	end
	btn.settings[2] = order
	self:sort(btn.btnList)
end


function config:dragStart(btn, offset)
	btn.isDrag = true
	if not btn.level then btn.level = btn:GetFrameLevel() end
	btn:SetFrameLevel(btn.level + 2)
	btn.offset = offset or 0
	btn.left = self.buttonPanel:GetLeft()
	btn.top = self.buttonPanel:GetTop() - btn.offset
	local numBtns = #btn.btnList
	btn.maxRow = math.ceil(numBtns / self.size) - 1
	if numBtns > self.size then numBtns = self.size end
	btn.maxColumn = numBtns
	btn:SetScript("OnUpdate", function(btn) self:dragBtn(btn) end)
	btn:StartMoving()
end


function config:dragStop(btn)
	btn.isDrag = nil
	btn:SetFrameLevel(btn.level)
	btn:SetScript("OnUpdate", nil)
	btn:StopMovingOrSizing()
	self:setPointBtn(btn, 4, 4 + btn.offset, btn.settings[2])
	self.hidingBar:sort()
	self:hidingBarUpdate()
end


function config:sort(buttons)
	sort(buttons, function(a, b)
		local o1, o2 = a.settings[2], b.settings[2]
		return o1 and not o2
			 or o1 and o2 and o1 < o2
			 or o1 == o2 and a.id < b.id
	end)
end


do
	local function btnClick(self)
		self.settings[1] = self:GetChecked()
		config:hidingBarUpdate()
	end

	function config:createButton(id, order, data, update)
		if self.buttons[id] then return end
		local btn = CreateFrame("CheckButton", nil, self.buttonPanel, "HidingBarAddonConfigButtonTemplate")
		btn.id = id
		if data.icon then
			btn.icon:SetTexture(data.icon)
			if data.iconR then
				btn.icon:SetVertexColor(data.iconR, 1, 1)
			end
			if data.iconG then
				local r, _, b = btn.icon:GetVertexColor()
				btn.icon:SetVertexColor(r, data.igonG, b)
			end
			if data.iconB then
				local r, g = btn.icon:GetVertexColor()
				btn.icon:SetVertexColor(r, g, data.iconB)
			end
			if data.iconDesaturated then
				btn.icon:SetDesaturated(true)
			end
		end
		btn.btnList = self.buttons
		btn:HookScript("OnClick", btnClick)
		btn:SetScript("OnDragStart", function(btn) self:dragStart(btn) end)
		btn:SetScript("OnDragStop", function(btn) self:dragStop(btn) end)
		btn.settings = self.hidingBar.config.btnSettings[btn.id]
		if not btn.settings then
			btn.settings = {[2] = order, tstmp = time()}
			self.hidingBar.config.btnSettings[btn.id] = btn.settings
		end
		btn.settings[2] = order
		btn:SetChecked(btn.settings[1])
		tinsert(self.buttons, btn)
		if update then
			self:sort(self.buttons)
			self:applyLayout()
		end
	end
end


do
	local function btnClick(self)
		self.settings[1] = self:GetChecked()
		config:hidingBarUpdate()
	end

	function config:createMButton(id, order, icon)
		if type(id) ~= "string" then return end
		local btn = CreateFrame("CheckButton", nil, self.buttonPanel, "HidingBarAddonConfigMButtonTemplate")
		btn.id = id
		btn.title = id:gsub("LibDBIcon10_", "")
		btn.icon:SetTexture(icon:GetTexture())
		btn.icon:SetTexCoord(icon:GetTexCoord())
		btn.icon:SetVertexColor(icon:GetVertexColor())
		btn.btnList = self.mbuttons
		btn:HookScript("OnClick", btnClick)
		btn:SetScript("OnDragStart", function(btn) self:dragStart(btn, math.ceil(#self.buttons / self.size) * 32) end)
		btn:SetScript("OnDragStop", function(btn) self:dragStop(btn) end)
		btn.settings = self.hidingBar.config.mbtnSettings[btn.id]
		if not btn.settings then
			btn.settings = {tstmp = time()}
			self.hidingBar.config.mbtnSettings[btn.id] = btn.settings
		end
		btn.settings[2] = order
		btn:SetChecked(btn.settings[1])
		tinsert(self.mbuttons, btn)
	end
end


function config:initButtons()
	for i, button in ipairs(self.hidingBar.createdButtons) do
		self:createButton(button.id, i, button.data)
	end
	for i, button in ipairs(self.hidingBar.minimapButtons) do
		local name = button:GetName()
		if name then
			local icon = button.icon or button.Icon or _G[name.."icon"] or _G[name.."Icon"] or button.background or button.Background
			if not icon or not icon.GetTexture then
				icon = self.noIcon
			end
			self:createMButton(name, i, icon)
		end
	end
	self:applyLayout()
end


local function setPosAnimated(btn, elapsed)
	btn.timer = btn.timer - elapsed
	if btn.timer <= 0 then
		btn:SetPoint("TOPLEFT", btn.x, btn.y)
		btn:SetScript("OnUpdate", nil)
	else
		local k = btn.timer / .1
		btn:SetPoint("TOPLEFT", btn.x - btn.deltaX * k, btn.y - btn.deltaY * k)
	end
end


function config:setPointBtn(btn, offsetX, offsetY, order)
	if order then
		btn.settings[2] = order
		if btn.isDrag then return end
		btn.timer = .1
		local line = math.ceil(order / self.size) - 1
		btn.x = (order - 1 - line * self.size) * 32 + offsetX
		btn.y = -line * 32 - offsetY
		btn.deltaX = btn.x - btn:GetLeft() + self.buttonPanel:GetLeft()
		btn.deltaY = btn.y - btn:GetTop() + self.buttonPanel:GetTop()
		btn:ClearAllPoints()
		btn:SetScript("OnUpdate", setPosAnimated)
	else
		btn:ClearAllPoints()
		local line = math.ceil(btn.settings[2] / self.size) - 1
		btn:SetPoint("TOPLEFT", (btn.settings[2] - 1 - line * self.size) * 32 + offsetX, -line * 32 - offsetY)
	end
end


function config:applyLayout()
	if not self.buttonPanel then return end

	for _, btn in ipairs(self.buttons) do
		self:setPointBtn(btn, 4, 4)
	end
	local offsetY = math.ceil(#self.buttons / self.size) * 32 + 4
	for _, btn in ipairs(self.mbuttons) do
		self:setPointBtn(btn, 4, offsetY)
	end

	local rows = math.ceil(#self.buttons / self.size) + math.ceil(#self.mbuttons / self.size)
	self.buttonPanel:SetSize(self.size * 32 + 8, rows * 32 + 8)
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