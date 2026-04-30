import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageCompressor {
  static Future<File?> compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path, 
        '${DateTime.now().millisecondsSinceEpoch}_compressed${p.extension(file.path)}'
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70, 
        minWidth: 1024,
        minHeight: 1024,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      return null;
    }
  }
}
