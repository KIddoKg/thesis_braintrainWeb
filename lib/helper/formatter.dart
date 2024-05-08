import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DoubleNumberExtension on double {
  String spaceSeparateNumbers() {
    var f = NumberFormat('#,##0');
    return f.format(this);
  }
}

extension IntegerNumberExtension on int {
  String toCurrency({subfix = 'đ'}) {
    var f = NumberFormat('###,###');
    return f.format(this) + subfix;
  }

  String toDateString({format = 'HH:mm dd/MM/yyyy'}) {
    var x = DateFormat(format)
        .format(DateTime.fromMillisecondsSinceEpoch(this, isUtc: false));
    return x;
  }
}

extension CapExtension on String {
  String get inCaps =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';

  String get capitalizeFirstofEach => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");
}

enum PopupInfor { notFound, wrongMoney, needLessMoney, finishWork }
enum ChartService { total, internet, water, phone, card, electric, viettelMoney, other,phoneCard }
class KeyIcon {
  String key;
  String name;
  int number;

  KeyIcon(String key, String name,int number)
      : key = key,
  name =name,
        number =number;

}

KeyIcon getServiceTypeIcon(ChartService type) {
  KeyIcon x = KeyIcon('','',0);
  switch (type) {
    case ChartService.total:
      x = KeyIcon('assets/svg/total.svg', 'Tổng Doanh thu',0);
      break;
    case ChartService.internet:
      x = KeyIcon('assets/svg/internet.svg','Internet/truyền hình',4);
      break;
    case ChartService.water:
      x = KeyIcon('assets/svg/waterBill.svg','Đóng điện nước',2);
      break;
    case ChartService.phone:
      x = KeyIcon('assets/svg/phone.svg','Nạp điện thoại',5);
      break;
    case ChartService.card:
      x = KeyIcon('assets/svg/card.svg','Nạp thẻ game',7);
      break;
    case ChartService.electric:
      x = KeyIcon('assets/svg/electricBill.svg','Đóng tiền điện',1);
      break;
    case ChartService.viettelMoney:
      x = KeyIcon('assets/svg/viettel.svg','Nạp Viettel Money',8);
      break;
      case ChartService.other:
      x = KeyIcon('assets/svg/more.svg','Thu hộ khác',3);
      break;
    case ChartService.phoneCard:
      x = KeyIcon('assets/svg/phone.svg','Nạp thẻ cào',6);
      break;
    default:
      x = KeyIcon('assets/svg/more.svg','Thu hộ khác',3);
      break;
  }
  return x;
}
enum IconService { notFound, wrongMoney, needLessMoney, finishWork }

enum ServiceType {
  homePhone,
  homePhoneViettel,
  internet,
  waterBill,
  phoneTopup,
  gameCard,
  powerBill,
  financial,
  viettelMoney
}

class KeyValue {
  String key;
  dynamic value;

  KeyValue(String key, dynamic value)
      : key = key,
        value = value;
}

KeyValue getServiceTypeInfo(ServiceType type) {
  KeyValue x = KeyValue('', null);
  switch (type) {
    case ServiceType.homePhone:
      x = KeyValue('Mua thẻ điện thoại', 6);
      break;
    case ServiceType.internet:
      x = KeyValue('Internet/truyền hình Viettel', 4);
      break;
    case ServiceType.waterBill:
      x = KeyValue('Đóng tiền nước', 2);
      break;
    case ServiceType.phoneTopup:
      x = KeyValue('Nạp tiền điện thoại', 5);
      break;
    case ServiceType.gameCard:
      x = KeyValue('Mua thẻ game', 7);
      break;
    case ServiceType.powerBill:
      x = KeyValue('Đóng tiền điện', 1);
      break;
      case ServiceType.powerBill:
      x = KeyValue('Đóng tiền điện', 8);
      break;
    default:
      x = KeyValue('Thu hộ khác', 3);
      break;
  }
  return x;
}

class KeyNameService {
  String key;


  KeyNameService(String key)
      : key = key;
}

KeyNameService getServiceName(String gameType, int gameName) {
  KeyNameService x = KeyNameService('');
  switch (gameType) {
    case "ATTENTION":
      switch(gameName) {
        case 0 : x = KeyNameService('Tìm kiếm');
        break;
        case 1 : x = KeyNameService('Bắt cặp');
        break;
        case 2 : x = KeyNameService('Bắt cá');
        break;
      }
      break;
    case "LANGUAGE":
      switch(gameName) {
        case 0 : x = KeyNameService('Tìm từ bắt đầu với');;
        break;
        case 1 : x = KeyNameService('Tìm từ tiếp theo');
        break;
        case 2 : x = KeyNameService('Nối từ');
        break;
        case 3 : x = KeyNameService('Sắp xếp từ');
        break;
      }
      break;
    case "MATH":
      switch(gameName) {
        case 0 : x = KeyNameService('Trò chơi mua sắm');
        break;
        case 1 : x = KeyNameService('Tìm Tổng');
        break;
      }
      break;
    case "MEMORY":
      switch(gameName) {
        case 0 : x = KeyNameService('Ghi nhớ màu');
        break;
        case 1 : x = KeyNameService('Tìm hình mới');
        break;
        case 2 : x = KeyNameService('Đó là hình nào');
        break;
      }
      break;
  }
  return x;
}


extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  Color hex(String hexString) {
    var c = hexString.replaceAll('#', '0xff');
    return Color(int.parse('$c'));
  }
}

extension StringColor on String {
  Color toColor() {
    if (this.isEmpty) return Colors.white;
    var c = this.replaceAll('#', '0xff');
    return Color(int.parse('$c'));
  }
}


// extension 
