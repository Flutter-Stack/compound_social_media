import 'package:compound/locator.dart';
import 'package:compound/models/post.dart';
import 'package:compound/services/cloud_storage_service.dart';
import 'package:compound/services/dialog_service.dart';
import 'package:compound/services/firestore_service.dart';
import 'package:compound/services/navigation_service.dart';
import 'package:compound/viewmodels/base_model.dart';
import 'package:compound/constants/route_names.dart';

class HomeViewModel extends BaseModel {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final CloudStorageService _cloudStorageService = locator<CloudStorageService>();

  void requestMoreData() => _firestoreService.requestMoreData();
  // List<Post> _posts;
  // List<Post> get posts => _posts;

  // // uncomment this 
  // // Future navigateToCreateView() async {
  // //   await _navigationService.navigateTo(CreatePostViewRoute);
  // //   await fetchPosts();
  // // }

  // Future fetchPosts() async {
  //   setBusy(true);
  //   var postsResults = await _firestoreService.getPostsOnceOff();
  //   setBusy(false);

  //   if (postsResults is List<Post>) {
  //     _posts = postsResults;
  //     notifyListeners();
  //   } else {
  //     await _dialogService.showDialog(
  //       title: 'Posts Update Failed',
  //       description: postsResults,
  //     );
  //   }
  // }


  // Streams 

  List<Post> _posts;
  List<Post> get posts => _posts;

  void listenToPosts() {
    setBusy(true);

    _firestoreService.listenToPostsRealTime().listen((postsData) {
      List<Post> updatedPosts = postsData;
      if (updatedPosts != null && updatedPosts.length > 0) {
        _posts = updatedPosts;
        notifyListeners();
      }
      setBusy(false);
    });
  }

  Future deletePost(int index) async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
      title: 'Are you sure?',
      description: 'Do you really want to delete the post?',
      confirmationTitle: 'Yes',
      cancelTitle: 'No',
    );

    if (dialogResponse.confirmed) {
      var postToDelete = _posts[index];
      setBusy(true);
      await _firestoreService.deletePost(postToDelete.documentId);
      // Delete the image after the post is deleted
      await _cloudStorageService.deleteImage(postToDelete.imageFileName);
      setBusy(false);
    }
  }

  Future navigateToCreateView() async {
    await _navigationService.navigateTo(CreatePostViewRoute);
  }

  void editPost(int index) {
    _navigationService.navigateTo(CreatePostViewRoute,
        arguments: _posts[index]);
  }
    
}