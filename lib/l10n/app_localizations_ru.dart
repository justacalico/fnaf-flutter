// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'FNAF Flutter';

  @override
  String get importExe => 'Укажите исполняемый файл оригинальной игры';

  @override
  String get importHint =>
      'Выберите FiveNightsatFreddys.exe из библиотеки Steam, чтобы извлечь ресурсы игры.';

  @override
  String get chooseFile => 'Выбрать .exe';

  @override
  String get extracting => 'Извлечение ресурсов...';

  @override
  String get extractFailed =>
      'Не удалось извлечь ресурсы. Убедитесь, что это оригинальный exe игры.';

  @override
  String get newGame => 'Новая игра';

  @override
  String get continueGame => 'Продолжить';

  @override
  String night(Object n) {
    return 'Ночь';
  }

  @override
  String nightN(Object n) {
    return 'Ночь $n';
  }

  @override
  String get customNight => 'Своя ночь';

  @override
  String get settings => 'Настройки';

  @override
  String get about => 'О программе';

  @override
  String get language => 'Язык';

  @override
  String get systemLanguage => 'Системный';

  @override
  String get checkUpdates => 'Проверить обновления';

  @override
  String get checking => 'Проверка...';

  @override
  String get upToDate => 'У вас последняя версия.';

  @override
  String get updateFailed => 'Не удалось проверить обновления.';

  @override
  String updateAvailable(Object v) {
    return 'Доступна версия $v';
  }

  @override
  String get viewRelease => 'Открыть релиз';

  @override
  String get allReleases => 'Все релизы';

  @override
  String get version => 'Версия';

  @override
  String get muteCall => 'Выкл. звонок';

  @override
  String get fan => 'Вентилятор';

  @override
  String get powerLeft => 'Заряд:';

  @override
  String get usage => 'Расход:';

  @override
  String get timeAm => 'AM';

  @override
  String get warning =>
      'ВНИМАНИЕ! В игре есть мигающий свет, громкие звуки и множество скримеров!';

  @override
  String get gameOver => 'Игра окончена';

  @override
  String get goodJob => 'Молодец, дружище!';

  @override
  String get theEnd => 'КОНЕЦ';

  @override
  String get door => 'ДВЕРЬ';

  @override
  String get light => 'СВЕТ';

  @override
  String get importWarning =>
      'Для игры нужна оригинальная копия. Файл exe читается только локально и не отправляется.';

  @override
  String get resetSave => 'Сбросить сохранение';

  @override
  String get removeAssets => 'Удалить извлечённые ресурсы';

  @override
  String get download => 'Скачать';

  @override
  String get getTheGame => 'Получить игру';

  @override
  String get landingTagline => 'Точный порт классического survival horror.';

  @override
  String get features => 'Возможности';

  @override
  String get theme => 'Тема';

  @override
  String get systemTheme => 'Системная';

  @override
  String get lightTheme => 'Светлая';

  @override
  String get darkTheme => 'Тёмная';

  @override
  String get oledTheme => 'OLED';

  @override
  String get playInBrowser => 'Играть в браузере';

  @override
  String get viewOnGitLab => 'Открыть на GitLab';
}
