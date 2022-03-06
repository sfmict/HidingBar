local main, hb = HidingBarConfigAddon, HidingBarAddon
local addon, L = main.name, main.L
main.noIcon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
main.noIcon:SetTexCoord(.05, .95, .05, .95)
main.noIcon:Hide()
main.buttons, main.mbuttons, main.mixedButtons = {}, {}, {}
local lsfdd = LibStub("LibSFDropDown-1.4")


local scale = WorldFrame:GetWidth() / GetPhysicalScreenSize() / UIParent:GetScale()
main.optionsPanelBackdrop = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 14 * scale,
	edgeSize = 14 * scale,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}


main.editBoxBackdrop = {
	bgFile = "Interface/ChatFrame/ChatFrameBackground",
	edgeFile = "Interface/ChatFrame/ChatFrameBackground",
	tile = true, edgeSize = 1 * scale, tileSize = 5 * scale,
}


main.colorButtonBackdrop = {
	edgeFile = "Interface/ChatFrame/ChatFrameBackground",
	edgeSize = 1 * scale,
}


local function toHex(tbl)
	local str = ""
	for i = 1, #tbl do
		str = str..("%02x"):format(tbl[i] * 255)
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
local buttonsTabs, barSettingsTabs = {}, {}

-- DIALOGS
main.addonName = ("%s_ADDON_"):format(addon:upper())
StaticPopupDialogs[main.addonName.."NEW_PROFILE"] = {
	text = addon..": "..L["New profile"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 48,
	editBoxWidth = 350,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb(self) end,
	EditBoxOnEnterPressed = function(self)
		StaticPopup_OnClick(self:GetParent(), 1)
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	OnShow = function(self)
		self.editBox:SetText(UnitName("player").." - "..GetRealmName())
		self.editBox:HighlightText()
	end,
}
local function profileExistsAccept(popup, data)
	if not popup then return end
	popup:Hide()
	main:createProfile(data)
end
StaticPopupDialogs[main.addonName.."PROFILE_EXISTS"] = {
	text = addon..": "..L["A profile with the same name exists."],
	button1 = OKAY,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = profileExistsAccept,
	OnCancel = profileExistsAccept,
}
StaticPopupDialogs[main.addonName.."DELETE_PROFILE"] = {
	text = addon..": "..L["Are you sure you want to delete profile %s?"],
	button1 = DELETE,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}
StaticPopupDialogs[main.addonName.."NEW_BAR"] = {
	text = addon..": "..L["Add bar"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 48,
	editBoxWidth = 350,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb(self) end,
	EditBoxOnEnterPressed = function(self)
		StaticPopup_OnClick(self:GetParent(), 1)
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	OnShow = function(self)
		self.editBox:SetText(L["Bar"].." "..(#main.currentProfile.bars + 1))
		self.editBox:HighlightText()
	end,
}
local function barExistsAccept(popup)
	if not popup then return end
	popup:Hide()
	main:createBar()
end
StaticPopupDialogs[main.addonName.."BAR_EXISTS"] = {
	text = addon..": "..L["A bar with the same name exists."],
	button1 = OKAY,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = barExistsAccept,
	OnCancel = barExistsAccept,
}
StaticPopupDialogs[main.addonName.."DELETE_BAR"] = {
	text = addon..": "..L["Are you sure you want to delete bar %s?"],
	button1 = DELETE,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}
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
StaticPopupDialogs[main.addonName.."ADD_CUSTOM_GRAB_BTN"] = {
	text = addon..": "..L["ADD_CUSTOM_GRAB_BTN_QUESTION"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}
StaticPopupDialogs[main.addonName.."REMOVE_CUSTOM_GRAB_BTN"] = {
	text = addon..": "..L["REMOVE_CUSTOM_GRAB_BTN_QUESTION"],
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
info:SetText(GetAddOnMetadata(addon, "Version"))

-- TITLE
local title = main:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetJustifyH("LEFT")
title:SetText(L["%s Configuration"]:format(addon))

-- PROFILES COMBOBOX
local profilesCombobox = lsfdd:CreateStretchButton(main, 150, 22)
profilesCombobox:SetPoint("TOPRIGHT", -16, -12)

profilesCombobox:ddSetInitFunc(function(self, level)
	local info = {}

	if level == 1 then
		local function removeProfile(btn)
			main:removeProfile(btn.value)
		end

		local function selectProfile(btn)
			hb:setProfile(btn.value)
			main:setProfile()
			main:hidingBarUpdate()
		end

		local profileName = hb.charDB.currentProfileName
		info.list = {}
		for i, profile in ipairs(hb.profiles) do
			local subInfo = {
				text = profile.isDefault and profile.name.." "..DARKGRAY_COLOR:WrapTextInColorCode(DEFAULT) or profile.name,
				value = profile.name,
				checked = profile.name == main.currentProfile.name,
				func = selectProfile,
			}
			if #hb.profiles > 1 then
				subInfo.remove = removeProfile
			end
			tinsert(info.list, subInfo)
		end
		self:ddAddButton(info, level)
		info.list = nil

		self:ddAddSeparator(level)

		info.keepShownOnClick = true
		info.notCheckable = true
		info.hasArrow = true
		info.text = L["New profile"]
		self:ddAddButton(info, level)

		if not main.currentProfile.isDefault then
			info.keepShownOnClick = nil
			info.hasArrow = nil
			info.text = L["Set as default"]
			info.func = function()
				for _, profile in ipairs(hb.profiles) do
					profile.isDefault = nil
				end
				main.currentProfile.isDefault = true
			end
			self:ddAddButton(info, level)
		end
	else
		info.notCheckable = true

		info.text = L["Create"]
		info.func = function() main:createProfile() end
		self:ddAddButton(info, level)

		info.text = L["Copy current"]
		info.func = function() main:createProfile(true) end
		self:ddAddButton(info, level)
	end
end)

-- PROFILES TEXT
local profilesText = main:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
profilesText:SetPoint("RIGHT", profilesCombobox, "LEFT", -5, 0)
profilesText:SetText(L["Profile"])

-------------------------------------------
-- BAR TAB PANEL
-------------------------------------------
main.barPanel = createTabPanel(buttonsTabs, L["Bar"])
main.barPanel:SetHeight(242)
main.barPanel:SetPoint("TOPLEFT", 8, -58)
main.barPanel:SetPoint("TOPRIGHT", -8, -58)

local barPanelScroll = CreateFrame("ScrollFrame", nil, main.barPanel, "UIPanelScrollFrameTemplate")
barPanelScroll:SetPoint("TOPLEFT", main.barPanel, 4, -6)
barPanelScroll:SetPoint("BOTTOMRIGHT", main.barPanel, -26, 20)
barPanelScroll.ScrollBar.bg = barPanelScroll.ScrollBar:CreateTexture(nil, "BACKGROUND")
barPanelScroll.ScrollBar.bg:SetAllPoints()
barPanelScroll.ScrollBar.bg:SetTexture("interface/buttons/white8x8")
barPanelScroll.ScrollBar.bg:SetVertexColor(0, 0, 0, .2)
barPanelScroll.HScrollBar = CreateFrame("SLIDER", nil, barPanelScroll)
local HScrollBar = barPanelScroll.HScrollBar
HScrollBar:SetOrientation("horizontal")
HScrollBar:SetSize(0, 16)
HScrollBar:SetPoint("TOPLEFT", barPanelScroll, "BOTTOMLEFT", 19, 0)
HScrollBar:SetPoint("TOPRIGHT", barPanelScroll, "BOTTOMRIGHT", -12, 0)
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
barPanelScroll:HookScript("OnScrollRangeChanged", function(self, xrange)
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
barPanelScroll:HookScript("OnHorizontalScroll", function(self, offset)
	local hsb = self.HScrollBar
	local min, max = hsb:GetMinMaxValues()
	hsb.leftBtn:SetEnabled(offset ~= 0)
	hsb.rightBtn:SetEnabled(hsb:GetValue() ~= max)
end)
barPanelScroll.child = CreateFrame("FRAME")
barPanelScroll.child:SetSize(1, 1)
barPanelScroll:SetScrollChild(barPanelScroll.child)

-- BAR COMBOBOX
local barCombobox = lsfdd:CreateButton(barPanelScroll.child, 120)
barCombobox:SetPoint("TOPLEFT", 3, -6)

barCombobox:ddSetInitFunc(function(self)
	local info = {}
	info.list = {}

	local function removeBar(btn)
		main:removeBar(btn.value.name)
	end

	local function selectBar(btn)
		main:setBar(btn.value)
	end

	for i, bar in ipairs(main.pBars) do
		local subInfo = {
			text = bar.isDefault and bar.name.." "..DARKGRAY_COLOR:WrapTextInColorCode(DEFAULT) or bar.name,
			value = bar,
			checked = bar.name == main.currentBar.name,
			func = selectBar,
		}
		if #main.pBars > 1 then
			subInfo.remove = removeBar
		end
		tinsert(info.list, subInfo)
	end
	self:ddAddButton(info)
	info.list = nil

	self:ddAddSeparator()

	info.notCheckable = true
	info.text = L["Add bar"]
	info.func = function() main:createBar() end
	self:ddAddButton(info)

	if not main.currentBar.isDefault then
		info.text = L["Set as default"]
		info.func = function()
			for _, bar in ipairs(main.currentProfile.bars) do
				bar.isDefault = nil
			end
			main.currentBar.isDefault = true
			hb:updateBars()
			main:setBar(main.currentBar)
		end
		self:ddAddButton(info)
	end
end)

-- BUTTON PANEL
main.buttonPanel = CreateFrame("Frame", nil, barPanelScroll.child, "HidingBarAddonPanel")
main.buttonPanel:SetPoint("TOPLEFT", barCombobox, "BOTTOMLEFT", 2, -5)

-------------------------------------------
-- IGNORE TAB PANEL
-------------------------------------------
main.ignoreTabPanel = createTabPanel(buttonsTabs, L["Ignore list"])

-- ADD IGNORE TEXT
local editBoxIgnore = CreateFrame("EditBox", nil, main.ignoreTabPanel, "HidingBarAddonAddTextBox")
editBoxIgnore:SetPoint("TOPLEFT", main.ignoreTabPanel, 15, -9)
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
main.ignoreScroll = CreateFrame("ScrollFrame", "HidingBarAddonIgnoreListScroll", main.ignoreTabPanel, "HidingBarAddonHybridScrollTemplate")
main.ignoreScroll.scrollBar.doNotHide = true
main.ignoreScroll:SetSize(300, 200)
main.ignoreScroll:SetPoint("TOPLEFT", editBoxIgnore, "BOTTOMLEFT", -2, -2)
main.ignoreScroll.update = function(scroll)
	local offset = HybridScrollFrame_GetOffset(scroll)
	local numButtons = #main.pConfig.ignoreMBtn

	for i, btn in ipairs(scroll.buttons) do
		local index = i + offset
		if index <= numButtons then
			btn:SetText(main.pConfig.ignoreMBtn[index]:gsub("%%([%(%)%.%%%+%-%*%?%[%^%$])", "%1"))
			btn.removeButton:SetScript("OnClick", function()
				main:removeIgnoreName(main.pConfig.ignoreMBtn[index])
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

-- IGNORE DESCRIPTION
local ignoreDescription = main.ignoreTabPanel:CreateFontString("ARTWORK", nil, "GameFontHighlight")
ignoreDescription:SetPoint("TOPLEFT", main.ignoreBtn, "TOPRIGHT", 5, 0)
ignoreDescription:SetPoint("BOTTOMRIGHT", main.ignoreTabPanel, -5, 5)
ignoreDescription:SetJustifyH("LEFT")
ignoreDescription:SetText(L["IGNORE_DESCRIPTION"])

-------------------------------------------
-- ADD BUTTONS OPTIONS TAB PANEL
-------------------------------------------
main.addBtnOptionsPanel = createTabPanel(buttonsTabs, L["Options of adding buttons"])

local addBtnOptionsScroll = CreateFrame("ScrollFrame", nil, main.addBtnOptionsPanel, "UIPanelScrollFrameTemplate")
addBtnOptionsScroll:SetPoint("TOPLEFT", main.addBtnOptionsPanel, 4, -6)
addBtnOptionsScroll:SetPoint("BOTTOMRIGHT", main.addBtnOptionsPanel, -26, 5)
addBtnOptionsScroll.ScrollBar.bg = addBtnOptionsScroll.ScrollBar:CreateTexture(nil, "BACKGROUND")
addBtnOptionsScroll.ScrollBar.bg:SetAllPoints()
addBtnOptionsScroll.ScrollBar.bg:SetTexture("interface/buttons/white8x8")
addBtnOptionsScroll.ScrollBar.bg:SetVertexColor(0, 0, 0, .2)
addBtnOptionsScroll.child = CreateFrame("FRAME")
addBtnOptionsScroll.child:SetSize(1, 1)
addBtnOptionsScroll:SetScrollChild(addBtnOptionsScroll.child)

-- ADD FROM DATA BROKER
main.addBtnFromDataBroker = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.addBtnFromDataBroker:SetPoint("TOPLEFT", 4, -2)
main.addBtnFromDataBroker.Text:SetText(L["Add buttons from DataBroker"])
main.addBtnFromDataBroker:SetScript("OnClick", function(btn)
	main.pConfig.addFromDataBroker = btn:GetChecked()
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

-- GRAB DEFAULT BUTTONS
main.grabDefault = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.grabDefault:SetPoint("TOPLEFT", main.addBtnFromDataBroker, "BOTTOMLEFT")
main.grabDefault.Text:SetText(L["Grab default buttons on minimap"])
main.grabDefault:SetScript("OnClick", function(btn)
	main.pConfig.grabDefMinimap = btn:GetChecked()
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

-- GRAB ADDONS BUTTONS
main.grab = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.grab:SetPoint("TOPLEFT", main.grabDefault, "BOTTOMLEFT")
main.grab.Text:SetText(L["Grab addon buttons on minimap"])
main.grab:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	main.pConfig.grabMinimap = checked
	main.grabAfter:SetEnabled(checked)
	main.grabWithoutName:SetEnabled(checked)
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

-- GRAB AFTER N SECOND
main.grabAfter = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.grabAfter:SetPoint("TOPLEFT", main.grab, "BOTTOMLEFT", 20, 0)
main.grabAfter.Text:SetText(L["Try to grab after"])
main.grabAfter:SetHitRectInsets(0, -main.grabAfter.Text:GetWidth(), 0, 0)
main.grabAfter:SetScript("OnClick", function(btn)
	main.pConfig.grabMinimapAfter = btn:GetChecked()
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

main.afterNumber = CreateFrame("EditBox", nil, addBtnOptionsScroll.child, "HidingBarAddonNumberTextBox")
main.afterNumber:SetPoint("LEFT", main.grabAfter.Text, "RIGHT", 3, 0)
main.afterNumber:SetScript("OnTextChanged", function(editBox, userInput)
	if userInput then
		local n = tonumber(editBox:GetText()) or 1
		if n < 1 then n = 1 end
		editBox:SetText(n)
		main.pConfig.grabMinimapAfterN = n
		editBox:HighlightText()
	end
end)

main.grabAfterTextSec = addBtnOptionsScroll.child:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
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

-- GRAB WITHOUT NAME
main.grabWithoutName = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.grabWithoutName:SetPoint("TOPLEFT", main.grabAfter, "BOTTOMLEFT")
main.grabWithoutName.Text:SetText(L["Grab buttons without a name"])
main.grabWithoutName:SetScript("OnClick", function(btn)
	main.pConfig.grabMinimapWithoutName = btn:GetChecked()
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

-- ADD BUTTON MANUALLY
local addButtonManuallyText = addBtnOptionsScroll.child:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
addButtonManuallyText:SetPoint("TOPLEFT", main.grabWithoutName, "BOTTOMLEFT", -13, -15)
addButtonManuallyText:SetText(L["Add button manually"])

-- MANUALLY GRAB EDITBOX
local editBoxGrab = CreateFrame("EditBox", nil, addBtnOptionsScroll.child, "HidingBarAddonAddTextBox")
editBoxGrab:SetWidth(368)
editBoxGrab:SetPoint("TOPLEFT", addButtonManuallyText, 0, -12)
editBoxGrab:SetScript("OnTextChanged", function(editBox)
	local textExists = editBox:GetText() ~= ""
	main.customGrabBtn:SetEnabled(textExists)
	editBox.clearButton:SetShown(editBox:HasFocus() or textExists)
end)
editBoxGrab:SetScript("OnEnterPressed", function(editBox)
	local text = editBox:GetText()
	if text ~= "" then
		main:addCustomGrabName(text)
		editBox:SetText("")
	end
	EditBox_ClearFocus(editBox)
end)

-- CUSTOM GRAB BTN
main.customGrabBtn = CreateFrame("BUTTON", nil, addBtnOptionsScroll.child, "UIPanelButtonTemplate")
main.customGrabBtn:SetSize(80, 22)
main.customGrabBtn:SetPoint("LEFT", editBoxGrab, "RIGHT")
main.customGrabBtn:SetText(ADD)
main.customGrabBtn:Disable()
main.customGrabBtn:SetScript("OnClick", function()
	local text = editBoxGrab:GetText()
	if text ~= "" then
		main:addCustomGrabName(text)
		editBoxGrab:SetText("")
	end
	EditBox_ClearFocus(editBoxGrab)
end)

-- CUSTOM POINT BTN
local coverGreen = CreateFrame("BUTTON")
coverGreen:SetFrameStrata("TOOLTIP")
coverGreen:SetFrameLevel(10000)
coverGreen.bg = coverGreen:CreateTexture(nil, "BACKGROUND")
coverGreen.bg:SetAllPoints()
coverGreen.bg:SetColorTexture(.2, 1, .2, .7)
coverGreen:Hide()
coverGreen:SetScript("OnLeave", function(btn)
	btn:Hide()
end)
coverGreen:SetScript("OnClick", function(btn)
	main:addCustomGrabName(btn.name)
	main.customGrabPointBtn:Click()
end)

local ignoredNames = {
	"StaticPopup.+",
}

main.customGrabPointBtn = CreateFrame("BUTTON", nil, addBtnOptionsScroll.child, "UIPanelButtonTemplate")
main.customGrabPointBtn:SetSize(120, 22)
main.customGrabPointBtn:SetPoint("LEFT", main.customGrabBtn, "RIGHT")
main.customGrabPointBtn:SetText(L["Point to button"])
main.customGrabPointBtn:SetScript("OnUpdate", function(btn)
	if not btn.isPoint then return end
	local focus = GetMouseFocus()
	if focus then
		local name = focus:GetName()
		if name and not focus:IsProtected() and (focus:HasScript("OnClick") and focus:GetScript("OnClick")
			or focus:HasScript("OnMouseUp") and focus:GetScript("OnMouseUp")
			or focus:HasScript("OnMouseDown") and focus:GetScript("OnMouseDown"))
		then
			for i = 1, #ignoredNames do
				if name:match(ignoredNames[i]) then return end
			end

			for i = 1, #hb.bars do
				local bar = hb.bars[i]
				if bar:IsShown() and bar:IsMouseOver() then return end
			end

			coverGreen.name = name
			coverGreen:SetAllPoints(focus)
			coverGreen:Show()
		end
	end
end)
main.customGrabPointBtn:SetScript("OnHide", function(btn)
	if btn.isPoint then btn:Click() end
end)
main.customGrabPointBtn:SetScript("OnClick", function(btn)
	if btn.isPoint then
		btn.isPoint = nil
		btn:SetText(L["Point to button"])
	else
		btn.isPoint = true
		btn:SetText(CANCEL)
	end
end)

-- CUSTOM GRAB SCROLL
main.customGrabScroll = CreateFrame("ScrollFrame", "HidingBarAddonCustomGrabScroll", addBtnOptionsScroll.child, "HidingBarAddonHybridScrollTemplate")
main.customGrabScroll.scrollBar.doNotHide = true
main.customGrabScroll:SetSize(545, 195)
main.customGrabScroll:SetPoint("TOPLEFT", editBoxGrab, "BOTTOMLEFT", -2, -2)
main.customGrabScroll.update = function(scroll)
	local offset = HybridScrollFrame_GetOffset(scroll)
	local numButtons = #main.pConfig.customGrabList

	for i, btn in ipairs(scroll.buttons) do
		local index = i + offset
		if index <= numButtons then
			btn:SetText(main.pConfig.customGrabList[index])
			btn.removeButton:SetScript("OnClick", function()
				main:removeCustomGrabName(main.pConfig.customGrabList[index])
			end)
			btn:Enable()
		else
			btn:SetText(EMPTY)
			btn:Disable()
		end
	end

	HybridScrollFrame_Update(scroll, scroll.buttonHeight * numButtons, scroll:GetHeight())
end
HybridScrollFrame_CreateButtons(main.customGrabScroll, "HidingBarAddonCustomGrabButtonTemplate")

-------------------------------------------
-- BAR SETTINGS TAB PANEL
-------------------------------------------
main.barSettingsPanel = createTabPanel(barSettingsTabs, L["Bar settings"])
main.barSettingsPanel:SetPoint("TOPLEFT", main.barPanel, "BOTTOMLEFT", 0, -25)
main.barSettingsPanel:SetPoint("BOTTOMRIGHT", main, -8, 8)

-- RELOAD BUTTON
local reloadBtn = CreateFrame("BUTTON", nil, main, "UIPanelButtonTemplate")
reloadBtn:SetSize(96, 22)
reloadBtn:SetPoint("BOTTOMRIGHT", main.barSettingsPanel, "TOPRIGHT")
reloadBtn:SetText(RELOADUI)
reloadBtn:SetScript("OnClick", function()
	ReloadUI()
end)

-- EXPAND TO TEXT
local expandToText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
expandToText:SetPoint("TOPRIGHT", -10, -8)
expandToText:SetWidth(114)
expandToText:SetText(L["Expand to"])

-- EXPAND TO COMBOBOX
local expandToCombobox = lsfdd:CreateButton(main.barSettingsPanel, 120)
expandToCombobox:SetPoint("TOPRIGHT", expandToText, "BOTTOMRIGHT", 2, -5)
expandToCombobox.texts = {[0] = L["Right / Bottom"], L["Left / Top"], L["Both direction"]}

local function updateExpandTo(btn)
	expandToCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setBarExpand(btn.value)
	main:hidingBarUpdate()
end

expandToCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = updateExpandTo
		self:ddAddButton(info)
	end
end)

-- LINE COLOR
local lineColor = CreateFrame("BUTTON", nil, main.barSettingsPanel, "HidingBarAddonColorButton")
lineColor:SetPoint("TOPRIGHT", expandToCombobox, "BOTTOMRIGHT", -3, -7)
local lineColorText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
lineColorText:SetPoint("RIGHT", lineColor, "LEFT", -3, 0)
lineColorText:SetJustifyH("RIGHT")
lineColorText:SetText(L["Line"])

lineColor.swatchFunc = function()
	main.barFrame:setLineColor(ColorPickerFrame:GetColorRGB())
	local hexColor = toHex(main.bConfig.lineColor)
	main.description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))
	main.fade.Text:SetText(L["Fade out line"]:format(hexColor))
	main.lineWidth.text:SetText(L["Line width"]:format(hexColor))
	lineColor.color:SetColorTexture(unpack(main.bConfig.lineColor))
	main:hidingBarUpdate()
end
lineColor.cancelFunc = function(color)
	main.barFrame:setLineColor(color.r, color.g, color.b)
	local hexColor = toHex(main.bConfig.lineColor)
	main.description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))
	main.fade.Text:SetText(L["Fade out line"]:format(hexColor))
	main.lineWidth.text:SetText(L["Line width"]:format(hexColor))
	lineColor.color:SetColorTexture(unpack(main.bConfig.lineColor))
	main:hidingBarUpdate()
end
lineColor:SetScript("OnClick", function(btn)
	if ColorPickerFrame:IsShown() and ColorPickerFrame.cancelFunc then
		ColorPickerFrame.cancelFunc(ColorPickerFrame.previousValues)
		HideUIPanel(ColorPickerFrame)
	end
	btn.r, btn.g, btn.b = unpack(main.bConfig.lineColor)
	OpenColorPicker(btn)
end)

-- BACKGROUND COLOR
local bgColor = CreateFrame("BUTTON", nil, main.barSettingsPanel, "HidingBarAddonColorButton")
bgColor:SetPoint("TOPRIGHT", lineColor, "BOTTOMRIGHT", 0, -3)
local bgColorText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
bgColorText:SetPoint("RIGHT", bgColor, "LEFT", -3, 0)
bgColorText:SetJustifyH("RIGHT")
bgColorText:SetText(L["Background"])

bgColor.hasOpacity = true
bgColor.swatchFunc = function()
	main.barFrame:setBackgroundColor(ColorPickerFrame:GetColorRGB())
	main.buttonPanel.bg:SetVertexColor(unpack(main.bConfig.bgColor))
	bgColor.color:SetColorTexture(unpack(main.bConfig.bgColor))
	main:hidingBarUpdate()
end
bgColor.opacityFunc = function()
	main.barFrame:setBackgroundColor(nil, nil, nil, OpacitySliderFrame:GetValue())
	main.buttonPanel.bg:SetVertexColor(unpack(main.bConfig.bgColor))
	bgColor.color:SetColorTexture(unpack(main.bConfig.bgColor))
	main:hidingBarUpdate()
end
bgColor.cancelFunc = function(color)
	main.barFrame:setBackgroundColor(color.r, color.g, color.b, color.opacity)
	main.buttonPanel.bg:SetVertexColor(unpack(main.bConfig.bgColor))
	bgColor.color:SetColorTexture(unpack(main.bConfig.bgColor))
	main:hidingBarUpdate()
end
bgColor:SetScript("OnClick", function(btn)
	if ColorPickerFrame:IsShown() and ColorPickerFrame.cancelFunc then
		ColorPickerFrame.cancelFunc(ColorPickerFrame.previousValues)
		HideUIPanel(ColorPickerFrame)
	end
	btn.r, btn.g, btn.b, btn.opacity = unpack(main.bConfig.bgColor)
	OpenColorPicker(btn)
end)

-- DESCRIPTION
main.description = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
main.description:SetPoint("TOPLEFT", 8, -10)
main.description:SetJustifyH("LEFT")
local locale = GetLocale()
if locale == "zhTW" or locale == "zhCN" then
	main.description:SetFont(main.description:GetFont(), 12)
end

-- ORIENTATION TEXT
local orientationText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
orientationText:SetPoint("TOPLEFT", main.description, "BOTTOMLEFT", 0, -23)
orientationText:SetText(L["Orientation"])

-- ORIENTATION COMBOBOX
local orientationCombobox = lsfdd:CreateButton(main.barSettingsPanel, 120)
orientationCombobox:SetPoint("LEFT", orientationText, "RIGHT", 3, 0)
orientationCombobox.texts = {[0] = L["Auto"], L["Horizontal"], L["Vertical"]}

local function orientationChange(btn)
	orientationCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setOrientation(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

orientationCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = orientationChange
		self:ddAddButton(info)
	end
end)

-- FRAME STARTA TEXT
local fsText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
fsText:SetPoint("LEFT", orientationCombobox, "RIGHT", 10, 0)
fsText:SetText(L["Strata of panel"])

-- FRAME STRATA COMBOBOX
local fsCombobox = lsfdd:CreateButton(main.barSettingsPanel, 120)
fsCombobox:SetPoint("LEFT", fsText, "RIGHT", 3, 0)
fsCombobox.texts = {[0] = "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"}

local function fsChange(btn)
	fsCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setFrameStrata(btn.value)
end

fsCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = fsChange
		self:ddAddButton(info)
	end
end)

-- LOCK
local lock = CreateFrame("CheckButton", nil, main.barSettingsPanel, "HidingBarAddonCheckButtonTemplate")
lock:SetPoint("TOPLEFT", orientationText, "BOTTOMLEFT", 0, -10)
lock.Text:SetText(L["Lock the bar's location"])
lock:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	main.barFrame:setLocked(checked)
end)
hb:on("LOCK_UPDATED", function(_, isLocked, bar)
	if main.barFrame == bar then
		lock:SetChecked(isLocked)
	end
end)

-- FADE
main.fade = CreateFrame("CheckButton", nil, main.barSettingsPanel, "HidingBarAddonCheckButtonTemplate")
main.fade:SetPoint("TOPLEFT", lock, "BOTTOMLEFT", 0, 0)
main.fade:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	main.fadeOpacity:SetEnabled(checked)
	main.barFrame:setFade(checked)
end)

-- FADE OPACITY
main.fadeOpacity = CreateFrame("SLIDER", nil, main.barSettingsPanel, "HidingBarAddonSliderTemplate")
main.fadeOpacity:SetPoint("LEFT", main.fade.Text, "RIGHT", 20, 0)
main.fadeOpacity:SetPoint("RIGHT", -49, 0)
main.fadeOpacity:SetMinMaxValues(0, .95)
main.fadeOpacity.step = 1 / .05
main.fadeOpacity.text:SetText(L["Opacity"])
main.fadeOpacity.edit:SetMaxLetters(4)
main.fadeOpacity:SetScript("OnValueChanged", function(slider, value, userInput)
	if not userInput then return end
	value = math.floor(value * slider.step + .5) / slider.step
	main.barFrame:setFadeOpacity(value)
	slider:SetValue(value)
end)

-- LINE WIDTH
main.lineWidth = CreateFrame("SLIDER", nil, main.barSettingsPanel, "HidingBarAddonSliderTemplate")
main.lineWidth:SetPoint("TOPLEFT", main.fade, "BOTTOMLEFT", 0, -15)
main.lineWidth:SetPoint("RIGHT", -35, 0)
main.lineWidth:SetMinMaxValues(4, 20)
main.lineWidth.edit:SetMaxLetters(2)
main.lineWidth:SetScript("OnValueChanged", function(slider, value, userInput)
	if not userInput then return end
	value = math.floor(value + .5)
	main.barFrame:setLineWidth(value)
	slider:SetValue(value)
end)

-- SHOW HANDLER TEXT
local showHandlerText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
showHandlerText:SetPoint("TOPLEFT", main.lineWidth, "BOTTOMLEFT", 0, -20)
showHandlerText:SetText(L["Show on"])

-- SHOW HANDLER
local showHandlerCombobox = lsfdd:CreateButton(main.barSettingsPanel, 120)
showHandlerCombobox:SetPoint("LEFT", showHandlerText, "RIGHT", 3, 0)
showHandlerCombobox.texts = {[0] = L["Hover"], L["Click"], L["Hover or Click"], L["Allways"]}

local function updateShowHandler(btn)
	showHandlerCombobox:ddSetSelectedValue(btn.value)
	main.barFrame.drag:setShowHandler(btn.value)
end

showHandlerCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = updateShowHandler
		self:ddAddButton(info)
	end
end)

-- DELAY TO SHOW
local delayToShowText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
delayToShowText:SetPoint("LEFT", showHandlerCombobox, "RIGHT", 10, 0)
delayToShowText:SetText(L["Delay to show"])

local delayToShowEditBox = CreateFrame("EditBox", nil, main.barSettingsPanel, "HidingBarAddonDecimalTextBox")
delayToShowEditBox:SetPoint("LEFT", delayToShowText, "RIGHT", 2, 0)
delayToShowEditBox:SetScript("OnTextChanged", function(editBox, userInput)
	if userInput then
		local int, dec = editBox:GetText():gsub(",", "."):match("(%d*)(%.?%d*)")
		if int == "" and dec ~= "" then int = "0" end
		local decimalText = int..dec
		editBox:SetNumber(decimalText)
		main.bConfig.showDelay = tonumber(decimalText) or 0
	end
end)
delayToShowEditBox:SetScript("OnEditFocusLost", function(editBox)
	editBox:SetNumber(main.bConfig.showDelay)
	editBox:HighlightText(0, 0)
end)

-- DELAY TO HIDE
local delayToHideText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
delayToHideText:SetPoint("LEFT", delayToShowEditBox, "RIGHT", 10, 0)
delayToHideText:SetText(L["Delay to hide"])

local delayToHideEditBox = CreateFrame("EditBox", nil, main.barSettingsPanel, "HidingBarAddonDecimalTextBox")
delayToHideEditBox:SetPoint("LEFT", delayToHideText, "RIGHT", 2, 0)
delayToHideEditBox:SetScript("OnTextChanged", function(editBox, userInput)
	if userInput then
		local int, dec = editBox:GetText():gsub(",", "."):match("(%d*)(%.?%d*)")
		if int == "" and dec ~= "" then int = "0" end
		local decimalText = int..dec
		editBox:SetNumber(decimalText)
		main.bConfig.hideDelay = tonumber(decimalText) or 0
	end
end)
delayToHideEditBox:SetScript("OnEditFocusLost", function(editBox)
	editBox:SetNumber(main.bConfig.hideDelay)
	editBox:HighlightText(0, 0)
end)

-------------------------------------------
-- BUTTON SETTINGS TAB PANEL
-------------------------------------------
main.buttonSettingsPanel =  createTabPanel(barSettingsTabs, L["Button settings"])

-- SLIDER NUMBER BUTTONS IN ROW
local buttonNumber = CreateFrame("SLIDER", nil, main.buttonSettingsPanel, "HidingBarAddonSliderTemplate")
buttonNumber:SetPoint("TOPLEFT", 8, -20)
buttonNumber:SetPoint("RIGHT", -35, 0)
buttonNumber:SetMinMaxValues(1, 30)
buttonNumber.text:SetText(L["Number of buttons"])
buttonNumber.edit:SetMaxLetters(2)
buttonNumber:SetScript("OnValueChanged", function(slider, value, userInput)
	if not userInput then return end
	value = math.floor(value + .5)
	slider:SetValue(value)
	if main.bConfig.size ~= value then
		main.barFrame:setMaxButtons(value)
		main:applyLayout(.3)
		main:hidingBarUpdate()
	end
end)

-- SLIDER BUTTONS SIZE
local buttonSize = CreateFrame("SLIDER", nil, main.buttonSettingsPanel, "HidingBarAddonSliderTemplate")
buttonSize:SetPoint("TOPLEFT", buttonNumber, "BOTTOMLEFT", 0, -18)
buttonSize:SetPoint("RIGHT", -35, 0)
buttonSize:SetMinMaxValues(16, 64)
buttonSize.text:SetText(L["Buttons Size"])
buttonSize.edit:SetMaxLetters(2)
buttonSize:SetScript("OnValueChanged", function(slider, value, userInput)
	if not userInput then return end
	value = math.floor(value + .5)
	slider:SetValue(value)
	if main.bConfig.buttonSize ~= value then
		main.barFrame:setButtonSize(value)
		main:setButtonSize()
		main:applyLayout()
		main:hidingBarUpdate()
	end
end)

-- SLIDER DISTANCE TO BAR BORDER
local barOffset =  CreateFrame("SLIDER", nil, main.buttonSettingsPanel, "HidingBarAddonSliderTemplate")
barOffset:SetPoint("TOPLEFT", buttonSize, "BOTTOMLEFT", 0, -18)
barOffset:SetPoint("RIGHT", -35, 0)
barOffset:SetMinMaxValues(0, 20)
barOffset.text:SetText(L["Distance to bar border"])
barOffset.edit:SetMaxLetters(2)
barOffset:SetScript("OnValueChanged", function(slider, value, userInput)
	if not userInput then return end
	value = math.floor(value + .5)
	slider:SetValue(value)
	if main.bConfig.barOffset ~= value then
		main.barFrame:setBarOffset(value)
		main:applyLayout()
		main:hidingBarUpdate()
	end
end)

-- SLIDER DISTANCE BETWEEN BUTTONS
local rangeBetweenBtns = CreateFrame("SLIDER", nil, main.buttonSettingsPanel, "HidingBarAddonSliderTemplate")
rangeBetweenBtns:SetPoint("TOPLEFT", barOffset, "BOTTOMLEFT", 0, -18)
rangeBetweenBtns:SetPoint("RIGHT", -35, 0)
rangeBetweenBtns:SetMinMaxValues(-5, 30)
rangeBetweenBtns.text:SetText(L["Distance between buttons"])
rangeBetweenBtns.edit:SetMaxLetters(2)
rangeBetweenBtns:SetScript("OnValueChanged", function(slider, value, userInput)
	if not userInput then return end
	value = math.floor(value + .5)
	slider:SetValue(value)
	if main.bConfig.rangeBetweenBtns ~= value then
		main.barFrame:setRangeBetweenBtns(value)
		main:applyLayout()
		main:hidingBarUpdate()
	end
end)

-- POSTION OF MINIMAP BUTTON TEXT
local mbtnPostionText = main.buttonSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
mbtnPostionText:SetPoint("TOPLEFT", rangeBetweenBtns, "BOTTOMLEFT", 0, -20)
mbtnPostionText:SetText(L["Position of minimap buttons"])

-- POSITION OF MINIMAP BUTTON
local mbtnPostionCombobox = lsfdd:CreateButton(main.buttonSettingsPanel, 120)
mbtnPostionCombobox:SetPoint("LEFT", mbtnPostionText, "RIGHT", 3, 0)
mbtnPostionCombobox.texts = {[0] = L["A new line"], L["Followed"], L["Mixed"]}

local function updateMBtnPostion(btn)
	mbtnPostionCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setMBtnPosition(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

mbtnPostionCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = updateMBtnPostion
		self:ddAddButton(info)
	end
end)

-- DIRECTION OF BUTTONS
local buttonDirection = lsfdd:CreateStretchButton(main.buttonSettingsPanel, 150, 22)
buttonDirection:SetPoint("LEFT", mbtnPostionCombobox, "RIGHT", 10, 1)
buttonDirection:SetText(L["Direction of buttons"])

buttonDirection:ddSetInitFunc(function(self, level)
	local info = {}

	local function setDirection(btn, ...)
		main.barFrame:setButtonDirection(...)
		main.barFrame:applyLayout()
		main:applyLayout(.3)
		main:hidingBarUpdate()
		self:ddRefresh()
	end

	info.keepShownOnClick = true
	info.isTitle = true
	info.notCheckable = true
	info.text = L["Horizontal"]
	self:ddAddButton(info)

	info.isTitle = nil
	info.notCheckable = nil

	for i, text in ipairs({L["Auto"], L["Left to right"], L["Right to left"]}) do
		i = i - 1
		info.text = text
		info.arg1 = "H"
		info.arg2 = i
		info.checked = function() return main.bConfig.buttonDirection.H == i end
		info.func = setDirection
		self:ddAddButton(info)
	end

	self:ddAddSpace()

	info.checked = nil
	info.func = nil
	info.isTitle = true
	info.notCheckable = true
	info.text = L["Vertical"]
	self:ddAddButton(info)

	info.isTitle = nil
	info.notCheckable = nil

	for i, text in ipairs({L["Auto"], L["Top to bottom"], L["Bottom to top"]}) do
		i = i - 1
		info.text = text
		info.arg1 = "V"
		info.arg2 = i
		info.checked = function() return main.bConfig.buttonDirection.V == i end
		info.func = setDirection
		self:ddAddButton(info)
	end
end)

-- INTERCEPT THE POSITION OF TOOLTIPS
local interceptTooltip = CreateFrame("CheckButton", nil, main.buttonSettingsPanel, "HidingBarAddonCheckButtonTemplate")
interceptTooltip:SetPoint("TOPLEFT", mbtnPostionText, "BOTTOMLEFT", 0, -10)
interceptTooltip.Text:SetText(L["Intercept the position of tooltips"])
interceptTooltip:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	main.bConfig.interceptTooltip = checked
end)

-------------------------------------------
-- POSITION BAR PANEL
-------------------------------------------
main.positionBarPanel = createTabPanel(barSettingsTabs, L["Bar position"])

local function updateBarTypePosition()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	main.attachedToSide.check:SetShown(main.bConfig.barTypePosition == 0)
	main.freeMove.check:SetShown(main.bConfig.barTypePosition == 1)
	main.hideToCombobox:SetEnabled(main.bConfig.barTypePosition == 1)
	main.coordX:SetEnabled(main.bConfig.barTypePosition == 1)
	main.coordY:SetEnabled(main.bConfig.barTypePosition == 1)
	main.likeMB.check:SetShown(main.bConfig.barTypePosition == 2)
	main.ombShowToCombobox:SetEnabled(main.bConfig.barTypePosition == 2)
	main.ombSize:SetEnabled(main.bConfig.barTypePosition == 2)
	main.canGrabbed:SetEnabled(main.bConfig.barTypePosition == 2)
end

-- BAR ATTACHED TO THE SIDE
main.attachedToSide = CreateFrame("BUTTON", nil, main.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
main.attachedToSide:SetPoint("TOPLEFT", 8, -8)
main.attachedToSide.Text:SetText(L["Bar attached to the side"])
main.attachedToSide:SetScript("OnClick", function()
	main.barFrame:setBarCoords(nil, 0)
	main.barFrame:setBarTypePosition(0)
	main:applyLayout(.3)
	if main.barFrame.omb and main.barFrame.omb.isGrabbed then
		for i, btn in ipairs(main.mbuttons) do
			if btn.rButton == main.barFrame.omb then
				main:removeMButton(btn, i)
				break
			end
		end
	end
	hb:updateBars()
	updateBarTypePosition()
	main:hidingBarUpdate()
end)

-- BAR MOVES FREELY
main.freeMove = CreateFrame("BUTTON", nil, main.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
main.freeMove:SetPoint("TOPLEFT", main.attachedToSide, "BOTTOMLEFT")
main.freeMove.Text:SetText(L["Bar moves freely"])
main.freeMove:SetScript("OnClick", function()
	main.barFrame:setBarTypePosition(1)
	main:applyLayout(.3)
	if main.barFrame.omb and main.barFrame.omb.isGrabbed then
		for i, btn in ipairs(main.mbuttons) do
			if btn.rButton == main.barFrame.omb then
				main:removeMButton(btn, i)
				break
			end
		end
	end
	hb:updateBars()
	updateBarTypePosition()
	main:hidingBarUpdate()
end)

-- HIDE TO
main.hideToCombobox = lsfdd:CreateButton(main.positionBarPanel, 120)
main.hideToCombobox:SetPoint("TOPLEFT", main.freeMove, "BOTTOMLEFT", 23, -3)
main.hideToCombobox.texts = {
	left = L["Hiding to left"],
	right = L["Hiding to right"],
	top = L["Hiding to up"],
	bottom = L["Hiding to down"],
}

local function updateBarAnchor(btn)
	main.hideToCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setBarAnchor(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

main.hideToCombobox:ddSetInitFunc(function(self)
	local info = {}
	for _, value in ipairs({"left", "right", "top", "bottom"}) do
		info.text = self.texts[value]
		info.value = value
		info.func = updateBarAnchor
		self:ddAddButton(info)
	end
end)
hb:on("ANCHOR_UPDATED", function(_, value, bar)
	if main.barFrame == bar then
		main.hideToCombobox:ddSetSelectedValue(value)
		main.hideToCombobox:ddSetSelectedText(main.hideToCombobox.texts[value])
		main:applyLayout(.3)
	end
end)

-- COORD X
main.coordXText = main.positionBarPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
main.coordXText:SetPoint("LEFT", main.hideToCombobox, "RIGHT", 10, 1)
main.coordXText:SetText("X")

main.coordX = CreateFrame("EditBox", nil, main.positionBarPanel, "HidingBarAddonCoordTextBox")
main.coordX:SetPoint("LEFT", main.coordXText, "RIGHT", 1, 0)
main.coordX:SetScript("OnTextChanged", function(editBox, userInput)
	if userInput then
		editBox:SetNumber(editBox:GetText():match("%-?%d*"))
	end
end)
main.coordX.setX = function(editBox, x)
	if main.bConfig.anchor == "left" or main.bConfig.anchor == "right" then
		main.barFrame:setBarCoords(nil, x)
	else
		main.barFrame:setBarCoords(x)
	end
	main.barFrame:updateBarPosition()
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
	if main.bConfig.anchor == "left" or main.bConfig.anchor == "right" then
		main.barFrame:setBarCoords(y)
	else
		main.barFrame:setBarCoords(nil, y)
	end
	main.barFrame:updateBarPosition()
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
main.likeMB:SetPoint("TOPLEFT", main.hideToCombobox, "BOTTOMLEFT", -23, -4)
main.likeMB.Text:SetText(L["Bar like a minimap button"])
main.likeMB:SetScript("OnClick", function()
	main.barFrame:setBarTypePosition(2)
	main:applyLayout(.3)
	if main.bConfig.omb.canGrabbed and not main.barFrame.omb.isGrabbed then
		if hb:grabOwnButton(main.barFrame.omb) then
			hb:sort()
			main.barFrame.omb:GetParent():setButtonSize()
		end
	end
	updateBarTypePosition()
	main:hidingBarUpdate()
end)

-- MINIMAP BUTTON SHOW TO
main.ombShowToCombobox = lsfdd:CreateButton(main.positionBarPanel, 120)
main.ombShowToCombobox:SetPoint("TOPLEFT", main.likeMB, "BOTTOMLEFT", 23, -3)
main.ombShowToCombobox.texts = {
	right = L["Show to left"],
	left = L["Show to right"],
	bottom = L["Show to up"],
	top = L["Show to down"],
}

local function mbShowToChange(btn)
	main.ombShowToCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setOMBAnchor(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

main.ombShowToCombobox:ddSetInitFunc(function(self)
	local info = {}
	for _, value in ipairs({"right", "left", "bottom", "top"}) do
		info.text = self.texts[value]
		info.value = value
		info.func = mbShowToChange
		self:ddAddButton(info)
	end
end)

-- SLIDER MINIMAP BUTTON SIZE
main.ombSize = CreateFrame("SLIDER", nil, main.positionBarPanel, "HidingBarAddonSliderTemplate")
main.ombSize:SetPoint("LEFT", main.ombShowToCombobox, "RIGHT", 10, 0)
main.ombSize:SetPoint("RIGHT", -35, 0)
main.ombSize:SetMinMaxValues(16, 64)
main.ombSize.text:SetText(L["Button Size"])
main.ombSize.edit:SetMaxLetters(2)
main.ombSize:SetScript("OnValueChanged", function(slider, value, userInput)
	if not userInput then return end
	value = math.floor(value + .5)
	slider:SetValue(value)
	if main.bConfig.omb.size ~= value then
		main.barFrame:setOMBSize(value)
		main.barFrame:setBarTypePosition()
	end
end)

-- THE BUTTON CAN BE CRABBED
main.canGrabbed = CreateFrame("CheckButton", nil, main.positionBarPanel, "HidingBarAddonCheckButtonTemplate")
main.canGrabbed:SetPoint("TOPLEFT", main.ombShowToCombobox, "BOTTOMLEFT", -2, -2)
main.canGrabbed.Text:SetText(L["The button can be grabbed"])
main.canGrabbed.tooltipText = L["If a suitable bar exists then the button will be grabbed"]
main.canGrabbed:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	local omb = main.barFrame.omb
	main.bConfig.omb.canGrabbed = btn:GetChecked()
	if checked then
		main.pConfig.ombGrabQueue[#main.pConfig.ombGrabQueue + 1] = main.barFrame.id
		if hb:grabOwnButton(omb) then
			hb:sort()
			omb:GetParent():setButtonSize()
		end
	else
		main:removeOmbGrabQueue(main.barFrame.id)
		for i, btn in ipairs(main.mbuttons) do
			if btn.rButton == omb then
				main:removeMButton(btn, i)
				break
			end
		end
		hb:updateBars()
	end
	main:hidingBarUpdate()
end)

-- CONTEXT MENU
local contextmenu = lsfdd:SetMixin({})
contextmenu:ddSetDisplayMode("menu")
contextmenu:ddHideWhenButtonHidden(main.buttonPanel)

contextmenu:ddSetInitFunc(function(self, level, btn)
	local info = {}

	if level == 1 then
		info.notCheckable = true
		info.keepShownOnClick = true
		info.hasArrow = true
		info.text = L["Move to"]
		info.value = btn
		self:ddAddButton(info, level)

		info.notCheckable = nil
		info.isNotRadio = true
		info.hasArrow = nil
		info.text = DISABLE
		info.checked = btn.settings[1]
		info.func = function()
			btn.settings[1] = not btn.settings[1]
			btn:SetChecked(btn.settings[1])
			main.barFrame:applyLayout()
			main:hidingBarUpdate()
		end
		self:ddAddButton(info, level)

		info.text = L["Clip button"]
		info.checked = btn.settings[4]
		info.func = function(_,_,_, checked)
			btn.settings[4] = checked and true or nil
			hb:setClipButtons()
		end
		info.OnTooltipShow = function(_, tooltip)
			tooltip:AddLine(L["Prevents button elements from going over the edges."], nil, nil, nil, true)
		end
		self:ddAddButton(info, level)

		info.notCheckable = true
		info.keepShownOnClick = nil
		info.OnTooltipShow = nil
		info.checked = nil

		if btn.toIgnore then
			info.text = L["Add to ignore list"]
			info.func = function()
				StaticPopup_Show(main.addonName.."ADD_IGNORE_MBTN", NORMAL_FONT_COLOR:WrapTextInColorCode(btn.name), nil, function()
					main:addIgnoreName(btn.name)
				end)
			end
			self:ddAddButton(info, level)
		end

		info.text = CANCEL
		info.func = function() self:ddCloseMenus() end
		self:ddAddButton(info, level)
	else
		info.list = {}

		local function moveTo(menu)
			local bar = menu.value
			if bar.isDefault then
				btn.settings[3] = nil
			else
				btn.settings[3] = bar.name
			end
			hb:updateBars()
			main:hidingBarUpdate()
			main:setBar(main.currentBar)
		end

		for i, bar in ipairs(main.currentProfile.bars) do
			if bar ~= main.currentBar
			and not (btn.name:match(hb.matchName)
				and hb:isBarParent(btn.rButton, hb.barByName[bar.name]))
			then
				tinsert(info.list, {
					notCheckable = true,
					text = bar.name,
					value = bar,
					func = moveTo
				})
			end
		end

		if #info.list == 0 then
			info.list[1] = {
				notCheckable = true,
				disabled = true,
				text = EMPTY,
			}
		end

		self:ddAddButton(info, level)
	end
end)


-- METHODS
local function copyTable(t)
	local n = {}
	for k, v in pairs(t) do
		n[k] = type(v) == "table" and copyTable(v) or v
	end
	return n
end


function main:createProfile(copy)
	local dialog = StaticPopup_Show(self.addonName.."NEW_PROFILE", nil, nil, function(popup)
		local text = popup.editBox:GetText()
		if text and text ~= "" then
			for _, profile in ipairs(hb.profiles) do
				if profile.name == text then
					self.lastProfileName = text
					StaticPopup_Show(self.addonName.."PROFILE_EXISTS", nil, nil, copy)
					return
				end
			end
			local profile = copy and copyTable(self.currentProfile) or {}
			profile.name = text
			profile.isDefault = nil
			hb:checkProfile(profile)
			tinsert(hb.profiles, profile)
			sort(hb.profiles, function(a, b) return a.name < b.name end)
			hb:setProfile(text)
			self:setProfile()
			self:hidingBarUpdate()
		end
	end)
	if dialog and self.lastProfileName then
		dialog.editBox:SetText(self.lastProfileName)
		dialog.editBox:HighlightText()
		self.lastProfileName = nil
	end
end


function main:removeProfile(profileName)
	StaticPopup_Show(self.addonName.."DELETE_PROFILE", NORMAL_FONT_COLOR:WrapTextInColorCode(profileName), nil, function()
		for i, profile in ipairs(hb.profiles) do
			if profile.name == profileName then
				tremove(hb.profiles, i)
				if profile.isDefault then
					hb.profiles[1].isDefault = true
				end
				break
			end
		end
		if self.currentProfile.name == profileName then
			hb:setProfile()
			self:setProfile()
		end
	end)
end


function main:setProfile()
	local currentProfileName, currentProfile, default = hb.charDB.currentProfileName

	for _, profile in ipairs(hb.profiles) do
		if profile.name == currentProfileName then
			currentProfile = profile
			break
		end
		if profile.isDefault then
			default = profile
		end
	end
	currentProfile = currentProfile or default

	if self.currentProfile then
		local compareCustomGrabList = false
		if #self.pConfig.customGrabList ~= #currentProfile.config.customGrabList then
			compareCustomGrabList = true
		else
			for i, name in ipairs(self.pConfig.customGrabList) do
				if name:match(hb.matchName) or name ~= currentProfile.config.customGrabList[i] then
					compareCustomGrabList = true
					break
				end
			end
		end

		if compareCustomGrabList
		or self.pConfig.addFromDataBroker ~= currentProfile.config.addFromDataBroker
		or not self.pConfig.grabDefMinimap ~= not currentProfile.config.grabDefMinimap
		or self.pConfig.grabMinimap ~= currentProfile.config.grabMinimap
		or self.pConfig.grabMinimap and
			(not self.pConfig.grabMinimapWithoutName ~= not currentProfile.config.grabMinimapWithoutName
			or not self.pConfig.grabMinimapAfter ~= not currentProfile.config.grabMinimapAfter
			or self.pConfig.grabMinimapAfter and self.pConfig.grabMinimapAfterN ~= currentProfile.config.grabMinimapAfterN)
		then
			StaticPopup_Show(self.addonName.."GET_RELOAD")
		end
	end

	self.currentProfile = currentProfile
	self.pConfig = self.currentProfile.config
	self.pBars = self.currentProfile.bars
	profilesCombobox:SetText(self.currentProfile.name)

	for _, btn in ipairs(self.buttons) do
		btn.settings = self.pConfig.btnSettings[btn.title]
	end

	local i = 1
	local btn = self.mbuttons[i]
	while btn do
		if btn.name:match(hb.matchName) and not btn.rButton.isGrabbed then
			self:removeMButton(btn, i)
		else
			btn.settings = self.pConfig.mbtnSettings[btn.name]
			i = i + 1
		end
		btn = self.mbuttons[i]
	end

	self.ignoreScroll:update()
	self.addBtnFromDataBroker:SetChecked(self.pConfig.addFromDataBroker)
	self.grabDefault:SetChecked(self.pConfig.grabDefMinimap)
	self.grab:SetChecked(self.pConfig.grabMinimap)
	self.grabAfter:SetChecked(self.pConfig.grabMinimapAfter)
	self.afterNumber:SetText(self.pConfig.grabMinimapAfterN)
	self.grabAfter:SetEnabled(self.pConfig.grabMinimap)
	self.grabWithoutName:SetEnabled(self.pConfig.grabMinimap)
	self.grabWithoutName:SetChecked(self.pConfig.grabMinimapWithoutName)
	self.customGrabScroll:update()

	self:sort(self.buttons)
	self:sort(self.mbuttons)
	self:sort(self.mixedButtons)
	self:setBar()
end


function main:createBar()
	local dialog = StaticPopup_Show(self.addonName.."NEW_BAR", nil, nil, function(popup)
		local text = popup.editBox:GetText()
		if text and text ~= "" then
			for _, bar in ipairs(self.currentProfile.bars) do
				if bar.name == text then
					self.lastBarName = text
					StaticPopup_Show(self.addonName.."BAR_EXISTS")
					return
				end
			end
			local bar = {name = text}
			tinsert(self.currentProfile.bars, bar)
			hb:checkProfile(self.currentProfile)
			hb:updateBars()
			sort(self.currentProfile.bars, function(a, b) return a.name < b.name end)
		end
	end)
	if dialog and self.lastBarName then
		dialog.editBox:SetText(self.lastBarName)
		dialog.editBox:HighlightText()
		self.lastBarName = nil
	end
end


function main:removeBar(barName)
	StaticPopup_Show(self.addonName.."DELETE_BAR", NORMAL_FONT_COLOR:WrapTextInColorCode(barName), nil, function()
		local barID
		for i, bar in ipairs(self.currentProfile.bars) do
			if bar.name == barName then
				barID = i
				tremove(self.currentProfile.bars, i)
				if bar.isDefault then
					self.currentProfile.bars[1].isDefault = true
				end
				break
			end
		end
		for _, settings in pairs(self.pConfig.btnSettings) do
			if settings[3] == barName then
				settings[3] = nil
			end
		end
		for _, settings in pairs(self.pConfig.mbtnSettings) do
			if settings[3] == barName then
				settings[3] = nil
			end
		end
		self:removeOmbGrabQueue(barID)
		for i, btn in ipairs(self.mbuttons) do
			if btn.name:match(hb.matchName) then
				self:removeMButton(btn, i)
			end
		end
		hb:updateBars()
		if self.currentBar.name == barName then
			self:setBar()
		else
			self:setBar(self.currentBar)
		end
	end)
end


function main:setBar(bar)
	if not bar then
		for _, b in ipairs(self.pBars) do
			if b.isDefault then
				bar = b
				break
			end
		end
	end

	if self.currentBar ~= bar then
		self.currentBar = bar
		self.bConfig = self.currentBar.config
		self.barFrame = hb.barByName[self.currentBar.name]
		self.direction = self.barFrame.direction
		barCombobox:ddSetSelectedText(self.currentBar.name)

		self.buttonPanel.bg:SetVertexColor(unpack(self.bConfig.bgColor))
		expandToCombobox:ddSetSelectedValue(self.bConfig.expand)
		expandToCombobox:ddSetSelectedText(expandToCombobox.texts[self.bConfig.expand])
		lineColor.color:SetColorTexture(unpack(self.bConfig.lineColor))
		bgColor.color:SetColorTexture(unpack(self.bConfig.bgColor))
		local hexColor = toHex(self.bConfig.lineColor)
		self.description:SetText(L["SETTINGS_DESCRIPTION"]:format(hexColor))
		orientationCombobox:ddSetSelectedValue(self.bConfig.orientation)
		orientationCombobox:ddSetSelectedText(orientationCombobox.texts[self.bConfig.orientation])
		fsCombobox:ddSetSelectedValue(self.bConfig.frameStrata)
		fsCombobox:ddSetSelectedText(fsCombobox.texts[self.bConfig.frameStrata])
		lock:SetChecked(self.bConfig.lock)
		self.fade.Text:SetText(L["Fade out line"]:format(hexColor))
		self.fade:SetChecked(self.bConfig.fade)
		self.fadeOpacity:SetValue(self.bConfig.fadeOpacity)
		self.fadeOpacity:SetEnabled(self.bConfig.fade)
		self.lineWidth.text:SetText(L["Line width"]:format(hexColor))
		self.lineWidth:SetValue(self.bConfig.lineWidth)
		showHandlerCombobox:ddSetSelectedValue(self.bConfig.showHandler)
		showHandlerCombobox:ddSetSelectedText(showHandlerCombobox.texts[self.bConfig.showHandler])
		delayToShowEditBox:SetNumber(self.bConfig.showDelay)
		delayToHideEditBox:SetNumber(self.bConfig.hideDelay)

		buttonNumber:SetValue(self.bConfig.size)
		buttonSize:SetValue(self.bConfig.buttonSize)
		barOffset:SetValue(self.bConfig.barOffset)
		rangeBetweenBtns:SetValue(self.bConfig.rangeBetweenBtns)
		mbtnPostionCombobox:ddSetSelectedValue(self.bConfig.mbtnPosition)
		mbtnPostionCombobox:ddSetSelectedText(mbtnPostionCombobox.texts[self.bConfig.mbtnPosition])
		interceptTooltip:SetChecked(self.bConfig.interceptTooltip)

		self.hideToCombobox:ddSetSelectedValue(self.bConfig.anchor)
		self.hideToCombobox:ddSetSelectedText(self.hideToCombobox.texts[self.bConfig.anchor])
		self.ombShowToCombobox:ddSetSelectedValue(self.bConfig.omb.anchor)
		self.ombShowToCombobox:ddSetSelectedText(self.ombShowToCombobox.texts[self.bConfig.omb.anchor])
		self.ombSize:SetValue(self.bConfig.omb.size)
		self.canGrabbed:SetChecked(self.bConfig.omb.canGrabbed)

		updateBarTypePosition()
		self:updateCoords()
	end

	for _, btn in ipairs(self.mixedButtons) do
		local show = btn.settings[3] == bar.name or not btn.settings[3] and bar.isDefault
		btn:SetShown(show)
		if show then
			btn:SetChecked(btn.settings[1])
		end
	end

	self:setButtonSize()
	self:applyLayout()
end


function main:removeOmbGrabQueue(id)
	for i = 1, #self.pConfig.ombGrabQueue do
		if self.pConfig.ombGrabQueue[i] == id then
			tremove(self.pConfig.ombGrabQueue, i)
			break
		end
	end
end


function main:updateCoords()
	if not self.barFrame then return end

	local x = self.barFrame.position or 0
	local y = self.barFrame.secondPosition or 0
	local anchor = self.bConfig.barTypePosition == 2 and self.bConfig.omb.anchor or self.bConfig.anchor
	if anchor == "left" or anchor == "right" then x, y = y, x end

	self.coordX:SetNumber(math.floor(x + .5))
	self.coordY:SetNumber(math.floor(y + .5))
end
hb:on("COORDS_UPDATED", function(_, bar)
	if main.barFrame == bar then
		main:updateCoords()
	end
end)


function main:removeMButtonByName(name, update)
	for i, btn in ipairs(self.mbuttons) do
		if btn.name == name then
			self:removeMButton(btn, i, update)
			hb:removeMButton(btn.rButton, update)
			if btn.rButton.__MSQ_Enabled or btn.rButton.rButton and btn.rButton.rButton.__MSQ_Enabled then
				StaticPopup_Show(self.addonName.."GET_RELOAD")
			end
			break
		end
	end
end


function main:removeMButton(button, mIndex, update)
	tremove(self.mbuttons, mIndex)
	for i, btn in ipairs(self.mixedButtons) do
		if btn == button then
			tremove(self.mixedButtons, i)
			break
		end
	end

	button:Hide()
	self.removedButtons = self.removedButtons or {}
	self.removedButtons[button.rButton] = button

	if update then
		self:applyLayout()
	end
end


function main:restoreMbutton(rButton)
	if not (self.removedButtons and self.removedButtons[rButton]) then return end

	local btn = self.removedButtons[rButton]
	self.removedButtons[rButton] = nil
	if not next(self.removedButtons) then self.removedButtons = nil end

	tinsert(self.mbuttons, btn)
	tinsert(self.mixedButtons, btn)
	btn.settings = self.pConfig.mbtnSettings[rButton:GetName()]
	local bar = self.currentBar
	btn:SetShown(btn.settings[3] == bar.name or not btn.settings[3] and bar.isDefault)
	btn:SetChecked(btn.settings[1])
	self:sort(self.mbuttons)
	self:sort(self.mixedButtons)
	self:setButtonSize()
	self:applyLayout()
end


function main:addIgnoreName(name)
	name = name:gsub("[%(%)%.%%%+%-%*%?%[%^%$]", "%%%1")
	for _, n in ipairs(self.pConfig.ignoreMBtn) do
		if name == n then return end
	end
	self:removeMButtonByName(name, true)
	tinsert(self.pConfig.ignoreMBtn, name)
	sort(self.pConfig.ignoreMBtn)
	self.ignoreScroll:update()
end


function main:removeIgnoreName(name)
	StaticPopup_Show(self.addonName.."REMOVE_IGNORE_MBTN", NORMAL_FONT_COLOR:WrapTextInColorCode(name:gsub("%%([%(%)%.%%%+%-%*%?%[%^%$])", "%1")), nil, function()
		for i = 1, #self.pConfig.ignoreMBtn do
			if name == self.pConfig.ignoreMBtn[i] then
				tremove(self.pConfig.ignoreMBtn, i)
				break
			end
		end
		self.ignoreScroll:update()
		hb:grabMButtons()
	end)
end


function main:addCustomGrabName(name)
	StaticPopup_Show(self.addonName.."ADD_CUSTOM_GRAB_BTN", NORMAL_FONT_COLOR:WrapTextInColorCode(name), nil, function()
		for _, n in ipairs(self.pConfig.customGrabList) do
			if name == n then return end
		end
		tinsert(self.pConfig.customGrabList, name)
		sort(self.pConfig.customGrabList)
		self.customGrabScroll:update()

		if hb:addCustomGrabButton(name) then
			local btn = _G[name]
			hb:setMBtnSettings(btn)
			hb:setBtnParent(btn)
			hb:sort()
			btn:GetParent():setButtonSize()
			self:initMButtons(true)
		end
	end)
end


function main:removeCustomGrabName(name)
	StaticPopup_Show(self.addonName.."REMOVE_CUSTOM_GRAB_BTN", NORMAL_FONT_COLOR:WrapTextInColorCode(name), nil, function()
		for i = 1, #self.pConfig.customGrabList do
			if name == self.pConfig.customGrabList[i] then
				tremove(self.pConfig.customGrabList, i)
				break
			end
		end
		self.customGrabScroll:update()
		if name:match(hb.matchName) then
			local btn = _G[name]
			if not btn or btn.bar.config.omb.canGrabbed then return end
		end
		self:removeMButtonByName(name, true)
	end)
end


function main:hidingBarUpdate()
	for i = 1, #self.currentProfile.bars do
		local bar = hb.bars[i]
		bar:enter()
		bar:leave(math.max(1.5, bar.config.hideDelay))
	end
end


function main:dragBtn(btn)
	local scale, x, y = btn:GetScale()
	if self.direction.V == "BOTTOM" then
		y = btn:GetBottom() - (self.buttonPanel:GetBottom() + self.bConfig.barOffset) / scale
	else
		y = (self.buttonPanel:GetTop() - self.bConfig.barOffset) / scale - btn:GetTop()
	end
	if self.direction.H == "RIGHT" then
		x = (self.buttonPanel:GetRight() - self.bConfig.barOffset) / scale - btn:GetRight()
	else
		x = btn:GetLeft() - (self.buttonPanel:GetLeft() + self.bConfig.barOffset) / scale
	end
	if self.orientation then x, y = y, x end
	local buttonSize = (self.bConfig.buttonSize + self.bConfig.rangeBetweenBtns) / scale
	local row, column = math.floor(y / buttonSize + .5), math.floor(x / buttonSize + .5) + 1
	if row < btn.minRow then row = btn.minRow
	elseif row > btn.maxRow then row = btn.maxRow end
	if column < 1 then column = 1
	elseif column > btn.maxColumn then column = btn.maxColumn end
	local order = row * self.bConfig.size + column - btn.orderDelta
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
	GameTooltip:Hide()
	contextmenu:ddCloseMenus()
	btn.isDrag = true
	local list = self.bConfig.mbtnPosition == 2 and self.mixedButtons or btn.defBtnList
	btn.btnList = {}
	for i = 1, #list do
		if list[i]:IsShown() then
			local j = #btn.btnList + 1
			btn.btnList[j] = list[i]
			list[i].settings[2] = j
		end
	end
	if not btn.level then btn.level = btn:GetFrameLevel() end
	btn:SetFrameLevel(btn.level + 2)
	btn.orderDelta = orderDelta or 0
	btn.maxColumn = #btn.btnList + btn.orderDelta
	btn.minRow = math.floor(btn.orderDelta / self.bConfig.size)
	btn.maxRow = math.ceil(btn.maxColumn / self.bConfig.size) - 1
	if btn.maxColumn > self.bConfig.size then btn.maxColumn = self.bConfig.size end
	btn:SetScript("OnUpdate", function(btn) self:dragBtn(btn) end)
	btn:StartMoving()
end


function main:dragStop(btn)
	btn.isDrag = nil
	btn.btnList = nil
	btn:SetFrameLevel(btn.level)
	btn:SetScript("OnUpdate", nil)
	btn:StopMovingOrSizing()
	self:setPointBtn(btn, btn.settings[2] + btn.orderDelta, .3)
	btn.orderDelta = nil
	btn.maxColumn = nil
	btn.minRow = nil
	btn.maxRow = nil
	self:sort(btn.defBtnList)
	self:sort(self.mixedButtons)
	self:applyLayout()
	hb:sort()
	self.barFrame:applyLayout()
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

	local function btnClick(btn, button)
		if button == "LeftButton" then
			btn.settings[1] = btn:GetChecked()
			main.barFrame:applyLayout()
			main:hidingBarUpdate()
			contextmenu:ddCloseMenus()
		elseif button == "RightButton" then
			btn:SetChecked(not btn:GetChecked())
			if btn.isDrag then return end
			contextmenu:ddToggle(1, btn, btn)
		end
	end

	local function btnDragStart(btn)
		main:dragStart(btn)
	end

	local function btnDragStop(btn)
		main:dragStop(btn)
	end

	local function btnEnter(btn)
		if btn.isDrag then return end
		GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
		GameTooltip:SetText(btn.title)
		GameTooltip:AddLine(L["Source:"]..GRAY_FONT_COLOR:WrapTextInColorCode(" DataBroker"), .3, .5, .7)
		GameTooltip:AddLine(L["BUTTON_TOOLTIP"], 1, 1, 1)
		GameTooltip:Show()
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
		btn:HookScript("OnEnter", btnEnter)
		contextmenu:ddSetNoGlobalMouseEvent(true, btn)
		buttonsByName[name] = btn
		tinsert(self.buttons, btn)
		tinsert(self.mixedButtons, btn)

		if update and self.barFrame then
			btn.settings = self.pConfig.btnSettings[name]
			local bar = self.currentBar
			btn:SetShown(btn.settings[3] == bar.name or not btn.settings[3] and bar.isDefault)
			btn:SetChecked(btn.settings[1])
			self:sort(self.buttons)
			self:sort(self.mixedButtons)
			self:setButtonSize()
			self:applyLayout()
		end
	end
	hb:on("BUTTON_ADDED", function(_, ...) main:createButton(...) end)
end


do
	local buttonsByName = {}

	local function btnClick(btn, button)
		if button == "LeftButton" then
			btn.settings[1] = btn:GetChecked()
			main.barFrame:applyLayout()
			main:hidingBarUpdate()
			contextmenu:ddCloseMenus()
		elseif button == "RightButton" then
			btn:SetChecked(not btn:GetChecked())
			if btn.isDrag then return end
			contextmenu:ddToggle(1, btn, btn)
		end
	end

	local function btnDragStart(btn)
		main:dragStart(btn, main.orderMBtnDelta)
	end

	local function btnDragStop(btn)
		main:dragStop(btn)
	end

	local function btnEnter(btn)
		if btn.isDrag then return end
		GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
		GameTooltip:SetText(btn.title)
		GameTooltip:AddLine(L["Source:"]..btn.source, .3, .5, .7)
		GameTooltip:AddLine(L["BUTTON_TOOLTIP"], 1, 1, 1)
		GameTooltip:Show()
	end

	function main:createMButton(button, name, icon, update)
		if not self.buttonPanel or type(name) ~= "string" then return end
		if buttonsByName[name] then
			self:restoreMbutton(button)
			return
		end

		local btn = CreateFrame("CheckButton", nil, self.buttonPanel, "HidingBarAddonConfigMButtonTemplate")
		btn.rButton = button
		btn.name = name
		btn.title = name:gsub("LibDBIcon10_", "")
		local atlas = icon:GetAtlas()
		if atlas then
			btn.icon:SetAtlas(atlas)
		else
			btn.icon:SetTexture(icon:GetTexture())
			btn.icon:SetTexCoord(icon:GetTexCoord())
		end
		btn.color = {icon:GetVertexColor()}
		btn.defBtnList = self.mbuttons
		btn:HookScript("OnClick", btnClick)
		btn:SetScript("OnDragStart", btnDragStart)
		btn:SetScript("OnDragStop", btnDragStop)
		btn:SetScript("OnEnter", btnEnter)
		contextmenu:ddSetNoGlobalMouseEvent(true, btn)
		btn.toIgnore = not (hb.manuallyButtons[button] or name:match(hb.matchName))
		btn.source = " "..GRAY_FONT_COLOR:WrapTextInColorCode(hb.manuallyButtons[button] and L["Manually added"] or "Minimap")
		hb.manuallyButtons[button] = nil
		buttonsByName[name] = btn
		tinsert(self.mbuttons, btn)
		tinsert(self.mixedButtons, btn)

		if update then
			btn.settings = self.pConfig.mbtnSettings[name]
			local bar = self.currentBar
			btn:SetShown(btn.settings[3] == bar.name or not btn.settings[3] and bar.isDefault)
			btn:SetChecked(btn.settings[1])
			self:sort(self.mbuttons)
			self:sort(self.mixedButtons)
			self:setButtonSize()
			self:applyLayout()
		end
	end
	hb:on("MBUTTON_ADDED", function(_, btn) main:createMButton(btn, btn:GetName(), btn.icon, true) end)
end


function main:initButtons()
	for _, button in ipairs(hb.createdButtons) do
		self:createButton(button.name, button)
	end
end


function main:initMButtons(update)
	for _, button in ipairs(hb.minimapButtons) do
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
			self:createMButton(button, name, icon, update)
		end
	end
end
hb:on("MBUTTONS_UPDATED", function() main:initMButtons(true) end)


function main:setButtonSize()
	for _, button in ipairs(self.buttons) do
		if button:IsShown() then
			button:SetScale(self.bConfig.buttonSize / button:GetWidth())
		end
	end
	for _, button in ipairs(self.mbuttons) do
		if button:IsShown() then
			button:SetScale(self.bConfig.buttonSize / button:GetWidth())
		end
	end
end


local function setPosAnimated(btn, elapsed)
	btn.timer = btn.timer - elapsed
	if btn.timer <= 0 then
		btn:SetPoint(main.direction.rPoint, btn.x, btn.y)
		btn:SetScript("OnUpdate", nil)
	else
		local scale = btn:GetScale()
		local deltaY = main.direction.V == "BOTTOM"
			and btn.deltaY + btn:GetHeight() - main.buttonPanel:GetHeight() / scale
			or btn.deltaY
		local deltaX = main.direction.H == "RIGHT"
			and btn.deltaX + main.buttonPanel:GetWidth() / scale - btn:GetWidth()
			or btn.deltaX
		local k = btn.timer / btn.delay
		btn:SetPoint(main.direction.rPoint, btn.x - deltaX * k, btn.y - deltaY * k)
	end
end


function main:setPointBtn(btn, order, delay)
	if btn.isDrag then return end
	local scale = btn:GetScale()
	local buttonSize = self.bConfig.buttonSize + self.bConfig.rangeBetweenBtns
	order = order - 1
	btn.x = (order % self.bConfig.size * buttonSize + self.bConfig.barOffset) / scale
	btn.y = (-math.floor(order / self.bConfig.size) * buttonSize - self.bConfig.barOffset) / scale
	if self.orientation then btn.x, btn.y = -btn.y, -btn.x end
	if self.direction.V == "BOTTOM" then btn.y = -btn.y end
	if self.direction.H == "RIGHT" then btn.x = -btn.x end

	if delay and btn:IsVisible() then
		btn.timer = delay
		btn.delay = delay
		btn.deltaX = btn.x - btn:GetLeft() + self.buttonPanel:GetLeft() / scale
		btn.deltaY = btn.y - btn:GetTop() + self.buttonPanel:GetTop() / scale
		btn:ClearAllPoints()
		btn:SetScript("OnUpdate", setPosAnimated)
	else
		btn:ClearAllPoints()
		btn:SetPoint(self.direction.rPoint, btn.x, btn.y)
	end
end


function main:applyLayout(delay)
	if not self.buttonPanel then return end
	if self.bConfig.orientation == 0 then
		local anchor = self.bConfig.barTypePosition == 2 and self.bConfig.omb.anchor or self.bConfig.anchor
		self.orientation = anchor == "top" or anchor == "bottom"
	else
		self.orientation = self.bConfig.orientation == 2
	end

	local i, columns, rows = 0, self.bConfig.size
	if self.bConfig.mbtnPosition == 2 then
		for _, btn in ipairs(self.mixedButtons) do
			if btn:IsShown() then
				i = i + 1
				self:setPointBtn(btn, i, delay)
			end
		end
		self.orderMBtnDelta = 0
		rows = math.ceil(i / columns)
	else
		for _, btn in ipairs(self.buttons) do
			if btn:IsShown() then
				i = i + 1
				self:setPointBtn(btn, i, delay)
			end
		end
		self.orderMBtnDelta = self.bConfig.mbtnPosition == 1 and i or math.ceil(i / columns) * columns
		local j = 0
		for _, btn in ipairs(self.mbuttons) do
			if btn:IsShown() then
				j = j + 1
				self:setPointBtn(btn, j + self.orderMBtnDelta, delay)
			end
		end
		rows = math.ceil((j + self.orderMBtnDelta) / columns)
	end

	if rows < 1 then rows = 1 end
	local buttonSize = self.bConfig.buttonSize + self.bConfig.rangeBetweenBtns
	local offset = self.bConfig.barOffset * 2 - self.bConfig.rangeBetweenBtns
	local width = columns * buttonSize + offset
	local height = rows * buttonSize + offset
	if self.orientation then width, height = height, width end
	self.buttonPanel:SetSize(width, height)
end


-- INIT
do
	local function init()
		main:initButtons()
		main:initMButtons()
		main:setProfile()
		hb.off(main, "INIT")
	end

	if hb.init then
		hb.on(main, "INIT", init)
	else
		init()
	end
end