/// Represents software release update channels.
enum UpdateChannel {
  development('development', 'Development'),
  stable('stable', 'Stable');

  final String id;
  final String displayName;

  const UpdateChannel(this.id, this.displayName);

  static UpdateChannel fromId(String id) {
    return UpdateChannel.values.firstWhere(
      (channel) => channel.id.toLowerCase() == id.toLowerCase(),
      orElse: () => UpdateChannel.development,
    );
  }
}
