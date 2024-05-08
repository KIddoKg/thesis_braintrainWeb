import 'dart:io';

import 'package:bmeit_webadmin/routes/app_route.dart';
import 'package:bmeit_webadmin/screen_web/unknowScreen/maintenance_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:socket_io/socket_io.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:flutter/material.dart';
import 'package:bmeit_webadmin/screen_web/Dashboard/home_page.dart';
import 'package:bmeit_webadmin/screen_web/LoginScreen/login_screen_web.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void configureApp() {
  setUrlStrategy(PathUrlStrategy());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyB07CEMFi2T5BUX6ZGz9vedMQLWJLxh22E",
          authDomain: "braintrain-62f15.firebaseapp.com",
          databaseURL: "https://braintrain-62f15-default-rtdb.asia-southeast1.firebasedatabase.app",
          projectId: "braintrain-62f15",
          storageBucket: "braintrain-62f15.appspot.com",
          messagingSenderId: "183795384114",
          appId: "1:183795384114:web:3450c5a21ca4c03ba9e12b",
          measurementId: "G-7WVEVKFR83"
      ));
  HttpOverrides.global = MyHttpOverrides();
  configureApp();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DBRef = FirebaseDatabase.instance.ref(); // lắng nghe sự thay đổi của database real time
  bool stopServer = false;
  // This widget is the root of your application.
  Future<void> readData() async {
    await DBRef.child("BaoTri").onValue.listen((DatabaseEvent event) {
      final DataSnapshot snapshot = event.snapshot;
      final dynamic data = snapshot.value;
      bool stopValue = data["stop"] ?? false;
      stopServer = stopValue;
      // if(stopValue == true)
      //   Navigator.pushNamed(context, "/");
      setState(() {

      });
      print('Stop value: $stopValue');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    readData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // SfGlobalLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('vi'),
      ],
      locale: const Locale('vi'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch: Colors.green,
        primaryColor: Colors.white,
        useMaterial3: true,
        // scaffoldBackgroundColor: const Color(0xFF2b8293),
      ),
      initialRoute: '/',
      home: stopServer ? MaintenanceScreen():LoginPage(),
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/login': (context) => stopServer ? MaintenanceScreen():LoginPage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/dashboard': (context) => stopServer ? MaintenanceScreen():DashBoard(),
      },
      // routerConfig: _router,
    );
  }
}
// final GoRouter _router = GoRouter(
//   routes: <RouteBase>[
//     GoRoute(
//       path: '/',
//       builder: (BuildContext context, GoRouterState state) {
//         return  LoginPage();
//       },
//       routes: <RouteBase>[
//         GoRoute(
//           path: 'dashboard',
//           builder: (BuildContext context, GoRouterState state) {
//             return  DashBoard();
//           },
//         ),
//       ],
//     ),
//   ],
// );
