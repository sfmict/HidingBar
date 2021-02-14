local addon, L = ...
local config, UIParent = _G[addon.."ConfigAddon"], UIParent
local hidingBar = CreateFrame("FRAME", addon.."Addon", UIParent, "HidingBarAddonPanel")
hidingBar:SetClampedToScreen(true)
hidingBar.cover = CreateFrame("FRAME", nil, hidingBar)
hidingBar.cover:Hide()
hidingBar.cover:SetAllPoints()
hidingBar.cover:EnableMouse(true)
hidingBar.cover:SetFrameLevel(hidingBar:GetFrameLevel() + 10)
hidingBar.drag = CreateFrame("BUTTON", nil, UIParent)
hidingBar.drag:SetClampedToScreen(true)
hidingBar.drag:SetHitRectInsets(-2, -2, -2, -2)
hidingBar.drag:SetFrameLevel(hidingBar:GetFrameLevel())
hidingBar.drag.bg = hidingBar.drag:CreateTexture(nil, "OVERLAY")
hidingBar.drag.bg:SetAllPoints()
hidingBar.drag.fTimer = CreateFrame("FRAME")
hidingBar.createdButtons, hidingBar.minimapButtons, hidingBar.mixedButtons = {}, {}, {}
local createdButtonsByName, btnSettings = {}, {}
local offsetX, offsetY = 2, 2
local ldb = LibStub("LibDataBroker-1.1")
local ldbi, ldbi_ver = LibStub("LibDBIcon-1.0")
local MSQ = LibStub("Masque", true)


local ignoreFrameList = {
	["LibDBIcon10_HidingBar"] = true,
	["GameTimeFrame"] = true,
	["QueueStatusMinimapButton"] = true,
	["HelpOpenTicketButton"] = true,
	["HelpOpenWebTicketButton"] = true,
	["MinimapBackdrop"] = true,
	["GarrisonLandingPageMinimapButton"] = true,
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["MiniMapWorldMapButton"] = true,
}


local function void() end
local function enter() hidingBar:enter() end
local function leave() hidingBar:leave() end


local function setTexCoord(self, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
	if not LRy then
		ULy, LLx, URx, URy, LRx, LRy = LLx, ULx, ULy, LLx, ULy, LLy
	end
	self.MSQ_Coord = {ULx, ULy, LLx, LLy, URx, URy, LRx, LRy}

	local data = self:GetParent().data
	if data.iconCoords then
		local cULx, cULy, cLLx, cLLy, cURx, cURy, cLRx, cLRy = unpack(data.iconCoords)
		if not cLRy then
			cULy, cLLx, cURx, cURy, cLRx, cLRy = cLLx, cULx, cULy, cLLx, cULy, cLLy
		end
		local top = cURx - cULx
		local right = cLRy - cURy
		local bottom = cLRx - cLLx
		local left = cLLy - cULy
		ULx = cULx + ULx * top
		ULy = cULy + ULy * left
		LLx = cLLx + LLx * bottom
		LLy = cULy + LLy * left
		URx = cULx + URx * top
		URy = cURy + URy * right
		LRx = cLLx + LRx * bottom
		LRy = cURy + LRy * right
	end

	self:dSetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
end


hidingBar:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
hidingBar:RegisterEvent("ADDON_LOADED")


function hidingBar:ADDON_LOADED(addonName)
	if addonName == addon then
		self:UnregisterEvent("ADDON_LOADED")

		local meta = {__index = function(self, key)
			self[key] = {tstmp = 0}
			return self[key]
		end}

		HidingBarDB = HidingBarDB or {}
		self.db = HidingBarDB
		self.db.config = self.db.config or {}
		self.config = self.db.config
		self.config.orientation = self.config.orientation or 0
		self.config.expand = self.config.expand or 2
		self.config.frameStrata = self.config.frameStrata or 2
		self.config.fadeOpacity = self.config.fadeOpacity or .2
		self.config.lineWidth = self.config.lineWidth or 4
		self.config.showHandler = self.config.showHandler or 0
		self.config.showDelay = self.config.showDelay or 0
		self.config.hideDelay = self.config.hideDelay or .75
		self.config.size = self.config.size or 10
		self.config.buttonSize = self.config.buttonSize or 32
		self.config.anchor = self.config.anchor or "top"
		self.config.barTypePosition = self.config.barTypePosition or 0
		if self.config.grabMinimap == nil then
			self.config.grabMinimap = true
		end
		self.config.grabMinimapAfterN = self.config.grabMinimapAfterN or 1
		self.config.mbtnPosition = self.config.mbtnPosition or 2
		self.config.ignoreMBtn = self.config.ignoreMBtn or {"GatherMatePin"}
		self.config.bgColor = self.config.bgColor or {.1, .1, .1, .7}
		self.config.lineColor = self.config.lineColor or {.8, .6, 0}
		self.config.omb = self.config.omb or {}
		if self.config.omb.hide == nil then
			self.config.omb.hide = true
		end
		self.config.omb.anchor = self.config.omb.anchor or "right"
		self.config.omb.size = self.config.omb.size or 31
		if self.config.omb.lock == nil then
			self.config.omb.lock = self.config.lock or false
		end
		self.config.btnSettings = setmetatable(self.config.btnSettings or {}, meta)
		self.config.mbtnSettings = setmetatable(self.config.mbtnSettings or {}, meta)

		if self.config.freeMove then
			self.config.barTypePosition = 1
			self.config.freeMove = nil
		end

		self:setFrameStrata()
		self:setLineColor()
		self:setBackgroundColor()
		self:setLineWidth()

		config.hidingBar = self
		config.config = self.config

		C_Timer.After(0, function() self:init() end)
	end
end


function hidingBar:createOwnMinimapButton()
	self.ldb_icon = ldb:NewDataObject(addon, {
		type = "data source",
		text = addon,
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
				if IsAltKeyDown() then
					self:setLocked(not self.config.lock)
					if config.lock then config.lock:SetChecked(self.config.lock) end
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
	ldbi:Register(addon, self.ldb_icon, self.config.omb)
end


function hidingBar:UI_SCALE_CHANGED()
	self:setBarTypePosition()
end


function hidingBar:ignoreCheck(name)
	if not name then return self.config.grabMinimapWithoutName end
	for i = 1, #self.config.ignoreMBtn do
		if name:find(self.config.ignoreMBtn[i]) then return end
	end
	return true
end


function hidingBar:init()
	if MSQ then
		self.MSQ_Button = MSQ:Group(addon, L["DataBroker Buttons"], "DataBroker")
		self.MSQ_Button:SetCallback(function()
			self:enter()
			self:leave()
		end)
		self.MSQ_MButton = MSQ:Group(addon, L["Minimap Buttons"], "MinimapButtons")
		self.MSQ_MButton_Data = {}

		function self:MSQ_MButton_Update(btn)
			if not btn.__MSQ_Enabled then return end
			local data = self.MSQ_MButton_Data[btn]
			if data then
				if data._Border then
					data._Border:Hide()
				end
				if data._Background then
					data._Background:Hide()
				end
				if data._Pushed then
					data._Pushed:SetAlpha(0)
				end
			end
		end

		self.MSQ_MButton:SetCallback(function()
			for btn in pairs(self.MSQ_MButton.Buttons) do
				self:MSQ_MButton_Update(btn)
			end
			self:enter()
			self:leave()
		end)
	end

	ldb.RegisterCallback(self, "LibDataBroker_DataObjectCreated", "ldb_add")
	ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__icon", "ldb_attrChange")
	ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__iconCoords", "ldb_attrChange")
	ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__iconR", "ldb_attrChange")
	ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__iconG", "ldb_attrChange")
	ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__iconB", "ldb_attrChange")
	ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged__iconDesaturated", "ldb_attrChange")
	for name, data in ldb:DataObjectIterator() do
		self:ldb_add(nil, name, data)
	end

	if self.config.grabMinimap then
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

		if self.config.grabMinimapAfter then
			C_Timer.After(tonumber(self.config.grabMinimapAfterN) or 1, function()
				self:grabMinimapAddonsButtons(Minimap)
				self:grabMinimapAddonsButtons(MinimapBackdrop)
				self:sort()
				self:setButtonSize()
				config:initMButtons(true)
			end)
		end
	end

	local t = time()

	if self.config.grabDefMinimap then
		-- CALENDAR BUTTON
		if self:ignoreCheck("GameTimeFrame") then
			local GameTimeFrame = GameTimeFrame
			btnSettings[GameTimeFrame] = self.config.mbtnSettings["GameTimeFrame"]
			btnSettings[GameTimeFrame].tstmp = t
			local normalTexture = GameTimeFrame:GetNormalTexture()
			normalTexture:SetTexCoord(0, .375, 0, .75)
			local pushedTexture = GameTimeFrame:GetPushedTexture()
			pushedTexture:SetTexCoord(.5, .875, 0, .75)
			local highlightTexture = GameTimeFrame:GetHighlightTexture()
			highlightTexture:SetTexCoord(0, 1, 0, .9375)
			local text = select(5, GameTimeFrame:GetRegions())
			text:SetPoint("CENTER", 0, -1)
			GameTimeFrame:SetNormalFontObject("GameFontBlackMedium")
			GameTimeCalendarInvitesTexture:SetPoint("CENTER")
			GameTimeCalendarInvitesGlow.Show = void
			GameTimeCalendarInvitesGlow:Hide()
			self:setHooks(GameTimeFrame)

			if self.MSQ_MButton then
				GameTimeFrame.icon = GameTimeFrame:CreateTexture(nil, "BACKGROUND")
				GameTimeFrame.icon:SetTexture(normalTexture:GetTexture())
				GameTimeFrame.icon:SetTexCoord(normalTexture:GetTexCoord())
				GameTimeFrame.data = {iconCoords = {.0859375, .296875, .156255, .59375}}
				GameTimeFrame.icon.dSetTexCoord = GameTimeFrame.icon.SetTexCoord
				GameTimeFrame.icon.SetTexCoord = setTexCoord
				GameTimeFrame.icon:SetAllPoints()
				GameTimeFrame.icon:SetPoint(normalTexture:GetPoint())
				local data = {
					_Pushed = GameTimeFrame:GetPushedTexture(),
					Icon = GameTimeFrame.icon,
					Highlight = GameTimeFrame:GetHighlightTexture(),
				}
				self.MSQ_MButton_Data[GameTimeFrame] = data
				self.MSQ_MButton:AddButton(GameTimeFrame, data, nil, true)
				self:MSQ_MButton_Update(GameTimeFrame)
			end

			self.SetClipsChildren(GameTimeFrame, true)
			self.SetAlpha(GameTimeFrame, 1)
			self.SetHitRectInsets(GameTimeFrame, 0, 0, 0, 0)
			self.SetParent(GameTimeFrame, self)
			self.SetScript(GameTimeFrame, "OnUpdate", nil)
			self.HookScript(GameTimeFrame, "OnEnter", enter)
			self.HookScript(GameTimeFrame, "OnLeave", leave)
			tinsert(self.minimapButtons, GameTimeFrame)
			tinsert(self.mixedButtons, GameTimeFrame)
		end

		-- TRACKING BUTTON
		if self:ignoreCheck("MiniMapTracking") then
			local MiniMapTracking = MiniMapTracking
			btnSettings[MiniMapTracking] = self.config.mbtnSettings["MiniMapTracking"]
			btnSettings[MiniMapTracking].tstmp = t
			local icon = MiniMapTrackingIcon
			hooksecurefunc(icon, "SetPoint", function(icon)
				icon:ClearAllPoints()
				self.SetPoint(icon, "CENTER")
			end)
			self:setHooks(MiniMapTracking)

			if self.MSQ_MButton then
				local data = {
					_Border = MiniMapTrackingButtonBorder,
					_Background = MiniMapTrackingBackground,
					Icon = icon,
					Highlight = MiniMapTrackingButton:GetHighlightTexture(),
				}
				self.MSQ_MButton_Data[MiniMapTrackingButton] = data
				self.MSQ_MButton:AddButton(MiniMapTrackingButton, data, nil, true)
				self:MSQ_MButton_Update(MiniMapTrackingButton)
			end

			self.SetClipsChildren(MiniMapTracking, true)
			self.SetAlpha(MiniMapTracking, 1)
			self.SetHitRectInsets(MiniMapTracking, 0, 0, 0, 0)
			self.SetParent(MiniMapTracking, self)
			self.SetScript(MiniMapTracking, "OnUpdate", nil)
			MiniMapTrackingButton:HookScript("OnMouseDown", function()
				icon:SetScale(.9)
			end)
			MiniMapTrackingButton:HookScript("OnMouseUp", function()
				icon:SetScale(1)
			end)
			MiniMapTrackingButton:HookScript("OnEnter", enter)
			MiniMapTrackingButton:HookScript("OnLeave", leave)
			tinsert(self.minimapButtons, MiniMapTracking)
			tinsert(self.mixedButtons, MiniMapTracking)
		end

		-- GARRISON BUTTON
		if self:ignoreCheck("GarrisonLandingPageMinimapButton") then
			local garrison = GarrisonLandingPageMinimapButton
			btnSettings[garrison] = self.config.mbtnSettings["GarrisonLandingPageMinimapButton"]
			btnSettings[garrison].tstmp = t
			garrison.show = garrison:IsShown()
			self:setHooks(garrison)
			garrison.Show = function(garrison)
				if not garrison.show then
					garrison.show = true
					self:applyLayout()
				end
			end
			garrison.Hide = function(garrison)
				if garrison.show then
					garrison.show = false
					self:applyLayout()
				end
			end
			garrison.IsShown = function(garrison)
				local show = garrison.show and not btnSettings[garrison][1]
				self.SetShown(garrison, show)
				return show
			end

			self.SetClipsChildren(garrison, true)
			self.SetAlpha(garrison, 1)
			self.SetHitRectInsets(garrison, 0, 0, 0, 0)
			self.SetParent(garrison, self)
			self.SetScript(garrison, "OnUpdate", nil)
			self.HookScript(garrison, "OnEnter", enter)
			self.HookScript(garrison, "OnLeave", leave)
			tinsert(self.minimapButtons, garrison)
			tinsert(self.mixedButtons, garrison)
		end

		-- QUEUE STATUS
		if self:ignoreCheck("QueueStatusMinimapButton") then
			local queue = QueueStatusMinimapButton
			btnSettings[queue] = self.config.mbtnSettings["QueueStatusMinimapButton"]
			btnSettings[queue].tstmp = t
			QueueStatusMinimapButtonDropDown:SetScript("OnHide", nil)
			queue.show = queue:IsShown()
			queue.icon = queue.Eye.texture
			self:setHooks(queue)
			queue.Show = function(queue)
				if not queue.show then
					queue.show = true
					self:applyLayout()
				end
			end
			queue.Hide = function(queue)
				if queue.show then
					queue.show = false
					if QueueStatusMinimapButtonDropDown == UIDROPDOWNMENU_OPEN_MENU then
						CloseDropDownMenus()
					end
					self:applyLayout()
				end
			end
			queue.IsShown = function(queue)
				local show = queue.show and not btnSettings[queue][1]
				self.SetShown(queue, show)
				return show
			end

			queue.EyeHighlightAnim:SetScript("OnLoop", nil)
			local f = CreateFrame("FRAME")
			f.eyeAnim = f:CreateAnimationGroup()
			f.eyeAnim:SetLooping(queue.EyeHighlightAnim:GetLooping())
			f.timer = f.eyeAnim:CreateAnimation()
			f.timer:SetDuration(1)
			f.eyeAnim:SetScript("OnLoop", function()
				if QueueStatusMinimapButton_OnGlowPulse(queue) then
					PlaySound(SOUNDKIT.UI_GROUP_FINDER_RECEIVE_APPLICATION)
				end
			end)
			hooksecurefunc(queue.EyeHighlightAnim, "Play", function() f.eyeAnim:Play() end)
			hooksecurefunc(queue.EyeHighlightAnim, "Stop", function() f.eyeAnim:Stop() end)
			f.eyeAnim:SetPlaying(queue.EyeHighlightAnim:IsPlaying())

			if self.MSQ_MButton then
				local data = {
					_Border = QueueStatusMinimapButtonBorder,
					Icon = queue.icon,
					Highlight = queue:GetHighlightTexture(),
				}
				self.MSQ_MButton_Data[queue] = data
				self.MSQ_MButton:AddButton(queue, data, nil, true)
				self:MSQ_MButton_Update(queue)
			end

			queue.icon:SetTexCoord(0, .125, 0, .25)
			self.SetClipsChildren(queue, true)
			self.SetAlpha(queue, 1)
			self.SetHitRectInsets(queue, 0, 0, 0, 0)
			self.SetParent(queue, self)
			self.SetScript(queue, "OnUpdate", nil)
			self.HookScript(queue, "OnEnter", enter)
			self.HookScript(queue, "OnLeave", leave)
			tinsert(self.minimapButtons, queue)
			tinsert(self.mixedButtons, queue)
		end

		-- MAIL
		if self:ignoreCheck("HidingBarAddonMail") then
			local proxyMail = CreateFrame("BUTTON", "HidingBarAddonMail", self, "HidingBarAddonMailTemplate")
			btnSettings[proxyMail] = self.config.mbtnSettings["HidingBarAddonMail"]
			btnSettings[proxyMail].tstmp = t
			local mail = MiniMapMailFrame
			proxyMail.show = mail:IsShown()
			self:setHooks(mail)
			self.SetParent(mail, self)
			self.Hide(mail)
			mail:UnregisterAllEvents()
			proxyMail:SetScript("OnEvent", mail:GetScript("OnEvent"))
			proxyMail:SetScript("OnEnter", mail:GetScript("OnEnter"))
			proxyMail:SetScript("OnLeave", mail:GetScript("OnLeave"))
			proxyMail:RegisterEvent("UPDATE_PENDING_MAIL")

			proxyMail.Show = function(proxyMail)
				if not proxyMail.show then
					proxyMail.show = true
					self:applyLayout()
				end
			end
			proxyMail.Hide = function(proxyMail)
				if proxyMail.show then
					proxyMail.show = false
					self:applyLayout()
				end
			end
			proxyMail.IsShown = function(proxyMail)
				local show = proxyMail.show and not btnSettings[proxyMail][1]
				self.SetShown(proxyMail, show)
				return show
			end

			if self.MSQ_MButton then
				local data = {
					_Border = proxyMail.border,
					Icon = proxyMail.icon,
					Highlight = proxyMail.highlight,
				}
				self.MSQ_MButton_Data[proxyMail] = data
				self.MSQ_MButton:AddButton(proxyMail, data, nil, true)
				self:MSQ_MButton_Update(proxyMail)
			end

			proxyMail:SetClipsChildren(true)
			proxyMail:HookScript("OnEnter", enter)
			proxyMail:HookScript("OnLeave", leave)
			tinsert(self.minimapButtons, proxyMail)
			tinsert(self.mixedButtons, proxyMail)
		end

		-- ZOOM IN & ZOOM OUT
		for _, zoom in ipairs({MinimapZoomIn, MinimapZoomOut}) do
			local name = zoom:GetName()
			if self:ignoreCheck(name) then
				btnSettings[zoom] = self.config.mbtnSettings[name]
				btnSettings[zoom].tstmp = t
				self:setHooks(zoom)

				if self.MSQ_MButton then
					zoom.icon = zoom:CreateTexture(nil, "ARTWORK")
					zoom.icon:SetTexture(zoom:GetNormalTexture():GetTexture())
					zoom.data = {iconCoords = {.24, .79, .21, .76}}
					zoom.icon.dSetTexCoord = zoom.icon.SetTexCoord
					zoom.icon.SetTexCoord = setTexCoord
					zoom:SetScript("OnMouseDown", function(self) self.icon:SetScale(.9) end)
					zoom:SetScript("OnMouseUp", function(self) self.icon:SetScale(1) end)
					local data = {
						_Pushed = zoom:GetPushedTexture(),
						Icon = zoom.icon,
						Highlight = zoom:GetHighlightTexture(),
					}
					self.MSQ_MButton_Data[zoom] = data
					self.MSQ_MButton:AddButton(zoom, data, nil,  true)
					self:MSQ_MButton_Update(zoom)
				else
					zoom.icon = zoom:GetNormalTexture()
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
					zoom:Disable()
				end

				self.SetClipsChildren(zoom, true)
				self.SetAlpha(zoom, 1)
				self.SetHitRectInsets(zoom, 0, 0, 0, 0)
				getmetatable(zoom).__index.Enable(zoom)
				self.SetParent(zoom, self)
				self.HookScript(zoom, "OnEnter", enter)
				self.HookScript(zoom, "OnLeave", leave)
				tinsert(self.minimapButtons, zoom)
				tinsert(self.mixedButtons, zoom)
			end
		end

		-- WORLD MAP BUTTON
		if self:ignoreCheck("MiniMapWorldMapButton") then
			local mapButton = MiniMapWorldMapButton
			btnSettings[mapButton] = self.config.mbtnSettings["MiniMapWorldMapButton"]
			btnSettings[mapButton].tstmp = t
			self:setHooks(mapButton)
			mapButton.puched = mapButton:GetPushedTexture()
			mapButton.highligt = mapButton:GetHighlightTexture()

			if self.MSQ_MButton then
				mapButton.icon = mapButton:CreateTexture(nil, "ARTWORK")
				mapButton.icon:SetTexture("Interface/QuestFrame/UI-QuestMap_Button")
				mapButton.icon:SetAllPoints()
				mapButton.data = {iconCoords = {.125, .875, 0, .5}}
				mapButton.icon.dSetTexCoord = mapButton.icon.SetTexCoord
				mapButton.icon.SetTexCoord = setTexCoord
				mapButton:SetScript("OnMouseDown", function(self) self.icon:SetScale(.9) end)
				mapButton:SetScript("OnMouseUp", function(self) self.icon:SetScale(1) end)
				local data = {
					_Pushed = mapButton.puched,
					Icon = mapButton.icon,
					Highlight = mapButton.highligt,
				}
				self.MSQ_MButton_Data[mapButton] = data
				self.MSQ_MButton:AddButton(mapButton, data, nil,  true)
				self:MSQ_MButton_Update(mapButton)
			else
				mapButton.icon = mapButton:GetNormalTexture()
				mapButton.icon:SetTexture("Interface/QuestFrame/UI-QuestMap_Button")
				mapButton.icon:SetTexCoord(.125, .875, 0, .5)
				mapButton.puched:SetTexture("Interface/QuestFrame/UI-QuestMap_Button")
				mapButton.puched:SetTexCoord(.125, .875, .5, 1)
				mapButton.highligt:SetTexture("Interface/BUTTONS/ButtonHilight-Square")
				mapButton.highligt:SetAllPoints()
			end

			self.SetClipsChildren(mapButton, true)
			self.SetAlpha(mapButton, 1)
			self.SetHitRectInsets(mapButton, 0, 0, 0, 0)
			self.SetParent(mapButton, self)
			self.HookScript(mapButton, "OnEnter", enter)
			self.HookScript(mapButton, "OnLeave", leave)
			tinsert(self.minimapButtons, mapButton)
			tinsert(self.mixedButtons, mapButton)
		end
	end

	local tstmp = tonumber(self.db.tstmp) or t
	local maxTime = 7776000 -- 60 * 60 * 24 * 90 = 90 days and remove
	for k, s in pairs(self.config.btnSettings) do
		if tstmp - (tonumber(s.tstmp) or 0) > maxTime then self.config.btnSettings[k] = nil end
	end
	for k, s in pairs(self.config.mbtnSettings) do
		if tstmp - (tonumber(s.tstmp) or 0) > maxTime then self.config.mbtnSettings[k] = nil end
	end
	self.db.tstmp = t

	self:createOwnMinimapButton()

	self.drag:setShowHandler()
	self:sort()
	self:setBarTypePosition()
	self:updateDragBarPosition()
	self:setButtonSize()

	self:RegisterEvent("UI_SCALE_CHANGED")
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
			if button.icon.MSQ_Coord then
				button.icon:SetTexCoord(unpack(button.icon.MSQ_Coord))
			else
				button.icon:dSetTexCoord(unpack(value))
			end
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
	--]]
	function hidingBar:addButton(name, data, update)
		if createdButtonsByName[name] then return end
		local button = CreateFrame("BUTTON", ("ADDON_%s_%s"):format(addon, name), self, "HidingBarAddonCreatedButtonTemplate")
		btnSettings[button] = self.config.btnSettings[name]
		btnSettings[button].tstmp = time()
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
			button.icon.dSetTexCoord = button.icon.SetTexCoord
			button.icon.SetTexCoord = setTexCoord
			button.iconR = data.iconR
			button.iconG = data.iconG
			button.iconB = data.iconB
			button.icon:SetVertexColor(data.iconR or 1, data.iconG or 1, data.iconB or 1)
			if data.iconDesaturated ~= nil then
				button.iconDesaturated = data.iconDesaturated
				button.icon:SetDesaturated(data.iconDesaturated)
			end
		end
		if data.OnClick then
			button:SetScript("OnClick", data.OnClick)
		end
		button:HookScript("OnEnter", enter)
		button:HookScript("OnLeave", leave)
		button.IsShown = IsShown
		tinsert(self.createdButtons, button)
		tinsert(self.mixedButtons, button)
		if update then
			self:sort()
			self:applyLayout()
			self:leave()
			config:createButton(name, button, update)
		end

		if self.MSQ_Button then
			local buttonData = {
				Icon = button.icon,
				Highlight = button.highlight,
			}
			self.MSQ_Button:AddButton(button, buttonData, nil, true)
		end

		return button
	end
end


function hidingBar:ldbi_add(_, button, name)
	if name == addon then return end
	self:addMButton(button)
	self:sort()
	self:setButtonSize()
	config:createMButton(button:GetName(), button.icon, true)
end


function hidingBar:grabMinimapAddonsButtons(parentFrame)
	for _, child in ipairs({parentFrame:GetChildren()}) do
		local width, height = child:GetSize()
		if max(width, height) > 16 and math.abs(width - height) < 5 then
			self:addMButton(child)
		end
	end
end


function hidingBar:addMButton(button)
	local name = button:GetName()
	if not ignoreFrameList[name] and self:ignoreCheck(name) then
		if button:HasScript("OnClick") and button:GetScript("OnClick")
		or button:HasScript("OnMouseUp") and button:GetScript("OnMouseUp")
		or button:HasScript("OnMouseDown") and button:GetScript("OnMouseDown") then
			if name then
				btnSettings[button] = self.config.mbtnSettings[name]
				btnSettings[button].tstmp = time()
			end

			local btn = self.minimapButtons[button[0]]
			self.minimapButtons[button[0]] = nil
			if btn ~= button then
				self:setHooks(button)
			end

			if self.MSQ_MButton and button:GetObjectType() == "Button" then
				self:setMButtonRegions(button)
			end

			local function setMouseEvents(frame)
				if frame:IsMouseEnabled() then
					self.SetHitRectInsets(frame, 0, 0, 0, 0)
					self.HookScript(frame, "OnEnter", enter)
					self.HookScript(frame, "OnLeave", leave)
				end
				for _, fchild in ipairs({frame:GetChildren()}) do
					setMouseEvents(fchild)
				end
			end
			setMouseEvents(button)

			self.SetFixedFrameStrata(button, false)
			self.SetFixedFrameLevel(button, false)
			self.SetClipsChildren(button, true)
			self.SetAlpha(button, 1)
			self.SetParent(button, self)
			tinsert(self.minimapButtons, button)
			tinsert(self.mixedButtons, button)
		else
			local mouseEnabled, clickable = {}
			local function getMouseEnabled(frame)
				if frame:IsMouseEnabled() then
					tinsert(mouseEnabled, frame)
					if frame:HasScript("OnClick") and frame:GetScript("OnClick") then
						clickable = true
					end
				end
				for _, fchild in ipairs({frame:GetChildren()}) do
					getMouseEnabled(fchild)
				end
			end
			getMouseEnabled(button)

			if clickable then
				if name then
					btnSettings[button] = self.config.mbtnSettings[name]
					btnSettings[button].tstmp = time()
				end

				self:setHooks(button)
				for _, frame in ipairs(mouseEnabled) do
					frame:SetHitRectInsets(0, 0, 0, 0)
					frame:HookScript("OnEnter", enter)
					frame:HookScript("OnLeave", leave)
				end

				self.SetFixedFrameStrata(button, false)
				self.SetFixedFrameLevel(button, false)
				self.SetClipsChildren(button, true)
				self.SetAlpha(button, 1)
				self.SetHitRectInsets(button, 0, 0, 0, 0)
				self.SetParent(button, self)
				tinsert(self.minimapButtons, button)
				tinsert(self.mixedButtons, button)
			end
		end
	end
end


function hidingBar:setMButtonRegions(btn, getData)
	local name, texture, layer, border, background, icon, highlight, data
	for _, region in ipairs({btn:GetRegions()}) do
		if region:GetObjectType() == "Texture" then
			name = region:GetDebugName():lower()
			texture = region:GetTexture()
			layer = region:GetDrawLayer()
			if type(texture) == "string" and texture:find("MiniMap%-TrackingBorder") then
				border = region
			end
			if type(texture) == "string" and texture:find("UI%-Minimap%-Background") or name:find("background") then
				background = region
			end
			if name:find("icon") or type(texture) == "string" and texture:lower():find("icon") then
				icon = region
			end
			if name:find("highlight") or layer == "HIGHLIGHT" then
				highlight = region
			end
		end
	end
	if border and icon then
		data = {
			_Border = border,
			_Background = background,
			Icon = icon,
			Highlight = highlight,
		}
		self.MSQ_MButton_Data[btn] = data
	elseif highlight then
		data = {Highlight = highlight}
	end

	if getData then return data end
	self.MSQ_MButton:AddButton(btn, data, nil, true)
	self:MSQ_MButton_Update(btn)
end


do
	local function IsShown(btn)
		local data = btnSettings[btn]
		local show = not (data and data[1])
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


function hidingBar:setLineColor(r, g, b)
	local color = self.config.lineColor
	if r then color[1] = r end
	if g then color[2] = g end
	if b then color[3] = b end
	self.drag.bg:SetColorTexture(unpack(color))
end


function hidingBar:setBackgroundColor(r, g, b, a)
	local color = self.config.bgColor
	if r then color[1] = r end
	if g then color[2] = g end
	if b then color[3] = b end
	if a then color[4] = a end
	self.bg:SetVertexColor(unpack(color))
end


function hidingBar:setOrientation(orientation)
	self.config.orientation = orientation
	self:applyLayout()
end


function hidingBar:setFade(fade)
	self.config.fade = fade
	if fade and self.drag:IsShown() then
		UIFrameFadeOut(self.drag, 1.5, self.drag:GetAlpha(), self.config.fadeOpacity)
	else
		UIFrameFadeRemoveFrame(self.drag)
		self.drag:SetAlpha(1)
	end
end


function hidingBar:setFadeOpacity(opacity)
	self.config.fadeOpacity = opacity
	UIFrameFadeRemoveFrame(self.drag)
	self.drag:SetAlpha(opacity)
end


function hidingBar:setLineWidth(width)
	if width then self.config.lineWidth = width end
	self.drag:SetSize(self.config.lineWidth, self.config.lineWidth)
end


function hidingBar:setMaxButtons(size)
	self.config.size = size
	self:applyLayout()
end


function hidingBar:setButtonSize(size)
	if size then self.config.buttonSize = size end

	for _, btn in ipairs(self.createdButtons) do
		btn:SetScale(self.config.buttonSize / btn:GetWidth())
	end
	for _, btn in ipairs(self.minimapButtons) do
		local width, height = btn:GetSize()
		local maxSize = width > height and width or height
		self.SetScale(btn, self.config.buttonSize / maxSize)
	end

	self:applyLayout()
end


function hidingBar:setMBtnPosition(position)
	self.config.mbtnPosition = position
	self:applyLayout()
end


function hidingBar:setPointBtn(btn, order, orientation)
	order = order - 1
	local size = self.config.size
	local x = order % size * self.config.buttonSize + offsetX
	local y = -math.floor(order / size) * self.config.buttonSize - offsetY
	if orientation == 2 then x, y = -y, -x end
	self.ClearAllPoints(btn)
	local scale = btn:GetScale()
	self.SetPoint(btn, "TOPLEFT", x / scale, y / scale)
end


function hidingBar:applyLayout()
	local orientation
	if self.config.orientation == 0 then
		orientation = (self.anchorObj.anchor == "left" or self.anchorObj.anchor == "right") and 1 or 2
	else
		orientation = self.config.orientation
	end

	local i, maxButtons, line = 0
	if self.config.mbtnPosition == 2 then
		for _, btn in ipairs(self.mixedButtons) do
			if btn:IsShown() then
				i = i + 1
				self:setPointBtn(btn, i, orientation)
			end
		end
		self.shown = i ~= 0
		maxButtons = i
		line = math.ceil(i / self.config.size)
	else
		for _, btn in ipairs(self.createdButtons) do
			if btn:IsShown() then
				i = i + 1
				self:setPointBtn(btn, i, orientation)
			end
		end
		local followed = self.config.mbtnPosition == 1
		local orderDelta = followed and i or math.ceil(i / self.config.size) * self.config.size
		local j = 0
		for _, btn in ipairs(self.minimapButtons) do
			if btn:IsShown() then
				j = j + 1
				self:setPointBtn(btn, j + orderDelta, orientation)
			end
		end
		self.shown = i + j ~= 0
		maxButtons = followed and i + j or i > j and i or j
		line = math.ceil((j + orderDelta) / self.config.size)
	end

	if not self.shown then self:Hide() end
	self:refreshShown()

	if maxButtons > self.config.size then maxButtons = self.config.size end
	local width = maxButtons * self.config.buttonSize + offsetX * 2
	local height = line * self.config.buttonSize + offsetY * 2
	if orientation == 2 then width, height = height, width end
	self:SetSize(width, height)
	return width, height
end


function hidingBar:setLocked(lock)
	self.config.lock = lock
	self:refreshShown()
	if lock then
		ldbi:Lock(addon)
	else
		ldbi:Unlock(addon)
	end
end


function hidingBar:setFrameStrata(strata)
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


function hidingBar:updateDragBarPosition()
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


function hidingBar:setOMBAnchor(anchor)
	if self.config.barTypePosition ~= 2 or self.config.omb.anchor == anchor then return end
	self.config.omb.anchor = anchor
	self:applyLayout()
	self:setBarTypePosition()
end


function hidingBar:setOMBSize(size)
	if size then self.config.omb.size = size end
	if self.omb then
		self.omb:SetScale(self.config.omb.size / self.omb:GetWidth())
	end
end


function hidingBar:setBarAnchor(anchor)
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


function hidingBar:setBarExpand(expand)
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


function hidingBar:setBarTypePosition(typePosition)
	if typePosition then self.config.barTypePosition = typePosition end

	if self.config.barTypePosition == 2 then
		ldbi:Show(addon)
		if not self.omb then
			self.omb = ldbi:GetMinimapButton(addon)
			self.omb.dSetPoint = self.omb.SetPoint
			self.omb.SetPoint = function(self, point, rFrame, rPoint, x, y)
				local scale = self:GetScale()
				if not rFrame or type(rFrame) == "number" then
					rFrame = (rFrame or 0) / scale
					rPoint = (rPoint or 0) / scale
				else
					x = (x or 0) / scale
					y = (y or 0) / scale
				end
				self:dSetPoint(point, rFrame, rPoint, x, y)
			end
			self:setOMBSize()
			if MSQ then
				self.MSQ_OMB = MSQ:Group(addon, L["Own Minimap Button"], "OMB")
				self.MSQ_OMB:SetCallback(function() self:MSQ_MButton_Update(self.omb) end)
				self.MSQ_OMB:AddButton(self.omb, self:setMButtonRegions(self.omb, true), nil, true)
				self:MSQ_MButton_Update(self.omb)
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
			self.ldb_icon.icon = "Interface/Icons/misc_arrowright"
		elseif self.config.omb.anchor == "right" then
			secondPosition = -btnSize
			self.ldb_icon.icon = "Interface/Icons/misc_arrowleft"
		elseif self.config.omb.anchor == "top" then
			secondPosition = -btnSize
			self.ldb_icon.icon = "Interface/Icons/misc_arrowdown"
		else
			secondPosition = btnSize
			self.ldb_icon.icon = "Interface/Icons/misc_arrowlup"
		end

		self.anchorObj = self.config.omb
		self.rFrame = self.omb
		self.position = position
		self.secondPosition = secondPosition
	else
		ldbi:Hide(addon)
		self.anchorObj = self.config
		self.rFrame = UIParent
		self.position = nil
		self.secondPosition = nil
	end

	if typePosition then self:applyLayout() end
	self:updateBarPosition()
end


function hidingBar:setBarCoords(position, secondPosition)
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

	function hidingBar:updateBarPosition()
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

		config:updateCoords()

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


function hidingBar:dragBar()
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

			config:applyLayout(.3)
			if config.hideToCombobox then
				UIDropDownMenu_SetSelectedValue(config.hideToCombobox, self.config.anchor)
			end
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


hidingBar.drag:SetScript("OnMouseDown", function(_, button)
	if button == "LeftButton" and not hidingBar.config.lock and hidingBar:IsShown() then
		hidingBar.isDrag = true
		hidingBar.cover:Show()
		hidingBar:SetScript("OnUpdate", hidingBar.dragBar)
	elseif button == "RightButton" then
		if IsAltKeyDown() then
			self:setLocked(not hidingBar.config.lock)
			if config.lock then config.lock:SetChecked(hidingBar.config.lock) end
		end
		if IsShiftKeyDown() then
			config:openConfig()
		end
	end
end)
hidingBar.drag:SetScript("OnMouseUp", function(_, button)
	if button == "LeftButton" and hidingBar.isDrag then
		hidingBar.isDrag = false
		hidingBar.cover:Hide()
		hidingBar:SetScript("OnUpdate", nil)
		if not hidingBar.isMouse then
			hidingBar:leave()
		end
	end
end)


function hidingBar:enter(force)
	self.isMouse = true
	if not self.isDrag and self.shown and (self.config.showHandler ~= 3 or force) then
		UIFrameFadeRemoveFrame(self.drag)
		self.drag:SetAlpha(1)
		self:SetScript("OnUpdate", nil)
		self:Show()
		self:Raise()
		self:updateDragBarPosition()
	end
end
hidingBar:SetScript("OnEnter", hidingBar.enter)


function hidingBar:hideBar(elapsed)
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


function hidingBar:leave()
	self.isMouse = false
	if not self.isDrag and self:IsShown() and self.config.showHandler ~= 3 then
		self.timer = self.config.hideDelay
		self:SetScript("OnUpdate", self.hideBar)
	end
end
hidingBar:SetScript("OnLeave", hidingBar.leave)


function hidingBar:refreshShown()
	if self.config.barTypePosition == 2 then
		self.drag:Hide()
		if self.config.showHandler == 3 then
			self:enter(true)
		end
		if self:IsShown() then
			self:leave()
		end
	elseif self.config.showHandler == 3 then
		self:enter(true)
		self.drag:SetShown(not self.config.lock and self.shown)
	else
		if self:IsShown() then
			self:leave()
		else
			self:updateDragBarPosition()
			if self.config.fade then
				UIFrameFadeOut(self.drag, 1.5, self.drag:GetAlpha(), self.config.fadeOpacity)
			end
		end
		self.drag:SetShown(self.shown)
	end
end


function hidingBar.drag:hoverHandler()
	if self:IsShown() and hidingBar.config.fade then
		UIFrameFadeOut(self, hidingBar.config.showDelay, self:GetAlpha(), 1)
	end
end


function hidingBar.drag:showBarDelay(elapsed)
	self.timer = self.timer - elapsed
	if self.timer <= 0 then
		self:SetScript("OnUpdate", nil)
		hidingBar:enter()
	end
end


function hidingBar.drag:showOnHoverWithDelay()
	if hidingBar:IsShown() or hidingBar.config.showDelay == 0 then
		hidingBar:enter()
	else
		self:hoverHandler()
		self.fTimer.timer = hidingBar.config.showDelay
		self.fTimer:SetScript("OnUpdate", self.showBarDelay)
	end
end


function hidingBar.drag:setShowHandler(showHandler)
	if showHandler then hidingBar.config.showHandler = showHandler end

	if hidingBar.config.showHandler == 3 then
		self:SetScript("OnEnter", nil)
		self:SetScript("OnClick", nil)
	elseif hidingBar.config.showHandler == 2 then
		self:SetScript("OnEnter", self.showOnHoverWithDelay)
		self:SetScript("OnClick", enter)
	elseif hidingBar.config.showHandler == 1 then
		self:SetScript("OnEnter", self.hoverHandler)
		self:SetScript("OnClick", enter)
	else
		self:SetScript("OnEnter", self.showOnHoverWithDelay)
		self:SetScript("OnClick", nil)
	end

	hidingBar:refreshShown()
end


hidingBar.drag:SetScript("OnLeave", function(self)
	self.fTimer:SetScript("OnUpdate", nil)
	if hidingBar.config.fade and not hidingBar:IsShown() and self:IsShown() then
		UIFrameFadeOut(self, hidingBar.config.showDelay, self:GetAlpha(), hidingBar.config.fadeOpacity)
	end
	hidingBar:leave()
end)