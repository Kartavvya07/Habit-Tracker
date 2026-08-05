import '../models/app_version_info.dart';

/// Abstract service to retrieve installed app version details.
abstract class PackageInfoService {
  Future<AppVersionInfo> getAppVersionInfo();
}

/// Default implementation for querying package version info.
class DefaultPackageInfoService implements PackageInfoService {
  final String version;
  final int buildNumber;

  const DefaultPackageInfoService({
    this.version = '0.4.0-dev.179',
    this.buildNumber = 179,
  });

  @override
  Future<AppVersionInfo> getAppVersionInfo() async {
    return AppVersionInfo(
      version: version,
      buildNumber: buildNumber,
    );
  }
}
