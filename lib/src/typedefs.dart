typedef ValidationErrors = Map<String, List<String>>;

typedef Validator<ValueType extends Object?> = String? Function(
  ValueType? value,
);
