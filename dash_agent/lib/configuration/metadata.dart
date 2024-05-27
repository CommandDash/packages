class Metadata {
  /// Name of the agent that will be displayed to developer.
  /// It doesn't necessary have to be unique similar to agent id defined in
  /// **pubspec.yaml** file.
  ///
  /// Example:
  /// ```dart
  ///  name: "My Agent"
  /// }
  /// ```
  final String name;

  /// Relative path of the avatar image for your agent. The supported formats
  /// are png or jpeg. Additionally, the image ratio should be **1:1** and max size
  /// should not exceed **512*512 pixel**. This will be used as the avatar for
  /// the agent.
  ///
  /// Example:
  /// ```dart
  /// avatarProfile: "assets/images/agent_avatar.png"
  /// ```
  final String? avatarProfile;

  /// List of tags that are associated with the agent.
  ///
  /// Example:
  /// ```dart
  /// tags: ['flutter', 'dart', 'analytics']
  /// ```
  final List<String> tags;

  Metadata(
      {required this.name, this.avatarProfile, this.tags = const <String>[]});

  /// Internal method used by dash_agent to convert the shared `Commmand` to json
  /// formated cofiguration that is deployable.
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'name': name,
      'avatar_path': avatarProfile,
      'tags': tags,
      'version': version
    };
    return processedJson;
  }

  final String version = '0.0.1';
}
