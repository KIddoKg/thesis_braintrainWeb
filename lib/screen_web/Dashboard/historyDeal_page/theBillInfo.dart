import 'package:bmeit_webadmin/helper/formatter.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../../../models/transactionModel.dart';

class BillInfor extends StatelessWidget {
  final TransactionModel data;
  BillInfor({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 384,
      child: Column(
        children: [
          ...billContentCard(data.billMoney),
          Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tổng tiền",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                data.amount.toCurrency(),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tiền khách đưa:",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              Text(
                data.receiveMoney.toCurrency(),
                style: TextStyle(fontSize: 20, color: Colors.black),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trả lại khách:",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              Text(
                data.changeMoney.toCurrency(),
                style: TextStyle(fontSize: 20, color: Colors.black),
              )
            ],
          ),
          SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }

  List<Widget> billContentCard(int money) {
    List<Widget> trees = [];
    trees.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Thông tin thanh toán",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700, 
                color: Colors.black,
                fontSize: 23
              ),
            ),
          ],
        ));
    trees.add(SizedBox(height: 4,));
    if (data.payerName.isNotEmpty) {
      trees.add(rowTextPrint("Tên khách hàng", data.payerName));
    }

    if (data.payerPhone.isNotEmpty) {
      trees.add(rowTextPrint("Số điện thoại", data.payerPhone));
    }

    trees.add(SizedBox(height: 16,));
    
    trees.add(rowTextPrint('Dịch vụ', data.serviceType != 5 &&
                  data.serviceType != 6 &&
                  data.serviceType != 7
              ? data.note
              : data.serviceTypeName, flexLeft: 3, flexRight: 7));
    List<Widget> groupCard = [];
    switch (data.serviceType) {
      // nạp thẻ
      case 5:
        groupCard = [
          // rowTextPrint('Số điện thoại', '${tabSelected['phoneNumber']}'),
          rowTextPrint('Nhà mạng', '${data.serviceName}'),
          rowTextPrint('Số điện thoại', '${data.customerPhone}', flexLeft: 4, flexRight: 6),
          rowTextPrint('Mệnh giá', money.toCurrency()),
        ];
        break;

// thẻ cào
      case 6:
        groupCard = [
          rowTextPrint('Nhà mạng', '${data.serviceName}'),
          if (data.isViettel && data.customerPhone.isNotEmpty) ...{
            rowTextPrint("Số điện thoại", data.customerPhone),
          } ,
          rowTextPrint('Mệnh giá', money.toCurrency()),
        ];
        break;

// thẻ game
      case 7:
        groupCard = [
          rowTextPrint('Nhà cung cấp', '${data.serviceName}'),
          rowTextPrint('Mệnh giá', money.toCurrency()),
        ];
        break;

      default:
        groupCard = [
          rowTextPrint('Mã khách hàng', '${data.billCode}'),
          rowTextPrint('Số tiền', money.toCurrency()),
        ];
        if(data.customerName.isNotEmpty) {
          groupCard.insert(0, rowTextPrint("Tên khách hàng", data.customerName));
        }
        break;
    }

    trees.addAll(groupCard);
    trees.add(
      rowTextPrint('Phí thu hộ', data.billFee == 0 ? 'Miễn phí': data.billFee.toCurrency()),
    );
    return trees;
  }

  Widget rowTextPrint(String title, dynamic value, {int flexLeft = 5, int flexRight = 5}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: flexLeft,
            child: Text(
              title,
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          Flexible(
            flex: flexRight,
            child: Text(
              '${value}',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          )
        ],
      );
}
