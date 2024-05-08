class ShiftModel {
  String id;
  String code;
  int state;
  int createDateTime;
  int closeDateTime;
  String creatorId;
  String posKey;
  double orderMoney;

  ShiftModel({
    required this.id,
    required this.code,
    required this.state,
    required this.createDateTime,
    required this.closeDateTime,
    required this.creatorId,
    required this.posKey,
    required this.orderMoney,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] ?? "",
      code: json['code'] ??"",
      state: json['state']??0,
      createDateTime: json['createDateTime']??0,
      closeDateTime: json['closeDateTime']??0,
      creatorId: json['creatorId']??"",
      posKey: json['posKey']??"",
      orderMoney: json['orderMoney'].toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'state': state,
      'createDateTime': createDateTime,
      'closeDateTime': closeDateTime,
      'creatorId': creatorId,
      'posKey': posKey,
      'orderMoney': orderMoney,
    };
  }
}
