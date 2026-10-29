import 'package:url_launcher/url_launcher.dart';

class Links {
  static Future<bool> Function(Uri uri) open = _open;

  // coverage:ignore-start
  static Future<bool> _open(Uri uri) => launchUrl(uri);
  // coverage:ignore-end
}
