if GetLocale() ~= "zhCN" then
	return
end

local _, L = ...

L["author"] = "作者"
L["%s Configuration"] = "%s 配置"
L["Profile"] = "配置"
L["New profile"] = "新建配置"
L["Create"] = "创建"
L["Copy current"] = "复制当前配置"
L["Set as default"] = "设为默认值"
L["A profile with the same name exists."] = "存在同名的配置文件。"
L["Are you sure you want to delete profile %s?"] = "你确定要删除配置文件 %s 吗？"
L["RELOAD_INTERFACE_QUESTION"] = "需要重新载入界面UI启用设置修改. 执行吗?"
L["ADD_IGNORE_MBTN_QUESTION"] = "你确定要将 %s 加入忽略列表吗?"
L["REMOVE_IGNORE_MBTN_QUESTION"] = "确定从忽略中移除 %s 吗?"
L["ADD_CUSTOM_GRAB_BTN_QUESTION"] = "你确定要将 %s 加入抓取列表吗？"
L["REMOVE_CUSTOM_GRAB_BTN_QUESTION"] = "你确定从抓取列表中删除 %s 吗？"
L["Add bar"] = "新建框架"
L["A bar with the same name exists."] = "已存在同名的框架。"
L["Are you sure you want to delete bar %s?"] = "你确定要删除框架 %s 吗？"
L["Bar"] = "框架"
L["Source:"] = "来源："
L["Manually added"] = "手动添加"
L["Move to"] = "移动到"
L["Clip button"] = "裁切按钮"
L["Prevents button elements from going over the edges."] = "防止按钮超出边框。"
L["Add to ignore list"] = "添加到忽略列表"
L["Options of adding buttons"] = "抓取按钮选项"
L["Bar settings"] = "框架设置"
L["Button settings"] = "按钮设置"
L["SETTINGS_DESCRIPTION"] = "当你点击|cff%sl线|r时:\n|cffffd200左键点击|r - 移动条.\n|cffffd200Shift+右键点击|r - 打开设置.\n|cffffd200Alt+右键点击|r - 锁定条位置."
L["Line"] = "边框"
L["Background"] = "背景"
L["Fade out line"] = "透明度 |cff%s 框架边框|r"
L["Opacity"] = "透明度"
L["Line width"] = "边框粗细"
L["Orientation"] = "方向"
L["Auto"] = "自动"
L["Horizontal"] = "水平"
L["Vertical"] = "垂直"
L["Strata of panel"] = "面板层级"
L["Lock the bar's location"] = "锁定框架位置 "
L["Expand to"] = "展开"
L["Right / Bottom"] = "右/下"
L["Left / Top"] = "左/上"
L["Both direction"] = "双向"
L["Add buttons from DataBroker"] = "从DataBroker添加按钮"
L["Grab default buttons on minimap"] = "抓取小地图上的默认按钮"
L["Grab addon buttons on minimap"] = "抓取小地图上的插件按钮"
L["Try to grab after"] = "之后尝试抓取"
L["sec."] = "秒"
L["Grab buttons without a name"] = "抓取无名按钮(|cffff2020不推荐|r)"
L["Add button manually"] = "手动添加按钮"
L["Point to button"] = "按钮提示"
L["Number of buttons"] = "按钮数量"
L["Buttons Size"] = "按钮尺寸"
L["Distance to bar border"] = "距离边框"
L["Distance between buttons"] = "按钮间距"
L["Position of minimap buttons"] = "小地图按钮位置"
L["A new line"] = "新一行"
L["Followed"] = "已跟随"
L["Mixed"] = "混合"
L["Direction of buttons"] = "按钮排列方向"
L["Right to left"] = "从右到左"
L["Left to right"] = "从左到右"
L["Top to bottom"] = "从上往下"
L["Bottom to top"] = "从下往上"
L["Intercept the position of tooltips"] = "拦截提示的位置"
-- L["Top"] = ""
-- L["Top left"] = ""
-- L["Top right"] = ""
-- L["Bottom"] = ""
-- L["Bottom left"] = ""
-- L["Bottom right"] = ""
-- L["Left"] = ""
-- L["Left top"] = ""
-- L["Left bottom"] = ""
-- L["Right"] = ""
-- L["Right top"] = ""
-- L["Right bottom"] = ""
L["Buttons"] = "按钮 "
L["Ignore list"] = "忽略列表"
L["BUTTON_TOOLTIP"] = "|cffffd200左键|r点击启用或禁用按钮，长按拖动位置。\n|cffffd200右键|r点击打开菜单。"
L["IGNORE_DESCRIPTION"] = "您可以指定名称的一部分.\n\n例如, |cffffd200HidingBar|r将会忽略:\n|cffffd200HidingBar1|r\n|cffffd200HidingBar2|r\n|cffffd200HidingBar3|r\n..."
L["DataBroker Buttons"] = "DataBroker按钮"
L["Minimap Buttons"] = "小地图按钮"
L["Manually Grabbed Buttons"] = "手动抓取按钮"
L["Own Minimap Button"] = "系统小地图按钮"
L["Show on"] = "显示在"
L["Hover"] = "悬浮"
L["Click"] = "点击"
L["Hover or Click"] = "悬浮或点击"
L["Allways"] = "一直"
L["Delay to show"] = "延迟显示"
L["Delay to hide"] = "延迟隐藏"
L["Bar position"] = "条位置"
L["Bar attached to the side"] = "框架侧边吸附"
L["Bar moves freely"] = "框架自由移动"
L["Bar like a minimap button"] = "框架类似小地图按钮"
L["Hiding to left"] = "隐藏到左侧"
L["Hiding to right"] = "隐藏到右侧"
L["Hiding to up"] = "隐藏到上方"
L["Hiding to down"] = "隐藏到下方"
L["Show to left"] = "显示在左侧"
L["Show to right"] = "显示在右侧"
L["Show to up"] = "显示在上方"
L["Show to down"] = "显示在下方"
L["Button Size"] = "按钮尺寸"
L["The button can be grabbed"] = "按钮可自行拖动"
L["If a suitable bar exists then the button will be grabbed"] = "存在合适的框架时，按钮位置可拖动。"
L["About"] = "关于"
L["Help with translation of %s. Thanks."] = "参与帮助翻译 %s. 谢谢."
L["Localization Translators:"] = "本地化翻译者:"