String getMinCLIVersion(Map agentJson) {
    final versions = _findVersions(agentJson);

    if (versions.isEmpty) {
      throw Exception(
          'Agent Json don\'t contain versions and hence failed to determine the minimum cli version required for the agent. Please contact CommandDash team. \nTroubling json: $agentJson');
    }

    var minVersion = versions.first;
    var minVersionNumber = _versionToNumber(minVersion);

    for (final version in versions) {
      final versionNumber = _versionToNumber(version);

      if ((minVersionNumber == null) ||
          (versionNumber != null && versionNumber < minVersionNumber)) {
        minVersion = version;
        minVersionNumber = versionNumber;
      }
    }
    return minVersion;
  }

  List<String> _findVersions(Map dict) {
    final versions = <String>[];

    dict.forEach((key, value) {
      if (value is List<dynamic>) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            versions.addAll(_findVersions(item));
          }
        }
      } else if (value is Map<String, dynamic>) {
        if (value.containsKey('version')) {
          versions.add(value['version'] as String);
        }
        versions.addAll(_findVersions(value));
      }
    });

    if (dict.containsKey('version')) {
      versions.add(dict['version'] as String);
    }

    return versions;
  }

  int? _versionToNumber(String version) {
    String number = '';
    for (int i = 0; i < version.length; i++) {
      String char = version[i];
      if (RegExp(r'[0-9]').hasMatch(char)) {
        number += char;
      }
    }
    if (number.isEmpty) {
      return null;
    }
    return int.parse(number);
  }