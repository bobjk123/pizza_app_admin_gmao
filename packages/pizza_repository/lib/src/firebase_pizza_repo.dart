import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_repository/pizza_repository.dart';

class FirebasePizzaRepo implements PizzaRepo {
  final pizzaCollection = FirebaseFirestore.instance.collection('pizzas');

  @override
  Future<List<Pizza>> getPizzas() async {
    try {
      final snapshot = await pizzaCollection.get();
      return snapshot.docs
          .map((e) => Pizza.fromEntity(PizzaEntity.fromDocument(e.data())))
          .toList();
    } catch (e) {
      // Provide clearer logging for Firestore permission issues and fail
      // gracefully for consumers (return empty list) while still surfacing
      // other unexpected errors.
      if (e is FirebaseException) {
        log('Firestore FirebaseException in getPizzas: code=${e.code}, message=${e.message}');
        if (e.code == 'permission-denied') {
          // Return an empty list instead of throwing so UI can show a
          // friendly message and continue running.
          return <Pizza>[];
        }
      }

      log('Unexpected error in getPizzas: $e');
      rethrow;
    }
  }
}
