class PubspecData {
  PubspecData(this.packageName,
      {required this.environment,
      required this.packageDescription,
      required this.packageVersion,
      this.dependencies,
      this.devDependencies,
      this.isFlutter = false});

  final String packageName;
  final String packageDescription;
  final String packageVersion;
  final Map environment;
  final bool isFlutter;

  final Map? dependencies;
  final Map? devDependencies;

  Map<String, dynamic> toJson() {
    return {
      'package_name': packageName,
      'package_description': packageDescription,
      'package_version': packageVersion,
      'environment': environment,
      'dependencies': dependencies,
      'devDependencies': devDependencies,
      'is_flutter': isFlutter,
    };
  }
}
