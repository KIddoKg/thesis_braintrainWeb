import '../helper/formatter.dart';

class TransactionModel {
  late String username;
  late String billCode;
  late int billFee;
  late int receiveMoney;
  late int changeMoney;
  late bool isCancelable;
  late String id;
  late String code;
  late String state;
  late int transactionType;
  late int createDate;
  late int completeDate;
  late int amount;
  late String note;
  late int balance;
  late String serviceId;
  late int serviceType;
  late String serviceTypeName;
  late String serviceName;
  late String accountId;
  late String accountName;
  late bool isViettel;
  late int billMoney;
  late String payerName;
  late String payerPhone;
  late String customerName;
  late String customerPhone;

  TransactionModel.fromJson(Map<String, dynamic> json)
      :billCode = json['billCode'] ?? '',
        billFee = json['billFee'] ?? 0,
        receiveMoney = json['receiveMoney'] ?? 0,
        changeMoney = json['changeMoney'] ?? 0,
        isCancelable = json['isCancelable'] ?? false,
        id = json['id'] ?? '',
        code = json['code'] ?? '',
        state = stateToString(json['state']),
        transactionType = json['transactionType'] ?? -1,
        // createDate = json['createDateTime'] != null
        //     ? (json['createDateTime'] as int).toDateString()
        //     : '',
        createDate = json['createDateTime'] ?? 0,
        completeDate = json['completeDateTime'] ?? 0,
        amount = json['amount'] ?? 0,
        note = json['note'] ?? '',
        balance = json['balance'] ?? 0,
        serviceId = json['serviceId'] ?? '',
        serviceType = json['serviceType'] ?? 0,
        serviceTypeName = serviceTypeToString(json['serviceType'] ?? ''),
        serviceName = json['serviceName'] ?? '',
        accountId = json['accountId'] ?? '',
        username = json['username'] ?? '',
        accountName = json['accountName'] ?? '',
        billMoney = json['billMoney'] ?? 0,
        isViettel = json['isViettelService'] ?? false,
        payerName = json['payerName'] ?? "",
        payerPhone = json['payerPhone'] ?? "",
        customerName = json['customerName'] ?? "",
        customerPhone = json['customerPhone'] ?? "";

  static String serviceTypeToString(int type) {
    ServiceType? typeService;
    switch (type) {
      case 6:
        typeService = ServiceType.homePhone;
        break;
      case 4:
        typeService = ServiceType.internet;
        break;
      case 2:
        typeService = ServiceType.waterBill;
        break;
      case 5:
        typeService = ServiceType.phoneTopup;
        break;
      case 7:
        typeService = ServiceType.gameCard;
        break;
      case 1:
        typeService = ServiceType.powerBill;
        break;
      case 8:
        typeService = ServiceType.viettelMoney;
        break;
      case 3:
        typeService = ServiceType.financial;
        break;
    }
    KeyValue serviceInfo = getServiceTypeInfo(typeService!);
    return serviceInfo.key;
  }

  static String stateToString(int state) {
    if (state == 0) return 'Đang xử lý';
    if (state == 1) return 'Thành công';
    if (state == -2) return 'Huỷ';
    if (state == -1) return 'Thất bại';
    return 'Thất bại';
  }
}
