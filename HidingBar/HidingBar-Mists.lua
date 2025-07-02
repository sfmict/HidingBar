local hb = HidingBarAddon


hb:addToIgnoreFrameList("GameTimeFrame")
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

	-- CALENDAR BUTTON
	local GameTimeFrame = GameTimeFrame
	if GameTimeFrame and self:ignoreCheck("GameTimeFrame") and not self.btnParams[GameTimeFrame] then
		local text = GameTimeFrame:GetFontString()
		text:SetPoint("CENTER", 0, -1)
		GameTimeFrame:SetNormalFontObject("GameFontBlackMedium")
		GameTimeCalendarInvitesTexture:SetPoint("CENTER")
		GameTimeCalendarInvitesGlow.Show = void
		GameTimeCalendarInvitesGlow:Hide()
		self:setHooks(GameTimeFrame)
		self:setSecureHooks(GameTimeFrame)
		local p = self:setParams(GameTimeFrame, function(p, GameTimeFrame)
			GameTimeCalendarInvitesGlow.Show = nil
			GameTimeFrame:SetScript("OnUpdate", p.OnUpdate)
		end)
		p.tooltipFrame = GameTooltip
		p.OnUpdate = GameTimeFrame:GetScript("OnUpdate")
		self.HookScript(GameTimeFrame, "OnUpdate", function(GameTimeFrame)
			local bar = GameTimeFrame:GetParent()
			if bar.config.interceptTooltip and GameTooltip:IsOwned(GameTimeFrame) then
				bar:updateTooltipPosition()
			end
		end)

		if not GameTimeFrame.__MSQ_Addon then
			GameTimeFrame:GetNormalTexture():SetTexCoord(0, .375, 0, .75)
			GameTimeFrame:GetPushedTexture():SetTexCoord(.5, .875, 0, .75)
			GameTimeFrame:GetHighlightTexture():SetTexCoord(0, 1, 0, .9375)

			if checkMasqueConditions(GameTimeFrame) then
				self:setMButtonRegions(GameTimeFrame, {.0859375, .296875, .156255, .59375})
			end
		end

		tinsert(self.minimapButtons, GameTimeFrame)
		tinsert(self.mixedButtons, GameTimeFrame)
	end

	-- TRACKING BUTTON
	local MiniMapTracking = MiniMapTracking
	if MiniMapTracking and self:ignoreCheck("MiniMapTracking") and not self.btnParams[MiniMapTracking] then
		local MiniMapTrackingButton = MiniMapTrackingButton
		local icon = MiniMapTrackingIcon
		MiniMapTracking.rButton = MiniMapTrackingButton
		self:setHooks(MiniMapTracking)
		self:setSecureHooks(MiniMapTracking)
		local p = self:setParams(MiniMapTracking, function(p)
			if MiniMapTrackingButton.__MSQ_Addon then return end
			icon.SetPoint = nil
			MiniMapTrackingButton:SetScript("OnMouseDown", p.OnMouseDown)
			MiniMapTrackingButton:SetScript("OnMouseUp", p.OnMouseUp)
		end)

		icon:ClearAllPoints()
		icon:SetPoint("CENTER")
		hooksecurefunc(icon, "SetPoint", function(icon)
			icon:ClearAllPoints()
			self.SetPoint(icon, "CENTER")
		end)
		p.OnMouseDown = MiniMapTrackingButton:GetScript("OnMouseDown")
		p.OnMouseUp = MiniMapTrackingButton:GetScript("OnMouseUp")
		MiniMapTrackingButton:HookScript("OnMouseDown", function()
			icon:SetScale(.9)
		end)
		MiniMapTrackingButton:HookScript("OnMouseUp", function()
			icon:SetScale(1)
		end)

		if checkMasqueConditions(MiniMapTrackingButton, self:getMBtnSettings(MiniMapTracking)) then
			self.MSQ_Button_Data[MiniMapTrackingButton] = {
				_Border = MiniMapTrackingButtonBorder,
				_Background = MiniMapTrackingBackground,
			}
			self:setTexCurCoord(icon, icon:GetTexCoord())
			icon.SetTexCoord = self.setTexCoord
			local data = {
				Icon = icon,
				Highlight = MiniMapTrackingButton:GetHighlightTexture()
			}
			self.MSQ_MButton:AddButton(MiniMapTrackingButton, data, "Legacy", true)
			self:MSQ_Button_Update(MiniMapTrackingButton)
			self:MSQ_CoordUpdate(MiniMapTrackingButton)
		end

		tinsert(self.minimapButtons, MiniMapTracking)
		tinsert(self.mixedButtons, MiniMapTracking)
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

		local btnData = self:getMBtnSettings(mail)
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

			local p = self:setParams(zoom, function(p, zoom)
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
	if mapButton and self:ignoreCheck("MiniMapWorldMapButton") and not self.btnParams[mapButton] then
		self:setHooks(mapButton)
		self:setSecureHooks(mapButton)

		local p = self:setParams(mapButton, function(p, mapButton)
			if mapButton.__MSQ_Addon then return end
			mapButton.normal:SetTexture(p.normalTexture)
			mapButton.normal:SetTexCoord(unpack(p.normalCoords))
			mapButton.normal:SetAllPoints()
			mapButton.puched:SetTexture(p.pushedTexture)
			mapButton.puched:SetTexCoord(unpack(p.pushedCoords))
			mapButton.puched:SetAllPoints()
			mapButton.highlight:SetTexture(p.highlightTexture)
			mapButton.highlight:SetTexCoord(unpack(p.highlightCoords))
			mapButton.highlight:ClearAllPoints()
			mapButton.highlight:SetPoint(unpack(p.highlightPoint))
			mapButton.border:Hide()
		end)

		if not mapButton.__MSQ_Addon then
			mapButton.normal = mapButton:GetNormalTexture()
			p.normalTexture = mapButton.normal:GetTexture()
			p.normalCoords = {mapButton.normal:GetTexCoord()}
			mapButton.normal:SetTexture("Interface/QuestFrame/UI-QuestMap_Button")
			mapButton.normal:SetTexCoord(.125, .875, 0, .5)
			mapButton.normal:SetSize(27, 27)
			mapButton.normal:ClearAllPoints()
			mapButton.normal:SetPoint("CENTER")
			mapButton.puched = mapButton:GetPushedTexture()
			p.pushedTexture = mapButton.puched:GetTexture()
			p.pushedCoords = {mapButton.puched:GetTexCoord()}
			mapButton.puched:SetTexture("Interface/QuestFrame/UI-QuestMap_Button")
			mapButton.puched:SetTexCoord(.125, .875, .5, 1)
			mapButton.puched:SetSize(27, 27)
			mapButton.puched:ClearAllPoints()
			mapButton.puched:SetPoint("CENTER")
			mapButton.highlight = mapButton:GetHighlightTexture()
			p.highlightTexture = mapButton.highlight:GetTexture()
			p.highlightCoords = {mapButton.highlight:GetTexCoord()}
			p.highlightPoint = {mapButton.highlight:GetPoint()}
			mapButton.highlight:SetTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")
			mapButton.highlight:SetAllPoints()
			mapButton.border = mapButton.border or mapButton:CreateTexture(nil, "OVERLAY")
			mapButton.border:SetTexture("Interface/Minimap/MiniMap-TrackingBorder")
			mapButton.border:SetSize(54, 54)
			mapButton.border:SetPoint("TOPLEFT", 0, -1)
			mapButton.border:Show()

			if checkMasqueConditions(mapButton) then
				self:setMButtonRegions(mapButton)
			end
		end

		tinsert(self.minimapButtons, mapButton)
		tinsert(self.mixedButtons, mapButton)
	end
end


function hb:PET_BATTLE_OPENING_START()
	self.petBattle = true
	if self.currentProfile then
		for i = 1, #self.currentProfile.bars do
			self.bars[i]:refreshShown()
		end
	end
end


function hb:PET_BATTLE_CLOSE()
	self.petBattle = nil
	if self.currentProfile then
		for i = 1, #self.currentProfile.bars do
			self.bars[i]:refreshShown()
		end
	end
end


hb:RegisterEvent("PET_BATTLE_OPENING_START")
hb:RegisterEvent("PET_BATTLE_CLOSE")