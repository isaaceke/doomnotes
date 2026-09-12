import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  Future<Map<String, String>> loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return {
      'version': info.version,
      'buildNumber': info.buildNumber,
      'appName': info.appName,
      'packageName': info.packageName,
    };
  }
}