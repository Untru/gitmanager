// @strict-types


#Область ПрограммныйИнтерфейс

Процедура ВключениеДопОбработокВОчередьНаАктуализацию(ТелоЗапроса) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если ТелоЗапроса["object_kind"] = "merge_request"
		И ТелоЗапроса["event_type"] = "merge_request"
		И ТелоЗапроса["object_attributes"]["action"] = "merge"
		Тогда
		
		НомерМерджРеквеста = ТелоЗапроса["object_attributes"]["iid"];
		
		ИмяПроекта = ТелоЗапроса["project"]["name"];
		Проект = Справочники.Проекты.НайтиПоНаименованию(ИмяПроекта);
		
		НастройкиПользователя = Справочники.НастройкиПользователей.НастройкиТекущегоПользователя();
		
		Если Не ЗначениеЗаполнено(НастройкиПользователя.ТокенGit) Тогда
			Возврат;
		КонецЕсли;
		
		НастройкиПроекта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Проект, "Репозиторий, ИДПроектаРепозитория, Ссылка");
		
		ИзмененныеОбработки = ПолучитьСписокИзмененыхОбъектовНаСервере(НомерМерджРеквеста,
			НастройкиПользователя,
			НастройкиПроекта);
			
		Для Каждого Элем Из ИзмененныеОбработки Цикл
		
			РегистрыСведений.ОчередьАктуализацииДопОбработок.ДобавитьЗапись(Элем.Значение);
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьСписокИзмененыхОбъектовНаСервере(НомерМерджРеквеста, НастройкиПользователя, НастройкиПроекта)

	ИзмененныеОбработки = Новый Соответствие;
	
	СписокКоммитов = РаботаСGitLab.СписокКоммитовПоМерджРеквесту(НастройкиПроекта.URLGitLab,
		НастройкиПроекта.ИДПроектаGitLab,
		НомерМерджРеквеста,
		НастройкиПользователя.ТокенGit
	);
	
	ТаблицаИзмененныхОбъектов = РаботаСGitLab.ИзмененияПоКоммиту(НастройкиПроекта.URLGitLab,
		НастройкиПроекта.ИДПроектаGitLab,
		НомерМерджРеквеста,
		НастройкиПользователя.ТокенGit,
		СписокКоммитов
	);
	
	Для Каждого СтрокаТаблицыЗначенийИзмененныеОбъекты Из ТаблицаИзмененныхОбъектов Цикл
		
		ТипОбъекта = СтрокаТаблицыЗначенийИзмененныеОбъекты.ТипОбъекта;
		
		Если Не ЗначениеЗаполнено(ТипОбъекта)
			Или ТипОбъекта <> "ВнешняяОбработка" Тогда
			Продолжить;
		КонецЕсли;
		
		//*ПолноеИмяОбъекта всегда будет с "Внешние обработки.", тип объекта ВнешнийОтчет пока не передается.
		ПолноеИмяОбъекта = СтрокаТаблицыЗначенийИзмененныеОбъекты.Объект;
		ИмяОбъекта = СтрЗаменить(ПолноеИмяОбъекта, "Внешние обработки.", "");
		
		СтруктураЗапись = Новый Структура;
		СтруктураЗапись.Вставить("ИмяОбъекта", ИмяОбъекта);
		СтруктураЗапись.Вставить("Проект",     НастройкиПроекта.Ссылка);
		
		ИзмененныеОбработки.Вставить(ИмяОбъекта, СтруктураЗапись);
		
	КонецЦикла;
	
	Возврат ИзмененныеОбработки;
	
КонецФункции

Процедура ЗапускАктуализацияДопОбработок() Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапросаОчередьСборкиДопОбработок();
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	ТаблицаЗаписей = РезультатЗапроса[1].Выгрузить();

	Если ТаблицаЗаписей.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ВыборкаПоПроектам = РезультатЗапроса[2].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаПоПроектам.Следующий() Цикл
		
		Проект = ВыборкаПоПроектам.Проект;
		ПараметрыПроекта = Справочники.Проекты.НастройкиПроекта(Проект);
		
		База = ПараметрыПроекта.БазаДляАктуализацииОбработок;
		
		Если Не ЗначениеЗаполнено(База) Тогда
			Продолжить;
		КонецЕсли;
		
		ПараметрыБазы = РаботаСGitAPIПовтИсп.НастройкиБазы(База);

		КаталогСборкиПроект = Справочники.Проекты.ПутьКПапкеСборкиОбработок(Проект);
		КаталогСборкиБаза = ПараметрыБазы.КаталогСборкиОбработок;
		
		МассивОбработки = Новый Массив;
		
		ВыборкаОбработки = ВыборкаПоПроектам.Выбрать();
		
		Пока ВыборкаОбработки.Следующий() Цикл
			
			МассивОбработки.Добавить(ВыборкаОбработки.ИмяОбъекта);
			
		КонецЦикла;
		
		ПараметрыЗадачи = КомандыЗапускаПриложения.НовыйПараметрыЗадачи();
		ПараметрыЗадачи.ВнешниеФайлы = СтрСоединить(МассивОбработки, ",");
		ПараметрыЗадачи.Расширения = ПараметрыПроекта.СтрокаРасширенийДляАктуализацииОбработок;

		КомандаЗапуска  = КомандыЗапускаПриложения.НовыйКомандаПереходаНаВеткуАктуализацияОбработок(ПараметрыБазы, ПараметрыЗадачи);
		ПараметрыЗапуска = СтратегияЗапускаСкриптов.ПодготовкаПараметровИЗапускПриложения(База, КомандаЗапуска);
		
		ДанныеЛогов = СтратегияЗапускаСкриптов.ДанныеЛоговСОжиданием(ПараметрыЗапуска);
		
		Если ДанныеЛогов.Выполнено Тогда
			
			УспешноСобранные = Новый Соответствие;
			
			НайденныеФайлы = НайтиФайлы(КаталогСборкиБаза,"*.e?f");
			
			Для Каждого Файл из НайденныеФайлы Цикл
				
				РаботаСОбъектами.СоздатьОбъектРазработки(Проект, Файл);
				
				УспешноСобранные.Вставить(Файл.ИмяБезРасширения, Истина);
				
				ИмяФайлаПриемника = СтрШаблон("%1\%2", КаталогСборкиПроект, Файл.Имя);
				КопироватьФайл(Файл.ПолноеИмя, ИмяФайлаПриемника);
				
			КонецЦикла;
			
		КонецЕсли;
		
		ТекущаяДата = ТекущаяДатаСеанса();
		
		Для Каждого СтрЗапись Из ТаблицаЗаписей Цикл
			
			Если ДанныеЛогов.ЕстьОшибки Тогда
				
				СтрЗапись.ОписаниеОшибки = Новый ХранилищеЗначения(ДанныеЛогов.ПодробныйЛогСтрокой);
				
			КонецЕсли;
			
			Если УспешноСобранные.Получить(СтрЗапись.ИмяОбъекта) <> Неопределено Тогда
				
				СтрЗапись.Обрабатывать = Ложь;
				
			КонецЕсли;
			
			СтрЗапись.ДатаПоследнейОбработки = ТекущаяДата;
			
			РегистрыСведений.ОчередьАктуализацииДопОбработок.ОбновитьЗапись(СтрЗапись.ИдентификаторЗаписи, СтрЗапись);
			
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ТекстЗапросаОчередьСборкиДопОбработок()

	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ОчередьАктуализацииДопОбработок.Обрабатывать КАК Обрабатывать,
	|	ОчередьАктуализацииДопОбработок.ИмяОбъекта КАК ИмяОбъекта,
	|	ОчередьАктуализацииДопОбработок.ИдентификаторЗаписи КАК ИдентификаторЗаписи,
	|	ОчередьАктуализацииДопОбработок.ДатаЗаписи КАК ДатаЗаписи,
	|	ОчередьАктуализацииДопОбработок.ДатаПоследнейОбработки КАК ДатаПоследнейОбработки,
	|	ОчередьАктуализацииДопОбработок.ОписаниеОшибки КАК ОписаниеОшибки,
	|	ОчередьАктуализацииДопОбработок.Проект КАК Проект
	|ПОМЕСТИТЬ ВТ_КОбработке
	|ИЗ
	|	РегистрСведений.ОчередьАктуализацииДопОбработок КАК ОчередьАктуализацииДопОбработок
	|ГДЕ
	|	ОчередьАктуализацииДопОбработок.Обрабатывать
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_КОбработке.Обрабатывать КАК Обрабатывать,
	|	ВТ_КОбработке.ИмяОбъекта КАК ИмяОбъекта,
	|	ВТ_КОбработке.ИдентификаторЗаписи КАК ИдентификаторЗаписи,
	|	ВТ_КОбработке.ДатаЗаписи КАК ДатаЗаписи,
	|	ВТ_КОбработке.ДатаПоследнейОбработки КАК ДатаПоследнейОбработки,
	|	ВТ_КОбработке.ОписаниеОшибки КАК ОписаниеОшибки,
	|	ВТ_КОбработке.Проект КАК Проект
	|ИЗ
	|	ВТ_КОбработке КАК ВТ_КОбработке
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВТ_КОбработке.ИмяОбъекта КАК ИмяОбъекта,
	|	ВТ_КОбработке.Проект КАК Проект
	|ИЗ
	|	ВТ_КОбработке КАК ВТ_КОбработке
	|ИТОГИ ПО
	|	Проект";
	
	Возврат ТекстЗапроса;
	
КонецФункции

#КонецОбласти