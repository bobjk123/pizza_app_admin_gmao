import 'dart:typed_data';
import 'package:pizza_repository/src/save_image_local_io.dart';

Future<void> main() async {
  final bytes = Uint8List.fromList(List.generate(256, (i) => i % 256));
  final name = 'test_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
  try {
    final saved = await saveImageLocally(bytes, name);
    // ignore: avoid_print
    print('Saved path (returned): $saved');
    // ignore: avoid_print
    print('Expected absolute path: C:\\Users\\aaron\\Desktop\\Aplicaciones Moviles\\pizza_app_8sc_gmao\\assets\\images\\$name');
  } catch (e) {
    // ignore: avoid_print
    print('Error saving image: $e');
  }
}
