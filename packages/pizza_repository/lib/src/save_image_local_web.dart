// Web implementation: inicia la descarga del archivo en el navegador.
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:path/path.dart' as p;

String _detectExtension(Uint8List bytes, String name) {
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

String _mimeForExtension(String filename) {
  final ext = p.extension(filename).toLowerCase();
  switch (ext) {
    case '.png':
      return 'image/png';
    case '.gif':
      return 'image/gif';
    case '.bmp':
      return 'image/bmp';
    case '.jpg':
    case '.jpeg':
    default:
      return 'image/jpeg';
  }
}

Future<String> saveImageLocally(Uint8List file, String name) async {
  final nameWithExt = _detectExtension(file, name);
  final mime = _mimeForExtension(nameWithExt);
  // Create a blob URL for previewing the image in the browser.
  // Do NOT revoke it immediately — the UI will use this URL while the page
  // is open. Note: this URL is not persistent across sessions; it's only
  // suitable for local preview. For long-term storage use Supabase or
  // another remote storage provider.
  final blob = html.Blob([file], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);
  return url;
}
