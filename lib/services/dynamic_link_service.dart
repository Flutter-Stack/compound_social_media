import 'package:compound/locator.dart';
import 'package:compound/services/navigation_service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkService {

  final NavigationService _navigationService = locator<NavigationService>();
  
    Future handleDynamicLinks() async {
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    // 2. handle link that has been retrieved
    _handleDeepLink(data);

    // 3. Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      // 3a. handle link that has been retrieved
      _handleDeepLink(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('_handleDeepLink | deeplink: $deepLink');

      // Check if we want to make a post
      // var isPost = deepLink.pathSegments.contains('post');

      // if (isPost) {
      //   // get the title of the post
      //   var title = deepLink.queryParameters['title'];

      //   if (title != null) {
      //     // if we have a post navigate to the CreatePostViewRoute and pass in the title as the arguments.
      //     _navigationService.navigateTo(CreatePostViewRoute, arguments: title);
      //   }
      // }

      var navigationRoute = deepLink.queryParameters['route'];

      var params = deepLink.queryParameters['params'];
      if (params != null) {
        _navigationService.navigateTo(navigationRoute, arguments: params);
      }
    }
  }

  Future<String> createFirstPostLink(String title) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://flutterstack.page.link',
      link: Uri.parse('https://www.flutterstack.io/post?title=$title'),
      androidParameters: AndroidParameters(
        packageName: 'com.filledstacks.compound',
      ),
      // NOT ALL ARE REQUIRED ===== HERE AS AN EXAMPLE =====
      iosParameters: IosParameters(
        bundleId: 'com.example.ios',
        minimumVersion: '1.0.1',
        appStoreId: '123456789',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'example-promo',
        medium: 'social',
        source: 'orkut',
      ),
      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
        providerToken: '123456',
        campaignToken: 'example-promo',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Example of a Dynamic Link',
        description: 'This link works whether app is installed or not!',
      ),
    );

    final Uri dynamicUrl = await parameters.buildUrl();

    return dynamicUrl.toString();
  }  
}