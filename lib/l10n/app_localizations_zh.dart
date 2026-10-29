// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FNAF Flutter';

  @override
  String get importExe => '请提供原版游戏可执行文件';

  @override
  String get importHint => '从 Steam 库中选择 FiveNightsatFreddys.exe 以提取游戏资源。';

  @override
  String get chooseFile => '选择 .exe 文件';

  @override
  String get extracting => '正在提取资源...';

  @override
  String get extractFailed => '提取失败。请确认这是原版游戏可执行文件。';

  @override
  String get newGame => '新游戏';

  @override
  String get continueGame => '继续游戏';

  @override
  String night(Object n) {
    return '第$n夜';
  }

  @override
  String nightN(Object n) {
    return '第$n夜';
  }

  @override
  String get customNight => '自定义夜';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get language => '语言';

  @override
  String get systemLanguage => '跟随系统';

  @override
  String get checkUpdates => '检查更新';

  @override
  String get checking => '正在检查...';

  @override
  String get upToDate => '已是最新版本。';

  @override
  String get updateFailed => '检查更新失败。';

  @override
  String updateAvailable(Object v) {
    return '新版本 $v 可用';
  }

  @override
  String get viewRelease => '查看发布';

  @override
  String get allReleases => '所有发布';

  @override
  String get version => '版本';

  @override
  String get muteCall => '静音通话';

  @override
  String get fan => '风扇';

  @override
  String get powerLeft => '剩余电量:';

  @override
  String get usage => '耗电量:';

  @override
  String get timeAm => '上午';

  @override
  String get warning => '警告!本游戏包含闪烁灯光、巨大噪音和大量惊吓内容!';

  @override
  String get gameOver => '游戏结束';

  @override
  String get goodJob => '干得漂亮,伙计!';

  @override
  String get theEnd => '完';

  @override
  String get door => '门';

  @override
  String get light => '灯';

  @override
  String get importWarning => '你必须拥有原版游戏才能游玩。exe 文件仅在本地读取,不会上传。';

  @override
  String get resetSave => '重置存档';

  @override
  String get removeAssets => '删除已提取的资源';

  @override
  String get download => '下载';

  @override
  String get getTheGame => '获取游戏';

  @override
  String get landingTagline => '忠实移植的原版生存恐怖经典。';

  @override
  String get features => '特性';

  @override
  String get theme => '主题';

  @override
  String get systemTheme => '跟随系统';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get oledTheme => 'OLED';

  @override
  String get playInBrowser => '在浏览器中游玩';

  @override
  String get viewOnGitLab => '在 GitLab 查看';
}
