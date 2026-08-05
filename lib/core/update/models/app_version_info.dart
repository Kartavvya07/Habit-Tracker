import 'package:equatable/equatable.dart';

/// Representation of the currently installed application version and build.
class AppVersionInfo extends Equatable {
  final String version;
  final int buildNumber;

  const AppVersionInfo({
    required this.version,
    required this.buildNumber,
  });

  @override
  List<Object?> get props => [version, buildNumber];
}
