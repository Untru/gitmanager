// @strict-types

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("Структура") Тогда
		
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеЗаполнения);
		ОбъектыРазработки.Загрузить(ДанныеЗаполнения.ОбъектыРазработки);
		Для Каждого Строка Из ОбъектыРазработки Цикл
			Строка.ВерсияОбъектаРазработки = Формат(Дата, "ДФ=yyyyMMdd");
		КонецЦикла;
		
		Для Каждого Элемент Из ДанныеЗаполнения.ОбъектыРазработки Цикл
			
			ИнформацияОВерсии = ОбщегоНазначения.JSONВЗначение(Элемент.ИнформацияОВерсии);
			Для Каждого Коммит Из ИнформацияОВерсии Цикл
				НоваяСтрока = Версии.Добавить();
				НоваяСтрока.ИдентификаторКоммита = Коммит.Ключ; 
				НоваяСтрока.ОбъектРазработки = Элемент.ОбъектРазработки; 
				НоваяСтрока.Название = Элемент.Название; 
				НоваяСтрока.ДатаИзменения = ПрочитатьДатуJSON(Коммит.Значение["ДатаКоммита"], ФорматДатыJSON.ISO); 
				НоваяСтрока.ОписаниеИзменения = Коммит.Значение["ЗаголовокКоммита"]; 
				НоваяСтрока.Автор = Справочники.НастройкиПользователей.ПользовательПоЭлектроннойПочте(
					Коммит.Значение["Автор"]
				);
				НомерЗадачи = Лев(НоваяСтрока.ОписаниеИзменения, 6);
				Если Не СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(НомерЗадачи) Тогда
					ГруппаРезультатаПоискаПоРегулярномуВыражению = СтрНайтиПоРегулярномуВыражению(
						НоваяСтрока.ОписаниеИзменения, "\d+_(\d+)").ПолучитьГруппы();
					Если ГруппаРезультатаПоискаПоРегулярномуВыражению.Количество() Тогда
						НомерЗадачи = ГруппаРезультатаПоискаПоРегулярномуВыражению[0].Значение;
					КонецЕсли;
				КонецЕсли;
				Попытка
					НоваяСтрока.Задача = Справочники.Задачи.НоваяЗадача(НомерЗадачи);
				Исключение
					ЗаписьЖурналаРегистрации("Релиз.СозданиеЗадачи", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());
				КонецПопытки;
				
			КонецЦикла;
		КонецЦикла;
		
	КонецЕсли;
	
	ТаблицаЗадач = Версии.Выгрузить();
	ТаблицаЗадач.Свернуть("Задача");
	ЗадачиРелиза.Загрузить(ТаблицаЗадач);
	Версии.Сортировать("ДатаИзменения Убыв"); 
	НайденнаяСтрока = ЗадачиРелиза.Найти(Справочники.Задачи.ПустаяСсылка(), "Задача");
	
	Если НайденнаяСтрока <> Неопределено Тогда
		ЗадачиРелиза.Удалить(НайденнаяСтрока);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.Релизы.Записывать = Истина;
	Для Каждого ТекСтрокаОбъектыРазработки Из ОбъектыРазработки Цикл
		Движение = Движения.Релизы.Добавить();
		Движение.Период = Дата;
		Движение.Проект = Проект;
		Движение.ОбъектРазработки = ТекСтрокаОбъектыРазработки.ОбъектРазработки;
		Движение.ВерсияОбъектаРазработки = ТекСтрокаОбъектыРазработки.ВерсияОбъектаРазработки;
	КонецЦикла;
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ЗадачиРелиза");
	ЭлементБлокировки.УстановитьЗначение("Релиз", Ссылка);
	Блокировка.Заблокировать(); 
	
	ЗадачиПоКоммитам = ЗадачиРелиза.Выгрузить();
	ТаблицаСопоставленныхЗадач = СопоставитьЗадачи();
	Для Каждого Элемент Из ТаблицаСопоставленныхЗадач Цикл
		РегистрыСведений.ЗадачиРелиза.ДобавитьЗаписиПоЗадачамРелиза(Ссылка, Элемент.Задача, 
			Элемент.НетЗадачиВГит, Элемент.НетЗадачиВБитрикс);
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#Область ПрограммныйИнтерфейс

Процедура ЗаполнитьОбъектыРазработкиВТабличнойЧасти() Экспорт

	ОбъектыРазработкиПоследнихРелизов = РегистрыСведений.Релизы.ОбъектыРазработкиПоследнихРелизов(Проект);
	ВсеОбъектыРазработки = Справочники.ОбъектыРазработки.ДанныеПоПроекту(Проект);
	ИзмененныеОбъектыРазработки = ИзмененныеОбъектыРазработки(ОбъектыРазработкиПоследнихРелизов, ВсеОбъектыРазработки);
	
	ОбъектыРазработки.Загрузить(ИзмененныеОбъектыРазработки);
	
КонецПроцедуры

Процедура СоздатьНедостающиеОбъекты() Экспорт
	
	ПутьКПапке = Справочники.Проекты.ПутьКПапкеСборкиОбработок(Проект);

	Отбор = Новый Структура;
	Отбор.Вставить("ОбъектРазработки", Справочники.ОбъектыРазработки.ПустаяСсылка());
	СписокОбработок = ОбъектыРазработки.Выгрузить(Отбор);
	
	Для Каждого Элемент Из СписокОбработок Цикл
		
		Файлы = НайтиФайлы(ПутьКПапке, СтрШаблон("%1.*", Элемент.Название));
		Если Файлы.Количество() Тогда
			ОбработкаСсылка = Справочники.ОбъектыРазработки.НайтиПоНаименованию(Элемент.Название);
			Если ОбработкаСсылка.Пустая() Тогда
				
				НовыйОбъект = Справочники.ОбъектыРазработки.СоздатьЭлемент();
				НовыйОбъект.Заполнить(Неопределено);
				НовыйОбъект.Владелец = Проект;
				НовыйОбъект.ТипОбъектаРазработки = РаботаСОбъектами.ТипОбъектаРазработкиПоФайлу(Файлы[0]);
				НовыйОбъект.Наименование = Элемент.Название;
				НовыйОбъект.Записать();
				ОбработкаСсылка = НовыйОбъект.Ссылка;
				
			КонецЕсли;
			
			НужнаяСтрока = ОбъектыРазработки.Найти(Элемент.Название);
			НужнаяСтрока.ОбъектРазработки = ОбработкаСсылка;
			
			Отбор = Новый Структура;
			Отбор.Вставить("Название", Элемент.Название);
			
			СтрокиВерсий = Версии.НайтиСтроки(Отбор);
			ПоменятьВерсии(СтрокиВерсий, ОбработкаСсылка);
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ИзмененныеОбъектыРазработки(ОбъектыРазработкиПоследнихРелизов, ВсеОбъектыРазработки)

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВсеОбъектыРазработки.ОбъектРазработки КАК ОбъектРазработки,
	|	ВсеОбъектыРазработки.Версия КАК Версия
	|ПОМЕСТИТЬ втВсеОбъектыРазработки
	|ИЗ
	|	&ВсеОбъектыРазработки КАК ВсеОбъектыРазработки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОбъектыРазработкиПоследнихРелизов.ОбъектРазработки КАК ОбъектРазработки,
	|	ОбъектыРазработкиПоследнихРелизов.ВерсияОбъектаРазработки КАК ВерсияОбъектаРазработки
	|ПОМЕСТИТЬ втОбъектыРазработкиПоследнихРелизов
	|ИЗ
	|	&ОбъектыРазработкиПоследнихРелизов КАК ОбъектыРазработкиПоследнихРелизов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втВсеОбъектыРазработки.ОбъектРазработки КАК ОбъектРазработки,
	|	втВсеОбъектыРазработки.Версия КАК ВерсияОбъектаРазработки
	|ИЗ
	|	втВсеОбъектыРазработки КАК втВсеОбъектыРазработки
	|		ЛЕВОЕ СОЕДИНЕНИЕ втОбъектыРазработкиПоследнихРелизов КАК втОбъектыРазработкиПоследнихРелизов
	|		ПО втВсеОбъектыРазработки.ОбъектРазработки = втОбъектыРазработкиПоследнихРелизов.ОбъектРазработки
	|			И втВсеОбъектыРазработки.Версия = втОбъектыРазработкиПоследнихРелизов.ВерсияОбъектаРазработки
	|ГДЕ
	|	втОбъектыРазработкиПоследнихРелизов.ОбъектРазработки ЕСТЬ NULL";
	
	Запрос.УстановитьПараметр("ОбъектыРазработкиПоследнихРелизов", ОбъектыРазработкиПоследнихРелизов);
	Запрос.УстановитьПараметр("ВсеОбъектыРазработки", ВсеОбъектыРазработки);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Процедура ПоменятьВерсии(СтрокиВерсий, ОбработкаСсылка)
	
	Для Каждого Элемент Из СтрокиВерсий Цикл
		Элемент.ОбъектРазработки = ОбработкаСсылка;
	КонецЦикла;
	
КонецПроцедуры

Функция СопоставитьЗадачи()
	
	Таблица = НовыйТаблицаЗадач();
	
	Для Каждого Элемент Из ЗадачиРелиза Цикл
		
		Если ЗначениеЗаполнено(Элемент.Задача.ОсновнаяЗадача) Тогда
			ТипЗадачи = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Элемент.Задача.ОсновнаяЗадача, "ТипЗадачи");
			Если ТипЗадачи = Перечисления.ТипыЗадач.Разработка  Тогда
				ЗадачаРелиза = Элемент.Задача.ОсновнаяЗадача.ОсновнаяЗадача;
			Иначе
				ЗадачаРелиза = Элемент.Задача.ОсновнаяЗадача;
			КонецЕсли;
		Иначе
			ЗадачаРелиза = Элемент.Задача;
		КонецЕсли;
		СтрокаТаблицы = Таблица.Добавить();
		СтрокаТаблицы.Задача = ЗадачаРелиза;
	КонецЦикла;

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ЗадачиИзGit", Таблица);
	Запрос.УстановитьПараметр("ЗадачиИзБитрикс", Задача.СвязанныеЗадачи.Выгрузить());
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Таблица1.Задача КАК Задача
	|ПОМЕСТИТЬ втПерваяЗадача
	|ИЗ
	|	&ЗадачиИзGit КАК Таблица1
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Таблица2.Задача КАК Задача
	|ПОМЕСТИТЬ втВтораяЗадача
	|ИЗ
	|	&ЗадачиИзБитрикс КАК Таблица2
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(втПерваяЗадача.Задача, втВтораяЗадача.Задача) КАК Задача,
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(втПерваяЗадача.Задача, ИСТИНА) = ИСТИНА
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК НетЗадачиВГит,
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(втВтораяЗадача.Задача, ИСТИНА) = ИСТИНА
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК НетЗадачиВБитрикс
	|ИЗ
	|	втПерваяЗадача КАК втПерваяЗадача
	|		ПОЛНОЕ СОЕДИНЕНИЕ втВтораяЗадача КАК втВтораяЗадача
	|		ПО втПерваяЗадача.Задача = втВтораяЗадача.Задача
	|
	|УПОРЯДОЧИТЬ ПО
	|	Задача";
		
	Результат = Запрос.Выполнить().Выгрузить();
	
	Возврат Результат;
	
КонецФункции

Функция НовыйТаблицаЗадач()
	
	ОписаниеЗадача = Новый ОписаниеТипов("СправочникСсылка.Задачи");
	
	Таблица = Новый ТаблицаЗначений;
	Таблица.Колонки.Добавить("Задача", ОписаниеЗадача, "Задача");
	Возврат Таблица;
	
КонецФункции

#КонецОбласти

#КонецЕсли
