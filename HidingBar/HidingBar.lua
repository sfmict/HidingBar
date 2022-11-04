local addon, L = ...
local config, UIParent = _G[addon.."ConfigAddon"], UIParent
local hb = CreateFrame("FRAME", addon.."Addon")
local cover = CreateFrame("FRAME")
cover:Hide()
cover:EnableMouse(true)
local btnSettingsMeta = {__index = function(self, key)
	self[key] = {tstmp = 0}
	return self[key]
end}
local createdButtonsByName, btnSettings, noGMEFrames = {}, {}, {}
hb.ldbiPrefix = "LibDBIcon10_"
hb.matchName = hb.ldbiPrefix..addon.."%d+$"
hb.createdButtons, hb.minimapButtons, hb.mixedButtons = {}, {}, {}
hb.btnParams, hb.manuallyButtons = {}, {}
hb.bars, hb.barByName = {}, {}
local LibStub = LibStub
hb.cb = LibStub("CallbackHandler-1.0"):New(hb, "on", "off")
local ldb = LibStub("LibDataBroker-1.1")
local ldbi = LibStub("LibDBIcon-1.0")
local media = LibStub("LibSharedMedia-3.0")
local MSQ = LibStub("Masque", true)


local ignoreFrameNameList = {
	["GameTimeFrame"] = true,
	["HelpOpenWebTicketButton"] = true,
	["MinimapBackdrop"] = true,
	["ExpansionLandingPageMinimapButton"] = true,
	["QueueStatusButton"] = true,
	["AddonCompartmentFrame"] = true,
}


local ignoreFrameList = {
	[Minimap.ZoomIn] = true,
	[Minimap.ZoomOut] = true,
	[MinimapCluster.Tracking] = true,
	[MinimapCluster.MailFrame] = true,
}


local function void() end

local function enter(btn, _, eventFrame)
	local bar = btn:GetParent()
	if not bar:IsShown() then return end
	bar.isMouse = true
	bar:enter()

	if bar.config.interceptTooltip then
		bar:updateTooltipPosition(eventFrame or btn)
	end
end

local function leave(btn)
	local bar = btn:GetParent()
	if bar:IsShown() then
		bar.isMouse = false
		bar:leave()
	end
end

local function setOMBPoint(self, point, rFrame, rPoint, x, y)
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


if MSQ then
	hb.MSQ_Button = MSQ:Group(addon, L["DataBroker Buttons"], "DataBroker")
	hb.MSQ_Button:SetCallback(function()
		for btn in pairs(hb.MSQ_Button.Buttons) do
			hb:MSQ_CoordUpdate(btn)
		end
		for _, bar in ipairs(hb.bars) do
			bar:enter()
			bar:leave(math.max(1.5, bar.config.hideDelay))
		end
	end)


	local defAtlas = MSQ:GetSkin("Default").Normal.Atlas
	hb.MSQ_Button_Data = {}
	hb.MSQ_MButton = MSQ:Group(addon, L["Minimap Buttons"], "MinimapButtons")
	hb.MSQ_MButton:SetCallback(function()
		for btn in pairs(hb.MSQ_MButton.Buttons) do
			hb:MSQ_Button_Update(btn)
			hb:MSQ_CoordUpdate(btn)
		end
		for _, bar in ipairs(hb.bars) do
			bar:enter()
			bar:leave(math.max(1.5, bar.config.hideDelay))
		end
	end)


	hb.MSQ_CGButton = MSQ:Group(addon, L["Manually Grabbed Buttons"], "CGButtons")
	hb.MSQ_CGButton:SetCallback(function()
		for btn in pairs(hb.MSQ_CGButton.Buttons) do
			hb:MSQ_Button_Update(btn)
			hb:MSQ_CoordUpdate(btn)
		end
		for _, bar in ipairs(hb.bars) do
			bar:enter()
			bar:leave(math.max(1.5, bar.config.hideDelay))
		end
	end)


	local prevCoord, curCoord, MSQ_Coord = {}, {}, {}
	function hb:MSQ_CoordUpdate(btn)
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


	function hb:setTexCurCoord(icon, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
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


	hb.setTexCoord = function(self, ...)
		local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = hb:setTexCurCoord(self, ...)

		if MSQ_Coord[self] then
			local mULx, mULy, mLLx, mLLy, mURx, mURy, mLRx, mLRy = unpack(MSQ_Coord[self])
			local top = URx - ULx
			local right = LRy - URy
			local bottom = LRx - LLx
			local left = LLy - ULy
			URx = ULx + mURx * top
			ULx = ULx + mULx * top
			LRy = URy + mLRy * right
			URy = URy + mURy * right
			LRx = LLx + mLRx * bottom
			LLx = LLx + mLLx * bottom
			LLy = ULy + mLLy * left
			ULy = ULy + mULy * left
		end

		config.noIcon.SetTexCoord(self, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
	end


	function hb:MSQ_Button_Update(btn)
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
				data._Normal:SetTexture()
				if data._IsNormalIcon then
					btn.SetNormalTexture = function(_, value)
						if not value then return end
						if C_Texture.GetAtlasInfo(value) then
							data._Icon:SetAtlas(value)
						else
							data._Icon:SetTexture(value)
						end
					end
					data._Normal.SetAtlas = function(_, atlas)
						local skin = MSQ:GetSkin(data._Group.db.SkinID).Normal
						if atlas == skin.Atlas or atlas == defAtlas then
							data._isMSQCoord = true
							data._isMSQColor = true
						else
							data._Icon:SetAtlas(atlas)
						end
					end
					data._Normal.SetTexture = function(_, texture)
						if texture then
							local skin = MSQ:GetSkin(data._Group.db.SkinID).Normal
							if texture == skin.Texture then
								data._isMSQCoord = true
								data._isMSQColor = true
							else
								data._Icon:SetTexture(texture)
							end
						end
					end
					data._Normal.SetTexCoord = function(_, ...)
						if data._isMSQCoord then
							data._isMSQCoord = nil
						else
							data._Icon:SetTexCoord(...)
						end
					end
					data._Normal.SetVertexColor = function(_, ...)
						if data._isMSQColor then
							data._isMSQColor = nil
						else
							data._Icon:SetVertexColor(...)
						end
					end
					data._Normal = nil
				else
					data._Normal.SetAtlas = void
					data._Normal.SetTexture = void
				end
			end
			if data._Pushed then
				data._Pushed:SetAlpha(0)
				data._Pushed:SetTexture()
				data._Pushed.SetAlpha = void
				data._Pushed.SetAtlas = void
				data._Pushed.SetTexture = void
			end
			if data._Callback then
				data:_Callback(btn)
			end
		end
	end


	function hb:setMButtonRegions(btn, iconCoords, MSQ_Group)
		local name, texture, tIsString, layer, border, background, icon, highlight
		local isButton = btn:IsObjectType("Button")

		for _, region in ipairs({btn:GetRegions()}) do
			if region:IsObjectType("Texture") then
				name = region:GetDebugName():gsub(".*%.", ""):lower()
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

		local normal, isNormalIcon = isButton and btn:GetNormalTexture()
		if normal and (not icon or icon ~= btn.icon or icon == normal) then
			isNormalIcon = true
			icon = btn:CreateTexture(nil, "BACKGROUND")
			local atlas = normal:GetAtlas()
			if atlas then
				icon:SetAtlas(atlas)
			else
				icon:SetTexture(normal:GetTexture())
			end
			icon:SetTexCoord(normal:GetTexCoord())
			icon:SetVertexColor(normal:GetVertexColor())
			icon:SetSize(normal:GetSize())
			for i = 1, normal:GetNumPoints() do
				icon:SetPoint(normal:GetPoint(i))
			end
			self.HookScript(btn, "OnMouseDown", function() icon:SetScale(.9) end)
			self.HookScript(btn, "OnMouseUp", function() icon:SetScale(1) end)
		end

		if not highlight then
			highlight = isButton and btn:GetHighlightTexture() or btn:CreateTexture(nil, "HIGHLIGHT")
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

		local data = {
			Icon = icon,
			Highlight = highlight,
		}
		MSQ_Group = MSQ_Group or self.MSQ_MButton
		MSQ_Group:AddButton(btn, data, "Legacy", true)

		local pushed = isButton and btn:GetPushedTexture()
		if border or background or pushed or normal then
			self.MSQ_Button_Data[btn] = {
				_Border = border,
				_Background = background,
				_Pushed = pushed,
			}
			if normal then
				local data = self.MSQ_Button_Data[btn]
				data._Normal = normal
				data._IsNormalIcon = isNormalIcon
				data._Icon = icon
				data._Group = MSQ_Group
			end
		end
		self:MSQ_Button_Update(btn)
		self:MSQ_CoordUpdate(btn)
	end
end


hb:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
hb:RegisterEvent("ADDON_LOADED")


function hb:ADDON_LOADED(addonName)
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

		local config = self.profiles[1].config

		for i = 1, #self.profiles do
			self:checkProfile(self.profiles[i])
		end

		if self.db.config then
			if not config then
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
			end

			self.db.config = nil
		end

		C_Timer.After(0, function()
			self:setProfile()
			self.cb:Fire("INIT")
			self.init = nil
		end)
	end
end


function hb:checkProfile(profile)
	profile.config = profile.config or {}
	if profile.config.addFromDataBroker == nil then
		profile.config.addFromDataBroker = true
	end
	if profile.config.grabMinimap == nil then
		profile.config.grabMinimap = true
	end
	profile.config.ignoreMBtn = profile.config.ignoreMBtn or {"GatherMatePin", "TTMinimapButton"}
	profile.config.grabMinimapAfterN = profile.config.grabMinimapAfterN or 1
	profile.config.customGrabList = profile.config.customGrabList or {}
	profile.config.ombGrabQueue = profile.config.ombGrabQueue or {}
	profile.config.btnSettings = setmetatable(profile.config.btnSettings or {}, btnSettingsMeta)
	profile.config.mbtnSettings = setmetatable(profile.config.mbtnSettings or {}, btnSettingsMeta)
	--[[ BTN SETTINGS OBJECT
	[1] - is disabled
	[2] - order
	[3] - parent bar name
	[4] - is cliped button
	[5] - auto show/hide
	]]

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
		bar.config.hideHandler = bar.config.hideHandler or 2
		bar.config.hideDelay = bar.config.hideDelay or .75
		bar.config.size = bar.config.size or 10
		bar.config.barOffset = bar.config.barOffset or 2
		bar.config.buttonDirection = bar.config.buttonDirection or {V = 0, H = 0}
		if bar.config.interceptTooltip == nil then
			bar.config.interceptTooltip = true
		end
		bar.config.interceptTooltipPosition = bar.config.interceptTooltipPosition or 0
		bar.config.buttonSize = bar.config.buttonSize or 31
		bar.config.rangeBetweenBtns = bar.config.rangeBetweenBtns or 0
		bar.config.anchor = bar.config.anchor or "top"
		bar.config.barTypePosition = bar.config.barTypePosition or 0
		bar.config.mbtnPosition = bar.config.mbtnPosition or 2
		if bar.config.bgTexture == nil then
			bar.config.bgTexture = "Solid"
		end
		bar.config.bgColor = bar.config.bgColor or {.1, .1, .1, .7}
		if bar.config.borderEdge == nil then
			bar.config.borderEdge = false
		end
		bar.config.borderColor = bar.config.borderColor or {1, 1, 1, 1}
		bar.config.borderOffset = bar.config.borderOffset or 4
		bar.config.borderSize = bar.config.borderSize or 16
		bar.config.lineTexture = bar.config.lineTexture or "Solid"
		bar.config.lineColor = bar.config.lineColor or {.8, .6, 0}
		if bar.config.lineBorderEdge == nil then
			bar.config.lineBorderEdge = false
		end
		bar.config.lineBorderColor = bar.config.lineBorderColor or {1, 1, 1, 1}
		bar.config.lineBorderOffset = bar.config.lineBorderOffset or 1
		bar.config.lineBorderSize = bar.config.lineBorderSize or 2
		bar.config.gapSize = bar.config.gapSize or 0
		bar.config.omb = bar.config.omb or {}
		if bar.config.omb.hide == nil then
			bar.config.omb.hide = true
		end
		bar.config.omb.anchor = bar.config.omb.anchor or "right"
		bar.config.omb.size = bar.config.omb.size or 31
		bar.config.omb.distanceToBar = bar.config.omb.distanceToBar or 0
		bar.config.omb.barDisplacement = bar.config.omb.barDisplacement or 0
	end

	local ombGrabQueue =  profile.config.ombGrabQueue
	for i = 1, #ombGrabQueue do
		if type(ombGrabQueue[i]) ~= "number" then
			for j = 1, #profile.bars do
				if ombGrabQueue[i] == profile.bars[j].name then
					ombGrabQueue[i] = j
				end
			end
		end
	end
end


function hb:UI_SCALE_CHANGED()
	for _, bar in ipairs(self.bars) do
		bar:setBarTypePosition()
		bar:setBorder()
		bar:setLineBorder()
	end
end


function hb:ignoreCheck(name)
	if not name then return self.pConfig.grabMinimapWithoutName end
	if name:match(self.matchName) then return end
	for i = 1, #self.pConfig.ignoreMBtn do
		if name:match(self.pConfig.ignoreMBtn[i]) then return end
	end
	return true
end


local function updateMinimapButtons(self)
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


function hb:init()
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
		local ldbiTbl = ldbi:GetButtonList()
		for i = 1, #ldbiTbl do
			local button = ldbi:GetMinimapButton(ldbiTbl[i])
			if self:ignoreCheck(self.GetName(button)) then
				self.minimapButtons[button[0]] = button
				self:setHooks(button)
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
					updateMinimapButtons(self)
				end
			end)
		end
	end

	local notGrabbed = {}
	for i = 1, #self.pConfig.customGrabList do
		local name = self.pConfig.customGrabList[i]
		if not self:addCustomGrabButton(name) then
			tinsert(notGrabbed, name)
		end
	end
	if #notGrabbed > 0 then
		C_Timer.After(1, function()
			local oldNumButtons = #self.minimapButtons
			for i = 1, #notGrabbed do
				self:addCustomGrabButton(notGrabbed[i])
			end
			if oldNumButtons ~= #self.minimapButtons then
				updateMinimapButtons(self)
			end
		end)
	end

	if self.pConfig.grabDefMinimap then
		self:grabDefButtons()
	end

	hooksecurefunc(UIParent, "SetScale", function() self:UI_SCALE_CHANGED() end)
	self:RegisterEvent("UI_SCALE_CHANGED")
end


function hb:setProfile(profileName)
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

	self:updateBars()
end


function hb:updateBars()
	wipe(self.barByName)
	for i = 1, #self.currentProfile.bars do
		local bar = self.bars[i]
		bar.barSettings = self.currentProfile.bars[i]
		bar.name = bar.barSettings.name
		bar.config = bar.barSettings.config
		self.barByName[bar.name] = bar

		if bar.createOwnMinimapButton then
			bar:createOwnMinimapButton()
		end

		if bar.barSettings.isDefault then
			self.defaultBar = bar
		end

		bar:Hide()
		if bar.config.fade then
			bar.drag:SetAlpha(bar.config.fadeOpacity)
		end
	end

	for i = 1, #self.mixedButtons do
		self:setBtnParent(self.mixedButtons[i])
	end

	for i = 1, #self.bars do
		local bar = self.bars[i]
		if bar.omb and bar.omb.isGrabbed then
			self:removeMButton(bar.omb)
		end

		if self.currentProfile.bars[i] then
			bar:setFrameStrata()
			bar.drag:setShowHandler()
			bar:setBarTypePosition()
			bar:setBackground()
			bar:setBorder()
			bar:setLineTexture()
			bar:setLineBorder()
			bar:setGapPosition()
			bar:setButtonDirection()
			bar:setTooltipPosition()
		else
			bar:Hide()
			bar.drag:Hide()
			ldbi:Hide(bar.ombName)
		end
	end

	self.queueEmpty = nil
	for i = 1, #self.pConfig.ombGrabQueue do
		local omb = self.bars[self.pConfig.ombGrabQueue[i]].omb
		if omb and not omb.isGrabbed then self:grabOwnButton(omb) end
	end

	self:sort()

	for i = 1, #self.currentProfile.bars do
		self.bars[i]:setButtonSize()
	end
end


function hb:getBtnName(btn)
	return self.GetName(btn) or self.btnParams[btn].name
end


function hb:setBtnSettings(btn)
	local btnData = self.pConfig.btnSettings[btn.name]
	btnData.tstmp = time()
	btnSettings[btn] = btnData
	btn:SetClipsChildren(not not btnData[4])
end


function hb:setMBtnSettings(btn)
	local name = self:getBtnName(btn)
	if name then
		local btnData = self.pConfig.mbtnSettings[name]
		btnData.tstmp = time()
		btnSettings[btn] = btnData
		btn:SetClipsChildren(not not btnData[4])
	end
end


function hb:setBtnParent(btn)
	local btnData = btnSettings[btn]
	self.SetParent(btn, self.barByName[btnData and btnData[3]] or self.defaultBar)
end


function hb:ldb_add(event, name, data)
	if name and data and (data.type == "launcher" or self.pConfig.addAnyTypeFromDataBroker
	                                             and data.icon
	                                             and data.OnClick
	                                             and not name:match(addon))
	then
		self:addButton(name, data, event)
	end
end


function hb:ldb_attrChange(_, name, key, value, data)
	if not data or data.type ~= "launcher" and not self.pConfig.addAnyTypeFromDataBroker then return end
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
	function hb:addButton(name, data, update)
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
			self:setTexCurCoord(button.icon, button.icon:GetTexCoord())
			button.icon.SetTexCoord = self.setTexCoord
			local buttonData = {
				Icon = button.icon,
				Highlight = button:CreateTexture(nil, "HIGHLIGHT"),
			}
			self.MSQ_Button:AddButton(button, buttonData, "Legacy", true)
			self:MSQ_CoordUpdate(button)
		end

		return button
	end
end


function hb:grabMButtons()
	local numButtons = #self.minimapButtons

	if self.pConfig.grabMinimap then
		self:grabMinimapAddonsButtons(Minimap)
		self:grabMinimapAddonsButtons(MinimapBackdrop)
	end

	if self.pConfig.grabDefMinimap then
		self:grabDefButtons()
	end

	if numButtons ~= #self.minimapButtons then
		updateMinimapButtons(self)
	end
end


function hb:grabDefButtons()
	local function sexyMapRegionsHide(f)
		for i, region in ipairs({f:GetRegions()}) do
			if region:IsObjectType("Texture") then
				local texture = region:GetTexture()
				if texture == 136430 or texture == 136467 then
					region:Hide()
				end 
			end
		end
	end
	
	-- CALENDAR BUTTON
	if self:ignoreCheck("GameTimeFrame") and not self.btnParams[GameTimeFrame] then
		local GameTimeFrame = GameTimeFrame
		self:setHooks(GameTimeFrame)
		sexyMapRegionsHide(GameTimeFrame)

		local p = self:setParams(GameTimeFrame, function(p, GameTimeFrame)
			GameTimeFrame:SetScript("OnUpdate", p.OnUpdate)
			if not GameTimeFrame.__MSQ_Addon then
				GameTimeFrame:GetNormalTexture():SetTexCoord(unpack(p.normalTexCoord))
				GameTimeFrame:GetPushedTexture():SetTexCoord(unpack(p.pushedTexCoord))
				GameTimeFrame:GetHighlightTexture():SetTexCoord(unpack(p.highlightTexCoord))
			end
			if p.AddonCompartmentFramePoint then
				local ACFParams = self.btnParams[AddonCompartmentFrame]
				if ACFParams then
					ACFParams.points[1] = p.AddonCompartmentFramePoint
				else
					AddonCompartmentFrame:ClearAllPoints()
					AddonCompartmentFrame:SetPoint(unpack(p.AddonCompartmentFramePoint))
				end
			end
		end)

		p.tooltipFrame = GameTooltip
		p.OnUpdate = GameTimeFrame:GetScript("OnUpdate")
		self.HookScript(GameTimeFrame, "OnUpdate", function(GameTimeFrame)
			local bar = GameTimeFrame:GetParent()
			if bar.config.interceptTooltip and GameTooltip:IsOwned(GameTooltip) then
				bar:updateTooltipPosition()
			end
		end)
		local normalTexture = GameTimeFrame:GetNormalTexture()
		p.normalTexCoord = {normalTexture:GetTexCoord()}
		normalTexture:SetTexCoord(0, .8, 0, .8)
		local pushedTexture = GameTimeFrame:GetPushedTexture()
		p.pushedTexCoord = {pushedTexture:GetTexCoord()}
		pushedTexture:SetTexCoord(0, .8, 0, .8)
		local highlightTexture = GameTimeFrame:GetHighlightTexture()
		p.highlightTexCoord = {highlightTexture:GetTexCoord()}
		highlightTexture:SetTexCoord(0, .8, 0, .8)

		local AddonCompartmentFrame = AddonCompartmentFrame
		local point, rFrame, rPoint, x, y = AddonCompartmentFrame:GetPoint()
		local ACFParams = self.btnParams[AddonCompartmentFrame]
		if rFrame == GameTimeFrame then
			p.AddonCompartmentFramePoint = {point, rFrame, rPoint, x, y}
			AddonCompartmentFrame:ClearAllPoints()
			AddonCompartmentFrame:SetPoint(GameTimeFrame:GetPoint())
		elseif ACFParams and ACFParams.points[1][2] == GameTimeFrame then
			p.AddonCompartmentFramePoint = ACFParams.points[1]
			ACFParams.points[1] = {GameTimeFrame:GetPoint()}
		end

		if self.MSQ_MButton and not GameTimeFrame.__MSQ_Addon then
			local icon = GameTimeFrame:CreateTexture(nil, "BACKGROUND")
			icon:SetAtlas(normalTexture:GetAtlas())
			icon:SetTexCoord(normalTexture:GetTexCoord())
			icon:SetSize(normalTexture:GetSize())
			self.HookScript(GameTimeFrame, "OnMouseDown", function() icon:SetScale(.9) end)
			self.HookScript(GameTimeFrame, "OnMouseUp", function() icon:SetScale(1) end)
			self:setTexCurCoord(icon, icon:GetTexCoord())
			icon.SetTexCoord = self.setTexCoord

			self.MSQ_Button_Data[GameTimeFrame] = {
				_Normal = normalTexture,
				_Pushed = pushedTexture,
				_Highlight = highlightTexture,
				_Icon = icon,
				_IsNormalIcon = true,
				_Group = self.MSQ_MButton,
				_Callback = function(data, GameTimeFrame)
					data._Callback = nil
					data._Highlight:SetAlpha(0)
					data._Highlight:SetTexture()
					data._Highlight.SetAlpha = void
					data._Highlight.SetAtlas = void
					data._Highlight.SetTexture = void
				end,
			}
			local data = {
				Icon = icon,
				Highlight = GameTimeFrame:CreateTexture(nil, "HIGHLIGHT"),
			}
			self.MSQ_MButton:AddButton(GameTimeFrame, data, "Legacy", true)
			self:MSQ_Button_Update(GameTimeFrame)
			self:MSQ_CoordUpdate(GameTimeFrame)
		end

		tinsert(self.minimapButtons, GameTimeFrame)
		tinsert(self.mixedButtons, GameTimeFrame)
	end

	-- AddonCompartmentFrame
	if self:ignoreCheck("AddonCompartmentFrame") and not self.btnParams[AddonCompartmentFrame] then
		local AddonCompartmentFrame = AddonCompartmentFrame
		self:setHooks(AddonCompartmentFrame)
		self:setParams(AddonCompartmentFrame)

		local btnData = self.pConfig.mbtnSettings["AddonCompartmentFrame"]
		if btnData[5] == nil then btnData[5] = true end

		if self.MSQ_MButton and not AddonCompartmentFrame.__MSQ_Addon then
			self:setMButtonRegions(AddonCompartmentFrame)
		end

		tinsert(self.minimapButtons, AddonCompartmentFrame)
		tinsert(self.mixedButtons, AddonCompartmentFrame)
	end

	-- TRACKING BUTTON
	if self:ignoreCheck("MinimapCluster.Tracking") and not self.btnParams[MinimapCluster.Tracking] then
		local tracking = MinimapCluster.Tracking
		tracking.rButton = tracking.Button
		tracking.icon = tracking.Button:GetNormalTexture()
		self:setHooks(tracking)
		sexyMapRegionsHide(tracking)

		local p = self:setParams(tracking, function(p, tracking)
			tracking.Background:Show()
			self:unsetHooks(tracking.Button)
			tracking.Button:SetSize(p.width, p.height)
			tracking.Button.ClearAllPoints = nil
			tracking.Button.SetPoint = nil
			self.ClearAllPoints(tracking.Button)
			for i = 1, #p.btnPoints do
				self.SetPoint(tracking.Button, unpack(p.btnPoints[i]))
			end
			if p.mailFramePoint then
				local mParams = self.btnParams[MinimapCluster.MailFrame]
				if mParams then
					mParams.points[1] = p.mailFramePoint
				else
					MinimapCluster.MailFrame:ClearAllPoints()
					MinimapCluster.MailFrame:SetPoint(unpack(p.mailFramePoint))
				end
			end
		end)

		p.name = "MinimapCluster.Tracking"
		tracking.Background:Hide()
		p.width, p.height = tracking.Button:GetSize()
		tracking.Button:SetSize(tracking:GetSize())
		p.btnPoints = {}
		for i = 1, self.GetNumPoints(tracking.Button) do
			p.btnPoints[i] = {self.GetPoint(tracking.Button, i)}
		end
		self.ClearAllPoints(tracking.Button)
		self.SetPoint(tracking.Button, "CENTER")
		self:setHooks(tracking.Button)

		local mail = MinimapCluster.MailFrame
		local point, rFrame, rPoint, x, y = mail:GetPoint()
		local mParams = self.btnParams[mail]
		if rFrame == tracking then
			p.mailFramePoint = {point, rFrame, rPoint, x, y}
			mail:ClearAllPoints()
			mail:SetPoint("RIGHT", MinimapCluster.BorderTop, "LEFT", -2, 0)
		elseif mParams and mParams.points[1][2] == tracking then
			p.mailFramePoint = mParams.points[1]
			mParams.points[1] = {"RIGHT", MinimapCluster.BorderTop, "LEFT", -2, 0}
		end

		if self.MSQ_MButton and not tracking.Button.__MSQ_Addon then
			self:setMButtonRegions(tracking.Button)
			if tracking.Button.__MSQ_Enabled then
				tracking.icon = tracking.Button.__MSQ_Icon
			end
		end

		tinsert(self.minimapButtons, tracking)
		tinsert(self.mixedButtons, tracking)
	end

	-- MAIL FRAME
	if self:ignoreCheck("MinimapCluster.MailFrame") and not self.btnParams[MinimapCluster.MailFrame] then
		local mail = MinimapCluster.MailFrame
		mail.icon = MiniMapMailIcon
		self:setHooks(mail)
		sexyMapRegionsHide(mail)

		local p = self:setParams(mail, function(p, mail)
			if mail.__MSQ_Addon then return end
			self.SetSize(mail, p.width, p.height)
			self.ClearAllPoints(mail.icon)
			for i = 1, #p.iconPoints do
				self.SetPoint(mail.icon, unpack(p.iconPoints[i]))
			end
		end)

		p.name = "MinimapCluster.MailFrame"
		p.width, p.height = mail:GetSize()
		self.SetSize(mail, 20, 20)
		p.iconPoints = {}
		for i = 1, self.GetNumPoints(mail.icon) do
			p.iconPoints[i] = {self.GetPoint(mail.icon, i)}
		end
		self.ClearAllPoints(mail.icon)
		self.SetPoint(mail.icon, "CENTER")

		local btnData = self.pConfig.mbtnSettings["MinimapCluster.MailFrame"]
		if btnData[5] == nil then btnData[5] = true end

		if self.MSQ_MButton and not mail.__MSQ_Addon then
			self:setMButtonRegions(mail)
		end

		tinsert(self.minimapButtons, mail)
		tinsert(self.mixedButtons, mail)
	end

	-- GARRISON BUTTON
	if self:ignoreCheck("ExpansionLandingPageMinimapButton") and not self.btnParams[ExpansionLandingPageMinimapButton] then
		local expBtn = ExpansionLandingPageMinimapButton
		self:setHooks(expBtn)
		self:setParams(expBtn).autoShowHideDisabled = true
		self.pConfig.mbtnSettings["ExpansionLandingPageMinimapButton"][5] = true

		if MSQ and not self.MSQ_Garrison then
			self.MSQ_Garrison = MSQ:Group(addon, GARRISON_FOLLOWERS, "GarrisonLandingPageMinimapButton")
			self.MSQ_Garrison:SetCallback(function()
				self:MSQ_Button_Update(expBtn)
				self:MSQ_CoordUpdate(expBtn)
				for _, bar in ipairs(self.bars) do
					bar:enter()
					bar:leave(math.max(1.5, bar.config.hideDelay))
				end
			end)
			self:setMButtonRegions(expBtn, nil, self.MSQ_Garrison)
		end

		tinsert(self.minimapButtons, expBtn)
		tinsert(self.mixedButtons, expBtn)
	end

	-- ZOOM IN & ZOOM OUT
	for _, zoom in ipairs({Minimap.ZoomIn, Minimap.ZoomOut}) do
		local name = zoom:GetDebugName()
		if self:ignoreCheck(name) and not self.btnParams[zoom] then
			zoom:SetHeight(zoom:GetWidth())
			local normal = zoom:GetNormalTexture()
			local pushed = zoom:GetPushedTexture()
			local highlight = zoom:GetHighlightTexture()
			self:setHooks(zoom)
			sexyMapRegionsHide(zoom)

			local p = self:setParams(zoom, function()
				zoom.Enable = nil
				zoom.Disable = nil

				if not zoom:GetScript("OnClick") then
					zoom.icon:SetDesaturated(false)
					zoom:GetNormalTexture():SetDesaturated(false)
					zoom:GetPushedTexture():SetDesaturated(false)
					zoom:GetHighlightTexture():SetDesaturated(false)
					zoom:Disable()
				end
				zoom:SetScript("OnClick", zoom.click)

				if not zoom.__MSQ_Addon then
					normal:SetTexCoord(unpack(p.normalTexCoord))
					pushed:SetTexCoord(unpack(p.pushedTexCoord))
					highlight:SetTexCoord(unpack(p.highlightTexCoord))
				end
			end)

			p.name = name
			p.tooltipFrame = GameTooltip
			p.normalTexCoord = {normal:GetTexCoord()}
			p.pushedTexCoord = {pushed:GetTexCoord()}
			p.highlightTexCoord = {highlight:GetTexCoord()}
			normal:SetTexCoord(0, .9, 0, .9)
			pushed:SetTexCoord(0, .9, 0, .9)
			highlight:SetTexCoord(0, .9, 0, .9)

			if self.MSQ_MButton and not zoom.__MSQ_Addon then
				zoom.icon = zoom:CreateTexture(nil, "BACKGROUND")
				zoom.icon:SetAtlas(normal:GetAtlas())
				zoom.icon:SetTexCoord(0, .9, 0, .9)
				zoom:SetScript("OnMouseDown", function(self) self.icon:SetScale(.9) end)
				zoom:SetScript("OnMouseUp", function(self) self.icon:SetScale(1) end)
				self:setMButtonRegions(zoom)
			end
			if not zoom.icon then zoom.icon = normal end

			zoom.click = zoom:GetScript("OnClick")
			zoom.Disable = function(zoom)
				zoom:SetScript("OnClick", nil)
				zoom.icon:SetDesaturated(true)
				zoom:GetNormalTexture():SetDesaturated(true)
				zoom:GetPushedTexture():SetDesaturated(true)
				zoom:GetHighlightTexture():SetDesaturated(true)
			end
			zoom.Enable = function(zoom)
				zoom:SetScript("OnClick", zoom.click)
				zoom.icon:SetDesaturated(false)
				zoom:GetNormalTexture():SetDesaturated(false)
				zoom:GetPushedTexture():SetDesaturated(false)
				zoom:GetHighlightTexture():SetDesaturated(false)
			end
			if not zoom:IsEnabled() then
				getmetatable(zoom).__index.Enable(zoom)
				zoom:Disable()
			end

			tinsert(self.minimapButtons, zoom)
			tinsert(self.mixedButtons, zoom)
		end
	end

	-- QUEUE STATUS
	if self:ignoreCheck("QueueStatusButton") and not self.btnParams[QueueStatusButton] then
		local queue = QueueStatusButton
		queue.icon = queue.Eye.texture
		queue.DropDown:SetScript("OnHide", nil)
		self:setHooks(queue)

		local p = self:setParams(queue, function(p, queue)
			QueueStatusFrame:ClearAllPoints()
			for i = 1, #p.statusFramePoints do
				QueueStatusFrame:SetPoint(unpack(p.statusFramePoints[i]))
			end
		end)

		p.statusFramePoints = {}
		for i = 1, QueueStatusFrame:GetNumPoints() do
			p.statusFramePoints[i] = {QueueStatusFrame:GetPoint(i)}
		end

		p.tooltipFrame = QueueStatusFrame
		self.HookScript(queue, "OnEnter", function(queue)
			local bar = self.GetParent(queue)
			if not bar.config.interceptTooltip then
				QueueStatusFrame:ClearAllPoints()
				for i = 1, #p.statusFramePoints do
					QueueStatusFrame:SetPoint(unpack(p.statusFramePoints[i]))
				end
			end
		end)

		local btnData = self.pConfig.mbtnSettings["QueueStatusButton"]
		if btnData[5] == nil then btnData[5] = true end

		if not queue.HidingBarSound then
			queue.EyeHighlightAnim:SetScript("OnLoop", nil)
			local f = CreateFrame("FRAME")
			queue.HidingBarSound = f
			f.eyeAnim = f:CreateAnimationGroup()
			f.eyeAnim:SetLooping(queue.EyeHighlightAnim:GetLooping())
			f.timer = f.eyeAnim:CreateAnimation()
			f.timer:SetDuration(1)
			f.eyeAnim:SetScript("OnLoop", function()
				if QueueStatusButton:OnGlowPulse() then
					PlaySound(SOUNDKIT.UI_GROUP_FINDER_RECEIVE_APPLICATION)
				end
			end)
			hooksecurefunc(queue.EyeHighlightAnim, "Play", function() f.eyeAnim:Play() end)
			hooksecurefunc(queue.EyeHighlightAnim, "Stop", function() f.eyeAnim:Stop() end)
			f.eyeAnim:SetPlaying(queue.EyeHighlightAnim:IsPlaying())
		end

		if self.MSQ_MButton and not queue.__MSQ_Addon then
			self:setTexCurCoord(queue.icon, queue.icon:GetTexCoord())
			queue.icon.SetTexCoord = self.setTexCoord
			local data = {
				Icon = queue.icon,
				Highlight = queue:CreateTexture(nil, "HIGHLIGHT"),
			}
			self.MSQ_MButton:AddButton(queue, data, "Legacy", true)
			self:MSQ_Button_Update(queue)
			self:MSQ_CoordUpdate(queue)
		end

		tinsert(self.minimapButtons, queue)
		tinsert(self.mixedButtons, queue)
	end
end


function hb:isBarParent(button, bar)
	while bar.omb do
		if bar.omb == button then return true end
		if bar.omb.isGrabbed then
			bar = bar.omb:GetParent()
		else
			break
		end
	end
end


function hb:grabOwnButton(button, force)
	if button.isGrabbed or not (button.bar.config.barTypePosition == 2 and button.bar.config.omb.canGrabbed or force) then return end
	local btnData = self.pConfig.mbtnSettings[button:GetName()]
	local bar, stop = self.barByName[btnData[3]], true

	if bar and not self:isBarParent(button, bar) then
		stop = false
	elseif not self:isBarParent(button, self.defaultBar) then
		btnData[3] = self.defaultBar.name
		stop = false
	else
		for i = 1, #self.currentProfile.bars do
			local sBar = self.bars[i]
			if sBar ~= bar and sBar ~= self.defaultBar and not self:isBarParent(button, sBar) then
				btnData[3] = sBar.name
				stop = false
				break
			end
		end
	end
	if stop then return end

	if self:addMButton(button, true) then
		button.isGrabbed = true
		if not force then
			self:setMBtnSettings(button)
			self:setBtnParent(button)
			self.cb:Fire("MBUTTON_ADDED", button)
		end
		return true
	end
end


function hb:addCustomGrabButton(name)
	local button = _G[name]
	if type(button) ~= "table" or type(button[0]) ~= "userdata" or self.btnParams[button] or self.IsProtected(button) then return end
	local oType = self.GetObjectType(button)
	if oType ~= "Button" and oType ~= "Frame" and oType ~= "CheckButton" then return end
	if name:match(self.matchName) then
		if self:grabOwnButton(button, true) then
			self.manuallyButtons[button] = true
			return true
		end
	elseif self:addMButton(button, true, self.MSQ_CGButton) then
		self.manuallyButtons[button] = true
		return true
	end
end


function hb:ldbi_add(_, button, name)
	if not button:GetName():match(self.matchName) and self:addMButton(button) then
		self:setMBtnSettings(button)
		self:setBtnParent(button)
		self:sort()
		button:GetParent():setButtonSize()
		self.cb:Fire("MBUTTON_ADDED", button)
	end
end


function hb:grabMinimapAddonsButtons(parentFrame)
	for _, child in ipairs({self.GetChildren(parentFrame)}) do
		local width, height = self.GetSize(child)
		if math.max(width, height) > 16 and math.abs(width - height) < 5 and not self.IsProtected(child) then
			self:addMButton(child)
		end
	end
end


function hb:addMButton(button, force, MSQ_Group)
	local name = self.GetName(button)
	if not ignoreFrameNameList[name] and not ignoreFrameList[button] and self:ignoreCheck(name) or force then
		if self.HasScript(button, "OnClick") and self.GetScript(button, "OnClick")
		or self.HasScript(button, "OnMouseUp") and self.GetScript(button, "OnMouseUp")
		or self.HasScript(button, "OnMouseDown") and self.GetScript(button, "OnMouseDown")
		or force then
			local btn = self.minimapButtons[button[0]]
			self.minimapButtons[button[0]] = nil
			if btn ~= button then
				self:setHooks(button)
			end

			if self.MSQ_MButton and not button.__MSQ_Addon then
				self:setMButtonRegions(button, nil, MSQ_Group)
			end

			self:setParams(button)
			tinsert(self.minimapButtons, button)
			tinsert(self.mixedButtons, button)
			return true
		else
			local clickable
			local function getMouseEnabled(frame)
				if self.HasScript(frame, "OnClick") and self.GetScript(frame, "OnClick")
				or self.HasScript(frame, "OnMouseUp") and self.GetScript(frame, "OnMouseUp")
				or self.HasScript(frame, "OnMouseDown") and self.GetScript(frame, "OnMouseDown") then
					clickable = true
					return
				end
				for _, fchild in ipairs({self.GetChildren(frame)}) do
					getMouseEnabled(fchild)
				end
			end
			getMouseEnabled(button)

			if clickable then
				self:setHooks(button)
				self:setParams(button)
				tinsert(self.minimapButtons, button)
				tinsert(self.mixedButtons, button)
				return true
			end
		end
	end
end


function hb:removeMButton(button, update)
	for i = 1, #self.minimapButtons do
		if button == self.minimapButtons[i] then
			tremove(self.minimapButtons, i)
			break
		end
	end

	for i = 1, #self.mixedButtons do
		if button == self.mixedButtons[i] then
			tremove(self.mixedButtons, i)
			break
		end
	end

	if update then
		self.GetParent(button):applyLayout()
	end

	self:unsetHooks(button)
	self:restoreParams(button)

	local name = self.GetName(button)
	if name and name:match(self.matchName) then
		button.isGrabbed = nil
		button.SetPoint = setOMBPoint
		button.bar:setOMBSize()
		if button.bar.config.omb.hide then
			ldbi:Hide(button.bar.ombName)
		end
	end
end


do
	local voidFunctions = {
		"SetFixedFrameStrata",
		"SetFixedFrameLevel",
		"SetHitRectInsets",
		"ClearAllPoints",
		"StartMoving",
		"SetParent",
		"SetPoint",
		"SetAlpha",
		"SetIgnoreParentScale",
		"SetScale",
		"SetSize",
		"SetWidth",
		"SetHeight",
		"Disable",
		"SetEnabled",
		"HookScript",
	}


	local function SetShown(btn, show)
		if hb.btnParams[btn].isShown == show then return end
		hb.btnParams[btn].isShown = show
		local btnData = btnSettings[btn]
		-- [1] - is disabled
		-- [5] - auto show/hide
		if btnData and btnData[5] and not btnData[1] then
			btn:GetParent():applyLayout()
		end
	end


	local function Show(btn)
		btn:SetShown(true)
	end


	local function Hide(btn)
		btn:SetShown(false)
	end


	local function IsShown(btn)
		local btnData = btnSettings[btn]
		 -- [1] - is disabled
		 -- [5] - auto show/hide
		local show = not (btnData and (btnData[1] or btnData[5] and not hb.btnParams[btn].isShown))
		hb.SetShown(btn, show)
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


	function hb:setHooks(btn)
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
		for i = 1, #voidFunctions do
			btn[voidFunctions[i]] = void
		end
		btn.SetShown = SetShown
		btn.Show = Show
		btn.Hide = Hide
		btn.IsShown = IsShown
		btn.SetScript = SetScript
	end


	function hb:unsetHooks(btn)
		btn.CreateAnimationGroup = nil
		for _, animationGroup in ipairs({btn:GetAnimationGroups()}) do
			animationGroup.Play = nil
		end
		for i = 1, #voidFunctions do
			btn[voidFunctions[i]] = nil
		end
		btn.SetShown = nil
		btn.Show = nil
		btn.Hide = nil
		btn.IsShown = nil
		btn.SetScript = nil
	end
end


function hb:setParams(btn, cb)
	self.btnParams[btn] = {
		points = {},
		frames = {},
	}
	local p = self.btnParams[btn]
	p.callback = cb
	p.isShown = self.IsShown(btn)
	p.parent = self.GetParent(btn)
	p.alpha = self.GetAlpha(btn)
	p.ignoreParentScale = self.IsIgnoringParentScale(btn)
	p.scale = self.GetScale(btn)
	p.strata = self.GetFrameStrata(btn)
	p.level = self.GetFrameLevel(btn)
	p.fixedFrameStrata = self.HasFixedFrameStrata(btn)
	p.fixedFrameLevel = self.HasFixedFrameLevel(btn)
	p.clipped = self.DoesClipChildren(btn)

	for i = 1, self.GetNumPoints(btn) do
		p.points[i] = {self.GetPoint(btn, i)}
	end

	local function OnEnter(f) enter(btn, nil, f) end
	local function OnLeave() leave(btn) end

	local function setMouseEvents(frame)
		if self.IsMouseMotionEnabled(frame) or self.IsMouseClickEnabled(frame) then
			p.frames[frame] = {}
			local fParams = p.frames[frame]

			fParams.insets = {self.GetHitRectInsets(frame)}
			self.SetHitRectInsets(frame, 0, 0, 0, 0)

			if self.HasScript(frame, "OnEnter") then
				fParams.OnEnter = self.GetScript(frame, "OnEnter")
				self.HookScript(frame, "OnEnter", OnEnter)
			end

			if self.HasScript(frame, "OnLeave") then
				fParams.OnLeave = self.GetScript(frame, "OnLeave")
				self.HookScript(frame, "OnLeave", OnLeave)
			end

			noGMEFrames[frame] = btn
		end
		for _, fchild in ipairs({self.GetChildren(frame)}) do
			setMouseEvents(fchild)
		end
	end
	setMouseEvents(btn)

	self.SetIgnoreParentScale(btn, false)
	self.SetFixedFrameStrata(btn, false)
	self.SetFixedFrameLevel(btn, false)
	self.SetAlpha(btn, 1)

	return p
end


function hb:restoreParams(btn)
	local p = self.btnParams[btn]
	if not p then return end
	self.SetShown(btn, p.isShown)
	self.SetParent(btn, p.parent)
	self.SetAlpha(btn, p.alpha)
	self.SetIgnoreParentScale(btn, p.ignoreParentScale)
	self.SetScale(btn, p.scale)
	self.SetFrameStrata(btn, p.strata)
	self.SetFrameLevel(btn, p.level)
	self.SetFixedFrameStrata(btn, p.fixedFrameStrata)
	self.SetFixedFrameLevel(btn, p.fixedFrameLevel)
	self.SetClipsChildren(btn, p.clipped)

	self.ClearAllPoints(btn)
	for i = 1, #p.points do
		self.SetPoint(btn, unpack(p.points[i]))
	end

	for frame, param in pairs(p.frames) do
		self.SetHitRectInsets(frame, unpack(param.insets))
		if self.HasScript(frame, "OnEnter") then self.SetScript(frame, "OnEnter", param.OnEnter) end
		if self.HasScript(frame, "OnLeave") then self.SetScript(frame, "OnLeave", param.OnLeave) end
		noGMEFrames[frame] = nil
	end

	if p.callback then p:callback(btn) end

	self.btnParams[btn] = nil
end


function hb:sort()
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

		local n1, n2 = self:getBtnName(a), self:getBtnName(b)
		return n1 and not n2
			or n1 and n2 and n1 < n2
	end
	sort(self.minimapButtons, btnSort)
	sort(self.mixedButtons, btnSort)
end


function hb:setClipButtons()
	for _, btn in ipairs(self.mixedButtons) do
		local btnData = btnSettings[btn]
		if btnData then
			btn:SetClipsChildren(not not btnData[4])
		end
	end
end


-------------------------------------------
-- FRAME FADE
-------------------------------------------
local function fade(self, elapsed)
	self.timer = self.timer - elapsed
	if self.timer <= 0 then
		self:SetScript("OnUpdate", nil)
		self:SetAlpha(self.endAlpha)
	else
		self:SetAlpha(self.endAlpha - self.deltaAlpha * self.timer)
	end
end


local function frameFade(self, delay, endAlpha)
	self.timer = delay
	self.endAlpha = endAlpha
	self.deltaAlpha = (endAlpha - self:GetAlpha()) / delay
	self:SetScript("OnUpdate", fade)
end


local function frameFadeStop(self, alpha)
	self:SetScript("OnUpdate", nil)
	self:SetAlpha(alpha)
end


-------------------------------------------
-- HIDINGBAR MIXIN
-------------------------------------------
local hidingBarMixin = CreateFromMixins(BackdropTemplateMixin)


function hidingBarMixin:createOwnMinimapButton()
	self.createOwnMinimapButton = nil
	self.ombName = addon..self.id
	self.ldb_icon = ldb:NewDataObject(self.ombName, {
		type = "data source",
		text = self.ombName,
		icon = "Interface/Icons/misc_arrowleft",
		OnClick = function(_, button)
			if button == "LeftButton" then
				if self:IsShown() and self.config.showHandler ~= 3 then
					self:Hide()
				else
					local func = self.drag:GetScript("OnClick")
					if func then func(self.drag) end
				end
			elseif button == "RightButton" then
				self.drag:GetScript("OnMouseDown")(self.drag, button)
			end
		end,
		OnEnter = function(btn)
			local func = self.drag:GetScript("OnEnter")
			if func then func(self.drag) end

			local parent = btn:GetParent()
			for i = 1, #hb.currentProfile.bars do
				local bar = hb.bars[i]
				if bar ~= self
				and bar.config.barTypePosition == 2
				and bar.config.showHandler ~= 3
				and bar.omb
				and parent == bar.omb:GetParent()
				and bar:IsShown()
				then
					bar:Hide()
					bar:updateDragBarPosition()
				end
			end
		end,
		OnLeave = function()
			local func = self.drag:GetScript("OnLeave")
			if func then func(self.drag) end
		end,
	})
	ldbi:Register(self.ombName, self.ldb_icon, self.config.omb)
end


function hidingBarMixin:initOwnMinimapButton()
	self.initOwnMinimapButton = nil
	self.omb = ldbi:GetMinimapButton(self.ombName)
	self.omb.bar = self
	self.omb.dSetPoint = self.omb.SetPoint
	self.omb.SetPoint = setOMBPoint
	self:setOMBSize()

	if MSQ then
		if not hb.MSQ_OMB then
			hb.MSQ_OMB = MSQ:Group(addon, L["Own Minimap Button"], "OMB")
			hb.MSQ_OMB:SetCallback(function()
				hb:MSQ_Button_Update(self.omb)
				hb:MSQ_CoordUpdate(self.omb)
			end)
		end
		hb:setMButtonRegions(self.omb, nil, hb.MSQ_OMB)
	end

	if self.config.omb.canGrabbed and (hb.queueEmpty or not next(hb.pConfig.ombGrabQueue)) then
		hb.pConfig.ombGrabQueue[#hb.pConfig.ombGrabQueue + 1] = self.id
		hb.queueEmpty = true
	end
end


function hidingBarMixin:setOMBAnchor(anchor)
	if self.config.barTypePosition ~= 2 or self.config.omb.anchor == anchor then return end
	self.config.omb.anchor = anchor
	self:setButtonDirection()
	self:applyLayout()
	self:setBarTypePosition()
	self:setGapPosition()
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


function hidingBarMixin:setTooltipPosition(position)
	if position then self.config.interceptTooltipPosition = position end

	if self.config.interceptTooltipPosition == 1 then
		self.tooltipPoint = "BOTTOM"
		self.tooltipRPoint = "TOP"
	elseif self.config.interceptTooltipPosition == 2 then
		self.tooltipPoint = "BOTTOMLEFT"
		self.tooltipRPoint = "TOPLEFT"
	elseif self.config.interceptTooltipPosition == 3 then
		self.tooltipPoint = "BOTTOMRIGHT"
		self.tooltipRPoint = "TOPRIGHT"
	elseif self.config.interceptTooltipPosition == 4 then
		self.tooltipPoint = "TOP"
		self.tooltipRPoint = "BOTTOM"
	elseif self.config.interceptTooltipPosition == 5 then
		self.tooltipPoint = "TOPLEFT"
		self.tooltipRPoint = "BOTTOMLEFT"
	elseif self.config.interceptTooltipPosition == 6 then
		self.tooltipPoint = "TOPRIGHT"
		self.tooltipRPoint = "BOTTOMRIGHT"
	elseif self.config.interceptTooltipPosition == 7 then
		self.tooltipPoint = "RIGHT"
		self.tooltipRPoint = "LEFT"
	elseif self.config.interceptTooltipPosition == 8 then
		self.tooltipPoint = "TOPRIGHT"
		self.tooltipRPoint = "TOPLEFT"
	elseif self.config.interceptTooltipPosition == 9 then
		self.tooltipPoint = "BOTTOMRIGHT"
		self.tooltipRPoint = "BOTTOMLEFT"
	elseif self.config.interceptTooltipPosition == 10 then
		self.tooltipPoint = "LEFT"
		self.tooltipRPoint = "RIGHT"
	elseif self.config.interceptTooltipPosition == 11 then
		self.tooltipPoint = "TOPLEFT"
		self.tooltipRPoint = "TOPRIGHT"
	elseif self.config.interceptTooltipPosition == 12 then
		self.tooltipPoint = "BOTTOMLEFT"
		self.tooltipRPoint = "BOTTOMRIGHT"
	else
		self.tooltipPoint = nil
		self.tooltipRPoint = nil
	end
end


function hidingBarMixin:updateTooltipPosition(eventFrame)
	local p = hb.btnParams[eventFrame]
	local tooltip = p and p.tooltipFrame

	if not tooltip then
		tooltip = LibDBIconTooltip:IsShown() and LibDBIconTooltip or GameTooltip:IsShown() and GameTooltip

		if not tooltip or tooltip:IsObjectType("GameTooltip") and tooltip:IsOwned(UIParent) then
			local lqtip = LibStub("LibQTip-1.0", true)
			if not lqtip then return end
			tooltip = nil
			for k, t in lqtip:IterateTooltips() do
				if t:IsShown() and (not t.autoHideTimerFrame or t.autoHideTimerFrame.alternateFrame == eventFrame) then
					t:SetClampedToScreen(true)
					tooltip = t
					break
				end
			end
			if not tooltip then return end
		end
	end

	if tooltip:IsObjectType("GameTooltip") then
		tooltip:SetAnchorType("ANCHOR_NONE")
	end

	local pos, point, rPoint, rFrame = self.config.interceptTooltipPosition

	if pos == 0 then
		local vPoint, vRPoint, hPoint

		if self:GetTop() + tooltip:GetHeight() + 10 < UIParent:GetHeight() then
			vPoint = "BOTTOM"
			vRPoint = "TOP"
		else
			vPoint = "TOP"
			vRPoint = "BOTTOM"
			pos = 4
		end

		if self.anchorObj.anchor == "left" then
			hPoint = "LEFT"
		elseif self.anchorObj.anchor == "right" then
			hPoint = "RIGHT"
		else
			hPoint = ""
		end

		point = vPoint..hPoint
		rPoint = vRPoint..hPoint
	else
		point = self.tooltipPoint
		rPoint = self.tooltipRPoint
	end

	if self.drag:IsShown() and (self.anchorObj.anchor == "bottom" and pos <= 3
	                        or self.anchorObj.anchor == "top" and pos >= 4 and pos <= 6
	                        or self.anchorObj.anchor == "right" and pos >= 7 and pos <= 9
	                        or self.anchorObj.anchor == "left" and pos >= 10)
	then
		rFrame = self.drag
	else
		rFrame = self
	end

	tooltip:ClearAllPoints()
	tooltip:SetPoint(point, rFrame, rPoint)
end


function hidingBarMixin:setBackground(bgTexture, r, g, b, a)
	if bgTexture ~= nil then self.config.bgTexture = bgTexture end

	local color = self.config.bgColor
	if r then color[1] = r end
	if g then color[2] = g end
	if b then color[3] = b end
	if a then color[4] = a end

	self.bg:SetTexture(media:Fetch("background", self.config.bgTexture or nil, true))
	self.bg:SetVertexColor(unpack(color))
end


function hidingBarMixin:setBorder(edge, size, r, g, b, a)
	if edge ~= nil then self.config.borderEdge = edge end
	if size then self.config.borderSize = size end

	local color = self.config.borderColor
	if r then color[1] = r end
	if g then color[2] = g end
	if b then color[3] = b end
	if a then color[4] = a end

	local scale = WorldFrame:GetWidth() / GetPhysicalScreenSize() / UIParent:GetScale()
	local edgeFile = media:Fetch("border", self.config.borderEdge or nil, true)
	self:SetBackdrop({
		edgeFile = edgeFile or "",
		edgeSize = self.config.borderSize * scale,
	})
	self:SetBackdropBorderColor(unpack(color))
	self.isEdged = edgeFile and true or false
	self:setBorderOffset()
end


function hidingBarMixin:setBorderOffset(offset)
	if offset then self.config.borderOffset = offset end
	offset = self.isEdged and self.config.borderOffset or 0
	self.bg:SetPoint("TOPLEFT", offset, -offset)
	self.bg:SetPoint("BOTTOMRIGHT", -offset, offset)
end


function hidingBarMixin:setLineTexture(texture, r, g, b)
	if texture then self.config.lineTexture = texture end

	local color = self.config.lineColor
	if r then color[1] = r end
	if g then color[2] = g end
	if b then color[3] = b end

	texture = media:Fetch("statusbar", self.config.lineTexture, true)
	if texture then
		self.drag.bg:SetTexture(texture)
		self.drag.bg:SetVertexColor(unpack(color))

		if self.anchorObj.anchor == "left" then
			self.drag.bg:SetTexCoord(1, 1, 0, 1, 1, 0, 0, 0)
		elseif self.anchorObj.anchor == "right" then
			self.drag.bg:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1)
		else
			self.drag.bg:SetTexCoord(0, 1, 0, 1)
		end
	else
		self.drag.bg:SetColorTexture(unpack(color))
	end
end


function hidingBarMixin:setLineBorder(edge, size, r, g, b, a)
	if edge ~= nil then self.config.lineBorderEdge = edge end
	if size then self.config.lineBorderSize = size end

	local color = self.config.lineBorderColor
	if r then color[1] = r end
	if g then color[2] = g end
	if b then color[3] = b end
	if a then color[4] = a end

	local scale = WorldFrame:GetWidth() / GetPhysicalScreenSize() / UIParent:GetScale()
	local edgeFile = media:Fetch("border", self.config.lineBorderEdge or nil, true)
	self.drag:SetBackdrop({
		edgeFile = edgeFile or "",
		edgeSize = self.config.lineBorderSize * scale,
	})
	self.drag:SetBackdropBorderColor(unpack(color))
	self.drag.isEdged = edgeFile and true or false
	self:setLineBorderOffset()
end


function hidingBarMixin:setLineBorderOffset(offset)
	if offset then self.config.lineBorderOffset = offset end
	offset = self.drag.isEdged and self.config.lineBorderOffset or 0
	self.drag.bg:SetPoint("TOPLEFT", offset, -offset)
	self.drag.bg:SetPoint("BOTTOMRIGHT", -offset, offset)
	self:setLineWidth()
end


function hidingBarMixin:setLineWidth(lineWidth)
	if lineWidth then self.config.lineWidth = lineWidth end
	lineWidth = self.config.lineWidth
	if self.drag.isEdged then
		lineWidth = lineWidth + self.config.lineBorderOffset * 2
	end
	self.drag:SetSize(lineWidth, lineWidth)
end


function hidingBarMixin:setGapPosition(gapSize)
	if gapSize then self.config.gapSize = gapSize end

	self.gap:ClearAllPoints()
	if self.config.barTypePosition == 2 then
		if self.config.omb.anchor == "left" then
			self.gap:SetPoint("TOPRIGHT", self, "TOPLEFT")
			self.gap:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT")
			self.gap:SetPoint("LEFT", self.omb, "RIGHT")
		elseif self.config.omb.anchor == "right" then
			self.gap:SetPoint("TOPLEFT", self, "TOPRIGHT")
			self.gap:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT")
			self.gap:SetPoint("RIGHT", self.omb, "LEFT")
		elseif self.config.omb.anchor == "top" then
			self.gap:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
			self.gap:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT")
			self.gap:SetPoint("TOP", self.omb, "BOTTOM")
		else
			self.gap:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
			self.gap:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
			self.gap:SetPoint("BOTTOM", self.omb, "TOP")
		end
	else
		if self.config.anchor == "left" then
			self.gap:SetPoint("TOPLEFT", self, "TOPRIGHT")
			self.gap:SetPoint("BOTTOMRIGHT", self.drag, "BOTTOMLEFT")
		elseif self.config.anchor == "right" then
			self.gap:SetPoint("TOPLEFT", self.drag, "TOPRIGHT")
			self.gap:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT")
		elseif self.config.anchor == "top" then
			self.gap:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
			self.gap:SetPoint("BOTTOMRIGHT", self.drag, "TOPRIGHT")
		else
			self.gap:SetPoint("TOPLEFT", self.drag, "BOTTOMLEFT")
			self.gap:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT")
		end
	end

	self:updateDragBarPosition()
end


function hidingBarMixin:setOrientation(orientation)
	self.config.orientation = orientation
	self:applyLayout()
end


function hidingBarMixin:setFade(fade)
	self.config.fade = fade
	if self.config.showHandler == 3 then
		if fade then
			frameFade(self, 1.5, self.config.fadeOpacity)
		else
			frameFadeStop(self, 1)
		end
	end
	if fade and self.drag:IsShown() then
		frameFade(self.drag, 1.5, self.config.fadeOpacity)
	else
		frameFadeStop(self.drag, 1)
	end
end


function hidingBarMixin:setFadeOpacity(opacity)
	self.config.fadeOpacity = opacity
	frameFadeStop(self.config.showHandler == 3 and self or self.drag, opacity)
end


function hidingBarMixin:setBarOffset(offset)
	self.config.barOffset = offset
	if self.config.barTypePosition == 2 then
		self:setBarTypePosition()
	end
	self:applyLayout()
end


function hidingBarMixin:setMaxButtons(size)
	self.config.size = size
	self:applyLayout()
end


function hidingBarMixin:setButtonDirection(mode, direction)
	if mode and direction then
		self.config.buttonDirection[mode] = direction
	end

	self.direction = self.direction or {}

	if self.config.buttonDirection.V == 0 then
		self.direction.V = self.anchorObj.anchor == "bottom" and "BOTTOM" or "TOP"
	elseif self.config.buttonDirection.V == 1 then
		self.direction.V = "TOP"
	else
		self.direction.V = "BOTTOM"
	end

	if self.config.buttonDirection.H == 0 then
		self.direction.H = self.anchorObj.anchor == "right" and "RIGHT" or "LEFT"
	elseif self.config.buttonDirection.H == 1 then
		self.direction.H = "LEFT"
	else
		self.direction.H = "RIGHT"
	end

	self.direction.rPoint = self.direction.V..self.direction.H
end


function hidingBarMixin:setButtonSize(size)
	if size then self.config.buttonSize = size end

	for _, btn in ipairs(hb.createdButtons) do
		if btn:GetParent() == self then
			btn:SetScale(self.config.buttonSize / btn:GetWidth())
		end
	end
	for _, btn in ipairs(hb.minimapButtons) do
		if btn:GetParent() == self then
			local width, height = btn:GetSize()
			local maxSize = width > height and width or height
			self.SetScale(btn, self.config.buttonSize / maxSize)

			local name = btn:GetName()
			if name and name:match(hb.matchName) then
				btn.bar:setBarTypePosition()
			end
		end
	end

	self:applyLayout()
end


function hidingBarMixin:setRangeBetweenBtns(range)
	self.config.rangeBetweenBtns = range
	self:applyLayout()
end


function hidingBarMixin:setMBtnPosition(position)
	self.config.mbtnPosition = position
	self:applyLayout()
end


function hidingBarMixin:setPointBtn(btn, order, orientation)
	order = order - 1
	local offset = self.config.buttonSize / 2 + self.barOffset
	local buttonSize = self.config.buttonSize + self.config.rangeBetweenBtns
	local x = order % self.config.size * buttonSize + offset
	local y = -math.floor(order / self.config.size) * buttonSize - offset
	if orientation then x, y = -y, -x end
	if self.direction.V == "BOTTOM" then y = -y end
	if self.direction.H == "RIGHT" then x = -x end
	self.ClearAllPoints(btn)
	local scale = btn:GetScale()
	self.SetPoint(btn, "CENTER", self, self.direction.rPoint, x / scale, y / scale)
end


function hidingBarMixin:applyLayout()
	local orientation
	if self.config.orientation == 0 then
		orientation = self.anchorObj.anchor == "top" or self.anchorObj.anchor == "bottom"
	else
		orientation = self.config.orientation == 2
	end

	self.barOffset = self.config.barOffset
	if self.isEdged then self.barOffset = self.barOffset + self.config.borderOffset end

	local i, maxButtons, line = 0
	if self.config.mbtnPosition == 2 then
		for _, btn in ipairs(hb.mixedButtons) do
			if btn:GetParent() == self and btn:IsShown() then
				i = i + 1
				self:setPointBtn(btn, i, orientation)
			end
		end
		maxButtons = i
		line = math.ceil(i / self.config.size)
	else
		for _, btn in ipairs(hb.createdButtons) do
			if btn:GetParent() == self and btn:IsShown() then
				i = i + 1
				self:setPointBtn(btn, i, orientation)
			end
		end
		local followed = self.config.mbtnPosition == 1
		local orderDelta = followed and i or math.ceil(i / self.config.size) * self.config.size
		local j = 0
		for _, btn in ipairs(hb.minimapButtons) do
			if btn:GetParent() == self and btn:IsShown() then
				j = j + 1
				self:setPointBtn(btn, j + orderDelta, orientation)
			end
		end
		maxButtons = followed and i + j or i > j and i or j
		line = math.ceil((j + orderDelta) / self.config.size)
	end

	if maxButtons > self.config.size then maxButtons = self.config.size
	elseif maxButtons < 1 then maxButtons = 1 end
	if line < 1 then line = 1 end
	local buttonSize = self.config.buttonSize + self.config.rangeBetweenBtns
	local offset = self.barOffset * 2 - self.config.rangeBetweenBtns
	local width = maxButtons * buttonSize + offset
	local height = line * buttonSize + offset
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
			self.drag:SetPoint("TOPLEFT", self, "TOPRIGHT", self.config.gapSize, 0)
			self.drag:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", self.config.gapSize, 0)
		elseif anchor == "right" then
			self.drag:SetPoint("TOPRIGHT", self, "TOPLEFT", -self.config.gapSize, 0)
			self.drag:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -self.config.gapSize, 0)
		elseif anchor == "top" then
			self.drag:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -self.config.gapSize)
			self.drag:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -self.config.gapSize)
		else
			self.drag:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, self.config.gapSize)
			self.drag:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, self.config.gapSize)
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


function hidingBarMixin:setBarAnchor(anchor)
	if self.config.barTypePosition ~= 1 or self.config.anchor == anchor then return end
	local x, y, position, secondPosition = self:GetCenter()
	self.config.anchor = anchor
	self:setButtonDirection()
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
	self:setGapPosition()
	self:setLineTexture()
end


function hidingBarMixin:setBarExpand(expand)
	if self.config.expand == expand then return end
	local anchor, delta, position = self.config.anchor
	local scale = self:GetEffectiveScale()

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
			self:initOwnMinimapButton()
		end

		local btnSize, position, secondPosition
		if self.omb.isGrabbed then
			btnSize = self.omb:GetParent().config.buttonSize
		else
			btnSize = self.config.omb.size
		end

		if self.config.omb.anchor == "left" or self.config.omb.anchor == "right" then
			if self.config.expand == 0 then
				position = btnSize + self.config.barOffset
			elseif self.config.expand == 1 then
				position = -self.config.barOffset
			else
				position = btnSize / 2
			end
		else
			if self.config.expand == 0 then
				position = -self.config.barOffset
			elseif self.config.expand == 1 then
				position = btnSize + self.config.barOffset
			else
				position = btnSize / 2
			end
		end

		if self.config.omb.anchor == "left" then
			secondPosition = btnSize + self.config.omb.distanceToBar
			self.ldb_icon.icon = "Interface/Icons/misc_arrowright"
		elseif self.config.omb.anchor == "right" then
			secondPosition = -btnSize - self.config.omb.distanceToBar
			self.ldb_icon.icon = "Interface/Icons/misc_arrowleft"
		elseif self.config.omb.anchor == "top" then
			secondPosition = -btnSize - self.config.omb.distanceToBar
			self.ldb_icon.icon = "Interface/Icons/misc_arrowdown"
		else
			secondPosition = btnSize + self.config.omb.distanceToBar
			self.ldb_icon.icon = "Interface/Icons/misc_arrowlup"
		end

		self.anchorObj = self.config.omb
		self.rFrame = self.omb
		self.position = position + self.config.omb.barDisplacement
		self.secondPosition = secondPosition
	else
		self.config.omb.hide = true
		ldbi:Hide(self.ombName)
		self.anchorObj = self.config
		self.rFrame = UIParent
		self.position = nil
		self.secondPosition = nil
	end

	if typePosition then
		self:setButtonDirection()
		self:applyLayout()
		self:refreshShown()
	end
	self:updateBarPosition()
end


function hidingBarMixin:setBarCoords(position, secondPosition)
	local scale = self:GetEffectiveScale()

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
			self.position = self.config.position / self:GetEffectiveScale()
		end

		if not self.secondPosition then
			if not self.config.secondPosition then
				self.config.secondPosition = 0
			end
			self.secondPosition = self.config.secondPosition / self:GetEffectiveScale()
		end

		hb.cb:Fire("COORDS_UPDATED", self)

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
	local scale = self:GetEffectiveScale()
	x, y = x / scale + self.dx, y / scale + self.dy

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
			self:setButtonDirection()
			width, height = self:applyLayout()
			self:updateDragBarPosition()
			self:setLineTexture()
			self:setGapPosition()

			hb.cb:Fire("ANCHOR_UPDATED", self.config.anchor, self)
		end
	else
		if anchor == "left" then
			local dx = UIwidth - x - self.drag:GetWidth() / 2
			if dx < 0 then x = x + dx end
		elseif anchor == "right" then
			local dx = x - self.drag:GetWidth() / 2
			if dx < 0 then x = x - dx end
		elseif anchor == "top" then
			local dy = y - self.drag:GetHeight() / 2
			if dy < 0 then y = y - dy end
		elseif anchor == "bottom" then
			local dy = UIheight - y - self.drag:GetHeight() / 2
			if dy < 0 then y = y + dy end
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
	if not self.isDrag then
		if self.config.showHandler ~= 3 or force then
			frameFadeStop(self.drag, 1)
			self:SetScript("OnUpdate", nil)
			self:Show()
			self:Raise()
			self:updateDragBarPosition()
		else
			frameFadeStop(self, 1)
			if self.drag:IsShown() then
				frameFadeStop(self.drag, 1)
			end
		end
	end
end


function hidingBarMixin:hideBar(elapsed)
	self.timer = self.timer - elapsed
	if self.timer <= 0 then
		self:Hide()
		self:updateDragBarPosition()
		self:SetScript("OnUpdate", nil)
		if self.config.fade and self.drag:IsShown() then
			frameFade(self.drag, 1.5, self.config.fadeOpacity)
		end
	end
end


function hidingBarMixin:leave(timer)
	if not self.isDrag and self:IsShown() then
		if self.config.showHandler == 3 then
			if self.config.fade then
				frameFade(self, 1.5, self.config.fadeOpacity)
				if self.drag:IsShown() then
					frameFade(self.drag, 1.5, self.config.fadeOpacity)
				end
			end
		elseif self.config.hideHandler % 2 == 0 or timer then
			self.timer = timer or self.config.hideDelay
			self:SetScript("OnUpdate", self.hideBar)
		end
	end
end


function hidingBarMixin:refreshShown()
	if self.config.barTypePosition == 2 then
		self.drag:Hide()
		if self.config.showHandler == 3 then
			self:enter(true)
			self:leave()
		elseif self:IsShown() then
			frameFadeStop(self, 1)
			self:GetScript("OnShow")(self)
			if not self.isMouse then
				self:leave()
			end
		end
	elseif self.config.showHandler == 3 then
		self.drag:SetShown(not self.config.lock)
		if self:IsShown() then
			self:SetScript("OnUpdate", nil)
		else
			self:enter(true)
		end
		self:leave()
	else
		self.drag:Show()
		frameFadeStop(self, 1)
		if self:IsShown() then
			frameFadeStop(self.drag, 1)
			self:GetScript("OnShow")(self)
			if not self.isMouse then
				self:leave()
			end
		end
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
		frameFade(self, bar.config.showDelay, 1)
	end
end


function hidingBarDragMixin:hideOnClick()
	local bar = self.bar
	if bar:IsShown() and bar.config.hideHandler == 3 then
		bar:Hide()
		bar:updateDragBarPosition()
		return true
	end
end


function hidingBarDragMixin:showOnClick()
	if not self:hideOnClick() then
		self.bar:enter()
	end
end


do
	local function showBarDelay(hb, elapsed)
		hb.timer = hb.timer - elapsed
		if hb.timer <= 0 then
			hb:SetScript("OnUpdate", nil)
			hb.tBar:enter()
		end
	end

	function hidingBarDragMixin:showOnHoverWithDelay()
		local bar = self.bar
		if bar:IsShown() or bar.config.showDelay == 0 then
			bar:enter()
		else
			if self:IsShown() and bar.config.fade then
				frameFade(self, bar.config.showDelay, 1)
			end
			hb.tBar = bar
			hb.timer = bar.config.showDelay
			hb:SetScript("OnUpdate", showBarDelay)
		end
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
		self:SetScript("OnClick", self.hideOnClick)
	end

	bar:refreshShown()
end


-------------------------------------------
-- CREATE BAR
-------------------------------------------
local function bar_OnEnter(self)
	if self:IsShown() then
		self.isMouse = true
		self:enter()
	end
end


local function bar_OnLeave(self)
	self.isMouse = false
	self:leave()
end


local function isNoGMEParent(bar)
	local frame = GetMouseFocus()
	while frame do
		if noGMEFrames[frame] then
			return noGMEFrames[frame]:GetParent() == bar
		end
		frame = frame:GetParent()
	end
end


local function bar_OnEvent(self, event, button)
	if (button == "LeftButton" or button == "RightButton")
	and not (self.isMouse
		or self.drag:IsShown() and self.drag:IsMouseOver()
		or self.omb and self.omb:IsShown() and self.omb:IsMouseOver()
		or isNoGMEParent(self))
	then
		self:Hide()
		self:updateDragBarPosition()
		self:SetScript("OnUpdate", nil)
		if self.config.fade and self.drag:IsShown() then
			frameFade(self.drag, 1.5, self.config.fadeOpacity)
		end
	end
end


local function bar_OnShow(self)
	if self.config.barTypePosition == 2 and self.omb and self.omb.isGrabbed then
		self:SetFrameLevel(self.omb:GetParent():GetFrameLevel() + 11)
	else
		self:SetFrameLevel(100)
	end
	if self.config.showHandler == 3
	or self.config.hideHandler == 0
	or self.config.hideHandler == 3
	then return end
	self:RegisterEvent("GLOBAL_MOUSE_DOWN")
end


local function bar_OnHide(self)
	self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
end


local function drag_OnMouseDown(self, button)
	local bar = self.bar
	if button == "LeftButton" and not bar.config.lock and bar:IsShown() then
		local x, y = GetCursorPosition()
		local cx, cy = self:GetCenter()
		local scale = bar:GetEffectiveScale()
		bar.dx = cx - x / scale
		bar.dy = cy - y / scale
	elseif button == "RightButton" then
		if IsAltKeyDown() then
			bar:setLocked(not bar.config.lock)
			hb.cb:Fire("LOCK_UPDATED", bar.config.lock, bar)
		end
		if IsShiftKeyDown() then
			config:openConfig()
			if config.setBar then
				config:setBar(bar.barSettings)
			end
		end
	end
end


local function drag_OnDragStart(self)
	local bar = self.bar
	if not bar.config.lock and bar:IsShown() then
		bar.isDrag = true
		cover:SetFrameStrata(bar:GetFrameStrata())
		cover:SetFrameLevel(bar:GetFrameLevel() + 10)
		cover:SetAllPoints(bar)
		cover:Show()
		bar:SetScript("OnUpdate", bar.dragBar)
	end
end


local function drag_OnDragStop(self)
	local bar = self.bar
	if bar.isDrag then
		bar.isDrag = false
		cover:Hide()
		bar:SetScript("OnUpdate", nil)
		if not bar.isMouse then
			bar:leave()
		end
	end
end


local function drag_OnLeave(self)
	hb:SetScript("OnUpdate", nil)
	local bar = self.bar
	if bar:IsShown() then
		bar:leave()
	elseif bar.config.fade and self:IsShown() then
		local delay = bar.config.showDelay ~= 0 and bar.config.showDelay or 1.5
		frameFade(self, delay, bar.config.fadeOpacity)
	end
end


local function gap_OnEnter(self)
	self.bar:enter()
end


local function gap_OnLeave(self)
	self.bar:leave()
end


setmetatable(hb.bars, {__index = function(self, key)
	local bar = CreateFrame("FRAME", nil, UIParent, "HidingBarAddonPanel")
	bar:SetClampedToScreen(true)
	bar:SetScript("OnEnter", bar_OnEnter)
	bar:SetScript("OnLeave", bar_OnLeave)
	bar:SetScript("OnEvent", bar_OnEvent)
	bar:SetScript("OnShow", bar_OnShow)
	bar:SetScript("OnHide", bar_OnHide)
	for k, v in pairs(hidingBarMixin) do
		bar[k] = v
	end

	bar.drag = CreateFrame("BUTTON", nil, UIParent, "BackdropTemplate")
	bar.drag.bar = bar
	bar.drag:RegisterForDrag("LeftButton")
	bar.drag:SetClampedToScreen(true)
	bar.drag:SetHitRectInsets(-2, -2, -2, -2)
	bar.drag:SetFrameLevel(bar:GetFrameLevel() + 10)
	bar.drag.bg = bar.drag:CreateTexture(nil, "BACKGROUND")
	bar.drag:SetScript("OnMouseDown", drag_OnMouseDown)
	bar.drag:SetScript("OnDragStart", drag_OnDragStart)
	bar.drag:SetScript("OnDragStop", drag_OnDragStop)
	bar.drag:SetScript("OnLeave", drag_OnLeave)
	for k, v in pairs(hidingBarDragMixin) do
		bar.drag[k] = v
	end

	bar.gap = CreateFrame("FRAME", nil, bar)
	bar.gap.bar = bar
	bar.gap:SetFrameLevel(bar:GetFrameLevel())
	bar.gap:SetScript("OnEnter", gap_OnEnter)
	bar.gap:SetScript("OnLeave", gap_OnLeave)
	bar.gap:SetMouseClickEnabled(false)

	bar.id = key
	self[key] = bar
	return bar
end})