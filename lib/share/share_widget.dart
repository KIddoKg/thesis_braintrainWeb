import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bmeit_webadmin/helper/formatter.dart';
import 'package:bmeit_webadmin/res/colors.dart';

import '../widget/style.dart';

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;

  ExpandedSection({this.expand = true, required this.child});

  @override
  _ExpandedSectionState createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    Animation<double> curve = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        axisAlignment: 1.0, sizeFactor: animation, child: widget.child);
  }
}

class DMCLSearchBoxWeb extends StatefulWidget {
  TextEditingController? controller;
  bool isAutocomplete;
  bool enableClearButton;
  bool enableAnimationSubmit;

  int minKeywordSearch;
  Color? backgroundColor;
  String hint;
  FocusNode? focusNode;
  int delayTypingSubmit;
  void Function(String)? onSubmit;
  void Function(String)? onChange;

  DMCLSearchBoxWeb(
      {super.key,
      this.hint = 'Tìm kiếm sản phẩm',
      this.onChange,
      this.focusNode,
      this.onSubmit,
      this.isAutocomplete = true,
      this.minKeywordSearch = 4,
      this.delayTypingSubmit = 1200,
      this.controller,
      this.backgroundColor,
      this.enableClearButton = false,
      this.enableAnimationSubmit = false});

  @override
  State<DMCLSearchBoxWeb> createState() => _DMCLSearchBoxWebState();
}

class _DMCLSearchBoxWebState extends State<DMCLSearchBoxWeb> {
  double animationWithValue = 0;
  bool isAnimated = false;
  bool isDisplayButtonClear = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Flexible(
            child: Container(
              clipBehavior: Clip.hardEdge,
              height: 32,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? '#F7F7F7'.toColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 375),
                    curve: Curves.easeInCubic,
                    width: animationWithValue,
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12),
                    // just removed center here
                    child: TextField(
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      focusNode: widget.focusNode,
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: (value) => autocomplete(value, context),
                      onSubmitted: (value) {
                        onBeforeSubmit(value);
                        print('textfield.enter event');
                      },
                      textInputAction: TextInputAction.go,
                      controller: widget.controller,
                      decoration: InputDecoration(
                          suffixIconConstraints:
                              const BoxConstraints(maxWidth: 38),
                          suffixIcon: Visibility(
                            visible: isDisplayButtonClear,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: GlobalStyles.backgroundColor,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  widget.controller!.clear();
                                  isDisplayButtonClear = false;
                                  print(
                                      'autoComple.text $isDisplayButtonClear');
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.clear,
                                  // size: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          border: InputBorder.none,
                          hintText: widget.hint,
                          hintStyle: TextStyle(
                              fontSize: 16,
                              color: GlobalStyles.backgroundActiveColor)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Timer? timerAutocomplete;

  void autocomplete(String value, context) {
    if (widget.onChange != null && !widget.isAutocomplete) {
      widget.onChange!(value);
    }

    if (!widget.isAutocomplete) return;

    if (timerAutocomplete != null) {
      print('autoComple.cancel reset timer');
      timerAutocomplete!.cancel();
    }

    if ((value.isEmpty && isDisplayButtonClear ||
        value.isNotEmpty && !isDisplayButtonClear)) {
      isDisplayButtonClear = !isDisplayButtonClear;
      setState(() {});
      print(
          'autoComple.display button clear ${isDisplayButtonClear ? 'hiển thị' : 'ẩn'}');
    }

    if (value.length < widget.minKeywordSearch) {
      return;
    }

    timerAutocomplete = Timer.periodic(
        Duration(milliseconds: widget.delayTypingSubmit), (timer) {
      print('autoComple.cancel submit text');
      onBeforeSubmit(value);

      // hidden keyboard
      FocusScope.of(context).unfocus();
      timer.cancel();
    });
  }

  void onBeforeSubmit(value) {
    needRunAnimation();
    if (widget.onSubmit != null) widget.onSubmit!(value);
  }

  void needRunAnimation() async {
    if (widget.enableAnimationSubmit) {
      animationWithValue = MediaQuery.of(context).size.width;
      isAnimated = !isAnimated;
      setState(() {});

      //await Future.delayed(const Duration(milliseconds: 500));
      animationWithValue = 0;
      isAnimated = !isAnimated;
      setState(() {});
    }
  }
}

class DMCLButtonWeb extends StatelessWidget {
  String title;
  Color? backgroundColor;
  Color? border;
  Color? fontColor;
  FontWeight fontWeight;
  double fontSize;
  double height;
  bool disable;
  bool size;
  double width;
  void Function()? onTap;

  DMCLButtonWeb(this.title,
      {super.key,
      this.onTap,
      this.width = 50,
      this.disable = false,
      this.size = false,
      this.backgroundColor = Colors.transparent,
      this.border = Colors.transparent,
      this.fontColor = Colors.blue,
      this.fontSize = 16,
      this.height = 30,
      this.fontWeight = FontWeight.w500});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: size == true
          ? Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(
                      width: 1,
                      color: disable == true
                          ? AppColors.bgButton
                          : border == Colors.transparent
                              ? GlobalStyles.backgroundActiveColor
                              : border!),
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 2, bottom: 2, right: 10, left: 10),
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: disable == true ? AppColors.bgButton : fontColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight),
                  ),
                ),
              ),
            )
          : Container(
              height: height,
              decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(
                      width: 1,
                      color: disable == true
                          ? AppColors.bgButton
                          : border == Colors.transparent
                              ? GlobalStyles.backgroundActiveColor
                              : border!),
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 2, bottom: 2, right: 10, left: 10),
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: disable == true ? AppColors.bgButton : fontColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight),
                  ),
                ),
              ),
            ),
    );
  }
}

class LoadingIndicator extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Duration loadingDuration;

  LoadingIndicator({
    required this.isLoading,
    required this.child,
    this.loadingDuration = const Duration(seconds: 2), // Default duration
  });

  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();

    if (widget.isLoading == true) {
      // Start the loading process
      _showLoading = true;
      Future.delayed(widget.loadingDuration, () {
        if (!mounted) return;
        _showLoading = false;
        setState(() {});
      });
    } else {
      _showLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showLoading == true
        ? Center(
            child: ColorLoader3(
            radius: 10,
            dotRadius: 6.0,
            centerDot: false,
            dotColor2: AppColors.primaryColor,
            dotColor: AppColors.primaryColor,
            dotQuality: 8,
          ))
        : widget.child;
  }
}

class LoadingDot extends StatelessWidget {
  LoadingDot({this.text = 'Đang tải dữ liệu', this.style});

  String? text;
  TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ColorLoader3(
          radius: 10,
          dotRadius: 6.0,
          centerDot: false,
          dotColor2: AppColors.primaryColor,
          dotColor: AppColors.primaryColor,
          dotQuality: 8,
        ),
        Text(
          text!,
          style: style == null ? TextStyle(color: Colors.grey) : style,
        )
      ],
    ));
  }
}

class ColorLoader2 extends StatefulWidget {
  final Color color1;
  final Color color2;
  final Color color3;

  ColorLoader2(
      {this.color1 = Colors.deepOrangeAccent,
      this.color2 = Colors.yellow,
      this.color3 = Colors.lightGreen});

  @override
  _ColorLoader2State createState() => _ColorLoader2State();
}

class _ColorLoader2State extends State<ColorLoader2>
    with TickerProviderStateMixin {
  late Animation<double> animation1;
  late Animation<double> animation2;
  late Animation<double> animation3;
  late AnimationController controller1;
  late AnimationController controller2;
  late AnimationController controller3;

  @override
  void initState() {
    super.initState();

    controller1 = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);

    controller2 = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);

    controller3 = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller1, curve: Interval(0.0, 1.0, curve: Curves.linear)));

    animation2 = Tween<double>(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: controller2, curve: Interval(0.0, 1.0, curve: Curves.easeIn)));

    animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller3,
        curve: Interval(0.0, 1.0, curve: Curves.decelerate)));

    controller1.repeat();
    controller2.repeat();
    controller3.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Stack(
          children: <Widget>[
            new RotationTransition(
              turns: animation1,
              child: CustomPaint(
                painter: Arc1Painter(widget.color1),
                child: Container(
                  width: 50.0,
                  height: 50.0,
                ),
              ),
            ),
            new RotationTransition(
              turns: animation2,
              child: CustomPaint(
                painter: Arc2Painter(widget.color2),
                child: Container(
                  width: 50.0,
                  height: 50.0,
                ),
              ),
            ),
            new RotationTransition(
              turns: animation3,
              child: CustomPaint(
                painter: Arc3Painter(widget.color3),
                child: Container(
                  width: 50.0,
                  height: 50.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    super.dispose();
  }
}

class Arc1Painter extends CustomPainter {
  final Color color;

  Arc1Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p1 = new Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect1 = new Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    canvas.drawArc(rect1, 0.0, 0.5 * pi, false, p1);
    canvas.drawArc(rect1, 0.6 * pi, 0.8 * pi, false, p1);
    canvas.drawArc(rect1, 1.5 * pi, 0.4 * pi, false, p1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Arc2Painter extends CustomPainter {
  final Color color;

  Arc2Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p2 = new Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect2 = new Rect.fromLTWH(
        0.0 + (0.2 * size.width) / 2,
        0.0 + (0.2 * size.height) / 2,
        size.width - 0.2 * size.width,
        size.height - 0.2 * size.height);

    canvas.drawArc(rect2, 0.0, 0.5 * pi, false, p2);
    canvas.drawArc(rect2, 0.8 * pi, 0.6 * pi, false, p2);
    canvas.drawArc(rect2, 1.6 * pi, 0.2 * pi, false, p2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Arc3Painter extends CustomPainter {
  final Color color;

  Arc3Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p3 = new Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect3 = new Rect.fromLTWH(
        0.0 + (0.4 * size.width) / 2,
        0.0 + (0.4 * size.height) / 2,
        size.width - 0.4 * size.width,
        size.height - 0.4 * size.height);

    canvas.drawArc(rect3, 0.0, 0.9 * pi, false, p3);
    canvas.drawArc(rect3, 1.1 * pi, 0.8 * pi, false, p3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ColorLoader3 extends StatefulWidget {
  final double radius;
  final double dotRadius;
  final Color? dotColor;
  final Color? dotColor2;
  final bool centerDot;
  final int dotQuality;

  ColorLoader3(
      {this.radius = 30.0,
      this.dotRadius = 3.0,
      this.centerDot = true,
      this.dotColor = Colors.white,
      this.dotColor2 = Colors.yellow,
      this.dotQuality = 0});

  @override
  _ColorLoader3State createState() => _ColorLoader3State();
}

class _ColorLoader3State extends State<ColorLoader3>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation_rotation;
  late AnimationController controller;

  late double radius;
  late double dotRadius;

  late int visibleDotCount; // Number of visible dots
  int time = 3000;

  @override
  void initState() {
    super.initState();

    radius = widget.radius;
    dotRadius = widget.dotRadius;
    visibleDotCount = widget.dotQuality;
    controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    animation_rotation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          visibleDotCount++; // Show the next dot
          if (visibleDotCount <= 8) {
            controller.forward(from: 0.0); // Start the animation again
          } else {
            controller.repeat(); // Repeat the rotation animation
          }
        });
      }
    });

    controller.forward(); // Start the loading animation
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      child: Center(
        child: RotationTransition(
          turns: animation_rotation,
          child: Stack(
            children: <Widget>[
              if (widget.centerDot)
                new Transform.translate(
                  offset: Offset(0.0, 0.0),
                  child: Dot(
                    radius: radius,
                    color: widget.dotColor,
                  ),
                ),
              for (var i = 0; i < 8; i++)
                if (i < visibleDotCount)
                  Transform.translate(
                    offset: Offset(
                      (radius + 10) * cos(i * pi / 4),
                      (radius + 10) * sin(i * pi / 4),
                    ),
                    child: Dot(
                      radius: dotRadius,
                      color: i % 2 == 0 ? widget.dotColor : widget.dotColor2,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }
}

class Dot extends StatelessWidget {
  final double? radius;
  final Color? color;

  Dot({this.radius, this.color});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class DMCLPageButton extends StatelessWidget {
  IconData icon;
  Color? backgroundColor;
  Color? border;
  Color? fontColor;
  FontWeight fontWeight;
  double fontSize;
  double height;
  bool disable;
  bool size;
  double width;
  void Function()? onTap;

  DMCLPageButton(this.icon,
      {super.key,
      this.onTap,
      this.width = 10,
      this.disable = false,
      this.size = false,
      this.backgroundColor = Colors.transparent,
      this.border = Colors.transparent,
      this.fontColor = Colors.blue,
      this.fontSize = 16,
      this.height = 40,
      this.fontWeight = FontWeight.w500});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: disable == false ? onTap : null,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, right: 0, left: 0),
          child: Center(
            // child: Text(
            //   title,
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //       color: disable == true ? AppColors.bgButton:fontColor, fontSize: fontSize, fontWeight: fontWeight),
            // ),
            child: Icon(
              icon,
              size: fontSize,
              color: disable == false ? fontColor : Colors.grey,
            ),
          ),
        ));
  }
}

class DMCLTextFiledWeb extends StatelessWidget {
  TextEditingController controller;
  bool lock;
  String labelText;
  IconData icon;

  DMCLTextFiledWeb({
    super.key,
    required this.controller,
    this.lock = false,
    required this.labelText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 20),
      child: TextFormField(
        readOnly: lock,
        enableInteractiveSelection: false,
        controller: controller,
        decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(
              icon,
              color: AppColors.primaryColor,
            ),
            border: OutlineInputBorder()),
        validator: (value) {
          if (value!.isEmpty) {
            return labelText + " không được bỏ trống";
          }
          return null;
        },
      ),
    );
  }
}

class DMCLTextFiledPassWeb extends StatefulWidget {
  final TextEditingController controller;
  final bool lock;
  final String labelText;
  final IconData icon;

  DMCLTextFiledPassWeb({
    Key? key,
    required this.controller,
    this.lock = false,
    required this.labelText,
    required this.icon,
  }) : super(key: key);

  @override
  _DMCLTextFiledPassWebState createState() => _DMCLTextFiledPassWebState();
}

class _DMCLTextFiledPassWebState extends State<DMCLTextFiledPassWeb> {
  bool hide = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 8.0,
        right: 8.0,
        bottom: 20,
      ),
      child: TextFormField(
        readOnly: widget.lock,
        enableInteractiveSelection: false,
        controller: widget.controller,
        obscureText: hide,
        // Use obscureText to hide/show the password
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(hide ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                hide = !hide; // Toggle the value of hide and trigger a rebuild
              });
            },
          ),
          labelText: widget.labelText,
          prefixIcon: Icon(
            widget.icon,
            color: AppColors.primaryColor,
          ),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return widget.labelText + " không được bỏ trống";
          }
          return null;
        },
      ),
    );
  }
}

class AnimatedToggle extends StatefulWidget {
  final List<String> values;
  final ValueChanged onToggleCallback;
  final bool valueChoose;
  final Color backgroundColor;
  final Color buttonColor;
  final Color textColor;
  final bool lock;

  AnimatedToggle({
    required this.values,
    this.lock = false,
    required this.onToggleCallback,
    this.backgroundColor = const Color(0xFFe7e7e8),
    required this.buttonColor,
    this.textColor = const Color(0xFF000000), this.valueChoose = false,
  });

  @override
  _AnimatedToggleState createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> {
  late bool initialPosition =  widget.valueChoose ? true: false;

  @override
  Widget build(BuildContext context) {
    int size = 300;

    return Container(
      width: size * 0.6,
      height: size * 0.13,
      margin: EdgeInsets.all(20),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (widget.lock == false) {
                initialPosition = !initialPosition;
                var index = 0;
                if (!initialPosition) {
                  index = 1;
                }
                widget.onToggleCallback(index);
              }
              setState(() {});
            },
            child: Container(
              width: size * 0.6,
              height: size * 0.13,
              decoration: ShapeDecoration(
                color: widget.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size * 0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.values.length,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: size * 0.09),
                    child: Center(
                      child: Text(
                        widget.values[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xAA000000),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
            alignment:
                initialPosition ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: size * 0.33,
              height: size * 0.13,
              decoration: ShapeDecoration(
                color: widget.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size * 0.1),
                ),
              ),
              child: Text(
                initialPosition ? widget.values[0] : widget.values[1],
                style: TextStyle(
                  fontSize: 16,
                  color: widget.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}

Future<dynamic> showAlertAction(
    BuildContext context, String title, String message, Function()? onTap,
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
                // Call the onTap function if provided
                onTap?.call();

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Đồng ý'))
      ],
    ),
  );
}

class LoadingFragmentDot extends StatelessWidget {
  LoadingFragmentDot({this.text = 'Đang tải dữ liệu', this.style});

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

class ErrorsNoti extends StatelessWidget {
  ErrorsNoti({this.text = 'Không có dữ liệu', this.style});

  String? text;
  TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.warning,size: 70,color: Colors.orange,),
        Center(
          child: Text(
            text!,
            textAlign: TextAlign.center,
            style: style == null ? TextStyle(color: Colors.grey) : style,
          ),
        )
      ],
    ));
  }
}


// class UILabelTextField extends StatefulWidget {
//   final String? initValue;
//   final Function(TextEditingController)? onInit;
//   final Function(String)? onChangeValue;
//   final String? hintText;
//
//   UILabelTextField({
//     this.initValue,
//     this.onInit,
//     this.onChangeValue,
//     this.hintText,
//   });
//
//   @override
//   _UILabelTextFieldState createState() => _UILabelTextFieldState();
// }
//
// class _UILabelTextFieldState extends State<UILabelTextField> {
//   late TextEditingController fieldController;
//
//   @override
//   void initState() {
//     super.initState();
//     fieldController = TextEditingController();
//     if (widget.onInit != null) {
//       widget.onInit!(fieldController);
//     }
//     if (widget.initValue != null) {
//       fieldController.text = widget.initValue!;
//     }
//   }
//
//   @override
//   void dispose() {
//     fieldController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(widget.hintText ?? ''),
//         TextField(
//           controller: fieldController,
//           onChanged: (text) {
//             if (widget.onChangeValue != null) {
//               widget.onChangeValue!(text);
//             }
//           },
//         ),
//       ],
//     );
//   }
// }
