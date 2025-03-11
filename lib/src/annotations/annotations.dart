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