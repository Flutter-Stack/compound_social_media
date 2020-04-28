import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageSelector {
  Future<File> selectImage() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }
}

//  You can keep the file in memory until you're certain it's uploaded, 
//  you can have different sources passed in from different functions, etc