// @strict-types


#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбновитьСписокОбработок(Команда)
	
	Если Не ЗначениеЗаполнено(База) Тогда
		ВызватьИсключение НСтр("ru='Обновление возможно только по выбранной базе'", "ru");	
	КонецЕсли;
	ОбновитьСписокОбработокНаСервере();
	Элементы.Список.Обновить();

КонецПроцедуры

&НаКлиенте
Процедура СобратьИзДевелопа(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	Обработка = Элементы.Список.ТекущиеДанные.Ссылка;
	СобратьОбработкуНаСервере("develop", Обработка);

КонецПроцедуры

&НаКлиенте
Процедура СобратьИзМейна(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	Обработка = Элементы.Список.ТекущиеДанные.Ссылка;
	СобратьОбработкуНаСервере("main", Обработка);

КонецПроцедуры

&НаКлиенте
Процедура СобратьОбработку(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	Обработка = Элементы.Список.ТекущиеДанные.Ссылка;
	Задача = Элементы.СписокЗадач.ТекущиеДанные.Задача;
	
	СобратьОбработкуНаСервере(НомерЗадачи(Задача), Обработка);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОбновитьСписокОбработокНаСервере()
	
	НастройкиБазы = РаботаСGitAPIПовтИсп.НастройкиБазы(База);
	Справочники.ОбъектыРазработки.СоздатьОбработкиПоРепозиторию(НастройкиБазы);
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	
	ПодключитьОбработчикОжидания("ВывестиСписокЗадачПоОбработке", 0.2, Истина);	
	
КонецПроцедуры

&НаКлиенте
Процедура ВывестиСписокЗадачПоОбработке() Экспорт
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекущиеДанные <> Неопределено Тогда
		ВывестиСписокЗадачПоОбработкеНаСервере(ТекущиеДанные.Ссылка);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ВывестиСписокЗадачПоОбработкеНаСервере(Обработка) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОбъектыРазработкиИсторияВерсий.Ссылка КАК Ссылка,
		|	ОбъектыРазработкиИсторияВерсий.Задача КАК Задача,
		|	МАКСИМУМ(ОбъектыРазработкиИсторияВерсий.ДатаВерсии) КАК ДатаВерсии,
		|	МАКСИМУМ(ОбъектыРазработкиИсторияВерсий.НомерВерсии) КАК НомерВерсии,
		|	ОбъектыРазработкиИсторияВерсий.Ответственный КАК Ответственный
		|ИЗ
		|	Справочник.ОбъектыРазработки.ИсторияВерсий КАК ОбъектыРазработкиИсторияВерсий
		|ГДЕ
		|	ОбъектыРазработкиИсторияВерсий.Ссылка = &Обработка
		|
		|СГРУППИРОВАТЬ ПО
		|	ОбъектыРазработкиИсторияВерсий.Ссылка,
		|	ОбъектыРазработкиИсторияВерсий.Задача,
		|	ОбъектыРазработкиИсторияВерсий.Ответственный
		|
		|УПОРЯДОЧИТЬ ПО
		|	ДатаВерсии УБЫВ";
	
	Запрос.УстановитьПараметр("Обработка", Обработка);
	
	СписокЗадач.Загрузить(Запрос.Выполнить().Выгрузить());

КонецПроцедуры

&НаСервере
Процедура СобратьОбработкуНаСервере(ИмяВетки, Обработка)

	НастройкиПроекта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(База.Владелец, "ПапкаАктуальныхОбработок, Репозиторий");
	РаботаСОбъектами.СкомпилироватьОбработкуПоВетке(ИмяВетки, Обработка, НастройкиПроекта, База);
	
КонецПроцедуры

&НаСервере
Функция НомерЗадачи(Задача)
	Возврат Справочники.Задачи.ВеткаЗадачи(Задача); 
КонецФункции

&НаКлиенте
Процедура ОткрытьПапку(Команда)
	
	НастройкиБазы = РаботаСGitAPIПовтИсп.НастройкиБазы(База);
	КаталогБилдаРепозитория = РаботаСGit.КаталогБилдаРепозитория(НастройкиБазы.КаталогБазыШара);
	Если КаталогБилдаРепозитория = "" Тогда
		ПоказатьПредупреждение(, "Не найден каталог обработок");
		Возврат;
	КонецЕсли;
	ЗапуститьПриложение(КаталогБилдаРепозитория);

КонецПроцедуры

&НаКлиенте
Процедура ПерейтиВVSCode(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	Обработка = Элементы.Список.ТекущиеДанные.Ссылка;
	Данные = ПутьКОбработке(Обработка);
	КомандаСистемы(СтрШаблон("code %1 %2", Данные.КаталогБазы, Данные.ПутьКОбработке));
	
КонецПроцедуры

Функция ПутьКОбработке(Обработка)

	Результат = Новый Структура;
	НастройкиБазы = Справочники.Базы.НастройкиБазы(База);
	ПутьКОбработке = СтрШаблон("%1\src\epf\%2\Ext\ObjectModule.bsl", НастройкиБазы.КаталогБазы, Обработка.Наименование); //
	Результат.Вставить("ПутьКОбработке", ПутьКОбработке);
	Результат.Вставить("КаталогБазы", НастройкиБазы.КаталогБазы);
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти
