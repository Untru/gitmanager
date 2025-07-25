///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область ПрограммныйИнтерфейс

// Определяет состав назначений и общие реквизиты в шаблонах сообщений 
//
// Параметры:
//  Настройки - Структура:
//    * ПредметыШаблонов - ТаблицаЗначений - содержит варианты предметов для шаблонов. Колонки:
//         ** Имя           - Строка - уникальное имя назначения.
//         ** Представление - Строка - представление варианта.
//         ** Макет         - Строка - имя макета СКД, если состав реквизитов определяется посредством СКД.
//         ** ЗначенияПараметровСКД - Структура - значения параметров СКД для текущего предмета шаблона сообщения.
//    * ОбщиеРеквизиты - ДеревоЗначений - содержит описание общих реквизитов доступных во всех шаблонах. Колонки:
//         ** Имя            - Строка - уникальное имя общего реквизита.
//         ** Представление  - Строка - представление общего реквизита.
//         ** Тип            - Тип    - тип общего реквизита. По умолчанию строка.
//    * ИспользоватьПроизвольныеПараметры  - Булево - указывает, можно ли использовать произвольные пользовательские
//                                                    параметры в шаблонах сообщений.
//    * ЗначенияПараметровСКД - Структура - общие значения параметров СКД, для всех макетов, где состав реквизитов
//                                          определяется средствами СКД.
//    * РасширенныйСписокПолучателей - Булево - если Истина, то для получателей письма можно указывать вариант отправки
//                                              и контакт в исходящих писем подсистемы Взаимодействия.
//
Процедура ПриОпределенииНастроек(Настройки) Экспорт
	
КонецПроцедуры

// Вызывается при подготовке шаблонов сообщений и позволяет переопределить список реквизитов и вложений.
//
// Параметры:
//  Реквизиты - ДеревоЗначений - список реквизитов шаблона:
//    * Имя            - Строка - уникальное имя реквизита.
//    * Представление  - Строка - представление реквизита.
//    * Тип            - Тип    - тип реквизита.
//    * Подсказка      - Строка - расширенная информация о реквизите.
//    * Формат         - Строка - формат вывода значения для чисел, дат, строк и булевых значений. 
//                                Например, "ДЛФ=D" для даты.
//  Вложения - ТаблицаЗначений - печатные формы и вложения, где:
//    * Имя           - Строка - уникальное имя вложения.
//    * Идентификатор - Строка - идентификатор вложения.
//    * Представление - Строка - представление варианта.
//    * Подсказка     - Строка - расширенная информация о вложении.
//    * ТипФайла      - Строка - тип вложения, который соответствует расширению файла: "pdf", "png", "jpg", mxl" и др.
//  НазначениеШаблона       - Строка  - назначение шаблона сообщения, например, "ОповещениеКлиентаИзменениеЗаказа".
//  ДополнительныеПараметры - Структура - дополнительные сведения о шаблоне сообщения.
//
Процедура ПриПодготовкеШаблонаСообщения(Реквизиты, Вложения, НазначениеШаблона, ДополнительныеПараметры) Экспорт

	Если НазначениеШаблона = "Документ.Релиз" Тогда
		ДополнительныеПараметры.РазворачиватьСсылочныеРеквизиты = Истина;
		//ШаблоныСообщений.СформироватьСписокРеквизитовПоСКД(Реквизиты, Документы.Релиз.ПолучитьМакет("ДанныеШаблонаСообщений"));
	КонецЕсли;

КонецПроцедуры

// Вызывается в момент создания сообщений по шаблону для заполнения значений реквизитов и вложений.
//
// Параметры:
//  Сообщение - Структура:
//    * ЗначенияРеквизитов - Соответствие из КлючИЗначение - список используемых в шаблоне реквизитов:
//      ** Ключ     - Строка - имя реквизита в шаблоне;
//      ** Значение - Строка - значение заполнения в шаблоне.
//    * ЗначенияОбщихРеквизитов - Соответствие из КлючИЗначение - список используемых в шаблоне общих реквизитов:
//      ** Ключ     - Строка - имя реквизита в шаблоне;
//      ** Значение - Строка - значение заполнения в шаблоне.
//    * Вложения - Соответствие из КлючИЗначение:
//      ** Ключ     - Строка - имя вложения в шаблоне;
//      ** Значение - ДвоичныеДанные
//                  - Строка - двоичные данные или адрес во временном хранилище вложения.
//    * ДополнительныеПараметры - Структура - дополнительные параметры сообщения. 
//  НазначениеШаблона - Строка -  полное имя назначения шаблон сообщения.
//  ПредметСообщения - ЛюбаяСсылка - ссылка на объект являющийся источником данных.
//  ПараметрыШаблона - Структура -  дополнительная информация о шаблоне сообщения.
//
Процедура ПриФормированииСообщения(Сообщение, НазначениеШаблона, ПредметСообщения, ПараметрыШаблона) Экспорт
	
	
	
КонецПроцедуры

// Заполняет список получателей SMS при отправке сообщения сформированного по шаблону.
//
// Параметры:
//   ПолучателиSMS - ТаблицаЗначений:
//     * НомерТелефона - Строка - номер телефона, куда будет отправлено сообщение SMS;
//     * Представление - Строка - представление получателя сообщения SMS;
//     * Контакт       - Произвольный - контакт, которому принадлежит номер телефона.
//  НазначениеШаблона - Строка - идентификатор назначения шаблона
//  ПредметСообщения - ЛюбаяСсылка - ссылка на объект, являющийся источником данных.
//                   - Структура  - структура описывающая параметры шаблона:
//    * Предмет               - ЛюбаяСсылка - ссылка на объект, являющийся источником данных;
//    * ВидСообщения - Строка - вид формируемого сообщения: "ЭлектроннаяПочта" или "СообщениеSMS";
//    * ПроизвольныеПараметры - Соответствие - заполненный список произвольных параметров;
//    * ОтправитьСразу - Булево - признак мгновенной отправки;
//    * ПараметрыСообщения - Структура - дополнительные параметры сообщения.
//
Процедура ПриЗаполненииТелефоновПолучателейВСообщении(ПолучателиSMS, НазначениеШаблона, ПредметСообщения) Экспорт
	
КонецПроцедуры

// Заполняет список получателей почты при отправке сообщения сформированного по шаблону.
//
// Параметры:
//   ПолучателиПисьма - ТаблицаЗначений - список получается письма:
//     * ВариантОтправки - Строка - вариант отправки для получателя письма: Кому, Копия, СкрытаяКопия, ОбратныйАдрес;
//     * Адрес           - Строка - адрес электронной почты получателя;
//     * Представление   - Строка - представление получателя письма;
//     * Контакт         - Произвольный - контакт, которому принадлежит адрес электронной почты.
//  НазначениеШаблона - Строка - идентификатор назначения шаблона.
//  ПредметСообщения - ЛюбаяСсылка - ссылка на объект, являющийся источником данных.
//                   - Структура  - структура описывающая параметры шаблона:
//    * Предмет               - ЛюбаяСсылка - ссылка на объект, являющийся источником данных;
//    * ВидСообщения - Строка - вид формируемого сообщения: "ЭлектроннаяПочта" или "СообщениеSMS";
//    * ПроизвольныеПараметры - Соответствие - заполненный список произвольных параметров;
//    * ОтправитьСразу - Булево - признак мгновенной отправки письма;
//    * ПараметрыСообщения - Структура - дополнительные параметры сообщения;
//    * ПреобразовыватьHTMLДляФорматированногоДокумента - Булево - признак преобразование HTML текста
//             сообщения содержащего картинки в тексте письма из-за особенностей вывода изображений
//             в форматированном документе;
//    * УчетнаяЗапись - СправочникСсылка.УчетныеЗаписиЭлектроннойПочты - учетная запись для отправки письма.
//
Процедура ПриЗаполненииПочтыПолучателейВСообщении(ПолучателиПисьма, НазначениеШаблона, ПредметСообщения) Экспорт
	
	
	
КонецПроцедуры

// Начальное заполнение предопределенных шаблонов сообщений

// Смотри также ОбновлениеИнформационнойБазыПереопределяемый.ПриНастройкеНачальногоЗаполненияЭлементов
// 
// Параметры:
//  Настройки - см. ОбновлениеИнформационнойБазыПереопределяемый.ПриНастройкеНачальногоЗаполненияЭлементов.Настройки
//
Процедура ПриНастройкеНачальногоЗаполненияЭлементов(Настройки) Экспорт
	
КонецПроцедуры

// Смотри также ОбновлениеИнформационнойБазыПереопределяемый.ПриНачальномЗаполненииЭлементов
//
// Параметры:
//  КодыЯзыков - см. ОбновлениеИнформационнойБазыПереопределяемый.ПриНачальномЗаполненииЭлементов.КодыЯзыков
//  Элементы   - см. ОбновлениеИнформационнойБазыПереопределяемый.ПриНачальномЗаполненииЭлементов.Элементы
//  ТабличныеЧасти - см. ОбновлениеИнформационнойБазыПереопределяемый.ПриНачальномЗаполненииЭлементов.ТабличныеЧасти
//
Процедура ПриНачальномЗаполненииЭлементов(КодыЯзыков, Элементы, ТабличныеЧасти) Экспорт
	
	
	
КонецПроцедуры

// Смотри также ОбновлениеИнформационнойБазыПереопределяемый.ПриНастройкеНачальногоЗаполненияЭлементов
//
// Параметры:
//  Объект                  - СправочникОбъект.РолиИсполнителей - заполняемый объект.
//  Данные                  - СтрокаТаблицыЗначений - данные заполнения объекта.
//  ДополнительныеПараметры - Структура:
//   * ПредопределенныеДанные - ТаблицаЗначений - данные заполненные в процедуре ПриНачальномЗаполненииЭлементов.
//
Процедура ПриНачальномЗаполненииЭлемента(Объект, Данные, ДополнительныеПараметры) Экспорт
	
	
	
КонецПроцедуры

#КонецОбласти

