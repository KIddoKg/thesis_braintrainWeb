import 'dart:async';

import 'package:bmeit_webadmin/screen_web/Dashboard/statistical_page/total_report.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' show pi;

import 'package:flutter_svg/svg.dart';
import 'package:bmeit_webadmin/screen_web/Dashboard/employer_page/employer_all_page.dart';
import 'package:bmeit_webadmin/screen_web/Dashboard/statistical_page/statistical_main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notification_center/notification_center.dart';

import '../../helper/appsetting.dart';
import '../../helper/formatter.dart';
import '../../models/menu_modal.dart';
import '../../res/colors.dart';
import '../../res/styles.dart';
import '../../services/services.dart';
import '../../services/socketClient.dart';
import '../../share/share_widget.dart';
import '../../widget/share_widget.dart';
import '../test.dart';
import '../testhome.dart';

// import 'employer_page/demo.dart';
import '../unknowScreen/request.dart';
import 'employer_page/employer_dis_page.dart';
import 'employer_page/employer_onl_page.dart';
import 'historyDeal_page/history_deal.dart';
import 'historyDeal_page/setting_gameAT1.dart';

class ShowSharedValue {
  final String appDataKey;

  ShowSharedValue(this.appDataKey);

  int getValue(BuildContext context) {
    final int value =
        SharedAppData.getValue<String, int>(context, appDataKey, () => 0);
    return value;
  }
}

class DashBoard extends StatefulWidget {
  DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  bool expandMenu = false;
  double rotate = 0.0;
  double rotateTwo = 0.0;
  double rotateThree = 0.0;
  late AnimationController _controller;
  late AnimationController _controllerList;
  late AnimationController _controllerListTwo;
  late AnimationController _controllerListThree;
  bool shouldShowStatisticalPage = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<MenuModel> menu = [
    // MenuModel(icon: 'assets/svg/personOnl.svg', title: "tài khoản online"),
    MenuModel(icon: 'assets/svg/personTotal.svg', title: "Tất cả tài khoản"),
    MenuModel(icon: 'assets/svg/personBlock.svg', title: "Tài khoản theo dõi"),
    MenuModel(
        icon: 'assets/svg/personBlock.svg', title: "Tài khoản không hoạt động"),
    MenuModel(
        icon: 'assets/svg/personBlock.svg', title: "Tài khoản yêu cầu xoá"),
  ];
  List<MenuModel> menuTwo = [
    MenuModel(icon: 'assets/svg/report.svg', title: "Thống kê bảng điểm"),
    // MenuModel(icon: 'assets/svg/total.svg', title: "Tổng Doanh thu"),
    // MenuModel(icon: 'assets/svg/internet.svg', title: "Internet/truyền hình"),
    // MenuModel(icon: 'assets/svg/waterBill.svg', title: "Đóng điện nước"),
    // MenuModel(icon: 'assets/svg/phone.svg', title: "Nạp điện thoại"),
    // MenuModel(icon: 'assets/svg/card.svg', title: "Nạp thẻ game"),
    // MenuModel(icon: 'assets/svg/phone.svg', title: "Thẻ cào điện thoại"),
    // MenuModel(icon: 'assets/svg/electricBill.svg', title: "Đóng tiền điện"),
    // MenuModel(icon: 'assets/svg/viettel.svg', title: "Nạp tiền Viettel Money"),
    // MenuModel(icon: 'assets/svg/more.svg', title: "Thu Hộ khác"),
  ];
  List<MenuModel> menuThree = [
    // MenuModel(icon: 'assets/svg/profile.svg', title: "Test"),
    MenuModel(icon: 'assets/svg/receipt.svg', title: "Trò chơi Ngôn ngữ 4"),
    MenuModel(icon: 'assets/svg/receipt.svg', title: "Trò chơi Tập trung 1"),
    // MenuModel(icon: 'assets/svg/profile.svg', title: "Đóng điện nước"),
  ];
  var tabViews = [
    EmployerAllPage(
      first: false,
    ),
    EmployerDisPage(),
    NotiScreen(),
    NotiScreen(),
    NotiScreen(),
  ];
  var tabViewsTrue = [
    EmployerAllPage(
      first: true,
    ),
    EmployerDisPage(),
    NotiScreen(),
    NotiScreen(),
    NotiScreen(),
  ];
  List<bool> isLoadingStates = [];
  var tabViewsTwo = [
    TotalReport(),
  ];

  List<ChartService> ChartType = [
    ChartService.total,
    ChartService.internet,
    ChartService.water,
    ChartService.phone,
    ChartService.card,
    ChartService.phoneCard,
    ChartService.electric,
    ChartService.viettelMoney,
    ChartService.other,
  ];
  var tabViewsThree = [HistoryDeal(),SettingATOne()];

  bool test = false;
  bool testTwo = false;
  bool testThree = false;
  bool small = true;
  bool smallTwo = false;
  bool smallThree = false;
  bool showBar = false;

  int selected = 0;
  int selectedTwo = -1;
  int selectedThree = -1;
  bool fristNe = false;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _controllerList = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _controllerListTwo = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _controllerListThree =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    Timer(Duration(milliseconds: 300), () => _controllerList.forward());
    _controllerList.forward();
    Timer(Duration(milliseconds: 1000), () => openFirst());
    Timer(Duration(milliseconds: 1300), () => openSecond());
    Timer(Duration(milliseconds: 1500), () => openThird());
    super.initState();
  }

  Future<void> openFirst() async {
    if (mounted) {
      small = false;
      expandMenu = true;
      setState(() {});
    }
  }

  Future<void> openSecond() async {
    if (mounted) {
      showBar = true;
      setState(() {});
    }
  }

  Future<void> openThird() async {
    if (mounted) {
      test = true;
      setState(() {});
    }
  }

  void setNew() {
    SharedAppData.setValue<String, int?>(context, 'deals', 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerList.dispose();
    _controllerListTwo.dispose();
    _controllerListThree.dispose();
    super.dispose();
  }

  void intS() {
    final showValue = ShowSharedValue('deals');
    int value = showValue.getValue(context);
    int x = value;
    print(value);
    if (value == 1) {
      selected = -1;
      selectedTwo = 0;
      selectedThree = -1;
      x = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    intS();

    print(MediaQuery.of(context).size.width);
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Row(
            children: [
              AnimatedContainer(
                  width: !small
                      ? 276
                      : showBar == true
                          ? 95
                          : 0,
                  // height: MediaQuery.of(context).size.height,
                  color: AppColors.primaryColor,
                  duration: Duration(milliseconds: 100),
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: showBar
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 40,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 50,
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                small = !small;

                                                setState(() {});
                                                if (expandMenu == false) {
                                                  _controller.forward();
                                                  expandMenu = true;
                                                } else {
                                                  _controller.reverse();
                                                  expandMenu = false;
                                                }
                                                NotificationCenter().notify(
                                                    'naviSmall',
                                                    data: small);
                                              },
                                              child: AnimatedIcon(
                                                icon: AnimatedIcons.arrow_menu,
                                                color: Colors.white,
                                                progress: _controller,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: Duration(milliseconds: 100),
                                          width: small == false ? 170 : 0,
                                          child: Image.asset(
                                            "assets/img/splash_icon.png",
                                            width: small == false ? 170 : 0,
                                            // height: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height - 140,
                                  child: SingleChildScrollView(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(6.0),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Material(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      test = !test;
                                                      if (test == true)
                                                        Timer(
                                                            Duration(
                                                                milliseconds:
                                                                    100),
                                                            () =>
                                                                _controllerList
                                                                    .forward());
                                                      if (test == false)
                                                        _controllerList
                                                            .reverse();

                                                      rotate += 1 / 2;
                                                      setState(() {});
                                                      print(test);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 15.0,
                                                              right: 10,
                                                              bottom: 15,
                                                              left: 5),
                                                      width: double.infinity,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 8,
                                                            child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Row(
                                                                  children: [
                                                                    AnimatedContainer(
                                                                        height: test
                                                                            ? 30
                                                                            : 0,
                                                                        duration: Duration(
                                                                            milliseconds:
                                                                                500),
                                                                        child:
                                                                            VerticalDivider(
                                                                          color:
                                                                              Colors.white,
                                                                          thickness:
                                                                              3,
                                                                        )),
                                                                    SvgPicture
                                                                        .asset(
                                                                      'assets/svg/person.svg',
                                                                      width: 25,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    if (small ==
                                                                        false)
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                    // if (small == false)
                                                                    Flexible(
                                                                      child: AnimatedSwitcher(
                                                                          duration: Duration(milliseconds: 100),
                                                                          reverseDuration: const Duration(milliseconds: 100),
                                                                          child: small == false
                                                                              ? Text(
                                                                                  "Thông tin tài khoản}",
                                                                                  style: TextStyle(fontSize: small == false ? 16 : 0, color: Colors.white, fontWeight: test ? FontWeight.w600 : FontWeight.normal),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                )
                                                                              : SizedBox()),
                                                                    ),
                                                                  ],
                                                                )),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child:
                                                                  AnimatedRotation(
                                                                turns: rotate +
                                                                    0.5,
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        500),
                                                                child: Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                ExpandedSection(
                                                  expand: test,
                                                  child: Container(
                                                    width: double.infinity,
                                                    color:
                                                        AppColors.primaryColor,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            left: 15,
                                                            right: 15,
                                                            bottom: 25),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        for (var i = 0;
                                                            i < menu.length;
                                                            i++)
                                                          buildListOne(i),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(6.0),
                                              ),
                                              color: Colors.transparent,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Material(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      testTwo = !testTwo;
                                                      if (testTwo == true)
                                                        Timer(
                                                            Duration(
                                                                milliseconds:
                                                                    300),
                                                            () =>
                                                                _controllerListTwo
                                                                    .forward());
                                                      if (testTwo == false)
                                                        _controllerListTwo
                                                            .reverse();
                                                      rotateTwo += 1 / 2;
                                                      setState(() {});
                                                      print(testTwo);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 15.0,
                                                              right: 10,
                                                              bottom: 15,
                                                              left: 5),
                                                      width: double.infinity,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 8,
                                                            child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Row(
                                                                  children: [
                                                                    AnimatedContainer(
                                                                        height: testTwo
                                                                            ? 30
                                                                            : 0,
                                                                        duration: Duration(
                                                                            milliseconds:
                                                                                500),
                                                                        child:
                                                                            VerticalDivider(
                                                                          color:
                                                                              Colors.white,
                                                                          thickness:
                                                                              3,
                                                                        )),
                                                                    SvgPicture
                                                                        .asset(
                                                                      'assets/svg/chart.svg',
                                                                      color: Colors
                                                                          .white,
                                                                      width: 25,
                                                                    ),
                                                                    if (small ==
                                                                        false)
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                    Flexible(
                                                                      child: AnimatedSwitcher(
                                                                          duration: Duration(milliseconds: 100),
                                                                          reverseDuration: const Duration(milliseconds: 100),
                                                                          child: small == false
                                                                              ? Text(
                                                                                  "Thống kê",
                                                                                  style: TextStyle(fontSize: small == false ? 16 : 0, color: Colors.white, fontWeight: testTwo ? FontWeight.w600 : FontWeight.normal),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                )
                                                                              : SizedBox()),
                                                                    ),
                                                                  ],
                                                                )),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child:
                                                                  AnimatedRotation(
                                                                turns:
                                                                    rotateTwo,
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        500),
                                                                child: Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                ExpandedSection(
                                                  expand: testTwo,
                                                  child: Container(
                                                    width: double.infinity,
                                                    color:
                                                        AppColors.primaryColor,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            left: 15,
                                                            right: 15,
                                                            bottom: 25),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        for (var i = 0;
                                                            i < menuTwo.length;
                                                            i++)
                                                          buildListTwo(i),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(6.0),
                                              ),
                                              color: Colors.transparent,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Material(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      rotateThree += 1 / 2;
                                                      testThree = !testThree;
                                                      if (testThree == true)
                                                        Timer(
                                                            Duration(
                                                                milliseconds:
                                                                    300),
                                                            () =>
                                                                _controllerListThree
                                                                    .forward());
                                                      if (testThree == false)
                                                        _controllerListThree
                                                            .reverse();
                                                      setState(() {});
                                                      print(testThree);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 15.0,
                                                              right: 10,
                                                              bottom: 15,
                                                              left: 5),
                                                      width: double.infinity,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 8,
                                                            child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Row(
                                                                  children: [
                                                                    AnimatedContainer(
                                                                        height: testThree
                                                                            ? 30
                                                                            : 0,
                                                                        duration: Duration(
                                                                            milliseconds:
                                                                                500),
                                                                        child:
                                                                            VerticalDivider(
                                                                          color:
                                                                              Colors.white,
                                                                          thickness:
                                                                              3,
                                                                        )),
                                                                    SvgPicture
                                                                        .asset(
                                                                      'assets/svg/receiptTotal.svg',
                                                                      width: 25,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    if (small ==
                                                                        false)
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                    Flexible(
                                                                      child: AnimatedSwitcher(
                                                                          duration: Duration(milliseconds: 100),
                                                                          reverseDuration: const Duration(milliseconds: 100),
                                                                          child: small == false
                                                                              ? Text(
                                                                                  "Cài đặt trò chơi",
                                                                                  style: TextStyle(fontSize: small == false ? 16 : 0, color: Colors.white, fontWeight: testThree ? FontWeight.w600 : FontWeight.normal),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                )
                                                                              : SizedBox()),
                                                                    ),
                                                                  ],
                                                                )),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child:
                                                                  AnimatedRotation(
                                                                turns:
                                                                    rotateThree,
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        500),
                                                                child: Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                ExpandedSection(
                                                  expand: testThree,
                                                  child: Container(
                                                    width: double.infinity,
                                                    color:
                                                        AppColors.primaryColor,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            left: 15,
                                                            right: 15,
                                                            bottom: 25),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        for (var i = 0;
                                                            i <
                                                                menuThree
                                                                    .length;
                                                            i++)
                                                          buildListThree(i),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 16, left: 8, right: 8),
                                  child: Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(6.0),
                                        ),
                                        color: Colors.transparent,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Material(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            color: Colors.white,
                                            child: InkWell(
                                              onTap: () {
                                                showAlert(context, 'Thông báo',
                                                    'Bạn có muốn đăng xuất ?',
                                                    actionAndroids: [
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            logOut();
                                                          },
                                                          child: const Text(
                                                              'Đồng ý')),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text('Hủy'))
                                                    ]);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                width: double.infinity,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 8,
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/svg/logout.svg',
                                                                width: 25,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              if (small ==
                                                                  false)
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                              Flexible(
                                                                child: AnimatedSwitcher(
                                                                    duration: Duration(milliseconds: 100),
                                                                    reverseDuration: const Duration(milliseconds: 100),
                                                                    child: small == false
                                                                        ? Text(
                                                                            "Đăng xuất",
                                                                            style: TextStyle(
                                                                                fontSize: small == false ? 16 : 0,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w600),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          )
                                                                        : SizedBox()),
                                                              ),
                                                            ],
                                                          )),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: AnimatedRotation(
                                                          turns: !small
                                                              ? 0.75
                                                              : 0.25,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  500),
                                                          child: Icon(
                                                            Icons
                                                                .keyboard_arrow_down,
                                                            color: Colors.black,
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              color: AppColors.primaryColor,
                            ))),
              Expanded(
                flex: 8,
                child: (() {
                  if (selectedTwo < 0 && selectedThree < 0) {
                    if (showBar == true) {
                      return tabViewsTrue[selected];
                    } else
                      return tabViews[selected];
                  } else if (selected < 0 && selectedThree < 0) {
                    return tabViewsTwo[selectedTwo];
                  } else if (selectedTwo < 0 && selected < 0) {
                    return tabViewsThree[selectedThree];
                  } else {
                    return Container();
                  }
                })(),
              ),
              // `if (!Responsive.isMobile(context))
              //    Expanded(
              //     flex: 4,
              //     child: Text("hello"),
              //   ),`
            ],
          ),
        ));
  }

  Widget buildListOne(int i) {
    double _listStart = 0.1 * i;
    double _listEnd = _listStart + 0.4;

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(2, 0),
        end: Offset(0, 0),
      ).animate(
        CurvedAnimation(
          parent: _controllerList,
          curve: Interval(
            _listStart,
            _listEnd,
            curve: Curves.ease,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: _controllerList,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(6.0),
            ),
            color: selected == i
                ? Theme.of(context).primaryColor
                : Colors.transparent,
          ),
          child: InkWell(
            onTap: () {
              // getData();
              selectedThree = -1;
              selectedTwo = -1;

              SharedAppData.setValue<String, int?>(context, 'deals', 2);

              setState(() {
                selected = i;
              });
            },
            child: Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: SvgPicture.asset(
                    width: 25,
                    menu[i].icon,
                    // Make sure menu[i].icon contains the correct asset path
                    color: selected == i ? Colors.black : Colors.white,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 100),
                        reverseDuration: const Duration(milliseconds: 100),
                        child: small == false
                            ? Text(
                                menu[i].title,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selected == i
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: selected == i
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            : SizedBox()),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListTwo(int i) {
    double _listStart = 0.1 * i;
    double _listEnd = _listStart + 0.1;

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(2, 0),
        end: Offset(0, 0),
      ).animate(
        CurvedAnimation(
          parent: _controllerListTwo,
          curve: Interval(
            _listStart,
            _listEnd,
            curve: Curves.ease,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: _controllerListTwo,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(6.0),
            ),
            color: selectedTwo == i
                ? Theme.of(context).primaryColor
                : Colors.transparent,
          ),
          child: InkWell(
            onTap: () {
              // Navigator.of(context).pop(); // Close the menu drawer if needed
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => DashBoard(select: selected)), // Navigate to the selected screen
              // );
              selected = -1;
              selectedThree = -1;
              shouldShowStatisticalPage = false;
              Future.delayed(Duration(milliseconds: 100), () {
                setState(() {
                  shouldShowStatisticalPage = true;
                });
              });
              setState(() {
                selectedTwo = i;
              });
              // widget.scaffoldKey.currentState!.closeDrawer();
            },
            child: Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: SvgPicture.asset(
                    menuTwo[i].icon,
                    width: 25,
                    color: selectedTwo == i ? Colors.black : Colors.white,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 100),
                        reverseDuration: const Duration(milliseconds: 100),
                        child: small == false
                            ? Text(
                                menuTwo[i].title,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: selectedTwo == i
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: selectedTwo == i
                                        ? FontWeight.w600
                                        : FontWeight.normal),
                                overflow: TextOverflow.ellipsis,
                              )
                            : SizedBox()),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListThree(int i) {
    double _listStart = 0.1 * i;
    double _listEnd = _listStart + 1;

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(2, 0),
        end: Offset(0, 0),
      ).animate(
        CurvedAnimation(
          parent: _controllerListThree,
          curve: Interval(
            _listStart,
            _listEnd,
            curve: Curves.ease,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: _controllerListThree,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(6.0),
            ),
            color: selectedThree == i
                ? Theme.of(context).primaryColor
                : Colors.transparent,
          ),
          child: InkWell(
            onTap: () {
              // Navigator.of(context).pop(); // Close the menu drawer if needed
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => DashBoard(select: selected)), // Navigate to the selected screen
              // );
              selected = -1;
              selectedTwo = -1;
              setState(() {
                selectedThree = i;
              });
              // widget.scaffoldKey.currentState!.closeDrawer();
            },
            child: Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: SvgPicture.asset(
                    menuThree[i].icon,
                    width: 25,
                    color: selectedThree == i ? Colors.black : Colors.white,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 100),
                        reverseDuration: const Duration(milliseconds: 100),
                        child: small == false
                            ? Text(
                                menuThree[i].title,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: selectedThree == i
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: selectedThree == i
                                        ? FontWeight.w600
                                        : FontWeight.normal),
                                overflow: TextOverflow.ellipsis,
                              )
                            : SizedBox()),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void logOut() async {
    var res = await Services.instance.setContext(context).logout();
    if (res == true) {
      AppSetting.instance.reset();
      await AppSetting.pref.remove('@profile');
      AppSetting.instance.accessToken = "";
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      Fluttertoast.showToast(
          msg: 'Có lỗi xảy ra khi đăng xuất. Bạn vẫn đăng xuất bình thường.');
    }
    // Fluttertoast.showToast(msg: 'Đang đăng xuất');
    // AppSetting.instance.reset();
    // AppSetting.pref.remove('@profile');

    //   try {
    //     DMCLSocket.instance.socket!.disconnect();
    //   } catch (error) {
    //     Fluttertoast.showToast(
    //         msg: 'Có lỗi xảy ra khi đăng xuất. Bạn vẫn đăng xuất bình thường.');
    //   } finally {
    //     AppSetting.instance.reset();
    //     // UserModel.instance.passwordCache = '';
    //
    //     Fluttertoast.cancel();
    //     Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    //   }
  }
}
