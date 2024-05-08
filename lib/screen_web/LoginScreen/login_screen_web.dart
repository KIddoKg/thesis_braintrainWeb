import 'dart:convert';
import 'dart:developer';

import 'package:bmeit_webadmin/models/adminModel.dart';
import 'package:bmeit_webadmin/share/share_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import '../../../res/colors.dart';
import '../../helper/appsetting.dart';
import '../../helper/formatter.dart';
import '../../res/styles.dart';
import '../../services/services.dart';
import '../../services/socketClient.dart';
import '../../widget/share_widget.dart';
import '../Dashboard/home_page.dart';

class LoginPage extends StatelessWidget {
  bool isContinues;
  LoginPage({this.isContinues = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _FormSection(
                  isContinues: isContinues,
                ),
                if (!Responsive.isDesktopSmall(context)) _ImageSection(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _FormSection extends StatefulWidget {
  bool isContinues;
  _FormSection({Key? key, required this.isContinues}) : super(key: key);

  @override
  @override
  State<_FormSection> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_FormSection>
    with TickerProviderStateMixin {
  late AnimationController _controllerBlue;
  double _width = 0.0;
  double _height = 0.0;
  bool _isVisible = false;
  TextEditingController fieldUser = TextEditingController();
  TextEditingController fieldPwd = TextEditingController();
  final FocusNode _textNode = FocusNode();
  double padValue = 0;
  bool end = false;
  bool beforeEnd = false;
  bool hasToken = false;
  bool isLoading = false;
  double animate = 0;

  @override
  void initState() {
    super.initState();
    onInit();
    _controllerBlue = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _controllerBlue.forward();

    _controllerBlue.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // custom code here
        setState(() {
          padValue = 30;
          _width = 400;
          _height = MediaQuery.of(context).size.height * .4;
        });
      }
    });
  }

  @override
  dispose() {
    _controllerBlue.dispose(); // you need this
    super.dispose();
  }

  Future<void> checkAnimated() async {
    await Future.delayed(Duration(seconds: 1));
    if (beforeEnd == true) {
      end = true;
      setState(() {});
      await Future.delayed(Duration(seconds: 5));
      if (!mounted) return;
      // Navigator.pushNamedAndRemoveUntil(
      //     context, '/dashborad', (route) => false);
    }
    // await onLogin();
  }

  toggleLoading() {
    if (!mounted) return;
    setState(() {
      isLoading = !isLoading;
    });
  }

  onLogin() async {
    if (onValidate().length > 0) {
      String txt = '';
      onValidate().forEach((e) => txt += '$e\n');

      showAlert(context, 'Thông báo', txt);

      return;
    }
    _width = 10;
    _height = 10;
    beforeEnd = true;
    animate = 45;
    await Future.delayed(Duration(seconds: 5));
    var res = await Services.instance
        .setContext(context)
        .login(fieldUser.text, fieldPwd.text);

    // toggleLoading();

    if (res.isSuccess) {
      if (widget.isContinues) {
        Navigator.pop(context);
        return;
      }

      // if (!DMCLSocket.instance.socket!.connected) {
      //   DMCLSocket.instance.socket!.connect();
      // }

      AdminModel.instance.passwordCache = fieldPwd.text;
      AdminModel.instance.save();
      AppSetting.instance.save();
      print("adkoakdoa: ${AppSetting.instance.accessToken}");
      // DMCLSocket.instance.userConnect(AdminModel.instance);

      FocusManager.instance.primaryFocus?.unfocus();

      // await Future.delayed(const Duration(milliseconds: 250));
      // Fluttertoast.showToast(msg: 'Đang xác minh ...');
      // await Future.delayed(const Duration(seconds: 1));
      //
      // Fluttertoast.cancel();

      // var data = res.cast<AdminModel>();
      // AdminModel? modelAdmin;
      // modelAdmin = data;
      // print(data);
      // Navigator.pushNamed(context, '/tabbar');
      // Navigator.pushAndRemoveUntil(context, ModalRoute.withName('/dashboard'), (route) => true);
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (route) => false);
    }
    if (!res.isSuccess) {
      _width = 400;
      _height = MediaQuery.of(context).size.height * .4;
      end = false;
      beforeEnd = false;
      animate = 0;
      setState(() {});
    }
  }

  void test() {
    _width = 400;
    _height = 370;
    beforeEnd = false;
    end = false;
    setState(() {});
  }

  List<String> onValidate() {
    List<String> errors = [];
    if (fieldUser.text.isEmpty)
      errors.add('Tên đăng nhập không được để trống.');
    if (fieldPwd.text.isEmpty) errors.add('Mật khẩu không được để trống.');
    return errors;
  }

  onInit() async {
    await AppSetting.init();

    // bool isExits = AppSetting.instance.accessToken == "";
    bool isExitsPro = AppSetting.pref.containsKey('@profile');
    // print("rreo${isExits}");
    if (isExitsPro) {
      var user = AppSetting.pref.getString('profile')!;
      log('> Profile: ' + user);
      var userJson = json.decode(user);
      AdminModel.fromJson(userJson);
      var appsetting = json.decode(AppSetting.pref.getString('appsetting')!);
      AppSetting.fromJson(appsetting);

      setState(() {
        hasToken = true;
      });

      log('> SharedPreferences: $user');

      fieldUser.text = AdminModel.instance.phone;
      // DMCLSocket.instance.setContext(context);
      // DMCLSocket.instance.userConnect(AdminModel.instance);
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (route) => false);
    }
    // if(isExits = true && isExitsPro == true){
    // {
    //   Navigator.pushNamedAndRemoveUntil(
    //       context, '/login', (route) => false);
    // }
    // }
    print("adkoakdoa: ${AppSetting.instance.accessToken}");
  }

  onSubmit() async {}
  handleKey(RawKeyEventData key) {
    String _keyCode;
    _keyCode = key.keyLabel.toString(); //keycode of key event (66 is return)
  }

  void _handleSubmitted(String finalinput) {
    setState(() {
      SystemChannels.textInput
          .invokeMethod('TextInput.hide'); //hide keyboard again
      onLogin();
    });
  }

  _buildTextComposer() {
    TextField _textField = TextField(
      controller: fieldPwd,
      obscureText: !_isVisible,
      decoration: InputDecoration(
          suffixIcon: IconButton(
              icon: Icon(
                _isVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isVisible = !_isVisible;
                });
              }),
          border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          filled: true,
          fillColor: HexColor.fromHex("#f6f6f7")),
      onSubmitted: _handleSubmitted,
    );
    FocusScope.of(context).requestFocus(_textNode);
    return RawKeyboardListener(
        focusNode: _textNode,
        onKey: (key) => handleKey(key.data),
        child: Center(
            child: _textField));
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingFragment()
        : SingleChildScrollView(
            child: SlideTransition(
              position:
                  Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset(0.0, 0.0))
                      .animate(_controllerBlue),
              child: FadeTransition(
                opacity: _controllerBlue,
                child: Container(
                  height: (!Responsive.isMobile(context))
                      ? MediaQuery.of(context).size.height
                      : 1000,
                  color: AppColors.primaryColor,
                  width: (!Responsive.isDesktopSmall(context))
                      ? 448
                      : MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .05,
                        ),
                        child: Image.asset(
                          "assets/img/splash_icon.png",
                          width: MediaQuery.of(context).size.width * 9,
                          height: MediaQuery.of(context).size.height * .1,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 25.63,
                              color: AppColors.neutral),
                        ),
                      ),
                      AnimatedCrossFade(
                          firstChild: Center(
                            child: AnimatedPadding(
                              padding: EdgeInsets.only(
                                  top: padValue + animate, bottom: padValue),
                              duration: Duration(seconds: 1),
                              curve: Curves.easeInOut,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 1000),
                                onEnd: checkAnimated,
                                width: _width,
                                height: _height,
                                curve: Curves.bounceInOut,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      bottom: 10
                                  ),
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16.0)),
                                    color: Colors.white,
                                  ),
                                  // width:(!Responsive.isMobileBig(context)) ? MediaQuery.of(context).size.width * 0.9 : 400,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .05,
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .02,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .02,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "Mã Admin",
                                                style: TextStyle(
                                                    fontFamily: "Nunito Sans",
                                                    fontSize: 14,
                                                    color: HexColor.fromHex(
                                                        "#8F92A1")),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .75,
                                                child: TextField(
                                                  controller: fieldUser,
                                                  decoration: InputDecoration(
                                                      border: const OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide.none,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8.0))),
                                                      filled: true,
                                                      fillColor:
                                                          HexColor.fromHex(
                                                              "#f6f6f7")),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 10,
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .02,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .02,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Mật khẩu",
                                                style: TextStyle(
                                                    fontFamily: "Nunito Sans",
                                                    fontSize: 14,
                                                    color: HexColor.fromHex(
                                                        "#8F92A1")),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .75,
                                                child: _buildTextComposer(),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .05,
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .02,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .02,
                                          ),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .75,
                                            height: 44,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.primaryColor),
                                                onPressed: () => {
                                                      onLogin(),
                                                      setState(() {})
                                                    },
                                                child: Text(
                                                  "Đăng nhập",
                                                  style: TextStyle(
                                                      color: AppColors.neutral),
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          secondChild: Padding(
                              padding: EdgeInsets.only(
                                  bottom: padValue, top: padValue),
                              child: ColorLoader3(
                                radius: 10,
                                dotRadius: 6.0,
                              )),
                          crossFadeState: !end
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: Duration(seconds: 1)),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * .05,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            test();
                            showAlert(context, 'Thông báo',
                                'Liên hệ quản lý để lấy thông tin tài khoản.');
                          },
                          child: Container(
                            width: double.infinity,
                            child: const Text(
                              "Quên mật khẩu ?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  togglePasswordVisibility() {}
}

class _ImageSection extends StatefulWidget {
  const _ImageSection({Key? key}) : super(key: key);

  @override
  State<_ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<_ImageSection>
    with TickerProviderStateMixin {
  late AnimationController _controllerPicture;

  @override
  void initState() {
    super.initState();
    _controllerPicture = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _controllerPicture.forward();
  }

  @override
  dispose() {
    _controllerPicture.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
            .animate(_controllerPicture),
        child: FadeTransition(
          opacity: _controllerPicture,
          child: Container(
            color: AppColors.background,
            child: Center(
              child: SvgPicture.asset(
                "assets/svg/manager.svg",
                width: 647,
                height: 602,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
