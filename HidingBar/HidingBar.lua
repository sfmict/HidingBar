local addon, L = ...
local config, UIParent = _G[addon.."ConfigAddon"], UIParent
local hidingBar = CreateFrame("FRAME", addon.."Addon")
local cover = CreateFrame("FRAME")
cover:Hide()
cover:EnableMouse(true)
local fTimer = CreateFrame("FRAME")
local btnSettingsMeta = {__index = function(self, key)
	self[key] = {tstmp = 0}
	return self[key]
end}
hidingBar.createdButtons, hidingBar.minimapButtons, hidingBar.mixedButtons = {}, {}, {}
hidingBar.bars, hidingBar.barByName = {}, {}
local createdButtonsByName, btnSettings = {}, {}
local offsetX, offsetY = 2, 2
local matchName = addon.."%d+$"
hidingBar.cb = LibStub("CallbackHandler-1.0"):New(hidingBar, "on", "off")
local ldb = LibStub("LibDataBroker-1.1")
local ldbi, ldbi_ver = LibStub("LibDBIcon-1.0")
local MSQ = LibStub("Masque", true)


local ignoreFrameList = {
	["HelpOpenWebTicketButton"] = true,
	["MinimapBackdrop"] = true,
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["MiniMapWorldMapButton"] = true,
	["MiniMapMailFrame"] = true,
	["MiniMapTrackingFrame"] = true,
	["MiniMapBattlefieldFrame"] = true,
}


local function void() end
local function enter(btn)
	local bar = btn:GetParent()
	if bar:IsShown() then
		bar.isMouse = true
		bar:enter()
	end
end
local function leave(btn)
	local bar = btn:GetParent()
	if bar:IsShown() then
		bar.isMouse = false
		bar:leave()
	end
end


if MSQ then
	hidingBar.MSQ_Button = MSQ:Group(addon, L["DataBroker Buttons"], "DataBroker")
	hidingBar.MSQ_Button:SetCallback(function()
		for btn in pairs(hidingBar.MSQ_Button.Buttons) do
			hidingBar:MSQ_CoordUpdate(btn)
		end
		for _, bar in ipairs(hidingBar.bars) do
			bar:enter()
			bar:leave(math.max(1.5, bar.config.hideDelay))
		end
	end)


	hidingBar.MSQ_Button_Data = {}
	hidingBar.MSQ_MButton = MSQ:Group(addon, L["Minimap Buttons"], "MinimapButtons")
	hidingBar.MSQ_MButton:SetCallback(function()
		for btn in pairs(hidingBar.MSQ_MButton.Buttons) do
			hidingBar:MSQ_Button_Update(btn)
			hidingBar:MSQ_CoordUpdate(btn)
		end
		for _, bar in ipairs(hidingBar.bars) do
			bar:enter()
			bar:leave(math.max(1.5, bar.config.hideDelay))
		end
	end)


	hidingBar.MSQ_CGButton = MSQ:Group(addon, L["Manually Grabbed Buttons"], "CGButtons")
	hidingBar.MSQ_CGButton:SetCallback(function()
		for btn in pairs(hidingBar.MSQ_CGButton.Buttons) do
			hidingBar:MSQ_Button_Update(btn)
			hidingBar:MSQ_CoordUpdate(btn)
		end
		for _, bar in ipairs(hidingBar.bars) do
			bar:enter()
			bar:leave(math.max(1.5, bar.config.hideDelay))
		end
	end)


	local prevCoord, curCoord, MSQ_Coord = {}, {}, {}
	function hidingBar:MSQ_CoordUpdate(btn)
		local icon = btn.__MSQ_Icon
		if not icon then return end
		if not MSQ_Coord[icon] then MSQ_Coord[icon] = {} end
		for i = 1, 8 do
			MSQ_Coord[icon][i] = curCoord[icon][i]
		end
		if prevCoord[icon] then
			icon:SetTexCoord(unpack(prevCoord[icon]))
		else
			curCoord[icon] = nil
		end
	end


	function hidingBar:setTexCurCoord(icon, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
		if not LRy then
			ULy, LLx, URx, URy, LRx, LRy = LLx, ULx, ULy, LLx, ULy, LLy
		end
		if curCoord[icon] then
			if not prevCoord[icon] then prevCoord[icon] = {} end
			for i = 1, 8 do
				prevCoord[icon][i] = curCoord[icon][i]
			end
		else
			curCoord[icon] = {}
		end
		curCoord[icon][1] = ULx
		curCoord[icon][2] = ULy
		curCoord[icon][3] = LLx
		curCoord[icon][4] = LLy
		curCoord[icon][5] = URx
		curCoord[icon][6] = URy
		curCoord[icon][7] = LRx
		curCoord[icon][8] = LRy
		return ULx, ULy, LLx, LLy, URx, URy, LRx, LRy
	end


	hidingBar.setTexCoord = function(self, ...)
		local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = hidingBar:setTexCurCoord(self, ...)

		if MSQ_Coord[self] then
			local mULx, mULy, mLLx, mLLy, mURx, mURy, mLRx, mLRy = unpack(MSQ_Coord[self])
			local top = URx - ULx
			local right = LRy - URy
			local bottom = LRx - LLx
			local left = LLy - ULy
			ULx = ULx + mULx * top
			ULy = ULy + mULy * left
			LLx = LLx + mLLx * bottom
			LLy = ULy + mLLy * left
			URx = ULx + mURx * top
			URy = URy + mURy * right
			LRx = LLx + mLRx * bottom
			LRy = URy + mLRy * right
		end

		config.noIcon.SetTexCoord(self, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
	end


	function hidingBar:MSQ_Button_Update(btn)
		if not btn.__MSQ_Enabled then return end
		local data = self.MSQ_Button_Data[btn]
		if data then
			if data._Border then
				data._Border:Hide()
			end
			if data._Background then
				data._Background:Hide()
			end
			if data._Normal then
				data._Normal.SetAtlas = function(_, atlas)
					data._Icon:SetAtlas(atlas)
				end
				data._Normal.SetTexture = function(_, texture)
					if texture then
						data._Icon:SetTexture(texture)
					end
				end
				data._Normal.SetTexCoord = function(_, ...)
					data._Icon:SetTexCoord(...)
				end
				data._Normal = nil
			end
			if data._Pushed then
				data._Pushed:SetAlpha(0)
				data._Pushed:SetTexture()
				data._Pushed.SetAlpha = void
				data._Pushed.SetAtlas = void
				data._Pushed.SetTexture = void
			end
		end
	end


	function hidingBar:setMButtonRegions(btn, iconCoords, MSQ_Group)
		local name, texture, tIsString, layer, border, background, icon, highlight, normal

		for _, region in ipairs({btn:GetRegions()}) do
			if region:GetObjectType() == "Texture" then
				name = region:GetDebugName():lower()
				texture = region:GetTexture()
				tIsString = type(texture) == "string"
				if tIsString then texture = texture:lower() end
				layer = region:GetDrawLayer()
				if texture == 136430 or tIsString and texture:find("minimap-trackingborder", 1, true) then
					border = region
				end
				if texture == 136467 or tIsString and texture:find("ui-minimap-background", 1, true) or name:find("background", 1, true) then
					background = region
				end
				if name:find("icon", 1, true) or not icon and tIsString and texture:find("icon", 1, true) then
					icon = region
				end
				if layer == "HIGHLIGHT" or not highlight and name:find("highlight", 1, true) then
					highlight = region
				end
			end
		end

		normal = btn:GetNormalTexture()
		if normal and (not icon or icon ~= btn.icon) then
			icon = btn:CreateTexture(nil, "BACKGROUND")
			local atlas = normal:GetAtlas()
			if atlas then
				icon:SetAtlas(atlas)
			else
				icon:SetTexture(normal:GetTexture())
				icon:SetTexCoord(normal:GetTexCoord())
			end
			icon:SetVertexColor(normal:GetVertexColor())
			icon:SetSize(normal:GetSize())
			for i = 1, normal:GetNumPoints() do
				icon:SetPoint(normal:GetPoint(i))
			end
			self.HookScript(btn, "OnMouseDown", function() icon:SetScale(.9) end)
			self.HookScript(btn, "OnMouseUp", function() icon:SetScale(1) end)
		else
			normal = nil
		end

		if not highlight then
			btn:SetHighlightTexture(" ")
			highlight = btn:GetHighlightTexture()
			highlight:SetTexture()
		end

		if icon then
			if iconCoords then
				self:setTexCurCoord(icon, unpack(iconCoords))
			else
				self:setTexCurCoord(icon, icon:GetTexCoord())
			end
			icon.SetTexCoord = self.setTexCoord
		else
			background = nil
		end

		local pushed = btn:GetPushedTexture()
		if border or background or pushed or normal then
			self.MSQ_Button_Data[btn] = {
				_Border = border,
				_Background = background,
				_Pushed = pushed,
			}
			if normal then
				self.MSQ_Button_Data[btn]._Normal = normal
				self.MSQ_Button_Data[btn]._Icon = icon
			end
		end

		local data = {
			Icon = icon,
			Highlight = highlight,
		}
		(MSQ_Group or self.MSQ_MButton):AddButton(btn, data, "Legacy", true)
		self:MSQ_Button_Update(btn)
		self:MSQ_CoordUpdate(btn)
	end
end


hidingBar:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
hidingBar:RegisterEvent("ADDON_LOADED")


function hidingBar:ADDON_LOADED(addonName)
	if addonName == addon then
		self:UnregisterEvent("ADDON_LOADED")
		self.ADDON_LOADED = nil

		HidingBarDBChar = HidingBarDBChar or {}
		self.charDB = HidingBarDBChar
		HidingBarDB = HidingBarDB or {}
		self.db = HidingBarDB
		self.db.profiles = self.db.profiles or {
			{name = L["Profile"].." 1", isDefault = true},
		}
		self.profiles = self.db.profiles

		for i = 1, #self.profiles do
			self:checkProfile(self.profiles[i])
		end

		if self.db.config then
			local keys = {
				ignoreMBtn = true,
				btnSettings = true,
				mbtnSettings = true,
				grabDefMinimap = true,
				grabMinimap = true,
				grabMinimapAfter = true,
				grabMinimapAfterN = true,
				grabMinimapWithoutName = true,
			}

			local profile1config = self.profiles[1].config
			for k in pairs(keys) do
				profile1config[k] = self.db.config[k]
			end

			local bar1config = self.profiles[1].bars[1].config
			for k, v in pairs(self.db.config) do
				if not keys[k] then
					bar1config[k] = v
				end
			end
			self.db.config = nil
		end

		C_Timer.After(0, function() self:setProfile() end)
	end
end


function hidingBar:checkProfile(profile)
	profile.config = profile.config or {}
	if profile.config.addFromDataBroker == nil then
		profile.config.addFromDataBroker = true
	end
	if profile.config.grabMinimap == nil then
		profile.config.grabMinimap = true
	end
	profile.config.ignoreMBtn = profile.config.ignoreMBtn or {"GatherMatePin"}
	profile.config.grabMinimapAfterN = profile.config.grabMinimapAfterN or 1
	profile.config.customGrabList = profile.config.customGrabList or {}
	profile.config.btnSettings = setmetatable(profile.config.btnSettings or {}, btnSettingsMeta)
	profile.config.mbtnSettings = setmetatable(profile.config.mbtnSettings or {}, btnSettingsMeta)

	profile.bars = profile.bars or {
		{name = L["Bar"].." 1", isDefault = true},
	}

	for i = 1, #profile.bars do
		local bar = profile.bars[i]
		bar.config = bar.config or {}
		bar.config.orientation = bar.config.orientation or 0
		bar.config.expand = bar.config.expand or 2
		bar.config.frameStrata = bar.config.frameStrata or 2
		bar.config.fadeOpacity = bar.config.fadeOpacity or .2
		bar.config.lineWidth = bar.config.lineWidth or 4
		bar.config.showHandler = bar.config.showHandler or 2
		bar.config.showDelay = bar.config.showDelay or 0
		bar.config.hideDelay = bar.config.hideDelay or .75
		bar.config.size = bar.config.size or 10
		bar.config.buttonSize = bar.config.buttonSize or 31
		bar.config.anchor = bar.config.anchor or "top"
		bar.config.barTypePosition = bar.config.barTypePosition or 0
		bar.config.mbtnPosition = bar.config.mbtnPosition or 2
		bar.config.bgColor = bar.config.bgColor or {.1, .1, .1, .7}
		bar.config.lineColor = bar.config.lineColor or {.8, .6, 0}
		bar.config.omb = bar.config.omb or {}
		if bar.config.omb.hide == nil then
			bar.config.omb.hide = true
		end
		bar.config.omb.anchor = bar.config.omb.anchor or "right"
		bar.config.omb.size = bar.config.omb.size or 31
	end
end


function hidingBar:UI_SCALE_CHANGED()
	for _, bar in ipairs(self.bars) do
		bar:setBarTypePosition()
	end
end


function hidingBar:ignoreCheck(name)
	if not name then return self.pConfig.grabMinimapWithoutName end
	if name:match(matchName) then return end
	for i = 1, #self.pConfig.ignoreMBtn do
		if name:match(self.pConfig.ignoreMBtn[i]) then return end
	end
	return true
end


function hidingBar:init()
	if self.pConfig.addFromDataBroker then
		for name, data in ldb:DataObjectIterator() do
			self:ldb_add(nil, name, data)
		end
		ldb.RegisterCallback(self, "LibDataBroker_DataObjectCreated", "ldb_add")
		ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__icon", "ldb_attrChange")
		ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__iconCoords", "ldb_attrChange")
		ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__iconR", "ldb_attrChange")
		ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__iconG", "ldb_attrChange")
		ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__iconB", "ldb_attrChange")
		ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__iconDesaturated", "ldb_attrChange")
	end

	if self.pConfig.grabMinimap then
		if ldbi and ldbi_ver >= 39 then
			local ldbiTbl = ldbi:GetButtonList()
			for i = 1, #ldbiTbl do
				local button = ldbi:GetMinimapButton(ldbiTbl[i])
				if self:ignoreCheck(button:GetName()) then
					self.minimapButtons[button[0]] = button
					self:setHooks(button)
				end
			end
		end

		self:grabMinimapAddonsButtons(Minimap)
		self:grabMinimapAddonsButtons(MinimapBackdrop)
		ldbi.RegisterCallback(self, "LibDBIcon_IconCreated", "ldbi_add")

		if self.pConfig.grabMinimapAfter then
			C_Timer.After(tonumber(self.pConfig.grabMinimapAfterN) or 1, function()
				local oldNumButtons = #self.minimapButtons

				self:grabMinimapAddonsButtons(Minimap)
				self:grabMinimapAddonsButtons(MinimapBackdrop)

				if oldNumButtons ~= #self.minimapButtons then
					for _, btn in ipairs(self.minimapButtons) do
						self:setMBtnSettings(btn)
						self:setBtnParent(btn)
					end
					self:sort()
					for _, bar in ipairs(self.bars) do
						bar:setButtonSize()
					end
					self.cb:Fire("MBUTTONS_UPDATED")
				end
			end)
		end
	end

	for i = 1, #self.pConfig.customGrabList do
		self:addCustomGrabButton(self.pConfig.customGrabList[i])
	end

	if self.pConfig.grabDefMinimap then
		-- MINIMAP LFG FRAME
		if self:ignoreCheck("MiniMapLFGFrame") then
			local LFGFrame = MiniMapLFGFrame
			self:setHooks(LFGFrame)
			LFGFrame.icon = MiniMapLFGFrameIconTexture
			LFGFrame.icon:SetTexCoord(0, .125, 0, .25)

			LFGFrame.Show = function(LFGFrame)
				if not LFGFrame.show then
					LFGFrame.show = true
					LFGFrame:GetParent():applyLayout()
				end
			end
			LFGFrame.Hide = function(LFGFrame)
				if LFGFrame.show then
					LFGFrame.show = false
					LFGFrame:GetParent():applyLayout()
				end
			end
			LFGFrame.IsShown = function(LFGFrame)
				local show = LFGFrame.show and not btnSettings[LFGFrame][1]
				self.SetShown(LFGFrame, show)
				return show
			end

			if self.MSQ_MButton then
				self:setMButtonRegions(LFGFrame)
			end

			self.SetAlpha(LFGFrame, 1)
			self.SetHitRectInsets(LFGFrame, 0, 0, 0, 0)
			self.HookScript(LFGFrame, "OnEnter", enter)
			self.HookScript(LFGFrame, "OnLeave", leave)
			tinsert(self.minimapButtons, LFGFrame)
			tinsert(self.mixedButtons, LFGFrame)
		end

		-- BATTLEFIELD FRAME
		if self:ignoreCheck("MiniMapBattlefieldFrame") then
			local battlefield = MiniMapBattlefieldFrame
			battlefield.icon = MiniMapBattlefieldIcon
			battlefield.show = battlefield:IsShown()
			self:setHooks(battlefield)

			battlefield.Show = function(battlefield)
				if not battlefield.show then
					battlefield.show = true
					battlefield:GetParent():applyLayout()
				end
			end
			battlefield.Hide = function(battlefield)
				if battlefield.show then
					battlefield.show = false
					battlefield:GetParent():applyLayout()
				end
			end
			battlefield.IsShown = function(battlefield)
				local show = battlefield.show and not btnSettings[battlefield][1]
				self.SetShown(battlefield, show)
				return show
			end

			if self.MSQ_MButton then
				self:setMButtonRegions(battlefield)
			end

			self.SetAlpha(battlefield, 1)
			self.SetHitRectInsets(battlefield, 0, 0, 0, 0)
			self.HookScript(battlefield, "OnEnter", enter)
			self.HookScript(battlefield, "OnLeave", leave)
			tinsert(self.minimapButtons, battlefield)
			tinsert(self.mixedButtons, battlefield)
		end

		-- MAIL
		if self:ignoreCheck("HidingBarAddonMail") then
			local proxyMail = CreateFrame("BUTTON", "HidingBarAddonMail", nil, "HidingBarAddonMailTemplate")
			local mail = MiniMapMailFrame
			proxyMail.show = mail:IsShown()
			self:setHooks(mail)
			self.Hide(mail)
			mail:UnregisterAllEvents()
			proxyMail:SetScript("OnEvent", mail:GetScript("OnEvent"))
			proxyMail:SetScript("OnEnter", mail:GetScript("OnEnter"))
			proxyMail:SetScript("OnLeave", mail:GetScript("OnLeave"))
			proxyMail:RegisterEvent("UPDATE_PENDING_MAIL")

			proxyMail.Show = function(proxyMail)
				if not proxyMail.show then
					proxyMail.show = true
					proxyMail:GetParent():applyLayout()
				end
			end
			proxyMail.Hide = function(proxyMail)
				if proxyMail.show then
					proxyMail.show = false
					proxyMail:GetParent():applyLayout()
				end
			end
			proxyMail.IsShown = function(proxyMail)
				local show = proxyMail.show and not btnSettings[proxyMail][1]
				self.SetShown(proxyMail, show)
				return show
			end

			if self.MSQ_MButton then
				self:setMButtonRegions(proxyMail)
			end

			proxyMail:HookScript("OnEnter", enter)
			proxyMail:HookScript("OnLeave", leave)
			tinsert(self.minimapButtons, proxyMail)
			tinsert(self.mixedButtons, proxyMail)
		end

		-- ZOOM IN & ZOOM OUT
		for _, zoom in ipairs({MinimapZoomIn, MinimapZoomOut}) do
			local name = zoom:GetName()
			if self:ignoreCheck(name) then
				self:setHooks(zoom)
				local normal = zoom:GetNormalTexture()

				if self.MSQ_MButton then
					zoom.icon = zoom:CreateTexture(nil, "BACKGROUND")
					zoom.icon:SetTexture(normal:GetTexture())
					zoom:SetScript("OnMouseDown", function(self) self.icon:SetScale(.9) end)
					zoom:SetScript("OnMouseUp", function(self) self.icon:SetScale(1) end)
					self:setMButtonRegions(zoom, {.24, .79, .21, .76})
				else
					zoom.icon = normal
				end

				zoom.click = zoom:GetScript("OnClick")
				zoom.Disable = function(zoom)
					zoom:SetScript("OnClick", nil)
					zoom.icon:SetDesaturated(true)
					zoom:GetPushedTexture():SetDesaturated(true)
				end
				zoom.Enable = function(zoom)
					zoom:SetScript("OnClick", zoom.click)
					zoom.icon:SetDesaturated(false)
					zoom:GetPushedTexture():SetDesaturated(false)
				end
				if not zoom:IsEnabled() then
					getmetatable(zoom).__index.Enable(zoom)
					zoom:Disable()
				end

				self.SetAlpha(zoom, 1)
				self.SetHitRectInsets(zoom, 0, 0, 0, 0)
				self.HookScript(zoom, "OnEnter", enter)
				self.HookScript(zoom, "OnLeave", leave)
				tinsert(self.minimapButtons, zoom)
				tinsert(self.mixedButtons, zoom)
			end
		end

		-- WORLD MAP BUTTON
		if self:ignoreCheck("MiniMapWorldMapButton") then
			local mapButton = MiniMapWorldMapButton
			self:setHooks(mapButton)
			mapButton.icon = mapButton:GetNormalTexture()
			mapButton.icon:SetTexture("Interface/QuestFrame/UI-QuestMap_Button")
			mapButton.icon:SetTexCoord(.125, .875, 0, .5)
			mapButton.puched = mapButton:GetPushedTexture()
			mapButton.puched:SetTexture("Interface/QuestFrame/UI-QuestMap_Button")
			mapButton.puched:SetTexCoord(.125, .875, .5, 1)
			mapButton.highlight = mapButton:GetHighlightTexture()
			mapButton.highlight:SetTexture("Interface/BUTTONS/ButtonHilight-Square")
			mapButton.highlight:SetAllPoints()

			if self.MSQ_MButton then
				mapButton.icon = mapButton:CreateTexture(nil, "BACKGROUND")
				mapButton.icon:SetTexture("Interface/QuestFrame/UI-QuestMap_Button")
				mapButton.icon:SetTexCoord(.125, .875, 0, .5)
				mapButton:SetScript("OnMouseDown", function(self) self.icon:SetScale(.9) end)
				mapButton:SetScript("OnMouseUp", function(self) self.icon:SetScale(1) end)
				self:setMButtonRegions(mapButton)
			end

			self.SetAlpha(mapButton, 1)
			self.SetHitRectInsets(mapButton, 0, 0, 0, 0)
			self.HookScript(mapButton, "OnEnter", enter)
			self.HookScript(mapButton, "OnLeave", leave)
			tinsert(self.minimapButtons, mapButton)
			tinsert(self.mixedButtons, mapButton)
		end
	end

	self:RegisterEvent("UI_SCALE_CHANGED")
end


function hidingBar:setProfile(profileName)
	if profileName then
		self.charDB.currentProfileName = profileName
	end
	local currentProfileName, currentProfile, default = self.charDB.currentProfileName

	for i = 1, #self.profiles do
		local profile = self.profiles[i]
		if profile.name == currentProfileName then
			currentProfile = profile
			break
		end
		if profile.isDefault then
			default = profile
		end
	end

	if not currentProfile then
		self.charDB.currentProfileName = nil
		currentProfile = default
	end
	self.currentProfile = currentProfile
	self.pConfig = currentProfile.config

	if self.init then self:init() end

	for _, btn in ipairs(self.createdButtons) do
		self:setBtnSettings(btn)
	end

	for _, btn in ipairs(self.minimapButtons) do
		self:setMBtnSettings(btn)
	end

	local t = time()
	local tstmp = tonumber(self.db.tstmp) or t
	local maxTime = 7776000 -- 60 * 60 * 24 * 90 = 90 days and remove
	for k, s in pairs(self.pConfig.btnSettings) do
		if tstmp - (tonumber(s.tstmp) or 0) > maxTime then self.pConfig.btnSettings[k] = nil end
	end
	for k, s in pairs(self.pConfig.mbtnSettings) do
		if tstmp - (tonumber(s.tstmp) or 0) > maxTime then self.pConfig.mbtnSettings[k] = nil end
	end
	self.db.tstmp = t

	self:sort()
	self:updateBars()

	if self.init then
		self.cb:Fire("INIT")
		self.init = nil
	end
end


function hidingBar:updateBars()
	wipe(self.barByName)
	for i = 1, #self.currentProfile.bars do
		local bar = self.bars[i]
		local barSettings = self.currentProfile.bars[i]
		bar.name = barSettings.name
		bar.config = barSettings.config
		self.barByName[bar.name] = bar

		if bar.createOwnMinimapButton then
			bar:createOwnMinimapButton()
		end

		if barSettings.isDefault then
			self.defaultBar = bar
		end
	end

	for i = 1, #self.mixedButtons do
		self:setBtnParent(self.mixedButtons[i])
	end

	for i = 1, #self.bars do
		local bar = self.bars[i]

		if self.currentProfile.bars[i] then
			bar:setFrameStrata()
			bar:setLineColor()
			bar:setBackgroundColor()
			bar:setLineWidth()
			bar.drag:setShowHandler()
			bar:setBarTypePosition()
			bar:updateDragBarPosition()
			bar:setButtonSize()
		else
			bar:Hide()
			bar.drag:Hide()
			ldbi:Hide(bar.ombName)
		end
	end
end


function hidingBar:setBtnSettings(btn)
	local btnData = self.pConfig.btnSettings[btn.name]
	btnData.tstmp = time()
	btnSettings[btn] = btnData
	btn:SetClipsChildren(btnData[4])
end


function hidingBar:setMBtnSettings(btn)
	local name = btn:GetName()
	if name then
		local btnData = self.pConfig.mbtnSettings[name]
		btnData.tstmp = time()
		btnSettings[btn] = btnData
		btn:SetClipsChildren(btnData[4])
	end
end


function hidingBar:setBtnParent(btn)
	local btnData = btnSettings[btn]
	self.SetParent(btn, self.barByName[btnData and btnData[3]] or self.defaultBar)
end


function hidingBar:ldb_add(event, name, data)
	if name and data and data.type == "launcher" then
		self:addButton(name, data, event)
	end
end


function hidingBar:ldb_attrChange(_, name, key, value, data)
	if not data or data.type ~= "launcher" then return end
	local button = createdButtonsByName[name]
	if button then
		if key == "icon" then
			button.icon:SetTexture(value)
		elseif key == "iconCoords" then
			button.icon:SetTexCoord(unpack(value))
		elseif key == "iconR" then
			local _, g, b = button.icon:GetVertexColor()
			button.icon:SetVertexColor(value, g, b)
		elseif key == "iconG" then
			local r, _, b = button.icon:GetVertexColor()
			button.icon:SetVertexColor(r, value, b)
		elseif key == "iconB" then
			local r, g = button.icon:GetVertexColor()
			button.icon:SetVertexColor(r, g, value)
		elseif key == "iconDesaturated" then
			button.icon:SetDesaturated(value)
		end
	end
end


do
	local function IsShown(btn)
		local show = not btnSettings[btn][1]
		btn:SetShown(show)
		return show
	end

	--[[
	OnEnter         - Handler OnEnter
	OnLeave         - Handler OnLeave
	OnClick         - Handler OnClick
	icon            - Texture icon
	iconCoords      - Table with coords
	iconR           - icon R color (RGB)
	iconG           - icon G color (RGB)
	iconB           - icon B color (RGB)
	iconDesaturated - Desaturated icon (boolean)
	OnTooltipShow   - Handler tooltip show: function(TooltipFrame) .. end
	]]
	function hidingBar:addButton(name, data, update)
		if createdButtonsByName[name] then return end
		local button = CreateFrame("BUTTON", ("ADDON_%s_%s"):format(addon, name), nil, "HidingBarAddonCreatedButtonTemplate")
		createdButtonsByName[name] = button
		button.name = name
		button.data = data
		if data.icon then
			button.icon:SetTexture(data.icon)
			button.iconTex = data.icon
			if data.iconCoords then
				button.iconCoords = {unpack(data.iconCoords)}
				button.icon:SetTexCoord(unpack(data.iconCoords))
			end
			button.iconR = data.iconR
			button.iconG = data.iconG
			button.iconB = data.iconB
			button.icon:SetVertexColor(data.iconR or 1, data.iconG or 1, data.iconB or 1)
			if data.iconDesaturated ~= nil then
				button.iconDesaturated = data.iconDesaturated
				button.icon:SetDesaturated(data.iconDesaturated)
			end
		end
		button:HookScript("OnEnter", enter)
		button:HookScript("OnLeave", leave)
		button.IsShown = IsShown
		tinsert(self.createdButtons, button)
		tinsert(self.mixedButtons, button)

		if update then
			self:setBtnSettings(button)
			self:setBtnParent(button)
			self:sort()
			button:GetParent():setButtonSize()
			self.cb:Fire("BUTTON_ADDED", name, button, true)
		end

		if self.MSQ_Button then
			if data.iconCoords then self:setTexCurCoord(button.icon, unpack(data.iconCoords)) end
			button.icon.SetTexCoord = self.setTexCoord
			button:SetHighlightTexture(" ")
			local buttonData = {
				Icon = button.icon,
				Highlight = button:GetHighlightTexture(),
			}
			buttonData.Highlight:SetTexture()
			self.MSQ_Button:AddButton(button, buttonData, "Legacy", true)
			self:MSQ_CoordUpdate(button)
		end

		return button
	end
end


function hidingBar:addCustomGrabButton(name)
	local button = _G[name]
	if button then
		for j = 1, #self.minimapButtons do
			if button == self.minimapButtons[j] then
				return
			end
		end
		return self:addMButton(button, true, self.MSQ_CGButton)
	end
end


function hidingBar:ldbi_add(_, button, name)
	if not name:match(matchName) and self:addMButton(button) then
		self:setMBtnSettings(button)
		self:setBtnParent(button)
		self:sort()
		button:GetParent():setButtonSize()
		self.cb:Fire("MBUTTON_ADDED", button:GetName(), button.icon, true)
	end
end


function hidingBar:grabMinimapAddonsButtons(parentFrame)
	for _, child in ipairs({parentFrame:GetChildren()}) do
		local width, height = child:GetSize()
		if math.max(width, height) > 16 and math.abs(width - height) < 5 then
			self:addMButton(child)
		end
	end
end


function hidingBar:addMButton(button, force, MSQ_Group)
	local name = button:GetName()
	if not ignoreFrameList[name] and self:ignoreCheck(name) then
		if button:HasScript("OnClick") and button:GetScript("OnClick")
		or button:HasScript("OnMouseUp") and button:GetScript("OnMouseUp")
		or button:HasScript("OnMouseDown") and button:GetScript("OnMouseDown")
		or force then
			local btn = self.minimapButtons[button[0]]
			self.minimapButtons[button[0]] = nil
			if btn ~= button then
				self:setHooks(button)
			end

			if self.MSQ_MButton and button:GetObjectType() == "Button" then
				self:setMButtonRegions(button, nil, MSQ_Group)
			end

			local function OnEnter() enter(button) end
			local function OnLeave() leave(button) end

			local function setMouseEvents(frame)
				if frame:IsMouseEnabled() then
					self.SetHitRectInsets(frame, 0, 0, 0, 0)
					self.HookScript(frame, "OnEnter", OnEnter)
					self.HookScript(frame, "OnLeave", OnLeave)
				end
				for _, fchild in ipairs({frame:GetChildren()}) do
					setMouseEvents(fchild)
				end
			end
			setMouseEvents(button)

			self.SetFixedFrameStrata(button, false)
			self.SetFixedFrameLevel(button, false)
			self.SetAlpha(button, 1)
			tinsert(self.minimapButtons, button)
			tinsert(self.mixedButtons, button)
			return true
		else
			local mouseEnabled, clickable = {}
			local function getMouseEnabled(frame)
				if frame:IsMouseEnabled() then
					tinsert(mouseEnabled, frame)
					if frame:HasScript("OnClick") and frame:GetScript("OnClick")
					or frame:HasScript("OnMouseUp") and frame:GetScript("OnMouseUp")
					or frame:HasScript("OnMouseDown") and frame:GetScript("OnMouseDown") then
						clickable = true
					end
				end
				for _, fchild in ipairs({frame:GetChildren()}) do
					getMouseEnabled(fchild)
				end
			end
			getMouseEnabled(button)

			if clickable then
				self:setHooks(button)

				local function OnEnter() enter(button) end
				local function OnLeave() leave(button) end

				for _, frame in ipairs(mouseEnabled) do
					self.SetHitRectInsets(frame, 0, 0, 0, 0)
					self.HookScript(frame, "OnEnter", OnEnter)
					self.HookScript(frame, "OnLeave", OnLeave)
				end

				self.SetFixedFrameStrata(button, false)
				self.SetFixedFrameLevel(button, false)
				self.SetAlpha(button, 1)
				tinsert(self.minimapButtons, button)
				tinsert(self.mixedButtons, button)
				return true
			end
		end
	end
end


do
	local function IsShown(btn)
		local btnData = btnSettings[btn]
		local show = not (btnData and btnData[1])
		hidingBar.SetShown(btn, show)
		return show
	end

	local function CreateAnimationGroup(self, ...)
		local animationGroup = getmetatable(self).__index.CreateAnimationGroup(self, ...)
		animationGroup.Play = void
		return animationGroup
	end

	local function SetScript(self, event, func, ...)
		event = event:lower()
		if func == nil or event ~= "onupdate" and event ~= "ondragstart" and event ~= "ondragstop" then
			getmetatable(self).__index.SetScript(self, event, func, ...)
		end
	end

	function hidingBar:setHooks(btn)
		btn.CreateAnimationGroup = CreateAnimationGroup
		for _, animationGroup in ipairs({btn:GetAnimationGroups()}) do
			local disable
			for _, animation in ipairs({animationGroup:GetAnimations()}) do
				if animation:GetTarget() == btn then
					local animType = animation:GetObjectType()
					if animType ~= "Animation" and animType ~= "Rotation" then
						disable = true
						break
					end
				end
			end
			if disable then
				animationGroup:Stop()
				animationGroup.Play = void
			end
		end
		btn.SetFixedFrameStrata = void
		btn.SetFixedFrameLevel = void
		btn.SetHitRectInsets = void
		btn.ClearAllPoints = void
		btn.StartMoving = void
		btn.SetParent = void
		btn.Show = void
		btn.Hide = void
		btn.IsShown = IsShown
		btn.SetShown = void
		btn.SetPoint = void
		btn.SetAlpha = void
		btn.SetScale = void
		btn.SetSize = void
		btn.SetWidth = void
		btn.SetHeight = void
		btn.Disable = void
		btn.SetEnabled = void
		btn.HookScript = void
		btn.SetScript = SetScript
	end
end


function hidingBar:sort()
	sort(self.createdButtons, function(a, b)
		local o1, o2 = btnSettings[a][2], btnSettings[b][2]
		return o1 and not o2
			or o1 and o2 and o1 < o2
			or o1 == o2 and a.name < b.name
	end)
	local btnSort = function(a, b)
		local o1 = btnSettings[a] and btnSettings[a][2]
		local o2 = btnSettings[b] and btnSettings[b][2]
		if o1 and not o2 or o1 and o2 and o1 < o2 then return true
		elseif o1 ~= o2 then return false end

		local n1, n2 = a:GetName(), b:GetName()
		return n1 and not n2
			or n1 and n2 and n1 < n2
	end
	sort(self.minimapButtons, btnSort)
	sort(self.mixedButtons, btnSort)
end


function hidingBar:setClipButtons()
	for _, btn in ipairs(self.mixedButtons) do
		local btnData = btnSettings[btn]
		if btnData then
			btn:SetClipsChildren(btnData[4])
		end
	end
end


-------------------------------------------
-- HIDINGBAR MIXIN
-------------------------------------------
local hidingBarMixin = {}


function hidingBarMixin:createOwnMinimapButton()
	self.createOwnMinimapButton = nil
	self.ombName = addon..self.id
	self.ldb_icon = ldb:NewDataObject(self.ombName, {
		type = "data source",
		text = self.ombName,
		icon = "Interface/MINIMAP/Vehicle-SilvershardMines-Arrow",
		OnClick = function(_, button)
			if button == "LeftButton" then
				if self:IsShown() and self.config.showHandler ~= 3 then
					self:Hide()
				else
					local func = self.drag:GetScript("OnClick")
					if func then func(self.drag) end
				end
			elseif button == "RightButton" then
				if IsAltKeyDown() then
					self:setLocked(not self.config.lock)
					self.cb:Fire("LOCK_UPDATED", self.config.lock, self)
				end
				if IsShiftKeyDown() then
					config:openConfig()
				end
			end
		end,
		OnEnter = function()
			local func = self.drag:GetScript("OnEnter")
			if func then func(self.drag) end
		end,
		OnLeave = function()
			local func = self.drag:GetScript("OnLeave")
			if func then func(self.drag) end
		end,
	})
	ldbi:Register(self.ombName, self.ldb_icon, self.config.omb)
end


function hidingBarMixin:setLineColor(r, g, b)
	local color = self.config.lineColor
	if r then color[1] = r end
	if g then color[2] = g end
	if b then color[3] = b end
	self.drag.bg:SetColorTexture(unpack(color))
end


function hidingBarMixin:setBackgroundColor(r, g, b, a)
	local color = self.config.bgColor
	if r then color[1] = r end
	if g then color[2] = g end
	if b then color[3] = b end
	if a then color[4] = a end
	self.bg:SetVertexColor(unpack(color))
end


function hidingBarMixin:setOrientation(orientation)
	self.config.orientation = orientation
	self:applyLayout()
end


function hidingBarMixin:setFade(fade)
	self.config.fade = fade
	if fade and self.drag:IsShown() then
		UIFrameFadeOut(self.drag, 1.5, self.drag:GetAlpha(), self.config.fadeOpacity)
	else
		UIFrameFadeRemoveFrame(self.drag)
		self.drag:SetAlpha(1)
	end
end


function hidingBarMixin:setFadeOpacity(opacity)
	self.config.fadeOpacity = opacity
	UIFrameFadeRemoveFrame(self.drag)
	self.drag:SetAlpha(opacity)
end


function hidingBarMixin:setLineWidth(width)
	if width then self.config.lineWidth = width end
	self.drag:SetSize(self.config.lineWidth, self.config.lineWidth)
end


function hidingBarMixin:setMaxButtons(size)
	self.config.size = size
	self:applyLayout()
end


function hidingBarMixin:setButtonSize(size)
	if size then self.config.buttonSize = size end

	for _, btn in ipairs(hidingBar.createdButtons) do
		if btn:GetParent() == self then
			btn:SetScale(self.config.buttonSize / btn:GetWidth())
		end
	end
	for _, btn in ipairs(hidingBar.minimapButtons) do
		if btn:GetParent() == self then
			local width, height = btn:GetSize()
			local maxSize = width > height and width or height
			self.SetScale(btn, self.config.buttonSize / maxSize)
		end
	end

	self:applyLayout()
end


function hidingBarMixin:setMBtnPosition(position)
	self.config.mbtnPosition = position
	self:applyLayout()
end


function hidingBarMixin:setPointBtn(btn, order, orientation)
	order = order - 1
	local halfSize = self.config.buttonSize / 2
	local x = order % self.config.size * self.config.buttonSize + halfSize + offsetX
	local y = -math.floor(order / self.config.size) * self.config.buttonSize - halfSize - offsetY
	if orientation then x, y = -y, -x end
	self.ClearAllPoints(btn)
	local scale = btn:GetScale()
	self.SetPoint(btn, "CENTER", self, "TOPLEFT", x / scale, y / scale)
end


function hidingBarMixin:applyLayout()
	local orientation
	if self.config.orientation == 0 then
		orientation = self.anchorObj.anchor == "top" or self.anchorObj.anchor == "bottom"
	else
		orientation = self.config.orientation == 2
	end

	local i, maxButtons, line = 0
	if self.config.mbtnPosition == 2 then
		for _, btn in ipairs(hidingBar.mixedButtons) do
			if btn:GetParent() == self and btn:IsShown() then
				i = i + 1
				self:setPointBtn(btn, i, orientation)
			end
		end
		self.shown = i ~= 0
		maxButtons = i
		line = math.ceil(i / self.config.size)
	else
		for _, btn in ipairs(hidingBar.createdButtons) do
			if btn:GetParent() == self and btn:IsShown() then
				i = i + 1
				self:setPointBtn(btn, i, orientation)
			end
		end
		local followed = self.config.mbtnPosition == 1
		local orderDelta = followed and i or math.ceil(i / self.config.size) * self.config.size
		local j = 0
		for _, btn in ipairs(hidingBar.minimapButtons) do
			if btn:GetParent() == self and btn:IsShown() then
				j = j + 1
				self:setPointBtn(btn, j + orderDelta, orientation)
			end
		end
		self.shown = i + j ~= 0
		maxButtons = followed and i + j or i > j and i or j
		line = math.ceil((j + orderDelta) / self.config.size)
	end

	self:refreshShown()

	if maxButtons > self.config.size then maxButtons = self.config.size end
	local width = maxButtons * self.config.buttonSize + offsetX * 2
	local height = line * self.config.buttonSize + offsetY * 2
	if orientation then width, height = height, width end
	self:SetSize(width, height)
	return width, height
end


function hidingBarMixin:setLocked(lock)
	self.config.lock = lock
	self:refreshShown()
	if lock then
		ldbi:Lock(self.ombName)
	else
		ldbi:Unlock(self.ombName)
	end
end


function hidingBarMixin:setFrameStrata(strata)
	if strata then self.config.frameStrata = strata end

	if self.config.frameStrata == 5 then
		strata = "TOOLTIP"
	elseif self.config.frameStrata == 4 then
		strata = "FULLSCREEN_DIALOG"
	elseif self.config.frameStrata == 3 then
		strata = "FULLSCREEN"
	elseif self.config.frameStrata == 2 then
		strata = "DIALOG"
	elseif self.config.frameStrata == 1 then
		strata = "HIGH"
	else
		strata = "MEDIUM"
	end

	self:SetFrameStrata(strata)
	self.drag:SetFrameStrata(strata)
end


function hidingBarMixin:updateDragBarPosition()
	local anchor = self.config.anchor
	self.drag:ClearAllPoints()
	if self:IsShown() then
		if anchor == "left" then
			self.drag:SetPoint("TOPLEFT", self, "TOPRIGHT")
			self.drag:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT")
		elseif anchor == "right" then
			self.drag:SetPoint("TOPRIGHT", self, "TOPLEFT")
			self.drag:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT")
		elseif anchor == "top" then
			self.drag:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
			self.drag:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
		else
			self.drag:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
			self.drag:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT")
		end
	else
		if anchor == "left" then
			self.drag:SetPoint("TOPLEFT", self, "TOPLEFT")
			self.drag:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
		elseif anchor == "right" then
			self.drag:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			self.drag:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
		elseif anchor == "top" then
			self.drag:SetPoint("TOPLEFT", self, "TOPLEFT")
			self.drag:SetPoint("TOPRIGHT", self, "TOPRIGHT")
		else
			self.drag:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
			self.drag:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
		end
	end
end


function hidingBarMixin:setOMBAnchor(anchor)
	if self.config.barTypePosition ~= 2 or self.config.omb.anchor == anchor then return end
	self.config.omb.anchor = anchor
	self:applyLayout()
	self:setBarTypePosition()
end


function hidingBarMixin:setOMBSize(size)
	if size then self.config.omb.size = size end
	if self.omb then
		local oldScale = self.omb:GetScale()
		self.omb:SetScale(self.config.omb.size / self.omb:GetWidth())
		for i = 1, self.omb:GetNumPoints() do
			local point, rFrame, rPoint, x, y = self.omb:GetPoint(i)
			self.omb:SetPoint(point, rFrame, rPoint, x * oldScale, y * oldScale)
		end
	end
end


function hidingBarMixin:setBarAnchor(anchor)
	if self.config.barTypePosition ~= 1 or self.config.anchor == anchor then return end
	local x, y, position, secondPosition = self:GetCenter()
	self.config.anchor = anchor
	local width, height = self:applyLayout()
	width, height = width / 2, height / 2

	if anchor == "left" or anchor == "right" then
		if self.config.expand == 0 then
			position = y + height
		elseif self.config.expand == 1 then
			position = y - height
		else
			position = y
		end
	else
		if self.config.expand == 0 then
			position = x - width
		elseif self.config.expand == 1 then
			position = x + width
		else
			position = x
		end
	end

	if anchor == "left" then
		secondPosition = x - width
	elseif anchor == "right" then
		secondPosition = x + width - UIParent:GetWidth()
	elseif anchor == "top" then
		secondPosition = y + height - UIParent:GetHeight()
	else
		secondPosition = y - height
	end

	self:setBarCoords(position, secondPosition)
	self:updateBarPosition()
end


function hidingBarMixin:setBarExpand(expand)
	if self.config.expand == expand then return end
	local anchor, delta, position = self.config.anchor
	local scale = UIParent:GetScale()

	if anchor == "left" or anchor == "right" then
		delta = self:GetHeight()
	else
		delta = -self:GetWidth()
	end

	if self.config.expand == 2 or expand == 2 then
		delta = delta / 2
		if self.config.expand == 1 then delta = -delta end
	end

	if expand == 0 then
		position = self.config.position / scale + delta
	else
		position = self.config.position / scale - delta
	end
	self.config.expand = expand

	self:setBarCoords(position)
	self:setBarTypePosition()
end


function hidingBarMixin:setBarTypePosition(typePosition)
	if typePosition then self.config.barTypePosition = typePosition end

	if self.config.barTypePosition == 2 then
		self.config.omb.hide = false
		ldbi:Show(self.ombName)
		if self.config.lock then
			ldbi:Lock(self.ombName)
		else
			ldbi:Unlock(self.ombName)
		end

		if not self.omb then
			self.omb = ldbi:GetMinimapButton(self.ombName)
			self.omb.dSetPoint = self.omb.SetPoint
			self.omb.SetPoint = function(self, point, rFrame, rPoint, x, y)
				local scale = self:GetScale()
				if not rFrame or type(rFrame) == "number" then
					rFrame = (rFrame or 0) / scale
					rPoint = (rPoint or 0) / scale
				elseif not rPoint or type(rPoint) == "number" then
					rPoint = (rPoint or 0) / scale
					x = (x or 0) / scale
				else
					x = (x or 0) / scale
					y = (y or 0) / scale
				end
				self:dSetPoint(point, rFrame, rPoint, x, y)
			end
			self:setOMBSize()
			if MSQ then
				if not hidingBar.MSQ_OMB then
					hidingBar.MSQ_OMB = MSQ:Group(addon, L["Own Minimap Button"], "OMB")
					hidingBar.MSQ_OMB:SetCallback(function()
						hidingBar:MSQ_Button_Update(self.omb)
						hidingBar:MSQ_CoordUpdate(self.omb)
					end)
				end
				hidingBar:setMButtonRegions(self.omb, nil, hidingBar.MSQ_OMB)
			end
		end

		local btnSize, position, secondPosition = self.config.omb.size
		if self.config.omb.anchor == "left" or self.config.omb.anchor == "right" then
			if self.config.expand == 0 then
				position = btnSize + offsetY
			elseif self.config.expand == 1 then
				position = -offsetY
			else
				position = btnSize / 2
			end
		else
			if self.config.expand == 0 then
				position = -offsetX
			elseif self.config.expand == 1 then
				position = btnSize + offsetX
			else
				position = btnSize / 2
			end
		end

		if self.config.omb.anchor == "left" then
			secondPosition = btnSize
			self.omb.icon:SetRotation(-math.pi/2)
		elseif self.config.omb.anchor == "right" then
			secondPosition = -btnSize
			self.omb.icon:SetRotation(math.pi/2)
		elseif self.config.omb.anchor == "top" then
			secondPosition = -btnSize
			self.omb.icon:SetRotation(math.pi)
		else
			secondPosition = btnSize
			self.omb.icon:SetRotation(0)
		end

		self.anchorObj = self.config.omb
		self.rFrame = self.omb
		self.position = position
		self.secondPosition = secondPosition
	else
		self.config.omb.hide = true
		ldbi:Hide(self.ombName)
		self.anchorObj = self.config
		self.rFrame = UIParent
		self.position = nil
		self.secondPosition = nil
	end

	if typePosition then self:applyLayout() end
	self:updateBarPosition()
end


function hidingBarMixin:setBarCoords(position, secondPosition)
	local scale = UIParent:GetScale()

	if position then
		self.position = position
		self.config.position = position * scale
	end

	if secondPosition then
		self.secondPosition = secondPosition
		self.config.secondPosition = secondPosition * scale
	end
end


do
	local pointForExpand = {
		left   = {[0] = "TOPLEFT",    "BOTTOMLEFT",  "LEFT"},
		right  = {[0] = "TOPRIGHT",   "BOTTOMRIGHT", "RIGHT"},
		top    = {[0] = "TOPLEFT",    "TOPRIGHT",    "TOP"},
		bottom = {[0] = "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOM"},
	}

	function hidingBarMixin:updateBarPosition()
		local anchor = self.anchorObj.anchor

		if not self.position then
			if not self.config.position then
				if anchor == "left" or anchor =="right" then
					self.config.position = WorldFrame:GetHeight() / 2
				else
					self.config.position = WorldFrame:GetWidth() / 2
				end
			end
			self.position = self.config.position / UIParent:GetScale()
		end

		if not self.secondPosition then
			if not self.config.secondPosition then
				self.config.secondPosition = 0
			end
			self.secondPosition = self.config.secondPosition / UIParent:GetScale()
		end

		hidingBar.cb:Fire("COORDS_UPDATED", self)

		local point = pointForExpand[anchor][self.config.expand]
		self:ClearAllPoints()
		if anchor == "left" then
			self:SetPoint(point, self.rFrame, "BOTTOMLEFT", self.secondPosition, self.position)
		elseif anchor == "right" then
			self:SetPoint(point, self.rFrame, "BOTTOMRIGHT", self.secondPosition, self.position)
		elseif anchor == "top" then
			self:SetPoint(point, self.rFrame, "TOPLEFT", self.position, self.secondPosition)
		else
			self:SetPoint(point, self.rFrame, "BOTTOMLEFT", self.position, self.secondPosition)
		end
	end
end


function hidingBarMixin:dragBar()
	local x, y = GetCursorPosition()
	local width, height = self:GetSize()
	local UIwidth, UIheight = UIParent:GetSize()
	local anchor = self.config.anchor
	local secondPosition, position = 0
	local scale = UIParent:GetScale()
	x, y = x / scale, y / scale

	if self.config.barTypePosition == 0 then
		local offset = 70 / scale

		if not IsShiftKeyDown() then
			local delta = 10 / scale
			if anchor == "top" or anchor == "bottom" then
				local halfWidth = UIwidth / 2
				if math.abs(halfWidth - x) < delta then
					x = halfWidth
				end
			else
				local halfHeight = UIheight / 2
				if math.abs(halfHeight - y) < delta then
					y = halfHeight
				end
			end
		end

		if anchor == "left" and x > width
		or anchor == "right" and x < UIwidth - width then
			if y > UIheight - offset then
				anchor = "top"
			elseif y < offset then
				anchor = "bottom"
			end
		elseif anchor == "top" and y < UIheight - height
		or anchor == "bottom" and y > height then
			if x < offset then
				anchor = "left"
			elseif x > UIwidth - offset then
				anchor = "right"
			end
		end

		if anchor ~= self.config.anchor then
			self.config.anchor = anchor
			width, height = self:applyLayout()
			self:updateDragBarPosition()

			hidingBar.cb:Fire("ANCHOR_UPDATED", self.config.anchor, self)
		end
	end

	if anchor == "left" or anchor == "right" then
		local delta
		if self.config.expand == 0 then
			delta = -height / 2
		elseif self.config.expand == 1 then
			delta = height / 2
		else
			delta = 0
		end
		position = y - delta
		if self.config.barTypePosition == 1 then
			local dhWidth = self.drag:GetWidth() / 2
			delta = anchor == "left" and width + dhWidth or UIwidth - width - dhWidth
			secondPosition = x - delta
		end
	else
		local delta
		if self.config.expand == 0 then
			delta = width / 2
		elseif self.config.expand == 1 then
			delta = -width / 2
		else
			delta = 0
		end
		position = x - delta
		if self.config.barTypePosition == 1 then
			local dhHeight = self.drag:GetHeight() / 2
			delta = anchor == "top" and UIheight - height - dhHeight or height + dhHeight
			secondPosition = y - delta
		end
	end

	self:setBarCoords(position, secondPosition)
	self:updateBarPosition()
end


function hidingBarMixin:enter(force)
	if not self.isDrag and self.shown and (self.config.showHandler ~= 3 or force) then
		UIFrameFadeRemoveFrame(self.drag)
		self.drag:SetAlpha(1)
		self:SetScript("OnUpdate", nil)
		self:Show()
		self:Raise()
		self:updateDragBarPosition()
	end
end


function hidingBarMixin:hideBar(elapsed)
	self.timer = self.timer - elapsed
	if self.timer <= 0 then
		self:Hide()
		self:updateDragBarPosition()
		self:SetScript("OnUpdate", nil)
		if self.config.fade and self.drag:IsShown() then
			UIFrameFadeOut(self.drag, 1.5, self.drag:GetAlpha(), self.config.fadeOpacity)
		end
	end
end


function hidingBarMixin:leave(timer)
	if not self.isDrag and self:IsShown() and self.config.showHandler ~= 3 then
		self.timer = timer or self.config.hideDelay
		self:SetScript("OnUpdate", self.hideBar)
	end
end


function hidingBarMixin:refreshShown()
	if not self.shown then
		self:Hide()
		self.drag:Hide()
	elseif self.config.barTypePosition == 2 then
		self.drag:Hide()
		if self.config.showHandler == 3 then
			self:enter(true)
		elseif self:IsShown() and not self.isMouse then
			self:leave()
		end
	elseif self.config.showHandler == 3 then
		self:enter(true)
		self.drag:SetShown(not self.config.lock)
	else
		if self:IsShown() then
			if not self.isMouse then
				self:leave()
			end
		else
			self:updateDragBarPosition()
			if self.config.fade then
				UIFrameFadeOut(self.drag, 1.5, self.drag:GetAlpha(), self.config.fadeOpacity)
			end
		end
		self.drag:Show()
	end
end


-------------------------------------------
-- HIDINGBAR DRAG MIXIN
-------------------------------------------
local hidingBarDragMixin = {}


function hidingBarDragMixin:hoverWithClick()
	local bar = self.bar
	if bar:IsShown() then
		bar:enter()
	elseif self:IsShown() and bar.config.fade then
		UIFrameFadeOut(self, bar.config.showDelay, self:GetAlpha(), 1)
	end
end


function hidingBarDragMixin:showOnClick()
	self.bar:enter()
end


function hidingBarDragMixin:showBarDelay(elapsed)
	self.timer = self.timer - elapsed
	if self.timer <= 0 then
		self:SetScript("OnUpdate", nil)
		self.bar:enter()
	end
end


function hidingBarDragMixin:showOnHoverWithDelay()
	local bar = self.bar
	if bar:IsShown() or bar.config.showDelay == 0 then
		bar:enter()
	else
		if self:IsShown() and bar.config.fade then
			UIFrameFadeOut(self, bar.config.showDelay, self:GetAlpha(), 1)
		end
		fTimer.bar = bar
		fTimer.timer = bar.config.showDelay
		fTimer:SetScript("OnUpdate", self.showBarDelay)
	end
end


function hidingBarDragMixin:setShowHandler(showHandler)
	local bar = self.bar
	if showHandler then bar.config.showHandler = showHandler end

	if bar.config.showHandler == 3 then
		self:SetScript("OnEnter", nil)
		self:SetScript("OnClick", nil)
	elseif bar.config.showHandler == 2 then
		self:SetScript("OnEnter", self.showOnHoverWithDelay)
		self:SetScript("OnClick", self.showOnClick)
	elseif bar.config.showHandler == 1 then
		self:SetScript("OnEnter", self.hoverWithClick)
		self:SetScript("OnClick", self.showOnClick)
	else
		self:SetScript("OnEnter", self.showOnHoverWithDelay)
		self:SetScript("OnClick", nil)
	end

	bar:refreshShown()
end


-------------------------------------------
-- CREATE BAR
-------------------------------------------
local function bar_OnEnter(self)
	self.isMouse = true
	self:enter()
end


local function bar_OnLeave(self)
	self.isMouse = false
	self:leave()
end


local function drag_OnMouseDown(self, button)
	local bar = self.bar
	if button == "LeftButton" and not bar.config.lock and bar:IsShown() then
		bar.isDrag = true
		cover:SetFrameStrata(bar:GetFrameStrata())
		cover:SetFrameLevel(bar:GetFrameLevel() + 10)
		cover:SetAllPoints(bar)
		cover:Show()
		bar:SetScript("OnUpdate", bar.dragBar)
	elseif button == "RightButton" then
		if IsAltKeyDown() then
			bar:setLocked(not bar.config.lock)
			hidingBar.cb:Fire("LOCK_UPDATED", bar.config.lock, bar)
		end
		if IsShiftKeyDown() then
			config:openConfig()
		end
	end
end


local function drag_OnMouseUp(self, button)
	local bar = self.bar
	if button == "LeftButton" and bar.isDrag then
		bar.isDrag = false
		cover:Hide()
		bar:SetScript("OnUpdate", nil)
		if not bar.isMouse then
			bar:leave()
		end
	end
end


local function drag_OnLeave(self)
	fTimer:SetScript("OnUpdate", nil)
	local bar = self.bar
	if bar.config.fade and not bar:IsShown() and self:IsShown() then
		UIFrameFadeOut(self, bar.config.showDelay, self:GetAlpha(), bar.config.fadeOpacity)
	end
	bar:leave()
end


setmetatable(hidingBar.bars, {__index = function(self, key)
	local bar = CreateFrame("FRAME", nil, UIParent, "HidingBarAddonPanel")
	bar:SetClampedToScreen(true)
	bar:SetScript("OnEnter", bar_OnEnter)
	bar:SetScript("OnLeave", bar_OnLeave)
	for k, v in pairs(hidingBarMixin) do
		bar[k] = v
	end

	bar.drag = CreateFrame("BUTTON", nil, UIParent)
	bar.drag.bar = bar
	bar.drag:SetClampedToScreen(true)
	bar.drag:SetHitRectInsets(-2, -2, -2, -2)
	bar.drag:SetFrameLevel(bar:GetFrameLevel() + 10)
	bar.drag.bg = bar.drag:CreateTexture(nil, "OVERLAY")
	bar.drag.bg:SetAllPoints()
	bar.drag:SetScript("OnMouseDown", drag_OnMouseDown)
	bar.drag:SetScript("OnMouseUp", drag_OnMouseUp)
	bar.drag:SetScript("OnLeave", drag_OnLeave)
	for k, v in pairs(hidingBarDragMixin) do
		bar.drag[k] = v
	end

	bar.id = key
	self[key] = bar
	return bar
end})