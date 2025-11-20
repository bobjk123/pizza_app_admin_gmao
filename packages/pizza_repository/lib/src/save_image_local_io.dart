import 'dart:io' as io;
import 'dart:typed_data';
import 'package:path/path.dart' as p;

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

Future<String> saveImageLocally(Uint8List file, String name) async {
  // Save into the current project's assets/images folder (temporary)
  final projectRoot = io.Directory.current.path;
  final imagesDirPath = p.join(projectRoot, 'assets', 'images');
  final dir = io.Directory(imagesDirPath);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }

  final nameWithExt = _ensureExtension(file, name);
  final localFilePath = p.join(imagesDirPath, nameWithExt);
  final localFile = io.File(localFilePath);
  await localFile.writeAsBytes(file, flush: true);
  return p.join('assets', 'images', nameWithExt).replaceAll('\\', '/');
}
