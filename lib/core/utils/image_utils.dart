import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'logger.dart';

class ImageUtils {
  
  
  static Future<File?> compressImage(File file, {int quality = 80}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed${p.extension(file.path)}',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );

      if (result == null) return null;
      
      
      return File(result.path);
    } catch (e) {
      AppLogger.error('Image compression failed', e);
      return file; 
    }
  }

  
  static Future<List<String>> compressImages(List<String> paths, {int quality = 80}) async {
    final List<String> compressedPaths = [];
    for (final path in paths) {
      final compressedFile = await compressImage(File(path), quality: quality);
      if (compressedFile != null) {
        compressedPaths.add(compressedFile.path);
      } else {
        compressedPaths.add(path);
      }
    }
    return compressedPaths;
  }
}
