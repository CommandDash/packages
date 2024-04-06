extension RedableStringExtension on Map<String, dynamic> {
  String humanReadableString({int indentLevel = 0}) {
    final data = this;
    String structuredString = "";
    data.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        structuredString += '${' ' * indentLevel}$key:\n';
        structuredString +=
            value.humanReadableString(indentLevel: indentLevel + 2);
      } else if (value is List<Map<String, dynamic>>) {
        structuredString += '${' ' * indentLevel}$key:\n';
        for (var item in value) {
          structuredString +=
              item.humanReadableString(indentLevel: indentLevel + 2);
        }
      } else {
        structuredString += '${' ' * indentLevel}$key: $value\n';
      }
    });
    return structuredString;
  }
}
