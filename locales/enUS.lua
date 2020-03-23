local _, L = ...

L["author"] = "Author"
L["%s Configuration"] = "%s Configuration"
L["RELOAD_INTERFACE_QUESTION"] = "To change this option need to reload interface. Do it now?"
L["SETTINGS_DESCRIPTION"] = "When you click on the |cffffd200yellow|r line:\n•|cffffd200LMB|r - drag bar.\n•|cffffd200RMB + Shift|r - open the settings.\n•|cffffd200RMB + Alt|r - lock the bar's location."
L["Fade out yellow line"] = "Fade out yellow line"
L["Opacity"] = "Opacity"
L["Orientation"] = "Orientation"
L["Auto"] = "Auto"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertical"
L["Lock the bar's location"] = "Lock the bar's location"
L["Grab addon buttons on minimap"] = "Grab addon buttons on minimap"
L["Number of buttons"] = "Number of buttons in a row / column"
L["BUTTON_PANEL_DESCRIPTION"] = "Click to enable / disable buttons or drag to reposition."

setmetatable(L, {__index = function(self, key)
	self[key] = key or ""
	return key
end})