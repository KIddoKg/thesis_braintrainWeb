import 'dart:async';
import 'package:bmeit_webadmin/models/employerModel.dart';
import 'package:bmeit_webadmin/screen_web/Dashboard/historyDeal_page/search_filter.dart';
import 'package:bmeit_webadmin/screen_web/Dashboard/historyDeal_page/theBillInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:bmeit_webadmin/helper/formatter.dart';
import '../../../models/adminModel.dart';
import '../../../models/transactionModel.dart';
import '../../../res/colors.dart';
import '../../../res/styles.dart';
import '../../../services/services.dart';
import '../../../share/share_widget.dart';
import '../../../widget/share_widget.dart';

class HistoryDeal extends StatefulWidget {
  HistoryDeal({Key? key}) : super(key: key);

  @override
  _HistoryDealState createState() => _HistoryDealState();
}

List<TransactionModel> paginatedDataSource = [];
dynamic _result;
List<TransactionModel> _deals = [];
final int rowsPerPage = 14;
List<int> listDropdownRow = [14, 25, 50, 100];
List<String> listDropdown = [
  'Tất cả',
  'Mã Test',
  'Ca làm việc',
];

class _HistoryDealState extends State<HistoryDeal>
    with SingleTickerProviderStateMixin {
  FocusNode _focus = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _TextPage = TextEditingController();
  final TextEditingController _TextPageAll = TextEditingController();
  final DataGridController _dataGridController = DataGridController();
  static final offset2 = Tween<Offset>(begin: Offset(0, -1), end: Offset.zero);

  late final DataGridController dataGridController;
  late Animation _animation;
  late AnimationController _animationController;

  TransactionModel? infoDeal;

  bool edit = false;
  bool loadingPgae = true;
  bool expandScreen = false;
  bool testBug = false;
  bool showLoadingIndicator = true;
  bool selectDate = false;
  bool canNext = true;
  bool canPrev = false;
  bool Errors = false;

  int pageCount = 1;
  int totalPage = 0;
  int dropdownRow = listDropdownRow.first;
  int totalPageCount = 1;

  String DateFrom = "Chọn ngày bắt đầu";
  String DateTo = "Chọn ngày kết thúc";
  String dataInput = "";
  String idDeal = "";
  String selectedDrawer = '';
  String selectPageSlide = "";
  String selectDateFunc = "Theo ngày";
  String selectPriceFunc = "bằng";
  String dropdownValue = listDropdown.first;

  double widthSearch = 400;

  DateTime selectedDate = DateTime.now();

  var outputFormat = DateFormat('dd/MM/yyyy');
  var currentPage = 1;
  var startItem = 1;
  var endItem = 14;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animation = IntTween(begin: 0, end: 100).animate(_animationController);
    _animation.addListener(() => setState(() {}));
    _focus.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        expandScreen = true;
        // testBug = true;
      });

      print(' widget binding : $expandScreen');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  DateTime startDate = DateTime(2001, 01, 01, 00, 00, 00);
  void _onFocusChange() {
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
    print(_focus.hasFocus.toString() == "true");
    if (_focus.hasFocus.toString() == "true") {
      widthSearch = 600;
    } else {
      widthSearch = 400;
    }
    setState(() {});
  }

  final TextEditingController _textFieldController = TextEditingController();
  final CollectionReference _brainTrainGameCollection =
  FirebaseFirestore.instance.collection('BrainTrainGame');

  void _addWord() {
    String inputText = _textFieldController.text.trim();

    // Split the input text into individual words
    List<String> words = inputText.split(',');

    // Remove any leading or trailing spaces from each word
    words = words.map((word) => word.trim()).toList();

    // Remove any empty strings from the list
    words.removeWhere((word) => word.isEmpty);

    // Add each word to the Firestore array
    if (words.isNotEmpty) {
      _brainTrainGameCollection.doc('WordLanguage4').update({
        'words': FieldValue.arrayUnion(words),
      }).then((_) {
        print('Words added successfully: $words');
        _textFieldController.clear();
      }).catchError((error) {
        print('Error adding words: $error');
      });
    }
  }
  void _deleteWord(String wordToDelete) {
    _brainTrainGameCollection.doc('WordLanguage4').update({
      'words': FieldValue.arrayRemove([wordToDelete]),
    }).then((_) {
      print('Word deleted successfully: $wordToDelete');
    }).catchError((error) {
      print('Error deleting word: $error');
    });
  }
  void _selectWord(String word) {
    setState(() {
      _selectedWord = word;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedWord = '';
    });
  }
  String _selectedWord = '';
  @override
  Widget build(BuildContext context) {
    _TextPage.text = pageCount.toString();
    _TextPageAll.text = totalPageCount.toString();
    if (!Responsive.isDesktopBig(context)) {
      _animationController.reverse();
      setState(() {});
    }
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
                'assets/svg/receipt.svg',
                width: 25,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Danh sách Test${_result}",
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
                    // width: 500,
                    height: constraints.maxHeight,
                    child: Stack(
                      children: <Widget>[
                        !testBug == true
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
                                    height: 50,
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.end,
                                      children: [
                                      ],
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextField(
                                        controller: _textFieldController,
                                        decoration: InputDecoration(labelText: 'Nhập từ cần thêm (có thể thêm nhanh nguyên dãy ngăn cách bởi dấu phẩy)'),
                                      ),
                                      SizedBox(height: 16.0),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: _addWord,
                                            child: Text('Thêm vào dữ liệu'),
                                          ),
                                          SizedBox(width: 16.0),
                                          ElevatedButton(
                                            onPressed: () {
                                              _deleteWord(_selectedWord);
                                            },
                                            child: Text('Xoá dữ liệu đã chọn'),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 32.0),
                                      Text(
                                        'Những từ đã có trong hệ thống (nhấn vào từ để chọn từ cần xoá)',
                                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8.0),
                                      StreamBuilder(
                                        stream: _brainTrainGameCollection.doc('WordLanguage4').snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return CircularProgressIndicator();
                                          }

                                          var wordLanguage4 = snapshot.data!.data() as Map<String, dynamic>;
                                          var wordsList = wordLanguage4['words'] as List<dynamic>;

                                          return Container(
                                            height: 500,
                                            width: 100,
                                            child: ListView.builder(
                                              itemCount: wordsList.length,
                                              itemBuilder: (context, index) {
                                                var word = wordsList[index] as String;

                                                return GestureDetector(
                                                  onTap: () {
                                                    _selectWord(word);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(8.0),
                                                    color: _selectedWord == word
                                                        ? Colors.blue.withOpacity(0.5)
                                                        : null,
                                                    child: Text('$word'),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

              ],
            ),
          );
        },
      ),
    );
  }




}

