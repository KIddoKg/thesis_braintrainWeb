import 'dart:convert';
import 'dart:developer';

import 'package:bmeit_webadmin/models/adminModel.dart';
import 'package:bmeit_webadmin/models/employerModel.dart';
import 'package:bmeit_webadmin/screen_web/LoginScreen/login_screen_web.dart';
import 'package:flutter/material.dart';
import '../../helper/appsetting.dart';

import '../../services/api.dart';
import '../../services/dio_helper.dart';
import 'package:flutter/cupertino.dart';

class Services {
  BuildContext? _context;

  Services._internal();

  static final Services _instance = Services._internal();

  static Services get instance => _instance;

  Services setContext(BuildContext context) {
    Services.instance._context = context;
    return _instance;
  }

  Future<void> _showAlert(String title, String message,
      {void Function()? onTap}) async {
    if (_context == null) return;

    await showCupertinoDialog(
        context: _context!,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        ));

    if (onTap != null) {
      onTap();
    }
  }

  Future<void> _gotoAuthenScreen() async {
    AppSetting.instance.reset();
    await AppSetting.pref.remove('@profile');
    AppSetting.instance.accessToken = "";
    Navigator.pushNamedAndRemoveUntil(_context!, '/login', (route) => false);
  }

  Future<T> _errorAction<T>(NetResponse res,
      {String? metaData,
        bool withLoadingBefore = true,
        Future<T> Function()? callApi}) async {
    String code = res.error!['code'];
    String message = res.error!['message'];

    if (_context == null) print('Chưa gán context cho mã lỗi "${code}" này');
    log('> context: $_context');

    // if (withLoadingBefore) Navigator.pop(_context!);

    switch (code) {
      case 'unauthorized':
        print("case nè");
        var res = await Services.instance.refreshToken();

        if (!res.isSuccess) {
          print("khác nè");
          await _showAlert('Thông báo', 'Hết thời gian đăng nhập. [Mã: $code]',
              onTap: () => _gotoAuthenScreen());
        } else {
          res.cast<AppSetting>(fromJson: res.data);
          var y = json.encode(AppSetting.instance.toJson());
          AppSetting.pref.setString('appsetting', y);

          if (callApi != null) {
            return await callApi();
          }
        }
        break;
      default:
        _showAlert(metaData != null ? metaData : 'Thông báo',
            '$message. [Nguồn: $code]');
        break;
    }

    return defaultReturnValue<T>();
  }

  T defaultReturnValue<T>() {
    if (T == bool) {
      return false as T;
    } else if (T == int) {
      return 0 as T;
    } else {
      return null as T;
    }
  }

  // Future<T> _errorAction<T>(
  //     NetResponse res,
  //     {String? metaData, bool withLoadingBefore = true, Future<T> Function()? callApi}
  //     ) async {
  //   String code = res.error!['code'];
  //   String message = res.error!['message'];
  //
  //   if (_context == null) print('Chưa gán context cho mã lỗi "${code}" này');
  //   log('> context: $_context');
  //
  //   T? returnValue;
  //
  //   switch (code) {
  //     case 'unauthorized':
  //       print("case nè");
  //       var res = await Services.instance.refreshToken();
  //
  //       if (!res.isSuccess) {
  //         print("khác nè");
  //         await _showAlert('Thông báo', 'Hết thời gian đăng nhập. [Mã: $code]',
  //             onTap: () => _gotoAuthenScreen());
  //       } else {
  //         res.cast<AppSetting>(fromJson: res.data);
  //         var y = json.encode(AppSetting.instance.toJson());
  //         AppSetting.pref.setString('appsetting', y);
  //
  //         if (callApi != null) {
  //           returnValue = await callApi();
  //         }
  //       }
  //       break;
  //     default:
  //       _showAlert(metaData != null ? metaData : 'Thông báo',
  //           '$message. [Nguồn: $code]');
  //       break;
  //   }
  //
  //   return returnValue!;
  // }


  Future<AdminModel?> getCurrentAccountInfor() async {
    var res = await API.getProfile().request();
    if (res.isSuccess) {
      return res.cast<AdminModel>();
    } else {
      return await _errorAction(res, callApi: () async {
        return getCurrentAccountInfor();
      });
    }
    return null;
  }

  Future<bool> logout() async {
    var res = API.logout().request();
    return true;
  }


  Future<NetResponse> login(String phone, String pwd) async {
    var res = await API.loginAdmin(phone, pwd).request();
    if (res.isSuccess) {
      print("daddđ${res.data}");
      res.cast<AdminModel>(fromJson: res.data);
      res.cast<AppSetting>(fromJson: res.data);

      var x = json.encode(AdminModel.instance.toJson());
      AppSetting.pref.setString('profile', x);

      var y = json.encode(AppSetting.instance.toJson());
      AppSetting.pref.setString('appsetting', y);

      return res;
    } else {
      _errorAction(res, withLoadingBefore: false);
    }
    return res;
  }

  Future<Employee> listUserID(String idUser) async {
    var res = await API.getListUserID(idUser).request();
    if (res.isSuccess) {
      return res.cast<Employee>();
    } else {
      return await _errorAction(
        res,
        callApi: () async {
          return listUserID(idUser);
        },
      );
    }
  }
  Future<bool?> setUserBL(String idUser, bool setMonitored) async {
    var res = await API.setUserBL(idUser,setMonitored).request();
    if (res.isSuccess) {
      return true;
    } else {
      return await _errorAction(
        res,
        callApi: () async {
          return setUserBL(idUser,setMonitored);
        },
      );
    }
  }

  Future<NetResponse?> getMonitorList(
      {page, size}) async {
    var res = await API.monitorList(page, size,).request();
    if (res.isSuccess) {
      return res;
    } else {
      return await _errorAction(
        res,
        callApi: () async {
          return getMonitorList(page:page, size:size);
        },
      );
    }
  }

  Future<NetResponse?> getEmployeeList(
      {page, size}) async {
    var res = await API.accountList(page, size,).request();
    if (res.isSuccess) {
      return res;
    } else {
      return await _errorAction(
        res,
        callApi: () async {
          return getEmployeeList(page:page, size:size);
        },
      );
    }
  }


  Future<NetResponse> refreshToken() async {
    return await API.refreshToken(AppSetting.instance.refreshToken).request();
  }

  Future<Map<String, dynamic>?> registerAccount(
      String name, String user, String password, String siteID) async {
    var res = await API.register(name, user, password, siteID).request();
    if (res.isSuccess)
      return res.data;
    else
      print("RRR${res.error!['message']}");
    return await _errorAction(res, callApi: () async {
      return registerAccount(name,user,password,siteID);
    });

    return null;
  }

  Future<bool> updateEmployeeInfor(Employee employee) async {
    var res = await API.updateAccount(employee).request();
    if (res.isSuccess)
      return true;
    else
      return await _errorAction(res, callApi: () async {
        return updateEmployeeInfor(employee);
      });
    // return false;
  }

  Future<bool> activeAccount(String accountId) async {
    var res = await API.activeAccount(accountId).request();
    if (res.isSuccess)
      return true;
    else
      return await _errorAction(res, callApi: () async {
        return activeAccount(accountId);
      });
    // return false;
  }

  Future<Employee?> getAdminInfor(String accountId) async {
    var res = await API.getProfileAdmin(accountId).request();
    if (res.isSuccess)
      return res.cast<Employee>();
    else
      return await _errorAction(res, callApi: () async {
        return getAdminInfor(accountId);
      });
    return null;
  }

  Future<bool> disableAccount(String accountId) async {
    var res = await API.disableAccount(accountId).request();
    if (res.isSuccess)
      return true;
    else
      return await _errorAction(res, callApi: () async {
        return disableAccount(accountId);
      });
    // return false;
  }


  Future<bool> resetPassword(
      String accountId, String username, String newPassword) async {
    var res =
    await API.resetPassword(accountId, username, newPassword).request();
    if (res.isSuccess) {
      return true;
    } else {
      return await _errorAction(
        res,
        callApi: () async {
          return resetPassword(accountId, username, newPassword);
        },
      );
    }
    // return false;
  }

  Future<Employee?> getDetailEmployeeInfor(String accountId) async {
    var res = await API.staff(accountId).request();
    if (res.isSuccess) {
      return res.cast<Employee>();
    } else {
      return await _errorAction(res, callApi: () async {
        return getDetailEmployeeInfor(accountId);
      });
    }
    // return null;
  }

  Future<NetResponse?> getListOrder(
      {page, size, Map<String, dynamic>? filter}) async {
    var res = await API.order(page, size, filter: filter).request();
    if (res.isSuccess)
      return res;
    else
      return await _errorAction(res, callApi: getListOrder);
    // return null;
  }

  Future<NetResponse?> getDataChart({Map<String, dynamic>? filter}) async {
    var res = await API.orderList(filter: filter).request();
    if (res.isSuccess)
      return res;
    else
      return await _errorAction(res, callApi: getDataChart);
    // return null;
  }

  Future<NetResponse?> getOrderInfo({required String id}) async {
    var res = await API.orderInfo(id).request();
    if (res.isSuccess)
      return res.data['notifyToken'];
    else
      return await _errorAction(res, callApi: () async {
        return getOrderInfo(id:id);
      });
    // return null;
  }
  Future<NetResponse?> getNotiInfo({required String phone}) async {
    var res = await API.getNoti(phone).request();
    if (res.isSuccess)
      return res;
    else
      return await _errorAction(res, callApi: () async {
        return getNotiInfo(phone:phone);
      });
    // return null;
  }

  Future<NetResponse?> getListOrderFindCode(
      {page, size, required String code}) async {
    var res = await API.order(page, size, code: code).request();
    if (res.isSuccess)
      return res;
    else
      return await _errorAction(res, callApi: () async {
        return getListOrderFindCode(page:page, size:size, code: code);
      });
    // return null;
  }

  Future<int> getTotalCancelledMoney(
      {page, size, Map<String, dynamic>? filter}) async {
    var res = await API.orderCancelled(page, size, filter: filter).request();
    if (res.isSuccess)
      return res.data;
    else
      return await _errorAction(res, callApi: () async {
        return getTotalCancelledMoney(page: page,size: size,filter: filter);
      });
    return 0;
  }

  Future<int> getTotalCompletedMoney(
      {page, size, Map<String, dynamic>? filter}) async {
    var res = await API.orderCompleted(page, size, filter: filter).request();
    if (res.isSuccess)
      return res.data;
    else
      return await _errorAction(res, callApi: () async {
        return getTotalCompletedMoney(page: page,size: size,filter: filter);
      });
    return 0;
  }

  Future<int> getTotalFailedMoney(
      {page, size, Map<String, dynamic>? filter}) async {
    var res = await API.orderFailed(page, size, filter: filter).request();
    if (res.isSuccess)
      return res.data;
    else
      return await _errorAction(res, callApi: () async {
        return getTotalFailedMoney(page: page,size: size,filter: filter);
      });
    return 0;
  }

  Future<int> getTotalPendingMoney(
      {page, size, Map<String, dynamic>? filter}) async {
    var res = await API.orderPending(page, size, filter: filter).request();
    if (res.isSuccess)
      return res.data;
    else
      return await _errorAction(res, callApi: () async {
        return getTotalPendingMoney(page: page,size: size,filter: filter);
      });
    return 0;
  }
  Future<NetResponse> getCheckCloseShift() async {
    var res = await API.checkCloseShift().request();
    if (res.isSuccess)
      return res;
    else
      return await _errorAction(res, callApi: () async {
        return getCheckCloseShift();
      });
  }
  Future<NetResponse> getCheckCloseShiftInfo(String id) async {
    var res = await API.checkCloseShiftInfo(id).request();
    if (res.isSuccess)
      return res;
    else
      return await _errorAction(res, callApi: () async {
        return getCheckCloseShiftInfo(id);
      });
  }
  Future<NetResponse> orderPrint(String orderId) async {
    var res = await API.orderPrint(orderId).request();
    if (res.isSuccess)
      return res.data['printCount'];
    else
      return await _errorAction(res, callApi: () async {
        return orderPrint(orderId);
      });
  }
}
