class ClassTest {
  final int id;
  final String name;
  final bool isTest;
  final List<ClassTest> items;
  final ClassTest? test;

  const ClassTest({required this.id, required this.name, this.isTest = true, this.items = const [], this.test});

  @override
  String toString() {
    return '''
    ClassTest {
      id: $id,
      name: $name,
      isTest: $isTest,
      items: $items,
      test: $test
    }
    ''';
  }
}