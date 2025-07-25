// @strict-types

#Область ПрограммныйИнтерфейс
Функция СоеденениеСAPI() Экспорт

	АдресWebGitLab = РаботаСGit.ПолучитьИмяСервераИзСтрокиURL(Константы.АдресWebGitLab.Получить());
	HttpСоединение = Новый HTTPСоединение(АдресWebGitLab, 443, , , , 30,
		Новый ЗащищенноеСоединениеOpenSSL(Неопределено, Неопределено));
		
	Возврат HttpСоединение;
	
КонецФункции

Функция НастройкиБазы(База) Экспорт
	
	Возврат Справочники.Базы.НастройкиБазы(База);
	
КонецФункции
#КонецОбласти
