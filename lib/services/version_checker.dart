import 'dart:convert';

import 'package:http/http.dart' as http;
import '../utils/version_utils.dart';

class AppUpdate {
  final Version version;
  final String tag;
  final String url;
  const AppUpdate(this.version, this.tag, this.url);
}

class VersionChecker {
  static const projectPath = 'HttpAnimations/fnaf-flutter';
  static const releasesPage = 'https://gitlab.com/$projectPath/-/releases';

  final http.Client client;
  final String currentVersion;
  bool _checking = false;
  AppUpdate? lastUpdate;
  bool? lastResult;

  VersionChecker({required this.currentVersion, http.Client? client})
      : client = client ?? http.Client();

  static Uri releasesUrl(String tag) =>
      Uri.parse('https://gitlab.com/$projectPath/-/releases/$tag');

  Future<AppUpdate?> check() async {
    if (_checking) return lastUpdate;
    _checking = true;
    try {
      var page = 1;
      Version? best;
      String? bestTag;
      final current = Version.parse(currentVersion) ?? const Version(0, 0, 0);
      while (page <= 10) {
        final res = await client.get(Uri.parse(
            'https://gitlab.com/api/v4/projects/${Uri.encodeComponent(projectPath)}/releases?per_page=100&page=$page&order_by=released_at&sort=desc'));
        if (res.statusCode != 200) {
          lastResult = false;
          return null;
        }
        final list = jsonDecode(res.body) as List;
        if (list.isEmpty) break;
        for (final r in list) {
          final tag = r['tag_name'] as String? ?? '';
          final v = Version.parse(tag);
          if (v != null && v > current && (best == null || v > best)) {
            best = v;
            bestTag = tag;
          }
        }
        if (list.length < 100) break;
        page++;
      }
      lastUpdate = best == null ? null : AppUpdate(best, bestTag!, '');
      lastResult = true;
      return lastUpdate;
    } catch (_) {
      lastResult = false;
      return null;
    } finally {
      _checking = false;
    }
  }
}
