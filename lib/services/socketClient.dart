// ignore_for_file: library_prefixes, file_names, unused_local_variable, no_leading_underscores_for_local_identifiers

import 'dart:developer';


import 'package:bmeit_webadmin/models/adminModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../helper/appsetting.dart';

class DMCLSocket {
  static final DMCLSocket _instance = DMCLSocket._internal();
  static DMCLSocket get instance => _instance;

  BuildContext? _context;

  DMCLSocket._internal();

  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  DMCLSocket initSocket() {
    String host1 = 'https://dmcl-admin.onrender.com';

    if (_socket != null) return _instance;

    _socket = IO.io(
        host1,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .setTimeout(5000)
            .setReconnectionAttempts(3)
            .disableAutoConnect() // disable auto-connection
            .build());

    _socket!.connect();

    _socket!.onConnect((_) {
      log('socket.connected');

      if (_context != null) {
        ScaffoldMessenger.of(_context!).hideCurrentSnackBar();
      }

      if (AppSetting.instance.appLifecycleState == AppLifecycleState.resumed) {
        Fluttertoast.showToast(msg: 'Kết nối máy chủ.');
      }

      // userConnect(UserModel.instance);
    });

    _socket!.onDisconnect((_) {
      log('socket.disconnected');
    });

    _socket!.onReconnecting((data) {
      ScaffoldMessenger.of(_context!).showSnackBar(const SnackBar(
        content: Text('Đang kết nối máy chủ '),
      ));

      userConnect(AdminModel.instance);
      log('socket.reconnect $data');
    });

    _socket!.onError((data) async {
      log(
        'socket.error $data',
      );

      var userName = AdminModel.instance.name != null
          ? 'user: ${AdminModel.instance.name}'
          : '';

      // await API
      //     .botReport(
      //         msg:
      //             '[dmcl.checkgia.socketio]\n-$userName\n- device: ${AppSetting.instance.deviceID}]\n- OS: ${AppSetting.instance.deviceOS} \n$data')
      //     .request();
    });

    _socket!.on('disconnect_user', (data) {
      log('socket.disconnect from web-admin');

      if (_context == null) {
        log('socket.disconnect: error: _context for socket.init not set');
        return;
      }

      Navigator.pushNamedAndRemoveUntil(_context!, '/login', (route) => false,
          arguments: {'logout': false, 'socket': true});

      ScaffoldMessenger.of(_context!).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(
            Icons.warning,
          ),
          SizedBox(
            width: 4,
          ),
          Text(
              'Thiết bị ngắt kết nối bởi máy chủ.\nChi tiết: Quản trị viên/ quản lý ngắt kết nối.'),
        ]),
        action: SnackBarAction(
            label: 'Kết nối',
            onPressed: () {
              _socket!.connect();
            }),
        duration: const Duration(minutes: 5),
      ));

      _socket!.disconnect();
      AppSetting.instance.reset();

      // _gotoAuthenScreen();
    });

    _socket!.on('disconnect', (data) {
      log('socket.disconnect');
      // _showAlert('Thông báo',
      //     'Thiết bị ngắt kết nối từ máy chủ.\nChi tiết: Máy chủ ngắt kết nối.',
      //     actions:
      //         CupertinoButton(child: Text('Kết nối'), onPressed: onPressed));

      return;
      if (_context != null) {
        ScaffoldMessenger.of(_context!).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(
              Icons.info,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
                'Thiết bị ngắt kết nối bởi máy chủ.\nChi tiết: Máy chủ tự động ngắt kết nối.'),
          ]),
          action: SnackBarAction(
              label: 'Đồng ý',
              onPressed: () {
                Navigator.pop(_context!);
                // _socket!.connect();
              }),
          duration: const Duration(minutes: 5),
        ));
      }
    });

    return _instance;
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void userConnect(AdminModel user) {
    var _user = {
      'accountId': user.accountId,
      'name': user.name,
      'store': user.accountId,
      // 'time_login': user.sessionStart
    };

    // _socket!.emit('user_connected',
    //     {_socket!.id, user.name, user.siteId, user.sessionStart});

    _socket?.emit('user_connected', _user);

    log('socket.user_connected');
  }
}
