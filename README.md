# AutoMapper for Dart

🚀 **AutoMapper for Dart** é uma biblioteca inspirada no AutoMapper do .NET, projetada para converter objetos entre diferentes tipos de forma automática e eficiente.

## 📌 Recursos

- 🚀 Conversão automática entre DTOs e Entidades.
- 🔧 Utiliza anotações para mapear automaticamente os objetos.
- ⚡ Suporte a listas, mapas e objetos aninhados.
- 🛠 Integração com `build_runner` para geração de código otimizada.

---

## 📦 Instalação

Adicione a dependência no seu `pubspec.yaml`:

```yaml
dependencies:
  auto_mapper: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.6
```

Rode o seguinte comando para gerar os mapeamentos:

```sh
flutter pub run build_runner build
```

---

## 🎯 Como Usar

### 1️⃣ Criando os DTOs e Entidades

Crie os DTOs e utilize a anotação `@AutoMap` para definir a conversão.

#### Exemplo:

```dart
import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/entity/warehouse_entity.dart';

@AutoMap(target: WarehouseEntity)
class WarehouseDto {
  List<BoxDto> boxes;

  WarehouseDto({required this.boxes});
}
```


### 2️⃣ Convertendo Objetos

Após gerar os mapeamentos com `build_runner`, basta utilizar o `AutoMapper.convert<T, U>()` para fazer a conversão.

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

---

## 📜 Anotações Disponíveis

- `@AutoMap(target: EntityClass)`: Define que o DTO será convertido para a entidade especificada.

---

## ⚙ Geração de Código

Após definir os DTOs e entidades, rode o seguinte comando para gerar o código automaticamente:

```sh
flutter pub run build_runner build
```

Caso queira regenerar completamente, use:

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🛠 Contribuindo

Contribuições são bem-vindas! Se quiser ajudar, siga os seguintes passos:

1. Faça um **fork** do repositório.
2. Crie uma **branch** para a sua feature (`git checkout -b minha-feature`).
3. Faça **commit** das suas alterações (`git commit -m 'Adicionando minha feature'`).
4. Faça um **push** para a branch (`git push origin minha-feature`).
5. Abra um **Pull Request**.

---

## 📄 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para mais detalhes.
