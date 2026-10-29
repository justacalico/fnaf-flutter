import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ga.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'GB'),
    Locale('ga'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en_GB, this message translates to:
  /// **'FNAF Flutter'**
  String get appTitle;

  /// No description provided for @importExe.
  ///
  /// In en_GB, this message translates to:
  /// **'Supply the original game executable'**
  String get importExe;

  /// No description provided for @importHint.
  ///
  /// In en_GB, this message translates to:
  /// **'Select FiveNightsatFreddys.exe from your Steam library to extract the game assets.'**
  String get importHint;

  /// No description provided for @chooseFile.
  ///
  /// In en_GB, this message translates to:
  /// **'Choose .exe'**
  String get chooseFile;

  /// No description provided for @extracting.
  ///
  /// In en_GB, this message translates to:
  /// **'Extracting assets...'**
  String get extracting;

  /// No description provided for @extractFailed.
  ///
  /// In en_GB, this message translates to:
  /// **'Extraction failed. Make sure this is the original game executable.'**
  String get extractFailed;

  /// No description provided for @newGame.
  ///
  /// In en_GB, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @continueGame.
  ///
  /// In en_GB, this message translates to:
  /// **'Continue'**
  String get continueGame;

  /// No description provided for @night.
  ///
  /// In en_GB, this message translates to:
  /// **'Night'**
  String night(Object n);

  /// No description provided for @nightN.
  ///
  /// In en_GB, this message translates to:
  /// **'Night {n}'**
  String nightN(Object n);

  /// No description provided for @customNight.
  ///
  /// In en_GB, this message translates to:
  /// **'Custom Night'**
  String get customNight;

  /// No description provided for @settings.
  ///
  /// In en_GB, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en_GB, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @language.
  ///
  /// In en_GB, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In en_GB, this message translates to:
  /// **'System'**
  String get systemLanguage;

  /// No description provided for @checkUpdates.
  ///
  /// In en_GB, this message translates to:
  /// **'Check for updates'**
  String get checkUpdates;

  /// No description provided for @checking.
  ///
  /// In en_GB, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @upToDate.
  ///
  /// In en_GB, this message translates to:
  /// **'You are up to date.'**
  String get upToDate;

  /// No description provided for @updateFailed.
  ///
  /// In en_GB, this message translates to:
  /// **'Update check failed.'**
  String get updateFailed;

  /// No description provided for @updateAvailable.
  ///
  /// In en_GB, this message translates to:
  /// **'Version {v} is available'**
  String updateAvailable(Object v);

  /// No description provided for @viewRelease.
  ///
  /// In en_GB, this message translates to:
  /// **'View release'**
  String get viewRelease;

  /// No description provided for @allReleases.
  ///
  /// In en_GB, this message translates to:
  /// **'All releases'**
  String get allReleases;

  /// No description provided for @version.
  ///
  /// In en_GB, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @muteCall.
  ///
  /// In en_GB, this message translates to:
  /// **'Mute call'**
  String get muteCall;

  /// No description provided for @fan.
  ///
  /// In en_GB, this message translates to:
  /// **'Fan'**
  String get fan;

  /// No description provided for @powerLeft.
  ///
  /// In en_GB, this message translates to:
  /// **'Power left:'**
  String get powerLeft;

  /// No description provided for @usage.
  ///
  /// In en_GB, this message translates to:
  /// **'Usage:'**
  String get usage;

  /// No description provided for @timeAm.
  ///
  /// In en_GB, this message translates to:
  /// **'AM'**
  String get timeAm;

  /// No description provided for @warning.
  ///
  /// In en_GB, this message translates to:
  /// **'WARNING! This game contains flashing lights, loud noises, and lots of jumpscares!'**
  String get warning;

  /// No description provided for @gameOver.
  ///
  /// In en_GB, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @goodJob.
  ///
  /// In en_GB, this message translates to:
  /// **'Good job, sport!'**
  String get goodJob;

  /// No description provided for @theEnd.
  ///
  /// In en_GB, this message translates to:
  /// **'THE END'**
  String get theEnd;

  /// No description provided for @door.
  ///
  /// In en_GB, this message translates to:
  /// **'DOOR'**
  String get door;

  /// No description provided for @light.
  ///
  /// In en_GB, this message translates to:
  /// **'LIGHT'**
  String get light;

  /// No description provided for @importWarning.
  ///
  /// In en_GB, this message translates to:
  /// **'You must own the original game to play. The exe is only read locally and never uploaded.'**
  String get importWarning;

  /// No description provided for @resetSave.
  ///
  /// In en_GB, this message translates to:
  /// **'Reset save data'**
  String get resetSave;

  /// No description provided for @removeAssets.
  ///
  /// In en_GB, this message translates to:
  /// **'Remove extracted assets'**
  String get removeAssets;

  /// No description provided for @download.
  ///
  /// In en_GB, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @getTheGame.
  ///
  /// In en_GB, this message translates to:
  /// **'Get the game'**
  String get getTheGame;

  /// No description provided for @landingTagline.
  ///
  /// In en_GB, this message translates to:
  /// **'A faithful port of the original survival horror classic.'**
  String get landingTagline;

  /// No description provided for @features.
  ///
  /// In en_GB, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @theme.
  ///
  /// In en_GB, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en_GB, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en_GB, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en_GB, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @oledTheme.
  ///
  /// In en_GB, this message translates to:
  /// **'OLED'**
  String get oledTheme;

  /// No description provided for @playInBrowser.
  ///
  /// In en_GB, this message translates to:
  /// **'Play in browser'**
  String get playInBrowser;

  /// No description provided for @viewOnGitLab.
  ///
  /// In en_GB, this message translates to:
  /// **'View on GitLab'**
  String get viewOnGitLab;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ga', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ga':
      return AppLocalizationsGa();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
