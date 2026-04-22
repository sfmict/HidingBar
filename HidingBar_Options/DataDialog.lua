local L = HidingBarConfigAddon.L
local dataDialog = CreateFrame("FRAME", "HidingBarDataDialog", UIParent, "DefaultPanelTemplate")
dataDialog:Hide()


dataDialog:SetScript("OnShow", function(self)
	self:SetScript("OnKeyDown", function(self, key)
		if key == GetBindingKey("TOGGLEGAMEMENU") then
			self:Hide()
			self:SetPropagateKeyboardInput(false)
		else
			self:SetPropagateKeyboardInput(true)
		end
	end)
	self:SetScript("OnEvent", function(self, event)
		self:EnableKeyboard(event == "PLAYER_REGEN_ENABLED")
	end)
	self:SetScript("OnHide", function(self)
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end)
	self:SetScript("OnShow", function(self)
		self:EnableKeyboard(not InCombatLockdown())
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end)
	self:GetScript("OnShow")(self)

	self:SetSize(300, 300)
	self:SetPoint("CENTER")
	self:SetFrameStrata("DIALOG")
	self:SetFrameLevel(2100)
	self:SetClampedToScreen(true)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)

	-- NAME
	self.nameString = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	self.nameString:SetPoint("TOPLEFT", 10, -30)
	self.nameString:SetText(NAME)

	self.nameEdit = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
	self.nameEdit:SetHeight(22)
	self.nameEdit:SetPoint("LEFT", self.nameString, "RIGHT", 5, 0)
	self.nameEdit:SetPoint("RIGHT", -6, 0)
	self.nameEdit:SetAutoFocus(false)
	self.nameEdit:SetTextInsets(0, 5, 0, 0)

	-- EDIT
	self.codeBtn = CreateFrame("BUTTON", nil, self, "BackdropTemplate")
	self.codeBtn:SetPoint("BOTTOMRIGHT", -4, 30)
	self.codeBtn:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	self.codeBtn:SetBackdropColor(.05, .05, .05)
	self.codeBtn:SetBackdropBorderColor(FRIENDS_GRAY_COLOR:GetRGB())
	self.codeBtn:SetScript("OnClick", function(btn) btn:GetParent().editBox:SetFocus() end)

	self.scrollBar = CreateFrame("EventFrame", nil, self.codeBtn, "WowTrimScrollBar")
	self.scrollBar:SetPoint("TOPRIGHT", self.codeBtn, -4, -5)
	self.scrollBar:SetPoint("BOTTOMRIGHT", self.codeBtn, -4, 4)

	self.editFrame = CreateFrame("FRAME", nil, self.codeBtn, "ScrollingEditBoxTemplate")
	self.editBox = self.editFrame:GetEditBox()

	self.editBox:HookScript("OnTextChanged", function(editBox)
		if self.info.type ~= "import" then return end
		local data = self:getDataFromString(editBox:GetText())
		if type(data) == "table" and self.info.valid(data) then
			self.nameEdit:SetFocus()
			self.nameEdit:HighlightText()
			self.nameEdit:SetCursorPosition(0)
			self.data = data
			self.btn1:Enable()
		else
			self.data = nil
			self.btn1:Disable()
		end
	end)

	self.editBox:HookScript("OnMouseUp", function(editBox)
		editBox:HighlightText()
	end)

	local anchorsToFrame = {
		CreateAnchor("TOPLEFT", self.codeBtn, "TOPLEFT", 8, -8),
		CreateAnchor("BOTTOMRIGHT", self.codeBtn, "BOTTOMRIGHT", -8, 8),
	}
	local anchorsToBar = {
		anchorsToFrame[1],
		CreateAnchor("BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", -3, 4),
	}
	local scrollBox = self.editFrame:GetScrollBox()
	ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, self.scrollBar)
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, self.scrollBar, anchorsToBar, anchorsToFrame)

	-- CONTROL BTNS
	self.btn1 = CreateFrame("BUTTON", nil, self, "UIPanelButtonTemplate")
	self.btn1:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -5, 5)
	self.btn1:SetSize(120, 22)
	self.btn1:SetText(SAVE)
	self.btn1:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		local name = self.nameEdit:GetText():trim()
		if self.nameEdit:IsShown() and name == "" then
			self.nameEdit:SetFocus()
			self.nameEdit:HighlightText()
			return
		end
		if self.info.save and not self.info.save(self.data, name) then
			return
		end
		self:Hide()
	end)

	self.btn2 = CreateFrame("BUTTON", nil, self, "UIPanelButtonTemplate")
	self.btn2:SetPoint("BOTTOM", 0, 5)
	self.btn2:SetSize(120, 22)
	self.btn2:SetScript("OnClick", function()
		self:Hide()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)
end)


function dataDialog:open(info)
	self:Show()
	self.info = info
	self.btn2:ClearAllPoints()

	if info.type == "import" then
		self:SetTitle(L["Import"])
		self.nameString:Show()

		self.nameEdit:Show()
		self.nameEdit:SetText(info.defName)

		self.codeBtn:SetPoint("TOPLEFT", self.nameString, "BOTTOMLEFT", -3, -4)
		self.editBox:SetText("")
		self.editBox:SetFocus()

		self.btn1:Disable()
		self.btn1:Show()

		self.btn2:SetText(CANCEL)
		self.btn2:SetPoint("BOTTOMLEFT", self, "BOTTOM", 5, 5)
	else
		self:SetTitle(L["Export"])
		self.nameString:Hide()
		self.nameEdit:Hide()

		self.codeBtn:SetPoint("TOPLEFT", 7, -24)
		self.editBox:SetText(self:getStringFromData(info.data))
		self.editBox:SetFocus()
		self.editBox:HighlightText()
		self.editBox:SetCursorPosition(0)

		self.btn1:Hide()
		self.btn2:SetText(OKAY)
		self.btn2:SetPoint("BOTTOM", 0, 5)
	end
end


function dataDialog:getStringFromData(data)
	local serialized = C_EncodingUtil.SerializeCBOR(data)
	local compressed = C_EncodingUtil.CompressString(serialized, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
	return C_EncodingUtil.EncodeBase64(compressed, Enum.Base64Variant.StandardUrlSafe)
end


function dataDialog:getDataFromString(str)
	local decoded, success, decompressed, data
	decoded = C_EncodingUtil.DecodeBase64(str, Enum.Base64Variant.StandardUrlSafe)
	success, decompressed = pcall(C_EncodingUtil.DecompressString, decoded, Enum.CompressionMethod.Deflate)
	if not success then return end
	success, data = pcall(C_EncodingUtil.DeserializeCBOR, decompressed)
	if success then return data end
end
