import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compound/models/post.dart';
import 'package:compound/models/user.dart';
import 'package:flutter/services.dart';

class FirestoreService {
  final CollectionReference _usersCollectionReference =
      Firestore.instance.collection("users");
  final CollectionReference _postsCollectionReference =
      Firestore.instance.collection('posts');

  final StreamController<List<Post>> _postsController =
      StreamController<List<Post>>.broadcast();

  DocumentSnapshot _lastDocument;
  List<List<Post>> _allPagedResults = List<List<Post>>();
  bool _hasMorePosts = true;

  Future createUser(User user) async {
    try {
      await _usersCollectionReference.document(user.id).setData(user.toJson());
    } catch (e) {
      return e.message;
    }
  }

  Future getUser(String uid) async {
    try {
      var userData = await _usersCollectionReference.document(uid).get();
      return User.fromData(userData.data);
    } catch (e) {
      return e.message;
    }
  }

  Future addPost(Post post) async {
    try {
      await _postsCollectionReference.add(post.toMap());
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future getPostsOnceOff() async {
    try {
      var postDocumentSnapshot = await _postsCollectionReference.getDocuments();
      if (postDocumentSnapshot.documents.isNotEmpty) {
        return postDocumentSnapshot.documents
            .map((snapshot) => Post.fromMap(snapshot.data, snapshot.documentID))
            .where((mappedItem) => mappedItem.title != null)
            .toList();
      }
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Stream listenToPostsRealTime() {
    // Register the handler for when the posts data changes
    // _postsCollectionReference.snapshots().listen((postsSnapshot) {
    //   if (postsSnapshot.documents.isNotEmpty) {
    //     var posts = postsSnapshot.documents
    //         .map((snapshot) => Post.fromMap(snapshot.data, snapshot.documentID))
    //         .where((mappedItem) => mappedItem.title != null)
    //         .toList();

    //     // Add the posts onto the controller
    //     _postsController.add(posts);
    //   }
    // });
    _requestPosts();
    return _postsController.stream;
  }

  Future deletePost(String documentId) async {
    await _postsCollectionReference.document(documentId).delete();
  }

  Future updatePost(Post post) async {
    try {
      await _postsCollectionReference
          .document(post.documentId)
          .updateData(post.toMap());
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  // void _requestPosts() {
  //   _postsCollectionReference.snapshots().listen((postsSnapshot) {
  //     if (postsSnapshot.documents.isNotEmpty) {
  //       var posts = postsSnapshot.documents
  //           .map((snapshot) => Post.fromMap(snapshot.data, snapshot.documentID))
  //           .where((mappedItem) => mappedItem.title != null)
  //           .toList();

  //       // Add the posts onto the controller
  //       _postsController.add(posts);
  //     }
  //   });
  // }

  void _requestPosts() {
    var pagePostsQuery = _postsCollectionReference
        .orderBy('title')
        .limit(20);

    if (_lastDocument != null) {
      pagePostsQuery = pagePostsQuery.startAfterDocument(_lastDocument);
    }

    // If there's no more posts then bail out of the function
    if (!_hasMorePosts) return;

    var currentRequestIndex = _allPagedResults.length;

    pagePostsQuery.snapshots().listen((postsSnapshot) {
      if (postsSnapshot.documents.isNotEmpty) {
        var posts = postsSnapshot.documents
            .map((snapshot) => Post.fromMap(snapshot.data, snapshot.documentID))
            .where((mappedItem) => mappedItem.title != null)
            .toList();

        var pageExists = currentRequestIndex < _allPagedResults.length;

        if (pageExists) {
          _allPagedResults[currentRequestIndex] = posts;
        } else {
          _allPagedResults.add(posts);
        }
        var allPosts = _allPagedResults.fold<List<Post>>(List<Post>(),
            (initialValue, pageItems) => initialValue..addAll(pageItems));

        _postsController.add(allPosts);

        // Save the last document from the results only if it's the current last page
        if (currentRequestIndex == _allPagedResults.length - 1) {
          _lastDocument = postsSnapshot.documents.last;
        }

        // Determine if there's more posts to request
        _hasMorePosts = posts.length == 20;
      }
    });
  }

  void requestMoreData() => _requestPosts();
}