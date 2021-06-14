

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchaseConnection.enablePendingPurchases();
  await Firebase.initializeApp();
//firebase local emulator
  // FirebaseFirestore.instance.settings = Settings(
  //     host: 'localhost:8585', sslEnabled: false, persistenceEnabled: false);
  //
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = (error) => flutterErrorHandler(error);
  }
  setupLocator();
  setupDialogUi();
  pushNotificationService.initialise();
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    debugPrint('runZonedGuarded: Caught error in my root zone.');
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  });
}

void flutterErrorHandler(FlutterErrorDetails details) {
  FlutterError.dumpErrorToConsole(details);
  Zone.current.handleUncaughtError(details.exception, details.stack);
}

class MyApp extends StatelessWidget {
  final botToastBuilder = BotToastInit(); //1. call BotToastInit
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MyUser(),
        ),
        ChangeNotifierProvider(
          create: (_) => AvatarProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ResourcesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AspcsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ToolsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Autoly',
        theme: ThemeData(
          appBarTheme: AppBarTheme(color: Color(0xff0fa2cf),),
          scaffoldBackgroundColor: Colors.white,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: TextTheme(subtitle1: TextStyle(color: Colors.black, fontSize: 21,family:'')),
        ),
        navigatorObservers: [BotToastNavigatorObserver()],
        home: Home(),
        builder: (context, child) {
          child = ExtendedNavigator.builder(
              navigatorKey: locator<NavigationService>().navigatorKey,
              initialRoute: router.Routes.splashScreen,
              router: router.Router(),
              observers: [locator<AnalyticsService>().getAnalyticsObserver()],
              builder: (context, extendedNav) => extendedNav)(context, child); //do something
          child = botToastBuilder(context, child);
          return child;
        },
      ),
    );
  }
}