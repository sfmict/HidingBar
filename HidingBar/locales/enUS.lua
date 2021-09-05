local _, L = ...

L["author"] = "Author"
L["%s Configuration"] = "%s Configuration"
L["Profile"] = "Profile"
L["New profile"] = "New profile"
L["Create"] = "Create"
L["Copy current"] = "Copy current"
L["Set as default"] = "Set as default"
L["A profile with the same name exists."] = "A profile with the same name exists."
L["Are you sure you want to delete profile %s?"] = "Are you sure you want to delete profile %s?"
L["RELOAD_INTERFACE_QUESTION"] = "You need to reload the interface to apply the changes. Do it now?"
L["ADD_IGNORE_MBTN_QUESTION"] = "Are you sure you want add to ignore list %s?"
L["REMOVE_IGNORE_MBTN_QUESTION"] = "Are you sure you want to unignore %s?"
L["Add bar"] = "Add bar"
L["A bar with the same name exists."] = "A bar with the same name exists."
L["Are you sure you want to delete bar %s?"] = "Are you sure you want to delete bar %s?"
L["Bar"] = "Bar"
L["Source:"] = "Source:"
L["Move to"] = "Move to"
L["Clip button"] = "Clip button"
L["Prevents button elements from going over the edges."] = "Prevents button elements from going over the edges."
L["Add to ignore list"] = "Add to ignore list"
L["Grab options"] = "Grab options"
L["Bar settings"] = "Bar settings"
L["Button settings"] = "Button settings"
L["SETTINGS_DESCRIPTION"] = "When you click on the |cff%sline|r:\n•|cffffd200LMB|r - drag bar.\n•|cffffd200RMB + Shift|r - open the settings.\n•|cffffd200RMB + Alt|r - lock the bar's location."
L["Line"] = "Line"
L["Background"] = "Background"
L["Fade out line"] = "Fade out |cff%sline|r"
L["Opacity"] = "Opacity"
L["Line width"] = "|cff%sLine|r width"
L["Orientation"] = "Orientation"
L["Auto"] = "Auto"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertical"
L["Strata of panel"] = "Strata of panel"
L["Lock the bar's location"] = "Lock the bar's location"
L["Expand to"] = "Expand to"
L["Right / Bottom"] = "Right / Bottom"
L["Left / Top"] = "Left / Top"
L["Both direction"] = "Both direction"
L["Grab addon buttons on minimap"] = "Grab addon buttons on minimap"
L["Try to grab after"] = "Try to grab after"
L["sec."] = "sec."
L["Grab buttons without a name"] = "Grab buttons without a name (|cffff2020not recommended|r)"
L["Number of buttons"] = "Number of buttons in a row / column"
L["Buttons Size"] = "Buttons Size"
L["Position of minimap buttons"] = "Position of minimap buttons"
L["A new line"] = "A new line"
L["Followed"] = "Followed"
L["Mixed"] = "Mixed"
L["Buttons"] = "Buttons"
L["Ignore list"] = "Ignore list"
L["BUTTON_TOOLTIP"] = "|cffffd200LMB|r to enable / disable buttons or drag to reposition.\n|cffffd200RMB|r to open the context menu."
L["IGNORE_DESCRIPTION"] = "You can specify a part of the name.\n\nFor example |cffffd200HidingBar|r will ignore:\n|cffffd200HidingBar1|r\n|cffffd200HidingBar2|r\n|cffffd200HidingBar3|r\n..."
L["DataBroker Buttons"] = "DataBroker Buttons"
L["Minimap Buttons"] = "Minimap Buttons"
L["Own Minimap Button"] = "Own Minimap Button"
L["Show on"] = "Show on"
L["Hover"] = "Hover"
L["Click"] = "Click"
L["Hover or Click"] = "Hover or Click"
L["Allways"] = "Always"
L["Delay to show"] = "Delay to show"
L["Delay to hide"] = "Delay to hide"
L["Bar position"] = "Bar position"
L["Bar attached to the side"] = "Bar attached to the side"
L["Bar moves freely"] = "Bar moves freely"
L["Bar like a minimap button"] = "Bar like a minimap button"
L["Hiding to left"] = "Hiding to left"
L["Hiding to right"] = "Hiding to right"
L["Hiding to up"] = "Hiding to up"
L["Hiding to down"] = "Hiding to down"
L["Show to left"] = "Show to left"
L["Show to right"] = "Show to right"
L["Show to up"] = "Show to up"
L["Show to down"] = "Show to down"
L["Button Size"] = "Button Size"
L["About"] = "About"
L["Help with translation of %s. Thanks."] = "Help with translation of %s. Thanks."
L["Localization Translators:"] = "Localization Translators:"

setmetatable(L, {__index = function(self, key)
	self[key] = key or ""
	return key
end})