local hb = HidingBarAddon


hb:addToIgnoreFrameList("GameTimeFrame")
hb:addToIgnoreFrameList("HelpOpenWebTicketButton")
hb:addToIgnoreFrameList("MinimapBackdrop")
hb:addToIgnoreFrameList("ExpansionLandingPageMinimapButton")
hb:addToIgnoreFrameList("QueueStatusButton")
hb:addToIgnoreFrameList("AddonCompartmentFrame")
hb:addToIgnoreFrameList("Minimap.ZoomIn")
hb:addToIgnoreFrameList("Minimap.ZoomOut")
hb:addToIgnoreFrameList("MinimapCluster.Tracking")
hb:addToIgnoreFrameList("MinimapCluster.IndicatorFrame.MailFrame")
hb:addToIgnoreFrameList("MinimapCluster.IndicatorFrame.CraftingOrderFrame")


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

	local function checkMasqueConditions(btn, btnData)
		return self.MSQ_MButton and not btn.__MSQ_Addon and not (btnData or self:getMBtnSettings(btn))[6]
	end

	-- CALENDAR BUTTON
	local GameTimeFrame = GameTimeFrame
	if GameTimeFrame and self:ignoreCheck("GameTimeFrame") and not self.btnParams[GameTimeFrame] then
		self:setHooks(GameTimeFrame)
		self:setSecureHooks(GameTimeFrame)
		sexyMapRegionsHide(GameTimeFrame)

		local p = self:setParams(GameTimeFrame, function(p, GameTimeFrame)
			GameTimeFrame:SetScript("OnUpdate", p.OnUpdate)
			if not GameTimeFrame.__MSQ_Addon then
				GameTimeFrame:SetSize(p.width, p.height)
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

		p.width, p.height = GameTimeFrame:GetSize()
		self.SetSize(GameTimeFrame, 20, 20)
		p.tooltipFrame = GameTooltip
		p.OnUpdate = GameTimeFrame:GetScript("OnUpdate")
		self.HookScript(GameTimeFrame, "OnUpdate", function(GameTimeFrame)
			local bar = GameTimeFrame:GetParent()
			if bar.config.interceptTooltip and GameTooltip:IsOwned(GameTimeFrame) then
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

		if checkMasqueConditions(GameTimeFrame) then
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
	local AddonCompartmentFrame = AddonCompartmentFrame
	if AddonCompartmentFrame and self:ignoreCheck("AddonCompartmentFrame") and not self.btnParams[AddonCompartmentFrame] then
		self:setHooks(AddonCompartmentFrame)
		self:setSecureHooks(AddonCompartmentFrame)
		self:setParams(AddonCompartmentFrame)
		sexyMapRegionsHide(AddonCompartmentFrame)

		local btnData = self:getMBtnSettings(AddonCompartmentFrame)
		if btnData[5] == nil then btnData[5] = true end

		if checkMasqueConditions(AddonCompartmentFrame, btnData) then
			self:setMButtonRegions(AddonCompartmentFrame)
		end

		tinsert(self.minimapButtons, AddonCompartmentFrame)
		tinsert(self.mixedButtons, AddonCompartmentFrame)
	end

	-- TRACKING BUTTON
	local tracking = self:getFrameFromPath("MinimapCluster.Tracking")
	if tracking and self:ignoreCheck("MinimapCluster.Tracking") and not self.btnParams[tracking] then
		tracking.rButton = tracking.Button
		tracking.icon = tracking.Button:GetNormalTexture()
		self:setHooks(tracking)
		self:setSecureHooks(tracking)
		sexyMapRegionsHide(tracking)

		local p = self:setParams(tracking, function(p, tracking)
			tracking.Background:Show()
			self:unsetHooks(tracking.Button)
			self.SetSize(tracking.Button, p.btnWidth, p.btnHeight)
			self.SetIgnoreParentScale(tracking.Button, p.btnIgnoreParentScale)
			self.SetScale(tracking.Button, p.btnScale)
			self.ClearAllPoints(tracking.Button)
			for i = 1, #p.btnPoints do
				self.SetPoint(tracking.Button, unpack(p.btnPoints[i]))
			end
			if p.indicatorFramePoint then
				self.ClearAllPoints(MinimapCluster.IndicatorFrame)
				self.SetPoint(MinimapCluster.IndicatorFrame, unpack(p.indicatorFramePoint))
			end
		end)

		p.name = "MinimapCluster.Tracking"
		tracking.Background:Hide()
		p.btnWidth, p.btnHeight = self.GetSize(tracking.Button)
		self.SetSize(tracking.Button, tracking:GetSize())
		p.btnIgnoreParentScale = self.IsIgnoringParentScale(tracking.Button)
		self.SetIgnoreParentScale(tracking.Button, false)
		p.btnScale = self.GetScale(tracking.Button)
		self.SetScale(tracking.Button, 1)
		p.btnPoints = {}
		for i = 1, self.GetNumPoints(tracking.Button) do
			p.btnPoints[i] = {self.GetPoint(tracking.Button, i)}
		end
		self.ClearAllPoints(tracking.Button)
		self.SetPoint(tracking.Button, "CENTER")
		self:setHooks(tracking.Button)

		local indicatorFrame = MinimapCluster.IndicatorFrame
		local point, rFrame, rPoint, x, y = self.GetPoint(indicatorFrame)
		if rFrame == tracking then
			p.indicatorFramePoint = {point, rFrame, rPoint, x, y}
			self.ClearAllPoints(indicatorFrame)
			self.SetPoint(indicatorFrame, "TOPRIGHT", MinimapCluster.BorderTop, "BOTTOMLEFT", 0, 0)
		end

		if checkMasqueConditions(tracking.Button, self:getMBtnSettings(tracking)) then
			self:setMButtonRegions(tracking.Button)
			if tracking.Button.__MSQ_Enabled then
				tracking.icon = tracking.Button.__MSQ_Icon
			end
		end

		tinsert(self.minimapButtons, tracking)
		tinsert(self.mixedButtons, tracking)
	end

	-- MAIL FRAME
	local mail = self:getFrameFromPath("MinimapCluster.IndicatorFrame.MailFrame")
	if mail and self:ignoreCheck("MinimapCluster.IndicatorFrame.MailFrame") and not self.btnParams[mail] then
		mail.icon = MiniMapMailIcon
		self:setHooks(mail)
		self:setSecureHooks(mail)
		sexyMapRegionsHide(mail)

		local p = self:setParams(mail, function(p, mail)
			mail.GetParent = p.GetParent
			self.SetScript(mail, "OnShow", p.OnShow)
			mail:GetParent():Layout()
			if mail.__MSQ_Addon then return end
			self.SetSize(mail, p.width, p.height)
			self.ClearAllPoints(mail.icon)
			for i = 1, #p.iconPoints do
				self.SetPoint(mail.icon, unpack(p.iconPoints[i]))
			end
		end)

		p.GetParent = rawget(mail, "GetParent")
		mail.GetParent = function() return MinimapCluster.IndicatorFrame end
		p.OnShow = self.GetScript(mail, "OnShow")
		self.SetScript(mail, "OnShow", function(mail) mail:OnEvent("UPDATE_PENDING_MAIL") end)
		p.name = "MinimapCluster.IndicatorFrame.MailFrame"
		p.width, p.height = mail:GetSize()
		self.SetSize(mail, 20, 20)
		p.iconPoints = {}
		for i = 1, self.GetNumPoints(mail.icon) do
			p.iconPoints[i] = {self.GetPoint(mail.icon, i)}
		end
		self.ClearAllPoints(mail.icon)
		self.SetPoint(mail.icon, "CENTER")

		local btnData = self:getMBtnSettings(mail)
		if btnData[5] == nil then btnData[5] = true end

		if checkMasqueConditions(mail, btnData) then
			self:setMButtonRegions(mail)
		end

		tinsert(self.minimapButtons, mail)
		tinsert(self.mixedButtons, mail)
	end

	-- CRAFTING ORDER FRAME
	local craftingOrder = self:getFrameFromPath("MinimapCluster.IndicatorFrame.CraftingOrderFrame")
	if craftingOrder and self:ignoreCheck("MinimapCluster.IndicatorFrame.CraftingOrderFrame") and not self.btnParams[craftingOrder] then
		craftingOrder.icon = MiniMapCraftingOrderIcon
		self:setHooks(craftingOrder)
		self:setSecureHooks(craftingOrder)
		sexyMapRegionsHide(craftingOrder)

		local p = self:setParams(craftingOrder, function(p, craftingOrder)
			craftingOrder.GetParent = p.GetParent
			craftingOrder:GetParent():Layout()
			if craftingOrder.__MSQ_Addon then return end
			self.SetSize(craftingOrder, p.width, p.height)
			self.ClearAllPoints(craftingOrder.icon)
			for i = 1, #p.iconPoints do
				self.SetPoint(craftingOrder.icon, unpack(p.iconPoints[i]))
			end
		end)

		p.GetParent = rawget(craftingOrder, "GetParent")
		craftingOrder.GetParent = function() return MinimapCluster.IndicatorFrame end
		p.name = "MinimapCluster.IndicatorFrame.CraftingOrderFrame"
		p.width, p.height = craftingOrder:GetSize()
		self.SetSize(craftingOrder, 20, 20)
		p.iconPoints = {}
		for i = 1, self.GetNumPoints(craftingOrder.icon) do
			p.iconPoints[i] = {self.GetPoint(craftingOrder.icon, i)}
		end
		self.ClearAllPoints(craftingOrder.icon)
		self.SetPoint(craftingOrder.icon, "CENTER")

		local btnData = self:getMBtnSettings(craftingOrder)
		if btnData[5] == nil then btnData[5] = true end

		if checkMasqueConditions(craftingOrder, btnData) then
			self:setMButtonRegions(craftingOrder)
		end

		tinsert(self.minimapButtons, craftingOrder)
		tinsert(self.mixedButtons, craftingOrder)
	end

	-- GARRISON BUTTON
	local expBtn = ExpansionLandingPageMinimapButton
	if expBtn and self:ignoreCheck("ExpansionLandingPageMinimapButton") and not self.btnParams[expBtn] then
		self:setHooks(expBtn)
		self:setSecureHooks(expBtn)
		self:setParams(expBtn).autoShowHideDisabled = true

		local btnData = self:getMBtnSettings(expBtn)
		btnData[5] = true

		if MSQ and not self.MSQ_Garrison and not btnData[6] then
			self.MSQ_Garrison = MSQ:Group(addon, GARRISON_FOLLOWERS, "GarrisonLandingPageMinimapButton")
			self.MSQ_Garrison:RegisterCallback(hb.MSQ_UpdateGroupBtns)
			self:setMButtonRegions(expBtn, nil, self.MSQ_Garrison)
		end

		tinsert(self.minimapButtons, expBtn)
		tinsert(self.mixedButtons, expBtn)
	end

	-- ZOOM IN & ZOOM OUT
	for _, pName in ipairs({"ZoomIn", "ZoomOut"}) do
		local zoom = Minimap[pName]
		local name = "Minimap."..pName

		if zoom and self:ignoreCheck(name) and not self.btnParams[zoom] then
			zoom:SetHeight(zoom:GetWidth())
			local normal = zoom:GetNormalTexture()
			local pushed = zoom:GetPushedTexture()
			local highlight = zoom:GetHighlightTexture()
			self:setHooks(zoom)
			self:setSecureHooks(zoom)
			sexyMapRegionsHide(zoom)

			local p = self:setParams(zoom, function(p, zoom)
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

			if checkMasqueConditions(zoom) then
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
	local queue = QueueStatusButton
	if queue and self:ignoreCheck("QueueStatusButton") and not self.btnParams[queue] then
		queue.icon = queue.Eye.texture
		self:setHooks(queue)
		self:setSecureHooks(queue)

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

		if checkMasqueConditions(queue) then
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