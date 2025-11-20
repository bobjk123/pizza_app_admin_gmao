import 'package:flutter/widgets.dart';

ImageProvider localImageProvider(String path) {
  // On web we can't access local filesystem; attempt to load
  // the path as a network resource as a fallback.
  return NetworkImage(path);
}
