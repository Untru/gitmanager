// @strict-types


#Область ПрограммныйИнтерфейс
//TODO 1) Вынести в модуль менеджера 2) А это не костыль? 
Процедура ОбновитьЗадачиСПустымиПолями() Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Задачи.НомерЗадачи КАК НомерЗадачи,
		|	Задачи.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Задачи КАК Задачи
		|ГДЕ
		|	Задачи.ОсновнаяЗадача = ЗНАЧЕНИЕ(Справочник.Задачи.ПустаяСсылка)
		|	И Задачи.НомерЗадачиБазовой <> ""0""
		|	И Задачи.НомерЗадачиБазовой <> """"
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	Задачи.НомерЗадачи,
		|	Задачи.Ссылка
		|ИЗ
		|	Справочник.Задачи КАК Задачи
		|ГДЕ
		|	Задачи.Постановщик = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	Задачи.НомерЗадачи,
		|	Задачи.Ссылка
		|ИЗ
		|	Справочник.Задачи КАК Задачи
		|ГДЕ
		|	Задачи.Ответственный = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	НомераЗадачи = РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("НомерЗадачи");
	Для Каждого Номер Из НомераЗадачи Цикл
		РегистрыСведений.ЗадачиКЗагрузке.ДобавитьЗадачу(Номер);
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбновитьДанныеЗадач() Экспорт
	
	ТаблицаЗадач = Справочники.Задачи.НеЗакрытыеЗадачи();
	ТипыТаскТрекеров = ТаблицаЗадач.Скопировать();
	ТипыТаскТрекеров.Свернуть("ТипТаскТрекера");
	
	Для Каждого ТипТаскТрекера Из ТипыТаскТрекеров Цикл
	
		ПараметрыОтбора = Новый Структура;
		ПараметрыОтбора.Вставить("ТипТаскТрекера", ТипТаскТрекера);
		
		ТаблицаЗадачПоТаскТрекеру = ТаблицаЗадач.Скопировать(ПараметрыОтбора);
		
		МенеджерТаскТрекера = Перечисления.ТаскТрекеры.МенеджерТаскТрекера(ТипТаскТрекера);
		МенеджерТаскТрекера.ОбновитьДанныеЗадачПоТаблице(ТаблицаЗадачПоТаскТрекеру);
			
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
