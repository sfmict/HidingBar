if GetLocale() ~= "ruRU" then
	return
end

local _, L = ...

L["author"] = "Автор"
L["%s Configuration"] = "Конфигурация %s"
L["Profile"] = "Профиль"
L["New profile"] = "Новый профиль"
L["Create"] = "Создать"
L["Copy current"] = "Копировать текущий"
L["Set as default"] = "Установить по умолчанию"
L["A profile with the same name exists."] = "Профиль с таким именем уже существует."
L["Are you sure you want to delete profile %s?"] = "Вы уверены, что хотите удалить профиль %s"
L["RELOAD_INTERFACE_QUESTION"] = "Для применения изменений необходимо перезагрузить интерфейс. Сделать это сейчас?"
L["ADD_IGNORE_MBTN_QUESTION"] = "Вы уверены, что хотите добавить в список игнорируемых %s?"
L["REMOVE_IGNORE_MBTN_QUESTION"] = "Вы уверены, что хотите удалить %s из списка игнорируемых?"
L["ADD_CUSTOM_GRAB_BTN_QUESTION"] = "Вы уверены, что хотите добавить в список захвата %s?"
L["REMOVE_CUSTOM_GRAB_BTN_QUESTION"] = "Вы уверены, что хотите удалить %s из списка захвата?"
L["Add bar"] = "Добавить панель"
L["A bar with the same name exists."] = "Панель с таким именем уже существует."
L["Are you sure you want to delete bar %s?"] = "Вы уверены, что хотите удалить панель %s?"
L["Bar"] = "Панель"
L["Source:"] = "Источник:"
L["Manually added"] = "Добавленно вручную"
L["Move to"] = "Переместить на"
L["Clip button"] = "Ограничить кнопку"
L["Prevents button elements from going over the edges."] = "Предотвращает выход элементов кнопки за края."
L["Add to ignore list"] = "Добавить в список игнорируемых"
L["Options of adding buttons"] = "Опции добавления кнопок"
L["Bar settings"] = "Настройки панели"
L["Button settings"] = "Настройки кнопок"
L["SETTINGS_DESCRIPTION"] = "Когда Вы кликаете по |cff%sлинии|r:\n•|cffffd200ЛКМ|r - перемещение панели.\n•|cffffd200ПКМ + Shift|r - открыть настройки.\n•|cffffd200ПКМ + Alt|r - заблокировать позицию панели."
L["Line"] = "Линия"
L["Background"] = "Фон"
L["Fade out line"] = "Исчезновение |cff%sлинии|r"
L["Opacity"] = "Прозрачность"
L["Line width"] = "Ширина |cff%sлинии|r"
L["Orientation"] = "Ориентация"
L["Auto"] = "Авто"
L["Horizontal"] = "Горизонтальная"
L["Vertical"] = "Вертикальная"
L["Strata of panel"] = "Слой панели"
L["Lock the bar's location"] = "Заблокировать позицию панели"
L["Expand to"] = "Расширять в"
L["Right / Bottom"] = "Право / Низ"
L["Left / Top"] = "Лево / Верх"
L["Both direction"] = "Оба направления"
L["Add buttons from DataBroker"] = "Добавлять кнопки из DataBroker"
L["Grab default buttons on minimap"] = "Захватить стандартные кнопки на миникарте"
L["Grab addon buttons on minimap"] = "Захватить кнопки аддонов на миникарте"
L["Try to grab after"] = "Попробовать захватить после"
L["sec."] = "сек."
L["Grab buttons without a name"] = "Захватить кнопки без имени (|cffff2020не рекомендуется|r)"
L["Add button manually"] = "Добавить кнопку вручную"
L["Point to button"] = "Указать на кнопку"
L["Number of buttons"] = "Количество кнопок в строке / столбце"
L["Buttons Size"] = "Размер кнопок"
L["Distance to bar border"] = "Дистанция до края панели"
L["Distance between buttons"] = "Дистанция между кнопками"
L["Position of minimap buttons"] = "Позиция кнопок миникарты"
L["A new line"] = "С новой строки"
L["Followed"] = "Следом"
L["Mixed"] = "Вперемешку"
L["Direction of buttons"] = "Направление кнопок"
L["Right to left"] = "Справа налево"
L["Left to right"] = "Слева направо"
L["Top to bottom"] = "Сверху вниз"
L["Bottom to top"] = "Снизу вверх"
L["Intercept the position of tooltips"] = "Перехватывать позицию всплывающих подсказок"
L["Buttons"] = "Кнопки"
L["Ignore list"] = "Список игнорируемых"
L["BUTTON_TOOLTIP"] = "|cffffd200ЛКМ|r, чтобы включить / отлючить кнопку или перетащить, чтобы переместить.\n|cffffd200ПКМ|r, чтобы открыть контекстное меню."
L["IGNORE_DESCRIPTION"] = "Вы можете указать часть имени.\n\nК примеру |cffffd200HidingBar|r будет игнорировать:\n|cffffd200HidingBar1|r\n|cffffd200HidingBar2|r\n|cffffd200HidingBar3|r\n..."
L["DataBroker Buttons"] = "Кнопки DataBroker"
L["Minimap Buttons"] = "Кнопки миникарты"
L["Manually Grabbed Buttons"] = "Кнопки захваченные вручную"
L["Own Minimap Button"] = "Собственная кнопка миникарты"
L["Show on"] = "Показать при"
L["Hover"] = "Наведении"
L["Click"] = "Клике"
L["Hover or Click"] = "Наведении или клике"
L["Allways"] = "Всегда"
L["Delay to show"] = "Задержка до показа"
L["Delay to hide"] = "Задержка до сокрытия"
L["Bar position"] = "Позиция панели"
L["Bar attached to the side"] = "Панель прикреплена к стороне"
L["Bar moves freely"] = "Панель перемещается свободно"
L["Bar like a minimap button"] = "Панель как кнопка миникарты"
L["Hiding to left"] = "Скрывается влево"
L["Hiding to right"] = "Скрывается вправо"
L["Hiding to up"] = "Скрывается вверх"
L["Hiding to down"] = "Скрывается вниз"
L["Show to left"] = "Показать слева"
L["Show to right"] = "Показать справа"
L["Show to up"] = "Показать сверху"
L["Show to down"] = "Показать снизу"
L["Button Size"] = "Размер кнопки"
L["The button can be grabbed"] = "Кнопка может быть захвачена"
L["If a suitable bar exists then the button will be grabbed"] = "Если существует подходящая панель, то кнопка будет захвачена"
L["About"] = "Об аддоне"
L["Help with translation of %s. Thanks."] = "Помогите с переводом %s. Спасибо."
L["Localization Translators:"] = "Переводчики локализаций:"