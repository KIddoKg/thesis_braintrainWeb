import 'package:bmeit_webadmin/res/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

import '../../helper/appsetting.dart';
import '../../services/services.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    logOut();
  }

  Future<void> logOut() async {
    var res = await Services.instance.setContext(context).logout();
    if (res == true) {
      AppSetting.instance.reset();
      await AppSetting.pref.remove('@profile');
      AppSetting.instance.accessToken = "";
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
              //   ClipPath(
              //     clipper: WaveClipper(),
              //     child: Container(
              //       padding: const EdgeInsets.only(bottom: 450),
              //       color: Colors.blue.withOpacity(.8),
              //       height: 220,
              //       alignment: Alignment.center,
              //
              //     ),
              //   ),
                Container(
                  height: 180,
                  child: ClipPath(
                    clipper: WaveClipper(waveDeep: 0, waveDeep2: 100 ),
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 50),
                      color: Colors.blue.withOpacity(.3),
                      height: 180,
                      alignment: Alignment.center,

                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 180-180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(

                        width: MediaQuery.of(context).size.width/2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'WEDSITE ĐANG',
                                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Colors.black54),
                                  children: const <TextSpan>[

                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: 'ĐƯỢC ',
                                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Colors.black54),
                                  children: const <TextSpan>[
                                    TextSpan(text: 'BẢO TRÌ', style: TextStyle(fontWeight: FontWeight.w900,fontSize: 45,color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                            SizedBox(height: 20,),
                            Text("Vui lòng quay lại sau",style: TextStyle(color: Colors.grey,fontSize: 18),),
                          ],
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width/2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Lottie.asset('assets/json/maintenance.json',height: 900, fit: BoxFit.contain,),
                          )),

                    ],
                  ),
                ),
                Container(
                  height: 180,
                  child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationX(pi),
                    child: ClipPath(

                      clipper: WaveClipper(waveDeep: 150, waveDeep2: 0 ),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 50),
                        color: Colors.blue.withOpacity(.3),
                        height: 180,
                        alignment: Alignment.center,

                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
class WaveClipper extends CustomClipper<Path> {
  final double waveDeep;
  final double waveDeep2;


  WaveClipper({this.waveDeep = 100,this.waveDeep2 = 0});
  @override
  Path getClip(Size size) {
    final double sw = size.width;
    final double sh = size.height;

    final Offset controlPoint1 = Offset(sw * .25 , sh -waveDeep2*2);
    final Offset destinationPoint1 = Offset(sw * .5  , sh - waveDeep- waveDeep2);

    final Offset controlPoint2 = Offset(sw * .75 , sh  - waveDeep*2 );
    final Offset destinationPoint2 = Offset(sw  , sh - waveDeep);

    final Path path = Path()
      ..lineTo(0, size.height-waveDeep2)
      ..quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, destinationPoint1.dx, destinationPoint1.dy
      )
      ..quadraticBezierTo(controlPoint2.dx, controlPoint2.dy ,destinationPoint2.dx, destinationPoint2.dy
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; //if new instance have different instance than old instance
    //then you must return true;
  }
}