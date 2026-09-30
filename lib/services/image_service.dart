import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera or gallery and compress it
  static Future<String?> pickAndCompressImage(
    ImageSource source,
    String traineeId,
  ) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return null;

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/trainee_images');

      // Create images directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final targetPath = '${imagesDir.path}/$traineeId.jpg';

      // Compress the image
      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
            pickedFile.path,
            targetPath,
            quality: 50, // 50% quality for smaller size
            minWidth: 300,
            minHeight: 300,
          );

      if (compressedFile != null) {
        return compressedFile.path;
      }

      // Fallback: copy without compression if compression fails
      await File(pickedFile.path).copy(targetPath);
      return targetPath;
    } catch (e) {
      return null;
    }
  }

  /// Delete trainee image
  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null) return;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors when deleting
    }
  }

  /// Check if image exists
  static bool imageExists(String? imagePath) {
    if (imagePath == null) return false;
    return File(imagePath).existsSync();
  }
}
