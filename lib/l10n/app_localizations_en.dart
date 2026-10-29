// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FNAF Flutter';

  @override
  String get importExe => 'Supply the original game executable';

  @override
  String get importHint =>
      'Select FiveNightsatFreddys.exe from your Steam library to extract the game assets.';

  @override
  String get chooseFile => 'Choose .exe';

  @override
  String get extracting => 'Extracting assets...';

  @override
  String get extractFailed =>
      'Extraction failed. Make sure this is the original game executable.';

  @override
  String get newGame => 'New Game';

  @override
  String get continueGame => 'Continue';

  @override
  String night(Object n) {
    return 'Night';
  }

  @override
  String nightN(Object n) {
    return 'Night $n';
  }

  @override
  String get customNight => 'Custom Night';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System';

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get checking => 'Checking...';

  @override
  String get upToDate => 'You are up to date.';

  @override
  String get updateFailed => 'Update check failed.';

  @override
  String updateAvailable(Object v) {
    return 'Version $v is available';
  }

  @override
  String get viewRelease => 'View release';

  @override
  String get allReleases => 'All releases';

  @override
  String get version => 'Version';

  @override
  String get muteCall => 'Mute call';

  @override
  String get fan => 'Fan';

  @override
  String get powerLeft => 'Power left:';

  @override
  String get usage => 'Usage:';

  @override
  String get timeAm => 'AM';

  @override
  String get warning =>
      'WARNING! This game contains flashing lights, loud noises, and lots of jumpscares!';

  @override
  String get gameOver => 'Game Over';

  @override
  String get goodJob => 'Good job, sport!';

  @override
  String get theEnd => 'THE END';

  @override
  String get door => 'DOOR';

  @override
  String get light => 'LIGHT';

  @override
  String get importWarning =>
      'You must own the original game to play. The exe is only read locally and never uploaded.';

  @override
  String get resetSave => 'Reset save data';

  @override
  String get removeAssets => 'Remove extracted assets';

  @override
  String get download => 'Download';

  @override
  String get getTheGame => 'Get the game';

  @override
  String get landingTagline =>
      'A faithful port of the original survival horror classic.';

  @override
  String get features => 'Features';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get oledTheme => 'OLED';

  @override
  String get playInBrowser => 'Play in browser';

  @override
  String get viewOnGitLab => 'View on GitLab';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get appTitle => 'FNAF Flutter';

  @override
  String get importExe => 'Supply the original game executable';

  @override
  String get importHint =>
      'Select FiveNightsatFreddys.exe from your Steam library to extract the game assets.';

  @override
  String get chooseFile => 'Choose .exe';

  @override
  String get extracting => 'Extracting assets...';

  @override
  String get extractFailed =>
      'Extraction failed. Make sure this is the original game executable.';

  @override
  String get newGame => 'New Game';

  @override
  String get continueGame => 'Continue';

  @override
  String night(Object n) {
    return 'Night';
  }

  @override
  String nightN(Object n) {
    return 'Night $n';
  }

  @override
  String get customNight => 'Custom Night';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System';

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get checking => 'Checking...';

  @override
  String get upToDate => 'You are up to date.';

  @override
  String get updateFailed => 'Update check failed.';

  @override
  String updateAvailable(Object v) {
    return 'Version $v is available';
  }

  @override
  String get viewRelease => 'View release';

  @override
  String get allReleases => 'All releases';

  @override
  String get version => 'Version';

  @override
  String get muteCall => 'Mute call';

  @override
  String get fan => 'Fan';

  @override
  String get powerLeft => 'Power left:';

  @override
  String get usage => 'Usage:';

  @override
  String get timeAm => 'AM';

  @override
  String get warning =>
      'WARNING! This game contains flashing lights, loud noises, and lots of jumpscares!';

  @override
  String get gameOver => 'Game Over';

  @override
  String get goodJob => 'Good job, sport!';

  @override
  String get theEnd => 'THE END';

  @override
  String get door => 'DOOR';

  @override
  String get light => 'LIGHT';

  @override
  String get importWarning =>
      'You must own the original game to play. The exe is only read locally and never uploaded.';

  @override
  String get resetSave => 'Reset save data';

  @override
  String get removeAssets => 'Remove extracted assets';

  @override
  String get download => 'Download';

  @override
  String get getTheGame => 'Get the game';

  @override
  String get landingTagline =>
      'A faithful port of the original survival horror classic.';

  @override
  String get features => 'Features';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get oledTheme => 'OLED';

  @override
  String get playInBrowser => 'Play in browser';

  @override
  String get viewOnGitLab => 'View on GitLab';
}
