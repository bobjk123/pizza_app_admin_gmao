import 'dart:io' as io;
import 'dart:typed_data';

Future<String> saveImageLocally(Uint8List file, String name) async {
  const localDirPath =
      r'C:\Users\aaron\Desktop\Aplicaciones Moviles\pizza_app_8sc_gmao\assets\images';
  final dir = io.Directory(localDirPath);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final localFilePath = localDirPath + io.Platform.pathSeparator + name;
  final localFile = io.File(localFilePath);
  await localFile.writeAsBytes(file, flush: true);
  return 'assets/images/$name';
}
