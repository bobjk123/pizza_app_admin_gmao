// Conditional export: use IO implementation when available, otherwise web.
export 'local_image_provider_io.dart'
    if (dart.library.html) 'local_image_provider_web.dart';
