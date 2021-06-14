

class Routes {
  static const String SplashScreen = '/';
  static const String LandingPage = '/landing-page';
  static const String Dashboard = '/dashboard-view';
  static const String AdDetailScreen = '/ad-details/:adId';

  static String adDetailScreen({@required dynamic adId}) => '/ad-details/$adId';
  static const String ChatHome = '/chats-screen-new';
  static const String SignInPage = '/sign-in-page-main';
  static const String MyProfile = '/my-profile-view';
  static const String CreateAds = '/create-ad-simple-view';
  static const String SimpleCreateAdView = '/simple-add-car-view';
  static const String PageNotFound = '/404';
  static const String MyGarage = '/my-garage-page';
  static const String ReportScreen = '/reportScreen';
  static const String ResourcesScreen = '/resourcesScreen';
  static const String SearchPage = '/car-search-form-view';
  static const String ChatPage = '/chat-screen-new';
  static const String FullImageView = '/full-screen-image-view';
  static const String PanaromaImageView = '/panorama-image-viewer';
  static const String CommentsPage = '/comments-screen';
  static const String DocumentHomePage = '/document-home-page';
  static const String LogoutPage = '/logout-screen';
  static const String OnboardingPage = '/onboarding-page';
  static const String PlateNumberSearchPage = '/plate-number-search-page';
  static const String CompareCarsView = '/compare-cars-view';
  static const String BeaconListingView = '/beacon-listing-view';
  static const String SearchResultPage = '/car-search-result-page';
  static const String FolderHomePage = '/folder-home-page';
  static const String AddFolderView = '/add-folder-view';
  static const String FavouriteDocList = '/FavouriteDocList';
  static const String SearchAdvancePage = '/SearchAdvancePage';
  static const String SomeoneProfileView = '/SomeoneProfileView';
  static const String SomeoneReviewsView = '/SomeoneReviewsView';
  static const String EditProfileView = '/EditProfileView';
  static const String BadgesView = '/BadgesView';
  static const String MyWalletView = '/MyWalletView';
  static const String MyReviewsView = '/MyReviewsView';
  static const String SettingsView = '/SettingsView';
  static const String UserVerficationView = '/UserVerficationView';
  static const String ContactUsView = '/ContactUsView';
  static const String SecurityLoginView = '/SecurityLoginView';
  static const String DiscussionView = '/DiscussionView';

  static const all = <String>{
    SplashScreen,
    LandingPage,
    Dashboard,
    AdDetailScreen,
    ChatHome,
    SignInPage,
    MyProfile,
    CreateAds,
    SimpleCreateAdView,
    PageNotFound,
    MyGarage,
    ReportScreen,
    SearchPage,
    ResourcesScreen,
    ChatPage,
    FullImageView,
    PanaromaImageView,
    CommentsPage,
    DocumentHomePage,
    LogoutPage,
    OnboardingPage,
    PlateNumberSearchPage,
    CompareCarsView,
    BeaconListingView,
    SearchResultPage,
    FolderHomePage,
    AddFolderView,
    FavouriteDocList,
    SearchAdvancePage,
    SomeoneProfileView,
    SomeoneReviewsView,
    EditProfileView,
    BadgesView,
    MyWalletView,
    MyReviewsView,
    SettingsView,
    UserVerficationView,
    ContactUsView,
    SecurityLoginView,
    DiscussionView,
  };
}

class Router extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.splashScreen, page: SplashScreen),
    RouteDef(Routes.Dashboard, page: DashboardView),
    RouteDef(Routes._adDetailScreen, page: AdDetailScreen),
    RouteDef(Routes.ChatHome, page: ChatHome),
    RouteDef(Routes.SignInPage, page: SignInPageMain),
    RouteDef(Routes.MyProfile, page: MyProfileView),
    RouteDef(Routes.createAds, page: CreateAdSimpleView),
    RouteDef(Routes.simpleCreateAdView, page: SimpleAddCarView),
    RouteDef(Routes.pageNotFound, page: PageNotFound),
    RouteDef(Routes.myGarage, page: MyGaragePage),
    RouteDef(Routes.ReportScreen, page: ReportScreen),
    RouteDef(Routes.resourcesScreen, page: ResourcesScreen),
    RouteDef(Routes.SearchPage, page: SearchPageMainWidget),
    RouteDef(Routes.ChatPage, page: ChatPage),
    RouteDef(Routes.FullImageView, page: FullScreenImageView),
    RouteDef(Routes.PanaromaImageView, page: PanoramaImageViewer),
    RouteDef(Routes.CommentsPage, page: CommentsScreen),
    RouteDef(Routes.DocumentHomePage, page: DocumentHomePage),
    RouteDef(Routes.LogoutPage, page: LogoutScreen),
    RouteDef(Routes.OnboardingPage, page: Onboarding),
    RouteDef(Routes.PlateNumberSearchPage, page: PlateNumberSearchPage),
    RouteDef(Routes.CompareCarsView, page: CompareCarsView),
    RouteDef(Routes.BeaconListingView, page: BeaconListingView),
    RouteDef(Routes.FolderHomePage, page: FolderHomePage),
    RouteDef(Routes.AddFolderView, page: AddFolderView),
    RouteDef(Routes.FavouriteDocList, page: FavouriteDocList),
    RouteDef(Routes.SearchAdvancePage, page: SearchAdvancePage),
    RouteDef(Routes.SomeoneProfileView, page: SomeoneProfileView),
    RouteDef(Routes.SomeoneReviewsView, page: SomeoneReviewsView),
    RouteDef(Routes.EditProfileView, page: EditProfileView),
    RouteDef(Routes.BadgesView, page: BadgesView),
    RouteDef(Routes.MyWalletView, page: MyWalletView),
    RouteDef(Routes.MyReviewsView, page: MyReviewsView),
    RouteDef(Routes.SettingsView, page: SettingsView),
    RouteDef(Routes.UserVerficationView, page: UserVerficationView),
    RouteDef(Routes.ContactUsView, page: ContactUsView),
    RouteDef(Routes.SecurityLoginView, page: SecurityLoginView),
    RouteDef(Routes.DiscussionView, page: DiscussionView),
  ];

  @override
  Map<Type, StackedRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, StackedRouteFactory>{
    SplashScreen: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SplashScreen(),
        settings: data,
      );
    },
    DashboardView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => DashboardView(),
        settings: data,
      );
    },
    AdDetailScreen: (data) {
      final args = data.getArgs<AdDetailScreenArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => AdDetailScreen(
          key: args.key,
          userId: args.userId,
          username: args.username,
          adId: args.adId,
        ),
        settings: data,
      );
    },
    ChatHome: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ChatHome(),
        settings: data,
      );
    },
    SignInPageMain: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SignInPageMain(),
        settings: data,
      );
    },
    MyProfileView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => MyProfileView(),
        settings: data,
      );
    },
    CreateAdSimpleView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => CreateAdSimpleView(),
        settings: data,
      );
    },
    SimpleAddCarView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const SimpleAddCarView(),
        settings: data,
      );
    },
    PageNotFound: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => PageNotFound(),
        settings: data,
      );
    },
    MyGaragePage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => MyGaragePage(),
        settings: data,
      );
    },

    SearchPageMainWidget: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SearchPageMainWidget(),
        settings: data,
      );
    }, // SearchAdvancePage
    SearchAdvancePage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SearchAdvancePage(),
        settings: data,
      );
    },
    ChatPage: (data) {
      final args = data.getArgs<ChatScreenNewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => ChatPage(
          //TODO: config first msg on click of add, and config opening chat page on notification click
          key: args.key,
          chatData: args.chatData,
          forwardData: args.forwardData,
        ),
        settings: data,
      );
    },
    FullScreenImageView: (data) {
      final args = data.getArgs<FullScreenImageViewArguments>(
        orElse: () => FullScreenImageViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => FullScreenImageView(
          key: args.key,
          title: args.title,
          imageList: args.imageList,
          currentIndex: args.currentIndex,
        ),
        settings: data,
      );
    },
    PanoramaImageViewer: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => PanoramaImageViewer(),
        settings: data,
      );
    },
    CommentsScreen: (data) {
      final args = data.getArgs<CommentsScreenArguments>(
        orElse: () => CommentsScreenArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => CommentsScreen(
          key: args.key,
          animation: args.animation,
          adId: args.adId,
          adImageUrl: args.adImageUrl,
          sellerId: args.sellerId,
        ),
        settings: data,
      );
    },
    DocumentHomePage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => DocumentHomePage(),
        settings: data,
      );
    },
    LogoutScreen: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => LogoutScreen(),
        settings: data,
      );
    },
    Onboarding: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => Onboarding(),
        settings: data,
      );
    },
    PlateNumberSearchPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => PlateNumberSearchPage(),
        settings: data,
      );
    },
    CompareCarsView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => CompareCarsView(),
        settings: data,
      );
    },
    BeaconListingView: (data) {
      final args = data.getArgs<BeaconListingViewArguments>(
        orElse: () => BeaconListingViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => BeaconListingView(key: args.key),
        settings: data,
      );
    },
    FolderHomePage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => FolderHomePage(),
        settings: data,
      );
    },
    AddFolderView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => AddFolderView(),
        settings: data,
      );
    },
    FavouriteDocList: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => FavouriteDocList(),
        settings: data,
      );
    },
    SomeoneProfileView: (data) {
      final args = data.getArgs<SomeoneProfileViewArguments>(
        orElse: () => SomeoneProfileViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => SomeoneProfileView(someoneUid: args.someoneUid),
        settings: data,
      );
    },
    SomeoneReviewsView: (data) {
      final args = data.getArgs<SomeoneReviewsViewArguments>(
        orElse: () => SomeoneReviewsViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => SomeoneReviewsView(
          someoneUid: args.someoneUid,
          someoneName: args.someoneName,
          adId: args.adId,
        ),
        settings: data,
      );
    },
    EditProfileView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => EditProfileView(),
        settings: data,
      );
    },
    BadgesView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => BadgesView(),
        settings: data,
      );
    },
    MyWalletView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => MyWalletView(),
        settings: data,
      );
    },
    MyReviewsView: (data) {
      final args = data.getArgs<MyReviewsViewArguments>(
        orElse: () => MyReviewsViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => MyReviewsView(
          userUid: args.userUid,
          userName: args.userName,
          isFromSellerPage: args.isFromSellerPage,
          //  comments: args.comments,
        ),
        settings: data,
      );
    },
    SettingsView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SettingsView(),
        settings: data,
      );
    },
    UserVerficationView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => UserVerficationView(),
        settings: data,
      );
    },
    ContactUsView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ContactUsView(),
        settings: data,
      );
    },
    SecurityLoginView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SecurityLoginView(),
        settings: data,
      );
    },
    DiscussionView: (data) {
      final args = data.getArgs<DiscussionViewArguments>(
        orElse: () => DiscussionViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => DiscussionView(
          key: args.key,
          adId: args.adId,
          adImageUrl: args.adImageUrl,
          sellerId: args.sellerId,
          adTitle: args.adTitle,
          adPrice: args.adPrice,
          adDistance: args.adDistance,
        ),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************
/// AdDetailScreen arguments holder class
class AdDetailScreenArguments {
  final Key key;
  final String userId;
  final String username;
  final String adId;

  AdDetailScreenArguments({this.key, this.userId, this.username, @required this.adId});
}

/// ChatScreenNew arguments holder class
class ChatScreenNewArguments {
  final Key key;
  final ChatSessionModel chatData;
  final String notificationImageUrl;
  final String sellerId;
  final bool isFirst;
  final MsgContentModel forwardData;

  ChatScreenNewArguments({
    this.key,
    @required this.chatData,
    this.notificationImageUrl,
    this.sellerId,
    @required this.isFirst,
    this.forwardData,
  });
}

/// FullScreenImageView arguments holder class
class FullScreenImageViewArguments {
  final Key key;
  final String title;
  final List<String> imageList;
  final int currentIndex;

  FullScreenImageViewArguments({this.key, this.title, this.imageList, this.currentIndex});
}

/// CommentsScreen arguments holder class
class CommentsScreenArguments {
  final Key key;
  final Animation<dynamic> animation;
  final String adId;
  final String adImageUrl;
  final String sellerId;

  CommentsScreenArguments({this.key, this.animation, this.adId, this.adImageUrl, this.sellerId});
}

/// BeaconListingView arguments holder class
class BeaconListingViewArguments {
  final Key key;

  BeaconListingViewArguments({this.key});
}

class UploadFolderViewArguments {
  final String folderName;
  final int folderColor;

  UploadFolderViewArguments({this.folderName, this.folderColor});
}

class SomeoneProfileViewArguments {
  final String someoneUid;

  SomeoneProfileViewArguments({this.someoneUid});
}

class SomeoneReviewsViewArguments {
  final String someoneUid;
  final String someoneName;

  // final List<VehicleCommentSessionModel> comments;
  final String adId;

  SomeoneReviewsViewArguments({this.someoneName, this.someoneUid, this.adId});
}

class MyReviewsViewArguments {
  final String userUid;
  final String userName;
  final bool isFromSellerPage;

//  final List<VehicleCommentSessionModel> comments;

  MyReviewsViewArguments({
    this.isFromSellerPage = false,
    this.userName,
    this.userUid,
    //  this.comments
  });
}

class DiscussionViewArguments {
  final Key key;
  final String adId;
  final String adImageUrl;
  final String sellerId;
  final String adTitle;
  final String adPrice;
  final String adDistance;

  DiscussionViewArguments({this.key, this.adId, this.adImageUrl, this.sellerId, this.adTitle, this.adPrice, this.adDistance});
}