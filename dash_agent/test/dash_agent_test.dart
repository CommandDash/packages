
import 'package:dash_agent/dash_agent.dart';
import 'package:flutter_test/flutter_test.dart';

import '../examples/main.dart';

void main() {
  test('adds one to input values', () async {
    await processAgent(MyAgent());
  });
}
