/// A utility class for mapping objects of one type to another.
class AutoMapper {
  /// A map that holds the converters for different types.
  static final Map<String, Function> _mappings = {};

  /// Adds a converter function to the mappings.
  ///
  /// The converter function takes an object of type `S` and returns an object of type `T`.
  ///
  /// Example:
  /// ```dart
  /// AutoMapper.add<int, String>((int value) => value.toString());
  /// ```
  static void add<S, T>(T Function(S) converter) {
    final key = _key<S, T>();
    _mappings[key] = converter;
  }

  /// Converts an object of type `S` to an object of type `T` using the registered converter.
  ///
  /// Throws an [Exception] if no converter is found for the type `S`.
  ///
  /// Example:
  /// ```dart
  /// String result = AutoMapper.convert<int, String>(123);
  /// ```
  static T convert<S, T>(S source) {
    final requestedKey = _key<S, T>();
    final candidates = _buildKeyCandidates<S, T>();

    for (final key in candidates) {
      final converter = _mappings[key];
      if (converter != null) {
        if (source == null && !_isNullableTypeName(_typeName<T>())) {
          throw Exception('Converter found for $key, but source is null and target type ${_typeName<T>()} is not nullable');
        }
        return (converter as dynamic)(source) as T;
      }
    }

    throw Exception('Converter not found for $requestedKey');
  }

  static String _key<S, T>() => '${S.toString()}=>${T.toString()}';

  static List<String> _buildKeyCandidates<S, T>() {
    final sourceType = _typeName<S>();
    final targetType = _typeName<T>();
    final sourceBase = _withoutNullableSuffix(sourceType);
    final targetBase = _withoutNullableSuffix(targetType);

    final candidates = <String>[
      '$sourceType=>$targetType',
      '$sourceBase=>$targetBase',
      '${_toNullable(sourceBase)}=>${_toNullable(targetBase)}',
      '${_toNullable(sourceBase)}=>$targetBase',
      '$sourceBase=>${_toNullable(targetBase)}',
    ];

    return candidates.toSet().toList();
  }

  static String _typeName<T>() => T.toString();

  static bool _isNullableTypeName(String typeName) => typeName.endsWith('?');

  static String _withoutNullableSuffix(String typeName) {
    return _isNullableTypeName(typeName) ? typeName.substring(0, typeName.length - 1) : typeName;
  }

  static String _toNullable(String typeName) {
    return _isNullableTypeName(typeName) ? typeName : '$typeName?';
  }
}