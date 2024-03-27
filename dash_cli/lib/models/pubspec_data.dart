class PubspecData {
  PubspecData(this.packageName,
      {required this.environment, this.dependencies, this.devDependencies, this.isFlutter = false});

  final String packageName;
  final Map environment;
  final bool isFlutter;

  final Map? dependencies;
  final Map? devDependencies;

  Map<String, dynamic> toJson() {
    return {
      'package_name': packageName,
      'environment': environment,
      'dependencies': dependencies,
      'devDependencies': devDependencies,
      'is_flutter': isFlutter,
    };
  }
}
