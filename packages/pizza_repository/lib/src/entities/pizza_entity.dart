import 'package:pizza_repository/src/entities/macros_entity.dart';

import '../models/models.dart';

class PizzaEntity {
  String pizzaId;
  String picture;
  bool isVeg;
  int spicy;
  String name;
  String description;
  int price;
  int discount;
  Macros macros;

  PizzaEntity({
    required this.pizzaId,
    required this.picture,
    required this.isVeg,
    required this.spicy,
    required this.name,
    required this.description,
    required this.price,
    required this.discount,
    required this.macros,
  });

  Map<String, Object?> toDocument() {
    return {
      'pizzaId': pizzaId,
      'picture': picture,
      'isVeg': isVeg,
      'spicy': spicy,
      'name': name,
      'description': description,
      'price': price,
      'discount': discount,
      'macros': macros.toEntity().toDocument(),
    };
  }

  static PizzaEntity fromDocument(Map<String, dynamic> doc) {
    // Defensive parsing with sensible defaults to avoid runtime errors
    final pizzaId = doc['pizzaId'] as String? ?? '';
    final picture = doc['picture'] as String? ?? '';
    final isVeg = doc['isVeg'] as bool? ?? false;
    final spicy = (doc['spicy'] is int)
        ? doc['spicy'] as int
        : int.tryParse('${doc['spicy']}') ?? 1;
    final name = doc['name'] as String? ?? '';
    final description = doc['description'] as String? ?? '';
    final price = (doc['price'] is int)
        ? doc['price'] as int
        : int.tryParse('${doc['price']}') ?? 0;
    final discount = (doc['discount'] is int)
        ? doc['discount'] as int
        : int.tryParse('${doc['discount']}') ?? 0;
    final macrosRaw =
        doc['macros'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final macros = Macros.fromEntity(MacrosEntity.fromDocument(macrosRaw));

    return PizzaEntity(
      pizzaId: pizzaId,
      picture: picture,
      isVeg: isVeg,
      spicy: spicy,
      name: name,
      description: description,
      price: price,
      discount: discount,
      macros: macros,
    );
  }
}
