import 'dart:io';

import 'package:flutter/widgets.dart';

/// Returns the right ImageProvider for an asset path or a device file path.
ImageProvider<Object> loadImageProvider(String pathOrAsset) {
  if (pathOrAsset.startsWith('assets/')) {
    return AssetImage(pathOrAsset);
  }
  return FileImage(File(pathOrAsset));
}
