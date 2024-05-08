import 'package:flutter/material.dart';

import 'colors.dart';
import 'dimensions.dart';

class AppStyles {
  static var addressBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimensions.radius),
    borderSide: const BorderSide(color: AppColors.background),
  );
  static var underLineBorder = const UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.white),
  );

  static var focusedTransparentBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimensions.radius),
    borderSide: const BorderSide(color: Colors.transparent),
  );
  static var energyBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimensions.radius),
    borderSide: const BorderSide(color: Colors.transparent),
  );

  static var focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimensions.radius),
    borderSide: const BorderSide(color: AppColors.background, width: 0.3),
  );
  static var focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimensions.radius),
    borderSide: const BorderSide(color: AppColors.primary, width: 0.3),
  );

  static var focusErrorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimensions.radius),
    borderSide: const BorderSide(color: AppColors.secondary),
  );
}

errorTextStyle(context) =>
    TextStyle(fontSize: 10, color: Theme.of(context).errorColor, fontWeight: FontWeight.w500, height: 1.4);

class Responsive {
  static bool isDesktopSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < 1350;
  static bool isDesktopOpenPOP(BuildContext context) =>
      MediaQuery.of(context).size.width < 1680;
  static bool isDesktopBig(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1300;
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 1150;
  static bool isMobileSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;
// static bool isMobileBig(BuildContext context) =>
//     MediaQuery.of(context).size.width < 1250;
}


Map<String, dynamic> filterDataInstance = {
  "state": null,
  "fromDateTime": DateTime.now().millisecondsSinceEpoch,
  "toDateTime": DateTime.now().millisecondsSinceEpoch,
  "serviceType": null,
};

Map<String, dynamic> createFilterData() {
  filterDataInstance = {
    "state": null,
    "fromDateTime": DateTime.now().millisecondsSinceEpoch,
    "toDateTime": DateTime.now().millisecondsSinceEpoch,
    "serviceType": null,
  };
  return filterDataInstance;
}
