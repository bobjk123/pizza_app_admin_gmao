import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter, unused_import
import 'dart:html' as html;

class FirebasePizzaRepo implements PizzaRepo {
  final CollectionReference<Map<String, dynamic>> pizzaCollection =
      FirebaseFirestore.instance.collection('pizzas');
      final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<List<Pizza>> getPizzas() async {
    try {
      return await pizzaCollection.get().then((value) => value.docs
          .map((e) => Pizza.fromEntity(PizzaEntity.fromDocument(e.data())))
          .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<String> sendImage(Uint8List file, String name) async {
    try {
      final bucket = supabase.storage.from("pizzas");

      final filePath = "images/$name";

      final res = await bucket.uploadBinary(
        filePath,
        file,
        fileOptions: const FileOptions(contentType: "image/jpeg"),
      );

      if (res.isEmpty) {
        throw Exception("Supabase upload failed");
      }

      // Obtener URL pública
      final publicUrl = bucket.getPublicUrl(filePath);

      return publicUrl;
    } catch (e, st) {
      log("ERROR sendImage(): $e", stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> createPizzas(Pizza pizza) async {
    try {
      log('Creating pizza document: ${pizza.toEntity().toDocument()}');
      return await pizzaCollection
          .doc(pizza.pizzaId)
          .set(pizza.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
