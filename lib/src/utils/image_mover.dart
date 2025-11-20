import 'dart:io' as io;
import 'package:path/path.dart' as p;

/// Moves a temporarily saved image (relative path like 'assets/images/name.ext')
/// from the current project's assets folder to the final project folder
/// C:\Users\aaron\Desktop\Aplicaciones Moviles\pizza_app_8sc_gmao\assets\images\
/// Returns the relative path unchanged on success.
Future<String> moveTempImageToFinal(String relativePath) async {
  if (!relativePath.startsWith('assets/')) return relativePath;

  final fileName = p.basename(relativePath);
  final srcPath = p.join(io.Directory.current.path, relativePath);
  final destDirPath =
      r'C:\\Users\\aaron\\Desktop\\Aplicaciones Moviles\\pizza_app_8sc_gmao\\assets\\images';
  final destDir = io.Directory(destDirPath);
  if (!destDir.existsSync()) {
    await destDir.create(recursive: true);
  }
  final destPath = p.join(destDir.path, fileName);

  final srcFile = io.File(srcPath);
  if (!srcFile.existsSync()) {
    // Nothing to move
    return relativePath;
  }

  final destFile = io.File(destPath);
  // If destination exists, overwrite
  if (destFile.existsSync()) {
    await destFile.delete();
  }

  // Attempt to move; if across volumes, fallback to copy+delete
  try {
    await srcFile.rename(destPath);
  } catch (_) {
    await srcFile.copy(destPath);
    await srcFile.delete();
  }

  return relativePath;
}
