import 'dart:math';

extension ReadableStringExtension on List<String>? {
  String humanPreferredString(int visibleCount) {
    final stringList = this;

    if (stringList == null) return '';

    final visibleSize = visibleCount == -1
        ? stringList.length
        : min(visibleCount, stringList.length);

    final size = stringList.length;

    if (size == 0) return '';
    if (size == 1) return stringList.first;
    if (size == 2) return stringList.join(' and ');

    var outputString = '';
    if (size > visibleSize) {
      final subList = stringList.sublist(0, visibleSize);
      outputString += subList.join(', ');
      outputString += ', and others';
    } else if (size == visibleSize) {
      final lastItem = stringList.last;
      final subList = stringList.sublist(0, visibleSize - 1);
      outputString += subList.join(', ');
      outputString += ', and $lastItem';
    }
    return outputString;
  }
}
