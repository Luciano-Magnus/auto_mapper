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
    final key = _key<S, T>();
    final converter = _mappings[key] as T Function(S)?;
    if (converter != null) {
      return converter(source);
    }
    throw Exception('Converter not found for $key');
  }

  static String _key<S, T>() => '${S.toString()}=>${T.toString()}';
}