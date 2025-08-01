// @strict-types

#Область ПрограммныйИнтерфейс

#Область Инициатор

Процедура ЗапускПриложения(ПараметрыЗапуска) Экспорт	

	ЮрлЗапускаJob = ПараметрыЗапуска.СтрокаКоманды;

	Ответ = КоннекторHTTP.Get(ЮрлЗапускаJob,
		ПараметрыЗапуска.ПараметрыЗапроса,
		ПараметрыЗапуска.ДополнительныеПараметрыЗапроса
	);
	
	Location = Ответ.Заголовки["Location"];
	Если ЗначениеЗаполнено(Location) Тогда
		ЮрлСостоянияJob = СтрШаблон("%1api/json", Location);
		РегистрыСведений.Пайплайны.ДобавитьЮрлСостояния(ПараметрыЗапуска.UID, ЮрлСостоянияJob);	
	КонецЕсли;

	
КонецПроцедуры

Процедура ПолучитьВывод(ПараметрыЗапускаПрограммы) Экспорт
 
	ЮрлВыводаЛогаJob = СтрШаблон("%1/job/%2/%3/logText/progressiveText?start=0",
		ПараметрыЗапускаПрограммы.URLJenkins,
		ПараметрыЗапускаПрограммы.ИмяJobJenkins, 
		ПараметрыЗапускаПрограммы.НомерJob
	);

	Ответ = КоннекторHTTP.Get(ЮрлВыводаЛогаJob,, ПараметрыЗапускаПрограммы.ДополнительныеПараметрыЗапроса);

	Если Не ЗначениеЗаполнено(ПараметрыЗапускаПрограммы.ИмяФайлаПотокаВыводаНаСервере) Тогда
		ПутьКПапке = Константы.ПутьКПапкеДевопсСервера.Получить();
		ПараметрыЗапускаПрограммы.ИмяФайлаПотокаВыводаНаСервере = СтратегияЗапускаСкриптов.ИмяВременногоФайла(ПутьКПапке);
	КонецЕсли;
		
	ФайлTXT = Новый ТекстовыйДокумент;
	ФайлTXT.УстановитьТекст(КоннекторHTTP.КакТекст(Ответ));
	ФайлTXT.Записать(ПараметрыЗапускаПрограммы.ИмяФайлаПотокаВыводаНаСервере, "CP866");
	
КонецПроцедуры

Процедура ПолучитьВыводПоСборке(Пайплайн) Экспорт
	
	ПараметрыЗапуска = ПодготовкаПараметров(Пайплайн);

	ЮрлВыводаЛогаJob = СтрШаблон("%1/job/%2/%3/logText/progressiveText?start=0",
		ПараметрыЗапуска.URLJenkins,
		ПараметрыЗапуска.ИмяJobJenkins, 
		Пайплайн.НомерJob
	);

	Ответ = КоннекторHTTP.Get(ЮрлВыводаЛогаJob,, ПараметрыЗапуска.ДополнительныеПараметрыЗапроса);
		
	ТекстСборки = КоннекторHTTP.КакТекст(Ответ);
	Если СтрНайти(ТекстСборки, ОбщегоНазначенияУправлениеРазработкой.ТекстОкончанияКоманды()) Тогда
		РегистрыСведений.Пайплайны.ЗафиксироватьВыполнениеСборки(ПараметрыЗапуска.UID, ТекстСборки);
	Иначе
		РегистрыСведений.Пайплайны.ЗафиксироватьЛоги(ПараметрыЗапуска.UID, ТекстСборки);
	КонецЕсли;

	
КонецПроцедуры
#КонецОбласти

// Конструктор параметров для ЗапуститьПрограмму.
//
// Возвращаемое значение:
//  Структура:
//    * ТекущийКаталог - Строка - задает текущий каталог запускаемого приложения.
//    * ДождатьсяЗавершения - Булево - Ложь - дожидаться завершения запущенного приложения 
//         перед продолжением работы.
//    * ПолучитьПотокВывода - Булево - Ложь - результат, направленный в поток stdout,
//         если не указан ДождатьсяЗавершения - игнорируется.
//    * ПолучитьПотокОшибок - Булево - Ложь - ошибки, направленные в поток stderr,
//         если не указан ДождатьсяЗавершения - игнорируется.
//    * КодировкаПотоков - КодировкаТекста
//                       - Строка - кодировка, используемая для чтения stdout и stderr.
//         По умолчанию используется для Windows "CP866", для остальных - "UTF-8".
//    * КодировкаИсполнения - Строка
//                          - Число - кодировка, устанавливаемая в Windows с помощью команды chcp,
//             возможные значения: "OEM", "CP866", "UTF8" или номер кодовой страницы.
//         В Linux устанавливается переменной окружения "LANGUAGE" для конкретной команды,
//             возможные значения можно определить выполнив команду "locale -a", например "ru_RU.UTF-8".
//         В MacOS игнорируется.
//    * ЮРЛАгента - Путь к базе которая запускает скрипт на удаленном сервере.
//
Функция ПараметрыЗапускаПрограммы() Экспорт
	
	Параметры = СтратегияЗапускаСкриптов.ПараметрыЗапускаПрограммы();
	Параметры.СтратегияЗапуска = "Jenkins";            
	Параметры.UID = "";            
	
	Возврат Параметры;
	
КонецФункции

Функция ПодготовкаПараметровИЗапускПриложения(База, Задача, Команда) Экспорт
	
	СтрокаКоманды = ОбщегоНазначенияСлужебныйКлиентСервер.БезопаснаяСтрокаКоманды(Команда);
	НастройкиБазы = РаботаСGitAPIПовтИсп.НастройкиБазы(База);
	
	ПараметрыЗапуска = ПараметрыЗапускаПрограммы();
	ПараметрыЗапуска.КомандаЗапуска = Команда;
	ПараметрыЗапуска.СтрокаКоманды = СтрокаКоманды;
	ПараметрыЗапуска.ПутьКПапкеДевопс = НастройкиБазы.ПутьКПапкеДевопс;
	ПараметрыЗапуска.ПараметрыЗапроса = НовыйПараметрыЗапроса();
	ПараметрыЗапуска.ДополнительныеПараметрыЗапроса = НовыйДополнительныеПараметрыЗапроса();
	ПараметрыЗапуска.URLJenkins = НастройкиБазы.URLJenkins;
	ПараметрыЗапуска.ИмяJobJenkins = НастройкиБазы.ИмяJobJenkins;
	
	ЗаполнитьПараметрыЗапроса(ПараметрыЗапуска.ПараметрыЗапроса, Задача, НастройкиБазы);
	ЗаполнитьДополнительныеПараметрыЗапроса(ПараметрыЗапуска.ДополнительныеПараметрыЗапроса, НастройкиБазы);

	ЗапускПриложения(ПараметрыЗапуска);
	
	Возврат ПараметрыЗапуска;
	
КонецФункции

Функция ПодготовкаПараметров(Пайплайн)
	
	Задача = Пайплайн.Задача;

	ПараметрыПроекта = Справочники.Проекты.НастройкиПроекта(Задача.Владелец); 
	ЮрлЗапускаJob = СтрШаблон("%1/job/%2/buildWithParameters",
		ПараметрыПроекта.URLJenkins,
		ПараметрыПроекта.ИмяJobJenkins
	);
	
	ПараметрыЗапуска = ПараметрыЗапускаПрограммы();
	ПараметрыЗапуска.UID = Пайплайн.UID;
	ПараметрыЗапуска.КомандаЗапуска = ЮрлЗапускаJob;
	ПараметрыЗапуска.СтрокаКоманды = ЮрлЗапускаJob;
	ПараметрыЗапуска.ПараметрыЗапроса = НовыйПараметрыЗапроса();
	ПараметрыЗапуска.ДополнительныеПараметрыЗапроса = НовыйДополнительныеПараметрыЗапроса();
	ПараметрыЗапуска.URLJenkins = ПараметрыПроекта.URLJenkins;
	ПараметрыЗапуска.ИмяJobJenkins = ПараметрыПроекта.ИмяJobJenkins;
	
	ЗаполнитьПараметрыЗапроса(ПараметрыЗапуска.ПараметрыЗапроса, Задача, ПараметрыПроекта);
	ЗаполнитьДополнительныеПараметрыЗапроса(ПараметрыЗапуска.ДополнительныеПараметрыЗапроса, ПараметрыПроекта);

	Возврат ПараметрыЗапуска;
	
КонецФункции

Процедура ЗапускПриложенияПоЗадаче(Пайплайн) Экспорт
	
	ПараметрыЗапуска = ПодготовкаПараметров(Пайплайн);
	ЗапускПриложения(ПараметрыЗапуска);
		
КонецПроцедуры

Процедура ПроверитьСтартПайплайна(Пайплайн) Экспорт

	ЮрлСостоянияJob = Пайплайн.ЮрлСостоянияJob; 
	ПараметрыЗапуска = ПодготовкаПараметров(Пайплайн);
	ОтветЗапускаJob = КоннекторHTTP.GetJson(ЮрлСостоянияJob,, ПараметрыЗапуска.ДополнительныеПараметрыЗапроса);
	Если ОтветЗапускаJob["executable"] = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	РегистрыСведений.Пайплайны.ДобавитьНомерJob(Пайплайн.UID, ОтветЗапускаJob["executable"]["number"]);
	
КонецПроцедуры

Процедура ПрочитатьОтчетПайплайнаAllure(Пайплайн) Экспорт
	
	ПараметрыЗапуска = ПодготовкаПараметров(Пайплайн);
	
	Адрес  = "http://jenkins.toolsworld.root.local/job/%1/%2/artifact/allure-report.zip";
	Адрес = СтрШаблон(Адрес, ПараметрыЗапуска.ИмяJobJenkins, Пайплайн.НомерJob);
	ИтогиТестов = РазобратьОтчетAllureПоВнешнимДанным(Адрес, ПараметрыЗапуска.ДополнительныеПараметрыЗапроса, Пайплайн);
	
	РегистрыСведений.Пайплайны.ЗаписатьРезультатТеста(Пайплайн, ИтогиТестов);

	СсылкаНаТест = РаботаСJenkins.СсылкаAllure(ПараметрыЗапуска.URLJenkins, ПараметрыЗапуска.ИмяJobJenkins, Пайплайн.НомерJob);
	РаботаСBitrix.ДобавитьКомментариемРезультатыТестов(СсылкаНаТест, ИтогиТестов["КоличествоУспешных"], ИтогиТестов["КоличествоОшибок"], Пайплайн.Задача);

КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция РазобратьОтчетAllureПоВнешнимДанным(Адрес, ДополнительныеПараметры, Пайплайн)
	
	Ответ = КоннекторHTTP.Get(Адрес,, ДополнительныеПараметры);
	ИтогиТестов = ИтогиТестов();

	Попытка
		ЧтениеZip = Новый ЧтениеZipФайла(Ответ.Тело.ОткрытьПотокДляЧтения());
	Исключение
		Возврат ИтогиТестов;
	КонецПопытки;
	
	Для Каждого Элемент Из ЧтениеZip.Элементы Цикл
		
		Если Элемент.Имя = "suites.json" Тогда
			ВременнаяПапка = ПолучитьИмяВременногоФайла();
			ЧтениеZip.Извлечь(Элемент, ВременнаяПапка);
			
			ШаблонПути = "%1\allure-report\data\%2";
			ПутьКФайлу = СтрШаблон(ШаблонПути, ВременнаяПапка, Элемент.Имя);
			
			Отчет = ЗначениеТекстовогоФайла(ПутьКФайлу);
			ДанныеОтчета = ОбщегоНазначения.JSONВЗначение(Отчет,, Истина);
			
			ИтогиТестов = РазобратьОтчетAllure(ДанныеОтчета);
			УдалитьФайлы(ПутьКФайлу);
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ИтогиТестов;
	
КонецФункции

Функция РазобратьОтчетAllure(ДанныеОтчета)
	
	ИтогиТестов = Новый Структура;
	
	СтатусыТестов = СтатусыТестов();
	
	Для Каждого Элемент Из СтатусыТестов Цикл
        ИтогиТестов.Вставить(Элемент.Значение, 0);
    КонецЦикла;
	
	Для каждого Тест Из ДанныеОтчета["children"] Цикл
		ИтогиТестов[СтатусыТестов[Тест["status"]]] = ИтогиТестов[СтатусыТестов[Тест["status"]]] + 1;
	КонецЦикла;
	
	Возврат ИтогиТестов;
	
КонецФункции

Функция СтатусыТестов()
	
	Результат = Новый Соответствие();
	Результат.Вставить("passed", "КоличествоУспешных");
	Результат.Вставить("failed", "КоличествоОшибок");
	Результат.Вставить("skipped", "КоличествоПропущенных");
	Результат.Вставить("broken", "КоличествоПровалов");
	
	Возврат Результат;
	
КонецФункции

Функция ИтогиТестов()
	
	Результат = Новый Соответствие();
	Результат.Вставить("КоличествоУспешных", 0);
	Результат.Вставить("КоличествоОшибок", 0);
	Результат.Вставить("КоличествоПропущенных", 0);
	Результат.Вставить("КоличествоПровалов", 0);
	
	Возврат Результат;
	
КонецФункции

Функция ЗначениеТекстовогоФайла(ПутьКФайлу)
	
	ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлу, КодировкаТекста.UTF8);
	Значение = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	
	Возврат Значение;

КонецФункции

Функция НовыйПараметрыЗапроса() Экспорт
	
	ПараметрыЗапроса = Новый Структура;

	ПараметрыЗапроса.Вставить("token", "");
	ПараметрыЗапроса.Вставить("BRANCH_NAME", "");
	ПараметрыЗапроса.Вставить("CATALOG_TEST", "");
	ПараметрыЗапроса.Вставить("NAMES_DATA_PROCESSORS", "");
	ПараметрыЗапроса.Вставить("RUN_STAGE", Ложь);
	ПараметрыЗапроса.Вставить("NEED_UPDATE_IB", Ложь);
	ПараметрыЗапроса.Вставить("EXTENSION_NAME", ""); 
	Возврат ПараметрыЗапроса;
	
КонецФункции

Функция НовыйДополнительныеПараметрыЗапроса() Экспорт
	
	ДополнительныеПараметрыЗапроса = Новый Структура;
	ДополнительныеПараметрыЗапроса.Вставить("Аутентификация", Новый Структура("Пользователь, Пароль", "", ""));
	
	Возврат ДополнительныеПараметрыЗапроса;
	
КонецФункции

Процедура ЗаполнитьПараметрыЗапроса(ПараметрыЗапроса, Задача, ПараметрыПроекта) Экспорт

	ВеткаЗадачи = Справочники.Задачи.ВеткаЗадачи(Задача);
    ВеткаЗадачи = СтрШаблон("*/%1", ВеткаЗадачи); 
	
	ПараметрыЗадачи = Справочники.Задачи.РеквизитыЗадачи(Задача);
	ВнешниеФайлы = ПараметрыЗадачи.ВнешниеФайлы;
	
	ПараметрыЗапроса.token = ПараметрыПроекта.ТокенJenkins;
	ПараметрыЗапроса.BRANCH_NAME = ВеткаЗадачи;
	ПараметрыЗапроса.NAMES_DATA_PROCESSORS = ВнешниеФайлы;
	ПараметрыЗапроса.EXTENSION_NAME = Справочники.Задачи.РасширенияЧерезЗапятую(Задача); 
	ПараметрыЗапроса.NEED_UPDATE_IB = Задача.ДорабатыватьКонфигурацию;
	CATALOG_TEST = Справочники.Задачи.КаталогиТестовЧерезЗапятую(Задача);
	Если ПустаяСтрока(CATALOG_TEST) Тогда
		CATALOG_TEST = "feature\smoke"; 
	КонецЕсли;
	ПараметрыЗапроса.CATALOG_TEST = CATALOG_TEST;
	
КонецПроцедуры

Процедура ЗаполнитьДополнительныеПараметрыЗапроса(ДополнительныеПараметрыЗапроса, НастройкиБазы) Экспорт
	
	ДополнительныеПараметрыЗапроса.Аутентификация.Пользователь = НастройкиБазы.ИмяПользователяJenkins;
	ДополнительныеПараметрыЗапроса.Аутентификация.Пароль = НастройкиБазы.ПарольJenkins;
		
КонецПроцедуры

#КонецОбласти
