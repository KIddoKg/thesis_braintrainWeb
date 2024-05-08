import 'package:bmeit_webadmin/helper/formatter.dart';
import 'package:bmeit_webadmin/res/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:bmeit_webadmin/res/colors.dart';

import '../../../models/adminModel.dart';
import '../../../models/transactionModel.dart';
import '../../../services/services.dart';
import '../../../share/share_widget.dart';
import '../../../widget/share_widget.dart';
import '../../../widget/style.dart';

class StatisticalPage extends StatefulWidget {
  ChartService? chartType;

  StatisticalPage({
    Key? key,
    required this.chartType,
  }) : super(key: key);

  @override
  State<StatisticalPage> createState() => _StatisticalPageState();
}

class _StatisticalPageState extends State<StatisticalPage> {
  late List<ExpenseData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  late TrackballBehavior _trackballBehavior;

  bool checkDays = true;
  bool checkWeek = false;
  bool checkMonth = false;
  bool expandScreen = false;
  bool testBug = false;
  bool runSave = true;
  bool loadingDataChart = false;

  int nextOrback = 0;
  int maxiChart = 0;
  int totalPrice = 0;
  int priceGrow = 0;

  double percent = 0.0;

  List<TransactionModel> _deals = [];

  Map<String, dynamic> filterData = {
    "fromDateTime": DateTime.now().millisecondsSinceEpoch,
    "toDateTime": DateTime.now().millisecondsSinceEpoch,
  };
  Map<String, dynamic> filterDataBefore = {
    "fromDateTime": DateTime.now().millisecondsSinceEpoch,
    "toDateTime": DateTime.now().millisecondsSinceEpoch,
    'serviceType': '',
  };
  Map<String, dynamic> filter = {
    'fromDateTime': DateTime.now().millisecondsSinceEpoch,
    'toDateTime': DateTime.now().millisecondsSinceEpoch,
    'serviceType': '',
  };


  @override
  void initState() {
    onSelectedDate(0);
    _chartData = getDataNull();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        expandScreen = true;
        _runCheck();
      });
      await initData();
      print(' widget binding : $expandScreen');
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
            color: Color.fromRGBO(0, 8, 22, 0.75),
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          child: Row(
            children: [
              Center(
                  child: Container(
                      padding: EdgeInsets.only(top: 11, left: 7),
                      height: 40,
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
                            ' : ${intValue?.toCurrency()} VNĐ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(255, 255, 255, 1),
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

  Future<void> initData() async {
    var x = getServiceTypeIcon(widget.chartType!);
    getDateBefore();
    filter['fromDateTime'] = filterData['fromDateTime'];
    filter['toDateTime'] = filterData['toDateTime'];
    filter['serviceType'] = x.number;
    filterDataBefore['serviceType'] = x.number;
    loadingDataChart = true;
    var resBefore =
        await Services.instance.getDataChart(filter: filterDataBefore);

    if (resBefore != null) {
      var res = await Services.instance.getDataChart(filter: filter);
      loadingDataChart = false;
      if (res != null) {
        var data = res.castList<TransactionModel>();
        _deals = data;
        maxiChart = 0;
        for (var e in _deals) {
          maxiChart += e.amount;
        }
        totalPrice = maxiChart;
        if (maxiChart < 100000) {
          maxiChart = 500000;
        }
        setState(() {});
        _chartData = getChartData();
      } else {
        showAlertAction(context, 'Thông báo',
            'Lấy dữ liệu từ Server thất bại, hãy thử lại!', initData);
      }
      var data = resBefore.castList<TransactionModel>();
      List<TransactionModel> _dealsBefore = [];
      _dealsBefore = data;
      priceGrow = 0;
      for (var e in _dealsBefore) {
        priceGrow += e.amount;
        setState(() {});
      }
    } else {
      showAlertAction(context, 'Thông báo',
          'Lấy dữ liệu từ Server thất bại, hãy thử lại!', initData);
    }
    if (totalPrice != 0 && priceGrow != 0) {
      percent = (totalPrice - priceGrow) / priceGrow;
    } else if (totalPrice != 0 && priceGrow == 0) {
      percent = 1;
    } else if (totalPrice == 0 && priceGrow != 0) {
      percent = -1;
    } else {
      percent = 0;
    }
    setState(() {});
  }

  Future<void> _runCheck() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    testBug = true;
    setState(() {});
  }

  List<ExpenseData> getChartData() {
    var data = getNull();
    if (checkWeek == true) {
      data = getChartDataWeek();
    } else if (checkMonth == true) {
      data = getChartMonth();
    } else if (checkDays == true) {
      data = getChartDataDays();
    }

    final List<ExpenseData> chartData = data;
    return chartData;
  }

  List<ExpenseData> getDataDealinDays() {
    var fromDateTime =
        filterData['fromDateTime']; // Assuming you have this variable
    var toDateTime =
        filterData['toDateTime']; // Assuming you have this variable

    DateTime fromDate = DateTime.fromMillisecondsSinceEpoch(fromDateTime);
    DateTime toDate = DateTime.fromMillisecondsSinceEpoch(toDateTime);

    // Sử dụng một Map để theo dõi tổng số tiền cho mỗi ngày
    Map<int, int> dailyExpenses = {};
    Map<int, int> dailySuccess = {};
    Map<int, int> dailyCancel = {};
    Map<int, int> dailyFailed = {};
    Map<int, int> dailyProcess = {};

    // Đảm bảo tạo các mục cho tất cả các ngày trong khoảng thời gian
    for (var day = 1; day <= toDate.day; day++) {
      dailyExpenses[day] ??= 0;
      dailySuccess[day] ??= 0;
      dailyCancel[day] ??= 0;
      dailyFailed[day] ??= 0;
      dailyProcess[day] ??= 0;

      // Calculate the next day, considering different month lengths
    }

    for (var e in _deals) {
      DateTime checkDay = DateTime.fromMillisecondsSinceEpoch(e.createDate);

      if (checkDay.isAfter(fromDate) && checkDay.isBefore(toDate)) {
        dailyExpenses[checkDay.day] =
            (dailyExpenses[checkDay.day]! + (e.amount))!;
      }
      if (checkDay.isAfter(fromDate) &&
          checkDay.isBefore(toDate) &&
          e.state == "Thành công") {
        dailySuccess[checkDay.day] = (dailySuccess[checkDay.day]! + e.amount)!;
      }
      if (checkDay.isAfter(fromDate) &&
          checkDay.isBefore(toDate) &&
          e.state == "Huỷ") {
        dailyCancel[checkDay.day] = (dailyCancel[checkDay.day]! + e.amount)!;
      }
      if (checkDay.isAfter(fromDate) &&
          checkDay.isBefore(toDate) &&
          e.state == "Thất bại") {
        dailyFailed[checkDay.day] = (dailyFailed[checkDay.day]! + e.amount)!;
      }
      if (checkDay.isAfter(fromDate) &&
          checkDay.isBefore(toDate) &&
          e.state == "Đang xử lý") {
        dailyProcess[checkDay.day] = (dailyProcess[checkDay.day]! + e.amount)!;
      }
    }

    final List<ExpenseData> chartData = [];

    // Tạo các đối tượng ExpenseData từ tổng số tiền hàng ngày
    dailyExpenses.forEach((day, totalAmount) {
      if (totalAmount > maxiChart) {
        maxiChart = totalAmount;
        setState(() {});
      }
      chartData.add(
        ExpenseData(
          '${day}',
          totalAmount,
          dailySuccess[day] ?? 0,
          // Giả sử expense2, expense3, expense4, expense5 cùng bằng tổng số tiền
          dailyProcess[day] ?? 0,
          // Giả sử expense2, expense3, expense4, expense5 cùng bằng tổng số tiền
          dailyFailed[day] ?? 0,
          // Giả sử expense2, expense3, expense4, expense5 cùng bằng tổng số tiền
          dailyCancel[day] ??
              0, // Giả sử expense2, expense3, expense4, expense5 cùng bằng tổng số tiền
        ),
      );
    });

    return chartData;
  }

  List<ExpenseData> getDataDealinWeeks() {
    var fromDateTime =
        filterData['fromDateTime']; // Assuming you have this variable
    var toDateTime =
        filterData['toDateTime']; // Assuming you have this variable

    DateTime fromDate = DateTime.fromMillisecondsSinceEpoch(fromDateTime);
    DateTime toDate = DateTime.fromMillisecondsSinceEpoch(toDateTime);

    // Calculate the number of weeks between fromDate and toDate
    int weeks = (toDate.difference(fromDate).inDays / 7).ceil();

    // Use maps to track total expenses and different categories of expenses by week
    Map<int, int> weeklyExpenses = {};
    Map<int, int> weeklySuccess = {};
    Map<int, int> weeklyCancel = {};
    Map<int, int> weeklyFailed = {};
    Map<int, int> weeklyProcess = {};

    for (var e in _deals) {
      DateTime checkDay = DateTime.fromMillisecondsSinceEpoch(e.createDate);

      if (checkDay.isAfter(fromDate) && checkDay.isBefore(toDate)) {
        // Calculate the week number for the current deal
        int weekNumber = checkDay.difference(fromDate).inDays ~/ 7 + 1;
        print(weekNumber);

        // Update weekly expenses and categories accordingly
        weeklyExpenses[weekNumber] =
            (weeklyExpenses[weekNumber] ?? 0) + e.amount;

        if (e.state == "Thành công") {
          weeklySuccess[weekNumber] =
              (weeklySuccess[weekNumber] ?? 0) + e.amount;
        }
        if (e.state == "Huỷ") {
          weeklyCancel[weekNumber] = (weeklyCancel[weekNumber] ?? 0) + e.amount;
        }
        if (e.state == "Thất bại") {
          weeklyFailed[weekNumber] = (weeklyFailed[weekNumber] ?? 0) + e.amount;
        }
        if (e.state == "Đang xử lý") {
          weeklyProcess[weekNumber] =
              (weeklyProcess[weekNumber] ?? 0) + e.amount;
        }
      }
    }

    final List<ExpenseData> chartData = [];

    // Create ExpenseData objects from weekly data
    for (int weekNumber = 1; weekNumber <= weeks; weekNumber++) {
      DateTime weekStart = fromDate.add(Duration(days: (weekNumber - 1) * 7));
      DateTime weekEnd = weekStart.add(Duration(days: 6));

      if (weekEnd.isAfter(toDate)) {
        weekEnd = toDate;
        print("qua tháng");
      }
      chartData.add(
        ExpenseData(
          '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}',
          weeklyExpenses[weekNumber] ?? 0,
          weeklySuccess[weekNumber] ?? 0,
          weeklyProcess[weekNumber] ?? 0,
          weeklyFailed[weekNumber] ?? 0,
          weeklyCancel[weekNumber] ?? 0,
        ),
      );
    }

    return chartData;
  }

  List<ExpenseData> getDataNull() {
    final List<ExpenseData> chartData = [];
    chartData.add(
      ExpenseData(
        '',
        0,
        0,
        0,
        0,
        0,
      ),
    );

    return chartData;
  }

  List<ExpenseData> getDataDealinMonths() {
    var fromDateTime =
        filterData['fromDateTime']; // Assuming you have this variable
    var toDateTime =
        filterData['toDateTime']; // Assuming you have this variable

    DateTime fromDate = DateTime.fromMillisecondsSinceEpoch(fromDateTime);
    DateTime toDate = DateTime.fromMillisecondsSinceEpoch(toDateTime);
    print("fromDate${fromDate}");

    Map<int, int> monthlyExpenses = {};
    Map<int, int> monthlySuccess = {};
    Map<int, int> monthlyCancel = {};
    Map<int, int> monthlyFailed = {};
    Map<int, int> monthlyProcess = {};

    for (var e in _deals) {
      DateTime checkDay = DateTime.fromMillisecondsSinceEpoch(e.createDate);

      if (checkDay.isAfter(fromDate) && checkDay.isBefore(toDate)) {
        // Calculate the month number for the current deal
        int monthNumber = checkDay.month;
        print(monthNumber);

        // Update monthly expenses and categories accordingly
        monthlyExpenses[monthNumber] =
            (monthlyExpenses[monthNumber] ?? 0) + e.amount;

        if (e.state == "Thành công") {
          monthlySuccess[monthNumber] =
              (monthlySuccess[monthNumber] ?? 0) + e.amount;
        }
        if (e.state == "Huỷ") {
          monthlyCancel[monthNumber] =
              (monthlyCancel[monthNumber] ?? 0) + e.amount;
        }
        if (e.state == "Thất bại") {
          monthlyFailed[monthNumber] =
              (monthlyFailed[monthNumber] ?? 0) + e.amount;
        }
        if (e.state == "Đang xử lý") {
          monthlyProcess[monthNumber] =
              (monthlyProcess[monthNumber] ?? 0) + e.amount;
        }
      }
    }

    final List<ExpenseData> chartData = [];

    // Create ExpenseData objects from monthly data
    for (int monthNumber = 1; monthNumber <= toDate.month; monthNumber++) {
      chartData.add(
        ExpenseData(
          '${monthNumber}/${toDate.year}',
          monthlyExpenses[monthNumber] ?? 0,
          monthlySuccess[monthNumber] ?? 0,
          monthlyProcess[monthNumber] ?? 0,
          monthlyFailed[monthNumber] ?? 0,
          monthlyCancel[monthNumber] ?? 0,
        ),
      );
    }

    return chartData;
  }

  List<ExpenseData> getChartMonth() {
    return getDataDealinMonths();
  }

  List<ExpenseData> getChartDataWeek() {
    return getDataDealinWeeks();
  }

  List<ExpenseData> getNull() {
    return getDataNull();
  }

  List<ExpenseData> getChartDataDays() {
    return getDataDealinDays();
  }

  void checkNowDays() {
    DateTime nowDate = DateTime.now();
    print(filterData['toDateTime'] == DateTime.now().millisecondsSinceEpoch);
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
      print("check nonth");
      startDate = DateTime(now.year - 1, 1, 1);
      endDate = DateTime(now.year - 1, 12, 31);
    }
    if (runSave == true) {
      filterDataBefore['fromDateTime'] = startDate.millisecondsSinceEpoch;

      filterDataBefore['toDateTime'] = endDate.millisecondsSinceEpoch;
      print(filterDataBefore['fromDateTime']);
      print(filterDataBefore['toDateTime']);
    }
    setState(() {});
  }

  final LinearGradient _linearGradient = LinearGradient(
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
            print("này là cộng tháng");
            startDate = DateTime(now.year, now.month + 1, 1);
            endDate = nowDate;
          } else if (nowDate.year > now.year) {
            print("này là gì ko bt");
            startDate = DateTime(now.year, now.month + 1, 1);
            int lastDayOfNextMonth = DateTime(now.year, now.month + 2, 0).day;
            endDate = DateTime(now.year, now.month + 1, lastDayOfNextMonth);
          } else if (nowDate.year == now.year &&
              nowDate.month > now.month + 1) {
            startDate = DateTime(now.year, now.month + 1, 1);
            int lastDayOfNextMonth = DateTime(now.year, now.month + 2, 0).day;
            endDate = DateTime(now.year, now.month + 1, lastDayOfNextMonth);
          } else {
            print("BBb");
            runSave = false;
            setState(() {});
          }

          break;
      }
    } else if (checkMonth == true) {
      print("check nonth");
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
            print("này là test");
            startDate = DateTime(nowDate.year, 1, 1);
            endDate = nowDate;
          } else if (nowDate.isAfter(DateTime(now.year - 1, 12, 31)) &&
              nowDate.year > now.year) {
            startDate = DateTime(now.year + 1, 1, 1);
            endDate = DateTime(now.year + 1, 12, 31);
          } else {
            print("BBb");
            runSave = false;
            setState(() {});
          }

          break;
      }
    }
    if (runSave == true) {
      filterData['fromDateTime'] = startDate.millisecondsSinceEpoch;
      print(filterData['fromDateTime']);
      filterData['toDateTime'] = endDate.millisecondsSinceEpoch;
    }
    setState(() {});
  }

  String formatLargeNumber(int number) {
    if (number >= 1000000) {
      int millionValue = (number / 1000000.0).toInt();
      return '${millionValue.toStringAsFixed(1)} M';
    } else {
      return number.toString();
    }
  }

  @override
  void dispose() {
    print("object");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkNowDays();
    var x = getServiceTypeIcon(widget.chartType!);
    return Scaffold(
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
                x.key,
                width: 25,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                x.name,
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
            child: Container(
              // width: 500,
              height: constraints.maxHeight,
              child: Stack(
                children: <Widget>[
                  testBug == true
                      ? Padding(
                          padding: const EdgeInsets.only(
                              right: 16.0, left: 8.0, top: 8, bottom: 16),
                          child: AnimatedContainer(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(18.0),
                                ),
                                color: Colors.white,
                              ),
                              duration: Duration(milliseconds: 300),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      if (!Responsive.isMobile(context))
                                        Center(
                                          child: Container(
                                            width: 242,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(6.0),
                                              ),
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(6.0),
                                                      topLeft:
                                                          Radius.circular(6.0),
                                                    ),
                                                    color: checkDays == true
                                                        ? AppColors.bgButton
                                                        : Colors.white,
                                                  ),
                                                  width: 80,
                                                  child: TextButton(
                                                      onPressed: () async {
                                                        checkMonth = false;
                                                        checkDays = true;
                                                        checkWeek = false;
                                                        onSelectedDate(0);
                                                        await initData();
                                                        _chartData =
                                                            getChartDataDays();

                                                        setState(() {});
                                                      },
                                                      child: Text(
                                                        "Ngày",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w600),
                                                      )),
                                                ),
                                                Container(
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    color: checkWeek == true
                                                        ? AppColors.bgButton
                                                        : Colors.white,
                                                    border: Border(
                                                      left: BorderSide(
                                                        color: Colors.black,
                                                        width: 1.0,
                                                      ),
                                                      right: BorderSide(
                                                        color: Colors.black,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                  child: TextButton(
                                                      onPressed: () async {
                                                        checkMonth = false;
                                                        checkDays = false;
                                                        checkWeek = true;
                                                        onSelectedDate(0);
                                                        await initData();
                                                        _chartData =
                                                            getChartDataWeek();

                                                        setState(() {});
                                                      },
                                                      child: Text(
                                                        "Tuần",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w600),
                                                      )),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(6.0),
                                                      topRight:
                                                          Radius.circular(6.0),
                                                    ),
                                                    color: checkMonth == true
                                                        ? AppColors.bgButton
                                                        : Colors.white,
                                                  ),
                                                  width: 80,
                                                  child: TextButton(
                                                      onPressed: () async {
                                                        checkDays = false;
                                                        checkWeek = false;
                                                        checkMonth = true;
                                                        onSelectedDate(0);
                                                        await initData();
                                                        _chartData =
                                                            getChartMonth();

                                                        setState(() {});
                                                      },
                                                      child: Text(
                                                        "Tháng",
                                                        style: TextStyle(
                                                            color: Colors.black,
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
                                      if (!Responsive.isMobile(context))
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Spacer(),
                                            Flexible(
                                                flex: 5,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    DMCLPageButton(
                                                      Icons.arrow_back_ios_new,
                                                      backgroundColor:
                                                          Colors.white,
                                                      disable: false,
                                                      onTap: () async {
                                                        onSelectedDate(1);
                                                        await initData();
                                                        setState(() {});
                                                      },
                                                      fontColor:
                                                          AppColors.primaryColor,
                                                      border: Colors.grey,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => {},
                                                      child: Container(
                                                        width: 200,
                                                        child: DMCLCard(
                                                          backgroundColor:
                                                              '#f7f7f7'.toColor(),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                (filterData['fromDateTime']
                                                                        as int)
                                                                    .toDateString(
                                                                        format:
                                                                            'dd/MM/yyyy'),
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    color: GlobalStyles
                                                                        .text45),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                color: GlobalStyles
                                                                    .backgroundDisableColor,
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
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        width: 200,
                                                        child: DMCLCard(
                                                          backgroundColor:
                                                              '#f7f7f7'.toColor(),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                (filterData['toDateTime']
                                                                        as int)
                                                                    .toDateString(
                                                                        format:
                                                                            'dd/MM/yyyy'),
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    color: GlobalStyles
                                                                        .text45),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                color: GlobalStyles
                                                                    .backgroundDisableColor,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DMCLPageButton(
                                                      Icons.arrow_forward_ios,
                                                      backgroundColor:
                                                          Colors.white,
                                                      disable: !runSave,
                                                      onTap: () async {
                                                        onSelectedDate(2);
                                                        await initData();
                                                        setState(() {});
                                                      },
                                                      fontColor:
                                                          AppColors.primaryColor,
                                                      border: Colors.grey,
                                                    ),
                                                  ],
                                                )),
                                            Spacer(),
                                          ],
                                        ),
                                      _deals.isNotEmpty
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 75.0,
                                                      top: 8,
                                                      bottom: 8),
                                                  child: Container(
                                                      child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "${x.name.toUpperCase()} (Triệu VNĐ)",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14),
                                                      ),
                                                      !Responsive.isMobileSmall(
                                                              context)
                                                          ? Row(
                                                              // crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  "${totalPrice.toCurrency()}",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize: 22,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 50),
                                                                Align(
                                                                  alignment: Alignment
                                                                      .bottomCenter,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      (percent >=
                                                                              0)
                                                                          ? Icon(
                                                                              Icons
                                                                                  .arrow_upward,
                                                                              size:
                                                                                  18,
                                                                              color: Colors
                                                                                  .green)
                                                                          : Icon(
                                                                              Icons
                                                                                  .arrow_downward_sharp,
                                                                              size:
                                                                                  18,
                                                                              color:
                                                                                  Colors.red),
                                                                      Text(
                                                                        "${(percent >= 0 ? (percent * 100) : (percent * -1 * 100)).toStringAsFixed(2)} % ",
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              14,
                                                                          color: percent >=
                                                                                  0
                                                                              ? Colors.green
                                                                              : Colors.red,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${totalPrice.toCurrency()}",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize: 22,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 50),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    (percent >= 0)
                                                                        ? Icon(
                                                                            Icons
                                                                                .arrow_upward,
                                                                            size:
                                                                                18,
                                                                            color: Colors
                                                                                .green)
                                                                        : Icon(
                                                                            Icons
                                                                                .arrow_downward_sharp,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                Colors.red),
                                                                    Text(
                                                                      "${(percent >= 0 ? (percent * 100) : (percent * -1 * 100)).toStringAsFixed(2)} % ",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        fontSize:
                                                                            14,
                                                                        color: percent >= 0
                                                                            ? Colors
                                                                                .green
                                                                            : Colors
                                                                                .red,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                    ],
                                                  )),
                                                ),
                                                Center(
                                                    child: Container(
                                                  // height: 787,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      260,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 28, right: 28),
                                                    child: SfCartesianChart(
                                                      // title:
                                                      //     ChartTitle(text: '${x.name}\n (triệu VNĐ)'),

                                                      legend:Legend(
                                                          isVisible: MediaQuery.of(context).size.height -260 > 200? true : false,
                                                          position: LegendPosition
                                                              .bottom,
                                                          toggleSeriesVisibility:
                                                              true,
                                                          iconBorderColor:
                                                              Colors.red,
                                                          backgroundColor:
                                                              Color.fromRGBO(
                                                                  0, 8, 22, 0.75),
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.white)),
                                                      // tooltipBehavior: _tooltipBehavior,
                                                      enableAxisAnimation: true,
                                                      trackballBehavior:
                                                          _trackballBehavior,
                                                      // primaryYAxis: NumericAxis(
                                                      //   // labelFormat: '{value} M',
                                                      //   numberFormat: NumberFormat.compact(),
                                                      //   minimum: 0,
                                                      //   maximum:
                                                      //   maxiChart + maxiChart * 0.05,
                                                      // ),
                                                      primaryYAxis: NumericAxis(
                                                        // labelFormat: '{value} M',
                                                        numberFormat: NumberFormat
                                                            .compact(),
                                                        minimum: 0,
                                                        // maximum: maxiChart +
                                                        //     maxiChart *
                                                        //         0.05,
                                                      ),
                                                      series: <ChartSeries>[
                                                        SplineAreaSeries<ExpenseData,
                                                                String>(
                                                            splineType: SplineType
                                                                .monotonic,
                                                            // cardinalSplineTension: 0.9,
                                                            color: Colors.blue,
                                                            dataSource:
                                                                _chartData,
                                                            xValueMapper: (ExpenseData
                                                                        exp,
                                                                    _) =>
                                                                exp
                                                                    .expenseCategory,
                                                            yValueMapper:
                                                                (ExpenseData exp,
                                                                        _) =>
                                                                    exp.total,
                                                            name:
                                                                'Tổng Test',
                                                            gradient:
                                                                _linearGradient,
                                                            // markerSettings: MarkerSettings(
                                                            //   isVisible: true,
                                                            //
                                                            // ),
                                                            borderWidth: 3,
                                                            borderGradient:
                                                                const LinearGradient(
                                                                    colors: <Color>[
                                                                  Color.fromRGBO(
                                                                      15,
                                                                      55,
                                                                      115,
                                                                      1.0),
                                                                ],
                                                                    stops: <double>[
                                                                  0.2,
                                                                ])),
                                                        SplineSeries<ExpenseData,
                                                            String>(
                                                          color: Colors.green,
                                                          splineType: SplineType
                                                              .monotonic,
                                                          dashArray: <double>[
                                                            5,
                                                            5
                                                          ],
                                                          dataSource: _chartData,
                                                          xValueMapper: (ExpenseData
                                                                      exp,
                                                                  _) =>
                                                              exp.expenseCategory,
                                                          yValueMapper:
                                                              (ExpenseData exp,
                                                                      _) =>
                                                                  exp.success,
                                                          name: 'Thành công',
                                                          // markerSettings: MarkerSettings(
                                                          //   isVisible: true,
                                                          // )
                                                        ),
                                                        LineSeries<ExpenseData,
                                                            String>(
                                                          color: Colors.yellow,
                                                          dataSource: _chartData,
                                                          xValueMapper: (ExpenseData
                                                                      exp,
                                                                  _) =>
                                                              exp.expenseCategory,
                                                          yValueMapper:
                                                              (ExpenseData exp,
                                                                      _) =>
                                                                  exp.process,
                                                          dashArray: <double>[
                                                            5,
                                                            5
                                                          ],
                                                          name: 'Chờ xử lý',
                                                          // markerSettings: MarkerSettings(
                                                          //   isVisible: true,
                                                          // )
                                                        ),
                                                        SplineSeries<ExpenseData,
                                                            String>(
                                                          splineType: SplineType
                                                              .monotonic,
                                                          color: Colors.orange,
                                                          dataSource: _chartData,
                                                          xValueMapper: (ExpenseData
                                                                      exp,
                                                                  _) =>
                                                              exp.expenseCategory,
                                                          yValueMapper:
                                                              (ExpenseData exp,
                                                                      _) =>
                                                                  exp.cancel,
                                                          name: 'Đã Huỷ',
                                                          // markerSettings: MarkerSettings(
                                                          //   isVisible: true,
                                                          // )
                                                        ),
                                                        LineSeries<ExpenseData,
                                                            String>(
                                                          color: Colors.redAccent,
                                                          dataSource: _chartData,
                                                          xValueMapper: (ExpenseData
                                                                      exp,
                                                                  _) =>
                                                              exp.expenseCategory,
                                                          yValueMapper:
                                                              (ExpenseData exp,
                                                                      _) =>
                                                                  exp.failed,
                                                          name: 'Thất bại',
                                                          // markerSettings: MarkerSettings(
                                                          //   isVisible: true,
                                                          // )
                                                        ),
                                                      ],
                                                      primaryXAxis: CategoryAxis(
                                                        labelPlacement:
                                                            LabelPlacement
                                                                .onTicks,
                                                        interval: 2,
                                                        majorGridLines:
                                                            MajorGridLines(
                                                                width: 0),
                                                        //Hide the axis line of x-axis
                                                        axisLine:
                                                            AxisLine(width: 0),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                              ],
                                            )
                                          : Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  loadingDataChart == true
                                                      ? LoadingDot()
                                                      : ErrorsNoti(
                                                          text:
                                                              "Không có dữ liệu \n trong thời gian này !",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black54,
                                                              fontSize: 20),
                                                        )
                                                ],
                                              ),
                                            )
                                    ],
                                  ),

                                ],
                              )
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
                              height: MediaQuery.of(context).size.height - 80,
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
          );
        },
      ),
    );
  }

}

class ExpenseData {
  ExpenseData(
    this.expenseCategory,
    this.total,
    this.success,
    this.process,
    this.failed,
    this.cancel,
  );

  final String expenseCategory;
  final int total;
  final int success;
  final int process;
  final int failed;
  final int cancel;

  @override
  String toString() {
    return 'ExpenseData(label: $expenseCategory, expense1: $total, '
        'expense2: $success, expense3: $cancel, '
        'expense4: $failed, expense5: $process)';
  }
}
