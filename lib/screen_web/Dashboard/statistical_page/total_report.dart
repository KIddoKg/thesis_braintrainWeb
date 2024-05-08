import 'package:bmeit_webadmin/helper/formatter.dart';
import 'package:bmeit_webadmin/res/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:bmeit_webadmin/res/colors.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../models/adminModel.dart';
import '../../../models/dataChartModel.dart';
import '../../../models/employerModel.dart';
import '../../../models/gameModel.dart';
import '../../../models/transactionModel.dart';
import '../../../services/services.dart';
import '../../../share/share_widget.dart';
import '../../../widget/share_widget.dart';
import '../../../widget/style.dart';
import 'navi_page.dart';

class TotalReport extends StatefulWidget {
  // ChartService? chartType;

  TotalReport({
    Key? key,
    // required this.chartType,
  }) : super(key: key);

  @override
  State<TotalReport> createState() => _TotalReportPageState();
}

class _TotalReportPageState extends State<TotalReport>  with SingleTickerProviderStateMixin {
  FocusNode _focus = FocusNode();
  late List<ExpenseData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  late TrackballBehavior _trackballBehavior;
  ChartService? chartType;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation _animation;
  bool checkDays = true;
  bool checkWeek = false;
  bool checkMonth = false;
  bool expandScreen = false;
  bool testBug = false;
  bool runSave = true;
  bool loadingDataChart = false;

  int nextOrback = 0;
  int testPr = 0;

  String typeTimeChart = "ngày";

  double percent = 0.0;
  double widthSearch = 300;

  String textTessr = "";

  List<GameModel> _deals = [];
  List<GameModel> _dealsBef = [];
  List<ExpenseData> testList = [];

  Map<String, dynamic> filterData = {
    "fromDateTime": DateTime.now().millisecondsSinceEpoch,
    "toDateTime": DateTime.now().millisecondsSinceEpoch,
  };
  Map<String, dynamic> filterDataBefore = {
    "fromDateTime": DateTime.now().millisecondsSinceEpoch,
    "toDateTime": DateTime.now().millisecondsSinceEpoch,
    'gameType': 'MEMORY',
    'gameName': 0,
    'id': ' ',
  };
  Map<String, dynamic> filter = {
    'fromDateTime': DateTime.now().millisecondsSinceEpoch,
    'toDateTime': DateTime.now().millisecondsSinceEpoch,
    'gameType': 'MEMORY',
    'gameName': 0,
    'id': '',
  };

  List<Map<String, dynamic>> priceList = [
    {"service": "DIFFERENCE", "total": 0, "totalBef": 0, "level": 0},
    {"service": "PAIRING", "total": 0, "totalBef": 0, "level": 0},
    {"service": "FISHING", "total": 0, "totalBef": 0, "level": 0},
    {"service": "STARTING_LETTER", "total": 0, "totalBef": 0, "level": 0},
    {"service": 'STARTING_WORD', "total": 0, "totalBef": 0, "level": 0},
    {"service": 'NEXT_WORD', "total": 0, "totalBef": 0, "level": 0},
    {"service": 'LETTERS_REARRANGE', "total": 0, "totalBef": 0, "level": 0},
    {"service": 'SMALLER_EXPRESSION', "total": 0, "totalBef": 0, "level": 0},
    {"service": 'SUM', "total": 0, "totalBef": 0, "level": 0},
    {"service": "POSITION", "total": 0, "totalBef": 0, "level": 0},
    {"service": 'NEW_PICTURE', "total": 0, "totalBef": 0, "level": 0},
    {"service": "LOST_PICTURE", "total": 0, "totalBef": 0, "level": 0},
  ];

  TextEditingController nameController = TextEditingController();
  TextEditingController acountIDController = TextEditingController();
  TextEditingController monitoredController = TextEditingController();
  TextEditingController passController = TextEditingController();

  // TextEditingController passwordController = TextEditingController();
  TextEditingController genderIdController = TextEditingController();
  TextEditingController loginCodeController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  TextEditingController notiController = TextEditingController();
  TextEditingController notiCenterController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Employee? infoDeal;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    _animation = IntTween(begin: 0, end: 100).animate(_animationController);
    _animation.addListener(() => setState(() {}));
    _focus.addListener(_onFocusChange);
    onSelectedDate(0);
    _chartData = getDataNull();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        expandScreen = true;
        _runCheck();
      });


      await initData();
    });

    _tooltipBehavior = TooltipBehavior(enable: true);
    _trackballBehavior = TrackballBehavior(
      enable: true,
      builder: (BuildContext context, TrackballDetails trackballDetails) {
        int? intValue;
        if (trackballDetails.point!.yValue is int) {
          intValue = trackballDetails.point!
              .yValue; // If dynamicData is already an int, assign it directly
        } else if (trackballDetails.point!.yValue is String) {
          intValue = int.tryParse(trackballDetails.point!.yValue);
        }
        return Container(
          height: 50,
          width: 280,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          child: Row(
            children: [
              Center(
                  child: Container(
                      padding: EdgeInsets.only(top: 8, left: 7),
                      height: 50,
                      width: 270,
                      child: Row(
                        children: [
                          Text(
                            '${trackballDetails.series?.name}',
                            style: TextStyle(
                              fontSize: 13,
                              color: trackballDetails.series!
                                  .color, // Change the color to the desired color
                            ),
                          ),
                          Text(
                            ' : ${intValue}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(26, 29, 45, 1.0),
                            ),
                          ),
                        ],
                      )))
            ],
          ),
        );
      },
      activationMode: ActivationMode.singleTap,
    );
    super.initState();
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    super.dispose();
  }



  Future<void> getInfo() async {
    var res =
        await Services.instance.listUserID(filter['id']);
    if (res != null) {
      var data = res;
      infoDeal = data;
      acountIDController.text = infoDeal!.id!;
      nameController.text = infoDeal!.fullName!;
      phoneController.text = infoDeal!.phone!;
      // passwordController.text = infoDeal!.pas!;
      loginCodeController.text = infoDeal!.loginCode.toString();
      genderIdController.text = infoDeal!.gender!;
      dobController.text = infoDeal!.dob!.toString();
    }
    // checkDoneShift();
    setState(() {});
  }

  void _onFocusChange() {
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
    print(_focus.hasFocus.toString() == "true");
    if (_focus.hasFocus.toString() == "true") {
      widthSearch = 450;
    } else {
      widthSearch = 300;
    }
    setState(() {});
  }

  Future<void> initData() async {
    // var x = getgameNameIcon(widget.chartType!);
    _deals = [];
    getDateBefore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    filter['id'] = prefs.getString('idUser') ?? "40010b6d-fa7d-4152-97c0-f3814aa17cef";
    filterDataBefore['id'] = prefs.getString('idUser') ?? "40010b6d-fa7d-4152-97c0-f3814aa17cef";
    filter['fromDateTime'] = filterData['fromDateTime'];
    filter['toDateTime'] = filterData['toDateTime'];
    filter['gameType'] = "MJ";
    // filter['gameName'] = filterData['toDateTime'];
    // filter['gameName'] = x.number;
    // filterDataBefore['gameName'] = x.number;
    loadingDataChart = true;

    var gameNames = ["MEMORY", "ATTENTION", "LANGUAGE", "MATH"];
    var res;

    for (var i = 0; i < gameNames.length; i++) {
      filter['gameType'] = gameNames[i];
      setState(() {

      });
      res = await Services.instance.getDataChart(filter: filter);

      if (res != null) {
        var data = res.castList<GameModel>();
        _deals.addAll(data);
      } else {
        break;
      }

  }

    if (res != null) {
      var resBefore;

      for (var i = 0; i < 4; i++) {
        if (i == 0) {
          filterDataBefore['gameName'] = "MEMORY";
          resBefore =
              await Services.instance.getDataChart(filter: filterDataBefore); if(res == null){
            break;
          }
        } else if (i == 1) {
          filterDataBefore['gameName'] = "ATTENTION";
          resBefore =
              await Services.instance.getDataChart(filter: filterDataBefore); if(res == null){
            break;
          }
        } else if (i == 2) {
          filterDataBefore['gameName'] = "LANGUAGE";
          resBefore =
              await Services.instance.getDataChart(filter: filterDataBefore); if(res == null){
            break;
          }
        } else if (i == 3) {
          filterDataBefore['gameName'] = "MATH";
          resBefore =
              await Services.instance.getDataChart(filter: filterDataBefore); if(res == null){
            break;
          }
        }
        if (resBefore != null) {
          var data = resBefore.castList<GameModel>();
          _dealsBef.addAll(data);
        } else {
          showAlertAction(context, 'Thông báo',
              'Lấy dữ liệu từ Server thất bại, hãy thử lại!', initData);
        }
      }
    }
    loadingDataChart = false;

    mackeClean();
    Map<String, String> gameNameMap = {
      "DIFFERENCE": "DIFFERENCE",
      "PAIRING": "PAIRING",
      "FISHING": "FISHING",
      "STARTING_LETTER": "STARTING_LETTER",
      "NEXT_WORD": "NEXT_WORD",
      "LETTERS_REARRANGE": "LETTERS_REARRANGE",
      "SMALLER_EXPRESSION": "SMALLER_EXPRESSION",
      "SUM": "SUM",
      "POSITION": "POSITION",
      "NEW_PICTURE": "NEW_PICTURE",
      "LOST_PICTURE": "LOST_PICTURE",
    };

    for (var e in _deals) {
      if (e.gameName != null && gameNameMap.containsKey(e.gameName)) {
        test2(gameNameMap[e.gameName]!, e.score);
      }
    }

    for (var e in _dealsBef) {
      if (e.gameName != null && gameNameMap.containsKey(e.gameName)) {
        test3(gameNameMap[e.gameName]!, e.score);
      }
    }

    // for (var i = 0; i < 12; i++) {
    //   print("e${i}");
    //   test2(i);
    // }
    setState(() {});
  }

  Future<void> _runCheck() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    testBug = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    filter['id'] = prefs.getString('idUser') ?? "40010b6d-fa7d-4152-97c0-f3814aa17cef";
    filterDataBefore['id'] = prefs.getString('idUser') ?? "40010b6d-fa7d-4152-97c0-f3814aa17cef";

    setState(() {});
    if(filter['id']!= "")
      await getInfo();
  }

  List<ExpenseData> getNull() {
    return getDataNull();
  }

  List<ExpenseData> getDataNull() {
    final List<ExpenseData> chartData = [];
    chartData.add(
      ExpenseData('', 0, 1
          // 0,
          // 0,
          // 0,
          // 0,
          ),
    );

    return chartData;
  }

  void mackeClean() {
    priceList = [
      {"service": "DIFFERENCE", "total": 0, "totalBef": 0, "level": 0},
      {"service": "PAIRING", "total": 0, "totalBef": 0, "level": 0},
      {"service": "FISHING", "total": 0, "totalBef": 0, "level": 0},
      {"service": "STARTING_LETTER", "total": 0, "totalBef": 0, "level": 0},
      {"service": 'STARTING_WORD', "total": 0, "totalBef": 0, "level": 0},
      {"service": 'NEXT_WORD', "total": 0, "totalBef": 0, "level": 0},
      {"service": 'LETTERS_REARRANGE', "total": 0, "totalBef": 0, "level": 0},
      {"service": 'SMALLER_EXPRESSION', "total": 0, "totalBef": 0, "level": 0},
      {"service": 'SUM', "total": 0, "totalBef": 0, "level": 0},
      {"service": "POSITION", "total": 0, "totalBef": 0, "level": 0},
      {"service": 'NEW_PICTURE', "total": 0, "totalBef": 0, "level": 0},
      {"service": "LOST_PICTURE", "total": 0, "totalBef": 0, "level": 0},
    ];
    setState(() {});
  }

  void test2(String gameName, int z) {
    for (var item in priceList) {
      if (item["service"] == gameName) {
        if (item["total"] < z) item["total"] = z;
        break; // Dừng sau khi tìm thấy và cập nhật
      }
    }

    // int y =0;
  }

  void test3(String gameName, int z) {
    for (var item in priceList) {
      if (item["service"] == gameName) {
        if (item["totalBef"] < z) item["totalBef"] = z;
        break; // Dừng sau khi tìm thấy và cập nhật
      }
    }
  }

  List<ExpenseData> getChartgameName(
      int gameName, String gameType, String Sort) {
    String x = "";
    switch (gameType) {
      case "ATTENTION":
        switch (gameName) {
          case 0:
            x = "DIFFERENCE";
            break;
          case 1:
            x = "PAIRING";
            break;
          case 2:
            x = "FISHING";
            break;
        }
        break;
      case "LANGUAGE":
        switch (gameName) {
          case 0:
            x = "STARTING_LETTER";
            break;
          case 1:
            x = "STARTING_WORD";
            break;
          case 2:
            x = "NEXT_WORD";
            break;
          case 3:
            x = "LETTERS_REARRANGE";
            break;
        }
        break;
      case "MATH":
        switch (gameName) {
          case 0:
            x = "SMALLER_EXPRESSION";
            break;
          case 1:
            x = "SUM";
            break;
        }
        break;
      case "MEMORY":
        switch (gameName) {
          case 0:
            x = "POSITION";
            break;
          case 1:
            x = "NEW_PICTURE";
            break;
          case 2:
            x = "LOST_PICTURE";
            break;
        }
        break;
    }

    List<ExpenseData> getChartDataService = [];

    List<ExpenseData> getDataDealinDays(String gameName) {
      var fromDateTime =
          filterData['fromDateTime']; // Assuming you have this variable
      var toDateTime =
          filterData['toDateTime']; // Assuming you have this variable
      int y = 0;
      DateTime fromDate = DateTime.fromMillisecondsSinceEpoch(fromDateTime);
      DateTime toDate = DateTime.fromMillisecondsSinceEpoch(toDateTime);

      // Sử dụng một Map để theo dõi tổng số tiền cho mỗi ngày
      Map<int, int> dailyExpenses = {};
      Map<int, int> dailyCount = {};

      // Đảm bảo tạo các mục cho tất cả các ngày trong khoảng thời gian
      for (var day = 1; day <= toDate.day; day++) {
        dailyExpenses[day] ??= 0;
        // Calculate the next day, considering different month lengths
      }

      for (var e in _deals) {
        DateTime checkDay = DateTime.fromMillisecondsSinceEpoch(e.createdDate);
        String gameNameCheck = e.gameName;
        int v = 0;
        if (checkDay.isAfter(fromDate) &&
            checkDay.isBefore(toDate) &&
            gameName == gameNameCheck) {
          if (dailyExpenses[checkDay.day]! < e.score) {
            dailyExpenses[checkDay.day] = e.score;
            dailyCount[checkDay.day] = (dailyCount[checkDay.day] ?? 0) + 1;
          } else {
            dailyCount[checkDay.day] = (dailyCount[checkDay.day] ?? 0) + 1;
          }
        }
      }

      final List<ExpenseData> chartData = [];

      // Tạo các đối tượng ExpenseData từ tổng số tiền hàng ngày
      dailyExpenses.forEach((day, totalAmount) {
        var x = 0;
        dailyCount.forEach((dayli, totalCount) {
          if (day == dayli) {
            x = totalCount;
          }
        });
        chartData.add(
          ExpenseData('${day}', totalAmount, x),
        );
      });
      Future.delayed(Duration(seconds: 2));

      return chartData;
    }

    List<ExpenseData> getDataDealinWeeks(String gameName) {
      var fromDateTime =
          filterData['fromDateTime']; // Assuming you have this variable
      var toDateTime =
          filterData['toDateTime']; // Assuming you have this variable
      Map<int, int> dailyCount = {};
      DateTime fromDate = DateTime.fromMillisecondsSinceEpoch(fromDateTime);
      DateTime toDate = DateTime.fromMillisecondsSinceEpoch(toDateTime);

      // Calculate the number of weeks between fromDate and toDate
      int weeks = (toDate.difference(fromDate).inDays / 7).ceil();

      // Use maps to track total expenses and different categories of expenses by week
      Map<int, int> weeklyExpenses = {};
      for (var e in _deals) {
        DateTime checkDay = DateTime.fromMillisecondsSinceEpoch(e.createdDate);
        String gameNameCheck = e.gameName;
        if (checkDay.isAfter(fromDate) &&
            checkDay.isBefore(toDate) &&
            gameName == gameNameCheck) {
          int weekNumber = checkDay.difference(fromDate).inDays ~/ 7 + 1;
          if(weeklyExpenses[weekNumber] == null){
            weeklyExpenses[weekNumber] = 0;
          }
          if (weeklyExpenses[weekNumber]!  < e.score) {
            weeklyExpenses[weekNumber] = e.score;
            dailyCount[weekNumber] = (dailyCount[weekNumber] ?? 0) + 1;
          } else {
            dailyCount[weekNumber] = (dailyCount[weekNumber] ?? 0) + 1;
          }
          // Calculate the week number for the current deal

          // weeklyExpenses[weekNumber] = e.score;
        }
      }

      final List<ExpenseData> chartData = [];

      // Create ExpenseData objects from weekly data
      for (int weekNumber = 1; weekNumber <= weeks; weekNumber++) {
        DateTime weekStart = fromDate.add(Duration(days: (weekNumber - 1) * 7));
        DateTime weekEnd = weekStart.add(Duration(days: 6));
        var x = 0;
        dailyCount.forEach((dayli, totalCount) {
          if (weekNumber == dayli) {
            x = totalCount;
          }
        });
        if (weekEnd.isAfter(toDate)) {
          weekEnd = toDate;
        }
        chartData.add(
          ExpenseData(
              '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}',
              weeklyExpenses[weekNumber] ?? 0,
              x),
        );
      }

      return chartData;
    }

    List<ExpenseData> getDataDealinMonths(String gameName) {
      var fromDateTime =
          filterData['fromDateTime']; // Assuming you have this variable
      var toDateTime =
          filterData['toDateTime']; // Assuming you have this variable

      DateTime fromDate = DateTime.fromMillisecondsSinceEpoch(fromDateTime);
      DateTime toDate = DateTime.fromMillisecondsSinceEpoch(toDateTime);
      Map<int, int> dailyCount = {};
      Map<int, int> monthlyExpenses = {};

      for (var e in _deals) {
        DateTime checkDay = DateTime.fromMillisecondsSinceEpoch(e.createdDate);
        String gameNameCheck = e.gameName;
        if (checkDay.isAfter(fromDate) &&
            checkDay.isBefore(toDate) &&
            gameName == gameNameCheck) {

          // Calculate the month number for the current deal
          int monthNumber = checkDay.month;
          if(monthlyExpenses[monthNumber] == null){
            monthlyExpenses[monthNumber] = 0;
          }
          if (monthlyExpenses[monthNumber]! < e.score) {
            monthlyExpenses[monthNumber] =  e.score;
            dailyCount[monthNumber] = (dailyCount[monthNumber] ?? 0) + 1;
          } else {
            dailyCount[monthNumber] = (dailyCount[monthNumber] ?? 0) + 1;
          }
          // Update monthly expenses and categories accordingly
          monthlyExpenses[monthNumber] =
              (monthlyExpenses[monthNumber] ?? 0) + e.score;
        }
      }

      final List<ExpenseData> chartData = [];

      // Create ExpenseData objects from monthly data
      for (int monthNumber = 1; monthNumber <= toDate.month; monthNumber++) {
        var x = 0;
        dailyCount.forEach((dayli, totalCount) {
          if (monthNumber == dayli) {
            x = totalCount;
          }
        });
        chartData.add(
          ExpenseData(
            '${monthNumber}/${toDate.year}',
            monthlyExpenses[monthNumber] ?? 0,
            x,
          ),
        );
      }

      return chartData;
    }

    switch (Sort) {
      case "ngày":
        if (_deals.isNotEmpty) getChartDataService = getDataDealinDays(x);
        break;
      case "tuần":
        if (_deals.isNotEmpty) getChartDataService = getDataDealinWeeks(x);
        break;
      case "tháng":
        if (_deals.isNotEmpty) getChartDataService = getDataDealinMonths(x);
        break;
    }

    return getChartDataService;
  }

  void checkPrecent(String gameType, int index) {
    int? z = 0;
    int? x = 0;
    z = getTotalForServiceBef(priceList, gameType, index);

    x = getTotalForService(priceList, gameType, index);
    percent = 0;
    textTessr = "";
    if (x != 0 && z != 0) {
      percent = ((x - z)! / z)!;
      textTessr = "${z} ${x}";
    } else if (x != 0 && z == 0) {
      percent = 1;
      textTessr = "${z} ${x}";
    } else if (x == 0 && z != 0) {
      percent = -1;
      textTessr = "${z} ${x}";
    } else {
      percent = 0;
      textTessr = "${z} ${x}";
    }
  }

  void checkNowDays() {
    DateTime nowDate = DateTime.now();
    var dateStr = filterData['toDateTime'];
    DateTime now = DateTime.fromMillisecondsSinceEpoch(dateStr);
    if (nowDate.day == now.day &&
        nowDate.month == now.month &&
        nowDate.year == now.year) {
      runSave = false;
    } else {
      runSave = true;
    }
    setState(() {});
  }

  void getDateBefore() {
    DateTime nowDate = DateTime.now();
    var dateStr = filterData['toDateTime'];
    DateTime now = DateTime.fromMillisecondsSinceEpoch(dateStr);
    // DateTime now = DateTime.parse(dateStr);
    int day = now.day;
    int month = now.month;
    int year = now.year;
    runSave = true;

    DateTime startDate = DateTime(year, month, day, 00, 00, 00);
    DateTime endDate = DateTime(year, month, day, 24, 00, 00);

    if (checkMonth == false) {
      startDate = DateTime(now.year, now.month - 1, 1);
      int lastDayOfPreviousMonth = DateTime(now.year, now.month, 0).day;
      endDate = DateTime(now.year, now.month - 1, lastDayOfPreviousMonth);
    } else if (checkMonth == true) {
      startDate = DateTime(now.year - 1, 1, 1);
      endDate = DateTime(now.year - 1, 12, 31);
    }
    if (runSave == true) {
      filterDataBefore['fromDateTime'] = startDate.millisecondsSinceEpoch;

      filterDataBefore['toDateTime'] = endDate.millisecondsSinceEpoch;
    }
    setState(() {});
  }

  final LinearGradient _linearGradientYellow = LinearGradient(
      colors: <Color>[
        Color.fromRGBO(255, 98, 0, 1.0),
        Color.fromRGBO(253, 127, 44, 1.0),
        Color.fromRGBO(253, 147, 70, 1.0),
        Color.fromRGBO(253, 167, 102, 1.0),
        Colors.white,
        Colors.white,
      ],
      stops: <double>[
        0.1,
        0.2,
        0.3,
        0.4,
        0.6,
        0.9
      ],
      // Setting gradient rotation value(degrees in radian) to transform the series gradient
      transform:
          GradientRotation((90 * (3.14 / 180)) // Converted 135 degree to radian
              ));
  final LinearGradient _linearGradientBlue = LinearGradient(
      colors: <Color>[
        Color.fromRGBO(15, 55, 115, 1.0),
        Color.fromRGBO(60, 163, 238, 1.0),
        Color.fromRGBO(143, 195, 230, 1.0),
        Color.fromRGBO(204, 236, 253, 1.0),
        Colors.white,
        Colors.white,
      ],
      stops: <double>[
        0.1,
        0.2,
        0.3,
        0.4,
        0.6,
        0.9
      ],
      // Setting gradient rotation value(degrees in radian) to transform the series gradient
      transform:
          GradientRotation((90 * (3.14 / 180)) // Converted 135 degree to radian
              ));

  int getTotalForService(
      List<Map<String, dynamic>> priceList, String gameType, int gameName) {
    String x = "";
    switch (gameType) {
      case "ATTENTION":
        switch (gameName) {
          case 0:
            x = "DIFFERENCE";
            break;
          case 1:
            x = "PAIRING";
            break;
          case 2:
            x = "FISHING";
            break;
        }
        break;
      case "LANGUAGE":
        switch (gameName) {
          case 0:
            x = "STARTING_LETTER";
            break;
          case 1:
            x = "STARTING_WORD";
            break;
          case 2:
            x = "NEXT_WORD";
            break;
          case 3:
            x = "LETTERS_REARRANGE";
            break;
        }
        break;
      case "MATH":
        switch (gameName) {
          case 0:
            x = "SMALLER_EXPRESSION";
            break;
          case 1:
            x = "SUM";
            break;
        }
        break;
      case "MEMORY":
        switch (gameName) {
          case 0:
            x = "POSITION";
            break;
          case 1:
            x = "NEW_PICTURE";
            break;
          case 2:
            x = "LOST_PICTURE";
            break;
        }
        break;
    }

    for (var item in priceList) {
      if (item["service"] == x) {
        return item["total"] ?? 0; // Trả về giá trị total khi tìm thấy dịch vụ
      }
    }
    return 0;
  }

  int getTotalForServiceBef(
      List<Map<String, dynamic>> priceList, String gameType, int gameName) {
    String x = "";
    switch (gameType) {
      case "ATTENTION":
        switch (gameName) {
          case 0:
            x = "DIFFERENCE";
            break;
          case 1:
            x = "PAIRING";
            break;
          case 2:
            x = "FISHING";
            break;
        }
        break;
      case "LANGUAGE":
        switch (gameName) {
          case 0:
            x = "STARTING_LETTER";
            break;
          case 1:
            x = "STARTING_WORD";
            break;
          case 2:
            x = "NEXT_WORD";
            break;
          case 3:
            x = "LETTERS_REARRANGE";
            break;
        }
        break;
      case "MATH":
        switch (gameName) {
          case 0:
            x = "SMALLER_EXPRESSION";
            break;
          case 1:
            x = "SUM";
            break;
        }
        break;
      case "MEMORY":
        switch (gameName) {
          case 0:
            x = "POSITION";
            break;
          case 1:
            x = "NEW_PICTURE";
            break;
          case 2:
            x = "LOST_PICTURE";
            break;
        }
        break;
    }

    for (var item in priceList) {
      if (item["service"] == x) {
        return item["totalBef"] ??
            0; // Trả về giá trị total khi tìm thấy dịch vụ
      }
    }
    return 0;
  }

  void onSelectedDate(int index) async {
    DateTime nowDate = DateTime.now();
    var dateStr = filterData['toDateTime'];
    DateTime now = DateTime.fromMillisecondsSinceEpoch(dateStr);
    // DateTime now = DateTime.parse(dateStr);
    int day = now.day;
    int month = now.month;
    int year = now.year;
    runSave = true;

    DateTime startDate = DateTime(year, month, day, 00, 00, 00);
    DateTime endDate = DateTime(year, month, day, 24, 00, 00);

    if (checkMonth == false) {
      switch (index) {
        case 0:
          startDate = DateTime(now.year, now.month, 1);
          endDate = now;
          break;
        case 1:
          startDate = DateTime(now.year, now.month - 1, 1);
          int lastDayOfPreviousMonth = DateTime(now.year, now.month, 0).day;
          endDate = DateTime(now.year, now.month - 1, lastDayOfPreviousMonth);
          break;

        case 2:
          if (nowDate.month == now.month + 1 && nowDate.year == now.year) {
            startDate = DateTime(now.year, now.month + 1, 1);
            endDate = nowDate;
          } else if (nowDate.year > now.year) {
            startDate = DateTime(now.year, now.month + 1, 1);
            int lastDayOfNextMonth = DateTime(now.year, now.month + 2, 0).day;
            endDate = DateTime(now.year, now.month + 1, lastDayOfNextMonth);
          } else if (nowDate.year == now.year &&
              nowDate.month > now.month + 1) {
            startDate = DateTime(now.year, now.month + 1, 1);
            int lastDayOfNextMonth = DateTime(now.year, now.month + 2, 0).day;
            endDate = DateTime(now.year, now.month + 1, lastDayOfNextMonth);
          } else {
            runSave = false;
            setState(() {});
          }

          break;
      }
    } else if (checkMonth == true) {
      switch (index) {
        case 0:
          startDate = DateTime(now.year, 1, 1);
          endDate = nowDate;
          runSave = true;
          break;
        case 1:
          startDate = DateTime(now.year - 1, 1, 1);
          endDate = DateTime(now.year - 1, 12, 31);
          break;

        case 2:
          if (nowDate.isAfter(DateTime(now.year - 1, 12, 31)) &&
              nowDate.year == now.year + 1) {
            startDate = DateTime(nowDate.year, 1, 1);
            endDate = nowDate;
          } else if (nowDate.isAfter(DateTime(now.year - 1, 12, 31)) &&
              nowDate.year > now.year) {
            startDate = DateTime(now.year + 1, 1, 1);
            endDate = DateTime(now.year + 1, 12, 31);
          } else {
            runSave = false;
            setState(() {});
          }

          break;
      }
    }
    if (runSave == true) {
      filterData['fromDateTime'] = startDate.millisecondsSinceEpoch;
      filterData['toDateTime'] = endDate.millisecondsSinceEpoch;
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktopOpenPOP(context) && _animation.value > 0) {
      widthSearch = 200;
      setState(() {});
    }
    checkNowDays();
    ChartSeriesController? _chartSeriesController1, _chartSeriesController2;
    // var x = getgameNameIcon(widget.chartType!);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: Container(
          width: 10,
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              SvgPicture.asset(
                "assets/svg/total.svg",
                width: 25,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Tổng quan Dữ liệu",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        leadingWidth: 300,
        actions: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: IconButton(
                    icon: AdminModel.instance.phone == null ||
                            AdminModel.instance.phone == ""
                        ? SvgPicture.asset('assets/svg/profile.svg')
                        : Image.network('${AdminModel.instance.phone}'),
                    onPressed: () {},
                  ),
                ),
              ),
              Text(
                "${AdminModel.instance.name}",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 20,
              )
            ],
          ),
        ],
        elevation: 0.0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height - 56,
            ),
            child: Row(children: [
              Flexible(
                flex: 10,
                child: Container(
                  // width: 500,
                  height: constraints.maxHeight,
                  child: Stack(
                    children: <Widget>[
                      testBug == true
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  right: 16.0, left: 8.0, top: 8, bottom: 16),
                              child: SingleChildScrollView(
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(18.0),
                                      ),
                                      color: Colors.white,
                                    ),
                                    width: constraints.maxWidth,
                                    // height: constraints.maxHeight,
                                    // duration: Duration(milliseconds: 300),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: AnimatedContainer(
                                            duration:
                                                const Duration(milliseconds: 350),
                                            width: !Responsive.isMobile(context)
                                                ? widthSearch
                                                : 200,
                                            child: DMCLSearchBoxWeb(
                                              focusNode: _focus,
                                              hint: 'Tìm kiếm theo id',
                                              controller: _searchController,
                                              isAutocomplete: false,
                                              onSubmit: (value) async {
                                                filter["id"] = value;
                                                filterDataBefore["id"] = value;
                                                await getInfo();
                                                await initData();
                                                if (infoDeal != null) {
                                                  acountIDController.text = infoDeal!.id!;
                                                  nameController.text = infoDeal!.fullName!;
                                                  phoneController.text = infoDeal!.phone!;
                                                  // passwordController.text = infoDeal!.pas!;
                                                  loginCodeController.text = infoDeal!.loginCode.toString();
                                                  genderIdController.text = infoDeal!.gender!;
                                                  dobController.text = infoDeal!.dob!.toString();
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        !Responsive.isMobile(context)
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Center(
                                                      child: Container(
                                                        width: 242,
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 5),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(
                                                                6.0),
                                                          ),
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Colors.black,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          6.0),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          6.0),
                                                                ),
                                                                color: checkDays ==
                                                                        true
                                                                    ? AppColors
                                                                        .bgButton
                                                                    : Colors
                                                                        .white,
                                                              ),
                                                              width: 80,
                                                              child: TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    checkMonth =
                                                                        false;
                                                                    checkDays =
                                                                        true;
                                                                    checkWeek =
                                                                        false;
                                                                    onSelectedDate(
                                                                        0);
                                                                    typeTimeChart =
                                                                        "ngày";
                                                                    await initData();

                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Text(
                                                                    "Ngày",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  )),
                                                            ),
                                                            Container(
                                                              width: 80,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: checkWeek ==
                                                                        true
                                                                    ? AppColors
                                                                        .bgButton
                                                                    : Colors
                                                                        .white,
                                                                border: Border(
                                                                  left:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    width: 1.0,
                                                                  ),
                                                                  right:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    width: 1.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    checkMonth =
                                                                        false;
                                                                    checkDays =
                                                                        false;
                                                                    checkWeek =
                                                                        true;
                                                                    onSelectedDate(
                                                                        0);
                                                                    typeTimeChart =
                                                                        "tuần";

                                                                    await initData();
                                                                    // _chartData =
                                                                    //     getChartDataWeek();

                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Text(
                                                                    "Tuần",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  )),
                                                            ),
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          6.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          6.0),
                                                                ),
                                                                color: checkMonth ==
                                                                        true
                                                                    ? AppColors
                                                                        .bgButton
                                                                    : Colors
                                                                        .white,
                                                              ),
                                                              width: 80,
                                                              child: TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    checkDays =
                                                                        false;
                                                                    checkWeek =
                                                                        false;
                                                                    checkMonth =
                                                                        true;
                                                                    onSelectedDate(
                                                                        0);
                                                                    typeTimeChart =
                                                                        "tháng";
                                                                    await initData();
                                                                    // _chartData =
                                                                    // getChartMonth();

                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Text(
                                                                    "Tháng",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Spacer(),
                                                        Flexible(
                                                            flex: 5,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                DMCLPageButton(
                                                                  Icons
                                                                      .arrow_back_ios_new,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  disable:
                                                                      false,
                                                                  onTap:
                                                                      () async {
                                                                    mackeClean();
                                                                    onSelectedDate(
                                                                        1);

                                                                    await initData();
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  fontColor:
                                                                      AppColors
                                                                          .primaryColor,
                                                                  border: Colors
                                                                      .grey,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      {},
                                                                  child:
                                                                      Container(
                                                                    width: 200,
                                                                    child:
                                                                        DMCLCard(
                                                                      backgroundColor:
                                                                          '#f7f7f7'
                                                                              .toColor(),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            (filterData['fromDateTime'] as int).toDateString(format: 'dd/MM/yyyy'),
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: GlobalStyles.text45),
                                                                          ),
                                                                          Icon(
                                                                            Icons.arrow_drop_down,
                                                                            color:
                                                                                GlobalStyles.backgroundDisableColor,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Flexible(
                                                            flex: 5,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {},
                                                                  child:
                                                                      Container(
                                                                    width: 200,
                                                                    child:
                                                                        DMCLCard(
                                                                      backgroundColor:
                                                                          '#f7f7f7'
                                                                              .toColor(),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            (filterData['toDateTime'] as int).toDateString(format: 'dd/MM/yyyy'),
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: GlobalStyles.text45),
                                                                          ),
                                                                          Icon(
                                                                            Icons.arrow_drop_down,
                                                                            color:
                                                                                GlobalStyles.backgroundDisableColor,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DMCLPageButton(
                                                                  Icons
                                                                      .arrow_forward_ios,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  disable:
                                                                      !runSave,
                                                                  onTap:
                                                                      () async {
                                                                    onSelectedDate(
                                                                        2);
                                                                    mackeClean();
                                                                    await initData();
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  fontColor:
                                                                      AppColors
                                                                          .primaryColor,
                                                                  border: Colors
                                                                      .grey,
                                                                ),
                                                              ],
                                                            )),
                                                        Spacer()
                                                      ],
                                                    )
                                                  ])
                                            : SizedBox(),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12.0)),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Danh mục Game Trí Nhớ",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15,
                                                          right: 15,
                                                          bottom: 15),
                                                  child: Center(
                                                    child: CustomScrollView(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      shrinkWrap: true,
                                                      slivers: [
                                                        SliverToBoxAdapter(
                                                            child: _deals
                                                                    .isNotEmpty
                                                                ? GridView
                                                                    .builder(
                                                                    physics:
                                                                        NeverScrollableScrollPhysics(),
                                                                    shrinkWrap:
                                                                        true,
                                                                    gridDelegate:
                                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                                      crossAxisCount:
                                                                          !Responsive.isMobile(context)
                                                                              ? 2
                                                                              : 1,
                                                                      crossAxisSpacing:
                                                                          10,
                                                                      mainAxisSpacing:
                                                                          10,
                                                                      mainAxisExtent: !Responsive.isMobileSmall(
                                                                              context)
                                                                          ? 450
                                                                          : 500, // here set custom Height You Want
                                                                    ),
                                                                    // return a custom ItemCard
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      var x = getServiceName(
                                                                          "MEMORY",
                                                                          index);
                                                                      _chartData = getChartgameName(
                                                                          index,
                                                                          "MEMORY",
                                                                          typeTimeChart);
                                                                      checkPrecent(
                                                                          "MEMORY",
                                                                          index);
                                                                      return Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.transparent,
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.grey,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(12.0)),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                left: 15.0,
                                                                                top: 6,
                                                                                bottom: 8,
                                                                              ),
                                                                              child: Container(
                                                                                width: double.infinity,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          "Điểm số của Game ${x.key}",
                                                                                          style: TextStyle(
                                                                                            fontWeight: FontWeight.w700,
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                        ),
                                                                                        Spacer(),
                                                                                        Center(
                                                                                          child: IconButton(
                                                                                            icon: Icon(Icons.info_outline),
                                                                                            // Replace 'add' with the desired icon
                                                                                            onPressed: ()  {
                                                                                              // Add your button press logic here
                                                                                              // Scaffold.of(context).openEndDrawer();
                                                                                               filter['gameName'] = index;
                                                                                               filter['gameType'] = "MEMORY";
                                                                                              setState(() {

                                                                                              });

                                                                                                  _scaffoldKey.currentState!.openEndDrawer();

                                                                                              print('Button Pressed!');
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 5),
                                                                                    !Responsive.isMobileSmall(context)
                                                                                        ? Row(
                                                                                            children: [
                                                                                              Text(
                                                                                                "${getTotalForService(priceList, "MEMORY", index).toCurrency()}",
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.w700,
                                                                                                  fontSize: 22,
                                                                                                  color: (index == 0 || index == 3 || index == 4 || index == 7) ? Color.fromRGBO(15, 55, 115, 1.0) : Color.fromRGBO(255, 98, 0, 1.0),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(width: 50),
                                                                                              Align(
                                                                                                alignment: Alignment.bottomCenter,
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                                  children: [
                                                                                                    (percent >= 0) ? Icon(Icons.arrow_upward, size: 18, color: Colors.green) : Icon(Icons.arrow_downward_sharp, size: 18, color: Colors.red),
                                                                                                    Text(
                                                                                                      "${(percent >= 0 ? (percent * 100) : (percent * -1 * 100)).toStringAsFixed(2)} % ",
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: TextStyle(
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                        fontSize: 14,
                                                                                                        color: percent >= 0 ? Colors.green : Colors.red,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        : Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                "${getTotalForService(priceList, "MEMORY", index)}",
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.w700,
                                                                                                  fontSize: 22,
                                                                                                  color: (index == 0 || index == 3 || index == 4 || index == 7) ? Color.fromRGBO(15, 55, 115, 1.0) : Color.fromRGBO(255, 98, 0, 1.0),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(width: 50),
                                                                                              Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                children: [
                                                                                                  (percent >= 0) ? Icon(Icons.arrow_upward, size: 18, color: Colors.green) : Icon(Icons.arrow_downward_sharp, size: 18, color: Colors.red),
                                                                                                  Text(
                                                                                                    "${(percent >= 0 ? (percent * 100) : (percent * -1 * 100)).toStringAsFixed(2)} % ",
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    style: TextStyle(
                                                                                                      fontWeight: FontWeight.w700,
                                                                                                      fontSize: 14,
                                                                                                      color: percent >= 0 ? Colors.green : Colors.red,
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              thickness: 1,
                                                                              indent: 20,
                                                                              endIndent: 20,
                                                                              color: Colors.grey,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                left: 15.0,
                                                                                top: 8,
                                                                              ),
                                                                              child: Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  "Điểm số theo thời gian",
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.w700,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Center(
                                                                                child: Container(
                                                                                  height: 300,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(left: 15, right: 20),
                                                                                    child: SfCartesianChart(
                                                                                      enableAxisAnimation: true,
                                                                                      legend: Legend(isVisible: true, position: LegendPosition.bottom, toggleSeriesVisibility: true, iconBorderColor: Colors.red, backgroundColor: Color.fromRGBO(0, 8, 22, 0.75), textStyle: TextStyle(color: Colors.white)),
                                                                                      // tooltipBehavior: _tooltipBehavior,
                                                                                      trackballBehavior: _trackballBehavior,
                                                                                      axes: <ChartAxis>[
                                                                                        NumericAxis(
                                                                                          // labelFormat: '{value} M',
                                                                                          numberFormat: NumberFormat.compact(),
                                                                                          majorGridLines: const MajorGridLines(width: 0),
                                                                                          opposedPosition: true,
                                                                                          minimum: 0,
                                                                                          name: 'yAxis1',
                                                                                          // maximum: maxiChart +
                                                                                          //     maxiChart *
                                                                                          //         0.05,
                                                                                        ),
                                                                                      ],
                                                                                      series: <CartesianSeries<ExpenseData, String>>[
                                                                                        SplineAreaSeries<ExpenseData, String>(
                                                                                            splineType: SplineType.monotonic,
                                                                                            // cardinalSplineTension:
                                                                                            // 0.9,
                                                                                            onRendererCreated: (ChartSeriesController controller) {
                                                                                              _chartSeriesController1 = controller;
                                                                                            },
                                                                                            color: Colors.blue,
                                                                                            dataSource: _chartData,
                                                                                            xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                                                                                            yValueMapper: (ExpenseData exp, _) => exp.total,
                                                                                            name: 'Điểm cao nhất',
                                                                                            gradient: (index == 0 || index == 3 || index == 4 || index == 7) ? _linearGradientBlue : _linearGradientYellow,
                                                                                            borderWidth: 3,
                                                                                            borderGradient: (index == 0 || index == 3 || index == 4 || index == 7)
                                                                                                ? LinearGradient(colors: <Color>[
                                                                                                    Color.fromRGBO(15, 55, 115, 1.0),
                                                                                                  ], stops: <double>[
                                                                                                    0.2,
                                                                                                  ])
                                                                                                : LinearGradient(colors: <Color>[
                                                                                                    Color.fromRGBO(255, 98, 0, 1.0),
                                                                                                  ], stops: <double>[
                                                                                                    0.2,
                                                                                                  ])),
                                                                                        LineSeries<ExpenseData, String>(
                                                                                            animationDuration: 4500,color:Colors.green,
                                                                                            dataSource: _chartData,
                                                                                            onRendererCreated: (ChartSeriesController controller) {
                                                                                              _chartSeriesController2 = controller;
                                                                                            },
                                                                                            xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                                                                                            yValueMapper: (ExpenseData exp, _) => exp.count,
                                                                                            yAxisName: 'yAxis1',
                                                                                            markerSettings: MarkerSettings(isVisible: true),
                                                                                            name: 'Số lần chơi')
                                                                                      ],
                                                                                      primaryXAxis: CategoryAxis(
                                                                                        labelPlacement: LabelPlacement.onTicks,
                                                                                        interval: 2,
                                                                                        majorGridLines: MajorGridLines(width: 0),
                                                                                        //Hide the axis line of x-axis
                                                                                        axisLine: AxisLine(width: 0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                    itemCount:
                                                                        3,
                                                                  )
                                                                : Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      loadingDataChart ==
                                                                              true
                                                                          ? LoadingDot()
                                                                          : ErrorsNoti(
                                                                              text: "Không có dữ liệu \n trong thời gian này !",
                                                                              style: TextStyle(color: Colors.black54, fontSize: 20),
                                                                            )
                                                                    ],
                                                                  )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12.0)),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Danh mục Game Tập Trung",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15,
                                                          right: 15,
                                                          bottom: 15),
                                                  child: Center(
                                                    child: CustomScrollView(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      shrinkWrap: true,
                                                      slivers: [
                                                        SliverToBoxAdapter(
                                                            child: _deals
                                                                    .isNotEmpty
                                                                ? GridView
                                                                    .builder(
                                                                    physics:
                                                                        NeverScrollableScrollPhysics(),
                                                                    shrinkWrap:
                                                                        true,
                                                                    gridDelegate:
                                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                                      crossAxisCount:
                                                                          !Responsive.isMobile(context)
                                                                              ? 2
                                                                              : 1,
                                                                      crossAxisSpacing:
                                                                          10,
                                                                      mainAxisSpacing:
                                                                          10,
                                                                      mainAxisExtent: !Responsive.isMobileSmall(
                                                                              context)
                                                                          ? 450
                                                                          : 500, // here set custom Height You Want
                                                                    ),
                                                                    // return a custom ItemCard
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      var x = getServiceName(
                                                                          "ATTENTION",
                                                                          index);
                                                                      _chartData = getChartgameName(
                                                                          index,
                                                                          "ATTENTION",
                                                                          typeTimeChart);
                                                                      checkPrecent(
                                                                          "ATTENTION",
                                                                          index);
                                                                      return Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.transparent,
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.grey,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(12.0)),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                left: 15.0,
                                                                                top: 7,
                                                                                bottom: 6,
                                                                              ),
                                                                              child: Container(
                                                                                width: double.infinity,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          "Điểm số của Game ${x.key}",
                                                                                          style: TextStyle(
                                                                                            fontWeight: FontWeight.w700,
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                        ),
                                                                                        Spacer(),
                                                                                        Center(
                                                                                          child: IconButton(
                                                                                            icon: Icon(Icons.info_outline),
                                                                                            // Replace 'add' with the desired icon
                                                                                            onPressed: ()  {
                                                                                              // Add your button press logic here
                                                                                              // Scaffold.of(context).openEndDrawer();
                                                                                              filter['gameName'] = index;
                                                                                              filter['gameType'] = "ATTENTION";
                                                                                              setState(() {

                                                                                              });

                                                                                              _scaffoldKey.currentState!.openEndDrawer();

                                                                                              print('Button Pressed!');
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 5),
                                                                                    !Responsive.isMobileSmall(context)
                                                                                        ? Row(
                                                                                            children: [
                                                                                              Text(
                                                                                                "${getTotalForService(priceList, "ATTENTION", index).toCurrency()}",
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.w700,
                                                                                                  fontSize: 22,
                                                                                                  color: (index == 0 || index == 3 || index == 4 || index == 7) ? Color.fromRGBO(15, 55, 115, 1.0) : Color.fromRGBO(255, 98, 0, 1.0),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(width: 50),
                                                                                              Align(
                                                                                                alignment: Alignment.bottomCenter,
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                                  children: [
                                                                                                    (percent >= 0) ? Icon(Icons.arrow_upward, size: 18, color: Colors.green) : Icon(Icons.arrow_downward_sharp, size: 18, color: Colors.red),
                                                                                                    Text(
                                                                                                      "${(percent >= 0 ? (percent * 100) : (percent * -1 * 100)).toStringAsFixed(2)} % ",
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: TextStyle(
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                        fontSize: 14,
                                                                                                        color: percent >= 0 ? Colors.green : Colors.red,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        : Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                "${getTotalForService(priceList, "ATTENTION ", index)}",
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.w700,
                                                                                                  fontSize: 22,
                                                                                                  color: (index == 0 || index == 3 || index == 4 || index == 7) ? Color.fromRGBO(15, 55, 115, 1.0) : Color.fromRGBO(255, 98, 0, 1.0),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(width: 50),
                                                                                              Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                children: [
                                                                                                  (percent >= 0) ? Icon(Icons.arrow_upward, size: 18, color: Colors.green) : Icon(Icons.arrow_downward_sharp, size: 18, color: Colors.red),
                                                                                                  Text(
                                                                                                    "${(percent >= 0 ? (percent * 100) : (percent * -1 * 100)).toStringAsFixed(2)} % ",
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    style: TextStyle(
                                                                                                      fontWeight: FontWeight.w700,
                                                                                                      fontSize: 14,
                                                                                                      color: percent >= 0 ? Colors.green : Colors.red,
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              thickness: 1,
                                                                              indent: 20,
                                                                              endIndent: 20,
                                                                              color: Colors.grey,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                left: 15.0,
                                                                                top: 8,
                                                                              ),
                                                                              child: Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  "Điểm số theo thời gian",
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.w700,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Center(
                                                                                child: Container(
                                                                                  height: 300,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(left: 15, right: 20),
                                                                                    child: SfCartesianChart(
                                                                                      enableAxisAnimation: true,
                                                                                      legend: Legend(isVisible: true, position: LegendPosition.bottom, toggleSeriesVisibility: true, iconBorderColor: Colors.red, backgroundColor: Color.fromRGBO(0, 8, 22, 0.75), textStyle: TextStyle(color: Colors.white)),
                                                                                      // tooltipBehavior: _tooltipBehavior,
                                                                                      trackballBehavior: _trackballBehavior,
                                                                                      axes: <ChartAxis>[
                                                                                        NumericAxis(
                                                                                          // labelFormat: '{value} M',
                                                                                          numberFormat: NumberFormat.compact(),
                                                                                          majorGridLines: const MajorGridLines(width: 0),
                                                                                          opposedPosition: true,
                                                                                          minimum: 0,
                                                                                          name: 'yAxis1',
                                                                                          // maximum: maxiChart +
                                                                                          //     maxiChart *
                                                                                          //         0.05,
                                                                                        ),
                                                                                      ],
                                                                                      series: <CartesianSeries<ExpenseData, String>>[
                                                                                        SplineAreaSeries<ExpenseData, String>(
                                                                                            splineType: SplineType.monotonic,
                                                                                            // cardinalSplineTension:
                                                                                            // 0.9,
                                                                                            onRendererCreated: (ChartSeriesController controller) {
                                                                                              _chartSeriesController1 = controller;
                                                                                            },
                                                                                            color: Colors.blue,
                                                                                            dataSource: _chartData,
                                                                                            xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                                                                                            yValueMapper: (ExpenseData exp, _) => exp.total,
                                                                                            name: 'Điểm cao nhất',
                                                                                            gradient: (index == 0 || index == 3 || index == 4 || index == 7) ? _linearGradientBlue : _linearGradientYellow,
                                                                                            borderWidth: 3,
                                                                                            borderGradient: (index == 0 || index == 3 || index == 4 || index == 7)
                                                                                                ? LinearGradient(colors: <Color>[
                                                                                              Color.fromRGBO(15, 55, 115, 1.0),
                                                                                            ], stops: <double>[
                                                                                              0.2,
                                                                                            ])
                                                                                                : LinearGradient(colors: <Color>[
                                                                                              Color.fromRGBO(255, 98, 0, 1.0),
                                                                                            ], stops: <double>[
                                                                                              0.2,
                                                                                            ])),
                                                                                        LineSeries<ExpenseData, String>(
                                                                                            animationDuration: 4500,color:Colors.green,
                                                                                            dataSource: _chartData,
                                                                                            onRendererCreated: (ChartSeriesController controller) {
                                                                                              _chartSeriesController2 = controller;
                                                                                            },
                                                                                            xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                                                                                            yValueMapper: (ExpenseData exp, _) => exp.count,
                                                                                            yAxisName: 'yAxis1',
                                                                                            markerSettings: MarkerSettings(isVisible: true),
                                                                                            name: 'Số lần chơi')
                                                                                      ],
                                                                                      primaryXAxis: CategoryAxis(
                                                                                        labelPlacement: LabelPlacement.onTicks,
                                                                                        interval: 2,
                                                                                        majorGridLines: MajorGridLines(width: 0),
                                                                                        //Hide the axis line of x-axis
                                                                                        axisLine: AxisLine(width: 0),
                                                                                      ),
                                                                                    )
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                    itemCount:
                                                                        3,
                                                                  )
                                                                : Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      loadingDataChart ==
                                                                              true
                                                                          ? LoadingDot()
                                                                          : ErrorsNoti(
                                                                              text: "Không có dữ liệu \n trong thời gian này !",
                                                                              style: TextStyle(color: Colors.black54, fontSize: 20),
                                                                            )
                                                                    ],
                                                                  )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12.0)),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Danh mục Game Ngôn ngữ",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15,
                                                          right: 15,
                                                          bottom: 15),
                                                  child: Center(
                                                    child: CustomScrollView(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      shrinkWrap: true,
                                                      slivers: [
                                                        SliverToBoxAdapter(
                                                            child: _deals
                                                                    .isNotEmpty
                                                                ? GridView
                                                                    .builder(
                                                                    physics:
                                                                        NeverScrollableScrollPhysics(),
                                                                    shrinkWrap:
                                                                        true,
                                                                    gridDelegate:
                                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                                      crossAxisCount:
                                                                          !Responsive.isMobile(context)
                                                                              ? 2
                                                                              : 1,
                                                                      crossAxisSpacing:
                                                                          10,
                                                                      mainAxisSpacing:
                                                                          10,
                                                                      mainAxisExtent: !Responsive.isMobileSmall(
                                                                              context)
                                                                          ? 450
                                                                          : 500, // here set custom Height You Want
                                                                    ),
                                                                    // return a custom ItemCard
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      var x = getServiceName(
                                                                          "LANGUAGE",
                                                                          index);
                                                                      _chartData = getChartgameName(
                                                                          index,
                                                                          "LANGUAGE",
                                                                          typeTimeChart);
                                                                      checkPrecent(
                                                                          "LANGUAGE",
                                                                          index);
                                                                      return Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.transparent,
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.grey,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(12.0)),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                left: 15.0,
                                                                                top: 7,
                                                                                bottom: 6,
                                                                              ),
                                                                              child: Container(
                                                                                width: double.infinity,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          "Điểm số của Game ${x.key}",
                                                                                          style: TextStyle(
                                                                                            fontWeight: FontWeight.w700,
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                        ),
                                                                                        Spacer(),
                                                                                        Center(
                                                                                          child: IconButton(
                                                                                            icon: Icon(Icons.info_outline),
                                                                                            // Replace 'add' with the desired icon
                                                                                            onPressed: ()  {
                                                                                              // Add your button press logic here
                                                                                              // Scaffold.of(context).openEndDrawer();
                                                                                              filter['gameName'] = index;
                                                                                              filter['gameType'] = "LANGUAGE";
                                                                                              setState(() {

                                                                                              });

                                                                                              _scaffoldKey.currentState!.openEndDrawer();

                                                                                              print('Button Pressed!');
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 5),
                                                                                    !Responsive.isMobileSmall(context)
                                                                                        ? Row(
                                                                                            children: [
                                                                                              Text(
                                                                                                "${getTotalForService(priceList, "LANGUAGE", index).toCurrency()}",
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.w700,
                                                                                                  fontSize: 22,
                                                                                                  color: (index == 0 || index == 3 || index == 4 || index == 7) ? Color.fromRGBO(15, 55, 115, 1.0) : Color.fromRGBO(255, 98, 0, 1.0),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(width: 50),
                                                                                              Align(
                                                                                                alignment: Alignment.bottomCenter,
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                                  children: [
                                                                                                    (percent >= 0) ? Icon(Icons.arrow_upward, size: 18, color: Colors.green) : Icon(Icons.arrow_downward_sharp, size: 18, color: Colors.red),
                                                                                                    Text(
                                                                                                      "${(percent >= 0 ? (percent * 100) : (percent * -1 * 100)).toStringAsFixed(2)} % ",
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: TextStyle(
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                        fontSize: 14,
                                                                                                        color: percent >= 0 ? Colors.green : Colors.red,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        : Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                "${getTotalForService(priceList, "LANGUAGE", index)}",
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.w700,
                                                                                                  fontSize: 22,
                                                                                                  color: (index == 0 || index == 3 || index == 4 || index == 7) ? Color.fromRGBO(15, 55, 115, 1.0) : Color.fromRGBO(255, 98, 0, 1.0),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(width: 50),
                                                                                              Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                children: [
                                                                                                  (percent >= 0) ? Icon(Icons.arrow_upward, size: 18, color: Colors.green) : Icon(Icons.arrow_downward_sharp, size: 18, color: Colors.red),
                                                                                                  Text(
                                                                                                    "${(percent >= 0 ? (percent * 100) : (percent * -1 * 100)).toStringAsFixed(2)} % ",
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    style: TextStyle(
                                                                                                      fontWeight: FontWeight.w700,
                                                                                                      fontSize: 14,
                                                                                                      color: percent >= 0 ? Colors.green : Colors.red,
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              thickness: 1,
                                                                              indent: 20,
                                                                              endIndent: 20,
                                                                              color: Colors.grey,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                left: 15.0,
                                                                                top: 8,
                                                                              ),
                                                                              child: Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  "Điểm số theo thời gian",
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.w700,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Center(
                                                                                child: Container(
                                                                                  height: 300,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(left: 15, right: 20),
                                                                                    child: SfCartesianChart(
                                                                                      enableAxisAnimation: true,
                                                                                      legend: Legend(isVisible: true, position: LegendPosition.bottom, toggleSeriesVisibility: true, iconBorderColor: Colors.red, backgroundColor: Color.fromRGBO(0, 8, 22, 0.75), textStyle: TextStyle(color: Colors.white)),
                                                                                      // tooltipBehavior: _tooltipBehavior,
                                                                                      trackballBehavior: _trackballBehavior,
                                                                                      axes: <ChartAxis>[
                                                                                        NumericAxis(
                                                                                          // labelFormat: '{value} M',
                                                                                          numberFormat: NumberFormat.compact(),
                                                                                          majorGridLines: const MajorGridLines(width: 0),
                                                                                          opposedPosition: true,
                                                                                          minimum: 0,
                                                                                          name: 'yAxis1',
                                                                                          // maximum: maxiChart +
                                                                                          //     maxiChart *
                                                                                          //         0.05,
                                                                                        ),
                                                                                      ],
                                                                                      series: <CartesianSeries<ExpenseData, String>>[
                                                                                        SplineAreaSeries<ExpenseData, String>(
                                                                                            splineType: SplineType.monotonic,
                                                                                            // cardinalSplineTension:
                                                                                            // 0.9,
                                                                                            onRendererCreated: (ChartSeriesController controller) {
                                                                                              _chartSeriesController1 = controller;
                                                                                            },
                                                                                            color: Colors.blue,
                                                                                            dataSource: _chartData,
                                                                                            xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                                                                                            yValueMapper: (ExpenseData exp, _) => exp.total,
                                                                                            name: 'Điểm cao nhất',
                                                                                            gradient: (index == 0 || index == 3 || index == 4 || index == 7) ? _linearGradientBlue : _linearGradientYellow,
                                                                                            borderWidth: 3,
                                                                                            borderGradient: (index == 0 || index == 3 || index == 4 || index == 7)
                                                                                                ? LinearGradient(colors: <Color>[
                                                                                              Color.fromRGBO(15, 55, 115, 1.0),
                                                                                            ], stops: <double>[
                                                                                              0.2,
                                                                                            ])
                                                                                                : LinearGradient(colors: <Color>[
                                                                                              Color.fromRGBO(255, 98, 0, 1.0),
                                                                                            ], stops: <double>[
                                                                                              0.2,
                                                                                            ])),
                                                                                        LineSeries<ExpenseData, String>(
                                                                                          color:Colors.green,
                                                                                            animationDuration: 4500,
                                                                                            dataSource: _chartData,
                                                                                            onRendererCreated: (ChartSeriesController controller) {
                                                                                              _chartSeriesController2 = controller;
                                                                                            },
                                                                                            xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                                                                                            yValueMapper: (ExpenseData exp, _) => exp.count,
                                                                                            yAxisName: 'yAxis1',
                                                                                            markerSettings: MarkerSettings(isVisible: true),
                                                                                            name: 'Số lần chơi')
                                                                                      ],
                                                                                      primaryXAxis: CategoryAxis(
                                                                                        labelPlacement: LabelPlacement.onTicks,
                                                                                        interval: 2,
                                                                                        majorGridLines: MajorGridLines(width: 0),
                                                                                        //Hide the axis line of x-axis
                                                                                        axisLine: AxisLine(width: 0),
                                                                                      ),
                                                                                    )
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                    itemCount:
                                                                        4,
                                                                  )
                                                                : Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      loadingDataChart ==
                                                                              true
                                                                          ? LoadingDot()
                                                                          : ErrorsNoti(
                                                                              text: "Không có dữ liệu \n trong thời gian này !",
                                                                              style: TextStyle(color: Colors.black54, fontSize: 20),
                                                                            )
                                                                    ],
                                                                  )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12.0)),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Danh mục Game Toán học",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15,
                                                          right: 15,
                                                          bottom: 15),
                                                  child: Center(
                                                    child: CustomScrollView(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      shrinkWrap: true,
                                                      slivers: [
                                                        SliverToBoxAdapter(
                                                            child: _deals
                                                                    .isNotEmpty
                                                                ? GridView
                                                                    .builder(
                                                                    physics:
                                                                        NeverScrollableScrollPhysics(),
                                                                    shrinkWrap:
                                                                        true,
                                                                    gridDelegate:
                                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                                      crossAxisCount:
                                                                          !Responsive.isMobile(context)
                                                                              ? 2
                                                                              : 1,
                                                                      crossAxisSpacing:
                                                                          10,
                                                                      mainAxisSpacing:
                                                                          10,
                                                                      mainAxisExtent: !Responsive.isMobileSmall(
                                                                              context)
                                                                          ? 450
                                                                          : 500, // here set custom Height You Want
                                                                    ),
                                                                    // return a custom ItemCard
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      var x = getServiceName(
                                                                          "MATH",
                                                                          index);
                                                                      _chartData = getChartgameName(
                                                                          index,
                                                                          "MATH",
                                                                          typeTimeChart);
                                                                      checkPrecent(
                                                                          "MATH",
                                                                          index);
                                                                      return Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.transparent,
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.grey,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(12.0)),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                left: 15.0,
                                                                                top: 7,
                                                                                bottom: 6,
                                                                              ),
                                                                              child: Container(
                                                                                width: double.infinity,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          "Điểm số của Game ${x.key}",
                                                                                          style: TextStyle(
                                                                                            fontWeight: FontWeight.w700,
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                        ),
                                                                                        Spacer(),
                                                                                        Center(
                                                                                          child: IconButton(
                                                                                            icon: Icon(Icons.info_outline),
                                                                                            // Replace 'add' with the desired icon
                                                                                            onPressed: ()  {
                                                                                              // Add your button press logic here
                                                                                              // Scaffold.of(context).openEndDrawer();
                                                                                              filter['gameName'] = index;
                                                                                              filter['gameType'] = "MATH";
                                                                                              setState(() {

                                                                                              });

                                                                                              _scaffoldKey.currentState!.openEndDrawer();

                                                                                              print('Button Pressed!');
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 5),
                                                                                    !Responsive.isMobileSmall(context)
                                                                                        ? Row(
                                                                                            children: [
                                                                                              Text(
                                                                                                "${getTotalForService(priceList, 'MATH', index).toCurrency()}",
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.w700,
                                                                                                  fontSize: 22,
                                                                                                  color: (index == 0 || index == 3 || index == 4 || index == 7) ? Color.fromRGBO(15, 55, 115, 1.0) : Color.fromRGBO(255, 98, 0, 1.0),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(width: 50),
                                                                                              Align(
                                                                                                alignment: Alignment.bottomCenter,
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                                  children: [
                                                                                                    (percent >= 0) ? Icon(Icons.arrow_upward, size: 18, color: Colors.green) : Icon(Icons.arrow_downward_sharp, size: 18, color: Colors.red),
                                                                                                    Text(
                                                                                                      "${(percent >= 0 ? (percent * 100) : (percent * -1 * 100)).toStringAsFixed(2)} % ",
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: TextStyle(
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                        fontSize: 14,
                                                                                                        color: percent >= 0 ? Colors.green : Colors.red,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        : Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                "${getTotalForService(priceList, "MATH", index)}",
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.w700,
                                                                                                  fontSize: 22,
                                                                                                  color: (index == 0 || index == 3 || index == 4 || index == 7) ? Color.fromRGBO(15, 55, 115, 1.0) : Color.fromRGBO(255, 98, 0, 1.0),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(width: 50),
                                                                                              Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                children: [
                                                                                                  (percent >= 0) ? Icon(Icons.arrow_upward, size: 18, color: Colors.green) : Icon(Icons.arrow_downward_sharp, size: 18, color: Colors.red),
                                                                                                  Text(
                                                                                                    "${(percent >= 0 ? (percent * 100) : (percent * -1 * 100)).toStringAsFixed(2)} % ",
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    style: TextStyle(
                                                                                                      fontWeight: FontWeight.w700,
                                                                                                      fontSize: 14,
                                                                                                      color: percent >= 0 ? Colors.green : Colors.red,
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              thickness: 1,
                                                                              indent: 20,
                                                                              endIndent: 20,
                                                                              color: Colors.grey,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                left: 15.0,
                                                                                top: 8,
                                                                              ),
                                                                              child: Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  "Điểm số theo thời gian",
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.w700,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Center(
                                                                                child: Container(
                                                                                  height: 300,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(left: 15, right: 20),
                                                                                    child: SfCartesianChart(
                                                                                      enableAxisAnimation: true,
                                                                                      legend: Legend(isVisible: true, position: LegendPosition.bottom, toggleSeriesVisibility: true, iconBorderColor: Colors.red, backgroundColor: Color.fromRGBO(0, 8, 22, 0.75), textStyle: TextStyle(color: Colors.white)),
                                                                                      // tooltipBehavior: _tooltipBehavior,
                                                                                      trackballBehavior: _trackballBehavior,
                                                                                      axes: <ChartAxis>[
                                                                                        NumericAxis(
                                                                                          // labelFormat: '{value} M',
                                                                                          numberFormat: NumberFormat.compact(),
                                                                                          majorGridLines: const MajorGridLines(width: 0),
                                                                                          opposedPosition: true,
                                                                                          minimum: 0,
                                                                                          name: 'yAxis1',
                                                                                          // maximum: maxiChart +
                                                                                          //     maxiChart *
                                                                                          //         0.05,
                                                                                        ),
                                                                                      ],
                                                                                      series: <CartesianSeries<ExpenseData, String>>[
                                                                                        SplineAreaSeries<ExpenseData, String>(
                                                                                            splineType: SplineType.monotonic,
                                                                                            // cardinalSplineTension:
                                                                                            // 0.9,
                                                                                            onRendererCreated: (ChartSeriesController controller) {
                                                                                              _chartSeriesController1 = controller;
                                                                                            },
                                                                                            color: Colors.blue,
                                                                                            dataSource: _chartData,
                                                                                            xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                                                                                            yValueMapper: (ExpenseData exp, _) => exp.total,
                                                                                            name: 'Điểm cao nhất',
                                                                                            gradient: (index == 0 || index == 3 || index == 4 || index == 7) ? _linearGradientBlue : _linearGradientYellow,
                                                                                            borderWidth: 3,
                                                                                            borderGradient: (index == 0 || index == 3 || index == 4 || index == 7)
                                                                                                ? LinearGradient(colors: <Color>[
                                                                                              Color.fromRGBO(15, 55, 115, 1.0),
                                                                                            ], stops: <double>[
                                                                                              0.2,
                                                                                            ])
                                                                                                : LinearGradient(colors: <Color>[
                                                                                              Color.fromRGBO(255, 98, 0, 1.0),
                                                                                            ], stops: <double>[
                                                                                              0.2,
                                                                                            ])),
                                                                                        LineSeries<ExpenseData, String>(
                                                                                            animationDuration: 4500,color:Colors.green,
                                                                                            dataSource: _chartData,
                                                                                            onRendererCreated: (ChartSeriesController controller) {
                                                                                              _chartSeriesController2 = controller;
                                                                                            },
                                                                                            xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                                                                                            yValueMapper: (ExpenseData exp, _) => exp.count,
                                                                                            yAxisName: 'yAxis1',
                                                                                            markerSettings: MarkerSettings(isVisible: true),
                                                                                            name: 'Số lần chơi')
                                                                                      ],
                                                                                      primaryXAxis: CategoryAxis(
                                                                                        labelPlacement: LabelPlacement.onTicks,
                                                                                        interval: 2,
                                                                                        majorGridLines: MajorGridLines(width: 0),
                                                                                        //Hide the axis line of x-axis
                                                                                        axisLine: AxisLine(width: 0),
                                                                                      ),
                                                                                    )
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                    itemCount:
                                                                        2,
                                                                  )
                                                                : Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      loadingDataChart ==
                                                                              true
                                                                          ? LoadingDot()
                                                                          : ErrorsNoti(
                                                                              text: "Không có dữ liệu \n trong thời gian này !",
                                                                              style: TextStyle(color: Colors.black54, fontSize: 20),
                                                                            )
                                                                    ],
                                                                  )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            )
                          : AnimatedPositioned(
                              width: expandScreen ? constraints.maxWidth : 0,
                              duration: Duration(milliseconds: 1000),
                              curve: Curves.fastOutSlowIn,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 16.0, left: 8.0, top: 8),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height - 80,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(18.0),
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: LoadingIndicator(
                                      isLoading: true, child: SizedBox()),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 11.0),
                  child: buildEndDrawerInfo(),
                ),
              ),
            ]),
          );
        },
      ),
      endDrawer: NavigationDrawerWidget(fromDate: filter['fromDateTime'], toDate: filter['toDateTime'], gameType: filter['gameType'], gameName: filter['gameName'], id: filter['id'],),
    );
  }

  Widget buildEndDrawerInfo() {
    // print(_toggleValue);
    return Container(
        width: 480,
        height: MediaQuery.of(context).size.height - 80,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(18.0),
          ),
          color: Colors.white,
        ),
        child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            reverseDuration: const Duration(milliseconds: 100),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          IconButton(
                              iconSize: 28,
                              onPressed: () {},
                              icon: Icon(
                                Icons.close,
                                size: 28,
                              )),
                          Spacer(),
                          Spacer(),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 160,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "Thông tin tài khoản",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Form(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      DMCLTextFiledWeb(
                                        lock: true,
                                        controller: acountIDController,
                                        labelText: 'Mã tài khoản',
                                        icon: Icons.verified_user,
                                      ),
                                      DMCLTextFiledWeb(   lock: true,
                                        controller: phoneController,
                                        labelText: 'Số điện thoại',
                                        icon: Icons.person,
                                      ),
                                      DMCLTextFiledWeb(   lock: true,
                                        controller: nameController,
                                        labelText: 'Tên tài khoản',
                                        icon: Icons.person,
                                      ),
                                      DMCLTextFiledWeb(   lock: true,
                                        controller: genderIdController,
                                        labelText: 'Giới tính',
                                        icon: Icons.store,
                                      ),
                                      DMCLTextFiledWeb(   lock: true,
                                        controller: dobController,
                                        labelText: 'Ngày sinh',
                                        icon: Icons.store,
                                      ),
                                      // DMCLTextFiledPassWeb(
                                      //   controller: passwordController,
                                      //   labelText: 'Mật khẩu',
                                      //   icon: Icons.lock,
                                      // ),
                                      DMCLTextFiledPassWeb(   lock: true,
                                        controller: loginCodeController,
                                        labelText: 'Mật khẩu cấp hai',
                                        icon: Icons.lock,
                                      ),

                                      SizedBox(height: 20.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
}

class ExpenseData {
  ExpenseData(
    this.expenseCategory,
    this.total,
    this.count,
  );

  final String expenseCategory;
  final int total;
  final int count;

  @override
  String toString() {
    return 'ExpenseData(label: $expenseCategory, expense1: $total,)';
  }
}
