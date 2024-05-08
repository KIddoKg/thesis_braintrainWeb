
import 'package:bmeit_webadmin/screen_web/Dashboard/home_page.dart';
import 'package:bmeit_webadmin/screen_web/LoginScreen/login_screen_web.dart';

class RouteGenerator {
  const RouteGenerator._();
  static const login_screen = '/';
  static const dash_screen = '/dashboard';


  static final routes = {
    login_screen: (context) => LoginPage(),
    dash_screen: (context) => DashBoard(),

  };
}
