class BillModel {
  String customerName;
  String billCode;
  int billMoney;
  int billFee;

  String? serviceId;
  int? receiveMoney;

  BillModel(String billCode, int billMoney, int billFee, int receiveMoney)
      : billCode = billCode,
        billMoney = billMoney,
        billFee = billFee,
        receiveMoney = receiveMoney,
        customerName = '';

  BillModel.fromJson(Map<String, dynamic> json)
      : customerName = json['customerName'] ?? '',
        billCode = json['billCode'],
        billMoney = json['billMoney'],
        billFee = json['billFee'];
}
