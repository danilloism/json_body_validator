import 'dart:collection';

import 'package:json_body_validator/src/typedefs.dart';

/// {@template json_body_validator}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class JsonBodyValidator {
  /// {@macro json_body_validator}
  JsonBodyValidator(this._map);

  final Map<String, dynamic> _map;
  final ValidationErrors _errors = {};

  void addTypeValidation<T>(
    String key, {
    bool nullable = true,
    List<Validator<T>>? extra,
  }) {
    addCustomValidation<T>(
      key,
      (value) => value == null && !nullable ? '$key is required' : null,
      extraValidators: extra,
    );
  }

  void addStringValidation(
    String key, {
    required bool nullable,
    required bool notEmpty,
    int? minLength,
    int? maxLength,
    Validator<String>? extra,
  }) {
    assert(
      minLength == null || minLength >= 0,
      'minLength must be null or >= 0',
    );
    assert(
      minLength == null || minLength > 0 || !notEmpty,
      'if minLength is not null and it\'s value equals 0, string can be empty',
    );
    assert(
      minLength == null || minLength == 0 || notEmpty,
      'if minLength is not null and it\'s value is greater than 0, string cannot be empty',
    );
    assert(
      maxLength == null || maxLength > 0,
      'maxLength must be greater than 0',
    );

    final extraValidators = <Validator<String>>[];

    if (notEmpty) {
      extraValidators.add((value) {
        if (value != null && value.isEmpty) {
          return '$key must not be empty';
        }

        return null;
      });
    }

    if (minLength != null) {
      extraValidators.add((value) {
        if (value != null && value.length < minLength) {
          return '$key must have at least $minLength characters';
        }

        return null;
      });
    }

    if (maxLength != null) {
      extraValidators.add((value) {
        if (value != null && value.length > maxLength) {
          return '$key must have a maximum of $maxLength characters';
        }

        return null;
      });
    }

    if (extra != null) {
      extraValidators.add(extra);
    }

    addTypeValidation<String>(
      key,
      nullable: nullable,
      extra: extraValidators,
    );
  }

  void addMinNumberOfFieldsRequiredValidaton({
    required Set<String> keys,
    required int min,
  }) {
    assert(
      keys.length > min,
      'fieldNames length must be greater than min',
    );

    var withValue = 0;

    for (final key in keys) {
      final value = _map[key];

      if (value != null) {
        if (value is String && value.isEmpty) {
          continue;
        }

        withValue++;
      }
    }

    return addCustomValidation(
      'schema',
      (_) => withValue < min
          ? 'At least one of the following fields must be provided: $keys'
          : null,
    );
  }

  void addEmailValidation() {
    addStringValidation(
      'email',
      nullable: false,
      notEmpty: true,
      extra: (value) => (value ?? '').contains('@') ? null : 'Email is invalid',
    );
  }

  void _removeErrorEntryIfEmpty(String key) {
    final errors = _errors[key];

    if (errors == null || errors.isEmpty) {
      _errors.remove(key);
    }
  }

  void addPasswordValidation() {
    addStringValidation(
      'password',
      nullable: false,
      notEmpty: true,
      minLength: 6,
    );
  }

  void addCustomValidation<ValueType extends Object?>(
    String key,
    Validator<ValueType> validator, {
    List<Validator<ValueType>>? extraValidators,
  }) {
    _errors[key] ??= [];
    if (_map[key] is! ValueType?) {
      _errors[key]!.add('$key must be $ValueType');
      return;
    }

    final error = validator(_map[key] as ValueType?);

    if (error != null) {
      _errors[key]!.add(error);
    }

    if (extraValidators != null && extraValidators.isNotEmpty) {
      for (final extra in extraValidators) {
        final extraError = extra(_map[key] as ValueType?);

        if (extraError != null) {
          _errors[key]!.add(extraError);
        }
      }
    }

    _removeErrorEntryIfEmpty(key);
  }

  ValidationErrors get errors => UnmodifiableMapView(_errors);

  bool get isValid => _errors.isEmpty;

  void clear() => _errors.clear();
}
