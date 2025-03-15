# AutoMapper for Dart

🚀 **AutoMapper for Dart** is a library inspired by .NET's AutoMapper, designed to automatically and efficiently convert objects between different types.

## 📌 Features

- 🚀 Automatic conversion between DTOs and Entities.
- 🔧 Uses annotations to automatically map objects.
- ⚡ Support for lists, maps, and nested objects.
- 🛠 Integration with `build_runner` for optimized code generation.
- ✨ Support for default values for missing fields.

---

## 📦 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  auto_mapper: ^1.0.0

dev_dependencies:
    build_runner: ^2.4.6
```

Run the following command to generate the mappings:

```sh
flutter pub run build_runner build
```

---

## 🎯 How to Use

### 1️⃣ Creating DTOs and Entities

Create the DTOs and use the `@AutoMap` annotation to define the conversion.

#### Example:

```dart
import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/entity/warehouse_entity.dart';

@AutoMap(target: WarehouseEntity)
class WarehouseDto {
  List<BoxDto> boxes;

  WarehouseDto({required this.boxes});
}
```

### 2️⃣ Converting Objects

After generating the mappings with `build_runner`, simply use `AutoMapper.convert<T, U>()` to perform the conversion.

```dart
void main() async {
  GeneratedMappings.register();

  ItemDto item1 = ItemDto(
    name: "Laptop",
    quantity: 10,
    isAvailable: true,
  );

  ContainerDto container = ContainerDto(items: [item1]);
  BoxDto box = BoxDto(container: container);
  WarehouseDto warehouse = WarehouseDto(boxes: [box]);

  var warehouseEntity = AutoMapper.convert<WarehouseDto, WarehouseEntity>(warehouse);
  print('Warehouse Entity: \$warehouseEntity');
}
```

### 💚 Default Values for Missing Fields

If the source object does not have a field present in the destination object, you can define a default value using the `@AutoMapFieldValue` annotation.

#### Example:

```dart
@AutoMap(target: ItemEntity)
class ItemDto {
  String name;
  int quantity;
  bool isAvailable;
  Status status;
  dynamic metadata;
  Map<String, dynamic> additionalInfo;

  @AutoMapFieldValue(
      defaultValue: const ClassTest(
      id: 1,
      name: 'test 1234',
      items: [
          ClassTest(id: 2, name: 'name 1'),
          ClassTest(id: 3, name: 'name 2')
        ],
      test: ClassTest(id: 4, name: 'name 3'),
      ),
  )
  ClassTest test;

  ItemDto({
    required this.name,
    required this.quantity,
    required this.isAvailable,
    required this.status,
    required this.metadata,
    required this.additionalInfo,
    required this.test,
  });
}
```

> [!NOTE]
>  In the example above, if the source object does not have the test field, it will be assigned the default instance.

## 📜 Available Annotations

- `@AutoMap(target: EntityClass)`: Defines that the DTO will be converted to the specified entity.
- `@AutoMapFieldValue(defaultValue: value)`: Sets a default value for a missing field.  

---

⚙ Code Generation
After defining your DTOs and entities, run the following command to generate the code automatically:

```sh
flutter pub run build_runner build
```

If you want to regenerate everything, use:

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

---

🛠 Contributing
Contributions are welcome! If you'd like to help, follow these steps:

- Fork the repository.
- Create a branch for your feature (git checkout -b my-feature).
- Commit your changes (git commit -m 'Adding my feature').
- Push to the branch (git push origin my-feature).
- Open a Pull Request.

📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.




