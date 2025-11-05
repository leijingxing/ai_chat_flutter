import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chat_flutter/ai_chat_flutter.dart';

void main() {
  test('validates message content', () {
    expect(isValidMessage(''), isFalse);
    expect(isValidMessage('  '), isFalse);
    expect(isValidMessage('Hello AI'), isTrue);
  });
}
