import 'dart:developer';
import 'package:bmeit_webadmin/helper/formatter.dart';
import 'package:bmeit_webadmin/share/share_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../widget/share_widget.dart';
import '../../../widget/style.dart';

class SearchFilter extends StatefulWidget {
  final Function(Map<String, dynamic> filterData) onFilterApplied;
  Animation animated;
  AnimationController animationController;
  Map<String, dynamic> filterData = {
    'dmyIndex': 0,
    "state": null,
    "fromDateTime": DateTime.now().millisecondsSinceEpoch,
    "toDateTime": DateTime.now().millisecondsSinceEpoch,
    "serviceType": null,
  };

  SearchFilter({required this.onFilterApplied,required this.filterData,required this.animated,required this.animationController});

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  bool isReset = false;
  var dmy = ['Tất cả','Tuần này', 'Tháng này', 'Tháng trước', '3 tháng trước', 'Khác'];
  List<Map<String, dynamic>> states = [
    {"title": 'Tất cả', "value": null},
    {"title": 'Đang xử lý', "value": 0},
    {"title": 'Đã hủy', "value": -2},
    {"title": 'Không thành công', "value": -1},
    {"title": 'Thành công', "value": 1},
    {"title": "", "value": null},
  ];
  List<Map<String, dynamic>> services = [
    {"title": 'Tất cả', "value": null},
    {"title": 'Tiền điện', "value": 1},
    {"title": 'Tiền nước', "value": 2},
    {"title": 'Tài chính', "value": 3},
    {"title": 'Internet', "value": 4},
    {"title": 'Nạp điện thoại', "value": 5},
    {"title": 'Thẻ cào điện thoại', "value": 6},
    {"title": 'Thẻ game', "value": 7},
    {"title": 'Viettel Money', "value": 8},
    {"title": '', "value": 8},
  ];

  var dmyIndex = 0;
  var stateIndex = 0;
  var serviceIndex = 0;

  @override
  void initState() {
    super.initState();

    var now = DateTime.now();
    int day = now.day;
    int month = now.month;
    int year = now.year;

    DateTime startDate = DateTime(year, month, day, 00, 00, 00);
    DateTime endDate = DateTime(year, month, day, 23, 59, 00);
    widget.filterData['fromDateTime'] = startDate.millisecondsSinceEpoch;
    widget.filterData['toDateTime'] = endDate.millisecondsSinceEpoch;


    dmyIndex = widget.filterData['dmyIndex'] ?? 0;
    stateIndex = widget.filterData['stateIndex'] ?? 0;
    serviceIndex = widget.filterData['serviceIndex'] ?? 0;

    onSelectedDate(dmyIndex);

    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var spacing = 10.0;
    var width = 450.0 ;

    return AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: widget.animated.value == 0 ? 0 : 420,
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
            child: widget.animated.value == 100 ?Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                  ),
                  (widget.animated.value >95) ?
                  Row(
                    children: [
                      IconButton(
                          iconSize: 28,
                          onPressed: () {
                            if (widget.animationController.value == 0.0) {
                              widget.animationController.forward();
                            } else {
                              widget.animationController.reverse();
                            }
                            setState(() {

                            });
                          },
                          icon: Icon(
                            Icons.close,
                            size: 28,
                          )),
                      Spacer(),
                      IconButton(
                        onPressed: resetAll,
                        icon: FaIcon(FontAwesomeIcons.clockRotateLeft),
                      )
                    ],
                  ) : SizedBox(),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          DMCLGroup('Theo ngày tháng năm',
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: spacing,
                              runSpacing: 15,
                              children: List<Widget>.generate((dmy.length / 2).ceil(), (rowIndex) {
                                final start = rowIndex * 2;
                                final end = (rowIndex + 1) * 2;
                                return Row(
                                  children: dmy.getRange(start, end).map((e) {
                                    final index = dmy.indexOf(e);
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8),
                                        child: DMCLCardItem(
                                          isSelected: index == dmyIndex,
                                          width: width,
                                          height: 52,
                                          backgroundSelected: '#f2f7fb'.toColor(),
                                          backgroundColor: '#f7f7f7'.toColor(),
                                          borderColor: Colors.transparent,
                                          child: Center(
                                            child: Text(
                                              e,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: index == dmyIndex
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: index == dmyIndex
                                                    ? GlobalStyles.activeColor
                                                    : GlobalStyles.text45,
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            dmyIndex = index;
                                            onSelectedDate(dmyIndex);
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                flex:5,
                                child: DMCLGroup('Từ ngày',
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () => onTapFromDate(),
                                          child: Container(
                                            width: 200,
                                            child: DMCLCard(
                                              backgroundColor: '#f7f7f7'.toColor(),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    (widget.filterData['fromDateTime']
                                                    as int)
                                                        .toDateString(
                                                        format: 'dd/MM/yyyy'),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: GlobalStyles.text45),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_drop_down,
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
                              ),
                              Spacer(),
                              Flexible(
                                flex: 5,
                                child: DMCLGroup('Đến ngày',
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () => onTapToDate(),
                                          child: Container(
                                            width: 200,
                                            child: DMCLCard(
                                              backgroundColor: '#f7f7f7'.toColor(),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    (widget.filterData['toDateTime']
                                                    as int)
                                                        .toDateString(
                                                        format: 'dd/MM/yyyy'),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: GlobalStyles.text45),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_drop_down,
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
                              ),
                            ],
                          ),
                          Divider(),
                          DMCLGroup('Theo trạng thái',
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: spacing,
                              runSpacing: 15,
                              children: List<Widget>.generate((states.length / 2).ceil(), (rowIndex) {
                                final start = rowIndex * 2;
                                final end = (rowIndex + 1) * 2;
                                return Row(
                                  children: states.getRange(start, end).map((e) {
                                    final index = states.indexOf(e);
                                    return Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.only(left: 8, right: 8),
                                          child: e['title'] != "" ? DMCLCardItem(
                                            isSelected:
                                            index ==  stateIndex,
                                            width: width,
                                            height: 52,
                                            backgroundSelected: '#f2f7fb'.toColor(),
                                            backgroundColor: '#f7f7f7'.toColor(),
                                            borderColor: Colors.transparent,
                                            child: Center(
                                                child: Text(
                                                  e['title'],
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: states.indexOf(e) ==
                                                          stateIndex
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: states.indexOf(e) ==
                                                          stateIndex
                                                          ? GlobalStyles.activeColor
                                                          : GlobalStyles.text45),
                                                )),
                                            onTap: () {
                                              widget.filterData['state'] =
                                              e['value'];
                                              print(e['value']);
                                              stateIndex = states.indexOf(e);
                                              setState(() {});
                                            },
                                          ) : SizedBox()
                                      ),
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            ),
                          ),
                          DMCLGroup('Theo dịch vụ',
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: spacing,
                              runSpacing: 15,
                              children: List<Widget>.generate((services.length / 2).ceil(), (rowIndex) {
                                final start = rowIndex * 2;
                                final end = (rowIndex + 1) * 2;
                                return Row(
                                  children: services.getRange(start, end).map((e) {
                                    final index = services.indexOf(e);
                                    return Expanded(
                                        child:e['title'] != "" ? Padding(
                                          padding: const EdgeInsets.only(left: 8, right: 8),
                                          child: DMCLCardItem(
                                            isSelected: index == serviceIndex,
                                            width: width,
                                            height: 52,
                                            backgroundSelected: '#f2f7fb'.toColor(),
                                            backgroundColor: '#f7f7f7'.toColor(),
                                            borderColor: Colors.transparent,
                                            child: Center(
                                              child: Text(
                                                e['title'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: index == serviceIndex
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: index == serviceIndex
                                                      ? GlobalStyles.activeColor
                                                      : GlobalStyles.text45,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              widget.filterData['serviceType'] = e['value'];
                                              serviceIndex = index;
                                              setState(() {});
                                            },
                                          ),
                                        ):SizedBox()
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            ),
                          ),

                          SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 8.0, left: 8, right: 8),
                    child: DMCLButton(
                      'Áp dụng',
                      fontColor: Colors.white,
                      onTap: () async {
                        widget.filterData['serviceIndex'] = serviceIndex;
                        widget.filterData['stateIndex'] = stateIndex;
                        widget.filterData['dmyIndex'] = dmyIndex;
                        print("testData${widget.filterData}");
                        widget.onFilterApplied(widget.filterData);
                        SharedAppData.setValue<String, Map<String, dynamic>>(context, 'filter',
                            widget.filterData);
                        // (isReset)?Navigator.pop(context, null):Navigator.pop(context, widget.filterData);
                      },
                    ),
                  )
                ],
              ),
            ):LoadingDot()
        )
    );
  }

  void onSelectedDate(int index) {
    var now = DateTime.now();
    int day = now.day;
    int month = now.month;
    int year = now.year;

    DateTime startDate = DateTime(year, month, day, 00, 00, 00);
    DateTime endDate = DateTime(year, month, day, 24, 00, 00);

    switch (dmyIndex) {
      case 0:
        int currentDay = now.weekday;
        startDate = DateTime(now.year-3, now.month, 1);
        endDate = now.add(Duration(days: DateTime.daysPerWeek - currentDay));
        break;
      case 1:
        int currentDay = now.weekday;
        startDate = now.subtract(Duration(days: currentDay - 1));
        endDate = now.add(Duration(days: DateTime.daysPerWeek - currentDay));
        break;
      case 2:
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        break;
      case 3:
        startDate = DateTime(now.year, now.month - 1, 1);
        int lastOfday = DateTime(now.year, now.month - 1, 0).day;
        endDate = DateTime(now.year, now.month - 1, lastOfday);
        break;
      case 4:
        int mouth = now.month - 3;
        startDate = DateTime(now.year, mouth, 1);
        int lastOfday = DateTime(now.year, mouth, 0).day;
        endDate = DateTime(now.year, now.month, now.day);
        break;
    }

    widget.filterData['fromDateTime'] = startDate.millisecondsSinceEpoch;
    widget.filterData['toDateTime'] = endDate.millisecondsSinceEpoch;
    setState(() {});
  }

  void onTapFromDate() async {
    var time = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime.now());

    widget.filterData['fromDateTime'] = time!.millisecondsSinceEpoch;

    // selected index
    dmyIndex = 5;

    setState(() {});
  }

  void onTapToDate() async {
    var time = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime.now());

    widget.filterData['toDateTime'] = time!.millisecondsSinceEpoch;

    // selected index
    dmyIndex = 5;

    setState(() {});
  }

  void resetAll() {
    DateTime startDate = DateTime(2001, 01, 01, 00, 00, 00);
    widget.filterData = {
      'dmyIndex': 0,
      "state": null,
      "fromDateTime": startDate.millisecondsSinceEpoch,
      "toDateTime": DateTime.now().millisecondsSinceEpoch,
      "serviceType": null,
    };
    dmyIndex = widget.filterData['dmyIndex'] ?? 0;
    stateIndex = widget.filterData['stateIndex'] ?? 0;
    serviceIndex = widget.filterData['serviceIndex'] ?? 0;
    isReset = true;
    setState(() {});
  }
}
