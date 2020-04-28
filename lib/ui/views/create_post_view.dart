import 'package:cached_network_image/cached_network_image.dart';
import 'package:compound/models/post.dart';
import 'package:compound/ui/shared/ui_helpers.dart';
import 'package:compound/ui/widgets/input_field.dart';
import 'package:compound/viewmodels/create_post_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider_architecture/provider_architecture.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;  
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePostView extends StatefulWidget {
  final Post edittingPost;
  final String postTitle;

  CreatePostView({
    Key key, 
    this.edittingPost,
    this.postTitle,  
  }) : super(key: key);

  @override
  _CreatePostViewState createState() => _CreatePostViewState(this.edittingPost, this.postTitle);
}

class _CreatePostViewState extends State<CreatePostView> {
  final titleController = TextEditingController();
  File _image;
  String _uploadedFileURL;
  final Post edittingPost;
  final String postTitle;
  _CreatePostViewState(
    this.edittingPost,
    this.postTitle,    
  );

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<CreatePostViewModel>.withConsumer(
      onModelReady: (model) {
        if (edittingPost != null) {
          // update the text in the controller
          titleController.text = edittingPost?.title ?? '';
          _uploadedFileURL = edittingPost?.imageUrl?? '';
          // print(_uploadedFileURL);
          model.setEdittingPost(edittingPost);
        }
        // if we have a title then set the title equal to the value passed in
        else if (postTitle != null) {
          titleController.text = postTitle;
        }        
      },
      builder: (context, model, child) => Scaffold(
          floatingActionButton: FloatingActionButton(
            child: !model.busy
                ? Icon(Icons.add)
                : CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
            onPressed: () async {
              if (!model.busy) {
                await uploadFile().then((fileDownloadUrl) async{
                  // if (fileDownloadUrl != null) {
                    model.addPost(title: titleController.text, imageUrl: fileDownloadUrl);
                  // }
                });
              }
            },
            backgroundColor:
                !model.busy ? Theme.of(context).primaryColor : Colors.grey[600],
          ),
          body: SingleChildScrollView(
            child:Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  verticalSpace(40),
                  Text(
                    'Create Post',
                    style: TextStyle(fontSize: 26),
                  ),
                  verticalSpaceMedium,
                  InputField(
                    placeholder: 'Title',
                    controller: titleController,
                  ),
                  verticalSpaceMedium,
                  Text('Post Image'),
                  verticalSpaceSmall,
                  // _uploadedFileURL != null
                  //   ? Image.network(
                  //       _uploadedFileURL,
                  //       // height: 150,
                  //     )
                  //   : Container(),                
                  // _image != null
                  //   ? Image.file(
                  //       _image,
                  //       // height: 150,
                  //     )
                  //   : Container(),
                  // _image == null ? RaisedButton(
                  //         child: Text('Subir Imagen del Producto'),
                  //         onPressed: chooseFile,
                  //         color: Colors.cyan,
                  //       )
                  //     : Container(),
                  // _image != null
                  //     ? RaisedButton(
                  //         child: Text('Limpiar Selección'),
                  //         onPressed: clearSelection,
                  //       )
                  //     : Container(),
                  // // SizedBox(height: 16,),
                  _uploadedFileURL != null
                    ? SizedBox(
                        height: 250,
                        child: CachedNetworkImage(
                          imageUrl: _uploadedFileURL,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ):Container(),

                  GestureDetector(
                    // When we tap we call selectImage
                    onTap: () => model.selectImage(),
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      // If the selected image is null we show "Tap to add post image"
                      child: model.selectedImage == null
                          ? Text(
                              'Tap to add post image',
                              style: TextStyle(color: Colors.grey[400]),
                            )
                            // If we have a selected image we want to show it
                          : Image.file(model.selectedImage),
                    ),
                  )
                  // Container(
                  //   height: 250,
                  //   decoration: BoxDecoration(
                  //       color: Colors.grey[200],
                  //       borderRadius: BorderRadius.circular(10)),
                  //   alignment: Alignment.center,
                  //   child: Text(
                  //     'Tap to add post image',
                  //     style: TextStyle(color: Colors.grey[400]),
                  //   ),
                  // )
                ],
              ),
            ),
          ))), 
        viewModelBuilder: () => CreatePostViewModel(),
    );
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  Future uploadFile() async {
    try {
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('posts/${Path.basename(_image.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      await uploadTask.onComplete;
      String _uploadedFileURL = await storageReference.getDownloadURL();
      return _uploadedFileURL;      
    } catch (error) {
      print(error);
    }
  }

  void clearSelection() {
    setState(() {
      _image = null;
    });
  }
}

// class CreatePostView extends StatefulWidget {
//   CreatePostView({Key key, this.edittingPost}) : super(key: key);
//   @override
//   _CreatePostViewState createState() => _CreatePostViewState();
// }

// class _CreatePostViewState extends State<CreatePostView> {
// final titleController = TextEditingController();
//   final Post edittingPost;


//   Future navigateToCreateView() async {
//     await _navigationService.navigateTo(CreatePostViewRoute);
//     await fetchPosts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         child: !model.busy
//             ? Icon(Icons.add)
//             : CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation(Colors.white),
//               ),
//         onPressed: () {
//           // Call the function to create the post
//           if (!model.busy)
//             model.addPost(
//               title: titleController.text,
//             );
//         },
//       ),
//     );
//   }
// }