if GetLocale() ~= "ruRU" then
	return
end

local _, L = ...

L["author"] = "Автор"
L["%s Configuration"] = "Конфигурация %s"
L["RELOAD_INTERFACE_QUESTION"] = "Для изменения этой опции необходимо перезагрузить интерфейс. Сделать это сейчас?"
L["ADD_IGNORE_MBTN_QUESTION"] = "Вы уверены, что хотите добавить в список игнорируемых %s?"
L["REMOVE_IGNORE_MBTN_QUESTION"] = "Вы уверены, что хотите удалить %s?"
L["SETTINGS_DESCRIPTION"] = "Когда вы кликаете по |cffffd200желтой|r линии:\n•|cffffd200ЛКМ|r - перемещение панели.\n•|cffffd200ПКМ + Shift|r - открыть настройки.\n•|cffffd200ПКМ + Alt|r - заблокировать позицию панели."
L["Fade out yellow line"] = "Исчезновение желтой линии"
L["Opacity"] = "Прозрачность"
L["Orientation"] = "Ориентация"
L["Auto"] = "Авто"
L["Horizontal"] = "Горизонтальная"
L["Vertical"] = "Вертикальная"
L["Lock the bar's location"] = "Заблокировать позицию панели"
L["Grab addon buttons on minimap"] = "Захватить кнопки аддонов на миникарте"
L["Grab buttons without a name"] = "Захватить кнопки без имени (|cffff2020не рекомендуется|r)"
L["Number of buttons"] = "Количество кнопок в строке / столбце"
L["Button Size"] = "Размер кнопок"
L["Buttons"] = "Кнопки"
L["Ignore list"] = "Список игнорируемых"
L["BUTTON_PANEL_DESCRIPTION"] = "•|cffffd200ЛКМ|r - чтобы включить / отключить кнопки или перетащить - чтобы изменить положение.\n•|cffffd200ПКМ|r - чтобы добавить кнопки миникарты в список игнорируемых."
L["IGNORE_DESCRIPTION"] = "Вы можете указать часть имени.\n\nК примеру |cffffd200HidingBar|r будет игнорировать:\n|cffffd200HidingBar1|r\n|cffffd200HidingBar2|r\n|cffffd200HidingBar3|r\n..."