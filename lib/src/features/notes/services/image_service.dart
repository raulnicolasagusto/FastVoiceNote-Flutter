import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Take a photo using the device camera
  Future<String?> takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;

      // Save the image to app directory
      return await _saveImage(photo);
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  /// Pick an image from gallery
  Future<String?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Save the image to app directory
      return await _saveImage(image);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Save image to app's documents directory
  Future<String> _saveImage(XFile image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'images'));
    
    // Create images directory if it doesn't exist
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Generate unique filename
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
    final savedPath = path.join(imagesDir.path, fileName);

    // Copy the image to the app directory
    final File imageFile = File(image.path);
    await imageFile.copy(savedPath);

    return savedPath;
  }

  /// Delete an image file
  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  /// Get all images for a note
  Future<List<String>> getImagesForNote(String noteId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'images', noteId));
      
      if (!await imagesDir.exists()) {
        return [];
      }

      final List<FileSystemEntity> files = imagesDir.listSync();
      return files
          .whereType<File>()
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('Error getting images: $e');
      return [];
    }
  }
}
