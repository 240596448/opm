///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ОписаниеКоманды(Знач КомандаПриложения) Экспорт
	
	КомандаПриложения.Опция("a all", Ложь, "Обновить все установленные пакеты");
	КомандаПриложения.Опция("f file", "", "Указать файл из которого нужно установить пакет");
	КомандаПриложения.Опция("l local", Ложь, "Обновление пакета в локальном каталоге oscript_modules");
	КомандаПриложения.Опция("s skip-install-deps", Ложь, "признак пропуска установки зависимых пакетов");
	КомандаПриложения.Опция("skip-create-app", Ложь, "признак отключения создания файла запуска");
	КомандаПриложения.Опция("m mirror", "", "Указать имя сервера, с которого необходимо ставить пакеты");

	ОпцияЗеркала = КомандаПриложения.Опция("m mirror", "", "Указать имя сервера, с которого необходимо ставить пакеты.
				|    Доступные сервера прописываются в конфигурационном файле opm.cfg, параметр 'СервераПакетов'.")
				.ВОкружении("OPM_HUB_MIRROR")
				.ТПеречисление();

	МенеджерПолучения = Новый МенеджерПолученияПакетов();
	Для Каждого ДоступноеЗеркало Из МенеджерПолучения.ИменаДоступныхСерверов() Цикл
		ОпцияЗеркала.Перечисление(ДоступноеЗеркало, ДоступноеЗеркало, "Сервер '" + ДоступноеЗеркало + "'");
	КонецЦикла;

	КомандаПриложения.Аргумент("PACKAGE", "", "Имя пакета в хабе. Чтобы установить конкретную версию, используйте ИмяПакета@ВерсияПакета")
						.ТМассивСтрок()
						.Обязательный(Ложь);

	// КомандаПриложения.Спек = "(-a | --all | -l | --local | -d | --dest )";

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач КомандаПриложения) Экспорт
	
	ОбновлениеВЛокальныйКаталог = КомандаПриложения.ЗначениеОпции("local");
	ОбновлениеВсехПакетов = КомандаПриложения.ЗначениеОпции("all");
	ФайлПакетаУстановки = КомандаПриложения.ЗначениеОпции("file");
	МассивПакетовКОбновлению = КомандаПриложения.ЗначениеАргумента("PACKAGE");

	НеобходимУстановитьЗависимости = Не КомандаПриложения.ЗначениеОпции("skip-install-deps");
	СоздаватьФайлыЗапуска = НЕ КомандаПриложения.ЗначениеОпции("skip-create-app");
	ИмяСервера = КомандаПриложения.ЗначениеОпции("mirror");

	РежимУстановки = РежимУстановкиПакетов.Глобально;

	Если ОбновлениеВЛокальныйКаталог = Истина Тогда
		РежимУстановки = РежимУстановкиПакетов.Локально;
	КонецЕсли;

	НастройкаУстановки = РаботаСПакетами.ПолучитьНастройкуУстановки();
	НастройкаУстановки.УстанавливатьЗависимости = НеобходимУстановитьЗависимости;
	НастройкаУстановки.СоздаватьФайлыЗапуска = СоздаватьФайлыЗапуска;
	НастройкаУстановки.ИмяСервера = ИмяСервера;

	Если ОбновлениеВсехПакетов Тогда
		РаботаСПакетами.ОбновитьУстановленныеПакеты(РежимУстановки, , НастройкаУстановки);
	ИначеЕсли НЕ ПустаяСтрока(ФайлПакетаУстановки) Тогда
		РаботаСПакетами.УстановитьПакетИзФайла(ФайлПакетаУстановки, РежимУстановки, , НастройкаУстановки);
	Иначе

		Для каждого ИмяПакета Из МассивПакетовКОбновлению Цикл
			РаботаСПакетами.ОбновитьПакетИзОблака(ИмяПакета, РежимУстановки, , НастройкаУстановки);
		КонецЦикла;

	КонецЕсли;
	
КонецПроцедуры
