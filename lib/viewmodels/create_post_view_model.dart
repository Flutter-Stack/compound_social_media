import 'dart:io';

import 'package:compound/locator.dart';
import 'package:compound/models/post.dart';
import 'package:compound/services/analytics_service.dart';
import 'package:compound/services/cloud_storage_service.dart';
import 'package:compound/services/dialog_service.dart';
import 'package:compound/services/firestore_service.dart';
import 'package:compound/services/navigation_service.dart';
import 'package:compound/utils/image_selector.dart';
import 'package:compound/viewmodels/base_model.dart';
import 'package:flutter/foundation.dart';

class CreatePostViewModel extends BaseModel {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  Post _edittingPost;

  bool get _editting => _edittingPost != null;

  final ImageSelector _imageSelector = locator<ImageSelector>();
  final CloudStorageService _cloudStorageService = locator<CloudStorageService>();

  File _selectedImage;
  File get selectedImage => _selectedImage;

  Future selectImage() async {
    var tempImage = await _imageSelector.selectImage();
    if(tempImage != null) {
      _selectedImage = tempImage;
      notifyListeners();
    }
  }

  Future addPost({@required String title, String imageUrl}) async {
    setBusy(true);

    CloudStorageResult storageResult;

    if (!_editting) {
      storageResult = await _cloudStorageService.uploadImage(
          imageToUpload: _selectedImage, title: title);
    }

    var result;

    if (!_editting) {
      result = await _firestoreService
          .addPost(Post(
            title: title,
            imageUrl:  storageResult.imageUrl,
            imageFileName: storageResult.imageFileName,
            userId: currentUser.id
          ));
      await _analyticsService.logPostCreated(
          hasImage: _selectedImage != null);          
    }
    else {
      result = await _firestoreService.updatePost(Post(
        title: title,
        imageUrl: _edittingPost.imageUrl,
        imageFileName: _edittingPost.imageFileName,
        userId: _edittingPost.userId,
        documentId: _edittingPost.documentId,
      ));
    }

    setBusy(false);

    if (result is String) {
      await _dialogService.showDialog(
        title: 'Cound not create post',
        description: result,
      );
    } else {
      await _dialogService.showDialog(
        title: 'Post successfully Added',
        description: 'Your post has been created',
      );
    }

    _navigationService.pop();
  }

  void setEdittingPost(Post edittingPost) {
    _edittingPost = edittingPost;
  }
}