import 'dart:async';
import 'dart:html';
import 'dart:ui' as ui; // Import the ui library for Image.toByteData
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
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
import 'package:image/image.dart' as img; // Import thư viện image

class SettingATOne extends StatefulWidget {
  SettingATOne({Key? key}) : super(key: key);

  @override
  _SettingATOneState createState() => _SettingATOneState();
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

class _SettingATOneState extends State<SettingATOne>
    with SingleTickerProviderStateMixin {
  FocusNode _focus = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController name = TextEditingController();
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

  final CollectionReference _brainTrainGameCollection =
      FirebaseFirestore.instance.collection('BrainTrainGame');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late Uint8List _imageBytes;

  void _addAttentionData() async {
    if (imageData == null) {
      showAlert(context, "Thiếu dữ liệu", "Thiếu ảnh");
      return;
    }
    ;
    if (titleController.text == "") {
      showAlert(context, "Thiếu dữ liệu", "Thiếu câu hỏi");
      return;
    }
    ;
    if (xxResult == 0 || xxResult == 0) {
      showAlert(context, "Thiếu dữ liệu", "Chư nhập đáp án");
      return;
    }
    ;

    _imageBytes = imageData!;
    try {
      // Upload image to Firebase Storage
      if (_imageBytes != null) {
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();

        UploadTask uploadTask = _storage
            .ref('attention_images')
            .child("${name.text}.png")
            .putData(_imageBytes, SettableMetadata(contentType: 'image/png'));
        // Get the current attentionData array from Firestore
        DocumentSnapshot documentSnapshot =
            await _brainTrainGameCollection.doc('Attention1').get();
        List<dynamic>? currentAttentionData =
            documentSnapshot.get('attentionData');

        // If 'attentionData' doesn't exist, initialize it as an empty array
        currentAttentionData ??= [];

        // Generate a unique key based on the existing array
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        // Add data to Firestore
        Map<String, dynamic> attentionDataItem = {
          'img': imageUrl,
          'key': name.text,
          'title': titleController.text,
          'result': {'x': xxResult, 'y': yyResult},
          'size': {'x': xx, 'y': yy},
        };

        // Update 'attentionData' in Firestore
        _brainTrainGameCollection.doc('Attention1').set({
          'attentionData': FieldValue.arrayUnion([attentionDataItem])
        }, SetOptions(merge: true)).then((_) {
          print('Attention data added successfully');
          showAlert(context, "Thành công", "Thêm câu hỏi thành công");
          setState(() {
            titleController.text = "";
            xxResult = 0;
            yyResult = 0;
            imageData = null;
          });
        }).catchError((error) {
          print('Error adding attention data: $error');
        });
      } else {
        print('Please select an image before adding attention data.');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  final _pickedImages = <Image>[];
  final _pickedImagesA = <Image>[];

  Future<void> _getImage() async {
    final fromPicker = await ImagePickerWeb.getImageAsWidget();

    if (fromPicker != null) {
      setState(() {
        _pickedImages.clear();
        _pickedImages.add(fromPicker);
        print(_pickedImages);
      });

      // Check if the list is not empty and the first image has a non-null height
      if (_pickedImages.isNotEmpty) {
        print("2834091280${_pickedImages[0].height}");
        print("2834091280${_pickedImages[0].width}");
        // print("2834091280${_pickedImages[0].}");
      } else {
        print("2834091280 Image height is null or list is empty");
      }
    }
  }

  String _imageInfo = '';
  TextEditingController titleController = TextEditingController();

  Future<void> _getImgFile() async {
    final infos = await ImagePickerWeb.getImageAsFile();
    setState(() => _imageInfo =
        'Name: ${infos?.size}\nRelative Path: ${infos?.relativePath}');
  }

  Future<void> _getImgInfo() async {
    final infos = await ImagePickerWeb.getImageInfo;
    final data = infos?.data;
    if (data != null) {
      setState(() {
        _pickedImages.clear();
        _pickedImages.add(Image.memory(data, semanticLabel: infos?.fileName));
        // _imageInfo = '${infos?.data}';
        imageData = infos!.data!;
      });
    }
    getImageDimensions();
  }

  Uint8List? imageData;

  Future<ui.Image> getImage() async {
    final Completer<ui.Image> completer = Completer();

    final ui.Codec codec = await ui.instantiateImageCodec(imageData!);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    completer.complete(frameInfo.image);

    return completer.future;
  }

  int xx = 0;
  int yy = 0;

  void getImageDimensions() {
    getImage().then((ui.Image image) {
      int width = image.width;
      int height = image.height;

      setState(() {
        yy = height;
        xx = width;
      });
      print('Image Width: $width, Height: $height');
    });
  }

  // void _readImageProperties() async {
  //   if (_pickedImages.isNotEmpty) {
  //     // Get the image info from the Image widget
  //     final ImageStream imageStream = _pickedImages[0].image.resolve(ImageConfiguration.empty);
  //
  //     // Wait for the image info to be available
  //     final ImageInfo imageInfo = await imageStream.first;
  //
  //     // Use the image info to get dimensions
  //     final int width = imageInfo.image.width;
  //     final int height = imageInfo.image.height;
  //
  //     print('Width: $width');
  //     print('Height: $height');
  //
  //     // Convert the ImageInfo to ByteData
  //     final ByteData byteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
  //     final Uint8List uint8List = byteData.buffer.asUint8List();
  //
  //     // Decode the image
  //     img.Image? image = img.decodeImage(uint8List);
  //
  //     if (image != null) {
  //       // Display additional image properties in the console
  //       print('Number of channels: ${img.channels(image)}');
  //       print('Format: ${image.format}');
  //     } else {
  //       print('Failed to decode image.');
  //     }
  //   } else {
  //     print('No image selected.');
  //   }
  // }

  // Future<void> _getImage() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
  //
  //     if (result != null) {
  //       _imageBytes = result.files.first.bytes!;
  //       setState(() {});
  //     } else {
  //       print('No file selected.');
  //     }
  //   } catch (error) {
  //     print('Error picking image: $error');
  //   }
  // }
  Offset? tappedPosition;
  bool all = false;

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
                            ? !all
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        right: 16.0,
                                        left: 8.0,
                                        top: 8,
                                        bottom: 16),
                                    child: AnimatedContainer(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(18.0),
                                        ),
                                        color: Colors.white,
                                      ),
                                      duration: Duration(milliseconds: 300),
                                      child: SingleChildScrollView(
                                        child: Container(
                                          height: constraints.maxHeight * 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  height: 50,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [],
                                                  )),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      width:
                                                          constraints.maxWidth /
                                                                  2 -
                                                              100,
                                                      child: TextField(
                                                        controller:
                                                            titleController,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Nhập câu hỏi',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: ElevatedButton(
                                                      onPressed: _getImgInfo,
                                                      child: Text('Chọn Ảnh'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width:
                                                          constraints.maxWidth /
                                                                  2 -
                                                              200,
                                                      child: TextField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                        controller: name,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Tên file (lưu ý nhập theo thứ tự)',
                                                        ),
                                                      ),
                                                    ),
                                                    Text(".png")
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ElevatedButton(
                                                  onPressed: _addAttentionData,
                                                  child: Text('Thêm câu hỏi'),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    all = true;
                                                    setState(() {});
                                                  },
                                                  child:
                                                      Text('Toàn bộ câu hỏi'),
                                                ),
                                              ),
                                              Divider(
                                                // height: 20,
                                                thickness: 1,
                                                indent: 20,
                                                endIndent: 20,
                                                color: Colors.grey,
                                              ),
                                              Text(
                                                  "Nhớ nhấn chọn vị trí câu trả lời vào trong ảnh"),
                                              imageData != null
                                                  ? InkWell(
                                                      onTapDown: (TapDownDetails
                                                              details) =>
                                                          onTapDown(
                                                              context, details),
                                                      child: Container(
                                                        width: xx.toDouble(),
                                                        height: yy.toDouble(),
                                                        child: Stack(
                                                          children: [
                                                            Container(
                                                              width:
                                                                  xx.toDouble(),
                                                              height:
                                                                  yy.toDouble(),
                                                              child: imageData !=
                                                                      null
                                                                  ? Image.memory(
                                                                      imageData!)
                                                                  : Container(),
                                                            ),
                                                            // Other widgets or overlays can be added here
                                                            if (tappedPosition !=
                                                                null)
                                                              Positioned(
                                                                left:
                                                                    tappedPosition!
                                                                            .dx -
                                                                        70,
                                                                top: tappedPosition!
                                                                        .dy -
                                                                    70,
                                                                child:
                                                                    Container(
                                                                  width: 140,
                                                                  height: 140,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .transparent,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .red,
                                                                      width: 5,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        right: 16.0,
                                        left: 8.0,
                                        top: 8,
                                        bottom: 16),
                                    child: AnimatedContainer(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(18.0),
                                        ),
                                        color: Colors.white,
                                      ),
                                      duration: Duration(milliseconds: 300),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  all = false;
                                                  setState(() {});
                                                },
                                                child: Text('Thêm câu hỏi'),
                                              ),
                                            ),
                                            Container(
                                              height: constraints.maxHeight * 2,
                                              child: StreamBuilder<
                                                  DocumentSnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection(
                                                        'BrainTrainGame')
                                                    .doc('Attention1')
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    return Center(
                                                        child: Text(
                                                            'Error: ${snapshot.error}'));
                                                  }

                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  }

                                                  List<dynamic>?
                                                      attentionDataList =
                                                      snapshot.data?.get(
                                                          'attentionData');
                                                  if (attentionDataList ==
                                                          null ||
                                                      attentionDataList
                                                          .isEmpty) {
                                                    return Center(
                                                        child: Text(
                                                            'No attention data available.'));
                                                  }

                                                  return ListView.builder(
                                                    itemCount: attentionDataList
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      Map<String, dynamic>
                                                          attentionData =
                                                          attentionDataList[
                                                                  index]
                                                              as Map<String,
                                                                  dynamic>;

                                                      // Assuming 'imageUrl' contains the file name (e.g., '1.png')
                                                      String fileName =
                                                          attentionData['img'];
                                                      String imageUrl =
                                                          'attention_images/$fileName.png';


                                                      return attentionDataWidget(
                                                          index,
                                                          fileName,
                                                          attentionData);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
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

  // Future<String> getDownloadURL(String path) async {
  //   final ref = FirebaseStorage.instance.ref().child(path);
  //   return await ref.getDownloadURL();
  // }

  double xxResult = 0;
  double yyResult = 0;

  void onTapDown(BuildContext context, TapDownDetails details) {
    print(details.localPosition.dx);
    print(details.localPosition.dy);
    // Handle the tap event here
    // You can access details.globalPosition to get the tap position

    double resultXFromCenterImage = details.localPosition.dx - xx / 2;
    double resultYFromCenterImage = details.localPosition.dy - yy / 2;

    print(resultXFromCenterImage + xx / 2);
    print(resultYFromCenterImage + yy / 2);

    setState(() {
      xxResult = resultXFromCenterImage + xx / 2;
      yyResult = resultYFromCenterImage + yy / 2;
      tappedPosition = details.localPosition;
    });
    // Additional logic can be added based on your requirements
  }

  void onTapped(Offset globalPosition) {
    // Handle the tap event here
    print(globalPosition);
    setState(() {
      tappedPosition = globalPosition;
    });
  }

  void _deleteAttentionData(String imageUrl) async {
    try {
      String documentId = 'Attention1'; // Replace with your actual document ID
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('BrainTrainGame')
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        List<dynamic>? currentAttentionData =
            documentSnapshot.get('attentionData');

        // Check if 'attentionData' exists and is a List
        if (currentAttentionData is List) {
          currentAttentionData.removeWhere((item) => item['img'] == imageUrl);

          await FirebaseFirestore.instance
              .collection('BrainTrainGame')
              .doc(documentId)
              .update({
            'attentionData': currentAttentionData,
          });

          print('Attention data deleted successfully');
        } else {
          print(
              'Error: Unable to delete attention data. Invalid data structure.');
        }
      } else {
        print('Error: Document does not exist.');
      }
    } catch (error) {
      print('Error deleting attention data: $error');
    }
  }

  Widget attentionDataWidget(
      int index, String img, Map<String, dynamic> attentionData) {


    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "${index + 1}. ${attentionData['title']}",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Show a confirmation dialog if needed
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Xoá ảnh'),
                        content: Text('Bạn có muốn xoá câu hỏi này?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text('Không'),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteAttentionData(attentionData['img']);
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text('Có'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                height: attentionData['size']['y'].toDouble(),
                width: attentionData['size']['x'].toDouble(),
                child: Column(
                  children: [
                    Container(
                      height: attentionData['size']['y'].toDouble(),
                      width: attentionData['size']['x'].toDouble(),
                      child: Image.network(
                          '$img'
                      ),

                    ),
                  ],
                ),
              ),
              // Circular shape


    Positioned(
                top: attentionData['result']['y'].toDouble() - 70,
                left: attentionData['result']['x'].toDouble() - 70,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.red,
                      width: 5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Widget attentionDataWidget(
//     int index, String img, Map<String, dynamic> attentionData) {
//   return Padding(
//     padding: const EdgeInsets.all(10.0),
//     child: Column(
//       children: [
//         Row(
//           children: [
//             Text(
//               "${index + 1}. ${attentionData['title']}",
//               style: TextStyle(
//                 fontSize: 20,
//               ),
//             ),
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: () {
//                 // Show a confirmation dialog if needed
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: Text('Xoá ảnh'),
//                       content: Text('Bạn có muốn xoá câu hỏi này?'),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pop(context); // Close the dialog
//                           },
//                           child: Text('Không'),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             _deleteAttentionData(attentionData['img']);
//                             Navigator.pop(context); // Close the dialog
//                           },
//                           child: Text('Có'),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//         Stack(
//           children: [
//             Container(
//               height: attentionData['size']['y'].toDouble(),
//               width: attentionData['size']['x'].toDouble(),
//               child: Column(
//                 children: [
//                   Container(
//                     height: attentionData['size']['y'].toDouble(),
//                     width: attentionData['size']['x'].toDouble(),
//                     child: Image.network(img),
//                   ),
//                 ],
//               ),
//             ),
//             // Circular shape
//             Positioned(
//               top: attentionData['result']['y'].toDouble() - 70,
//               left: attentionData['result']['x'].toDouble() - 70,
//               child: Container(
//                 width: 140,
//                 height: 140,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.transparent,
//                   border: Border.all(
//                     color: Colors.red,
//                     width: 5,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
}
