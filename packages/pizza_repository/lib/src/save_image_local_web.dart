// Web implementation: inicia la descarga del archivo en el navegador.
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

Future<String> saveImageLocally(Uint8List file, String name) async {
  final blob = html.Blob([file], 'image/jpeg');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', name)
    ..click();
  html.Url.revokeObjectUrl(url);
  return 'assets/images/$name';
}
