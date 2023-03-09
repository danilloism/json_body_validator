// ignore_for_file: prefer_const_constructors
import 'package:json_body_validator/json_body_validator.dart';
import 'package:test/test.dart';

void main() {
  group('JsonBodyValidator', () {
    test('can be instantiated', () {
      expect(JsonBodyValidator({}), isNotNull);
    });
  });
}
