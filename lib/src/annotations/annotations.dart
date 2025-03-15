/// An annotation used to specify the target type for automatic mapping.
///
/// This annotation is used to mark a class or a field that should be automatically mapped
/// to another type. The `target` parameter specifies the type to which the annotated
/// element should be mapped.
class AutoMap {
  /// The target type to which the annotated element should be mapped.
  final Type target;

  /// Creates an instance of the [AutoMap] annotation with the specified target type.
  ///
  /// The [target] parameter must not be null.
  const AutoMap({required this.target});
}

/// An annotation used to specify the default value for a field during automatic mapping.
class AutoMapFieldValue {
  /// The default value for the field.
  final dynamic defaultValue;

  /// Creates an instance of the [AutoMapFieldValue] annotation with the specified default value and field name.
  ///
  /// The [defaultValue] and [name] parameters must not be null.
  const AutoMapFieldValue({required this.defaultValue});
}