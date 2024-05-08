import 'dart:async';
import 'dart:convert';
import 'package:bmeit_webadmin/models/transactionModel.dart';
import 'package:bmeit_webadmin/screen_web/Dashboard/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:notification_center/notification_center.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../../models/adminModel.dart';
import '../../../models/employerModel.dart';
import '../../../models/shiftModel.dart';
import '../../../res/colors.dart';
import '../../../res/styles.dart';
import '../../../services/services.dart';
import '../../../share/share_widget.dart';
import '../../../widget/share_widget.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../statistical_page/total_report.dart';

class EmployerAllPage extends StatefulWidget {
  bool first;

  EmployerAllPage({Key? key, required this.first}) : super(key: key);

  @override
  _EmployerAllPageState createState() => _EmployerAllPageState();
}

List<Employee> paginatedDataSource = [];
List<Employee> _employees = [];
List<int> listDropdownRow = [17, 25, 50, 100];
List<String> listDropdown = [
  'Tất cả',
  'Mã tài khoản',
];

dynamic _result;

final int rowsPerPage = 17;

class _EmployerAllPageState extends State<EmployerAllPage>
    with SingleTickerProviderStateMixin {
  FocusNode _focus = FocusNode();

  PageController _pageController = PageController();
  final DataGridController _dataGridController = DataGridController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _TextPage = TextEditingController();
  final TextEditingController _TextPageAll = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formKeyPass = GlobalKey<FormState>();
  static final offset1 = Tween<Offset>(begin: Offset(1, 0), end: Offset.zero);
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

  bool onEdit = false;
  bool edit = false;
  bool showLoadingIndicator = false;
  bool expandScreen = false;
  bool testBug = false;
  bool canNext = true;
  bool canPrev = false;
  bool small = false;
  bool lockChangeInfo = true;
  bool desktopSmall = false;
  bool closeShift = false;
  bool loading = false;

  late EmployeeDataSource _employeeDataSource;
  late AnimationController _animationController;
  late Animation _animation;
  Employee? infoDeal;

  int pageCount = 1;
  int totalPage = 0;
  int pageSize = 1;
  int _toggleValue = 0;
  int dropdownRow = listDropdownRow.first;
  int totalPageCount = 1;

  late final DataGridController dataGridController;
  List<String> selectID = [];
  List<Employee> dataGridRows = [];
  List<ShiftModel> shiftData = [];

  DateTime selectedDate = DateTime.now();

  String DateFrom = "Chọn ngày bắt đầu";
  String DateTo = "Chọn ngày kết thúc";
  String dropdownValue = listDropdown.first;
  String dataInput = "";
  String selectPageSlide = "";
  String idDeal = "";
  String idShift = "";

  var currentPage = 1;
  var startItem = 1;
  var endItem = 1;
  var outputFormat = DateFormat('dd/MM/yyyy');

  double widthSearch = 300;

  Map<String, dynamic> filter = {
    'code': null,
    'name': null,
    'siteId': null,
    'states': true,
  };
  Map<String, dynamic> filterShift = {
    'shiftId': '',
  };

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    _animation = IntTween(begin: 0, end: 100).animate(_animationController);
    _animation.addListener(() => setState(() {}));
    _focus.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        if (widget.first == false)
          _runFrist();
        else
          expandScreen = true;
        _runCheck();
      });
      await initData();
      print(' widget binding : $expandScreen');
    });
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _pageController.dispose();
    _animationController.dispose();

    super.dispose();
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

  Future<void> _runFrist() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    expandScreen = true;
    setState(() {});
  }

  Future<void> dataTest(int page) async {
    // await Future.delayed(Duration(seconds: 1));
    var res;
    switch (dropdownValue) {
      case "Tất cả":
        if (mounted)
          res = await Services.instance.setContext(context).getEmployeeList(
                page: page,
                size: dropdownRow,
              );
        break;
      case "Mã tài khoản":
        res = await Services.instance.listUserID(dataInput);
        break;
    }
    // if (res) {
    //   if (mounted)
    //     showAlertAction(context, 'Thông báo',
    //         'Lấy dữ liệu từ Server thất bại, hãy thử lại!', initData);
    // }
    // ;
    if (res != null) {
      pageCount = res.meta['pageNumber'];
      totalPage = res.meta!['totalElements'];
      pageSize = res.meta!['pageSize'];
      // canNext = res.meta!['canNext'];
      // canPrev = res.meta!['canPrev'];
      totalPageCount = (totalPage / pageSize).ceil();
      print("tes${pageCount} - ${totalPageCount}");
      if (pageCount < totalPageCount) {
        canNext = true;
        canPrev = false;
      } else if (pageCount == totalPageCount) {
        if (totalPageCount != 1) {
          canNext = false;
          canPrev = true;
        } else {
          canNext = false;
          canPrev = false;
        }
      }
      print("djfai:${totalPage}${pageSize}${totalPageCount}");
      // await Future.delayed(Duration(seconds: 1));

      var data = res.castList<Employee>();
      _employees = data;
      countPage(0);
      _employeeDataSource = EmployeeDataSource();
      if (mounted)
        setState(() {
          if (!data.isEmpty) {
            showLoadingIndicator = false;
          }
        });
    }
    // return data;
  }

  void resetData() async {
    nameController.clear();

    // passwordController.clear();

    pageCount = 1;
    currentPage = 1;
    startItem = 1;
    endItem = 1;
    await initData();
    setState(() {});
  }

  void countPage(int next) {
    int itemsPerPage = dropdownRow;
    if (totalPage <= itemsPerPage) {
      startItem = pageCount;
      endItem = totalPage;
      print("Start${startItem}, ${endItem}");
    } else {
      if (itemsPerPage * (pageCount) < totalPage) {
        startItem = itemsPerPage * (pageCount - 1) + 1;
        endItem = itemsPerPage * (pageCount);
      } else {
        startItem = itemsPerPage * (pageCount - 1) + 1;
        endItem = totalPage;
      }
    }
    // setState(() {});
  }

  Future<void> _runCheck() async {
    await Future.delayed(
        Duration(milliseconds: widget.first == false ? 1800 : 1000));
    if (!mounted) return;
    testBug = true;
    setState(() {});
  }

  Future<void> activatedAccount() async {
    showLoadingIndicator = true;
    for (var id in selectID) {
      var res = await Services.instance.setUserBL(id, true);

      if (res != null) {
        continue;
      } else {
        showLoadingIndicator = false;
        showAlert(
            context, 'Thông báo', 'Phát hiện lỗi bất thường mời thao tác lại');
        break;
      }
    }
    selectID.clear();
    initData();
    showAlert(context, 'Thông báo', 'Đã thêm tài khoản vào danh sách theo dõi');
  }

  Future<void> initData() async {
    _employeeDataSource = EmployeeDataSource();
    // await Services.instance.refreshToken();
    if (mounted)
      setState(() {
        showLoadingIndicator = true;
      });
    await dataTest(pageCount);
  }

  void openSlidePage() {
    if (_animationController.value == 0.0) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void openSlideOneTime() {
    if (_animationController.value == 0.0) {
      _animationController.forward();
    }
  }

  // Future<String?> getTokenForUser1() async {
  //   try {
  //     // Thực hiện truy vấn để lấy dữ liệu của tài liệu "User1" trong collection "TokenUser"
  //     // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //     //     .collection("TokenUser")
  //     //     .doc('User1')
  //     //     .get();
  //     DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //         .collection("TokenPrint")
  //         .doc(userController.text)
  //         .get();
  //
  //     // Kiểm tra xem tài liệu có tồn tại và có chứa trường 'token' không
  //     if (documentSnapshot.exists) {
  //       Map<String, dynamic> data =
  //           documentSnapshot.data() as Map<String, dynamic>;
  //
  //       // Kiểm tra xem tài liệu có chứa trường 'token' không
  //       if (data.containsKey('token')) {
  //         return data['token'] as String;
  //       } else {
  //         print("Trường 'token' không tồn tại trong tài liệu");
  //         return null; // Trường 'token' không tồn tại trong tài liệu
  //       }
  //     } else {
  //       print("User1 not found");
  //       return null; // Tài liệu "User1" không tồn tại
  //     }
  //   } catch (e) {
  //     print("Lỗi khi truy vấn dữ liệu: $e");
  //     return null;
  //   }
  // }

  // Future<void> checkDoneShift() async {
  //   var res = await Services.instance.getCheckCloseShift();
  //   if (res.isSuccess) {
  //     var data = res.castList<ShiftModel>();
  //     shiftData = data;
  //   }
  //   String targetAccountID= acountIDController.text;
  //   print(targetAccountID);
  //   int maxCloseDateTime = 0;
  //   String idWithMaxCloseDateTime = "";
  //
  //   for (var e in shiftData) {
  //     // Check if the current entry has state equal to 1.
  //     if (e.state == 1 && e.creatorId == targetAccountID && e.closeDateTime != null) {
  //       // Check if there is no other entry with the same creatorId and state equal to 0.
  //       bool hasMatchingState0 = shiftData.any((entry) =>
  //       entry.creatorId == e.creatorId && entry.state == 0);
  //
  //       if (!hasMatchingState0 && e.closeDateTime > maxCloseDateTime) {
  //         maxCloseDateTime = e.closeDateTime;
  //         idWithMaxCloseDateTime = e.id;
  //       }
  //     }
  //   }
  //
  //   if (idWithMaxCloseDateTime.isNotEmpty) {
  //     print("ID with the latest closeDateTime: $idWithMaxCloseDateTime");
  //     closeShift = true;
  //     idShift = idWithMaxCloseDateTime;
  //   } else {
  //     print("No matching ID found.");
  //     closeShift = false;
  //   }
  //   setState(() {});
  // }

  calHead(List<Map<String, dynamic>> data) {
    Map<String, Map<String, dynamic>> groupedDeals = {};
    int count = 1;
    for (var deal in data) {
      String nameService = deal['nameService'];
      int price = deal['price'];

      if (groupedDeals.containsKey(nameService)) {
        // If the service already exists in the map, ensure it's not null and then update the values
        var existingService = groupedDeals[nameService];
        if (existingService != null) {
          existingService['price'] += price;
          existingService['amount'] += count;
        }
      } else {
        // If the service doesn't exist in the map, create a new entry
        groupedDeals[nameService] = {
          "nameService": nameService,
          "price": price,
          "amount": count,
        };
      }
    }

    List<Map<String, dynamic>> result =
        groupedDeals.values.where((service) => service != null).toList();

    // Print the grouped and summarized deals
    return result;
  }

  callStatus(List<Map<String, dynamic>> data) {
    Map<String, Map<String, dynamic>> groupedDeals = {};
    int count = 1;
    for (var deal in data) {
      String status = deal['status'];
      int price = deal['price'];

      if (groupedDeals.containsKey(status)) {
        // If the service already exists in the map, ensure it's not null and then update the values
        var existingService = groupedDeals[status];
        if (existingService != null) {
          existingService['price'] += price;
          existingService['amount'] += count;
        }
      } else {
        // If the service doesn't exist in the map, create a new entry
        groupedDeals[status] = {
          "status": status,
          "price": price,
          "amount": count,
        };
      }
    }

    List<Map<String, dynamic>> result =
        groupedDeals.values.where((status) => status != null).toList();

    // Print the grouped and summarized deals
    return result;
  }

  @override
  Widget build(BuildContext context) {
    _TextPage.text = pageCount.toString();
    _TextPageAll.text = totalPageCount.toString();
    if (selectID.length != 0) {
      onEdit = true;
      setState(() {});
    } else {
      onEdit = false;
    }
    if (Responsive.isDesktopOpenPOP(context) && _animation.value > 0) {
      widthSearch = 170;
      setState(() {});
    }
    if (!Responsive.isDesktopBig(context)) {
      desktopSmall = true;
      _animationController.reverse();
      setState(() {});
    } else {
      desktopSmall = false;
      setState(() {});
    }
    if (Responsive.isMobileSmall(context)) {
      edit = false;
      setState(() {});
    }
    NotificationCenter().subscribe('naviSmall', (bool value) {
      if (mounted)
        setState(() {
          print("small${small}");
          small = value;
        });
    });
    return Scaffold(
      endDrawerEnableOpenDragGesture: false,
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
                'assets/svg/personTotal.svg',
                width: 25,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Tất cả tài khoản",
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
            child: Row(
              children: [
                Flexible(
                  flex: 10,
                  child: Container(
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          height: 80,
                                          child: desktopSmall != false
                                              ? Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Flexible(
                                                      flex: 1,
                                                      child: Container(
                                                        child: Wrap(
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .center,
                                                          alignment:
                                                              WrapAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Container(
                                                                height: 30,
                                                                // padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  border: Border.all(
                                                                      color: AppColors
                                                                          .primaryColor,
                                                                      style: BorderStyle
                                                                          .solid,
                                                                      width: 1),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8,
                                                                          right:
                                                                              8),
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    value:
                                                                        dropdownValue,
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .arrow_drop_down_rounded),
                                                                    elevation:
                                                                        16,
                                                                    style: TextStyle(
                                                                        color: AppColors
                                                                            .primaryColor),
                                                                    underline:
                                                                        Container(
                                                                      color: AppColors
                                                                          .primaryColor,
                                                                    ),
                                                                    onChanged:
                                                                        (String?
                                                                            value) {
                                                                      dropdownValue =
                                                                          value!;
                                                                      if (dropdownValue ==
                                                                          "Tất cả") {
                                                                        // _employees =
                                                                        //     populateData();
                                                                        initData();
                                                                      }
                                                                      // This is called when the user selects an item.
                                                                      setState(
                                                                          () {
                                                                        print(
                                                                            dropdownValue);
                                                                      });
                                                                    },
                                                                    items: listDropdown.map<
                                                                        DropdownMenuItem<
                                                                            String>>((String
                                                                        value) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            value,
                                                                        child: Center(
                                                                            child:
                                                                                Text(value)),
                                                                      );
                                                                    }).toList(),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            AnimatedContainer(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          150),
                                                              width: !Responsive
                                                                      .isMobile(
                                                                          context)
                                                                  ? widthSearch
                                                                  : 170,
                                                              child:
                                                                  DMCLSearchBoxWeb(
                                                                focusNode:
                                                                    _focus,
                                                                hint:
                                                                    'Tìm kiếm theo ${dropdownValue}',
                                                                controller:
                                                                    _searchController,
                                                                isAutocomplete:
                                                                    false,
                                                                onSubmit:
                                                                    (value) async {
                                                                  pageCount = 1;
                                                                  countPage(0);
                                                                  dataInput =
                                                                      value;
                                                                  await Future.delayed(
                                                                      Duration(
                                                                          seconds:
                                                                              1));
                                                                  await initData();
                                                                  if (totalPageCount ==
                                                                      0) {
                                                                    showAlert(
                                                                        context,
                                                                        'Thông báo',
                                                                        'Không có dữ liệu phù hợp');
                                                                  }
                                                                  setState(
                                                                      () {});
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (!Responsive
                                                        .isMobileSmall(context))
                                                      SizedBox(
                                                        width: 16,
                                                      ),
                                                    if (!Responsive
                                                        .isMobileSmall(context))
                                                      Container(
                                                        // width: 380,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            edit == true
                                                                ? Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              right: 8),
                                                                          child:
                                                                              DMCLButtonWeb(
                                                                            'Huỷ',
                                                                            onTap:
                                                                                () {
                                                                              edit = !edit;
                                                                              selectID = [];
                                                                              setState(() {});
                                                                            },
                                                                            backgroundColor:
                                                                                Colors.white,
                                                                            fontColor:
                                                                                AppColors.primaryColor,
                                                                            fontSize:
                                                                                16,
                                                                            disable:
                                                                                false,
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              right: 8),
                                                                          child:
                                                                              DMCLButtonWeb(
                                                                            'Theo dõi',
                                                                            onTap: !onEdit
                                                                                ? null
                                                                                : () {
                                                                                    activatedAccount();
                                                                                  },
                                                                            backgroundColor:
                                                                                Colors.white,
                                                                            fontColor:
                                                                                Colors.red,
                                                                            fontSize:
                                                                                16,
                                                                            disable:
                                                                                !onEdit,
                                                                            border:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8),
                                                                    child:
                                                                        DMCLButtonWeb(
                                                                      'Chức năng',
                                                                      onTap:
                                                                          () {
                                                                        edit =
                                                                            !edit;
                                                                        setState(
                                                                            () {});
                                                                      },
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      fontColor:
                                                                          AppColors
                                                                              .primaryColor,
                                                                      fontSize:
                                                                          16,
                                                                      disable:
                                                                          false,
                                                                    ),
                                                                  )
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    Container(
                                                      width: 100,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: edit ==
                                                                      false
                                                                  ? SizedBox()
                                                                  : Text(
                                                                      "Đã chọn (${selectID.length})"))),
                                                    ),
                                                    Flexible(
                                                      flex: 7,
                                                      child: Center(
                                                        child: Container(
                                                          width: constraints
                                                              .maxWidth,
                                                          child:
                                                              AnimatedSwitcher(
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  transitionBuilder: (Widget
                                                                          child,
                                                                      Animation<
                                                                              double>
                                                                          animation) {
                                                                    return SlideTransition(
                                                                      position:
                                                                          (offset1)
                                                                              .animate(animation),
                                                                      child:
                                                                          child,
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    // key:
                                                                    //     ValueKey<bool>(search),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        // SizedBox(
                                                                        //   width: MediaQuery.of(context).size.width * 00.06,
                                                                        // ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                30,
                                                                            // padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              border: Border.all(color: AppColors.primaryColor, style: BorderStyle.solid, width: 1),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(left: 8, right: 8),
                                                                              child: DropdownButton<String>(
                                                                                value: dropdownValue,
                                                                                icon: const Icon(Icons.arrow_drop_down_rounded),
                                                                                elevation: 16,
                                                                                style: TextStyle(color: AppColors.primaryColor),
                                                                                underline: Container(
                                                                                  height: 0,
                                                                                  color: AppColors.primaryColor,
                                                                                ),
                                                                                onChanged: (String? value) {
                                                                                  dropdownValue = value!;
                                                                                  if (dropdownValue == "Tất cả") {
                                                                                    initData();
                                                                                  }
                                                                                  // This is called when the user selects an item.
                                                                                  setState(() {
                                                                                    print(dropdownValue);
                                                                                  });
                                                                                },
                                                                                items: listDropdown.map<DropdownMenuItem<String>>((String value) {
                                                                                  return DropdownMenuItem<String>(
                                                                                    value: value,
                                                                                    child: Center(child: Text(value)),
                                                                                  );
                                                                                }).toList(),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        AnimatedContainer(
                                                                          duration:
                                                                              const Duration(milliseconds: 150),
                                                                          width: !Responsive.isMobile(context)
                                                                              ? widthSearch
                                                                              : 170,
                                                                          child:
                                                                              DMCLSearchBoxWeb(
                                                                            focusNode:
                                                                                _focus,
                                                                            hint:
                                                                                'Tìm kiếm theo ${dropdownValue}',
                                                                            controller:
                                                                                _searchController,
                                                                            isAutocomplete:
                                                                                false,
                                                                            onSubmit:
                                                                                (value) async {
                                                                              pageCount = 1;
                                                                              countPage(0);
                                                                              dataInput = value;
                                                                              await Future.delayed(Duration(seconds: 1));
                                                                              await initData();
                                                                              if (totalPageCount == 0) {
                                                                                showAlert(context, 'Thông báo', 'Không có dữ liệu phù hợp');
                                                                              }
                                                                              setState(() {});
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      // width: 380,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          edit == true
                                                              ? Container(
                                                                  child: Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                8),
                                                                        child:
                                                                            DMCLButtonWeb(
                                                                          'Huỷ',
                                                                          onTap:
                                                                              () {
                                                                            edit =
                                                                                !edit;
                                                                            selectID =
                                                                                [];
                                                                            setState(() {});
                                                                          },
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          fontColor:
                                                                              AppColors.primaryColor,
                                                                          fontSize:
                                                                              16,
                                                                          disable:
                                                                              false,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                8),
                                                                        child:
                                                                            DMCLButtonWeb(
                                                                          'Theo dõi',
                                                                          onTap: !onEdit
                                                                              ? null
                                                                              : () {
                                                                                  activatedAccount();
                                                                                },
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          fontColor:
                                                                              Colors.red,
                                                                          fontSize:
                                                                              16,
                                                                          disable:
                                                                              !onEdit,
                                                                          border:
                                                                              Colors.red,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              8),
                                                                  child:
                                                                      DMCLButtonWeb(
                                                                    'Chức năng',
                                                                    onTap: () {
                                                                      edit =
                                                                          !edit;
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    fontColor:
                                                                        AppColors
                                                                            .primaryColor,
                                                                    fontSize:
                                                                        16,
                                                                    disable:
                                                                        false,
                                                                  ),
                                                                )
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 70,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child:
                                                                  CircleAvatar(
                                                                radius: 20,
                                                                backgroundColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                child:
                                                                    IconButton(
                                                                        color: Colors
                                                                            .white,
                                                                        onPressed:
                                                                            () {
                                                                          selectPageSlide =
                                                                              "addEmployee";
                                                                          openSlideOneTime();
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .add,
                                                                          size:
                                                                              23,
                                                                        )),
                                                              ))),
                                                    ),
                                                  ],
                                                )),
                                      Divider(
                                        // height: 20,
                                        thickness: 1,
                                        indent: 20,
                                        endIndent: 20,
                                        color: Colors.grey,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                                height:
                                                    constraints.maxHeight - 200,
                                                width: constraints.maxWidth,
                                                child: buildStack(constraints)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (!Responsive.isMobile(context))
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20),
                                                  child: Text(
                                                      "Số hàng mỗi trang:",
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                DropdownButton<int>(
                                                  value: dropdownRow,
                                                  icon: const Icon(Icons
                                                      .arrow_drop_down_rounded),
                                                  elevation: 16,
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .primaryColor),
                                                  underline: Container(
                                                    height: 0,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                  onChanged:
                                                      (int? value) async {
                                                    selectID = [];
                                                    dropdownRow = value!;
                                                    pageCount = 1;
                                                    currentPage = 1;
                                                    countPage(0);
                                                    await initData();
                                                    setState(() {});
                                                  },
                                                  items: listDropdownRow.map<
                                                      DropdownMenuItem<
                                                          int>>((int value) {
                                                    return DropdownMenuItem<
                                                        int>(
                                                      value: value,
                                                      child: Center(
                                                          child: Text(
                                                              "${value}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16))),
                                                    );
                                                  }).toList(),
                                                ),
                                              ],
                                            ),
                                          if (!Responsive.isMobile(context))
                                            Spacer(), //
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              DMCLPageButton(
                                                Icons.arrow_back_ios_new,
                                                backgroundColor: Colors.white,
                                                disable: canPrev == false ||
                                                    showLoadingIndicator ==
                                                        true,
                                                onTap: () async {
                                                  if (canPrev == true)
                                                    pageCount--;
                                                  _TextPage.text =
                                                      pageCount.toString();

                                                  await initData();
                                                  countPage(2);
                                                  setState(() {});
                                                },
                                                fontColor:
                                                    AppColors.primaryColor,
                                                border: Colors.grey,
                                              ),
                                              Container(
                                                width: 30,
                                                child: TextField(
                                                  // obscureText: true,
                                                  controller: _TextPage,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey),
                                                  textAlign: TextAlign.center,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  decoration: InputDecoration(
                                                      fillColor: Colors.green,
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                        bottom: 18.0,
                                                      )),
                                                  onSubmitted: (value) async {
                                                    int? parsedValue =
                                                        int.tryParse(value);
                                                    if (parsedValue != null &&
                                                        parsedValue <=
                                                            totalPageCount &&
                                                        parsedValue != 0) {
                                                      pageCount = parsedValue;
                                                      countPage(0);
                                                      await initData();
                                                    } else {
                                                      if (parsedValue == 0) {
                                                        showAlert(
                                                            context,
                                                            'Thông báo',
                                                            'Số trang không đúng, nhập lại số trang');
                                                      } else
                                                        showAlert(
                                                            context,
                                                            'Thông báo',
                                                            'Số trang vượt quá số trang tổng');
                                                    }

                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                              Text("-"),
                                              Container(
                                                width: 30,
                                                child: TextField(
                                                  // obscureText: true,
                                                  readOnly: true,
                                                  controller: _TextPageAll,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                  textAlign: TextAlign.center,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  decoration: InputDecoration(
                                                      fillColor: Colors.green,
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                        bottom: 18.0,
                                                      )
                                                      // contentPadding: EdgeInsets.only(bottom:16),
                                                      ),
                                                ),
                                              ),
                                              DMCLPageButton(
                                                Icons.arrow_forward_ios,
                                                backgroundColor: Colors.white,
                                                disable: canNext == false ||
                                                    showLoadingIndicator ==
                                                        true,
                                                onTap: () async {
                                                  if (canNext == true)
                                                    pageCount++;
                                                  _TextPage.text =
                                                      pageCount.toString();
                                                  await initData();
                                                  countPage(1);
                                                  setState(() {});
                                                },
                                                fontColor:
                                                    AppColors.primaryColor,
                                                border: Colors.grey,
                                              ),
                                            ],
                                          ),

                                          if (!Responsive.isDesktopOpenPOP(
                                              context))
                                            Spacer(), //
                                          if (!Responsive.isDesktopOpenPOP(
                                              context))
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 20.0),
                                                  child: Text(
                                                    "${startItem}-${endItem} trong tổng số ${totalPage}",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : AnimatedPositioned(
                                width: expandScreen ? constraints.maxWidth : 0,
                                // height: expandScreen
                                //     ? MediaQuery.of(context).size.height - 67
                                //     : 200,
                                duration: Duration(milliseconds: 1000),
                                curve: Curves.fastOutSlowIn,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 16.0,
                                    left: 8.0,
                                    top: 8,
                                  ),
                                  child: Container(
                                    height: constraints.maxHeight - 24,
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
                (Responsive.isMobileSmall(context) && _animation.value != 0)
                    ? Flexible(
                        child: Padding(
                            padding: _animation.value != 0
                                ? const EdgeInsets.only(
                                    bottom: 11.0, right: 16, left: 8)
                                : const EdgeInsets.only(bottom: 11.0),
                            child: switchSlide()),
                      )
                    : Padding(
                        padding: _animation.value != 0
                            ? const EdgeInsets.only(
                                bottom: 11.0, right: 16, left: 8)
                            : const EdgeInsets.only(bottom: 11.0),
                        child: switchSlide()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget switchSlide() {
    if (selectPageSlide == "addEmployee") {
      return buildEndDrawer();
    } else if (selectPageSlide == "infoEmployee") {
      return buildEndDrawerInfo();
    } else {
      return SizedBox();
    }
  }

  Widget buildEndDrawer() {
    return AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: _animation.value == 0 ? 0 : 380,
        height: MediaQuery.of(context).size.height - 80,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(18.0),
          ),
          color: Colors.white,
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          reverseDuration: const Duration(milliseconds: 100),
          child: _animation.value == 100
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                      ),
                      if (_animation.value > 40)
                        Row(
                          children: [
                            IconButton(
                                iconSize: 28,
                                onPressed: () {
                                  openSlidePage();
                                },
                                icon: Icon(
                                  Icons.close,
                                  size: 28,
                                )),
                            Spacer(),
                            IconButton(
                              onPressed: resetData,
                              icon: FaIcon(FontAwesomeIcons.clockRotateLeft),
                            )
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "Thêm tài khoản mới",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 20),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                DMCLTextFiledWeb(
                                  controller: acountIDController,
                                  labelText: 'Mã tài khoản',
                                  icon: Icons.verified_user,
                                ),
                                DMCLTextFiledWeb(
                                  controller: phoneController,
                                  labelText: 'Số điện thoại',
                                  icon: Icons.person,
                                ),
                                DMCLTextFiledWeb(
                                  controller: nameController,
                                  labelText: 'Tên tài khoản',
                                  icon: Icons.person,
                                ),
                                DMCLTextFiledWeb(
                                  controller: genderIdController,
                                  labelText: 'Giới tính',
                                  icon: Icons.store,
                                ),
                                DMCLTextFiledWeb(
                                  controller: dobController,
                                  labelText: 'Ngày sinh',
                                  icon: Icons.store,
                                ),
                                // DMCLTextFiledPassWeb(
                                //   controller: passwordController,
                                //   labelText: 'Mật khẩu',
                                //   icon: Icons.lock,
                                // ),
                                DMCLTextFiledPassWeb(
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
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 20.0, left: 8, right: 8),
                        child: DMCLButton(
                          'Tạo tài khoản',
                          fontColor: Colors.white,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              // Do something with the form data
                              showLoadingIndicator = true;
                              String name = nameController.text;
                              String user = phoneController.text;
                              // String password = passwordController.text;
                              String sideId = dobController.text;

                              // You can process the data here, for example, print it
                              print('Name: $name');
                              print('User: $user');
                              // print('Password: $password');
                              print('SideID: $sideId');

                              // var res = await Services.instance.registerAccount(
                              //     name, user, password, sideId);
                              // if (res != null) {
                              //   showAlert(
                              //     context,
                              //     'Thông báo',
                              //     'Bạn đã tạo tài khoản thành công, nhưng tài khoản chưa được kích hoạt',
                              //   );
                              await initData();
                            } else {
                              showLoadingIndicator = false;
                            }
                            // } else {}
                          },
                        ),
                      )
                    ],
                  ),
                )
              : LoadingDot(),
        ));
  }

  Widget buildEndDrawerInfo() {
    print(_pageController);
    if (infoDeal != null) {
      acountIDController.text = infoDeal!.id!;
      nameController.text = infoDeal!.fullName!;
      phoneController.text = infoDeal!.phone!;
      // passwordController.text = infoDeal!.pas!;
      loginCodeController.text = infoDeal!.loginCode.toString();
      genderIdController.text = infoDeal!.gender!;
      dobController.text = infoDeal!.dob!.toString();
      _toggleValue = infoDeal!.monitored! ? 0 : 1;
    }
    // print(_toggleValue);
    return AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: _animation.value == 0 ? 0 : 380,
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
          child: _animation.value == 100 && infoDeal != null
              ? loading == false
                  ? Column(
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
                              if (_animation.value > 40)
                                Row(
                                  children: [
                                    IconButton(
                                        iconSize: 28,
                                        onPressed: () {
                                          openSlidePage();
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          size: 28,
                                        )),
                                    Spacer(),
                                    SmoothPageIndicator(
                                        controller: _pageController,
                                        count: 2,
                                        effect: JumpingDotEffect(
                                            activeDotColor:
                                                AppColors.primaryColor,
                                            dotColor: Colors.grey,
                                            dotHeight: 10,
                                            dotWidth: 10,
                                            spacing: 10,
                                            verticalOffset: 10)),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        lockChangeInfo = !lockChangeInfo;
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        lockChangeInfo
                                            ? Icons.edit_off_outlined
                                            : Icons.edit_outlined,
                                        size: 28,
                                      ),
                                    )
                                  ],
                                ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 160,
                                child: PageView(
                                    controller: _pageController,
                                    children: <Widget>[
                                      Column(
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
                                                key: _formKey,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    DMCLTextFiledWeb(
                                                      lock: lockChangeInfo,
                                                      controller:
                                                          acountIDController,
                                                      labelText: 'Mã tài khoản',
                                                      icon: Icons.verified_user,
                                                    ),
                                                    DMCLTextFiledWeb( lock: lockChangeInfo,
                                                      controller:
                                                          phoneController,
                                                      labelText:
                                                          'Số điện thoại',
                                                      icon: Icons.person,
                                                    ),
                                                    DMCLTextFiledWeb( lock: lockChangeInfo,
                                                      controller:
                                                          nameController,
                                                      labelText:
                                                          'Tên tài khoản',
                                                      icon: Icons.person,
                                                    ),
                                                    DMCLTextFiledWeb( lock: lockChangeInfo,
                                                      controller:
                                                          genderIdController,
                                                      labelText: 'Giới tính',
                                                      icon: Icons.store,
                                                    ),
                                                    DMCLTextFiledWeb( lock: lockChangeInfo,
                                                      controller: dobController,
                                                      labelText: 'Ngày sinh',
                                                      icon: Icons.store,
                                                    ),
                                                    // DMCLTextFiledPassWeb(
                                                    //   controller: passwordController,
                                                    //   labelText: 'Mật khẩu',
                                                    //   icon: Icons.lock,
                                                    // ),
                                                    DMCLTextFiledPassWeb( lock: lockChangeInfo,
                                                      controller:
                                                          loginCodeController,
                                                      labelText:
                                                          'Mật khẩu cấp hai',
                                                      icon: Icons.lock,
                                                    ),

                                                    if (_animation.value > 80)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 8.0,
                                                                left: 8.0,
                                                                right: 8.0,
                                                                bottom: 20),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Trạng thái theo dõi: ",
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                            Center(
                                                              child:
                                                                  AnimatedToggle(
                                                                values: [
                                                                  'Bật',
                                                                  'Tắt'
                                                                ],
                                                                valueChoose: infoDeal!.monitored ?? false,
                                                                onToggleCallback:
                                                                    (value) async {
                                                                  setState(() {
                                                                    _toggleValue =
                                                                        value;

                                                                  });
                                                                  var res = await Services.instance.setUserBL(infoDeal!.id,_toggleValue == 0 ? true : false);
                                                                },
                                                                lock:
                                                                    lockChangeInfo,
                                                                buttonColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                backgroundColor:
                                                                    const Color(
                                                                        0xFFB5C1CC),
                                                                textColor:
                                                                    const Color(
                                                                        0xFFFFFFFF),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    SizedBox(height: 20.0),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8,
                                                bottom: 8.0,
                                                left: 8,
                                                right: 8),
                                            child: DMCLButton(
                                              !lockChangeInfo
                                                  ? 'Cập nhập thông tin'
                                                  : 'Xem thống kê',
                                              fontColor: Colors.white,
                                              onTap: () async {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                prefs.setString(
                                                    'idUser', infoDeal!.id);
                                                SharedAppData.setValue<String,
                                                    int?>(context, 'deals', 1);
                                              },
                                              // onTap: () async {
                                              //   if (_formKey.currentState!
                                              //       .validate()) {
                                              //     // Do something with the form data
                                              //     showLoadingIndicator = true;
                                              //     infoDeal?.id =
                                              //         nameController.text;
                                              //     infoDeal?.id =
                                              //         userController.text;
                                              //     infoDeal?.id =
                                              //         sideIdController.text;
                                              //     infoDeal?.id =
                                              //         acountIDController.text;
                                              //     infoDeal?.monitored =
                                              //         _toggleValue == 0
                                              //             ? true
                                              //             : false;
                                              //     print(_toggleValue);
                                              //     var res = await Services.instance
                                              //         .updateEmployeeInfor(
                                              //             infoDeal!);
                                              //     if (res != null) {
                                              //       showAlert(
                                              //         context,
                                              //         'Thông báo',
                                              //         'Bạn đã cập nhập thành công thông tin tài khoản',
                                              //       );
                                              //       await initData();
                                              //     } else {
                                              //       if (mounted)
                                              //         showLoadingIndicator = false;
                                              //     }
                                              //   } else {}
                                              // },
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Text(
                                                "Nâng cao",
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
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8,
                                                                  right: 8),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SvgPicture
                                                                      .asset(
                                                                    'assets/svg/home.svg',
                                                                    width: 25,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  Text(
                                                                    "  Chức năng mở rộng",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                  ),
                                                                ],
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            8.0,
                                                                        right:
                                                                            8.0,
                                                                        top:
                                                                            16),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          380 /
                                                                              2,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          const Text(
                                                                            'Gửi Thông báo cho bệnh nhân',
                                                                            style:
                                                                                TextStyle(color: Colors.black54, fontSize: 16),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                4,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                175,
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                Marquee(
                                                                              text: "Thông báo sẽ được hiển thị lên trên thiết bị của bệnh nhân",
                                                                              scrollAxis: Axis.horizontal,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              blankSpace: 50.0,
                                                                              velocity: 25.0,
                                                                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.green),
                                                                            ),
                                                                          ),

                                                                          // Text(
                                                                          //   imei,
                                                                          //   style: const TextStyle(
                                                                          //       fontWeight: FontWeight.w500),
                                                                          //   overflow: TextOverflow.ellipsis,
                                                                          // )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    DMCLButtonWeb(
                                                                      'Gửi',
                                                                      onTap:
                                                                          () async {
                                                                        var res = await Services
                                                                            .instance
                                                                            .getNotiInfo(phone: infoDeal?.phone ?? "");
                                                                        print(res!
                                                                            .data['notifyToken']);

                                                                        var data =
                                                                            {
                                                                          'to':
                                                                              res!.data['notifyToken'],
                                                                          'notification':
                                                                              {
                                                                            'title': notiController.text.isEmpty
                                                                                ? 'Brain Train chào mọi người ngày mới'
                                                                                : notiController.text,
                                                                            'body': notiCenterController.text.isEmpty
                                                                                ? 'Quay lại Brain Train luyện tập nào'
                                                                                : notiCenterController.text,
                                                                            "sound":
                                                                                "jetsons_doorbell.mp3"
                                                                          },
                                                                          'android':
                                                                              {
                                                                            'notification':
                                                                                {
                                                                              'notification_count': 23,
                                                                            },
                                                                          },
                                                                          'data':
                                                                              {
                                                                            'type':
                                                                                'msj',
                                                                            'id':
                                                                                'In nè'
                                                                          }
                                                                        };

                                                                        await http.post(
                                                                            Uri.parse(
                                                                                'https://fcm.googleapis.com/fcm/send'),
                                                                            body: jsonEncode(
                                                                                data),
                                                                            headers: {
                                                                              'Content-Type': 'application/json; charset=UTF-8',
                                                                              'Authorization': 'key=AAAAKssO_zI:APA91bGdFFV_KVnsNLL_4d9VP_DEJAxQIrYDo8bZrgOyY_IvwUCfTwdsj1XWneXaWX7_Zi24BKuyXSZKhDe2BreCm0Qs7c-xdLEZRVMmBEluBFti35ExGlXWtITEMjIPE35oknq9AytG'
                                                                            }).then(
                                                                            (value) {


                                                                        }).onError((error,
                                                                            stackTrace) {

                                                                          setState(() {

                                                                          });
                                                                          });


                                                                        if(res!
                                                                            .data['notifyToken'] != null){
                                                                          showAlert(
                                                                              context,
                                                                              'Thông báo',
                                                                              'Đã gửi thành công');
                                                                        }else{
                                                                          showAlert(
                                                                              context,
                                                                              'Thông báo',
                                                                              'Lỗi! Bạn hãy gửi lại thông báo');
                                                                        };
                                                                        
                                                                        
                                                                      },
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      fontColor:
                                                                          AppColors
                                                                              .primaryColor,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            16),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: <Widget>[
                                                                    DMCLTextFiledWeb(
                                                                      lock:
                                                                          lockChangeInfo,
                                                                      controller:
                                                                          notiController,
                                                                      labelText:
                                                                          'Tiêu đề thông báo ',
                                                                      icon: Icons
                                                                          .person_pin_circle_sharp,
                                                                    ),
                                                                    DMCLTextFiledWeb(
                                                                      lock:
                                                                          lockChangeInfo,
                                                                      controller:
                                                                          notiCenterController,
                                                                      labelText:
                                                                          'Nội dung thông báo',
                                                                      icon: Icons
                                                                          .person,
                                                                    ),
                                                                    // DMCLTextFiledWeb(
                                                                    //   controller:
                                                                    //       passwordController,
                                                                    //   labelText:
                                                                    //       'Mật khẩu',
                                                                    //   icon: Icons.lock,
                                                                    // ),
                                                                    SizedBox(
                                                                        height:
                                                                            20.0),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 16,
                                                                  left: 8.0,
                                                                  right: 8),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/svg/home.svg',
                                                                width: 25,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              Text(
                                                                "  Đặt lại mật khẩu",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 16),
                                                          child: Form(
                                                            key: _formKeyPass,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: <Widget>[
                                                                DMCLTextFiledWeb(
                                                                  lock: true,
                                                                  controller:
                                                                      acountIDController,
                                                                  labelText:
                                                                      'Mã tài khoản',
                                                                  icon: Icons
                                                                      .person_pin_circle_sharp,
                                                                ),
                                                                DMCLTextFiledPassWeb(
                                                                  lock:
                                                                      lockChangeInfo,
                                                                  controller:
                                                                      passController,
                                                                  labelText:
                                                                      'Mật khẩu',
                                                                  icon: Icons
                                                                      .person,
                                                                ),
                                                                // DMCLTextFiledWeb(
                                                                //   controller:
                                                                //       passwordController,
                                                                //   labelText:
                                                                //       'Mật khẩu',
                                                                //   icon: Icons.lock,
                                                                // ),
                                                                SizedBox(
                                                                    height:
                                                                        20.0),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8,
                                                                  bottom: 8.0,
                                                                  left: 8,
                                                                  right: 8),
                                                          child: DMCLButton(
                                                            'Đổi mật khẩu',
                                                            fontColor:
                                                                Colors.white,
                                                            onTap: () async {
                                                              if (_formKeyPass
                                                                  .currentState!
                                                                  .validate()) {
                                                                showLoadingIndicator =
                                                                    true;
                                                                String password =
                                                                    passController
                                                                        .text;
                                                                String accountID =
                                                                    acountIDController
                                                                        .text;
                                                                String user =
                                                                    userController
                                                                        .text;
                                                                var res =
                                                                    await Services
                                                                        .instance
                                                                        .resetPassword(
                                                                  accountID,
                                                                  user,
                                                                  password,
                                                                );

                                                                if (res != null) {
                                                                  showLoadingIndicator =
                                                                      false;
                                                                  showAlert(
                                                                    context,
                                                                    'Thông báo',
                                                                    'Bạn đã cập nhập mật khẩu cho tài khoản thành công',
                                                                  );
                                                                } else {
                                                                  showLoadingIndicator =
                                                                      false;
                                                                }
                                                              } else {}
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : LoadingDot()
              : LoadingDot(),
        ));
  }

  Widget buildDataGrid(BoxConstraints constraint) {
    return Scaffold(
        body: SfDataGridTheme(
      data: SfDataGridThemeData(
        headerColor: Colors.white,
        sortIconColor: AppColors.primaryColor,
        rowHoverColor: AppColors.primaryColor,
        rowHoverTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      child: edit == true
          ? SfDataGrid(
              // allowFiltering: true,
              // showFilterIconOnHover:true,
              controller: _dataGridController,
              showCheckboxColumn: true,
              checkboxColumnSettings:
                  DataGridCheckboxColumnSettings(showCheckboxOnHeader: false),
              selectionMode: SelectionMode.multiple,
              allowSorting: true,
              allowMultiColumnSorting: true,
              headerGridLinesVisibility: GridLinesVisibility.horizontal,
              gridLinesVisibility: GridLinesVisibility.horizontal,
              columnWidthMode: ColumnWidthMode.fill,
              source: _employeeDataSource,
              // columnWidthMode: ColumnWidthMode.fill,

              onCellTap: (DataGridCellTapDetails details) {
                print("ok");
                // var electedIndex = details.rowColumnIndex.rowIndex - 1;
                // print(electedIndex);
                if (details.rowColumnIndex.rowIndex != 0) {
                  final DataGridRow row = _employeeDataSource
                      .effectiveRows[details.rowColumnIndex.rowIndex - 1];
                  int index = _employeeDataSource._employeeData.indexOf(row);
                  print(_employees[index]);
                  if (selectID.contains(_employees[index].id) == false) {
                    selectID.add(_employees[index].id);
                  } else {
                    selectID.remove(_employees[index].id);
                  }

                  print(selectID);
                  setState(() {});
                }
              },
              columns: <GridColumn>[
                  GridColumn(
                      columnName: 'id',
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.center,
                          child: Text(
                            'ID',
                          ))),
                  GridColumn(
                      columnName: 'name',
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.center,
                          child: Text('Tên'))),
                  GridColumn(
                      columnName: 'branch',
                      // width: 110,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.center,
                          child: Text(
                            'Giới tính',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'phone',
                      // width: 110,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.center,
                          child: Text(
                            'Số điện thoại ',
                            overflow: TextOverflow.ellipsis,
                          ))),
                ])
          : SfDataGrid(
              // allowFiltering: true,
              // showFilterIconOnHover:true,
              controller: _dataGridController,
              allowSorting: true,
              allowMultiColumnSorting: true,
              headerGridLinesVisibility: GridLinesVisibility.horizontal,
              gridLinesVisibility: GridLinesVisibility.horizontal,
              columnWidthMode: ColumnWidthMode.fill,
              source: _employeeDataSource,
              onCellTap: (DataGridCellTapDetails details) async {
                if (details.rowColumnIndex.rowIndex != 0) {
                  final DataGridRow row = _employeeDataSource
                      .effectiveRows[details.rowColumnIndex.rowIndex - 1];
                  int index = _employeeDataSource._employeeData.indexOf(row);
                  String idDeal = _employees[index].id;
                  selectPageSlide = "infoEmployee";
                  openSlideOneTime();
                  loading = true;
                  setState(() {});
                  var res = await Services.instance.listUserID(idDeal);
                  await Future.delayed(Duration(seconds: 1));
                  if (res != null) {
                    var data = res;
                    infoDeal = data;

                    loading = false;
                  }
                  // checkDoneShift();
                  setState(() {});
                }

                print("cell");
              },
              columns: <GridColumn>[
                  GridColumn(
                      columnName: 'id',
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.center,
                          child: Text(
                            'ID',
                          ))),
                  GridColumn(
                      columnName: 'name',
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.center,
                          child: Text('Tên'))),
                  GridColumn(
                      columnName: 'branch',
                      // width: 110,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.center,
                          child: Text(
                            'Giới tính',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'phone',
                      // width: 110,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.center,
                          child: Text(
                            'Số điện thoại ',
                            overflow: TextOverflow.ellipsis,
                          ))),
                ]),
    ));
  }

  Widget buildStack(BoxConstraints constraints) {
    List<Widget> _getChildren() {
      final List<Widget> stackChildren = [];
      stackChildren.add(buildDataGrid(constraints));

      if (showLoadingIndicator == true) {
        stackChildren.add(Container(
            color: Colors.black12,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: LoadingDot()));
      }

      return stackChildren;
    }

    return Stack(
      children: _getChildren(),
    );
  }
}

class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource() {
    paginatedDataSource = _employees.getRange(0, _employees.length).toList();
    buildDataGridRows();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  void buildDataGridRows() {
    _employeeData = paginatedDataSource
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.fullName),
              DataGridCell<String>(columnName: 'gender', value: e.gender),
              DataGridCell<String>(columnName: 'phone', value: e.phone),
            ]))
        .toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        color: Colors.white,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(e.columnName == 'gender'
                ? e.value.toString() == "MALE"
                    ? "Nam"
                    : "Nữ"
                : e.value.toString()),
          );
        }).toList());
  }
}
