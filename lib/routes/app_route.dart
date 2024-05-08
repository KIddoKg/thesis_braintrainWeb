
import 'package:bmeit_webadmin/screen_web/Dashboard/home_page.dart';

import '../screen_web/LoginScreen/login_screen_web.dart';

class RouteGenerator {
  const RouteGenerator._();

  //! general routes
  // static const signin = '/signin';
  // static const login = '/';
  static const dashboard = '/dashboard';


  static final routes = {
    // signin: (context) =>  LoginPage(),
    // login: (context) =>  LoginPage(),
    dashboard: (context) =>  DashBoard(),
  };
}
