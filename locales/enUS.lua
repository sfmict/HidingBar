local _, L = ...

L["author"] = "Author"
L["%s Configuration"] = "%s Configuration"
L["RELOAD_INTERFACE_QUESTION"] = "To change this option need to reload interface. Do it now?"
L["ADD_IGNORE_MBTN_QUESTION"] = "Are you sure you want add to ignore list %s?"
L["REMOVE_IGNORE_MBTN_QUESTION"] = "Are you sure you want to delete %s?"
L["SETTINGS_DESCRIPTION"] = "When you click on the |cffffd200yellow|r line:\n•|cffffd200LMB|r - drag bar.\n•|cffffd200RMB + Shift|r - open the settings.\n•|cffffd200RMB + Alt|r - lock the bar's location."
L["Fade out yellow line"] = "Fade out yellow line"
L["Opacity"] = "Opacity"
L["Orientation"] = "Orientation"
L["Auto"] = "Auto"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertical"
L["Lock the bar's location"] = "Lock the bar's location"
L["Grab addon buttons on minimap"] = "Grab addon buttons on minimap"
L["Grab buttons without a name"] = "Grab buttons without a name (|cffff2020not recommended|r)"
L["Number of buttons"] = "Number of buttons in a row / column"
L["Button Size"] = "Button Size"
L["Buttons"] = "Buttons"
L["Ignore list"] = "Ignore list"
L["BUTTON_PANEL_DESCRIPTION"] = "•|cffffd200LMB|r to enable / disable buttons or drag to reposition.\n•|cffffd200RMB|r on minimap buttons to add them to ignore list."
L["IGNORE_DESCRIPTION"] = "You can specify a part of the name.\n\nFor example |cffffd200HidingBar|r will ignore:\n|cffffd200HidingBar1|r\n|cffffd200HidingBar2|r\n|cffffd200HidingBar3|r\n..."

setmetatable(L, {__index = function(self, key)
	self[key] = key or ""
	return key
end})