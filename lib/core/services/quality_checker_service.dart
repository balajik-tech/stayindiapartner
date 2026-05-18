import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image/image.dart' as img;
import 'package:stayindia_owner/core/utils/logger.dart';

class QualityCheckerService {
  static final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.4),
  );

  static Future<String?> checkImageQuality(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);

      final labels = await _imageLabeler.processImage(inputImage);

      AppLogger.info(
        'Image Labels: ${labels.map((e) => "${e.label} (${e.confidence})").join(', ')}',
      );

      if (labels.isEmpty) {
        return "Image is too blurry or unclear. Please take a steadier photo.";
      }

      for (var label in labels) {
        final text = label.label.toLowerCase();
        if ((text.contains('blur') ||
                text.contains('mist') ||
                text.contains('fog')) &&
            label.confidence > 0.7) {
          return "Image appears to be blurry. Please try again.";
        }
      }

      final bytes = await File(path).readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage != null) {
        double totalLuma = 0;
        int sampleCount = 0;

        const int sampleStep = 20;

        for (int y = 0; y < decodedImage.height; y += sampleStep) {
          for (int x = 0; x < decodedImage.width; x += sampleStep) {
            final pixel = decodedImage.getPixel(x, y);

            final r = pixel.r;
            final g = pixel.g;
            final b = pixel.b;

            final luma = (0.299 * r) + (0.587 * g) + (0.114 * b);
            totalLuma += luma;
            sampleCount++;
          }
        }

        final avgLuma = totalLuma / sampleCount;
        AppLogger.info('Average Image Luma: $avgLuma');

        if (avgLuma < 35) {
          return "Image is too dark. Please upload a brighter photo.";
        }

        if (avgLuma > 245) {
          return "Image is too bright or washed out. Please try again.";
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Error in QualityCheckerService: $e');
      return null;
    }
  }

  static void dispose() {
    _imageLabeler.close();
  }
}
