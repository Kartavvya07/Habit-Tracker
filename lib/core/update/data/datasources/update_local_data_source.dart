import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/update_channel.dart';
import '../../models/update_manifest.dart';

/// Abstract local data source for caching manifests and channel preferences.
abstract class UpdateLocalDataSource {
  Future<UpdateManifest?> getCachedManifest();
  Future<void> cacheManifest(UpdateManifest manifest);
  Future<UpdateChannel> getSelectedChannel();
  Future<void> setSelectedChannel(UpdateChannel channel);
}

/// SharedPreferences implementation of [UpdateLocalDataSource].
class SharedPreferencesUpdateLocalDataSource implements UpdateLocalDataSource {
  static const String _manifestKey = 'cached_update_manifest';
  static const String _channelKey = 'selected_update_channel';

  final SharedPreferences? _prefs;

  SharedPreferencesUpdateLocalDataSource({SharedPreferences? prefs})
      : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  @override
  Future<UpdateManifest?> getCachedManifest() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_manifestKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final Map<String, dynamic> jsonMap =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return UpdateManifest.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheManifest(UpdateManifest manifest) async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(manifest.toJson());
    await prefs.setString(_manifestKey, jsonString);
  }

  @override
  Future<UpdateChannel> getSelectedChannel() async {
    final prefs = await _getPrefs();
    final channelId = prefs.getString(_channelKey);
    if (channelId == null) return UpdateChannel.development;
    return UpdateChannel.fromId(channelId);
  }

  @override
  Future<void> setSelectedChannel(UpdateChannel channel) async {
    final prefs = await _getPrefs();
    await prefs.setString(_channelKey, channel.id);
  }
}
