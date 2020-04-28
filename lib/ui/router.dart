import 'package:compound/models/post.dart';
import 'package:compound/ui/views/create_post_view.dart';
import 'package:compound/ui/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:compound/constants/route_names.dart';
import 'package:compound/ui/views/login_view.dart';
import 'package:compound/ui/views/signup_view.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginViewRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: LoginView(),
      );
    case SignUpViewRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: SignUpView(),
      );
    case HomeViewRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: HomeView(),
      );
    case CreatePostViewRoute:
      String postTitle;
      Post postToEdit;

      // if it's a string we set postTitle
      if (settings.arguments is String) {
        postTitle = settings.arguments;
      }
      // if it's a post we set post to edit
      else if (settings.arguments is Post) {
        postToEdit = settings.arguments as Post;
      }

      return _getPageRoute(
        routeName: settings.name,
        viewToShow: CreatePostView(
          edittingPost: postToEdit,
          postTitle: postTitle,
        ),
      );
      // var postToEdit = settings.arguments as Post;
      // return _getPageRoute(
      //   routeName: settings.name,
      //   viewToShow: CreatePostView(
      //     edittingPost: postToEdit,
      //   ),
      // );
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

PageRoute _getPageRoute({String routeName, Widget viewToShow}) {
  return MaterialPageRoute(
      settings: RouteSettings(
        name: routeName,
      ),
      builder: (_) => viewToShow);
}
