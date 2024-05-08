import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class AppSetting {
  String accessToken ="";
  String refreshToken = "";
  bool? enableAuthenLocal = true;

  AppSetting._internal();
  static AppSetting _instance = AppSetting._internal();
  static AppSetting get instance => _instance;
  AppLifecycleState? appLifecycleState;
  static late SharedPreferences pref;

  factory AppSetting.fromJson(Map<String, dynamic> json) {
    _instance.accessToken = json['access_token'] ?? "";
    _instance.refreshToken = json['refresh_token'] ?? "";
    _instance.enableAuthenLocal = json['enableAuthenLocal'] ?? false;
    return _instance;
  }
  factory AppSetting.loadConfig(Map<String, dynamic> json) {
    // _instance.isAcceptPushNoti = json['isAcceptPushNoti'] ?? false;

    _instance.accessToken = json['access_token'] ?? '';
    _instance.enableAuthenLocal = json['enableAuthenLocal'] ?? false;

    log('appsetting.load $json');
    return _instance;
  }
  Map<String, dynamic> toJson() {
    return {
      "access_token": _instance.accessToken,
      "refresh_token": _instance.refreshToken,
      "enableAuthenLocal": _instance.enableAuthenLocal,
    };
  }

  static init() async {

    pref = await SharedPreferences.getInstance();

    var hasConfig = pref.containsKey('@appSetting');
    if (hasConfig) {
      var json = pref.getString('@appSetting');
      var objJson = jsonDecode(json!);
      AppSetting.loadConfig(objJson);
    }

  }
  void save() async {
    var json = _instance.toJson();
    pref.setString('@appSetting', jsonEncode(json));

    log('appsetting.save $json');
  }
  void reset() {
    pref.remove("@profile");
    print("reset");
    _instance.accessToken = '';
    _instance.refreshToken = '';

    log('AppSetting.reset clean profileLocal');
  }

}