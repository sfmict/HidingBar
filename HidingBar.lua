local addon, L = ...
local config = _G[addon.."ConfigAddon"]
local hidingBar = CreateFrame("FRAME", addon.."Addon", UIParent, "HidingBarAddonPanel")
hidingBar:SetFrameStrata("DIALOG")
hidingBar:EnableMouse(true)
hidingBar.drag = CreateFrame("FRAME", nil, UIParent)
hidingBar.drag:SetFrameStrata("DIALOG")
hidingBar.drag:EnableMouse(true)
hidingBar.drag:SetSize(4, 4)
hidingBar.drag:SetHitRectInsets(-2, -2, -2, -2)
hidingBar.drag.bg = hidingBar.drag:CreateTexture(nil, "OVERLAY")
hidingBar.drag.bg:SetAllPoints()
hidingBar.drag.bg:SetColorTexture(.8, .6, 0)
hidingBar.createdButtons, hidingBar.minimapButtons = {}, {}


local ignoreFrameList = {
	["GameTimeFrame"] = true,
	["QueueStatusMinimapButton"] = true,
	["HelpOpenTicketButton"] = true,
	["HelpOpenWebTicketButton"] = true,
}


hidingBar:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
hidingBar:RegisterEvent("ADDON_LOADED")


function hidingBar:ADDON_LOADED(addonName)
	if addonName == addon then
		self:UnregisterEvent("ADDON_LOADED")

		HidingBarDB = HidingBarDB or {}
		self.db = HidingBarDB
		self.db.config = self.db.config or {}
		self.config = self.db.config
		self.config.orientation = self.config.orientation or 0
		self.config.size = self.config.size or 10
		self.config.anchor = self.config.anchor or "top"
		self.config.fadeOpacity = self.config.fadeOpacity or .2
		self.config.btnSettings = self.config.btnSettings or {}
		self.config.mbtnSettings = self.config.mbtnSettings or {}

		C_Timer.After(0, function() self:init() end)
	end
end


function hidingBar:init()
	local t = time()

	local ldb = LibStub("LibDataBroker-1.1")
	ldb.RegisterCallback(self, "LibDataBroker_DataObjectCreated", "ldb_add")
	for name, data in ldb:DataObjectIterator() do
		local settings = self.config.btnSettings[name]
		if settings then settings.tstmp = t end
		self:ldb_add(nil, name, data)
	end

	if self.config.grabMinimap then
		local ldbi = LibStub.libs["LibDBIcon-1.0"]
		if ldbi then
			local ldbiTbl = ldbi:GetButtonList()
			for i = 1, #ldbiTbl do
				local button = ldbi:GetMinimapButton(ldbiTbl[i])
				local settings = self.config.mbtnSettings[button:GetName()]
				if settings then settings.tstmp = t end
				self.minimapButtons[button[0]] = button
				self:setHooks(button)
			end
		end
	end

	if self.config.grabMinimap then
		for _, child in ipairs({Minimap:GetChildren()}) do
			if child:HasScript("OnClick") and math.abs(child:GetWidth() - child:GetHeight()) < 5 then
				local name = child:GetName()
				fprint(name)
				if not ignoreFrameList[name] then
					local settings = self.config.mbtnSettings[child:GetName()]
					if settings then settings.tstmp = t end

					local btn = self.minimapButtons[child[0]]
					self.minimapButtons[child[0]] = nil
					if not btn or btn ~= child then
						self:setHooks(child)
					end

					local width, height = child:GetWidth(), child:GetHeight()
					local maxSize = width > height and width or height
					self.SetScale(child, 32 / maxSize)

					self.SetParent(child, self)
					self.HookScript(child, "OnEnter", function() self:enter() end)
					self.HookScript(child, "OnLeave", function() self:leave() end)
					tinsert(self.minimapButtons, child)
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
	self:applyLayout()
	self:setPosition()
	self:leave()
end


function hidingBar:ldb_add(event, name, data)
	if name and data and data.type == "launcher" then
		self:addButton(name, data, event)
	end
end


--[[
OnEnter         - Handler OnEnter
OnLeave         - Handler OnLeave
OnClick         - Handler OnClick
icon            - Texture icon
iconDesaturated - Desaturated icon (boolean)
OnTooltipShow   - Handler tooltip show: function(TooltipFrame) .. end
--]]
function hidingBar:addButton(name, data, update)
	local buttonName  = format("ADDON_%s_%s", addon, name)
	if _G[buttonName] then return end
	local button = CreateFrame("BUTTON", buttonName, self, "HidingBarAddonCreatedButtonTemplate")
	button.id = name
	button.data = data
	if data.icon then
		button.icon:SetTexture(data.icon)
		if data.iconDesaturated then
			button.icon:SetDesaturated(true)
		end
	end
	if data.OnClick then
		button:SetScript("OnClick", data.OnClick)
	end
	button:HookScript("OnEnter", function() self:enter() end)
	button:HookScript("OnLeave", function() self:leave() end)
	tinsert(self.createdButtons, button)
	if update then
		self:sort()
		self:applyLayout()
		config:createButton(name, #self.createdButtons, data, update)
	end
	return button
end


local function void() end
function hidingBar:setHooks(btn)
	btn.CreateAnimationGroup = function(self, ...)
		local animationGroup = getmetatable(self).__index.CreateAnimationGroup(self, ...)
		animationGroup.Play = void
		return animationGroup
	end
	btn:SetAlpha(1)
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
	btn:SetScript("OnUpdate", nil)
	btn.SetScript = function(self, event, ...)
		event = event:lower()
		if event ~= "onupdate" and event ~= "ondragstart" and event ~= "ondragstop" then
			getmetatable(self).__index.SetScript(self, event, ...)
		end
	end
end


function hidingBar:sort()
	sort(self.createdButtons, function(a, b)
		local o1, o2 = self.config.btnSettings[a.id] and self.config.btnSettings[a.id][2], self.config.btnSettings[b.id] and self.config.btnSettings[b.id][2]
		return o1 and not o2
			 or o1 and o2 and o1 < o2
			 or o1 == o2 and a.id < b.id
	end)
	sort(self.minimapButtons, function(a, b)
		local n1, n2 = a:GetName(), b:GetName()
		local o1, o2 = self.config.mbtnSettings[n1] and self.config.mbtnSettings[n1][2], self.config.mbtnSettings[n2] and self.config.mbtnSettings[n2][2]
		return o1 and not o2
			 or o1 and o2 and o1 < o2
			 or o1 == o2 and (n1 and not n2
								or n1 and n2 and n1 < n2)
	end)
end


function hidingBar:setPointBtn(btn, offsetX, offsetY, order, orientation)
	local size, x, y = self.config.size
	local line = math.ceil(order / size) - 1
	self.ClearAllPoints(btn)
	if orientation == 1 then
		x = (order - 1 - line * size) * 32 + offsetX
		y = -line * 32 - offsetY
	else
		x = line * 32 + offsetY
		y = (line * size - order + 1) * 32 - offsetX
	end
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
		if not self.config.btnSettings[btn.id] or not self.config.btnSettings[btn.id][1] then
			i = i + 1
			self:setPointBtn(btn, offsetX, offsetY, i, orientation)
			btn:Show()
		else
			btn:Hide()
		end
	end
	local offsetD = math.ceil(i / self.config.size) * 32 + offsetY
	local j = 0
	for _, btn in ipairs(self.minimapButtons) do
		local name = btn:GetName()
		if not self.config.mbtnSettings[name] or not self.config.mbtnSettings[name][1] then
			j = j + 1
			self:setPointBtn(btn, offsetX, offsetD, j, orientation)
			self.Show(btn)
		else
			self.Hide(btn)
		end
	end

	local shown = i + j ~= 0
	self:SetShown(shown)
	self.drag:SetShown(shown)

	local maxButtons = i > j and i or j
	if maxButtons > self.config.size then maxButtons = self.config.size end
	local line = math.ceil(i / self.config.size) + math.ceil(j / self.config.size)
	local width = maxButtons * 32 + offsetX * 2
	local height = line * 32 + offsetY * 2
	if orientation == 1 then
		self:SetSize(width, height)
	else
		self:SetSize(height, width)
	end
	return self:GetSize()
end


function hidingBar:setPosition()
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

	self.drag:ClearAllPoints()
	if self:IsShown() then
		if self.config.anchor == "left" then
			self.drag:SetPoint("TOPRIGHT", self, "TOPRIGHT", 4, 0)
			self.drag:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, 0)
		elseif self.config.anchor == "right" then
			self.drag:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 0)
			self.drag:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -4, 0)
		elseif self.config.anchor == "top" then
			self.drag:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, -4)
			self.drag:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, -4)
		else
			self.drag:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 4)
			self.drag:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 4)
		end
	else
		if self.config.anchor == "left" then
			self.drag:SetPoint("TOPLEFT", self, "TOPLEFT")
			self.drag:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
		elseif self.config.anchor == "right" then
			self.drag:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			self.drag:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
		elseif self.config.anchor == "top" then
			self.drag:SetPoint("TOPLEFT", self, "TOPLEFT")
			self.drag:SetPoint("TOPRIGHT", self, "TOPRIGHT")
		else
			self.drag:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
			self.drag:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
		end
	end

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
	self.config.position = position * UIParent:GetScale()
	self:setPosition()
end


hidingBar.drag:SetScript("OnMouseDown", function(_, button)
	if button == "LeftButton" and not hidingBar.config.lock then
		hidingBar.isDrag = true
		hidingBar:SetScript("OnUpdate", hidingBar.dragBar)
	else
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
		self:setPosition()
	end
end
hidingBar:SetScript("OnEnter", hidingBar.enter)
hidingBar.drag:SetScript("OnEnter", function() hidingBar:enter() end)


function hidingBar:hideBar(elapsed)
	self.timer = self.timer - elapsed
	if self.timer <= 0 then
		self:Hide()
		self:setPosition()
		self:SetScript("OnUpdate", nil)
		if self.config.fade then
			UIFrameFadeOut(self.drag, 1.5, self.drag:GetAlpha(), self.config.fadeOpacity)
		end
	end
end


function hidingBar:leave()
	self.isMouse = false
	if not self.isDrag then
		self.timer = .75
		self:SetScript("OnUpdate", hidingBar.hideBar)
	end
end
hidingBar:SetScript("OnLeave", hidingBar.leave)
hidingBar.drag:SetScript("OnLeave", function() hidingBar:leave() end)