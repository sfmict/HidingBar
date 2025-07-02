local addon, ns = ...
local hb = HidingBarAddon
local hidingBarMixin = ns.hidingBarMixin
local ldbi = LibStub("LibDBIcon-1.0")
hb.ombDefIcon = "Interface/MINIMAP/Vehicle-SilvershardMines-Arrow"


hb:addToIgnoreFrameList("HelpOpenWebTicketButton")
hb:addToIgnoreFrameList("MinimapBackdrop")
hb:addToIgnoreFrameList("MinimapZoomIn")
hb:addToIgnoreFrameList("MinimapZoomOut")
hb:addToIgnoreFrameList("MiniMapWorldMapButton")
hb:addToIgnoreFrameList("MiniMapMailFrame")
hb:addToIgnoreFrameList("MiniMapTracking")
hb:addToIgnoreFrameList("MiniMapBattlefieldFrame")
hb:addToIgnoreFrameList("MiniMapLFGFrame")


function hb:grabDefButtons()
	local function checkMasqueConditions(btn, btnData)
		return self.MSQ_MButton and not btn.__MSQ_Addon and not (btnData or self:getMBtnSettings(btn))[6]
	end

	-- TRACKING BUTTON
	local tracking =  MiniMapTracking
	if tracking and self:ignoreCheck("MiniMapTracking") and not self.btnParams[tracking] then
		local btnData = rawget(self.pConfig.mbtnSettings, "MiniMapTrackingFrame")
		if btnData then
			self.pConfig.mbtnSettings["MiniMapTracking"] = btnData
			self.pConfig.mbtnSettings["MiniMapTrackingFrame"] = nil
		end
		tracking.icon = MiniMapTrackingIcon
		tracking.icon:SetTexture(132328)
		tracking:GetScript("OnEvent")(tracking, "UNIT_AURA")
		tracking.show = tracking:IsShown()
		self:setHooks(tracking)
		self:setSecureHooks(tracking)
		self:setParams(tracking)

		btnData = self:getMBtnSettings(tracking)
		if btnData[5] == nil then btnData[5] = true end

		if checkMasqueConditions(tracking, btnData)then
			self:setMButtonRegions(tracking)
		end

		tinsert(self.minimapButtons, tracking)
		tinsert(self.mixedButtons, tracking)
	end

	-- MINIMAP LFG FRAME
	local LFGFrame = MiniMapLFGFrame
	if LFGFrame and self:ignoreCheck("MiniMapLFGFrame") and not self.btnParams[LFGFrame] then
		LFGFrame.icon = MiniMapLFGFrameIconTexture
		LFGFrame.icon:SetTexCoord(0, .125, 0, .25)
		self:setHooks(LFGFrame)
		self:setSecureHooks(LFGFrame)
		self:setParams(LFGFrame)

		local btnData = self:getMBtnSettings(LFGFrame)
		if btnData[5] == nil then btnData[5] = true end

		if checkMasqueConditions(LFGFrame, btnData) then
			self:setMButtonRegions(LFGFrame)
		end

		tinsert(self.minimapButtons, LFGFrame)
		tinsert(self.mixedButtons, LFGFrame)
	end

	-- BATTLEFIELD FRAME
	local battlefield = MiniMapBattlefieldFrame
	if battlefield and self:ignoreCheck("MiniMapBattlefieldFrame") and not self.btnParams[battlefield] then
		battlefield.icon = MiniMapBattlefieldIcon
		battlefield.show = battlefield:IsShown()
		self:setHooks(battlefield)
		self:setSecureHooks(battlefield)
		self:setParams(battlefield)

		local btnData = self:getMBtnSettings(battlefield)
		if btnData[5] == nil then btnData[5] = true end

		if checkMasqueConditions(battlefield, btnData) then
			self:setMButtonRegions(battlefield)
		end

		tinsert(self.minimapButtons, battlefield)
		tinsert(self.mixedButtons, battlefield)
	end

	-- MAIL
	local mail = MiniMapMailFrame
	if mail and self:ignoreCheck("MiniMapMailFrame") and not self.btnParams[mail] then
		local btnData = rawget(self.pConfig.mbtnSettings, "HidingBarAddonMail")
		if btnData then
			self.pConfig.mbtnSettings["MiniMapMailFrame"] = btnData
			self.pConfig.mbtnSettings["HidingBarAddonMail"] = nil
		end

		mail.icon = MiniMapMailIcon
		self:setHooks(mail)
		self:setSecureHooks(mail)
		self:setParams(mail)

		btnData = self:getMBtnSettings(mail)
		if btnData[5] == nil then btnData[5] = true end

		if checkMasqueConditions(mail, btnData) then
			self:setMButtonRegions(mail)
		end

		tinsert(self.minimapButtons, mail)
		tinsert(self.mixedButtons, mail)
	end

	-- ZOOM IN & ZOOM OUT
	for _, zoom in pairs({MinimapZoomIn, MinimapZoomOut}) do
		local name = zoom:GetName()
		if self:ignoreCheck(name) and not self.btnParams[zoom] then
			self:setHooks(zoom)
			self:setSecureHooks(zoom)
			local normal = zoom:GetNormalTexture()

			if checkMasqueConditions(zoom) then
				zoom.icon = zoom:CreateTexture(nil, "BACKGROUND")
				zoom.icon:SetTexture(normal:GetTexture())
				zoom:SetScript("OnMouseDown", function(self) self.icon:SetScale(.9) end)
				zoom:SetScript("OnMouseUp", function(self) self.icon:SetScale(1) end)
				self:setMButtonRegions(zoom, {.24, .79, .21, .76})
			end
			if not zoom.icon then zoom.icon = normal end

			zoom.click = zoom:GetScript("OnClick")
			zoom.Disable = function(zoom)
				zoom:SetScript("OnClick", nil)
				zoom.icon:SetDesaturated(true)
				zoom:GetNormalTexture():SetDesaturated(true)
				zoom:GetPushedTexture():SetDesaturated(true)
			end
			zoom.Enable = function(zoom)
				zoom:SetScript("OnClick", zoom.click)
				zoom.icon:SetDesaturated(false)
				zoom:GetNormalTexture():SetDesaturated(false)
				zoom:GetPushedTexture():SetDesaturated(false)
			end
			if not zoom:IsEnabled() then
				getmetatable(zoom).__index.Enable(zoom)
				zoom:Disable()
			end

			local p = self:setParams(zoom, function()
				zoom.Enable = nil
				zoom.Disable = nil
				if not zoom:GetScript("OnClick") then
					zoom.icon:SetDesaturated(false)
					zoom:GetNormalTexture():SetDesaturated(false)
					zoom:GetPushedTexture():SetDesaturated(false)
					zoom:Disable()
				end
				zoom:SetScript("OnClick", zoom.click)
			end)
			p.tooltipFrame = GameTooltip

			tinsert(self.minimapButtons, zoom)
			tinsert(self.mixedButtons, zoom)
		end
	end

	-- WORLD MAP BUTTON
	local mapButton = MiniMapWorldMapButton
	if MiniMapWorldMapButton and self:ignoreCheck("MiniMapWorldMapButton") and not self.btnParams[MiniMapWorldMapButton] then
		self:setHooks(mapButton)
		self:setSecureHooks(mapButton)
		local p = self:setParams(mapButton, function(p, mapButton)
			if mapButton.__MSQ_Addon then return end
			mapButton.normal:ClearAllPoints()
			mapButton.normal:SetPoint(unpack(p.iconPoint))
			mapButton.puched:ClearAllPoints()
			mapButton.puched:SetPoint(unpack(p.pushedPoint))
			mapButton.border:ClearAllPoints()
			mapButton.border:SetPoint(unpack(p.borderPoint))
		end)

		mapButton.normal = mapButton:GetNormalTexture()
		p.iconPoint = {mapButton.normal:GetPoint()}
		mapButton.normal:ClearAllPoints()
		mapButton.normal:SetPoint("CENTER")
		mapButton.puched = mapButton:GetPushedTexture()
		p.pushedPoint = {mapButton.puched:GetPoint()}
		mapButton.puched:ClearAllPoints()
		mapButton.puched:SetPoint("CENTER", 1, -1)
		mapButton.border = MiniMapWorldBorder
		p.borderPoint = {mapButton.border:GetPoint()}
		mapButton.border:ClearAllPoints()
		mapButton.border:SetPoint("TOPLEFT", 1, -1)

		if checkMasqueConditions(mapButton) then
			self:setMButtonRegions(mapButton)
		end

		tinsert(self.minimapButtons, mapButton)
		tinsert(self.mixedButtons, mapButton)
	end
end


function hidingBarMixin:setBarTypePosition(typePosition, force)
	if typePosition then self.config.barTypePosition = typePosition end

	if self.config.barTypePosition == 2 then
		self.config.omb.hide = self.config.ombHide

		if self.config.ombHide then
			ldbi:Hide(self.ombName)
		else
			ldbi:Show(self.ombName)
		end

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

		local rotation
		if self.config.omb.anchor == "left" then
			secondPosition = btnSize + self.config.omb.distanceToBar
			rotation = -math.pi/2
		elseif self.config.omb.anchor == "right" then
			secondPosition = -btnSize - self.config.omb.distanceToBar
			rotation = math.pi/2
		elseif self.config.omb.anchor == "top" then
			secondPosition = -btnSize - self.config.omb.distanceToBar
			rotation = math.pi
		else
			secondPosition = btnSize + self.config.omb.distanceToBar
			rotation = 0
		end
		self.ldb_icon.icon = self.config.omb.icon or hb.ombDefIcon
		self.omb.icon:SetRotation(self.config.omb.icon and 0 or rotation)

		if typePosition or force or not self.rFrame then
			frameFadeStop(self.omb, 1)
			self.omb:GetScript("OnLeave")(self.omb)
			self.rFrame = self.omb
		end

		self.anchorObj = self.config.omb
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