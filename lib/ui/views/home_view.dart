import 'package:compound/ui/shared/ui_helpers.dart';
import 'package:compound/ui/widgets/creation_aware_list_item.dart';
import 'package:compound/ui/widgets/post_item.dart';
import 'package:compound/viewmodels/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider_architecture/_viewmodel_provider.dart';

//  uncomment for without stream
// class HomeView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ViewModelProvider<HomeViewModel>.withConsumer(
//       onModelReady: (model) => model.fetchPosts(),
//       viewModelBuilder: HomeViewModel(), 
//       builder: (BuildContext , HomeViewModel , Widget ) {
//         return Expanded(
//         child: model.posts != null
//         ? ListView.builder(
//             itemCount: model.posts.length,
//             itemBuilder: (context, index) => PostItem(
//               post: model.posts[index],
//             ),
//           )
//         : Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation(
//                   Theme.of(context).primaryColor),
//             ),
//           ));
//       },
//       "Pull to Refresh"
//     );
//   }
// }

// with stream
class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<HomeViewModel>.withConsumer(
      onModelReady: (model) => model.listenToPosts(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          // child:
          //     !model.busy ? Icon(Icons.add) : CircularProgressIndicator(),
          child: Icon(Icons.add),
          onPressed: model.navigateToCreateView,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              verticalSpace(35),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                    child: Image.asset('assets/images/title.png'),
                  ),
                ],
              ),
              Expanded(
                child: model.posts != null
                  ? ListView.builder(
                      itemCount: model.posts.length,
                      itemBuilder: (context, index) =>
                        CreationAwareListItem(
                          itemCreated: () {
                            // when the item is created we request more data when it's the 20th index
                            if (index % 20 == 0)
                              model.requestMoreData();
                          },
                          child:  GestureDetector(
                          onTap: () => model.editPost(index),
                          child: PostItem(
                            post: model.posts[index],
                            onDeleteItem: () => model.deletePost(index),
                          ),
                        ),
                      )) : Center(
                      // child: CircularProgressIndicator(
                      //   valueColor: AlwaysStoppedAnimation(
                      //       Theme.of(context).primaryColor),
                      // ),
                      child: Text("Posts Are Not Created. Please Create A Post"),
                    )
                  )
            ],
          ),
        ),
      ), 
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}