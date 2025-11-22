import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'save_image_local_io.dart'
    if (dart.library.html) 'save_image_local_web.dart' as local_saver;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

/// FirebasePizzaRepo supports uploading images to Supabase Storage (preferred)
/// and falls back to local saves when no Supabase client is provided.
class FirebasePizzaRepo implements PizzaRepo {
  final CollectionReference<Map<String, dynamic>> pizzaCollection =
      FirebaseFirestore.instance.collection('pizzas');

  final SupabaseClient? _supabaseClient;
  final String _storageBucket;

  /// If you want to use Supabase Storage, pass a configured [SupabaseClient]
  /// instance and (optionally) the target storage bucket name.
  /// If [supabaseClient] is null, the repo will save images locally.
  FirebasePizzaRepo(
      {SupabaseClient? supabaseClient, String storageBucket = 'public'})
      : _supabaseClient = supabaseClient,
        _storageBucket = storageBucket {
    // Debug log to help identify whether Supabase client is available at runtime.
    try {
      log('FirebasePizzaRepo created. Supabase client provided: ${_supabaseClient != null}, bucket: $_storageBucket');
    } catch (_) {}
  }

  SupabaseClient? _tryGetSupabaseClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

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

  String _ensureExtension(Uint8List bytes, String name) {
    final ext = p.extension(name);
    if (ext.isNotEmpty) return name;

    if (bytes.length >= 4) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        return '$name.jpg';
      }
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return '$name.png';
      }
      if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
        return '$name.gif';
      }
      if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
        return '$name.bmp';
      }
    }

    return '$name.jpg';
  }

  @override
  Future<String> sendImage(Uint8List file, String name) async {
    final nameWithExt = _ensureExtension(file, name);

    // Try to obtain a Supabase client: prefer injected one, otherwise see if
    // Supabase was initialized globally via `Supabase.initialize` in `main.dart`.
    final client = _supabaseClient ?? _tryGetSupabaseClient();

    if (client != null) {
      log('Attempting Supabase upload for $nameWithExt to bucket=$_storageBucket');
      try {
        final path = 'pizzas/$nameWithExt';
        await client.storage.from(_storageBucket).uploadBinary(path, file);
        final publicUrl =
            client.storage.from(_storageBucket).getPublicUrl(path);
        log('Uploaded to Supabase Storage: $publicUrl');
        return publicUrl;
      } catch (e) {
        log('Supabase upload failed: $e');
        // Fallthrough to local save
      }
    }

    log('No Supabase client available or upload failed; falling back to local save');

    // Fallback: save locally (keeps previous behavior)
    try {
      final savedPath = await local_saver.saveImageLocally(file, nameWithExt);
      return savedPath;
    } catch (e) {
      log('Local save failed: $e');
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
