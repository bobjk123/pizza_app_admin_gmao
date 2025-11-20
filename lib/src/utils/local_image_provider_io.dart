import 'dart:io' as io;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

ImageProvider localImageProvider(String path) {
  // Accept relative paths like 'assets/images/name.ext'
  final absPath = p.join(io.Directory.current.path, path);
  return FileImage(io.File(absPath));
}
