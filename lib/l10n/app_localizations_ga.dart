// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Irish (`ga`).
class AppLocalizationsGa extends AppLocalizations {
  AppLocalizationsGa([String locale = 'ga']) : super(locale);

  @override
  String get appTitle => 'FNAF Flutter';

  @override
  String get importExe => 'Tabhair exe an chluiche bhunaidh';

  @override
  String get importHint =>
      'Roghnaigh FiveNightsatFreddys.exe ó do leabharlann Steam chun sócmhainní an chluiche a bhaint.';

  @override
  String get chooseFile => 'Roghnaigh .exe';

  @override
  String get extracting => 'Á bhaint...';

  @override
  String get extractFailed =>
      'Theip ar an mbaint. Cinntigh gurb é exe bunaidh an chluiche é.';

  @override
  String get newGame => 'Cluiche Nua';

  @override
  String get continueGame => 'Lean ar aghaidh';

  @override
  String night(Object n) {
    return 'Oíche';
  }

  @override
  String nightN(Object n) {
    return 'Oíche $n';
  }

  @override
  String get customNight => 'Oíche Saincheaptha';

  @override
  String get settings => 'Socruithe';

  @override
  String get about => 'Faoi';

  @override
  String get language => 'Teanga';

  @override
  String get systemLanguage => 'Córas';

  @override
  String get checkUpdates => 'Seiceáil nuashonruithe';

  @override
  String get checking => 'Á sheiceáil...';

  @override
  String get upToDate => 'Tá an leagan is déanaí agat.';

  @override
  String get updateFailed => 'Theip ar sheiceáil nuashonruithe.';

  @override
  String updateAvailable(Object v) {
    return 'Tá leagan $v ar fáil';
  }

  @override
  String get viewRelease => 'Féach ar an eisiúint';

  @override
  String get allReleases => 'Gach eisiúint';

  @override
  String get version => 'Leagan';

  @override
  String get muteCall => 'Balbhaigh an glao';

  @override
  String get fan => 'Fan';

  @override
  String get powerLeft => 'Cumhacht fágtha:';

  @override
  String get usage => 'Úsáid:';

  @override
  String get timeAm => 'AM';

  @override
  String get warning =>
      'RABHADH! Tá soilse splancacha, fuaimeanna láidre agus scaollacha sa chluiche seo!';

  @override
  String get gameOver => 'Cluiche Thart';

  @override
  String get goodJob => 'Maith thú, a chara!';

  @override
  String get theEnd => 'DEIREADH';

  @override
  String get door => 'DORAS';

  @override
  String get light => 'SOLAS';

  @override
  String get importWarning =>
      'Ní mór an cluiche bunaidh a bheith agat. Ní uaslódáiltear an exe riamh.';

  @override
  String get resetSave => 'Athshocraigh sábháil';

  @override
  String get removeAssets => 'Bain sócmhainní bainte';

  @override
  String get download => 'Íoslódáil';

  @override
  String get getTheGame => 'Faigh an cluiche';

  @override
  String get landingTagline => 'Port dílis den chlásiceach uafáis marthanais.';

  @override
  String get features => 'Gnéithe';

  @override
  String get theme => 'Téama';

  @override
  String get systemTheme => 'Córas';

  @override
  String get lightTheme => 'Solas';

  @override
  String get darkTheme => 'Dorcha';

  @override
  String get oledTheme => 'OLED';

  @override
  String get playInBrowser => 'Imir sa bhrabhsálaí';

  @override
  String get viewOnGitLab => 'Féach ar GitLab';
}
