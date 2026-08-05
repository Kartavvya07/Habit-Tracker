import 'package:equatable/equatable.dart';

/// Data class representing an update manifest downloaded from the remote server.
class UpdateManifest extends Equatable {
  final String channel;
  final int latestBuild;
  final String version;
  final String apkUrl;
  final String? sha256;
  final List<String> releaseNotes;
  final String? publishedAt;
  final bool mandatory;
  final Map<String, dynamic> extraFields;

  const UpdateManifest({
    required this.channel,
    required this.latestBuild,
    required this.version,
    required this.apkUrl,
    this.sha256,
    this.releaseNotes = const [],
    this.publishedAt,
    this.mandatory = false,
    this.extraFields = const {},
  });

  /// Factory parser designed to tolerate missing, null, or extra unknown fields for future compatibility.
  factory UpdateManifest.fromJson(Map<String, dynamic> json) {
    List<String> parseReleaseNotes(dynamic notes) {
      if (notes is List) {
        return notes.map((e) => e.toString()).toList();
      } else if (notes is String) {
        return [notes];
      }
      return const [];
    }

    final knownKeys = {
      'channel',
      'latestBuild',
      'version',
      'apkUrl',
      'sha256',
      'releaseNotes',
      'publishedAt',
      'mandatory',
    };

    final extra = <String, dynamic>{};
    json.forEach((key, value) {
      if (!knownKeys.contains(key)) {
        extra[key] = value;
      }
    });

    return UpdateManifest(
      channel: (json['channel'] as String?) ?? 'development',
      latestBuild: (json['latestBuild'] as num?)?.toInt() ?? 0,
      version: (json['version'] as String?) ?? '',
      apkUrl: (json['apkUrl'] as String?) ?? '',
      sha256: json['sha256'] as String?,
      releaseNotes: parseReleaseNotes(json['releaseNotes']),
      publishedAt: json['publishedAt']?.toString(),
      mandatory: (json['mandatory'] as bool?) ?? false,
      extraFields: Map.unmodifiable(extra),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channel': channel,
      'latestBuild': latestBuild,
      'version': version,
      'apkUrl': apkUrl,
      if (sha256 != null) 'sha256': sha256,
      'releaseNotes': releaseNotes,
      if (publishedAt != null) 'publishedAt': publishedAt,
      'mandatory': mandatory,
      ...extraFields,
    };
  }

  @override
  List<Object?> get props => [
        channel,
        latestBuild,
        version,
        apkUrl,
        sha256,
        releaseNotes,
        publishedAt,
        mandatory,
        extraFields,
      ];
}
