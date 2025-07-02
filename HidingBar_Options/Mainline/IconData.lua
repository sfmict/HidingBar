local main = HidingBarConfigAddon
local iconData = CreateFrame("FRAME", nil, main, "HidingBarAddonDarkPanelTemplate")
main.iconData = iconData
iconData:Hide()


local function fillOutExtraIconsWithSpells(extraIcons, icons)
	for skillLineIndex = 1, C_SpellBook.GetNumSpellBookSkillLines() do
		local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex)
		for i = 1, skillLineInfo.numSpellBookItems do
			local spellIndex = skillLineInfo.itemIndexOffset + i
			local spellType, ID = C_SpellBook.GetSpellBookItemType(spellIndex, Enum.SpellBookSpellBank.Player)
			if spellType ~= "FUTURESPELL" then
				local fileID = C_SpellBook.GetSpellBookItemTexture(spellIndex, Enum.SpellBookSpellBank.Player)
				if fileID ~= nil and not icons[fileID] then
					local name = C_SpellBook.GetSpellBookItemName(spellIndex, Enum.SpellBookSpellBank.Player)
					extraIcons[#extraIcons + 1] = {type = "spell", name = name, icon = fileID}
					icons[fileID] = true
				end
			end

			if spellType == "FLYOUT" then
				local _, _, numSlots, isKnown = GetFlyoutInfo(ID)
				if isKnown and (numSlots > 0) then
					for k = 1, numSlots do
						local spellID, overrideSpellID, isSlotKnown = GetFlyoutSlotInfo(ID, k)
						if isSlotKnown then
							local fileID = C_Spell.GetSpellTexture(spellID)
							if fileID ~= nil and not icons[fileID] then
								local name = C_Spell.GetSpellName(spellID)
								extraIcons[#extraIcons + 1] = {type = "spell", name = name, icon = fileID}
								icons[fileID] = true
							end
						end
					end
				end
			end
		end
	end
end


local function fillOutExtraIconsWithTalents(extraIcons, icons)
	local isInspect = false
	for specIndex = 1, GetNumSpecGroups(isInspect) do
		for tier = 1, MAX_TALENT_TIERS do
			for column = 1, NUM_TALENT_COLUMNS do
				local spellID, name, icon = GetTalentInfo(tier, column, specIndex)
				if icon ~= nil and not icons[icon] then
					extraIcons[#extraIcons + 1] = {type = "spell", name = name, icon = icon}
					icons[icon] = true
				end
			end
		end
	end

	for pvpTalentSlot = 1, 3 do
		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(pvpTalentSlot)
		if slotInfo ~= nil then
			for i, pvpTalentID in ipairs(slotInfo.availableTalentIDs) do
				local spellID, name, icon = GetPvpTalentInfoByID(pvpTalentID)
				if icon ~= nil and not icons[icon] then
					extraIcons[#extraIcons + 1] = {type = "spell", name = name, icon = icon}
					icons[icon] = true
				end
			end
		end
	end
end


local function fillOutExtraIconsWithEquipment(extraIcons, icons)
	for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local itemTexture = GetInventoryItemTexture("player", i)
		if itemTexture ~= nil and not icons[itemTexture] then
			local link = GetInventoryItemLink("player", i)
			local name = C_Item.GetItemInfo(link)
			extraIcons[#extraIcons + 1] = {type = "item", name = name, icon = itemTexture}
			icons[itemTexture] = true
		end
	end
end


local function refreshExtraIcons()
	if not iconData.spell then
		iconData.spell = {}
		GetLooseMacroIcons(iconData.spell)
		GetMacroIcons(iconData.spell)
	end
	if not iconData.item then
		iconData.item = {}
		GetLooseMacroItemIcons(iconData.item)
		GetMacroItemIcons(iconData.item)
	end
end


local function getIconTexture(icon)
	local fileDataID = tonumber(icon)
	if fileDataID then return fileDataID end
	return [[INTERFACE\ICONS\]]..icon
end


iconData:SetScript("OnShow", function(self)
	self:EnableMouse(true)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10)
	-- (33+5)*10+5+10+26
	self:SetSize(421, 500)

	self.filters = {
		other = true,
		spell = true,
		item = true,
	}
	self.icons = {}
	self.extraIcons = {}
	self.filtredIcons = {}
	fillOutExtraIconsWithSpells(self.extraIcons, self.icons)
	fillOutExtraIconsWithTalents(self.extraIcons, self.icons)
	fillOutExtraIconsWithEquipment(self.extraIcons, self.icons)
	self.icons = nil
	sort(self.extraIcons, function(a, b)
		if a.type == "spell" and b.type ~= "spell" then return true
		elseif a.type ~= "spell" and b.type == "spell" then return false end
		return a.name < b.name
	end)
	tinsert(self.extraIcons, 1, {type = "other", name = HidingBarAddon.ombDefIcon, icon = 450906})

	-- SELECTED ICON
	self.selectedIconBtn = CreateFrame("BUTTON", nil, self, "HidingBarAddonIconButtonTemplate")
	self.selectedIconBtn:SetPoint("TOPRIGHT", -7, -11)
	self.selectedIconBtn:SetScript("OnClick", function()
		self:scrollToSelectedIcon()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	self.selectedText = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	self.selectedText:SetPoint("TOPRIGHT", self.selectedIconBtn, "TOPLEFT", -5, 0)
	self.selectedText:SetText(ICON_SELECTION_TITLE_CURRENT)

	-- SEARCH BOX
	self.searchBox = CreateFrame("Editbox", nil, self, "SearchBoxTemplate")
	self.searchBox:SetPoint("TOPLEFT", 20, -28)
	self.searchBox:SetSize(150, 19)
	self.searchBox:SetMaxLetters(40)
	self.searchBox:SetScript("OnTextChanged", function(searchBox)
		SearchBoxTemplate_OnTextChanged(searchBox)
		self:refreshFilters()
	end)

	-- FILTER BUTTON
	self.filtersButton = LibStub("LibSFDropDown-1.5"):CreateStretchButtonOriginal(self, 93, 22)
	self.filtersButton:SetPoint("LEFT", self.searchBox, "RIGHT", -1, 0)
	self.filtersButton:SetText(FILTER)
	self.filtersButton:ddSetInitFunc(function(...) self:filterDropDownInit(...) end)

	-- SCROLL
	self.scrollBox = CreateFrame("FRAME", nil, self, "WowScrollBoxList")
	self.scrollBox:SetPoint("TOPLEFT", 10, -50)
	self.scrollBox:SetPoint("BOTTOMRIGHT", -26, 36)

	self.scrollBar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar")
	self.scrollBar:SetPoint("TOPLEFT", self.scrollBox, "TOPRIGHT", 8, -2)
	self.scrollBar:SetPoint("BOTTOMLEFT", self.scrollBox, "BOTTOMRIGHT", 8, 0)

	self.view = CreateScrollBoxListGridView(10, 5, 5, 5, 5, 5, 5)
	self.view:SetElementInitializer("HidingBarAddonIconButtonSelectedTemplate", function(...) self:btnInit(...) end)
	ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollBox, self.scrollBar, self.view)

	-- OK & CANCEL
	self.cancel = CreateFrame("BUTTON", nil, self, "UIPanelButtonTemplate")
	self.cancel:SetPoint("BOTTOMRIGHT", -30, 10)
	self.cancel:SetText(CANCEL)
	self.cancel:SetScript("OnClick", function(btn)
		btn:GetParent():Hide()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	self.ok = CreateFrame("BUTTON", nil, self, "UIPanelButtonTemplate")
	self.ok:SetPoint("RIGHT", self.cancel, "LEFT", -5, 0)
	self.ok:SetText(OKAY)
	self.ok:SetScript("OnClick", function(btn)
		self.btn.icon:SetTexture(self.selectedIcon)
		self.func()
		btn:GetParent():Hide()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	local width = math.max(self.cancel:GetFontString():GetStringWidth(), self.ok:GetFontString():GetStringWidth()) + 40
	self.cancel:SetSize(width, 22)
	self.ok:SetSize(width, 22)

	-- SHOW / HIDE / EVENTS
	self:SetScript("OnShow", function(self)
		self:RegisterEvent("GLOBAL_MOUSE_DOWN")
	end)
	self:GetScript("OnShow")(self)
	self:SetScript("OnHide", function(self)
		self:ClearAllPoints()
		self:Hide()
		self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
	end)
	self:SetScript("OnEvent", function(self, event, button)
		if not (self:IsMouseOver() or self.btn:IsMouseOver())
		and (button == "LeftButton" or button == "RightButton")
		then
			self:Hide()
		end
	end)
end)


function iconData:init(btn, func)
	if self.btn == btn and self:IsShown() then
		self:Hide()
	else
		self:Hide()
		self.btn = btn
		self.func = func
		self:SetPoint("LEFT", btn, "RIGHT", 5, 0)
		self:Show()
		self.selectedIcon = btn.icon:GetTexture()
		self.selectedIconBtn.icon:SetTexture(self.selectedIcon)
		self:refreshFilters()
		self:scrollToSelectedIcon()
	end
end


function iconData:filterDropDownInit(btn, level)
	local info = {}
	info.keepShownOnClick = true
	info.isNotRadio = true

	info.text = SPELLS
	info.func = function(_,_,_, checked)
		self.filters.spell = checked
		self:refreshFilters()
	end
	info.checked = self.filters.spell
	btn:ddAddButton(info, level)

	info.text = ITEMS
	info.func = function(_,_,_, checked)
		self.filters.item = checked
		self:refreshFilters()
	end
	info.checked = self.filters.item
	btn:ddAddButton(info, level)

	info.text = OTHER
	info.func = function(_,_,_, checked)
		self.filters.other = checked
		self:refreshFilters()
	end
	info.checked = self.filters.other
	btn:ddAddButton(info, level)

	info.text = ADVANCED_LABEL
	info.func = function(_,_,_, checked)
		refreshExtraIcons()
		self.filters.extra = checked
		self:refreshFilters()
	end
	info.checked = self.filters.extra
	btn:ddAddButton(info, level)
end


function iconData:refreshFilters()
	local text = self.searchBox:GetText():trim():lower()
	self.filters.text = #text == 0
	wipe(self.filtredIcons)

	for i = 1, #self.extraIcons do
		local iconData = self.extraIcons[i]
		if self.filters[iconData.type]
		and (#text == 0 or iconData.name:lower():find(text, 1, true))
		then
			self.filtredIcons[#self.filtredIcons + 1] = iconData
		end
	end

	self:updateList()
end


function iconData:getNumIcons()
	local num = #self.filtredIcons

	if self.filters.extra and self.filters.text then
		if self.filters.spell then
			num = num + #self.spell
		end
		if self.filters.item then
			num = num + #self.item
		end
	end

	return num
end


function iconData:getIconByIndex(index)
	local numIcons = #self.filtredIcons

	if index <= numIcons then return self.filtredIcons[index].icon	end
	index = index - numIcons

	if self.filters.extra and self.filters.text then
		if self.filters.spell then
			numIcons = #self.spell
			if index <= numIcons then return getIconTexture(self.spell[index]) end
			index = index - numIcons
		end
		if self.filters.item then
			return getIconTexture(self.item[index])
		end
	end
end


function iconData:getIndexOfIcon(icon)
	for i = 1, self:getNumIcons() do
		if self:getIconByIndex(i) == icon then return i end
	end
end


function iconData:scrollToSelectedIcon()
	local index = self:getIndexOfIcon(self.selectedIcon)
	if index then self.scrollBox:ScrollToElementDataIndex(index, ScrollBoxConstants.AlignCenter) end
end


do
	local function click(btn)
		iconData.selectedIcon = btn.icon:GetTexture()
		iconData.selectedIconBtn.icon:SetTexture(iconData.selectedIcon)
		iconData:updateList()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end

	function iconData:btnInit(btn, index)
		local icon = self:getIconByIndex(index)
		btn.icon:SetTexture(icon)
		btn.selectedTexture:SetShown(icon == self.selectedIcon)
		btn:SetScript("OnClick", click)
	end
end


function iconData:updateList()
	self.dataProvider = CreateIndexRangeDataProvider(self:getNumIcons())
	self.scrollBox:SetDataProvider(self.dataProvider, ScrollBoxConstants.RetainScrollPosition)
end