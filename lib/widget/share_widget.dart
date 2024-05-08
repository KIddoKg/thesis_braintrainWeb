import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:bmeit_webadmin/helper/formatter.dart';
import 'package:bmeit_webadmin/widget/style.dart';

class TextFieldPassword extends StatefulWidget {
  TextFieldPassword(this.field);

  TextEditingController field;

  @override
  State<TextFieldPassword> createState() => _TextFieldPasswordState();
}

class _TextFieldPasswordState extends State<TextFieldPassword> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _isVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.field,
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
    );
  }
}

class DMCLTextField extends StatelessWidget {
  TextEditingController? controller;
  String hintText;
  bool fromPowerBill;

  DMCLTextField(
      {required this.hintText, this.controller, this.fromPowerBill = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GlobalStyles.borderColor, width: 1),
      ),
      child: Center(
        child: TextField(
          textCapitalization: (fromPowerBill)
              ? TextCapitalization.characters
              : TextCapitalization.none,
          autocorrect: false,
          enableSuggestions: false,
          controller: controller,
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
            fillColor: Colors.red,
            hintText: hintText,
            hintStyle: TextStyle(color: GlobalStyles.textHintColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 8, right: 8),
          ),
        ),
      ),
    );
  }
}

class DMCLNumberField extends StatelessWidget {
  TextEditingController? controller;
  String hintText;

  DMCLNumberField({
    required this.hintText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GlobalStyles.borderColor, width: 1),
      ),
      child: Center(
        child: TextField(
          keyboardType: TextInputType.number,
          autocorrect: false,
          enableSuggestions: false,
          controller: controller,
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
            fillColor: Colors.red,
            hintText: hintText,
            hintStyle: TextStyle(color: GlobalStyles.textHintColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 8, right: 8),
          ),
        ),
      ),
    );
  }
}

class DMCLButton extends StatelessWidget {
  String title;
  Color? backgroundColor;
  Color? fontColor;
  FontWeight fontWeight;
  double fontSize;
  double height;
  void Function()? onTap;

  DMCLButton(this.title,
      {this.onTap,
      this.backgroundColor = Colors.transparent,
      this.fontColor = Colors.blue,
      this.fontSize = 20,
      this.height = 50,
      this.fontWeight = FontWeight.w500});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
            color: backgroundColor == Colors.transparent
                ? GlobalStyles.buttonBackgroundCollor
                : backgroundColor,
            border: Border.all(
                width: 1,
                color: backgroundColor == Colors.transparent
                    ? GlobalStyles.buttonBackgroundCollor
                    : backgroundColor!),
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: backgroundColor == Colors.transparent
                      ? fontColor
                      : GlobalStyles.getFontColorForBackground(
                          backgroundColor!),
                  fontSize: this.fontSize,
                  fontWeight: this.fontWeight),
            ),
          ),
        ),
      ),
    );
  }
}

class DMCLShadow extends StatelessWidget {
  Widget child;
  Offset direction;
  double radius;

  DMCLShadow(
      {required this.child, this.direction = Offset.zero, this.radius = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(27, 0, 0, 0),
            blurRadius: 12,
            offset: this.direction, // Shadow position
          ),
        ],
      ),
      child: child,
    );
  }
}

class AvatarLoad extends StatelessWidget {
  AvatarLoad(this.url, {this.size = 25});

  String url;
  double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: size,
        backgroundColor: Colors.transparent,
        child: this.url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: this.url,
                placeholder: (ctx, url) => const CircularProgressIndicator(
                  color: Colors.amber,
                  strokeWidth: 2,
                  backgroundColor: Colors.transparent,
                ),
                errorWidget: (ctx, url, error) => SvgPicture.asset(
                  "assets/img/user.svg",
                  height: size + 5,
                  width: size + 5,
                  color: Colors.white,
                ),
              )
            : SvgPicture.asset("assets/img/user.svg",
                height: size + 5, width: size + 5, color: Colors.white));
  }
}

class LoadingFragment extends StatelessWidget {
  LoadingFragment({this.text = 'Đang tải dữ liệu', this.style});

  String? text;
  TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          // backgroundColor: Color.fromARGB(128, 158, 158, 158),
          radius: 20,
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.amber,
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          text!,
          style: style == null ? TextStyle(color: Colors.grey) : style,
        )
      ],
    ));
  }
}

Future<dynamic> showAlert(BuildContext context, String title, String message,
    {List<CupertinoButton>? actions,
      List<ElevatedButton>? actionAndroids}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (actionAndroids != null)
          ...actionAndroids
        else
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Đồng ý'))
      ],
    ),
  );
}


class DMCLCard extends StatelessWidget {
  Widget? child;
  Color? backgroundColor;
  Color? borderColor;

  DMCLCard({this.child, this.backgroundColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: borderColor == null
                ? GlobalStyles.borderCardColor
                : borderColor!),
        borderRadius: BorderRadius.circular(8),
        color: this.backgroundColor == null
            ? GlobalStyles.backgroundCardColor
            : backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}

class DMCLRow extends StatelessWidget {
  DMCLRow({
    this.title,
    this.child,
    this.padding,
  });

  EdgeInsets? padding;
  Widget? title;
  Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding == null ? EdgeInsets.only(bottom: 8) : padding!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [if (title != null) title!, if (child != null) child!],
      ),
    );
  }
}

class DMCLRowText extends StatelessWidget {
  DMCLRowText(this.title, this.value,
      {this.styleTitle, this.styleValue, this.padding = null});

  String title, value;
  TextStyle? styleValue, styleTitle;
  EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return DMCLRow(
        padding: padding,
        title: Text(
          title,
          style: styleTitle == null
              ? TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: GlobalStyles.text54)
              : styleTitle,
        ),
        child: Text(
          value,
          style: styleValue == null
              ? TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black)
              : styleValue,
        ));
  }
}

class DMCLGroup extends StatelessWidget {
  DMCLGroup(
    this.title, {
    required this.child,
  });

  String title;
  Widget child;
  EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.0, bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black),
            ),
          ),
          child
        ],
      ),
    );
  }
}

class DMCLSearchBox extends StatelessWidget {
  TextEditingController? field;

  String hint;
  Function(String)? onSubmit;

  DMCLSearchBox(
      {this.hint = 'Tìm kiếm loại dịch vụ', this.onSubmit, this.field});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: '#F7F7F7'.toColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12),
                child: Center(
                  child: TextField(
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: onSubmit,
                    controller: field,
                    decoration: InputDecoration(
                        // prefixIcon: Padding(
                        //   padding: const EdgeInsets.all(12.0),
                        //   child: SvgPicture.asset("assets/img/magnifier.svg"),
                        // ),
                        border: InputBorder.none,
                        hintText: this.hint,
                        hintStyle: TextStyle(
                            fontSize: 18, color: GlobalStyles.text45)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
                color: GlobalStyles.backgroundActiveColor,
                borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              onPressed: () {
                if (onSubmit != null) onSubmit!(field!.text);
                FocusScope.of(context).unfocus();
              },
              iconSize: 28,
              icon: Icon(
                Icons.search,
              ),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class ListPickerItem extends StatelessWidget {
  bool isSelected;
  Function()? onTap;
  String title;
  dynamic value;

  ListPickerItem(this.title, {this.value, this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 16, left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.check,
                      color: isSelected
                          ? GlobalStyles.activeColor
                          : Colors.transparent,
                    )
                  ],
                ),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  toList() {}
}

class DMCLListView extends StatefulWidget {
  bool isSearching;
  List<ListPickerItem> data = [];
  void Function(int index)? onItemPress;

  DMCLListView(this.isSearching, this.data, {this.onItemPress});

  @override
  State<DMCLListView> createState() => _DMCLListViewState();
}

class _DMCLListViewState extends State<DMCLListView> {
  late List<String> test;
  int selectedIdx = -1;
  String test2 = "";

  @override
  void initState() {
    super.initState();
    test = widget.data
        .where((item) => item.isSelected)
        .map((item) => item.title)
        .toList();
    if (test.isNotEmpty) {
      for (var i = 0; i < widget.data.length; i++) {
        if (widget.data[i].title == test[test.length - 1]) {
          selectedIdx = i;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (ctx, index) {
        final item = widget.data[index];
        bool test3 = false;
        final isSelected;
        if (test.isNotEmpty && test.last == item.title) {
          isSelected = true;
        } else {
          isSelected = false;
        }

        return ListPickerItem(
          item.title,
          isSelected: isSelected,
          onTap: () {
            if (widget.onItemPress != null) widget.onItemPress!(index);

            setState(() {
              if (isSelected) {
                selectedIdx = -1;
                item.isSelected = false;
                // Unselect the currently selected item if it's already selected
              } else {
                for (var i = 0; i < widget.data.length; i++) {
                  widget.data[i].isSelected = false;
                  // Set isSelected = false for all items
                }

                test.add(item.title);
                item.isSelected = true;
                // Select the new item
              }
            });

            if (item.onTap != null) item.onTap!();
          },
        );
      },
    );
  }
}

class DMCLListPicker<T> extends StatefulWidget {
  BuildContext context;
  List<ListPickerItem> source;
  String? text;
  String title;
  ListPickerItem? _item;
  void Function(ListPickerItem item)? onChange;

  DMCLListPicker({
    required this.context,
    required this.source,
    required this.title,
    this.text = '',
    this.onChange,
  });

  @override
  State<DMCLListPicker<T>> createState() => _DMCLListPickerState<T>();
}

class _DMCLListPickerState<T> extends State<DMCLListPicker<T>> {
  List<ListPickerItem> filteredSource = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredSource.addAll(widget.source);
  }

  void performSearch(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      filteredSource = widget.source
          .where(
              (item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onModalPop(),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: GlobalStyles.borderColor),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 12.0, bottom: 12, left: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.text!.isEmpty ? widget.title : widget.text!,
                style: TextStyle(
                  fontSize: 18,
                  color: GlobalStyles.textHintColor,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onModalPop() {
    showModalBottomSheet(
      context: widget.context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DMCLModal(
        title: widget.title,
        height: MediaQuery.of(context).size.height * 0.85,
        body: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DMCLSearchBox(
              field: searchController,
              onSubmit: performSearch,
            ),
          ),
          Expanded(
            child: DMCLListView(
              isSearching,
              isSearching ? filteredSource : widget.source,
              onItemPress: (index) {
                setState(() {
                  widget._item = isSearching
                      ? filteredSource[index]
                      : widget.source[index];
                });
              },
            ),
          ),
          DMCLShadow(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DMCLButton(
                'Chọn',
                backgroundColor: GlobalStyles.backgroundActiveColor,
                fontColor: Colors.white,
                onTap: () {
                  setState(() {
                    widget.text = widget._item?.title ?? '';
                  });
                  Navigator.pop(ctx);

                  if (widget.onChange != null) {
                    widget.onChange!(widget._item!);
                  }

                  log('picker: ${widget.text}');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DMCLModal extends StatelessWidget {
  late String title;
  double height;
  Icon? leadingIcon;
  Widget? trailing;
  List<Widget>? body;

  DMCLModal(
      {required this.title,
      this.height = 600,
      this.leadingIcon,
      this.trailing,
      this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: IconButton(
                        iconSize: 32,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close)),
                  ),
                  Flexible(
                    flex: 3,
                    child: Text(
                      title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Flexible(
                      child: trailing ??
                          SizedBox(
                            width: 64,
                          ))
                ],
              ),
            ),
            ...body!
          ],
        ));
  }
}

Future<BuildContext?> showLoading(BuildContext context,
    {String message = 'Đang tải'}) async {
  BuildContext? _ctx;
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        _ctx = ctx;
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: Container(
            decoration: BoxDecoration(color: Color.fromARGB(128, 0, 0, 0)),
            child: Center(
                child: LoadingFragment(
              text: message,
              style: TextStyle(color: Colors.white),
            )),
          ),
        );
      });
  await Future.delayed(Duration(milliseconds: 100));
  return _ctx;
}

Future<BuildContext?> showPopup(BuildContext context,
    {PopupInfor? popupInfor = PopupInfor.notFound,
    int? money,
    String message = "",
    String icon = ""}) {
  if (popupInfor == PopupInfor.notFound) {
    message = message.isEmpty
        ? "Khánh hàng không có hóa đơn cần thanh toán"
        : message;
    icon = icon.isEmpty ? "assets/img/notFound.svg" : icon;
  } else if (popupInfor == PopupInfor.wrongMoney) {
    message = message.isEmpty
        ? "Số tiền khách đưa không được nhỏ hơn ${money!.toCurrency()}"
        : message;
    icon = icon.isEmpty ? "assets/img/wrongMoney.svg" : icon;
  } else if (popupInfor == PopupInfor.needLessMoney) {
    message = message.isEmpty
        ? "Số tiền khách đưa không được vượt quá ${money!.toCurrency()}"
        : message;
    icon = icon.isEmpty ? "assets/img/wrongMoney.svg" : icon;
  } else if (popupInfor == PopupInfor.finishWork) {
    message =
        message.isEmpty ? "Bạn có muốn thực hiện chốt ca không ?" : message;
    icon = icon.isEmpty ? "assets/img/group.svg" : icon;
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      color: Color.fromARGB(95, 0, 0, 0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          width: MediaQuery.of(context).size.width * 0.75,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: 100, height: 100, child: SvgPicture.asset(icon)),
                SizedBox(
                  height: 8,
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 16,
                ),
                (popupInfor == PopupInfor.finishWork)
                    ? DMCLButton(
                        'Đồng ý',
                        fontSize: 18,
                        fontColor: Colors.white,
                        onTap: () {},
                      )
                    : Visibility(visible: true, child: Container()),
                SizedBox(
                  height: 16,
                ),
                DMCLButton(
                  (popupInfor == PopupInfor.finishWork) ? 'Hủy' : 'Đã hiểu',
                  fontSize: 18,
                  fontColor: Colors.white,
                  onTap: () {
                    if (popupInfor == PopupInfor.notFound) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } else if (popupInfor == PopupInfor.wrongMoney ||
                        popupInfor == PopupInfor.needLessMoney ||
                        popupInfor == PopupInfor.finishWork) {
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class AnimationWidget extends StatefulWidget {
  AnimationWidget(this.child, {this.duration = 2000});

  Widget child;
  int duration;

  _AnimationWidgetState createState() => _AnimationWidgetState();
}

class _AnimationWidgetState extends State<AnimationWidget>
    with TickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: new Duration(milliseconds: widget.duration),
  )..repeat();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: RotationTransition(
          child: widget.child,
          turns: controller,
        ));
  }
}

class DMCLCardItem extends StatelessWidget {
  DMCLCardItem(
      {this.onTap,
      this.isSelected = false,
      required this.child,
      this.backgroundColor = Colors.transparent,
      this.backgroundSelected = Colors.redAccent,
      this.borderColor = Colors.grey,
      this.borderColorSelected = Colors.grey,
      this.width = 100,
      this.height = 60});

  double? width, height;
  Widget child;
  bool isSelected;

  Color? backgroundSelected;
  Color? backgroundColor;
  Color? borderColor;
  Color? borderColorSelected;

  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? backgroundSelected : backgroundColor,
            border: Border.all(
                width: 1,
                color: isSelected && borderColor != Colors.transparent
                    ? borderColorSelected!
                    : borderColor!),
          ),
          width: width,
          height: height,
          child: Padding(padding: EdgeInsets.all(8), child: child)),
    );
  }
}

Widget DMCLAppBar(context, title, siteId, {extendBody, leading}) {
  return DMCLShadow(
    direction: Offset(0, -15),
    child: Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * .07,
          bottom: 8,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: GlobalStyles.buttonBackgroundCollor),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 20,
                            color: GlobalStyles.backgroundDisableColor,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            siteId,
                            style: TextStyle(color: GlobalStyles.text45),
                          ),
                        ],
                      )
                    ],
                  ),
                  if (leading != null) leading
                ],
              ),
              if (extendBody != null) extendBody
            ],
          ),
        ),
      ),
    ),
  );
}

Function debounce(int milliseconds, {Function? func}) {
  Timer? timer;
  return () {
    if (timer != null) {
      timer!.cancel();
    }

    timer = Timer(Duration(milliseconds: milliseconds), () => {func!()});
  };
}
