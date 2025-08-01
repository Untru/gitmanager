// @strict-types

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Пинг(ПараметрКоманды);
	
КонецПроцедуры
	
#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура Пинг(База)
	
	ДанныеЛоговПингаБазы = Справочники.Базы.ДанныеЛоговПингаБазы(База);
	Сообщить(ДанныеЛоговПингаБазы.ПодробныйЛогСтрокой);
	
КонецПроцедуры

#КонецОбласти