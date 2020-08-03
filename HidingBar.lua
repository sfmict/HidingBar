local addon, L = ...
local config = _G[addon.."ConfigAddon"]
local hidingBar = CreateFrame("FRAME", addon.."Addon", UIParent, "HidingBarAddonPanel")
hidingBar.cover = CreateFrame("FRAME", nil, hidingBar)
hidingBar.cover:Hide()
hidingBar.cover:SetAllPoints()
hidingBar.cover:EnableMouse(true)
hidingBar.cover:SetFrameLevel(hidingBar:GetFrameLevel() + 10)
hidingBar.drag = CreateFrame("FRAME", nil, UIParent)
hidingBar.drag:SetFrameStrata("DIALOG")
hidingBar.drag:EnableMouse(true)
hidingBar.drag:SetSize(4, 4)
hidingBar.drag:SetHitRectInsets(-2, -2, -2, -2)
hidingBar.drag.bg = hidingBar.drag:CreateTexture(nil, "OVERLAY")
hidingBar.drag.bg:SetAllPoints()
hidingBar.drag.bg:SetColorTexture(.8, .6, 0)
hidingBar.createdButtons, hidingBar.minimapButtons = {}, {}
local createdButtonsByName = {}


local ignoreFrameList = {
	["MiniMapBattlefieldFrame"] = true,
	["HelpOpenTicketButton"] = true,
	["HelpOpenWebTicketButton"] = true,
	["MinimapBackdrop"] = true,
}


local function enter() hidingBar:enter() end
local function leave() hidingBar:leave() end


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
		self.config.size = self.config.size or 10
		self.config.buttonSize = self.config.buttonSize or 32
		self.config.anchor = self.config.anchor or "top"
		self.config.fadeOpacity = self.config.fadeOpacity or .2
		self.config.ignoreMBtn = self.config.ignoreMBtn or {}
		self.config.btnSettings = setmetatable(self.config.btnSettings or {}, meta)
		self.config.mbtnSettings = setmetatable(self.config.mbtnSettings or {}, meta)

		config.hidingBar = self
		config.config = self.config

		C_Timer.After(0, function() self:init() end)
	end
end


function hidingBar:UI_SCALE_CHANGED()
	self.position = nil
	self:setBarPosition()
end


function hidingBar:ignoreCheck(name)
	if not name then return true end
	for i = 1, #self.config.ignoreMBtn do
		if name:find(self.config.ignoreMBtn[i]) then return end
	end
	return true
end


function hidingBar:init()
	local t = time()

	local MSQ = LibStub("Masque", true)
	if MSQ then
		self.MSQ_Button = MSQ:Group(addon, L["DataBroker Buttons"])
		self.MSQ_Button:SetCallback(function()
			self:enter()
			self:leave()
		end)
		self.MSQ_MButton = MSQ:Group(addon, L["Minimap Buttons"])
		self.MSQ_MButton_Data = {}
		function self:MSQ_MButton_Update(btn)
			if not btn.__MSQ_Enabled then return end
			local data = self.MSQ_MButton_Data[btn]
			if data then
				data._Border:Hide()
				if data._Background then
					data._Background:Hide()
				end
			end
		end
		self.MSQ_MButton:SetCallback(function()
			for _, btn in ipairs(self.minimapButtons) do
				self:MSQ_MButton_Update(btn)
			end
			self:enter()
			self:leave()
		end)
	end

	local ldb = LibStub("LibDataBroker-1.1")
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
		local ldbi = LibStub("LibDBIcon-1.0", true)
		if ldbi then
			local ldbiTbl = ldbi:GetButtonList()
			for i = 1, #ldbiTbl do
				local button = ldbi:GetMinimapButton(ldbiTbl[i])
				local name = button:GetName()
				if self:ignoreCheck(name) and (name or self.config.grabMinimapWithoutName) then
					self.minimapButtons[button[0]] = button
					self:setHooks(button)
				end
			end
		end

		for _, child in ipairs({Minimap:GetChildren()}) do
			local name = child:GetName()
			local width, height = child:GetSize()
			if not ignoreFrameList[name] and self:ignoreCheck(name) and (name or self.config.grabMinimapWithoutName) and math.abs(width - height) < 5 then
				if child:HasScript("OnClick") and child:GetScript("OnClick") then
					if name then self.config.mbtnSettings[name].tstmp = t end

					local btn = self.minimapButtons[child[0]]
					self.minimapButtons[child[0]] = nil
					if not btn or btn ~= child then
						self:setHooks(child)
					end

					if self.MSQ_MButton then
						self:setMButtonRegions(child)
					end

					self.SetClipsChildren(child, true)
					self.SetAlpha(child, 1)
					self.SetHitRectInsets(child, 0, 0, 0, 0)
					self.SetParent(child, self)
					self.SetScript(child, "OnUpdate", nil)
					self.HookScript(child, "OnEnter", enter)
					self.HookScript(child, "OnLeave", leave)
					tinsert(self.minimapButtons, child)
				else
					local mouseEnabled, clickable = {}
					local function getMouseEnabled(frame)
						for _, fchild in ipairs({frame:GetChildren()}) do
							if fchild:IsMouseEnabled() then
								tinsert(mouseEnabled, fchild)
								if fchild:HasScript("OnClick") and fchild:GetScript("OnClick") then
									clickable = true
								end
							end
							getMouseEnabled(fchild)
						end
					end
					getMouseEnabled(child)

					if clickable then
						if name then self.config.mbtnSettings[name].tstmp = t end

						self:setHooks(child)
						for _, frame in ipairs(mouseEnabled) do
							frame:SetHitRectInsets(0, 0, 0, 0)
							frame:HookScript("OnEnter", enter)
							frame:HookScript("OnLeave", leave)
						end
						if child:IsMouseEnabled() then
							self.SetHitRectInsets(child, 0, 0, 0, 0)
							self.HookScript(child, "OnEnter", enter)
							self.HookScript(child, "OnLeave", leave)
						end

						if self.MSQ_MButton then
							self.MSQ_MButton:AddButton(child, nil, nil, true)
						end

						self.SetClipsChildren(child, true)
						self.SetAlpha(child, 1)
						self.SetParent(child, self)
						tinsert(self.minimapButtons, child)
					end
				end
			end
		end
	end

	local tstmp = self.db.tstmp or t
	local maxTime = 60 * 60 * 24 * 90 -- 90 days and remove
	for k, s in pairs(self.config.btnSettings) do
		if tstmp - s.tstmp > maxTime then self.config.btnSettings[k] = nil end
	end
	for k, s in pairs(self.config.mbtnSettings) do
		if tstmp - s.tstmp > maxTime then self.config.mbtnSettings[k] = nil end
	end
	self.db.tstmp = t

	self:sort()
	self:setButtonSize()
	self:applyLayout()
	self:setBarPosition()
	self:leave()

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
	self.config.btnSettings[name].tstmp = time()
	local button = CreateFrame("BUTTON", ("ADDON_%s_%s"):format(addon, name), self, "HidingBarAddonCreatedButtonTemplate")
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
	tinsert(self.createdButtons, button)
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


function hidingBar:setMButtonRegions(btn)
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
				highligt = region
			end
		end
	end
	if border and icon then
		data = {
			_Border = border,
			_Background = background,
			Icon = icon,
			Highlight = highligt,
		}
		self.MSQ_MButton_Data[btn] = data
	end
	self.MSQ_MButton:AddButton(btn, data, nil, true)
	self:MSQ_MButton_Update(btn)
end


local function void() end
function hidingBar:setHooks(btn)
	btn.CreateAnimationGroup = function(self, ...)
		local animationGroup = getmetatable(self).__index.CreateAnimationGroup(self, ...)
		animationGroup.Play = void
		return animationGroup
	end
	for _, animationGroup in ipairs({btn:GetAnimationGroups()}) do
		animationGroup:Stop()
		animationGroup.Play = void
	end
	btn.SetHitRectInsets = void
	btn.ClearAllPoints = void
	btn.StartMoving = void
	btn.SetParent = void
	btn.Show = void
	btn.Hide = void
	btn.SetShown = void
	btn.SetPoint = void
	btn.SetAlpha = void
	btn.SetScale = void
	btn.SetSize = void
	btn.SetWidth = void
	btn.SetHeight = void
	btn.HookScript = void
	btn.SetScript = function(self, event, ...)
		event = event:lower()
		if event ~= "onupdate" and event ~= "ondragstart" and event ~= "ondragstop" then
			getmetatable(self).__index.SetScript(self, event, ...)
		end
	end
end


function hidingBar:sort()
	sort(self.createdButtons, function(a, b)
		local o1, o2 = self.config.btnSettings[a.name][2], self.config.btnSettings[b.name][2]
		return o1 and not o2
			 or o1 and o2 and o1 < o2
			 or o1 == o2 and a.name < b.name
	end)
	sort(self.minimapButtons, function(a, b)
		local n1, n2, o1, o2 = a:GetName(), b:GetName()
		if n1 then o1 = self.config.mbtnSettings[n1][2] end
		if n2 then o2 = self.config.mbtnSettings[n2][2] end
		return o1 and not o2
			 or o1 and o2 and o1 < o2
			 or o1 == o2 and (n1 and not n2
								or n1 and n2 and n1 < n2)
	end)
end


function hidingBar:setButtonSize()
	for _, btn in ipairs(self.createdButtons) do
		btn:SetScale(self.config.buttonSize / btn:GetWidth())
	end
	for _, btn in ipairs(self.minimapButtons) do
		local width, height = btn:GetSize()
		local maxSize = width > height and width or height
		self.SetScale(btn, self.config.buttonSize / maxSize)
	end
end


function hidingBar:setPointBtn(btn, offsetX, offsetY, order, orientation)
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
	local offsetX, offsetY, orientation = 2, 2
	if self.config.orientation == 0 then
		orientation = (self.config.anchor == "left" or self.config.anchor == "right") and 1 or 2
	else
		orientation = self.config.orientation
	end

	local i = 0
	for _, btn in ipairs(self.createdButtons) do
		if not self.config.btnSettings[btn.name][1] then
			i = i + 1
			self:setPointBtn(btn, offsetX, offsetY, i, orientation)
			btn:Show()
		else
			btn:Hide()
		end
	end
	local line = math.ceil(i / self.config.size)
	local offsetYm = line * self.config.buttonSize + offsetY
	local j = 0
	for _, btn in ipairs(self.minimapButtons) do
		local name = btn:GetName()
		if not name or not self.config.mbtnSettings[name][1] then
			j = j + 1
			self:setPointBtn(btn, offsetX, offsetYm, j, orientation)
			self.Show(btn)
		else
			self.Hide(btn)
		end
	end

	local shown = i + j ~= 0
	self.drag:SetShown(shown)
	if not shown then self:Hide() end

	local maxButtons = i > j and i or j
	if maxButtons > self.config.size then maxButtons = self.config.size end
	line = line + math.ceil(j / self.config.size)
	local width = maxButtons * self.config.buttonSize + offsetX * 2
	local height = line * self.config.buttonSize + offsetY * 2
	if orientation == 1 then
		self:SetSize(width, height)
	else
		self:SetSize(height, width)
	end
	return self:GetSize()
end


function hidingBar:setDragBarPosition()
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


function hidingBar:setBarPosition()
	if not self.position then
		local scale = UIParent:GetScale()
		if not self.config.position then
			if self.config.anchor == "left" or self.config.anchor =="right" then
				self.config.position = WorldFrame:GetHeight() / 2 - self:GetHeight() / 2 * scale
			else
				self.config.position = WorldFrame:GetWidth() / 2 - self:GetWidth() / 2 * scale
			end
		end
		self.position = self.config.position / scale
	end

	local anchor = self.config.anchor
	self:ClearAllPoints()
	if anchor == "left" then
		self:SetPoint("BOTTOMLEFT", 0, self.position)
	elseif anchor == "right" then
		self:SetPoint("BOTTOMRIGHT", 0, self.position)
	elseif anchor == "top" then
		self:SetPoint("TOPLEFT", self.position, 0)
	else
		self:SetPoint("BOTTOMLEFT", self.position, 0)
	end
end


function hidingBar:dragBar()
	local x, y = GetCursorPosition()
	local width, height = self:GetSize()
	local UIwidth, UIheight = UIParent:GetSize()
	local scale = UIParent:GetScale()
	x, y = x / scale, y / scale

	local anchor = self.config.anchor
	local offset, position = 100

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
		self:setDragBarPosition()
	end

	if anchor == "left" or anchor == "right" then
		position = y - height / 2
		if position + height > UIheight then position = UIheight - height end
	else
		position = x - width / 2
		if position + width > UIwidth then position = UIwidth - width end
	end
	if position < 0 then position = 0 end

	self.position = position
	self.config.position = position * scale
	self:setBarPosition()
end


hidingBar.drag:SetScript("OnMouseDown", function(_, button)
	if button == "LeftButton" and not hidingBar.config.lock then
		hidingBar.isDrag = true
		hidingBar.cover:Show()
		hidingBar:SetScript("OnUpdate", hidingBar.dragBar)
	elseif button == "RightButton" then
		if IsAltKeyDown() then
			hidingBar.config.lock = not hidingBar.config.lock
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


function hidingBar:enter()
	self.isMouse = true
	if not self.isDrag then
		UIFrameFadeRemoveFrame(self.drag)
		self.drag:SetAlpha(1)
		self:SetScript("OnUpdate", nil)
		self:Show()
		self:Raise()
		self:setDragBarPosition()
	end
end
hidingBar:SetScript("OnEnter", hidingBar.enter)
hidingBar.drag:SetScript("OnEnter", enter)


function hidingBar:hideBar(elapsed)
	self.timer = self.timer - elapsed
	if self.timer <= 0 then
		self:Hide()
		self:setDragBarPosition()
		self:SetScript("OnUpdate", nil)
		if self.config.fade then
			UIFrameFadeOut(self.drag, 1.5, self.drag:GetAlpha(), self.config.fadeOpacity)
		end
	end
end


function hidingBar:leave()
	self.isMouse = false
	if not self.isDrag and self:IsShown() then
		self.timer = .75
		self:SetScript("OnUpdate", self.hideBar)
	end
end
hidingBar:SetScript("OnLeave", hidingBar.leave)
hidingBar.drag:SetScript("OnLeave", leave)