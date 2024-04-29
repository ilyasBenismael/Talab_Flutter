import 'package:image_picker/image_picker.dart';
import 'dart:io';


class Utilities {

  static Future<File?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      return File(pickedFile!.path);
    } catch (e) {
      return null;
    }
  }



}