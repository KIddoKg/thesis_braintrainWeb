import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../helper/formatter.dart';
import '../../../models/dataChartModel.dart';
import '../../../models/gameModel.dart';
import '../../../res/colors.dart';
import '../../../services/services.dart';

Map<String, dynamic> filter = {
  'fromDateTime': DateTime.now().millisecondsSinceEpoch,
  'toDateTime': DateTime.now().millisecondsSinceEpoch,
  'gameType': 'd',
  'gameName': 0,
  'id': '',
};

class NavigationDrawerWidget extends StatefulWidget {
  final int fromDate;
  final int toDate;
  final String gameType;
  final int gameName;
  final String id;

  NavigationDrawerWidget({
    required this.fromDate,
    required this.toDate,
    required this.gameType,
    required this.gameName,
    required this.id, // Default duration
  });

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = EdgeInsets.symmetric(horizontal: 20);

  late EmployeeDataSource _employeeDataSource;

  List<GameModel> _employees = <GameModel>[];

  // List<GameModel> getEmployeeData() {
  //   return [
  //     GameModel(
  //         id: "7468012d-382c-4b7b-a9cd-cfa89e644e59",
  //         gameType: "MATH",
  //         gameName: "SUM",
  //         noOfLevels: 3,
  //         score: 2900,
  //         playTime: 0,
  //         level: 1,
  //         newPicOneResult: null,
  //         newPicTwoResult: null,
  //         noOfFishCaught: null,
  //         boatStatus: false,
  //         wordList: null,
  //         createdDate: 1702822535941),
  //     GameModel(
  //         id: "7468012d-382c-4b7b-a9cd-cfa89e644e59",
  //         gameType: "MATH",
  //         gameName: "SUM",
  //         noOfLevels: 3,
  //         score: 2900,
  //         playTime: 0,
  //         level: 1,
  //         newPicOneResult: null,
  //         newPicTwoResult: null,
  //         noOfFishCaught: null,
  //         boatStatus: false,
  //         wordList: null,
  //         createdDate: 1702822535941),
  //     GameModel(
  //         id: "7468012d-382c-4b7b-a9cd-cfa89e644e59",
  //         gameType: "MATH",
  //         gameName: "SUM",
  //         noOfLevels: 3,
  //         score: 2900,
  //         playTime: 0,
  //         level: 1,
  //         newPicOneResult: null,
  //         newPicTwoResult: null,
  //         noOfFishCaught: null,
  //         boatStatus: false,
  //         wordList: null,
  //         createdDate: 1702822535941),
  //   ];
  // }

  @override
  void initState() {
    super.initState();
    // _employees = getEmployeeData();
    _employeeDataSource = EmployeeDataSource(employees: _employees);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initData();
    });
  }

  Future<void> initData() async {
    filter['fromDateTime'] = widget.fromDate;
    filter['toDateTime'] = widget.toDate;
    filter['id'] = widget.id;

    // filter['gameName'] = filterData['toDateTime'];
    // filter['gameName'] = x.number;
    // filterDataBefore['gameName'] = x.number;
    var res;

    filter['gameType'] = widget.gameType;
    res = await Services.instance.getDataChart(filter: filter);

    if (res != null) {
      var data = res.castList<GameModel>();
      List<GameModel> dataFil = [];
      _employees = data;
      for (var e in _employees) {
        String x = "";
        switch (widget.gameType) {
          case "ATTENTION":
            switch (widget.gameName) {
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
            switch (widget.gameName) {
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
            switch (widget.gameName) {
              case 0:
                x = "SMALLER_EXPRESSION";
                break;
              case 1:
                x = "SUM";
                break;
            }
            break;
          case "MEMORY":
            switch (widget.gameName) {
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

        if (e.gameName == x) {
          dataFil.add(e);
        }
        filter['gameName'] = x;
      }
      _employeeDataSource = EmployeeDataSource(employees: dataFil);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var game = getServiceName(widget.gameType, widget.gameName);
    return Drawer(
      width: 1000,
      child: Material(
          color: AppColors.primary,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Chi tiết lịch sử của trò ${game.key}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
                  ),

                  Container(
                      height: MediaQuery.of(context).size.height - 70,
                      width: 1000,
                      child: buildTable1()),
                ],
              ),
            ),
          )),
    );
  }

  Widget buildTable1() {
    return SfDataGrid(
      columnWidthMode: ColumnWidthMode.fill,
      source: _employeeDataSource,
      // isScrollbarAlwaysShown: true,
      columns: [
        GridColumn(
            columnName: 'id',
            label: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.center,
                child: Text(
                  'ID',
                  overflow: TextOverflow.ellipsis,
                ))),
        GridColumn(
            columnName: 'name',
            label: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.center,
                child: Text(
                  'Tên Game',
                  overflow: TextOverflow.ellipsis,
                ))),
    if (filter['gameName'] != "LETTERS_REARRANGE")
        GridColumn(
            columnName: 'score',
            label: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.center,
                child: Text(
                  'Điểm số',
                  overflow: TextOverflow.ellipsis,
                ))),
        GridColumn(
            columnName: 'level',
            label: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.center,
                child: Text(
                  'Cấp độ',
                  overflow: TextOverflow.ellipsis,
                ))),
        if (filter['gameName'] == "LOST_PICTURE" || filter['gameName'] == "DIFFERENCE"|| filter['gameName'] == "PAIRING")
        GridColumn(
            columnName: 'time',
            label: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.center,
                child: Text(
                  'Thời gian chơi',
                  overflow: TextOverflow.ellipsis,
                ))),
        if (filter['gameName'] == "STARTING_LETTER" || filter['gameName'] == "STARTING_WORD" || filter['gameName'] == "NEXT_WORD")
          GridColumn(
              columnName: 'word',
              label: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Danh sách từ',
                    overflow: TextOverflow.ellipsis,
                  ))),
        if (filter['gameName'] == "FISHING" )
          GridColumn(
              columnName: 'fish',
              label: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Số cá bắt được',
                    overflow: TextOverflow.ellipsis,
                  ))),
        if (filter['gameName'] == "FISHING" )
          GridColumn(
              columnName: 'boatStatus',
              label: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Chiến thắng',
                    overflow: TextOverflow.ellipsis,
                  ))),
        if (filter['gameName'] == "NEW_PICTURE" )
          GridColumn(
              columnName: 'newPicOneResult',
              label: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Số hình lần chơi 1',
                    overflow: TextOverflow.ellipsis,
                  ))),
        if (filter['gameName'] == "NEW_PICTURE")
          GridColumn(
              columnName: 'newPicTwoResult',
              label: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Số hình lần chơi 1',
                    overflow: TextOverflow.ellipsis,
                  ))),
        GridColumn(
            columnName: 'date',
            label: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.center,
                child: Text(
                  'Ngày chơi game',
                  overflow: TextOverflow.ellipsis,
                ))),
      ],
    );
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required String email,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: padding.add(EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      );

  Widget buildMenuItem({
    required String text,
    required String icon,
    var colorText = "",
    VoidCallback? onClicked,
  }) {
    final color = Colors.white;

    final hoverColor = Colors.white70;
    if (colorText == "") {
      colorText = Colors.white70;
    }
    return ListTile(
      leading: Image.asset(icon),
      title: Text(text, style: TextStyle(color: colorText)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();

    switch (index) {
      case 0:
        break;
      case 1:
        break;
    }
  }
}

class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource({required List<GameModel> employees}) {
    dataGridRows = employees
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'id', value: dataGridRow.id),
              DataGridCell<String>(
                  columnName: 'name', value: dataGridRow.gameName),
      if (filter['gameName'] != "LETTERS_REARRANGE")
              DataGridCell<int>(columnName: 'score', value: dataGridRow.score),
              DataGridCell<int>(columnName: 'level', value: dataGridRow.level),
              if (filter['gameName'] == "LOST_PICTURE" || filter['gameName'] == "DIFFERENCE"|| filter['gameName'] == "PAIRING")
              DataGridCell<int>(columnName: 'time', value: dataGridRow.playTime),
      if (filter['gameName'] == "STARTING_LETTER" || filter['gameName'] == "STARTING_WORD"|| filter['gameName'] == "NEXT_WORD")
        DataGridCell<String>(
            columnName: 'word',
            value: dataGridRow.wordList),
              if (filter['gameName'] == "FISHING")
                DataGridCell<int>(
                    columnName: 'fish',
                    value: dataGridRow.noOfFishCaught),
      if (filter['gameName'] == "FISHING")
                DataGridCell<bool>(
                    columnName: 'boatStatus',
                    value: dataGridRow.boatStatus),
      if (filter['gameName'] == "NEW_PICTURE")
                DataGridCell<int>(
                    columnName: 'newPicOneResult',
                    value: dataGridRow.newPicOneResult),
              if (filter['gameName'] == "NEW_PICTURE")
                DataGridCell<int>(
                    columnName: 'newPicTwoResult',
                    value: dataGridRow.newPicTwoResult),
              DataGridCell<String>(
                  columnName: 'date',
                  value: DateTime.fromMillisecondsSinceEpoch(
                          dataGridRow.createdDate)
                      .toString()),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child:
          Text(dataGridCell.columnName == 'boatStatus' ?
            dataGridCell.value.toString() == "true" ? "Vượt qua" : "Thất bại" : dataGridCell.value.toString() ,
            // overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }
}
