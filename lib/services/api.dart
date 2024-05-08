import 'package:dio/dio.dart';
import 'package:bmeit_webadmin/models/employerModel.dart';

import 'dio_helper.dart';

class API {
  static String identity = 'http://45.117.177.103:8080/api/admin';//dmcl
  static String auth = 'http://45.117.177.103:8080/api/auth';
  static String domain = 'https://api.thuho.service.dienmaycholon.vn/Admin';
  static String git domainAccount = '$domain/Account';
  static String domainOrder = '$domain/Order';
  static String domainOrderList = '$domain/Order/List';
  static String domainSite = '$domain/Site';
  static String dmcl_mobile = 'https://apiat.stdmcl.com:11443/api/v1';
  static String printApi = 'https://api.thuho.service.dienmaycholon.vn/App';
  static Dio dio = Dio();

  //https://api.thuho.service.dienmaycholon.vn/Identity
  static NetRequest getProfile() {
    String url = '$identity';

    NetRequest req = NetRequest(url, 'get')..withAuthen();
    return req;
  }

  //http://45.117.177.103:8080/api/auth/logout
  static NetRequest logout() {
    String url = '$auth/logout';

    NetRequest req = NetRequest(url, 'get')..withAuthen();
    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Identity/LoginAdmin
  static NetRequest loginAdmin(String phone, String pwd) {
    String url = '$identity/login';
    Map<String, String> data = Map();

    data['phone'] = phone;
    data['password'] = pwd;

    NetRequest req = NetRequest(url, 'post', data: data);

    return req;
  }

 // http://45.117.177.103:8080/api/admin/user/f0b17be9-cbff-4437-9fbf-f9ac83cb5836
  static NetRequest getListUserID(idUser) {
    var filterQuery = '';
    if (idUser != null) {
      filterQuery =
      'idUser';
    }

    String url = '$identity/user/$idUser';
    NetRequest req = NetRequest(url, 'get',)..withAuthen();
    return req;
  }

  // http://45.117.177.103:8080/api/admin/monitor-user?userId=f0b17be9-cbff-4437-9fbf-f9ac83cb5836&setMonitored=true
  static NetRequest setUserBL(idUser,setMonitored) {
    String url = '$identity/monitor-user?userId=$idUser&setMonitored=$setMonitored';
    NetRequest req = NetRequest(url, 'put',)..withAuthen();
    return req;
  }
  //http://45.117.177.103:8080/api/admin/all-users?pageNumber=0&pageSize=19
  static NetRequest accountList(int page, int size) {

    String url = '$identity/all-users?pageNumber=$page&pageSize=$size';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }
  // http://45.117.177.103:8080/api/admin/monitor-user?pageNumber=0&pageSize=2
  static NetRequest monitorList(int page, int size) {

    String url = '$identity/monitor-user?pageNumber=$page&pageSize=$size';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }
  // http://45.117.177.103:8080/api/admin/notify-token/0869307217
  static NetRequest getNoti(String phone) {

    String url = '$identity/notify-token/$phone';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }


  static NetRequest refreshToken(refreshToken) {
    Map<String, dynamic> data = Map();
    var filterQuery = '';
    if (refreshToken != null) {
      filterQuery =
      'refreshToken=$refreshToken';
    }

    String url = '$auth/refresh-token?$filterQuery';
    NetRequest req = NetRequest(url, 'post', data: data);
    return req;
  }


  //https://api.thuho.service.dienmaycholon.vn/Identity/Register
  static NetRequest register(String name,String user,String password, String siteID) {
    String url = '$identity/Register';
    Map<String, String> data = Map();

    data['name'] = name;
    data['username'] = user;
    data['password'] = password;
    data['siteId'] = siteID;

    NetRequest req = NetRequest(url, 'post', data: data);

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Account/{id}
  static NetRequest updateAccount(Employee employee) {
    print("EL<${employee.id}");
    String url = '$domainAccount/${employee.id}';
    print(employee);
    print(url);
    Map<String, dynamic> data = Map();

    data['active'] = employee.id!;
    data['name'] = employee.id!;
    data['avatarLink'] = employee.id;
    data['siteId'] = employee.id;
    data['username'] = employee.id;

    NetRequest req = NetRequest(url, 'put', data: data)..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Account/ActiveAccount/{id}
  static NetRequest activeAccount(String id) {
    String url = '$domainAccount/ActiveAccount/$id';

    NetRequest req = NetRequest(url, 'post')..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Account/Admin/{id}
  static NetRequest getProfileAdmin(String id) {
    String url = '$domainAccount/Admin/$id';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Account/DisableAccount/{id}
  static NetRequest disableAccount(String id) {
    String url = '$domainAccount/DisableAccount/$id';

    NetRequest req = NetRequest(url, 'post')..withAuthen();

    return req;
  }



  //https://api.thuho.service.dienmaycholon.vn/Admin/Account/ResetPassword/{id}
  static NetRequest resetPassword(String id, String username, String newPassword) {
    String url = '$domainAccount/ResetPassword/$id';
    Map<String, String> data = Map();

    data['username'] = username;
    data['newPassword'] = newPassword;

    NetRequest req = NetRequest(url, 'post', data: data)..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Account/Staff/{id}
  static NetRequest staff(String id) {
    String url = '$domainAccount/Staff/$id';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Order
  static NetRequest order(int page, int size, {Map<String, dynamic>? filter, String? code, String? billCode}) {
    var filterQuery = '';
    if (filter != null) {
      var accountId = filter['accountId'] ?? '';
      var state = filter['state'] ?? '';
      var fromDate = filter['fromDateTime'] ?? '';
      var toDate = filter['toDateTime'] ?? '';
      var serviceType = filter['serviceType'] ?? '';
      var shiftId = filter['shiftId'] ?? '';
      filterQuery =
      'state=$state&fromDateTime=$fromDate&toDateTime=$toDate&serviceType=$serviceType&shiftId=$shiftId';
    }
    if (code != null) filterQuery = '&code=$code';
    if (billCode != null) filterQuery = '&billCode=$billCode';

    String url = '$domainOrder?page=$page&size=$size&$filterQuery';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }
  //http://45.117.177.103:8080/api/admin/chart/by-game-type?userId=74fbebbb-8e56-490d-a2b3-b9d1771e66e3&gameType=ATTENTION&fromDate=1696700000000&toDate=1702838048750
  static NetRequest orderList({Map<String, dynamic>? filter}) {
    var filterQuery = '';
    if (filter != null) {
        var fromDate = filter['fromDateTime'] ?? '';
        var toDate = filter['toDateTime'] ?? '';
        var gameType= filter['gameType'] ?? '';
print("Dadadd${filter['gameType']}");
        // var userId = "74fbebbb-8e56-490d-a2b3-b9d1771e66e3";
        var userId = filter['id'];
        filterQuery =
        'userId=$userId&gameType=$gameType&fromDate=$fromDate&toDate=$toDate';


    }
    String url = '$identity/chart/by-game-type?$filterQuery';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

//https://api.thuho.service.dienmaycholon.vn/Admin/Order/{id}
  static NetRequest orderInfo(String id) {
    String url = '$domainOrder/$id';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Order/Cancelled
  static NetRequest orderCancelled(int page, int size, {Map<String, dynamic>? filter, String? code, String? billCode}) {
    var filterQuery = '';
    if (filter != null) {
      var accountId = filter['accountId'] ?? '';
      var state = filter['state'] ?? '';
      var fromDate = filter['fromDateTime'] ?? '';
      var toDate = filter['toDateTime'] ?? '';
      var serviceType = filter['serviceType'] ?? '';
      var shiftId = filter['shiftId'] ?? '';
      filterQuery =
      'accountId=$accountId&state=$state&fromDateTime=$fromDate&toDateTime=$toDate&serviceType=$serviceType&shifId=$shiftId';
    }
    if (code != null) filterQuery = '&code=$code';
    if (billCode != null) filterQuery = '&billCode=$billCode';

    String url = '$domainOrder/Cancelled?page=$page&size=$size&$filterQuery';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Order/Completed
  static NetRequest orderCompleted(int page, int size, {Map<String, dynamic>? filter, String? code, String? billCode}) {
    var filterQuery = '';
    if (filter != null) {
      var accountId = filter['accountId'] ?? '';
      var state = filter['state'] ?? '';
      var fromDate = filter['fromDateTime'] ?? '';
      var toDate = filter['toDateTime'] ?? '';
      var serviceType = filter['serviceType'] ?? '';
      var shiftId = filter['shiftId'] ?? '';
      filterQuery =
      'accountId=$accountId&state=$state&fromDateTime=$fromDate&toDateTime=$toDate&serviceType=$serviceType&shifId=$shiftId';
    }
    if (code != null) filterQuery = '&code=$code';
    if (billCode != null) filterQuery = '&billCode=$billCode';

    String url = '$domainOrder/Completed?page=$page&size=$size&$filterQuery';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Order/Failed
  static NetRequest orderFailed(int page, int size, {Map<String, dynamic>? filter, String? code, String? billCode}) {
    var filterQuery = '';
    if (filter != null) {
      var accountId = filter['accountId'] ?? '';
      var state = filter['state'] ?? '';
      var fromDate = filter['fromDateTime'] ?? '';
      var toDate = filter['toDateTime'] ?? '';
      var serviceType = filter['serviceType'] ?? '';
      var shiftId = filter['shiftId'] ?? '';
      filterQuery =
      'accountId=$accountId&state=$state&fromDateTime=$fromDate&toDateTime=$toDate&serviceType=$serviceType&shifId=$shiftId';
    }
    if (code != null) filterQuery = '&code=$code';
    if (billCode != null) filterQuery = '&billCode=$billCode';

    String url = '$domainOrder/Failed?page=$page&size=$size&$filterQuery';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Order/Pending
  static NetRequest orderPending(int page, int size, {Map<String, dynamic>? filter, String? code, String? billCode}) {
    var filterQuery = '';
    if (filter != null) {
      var accountId = filter['accountId'] ?? '';
      var state = filter['state'] ?? '';
      var fromDate = filter['fromDateTime'] ?? '';
      var toDate = filter['toDateTime'] ?? '';
      var serviceType = filter['serviceType'] ?? '';
      var shiftId = filter['shiftId'] ?? '';
      filterQuery =
      'accountId=$accountId&state=$state&fromDateTime=$fromDate&toDateTime=$toDate&serviceType=$serviceType&shifId=$shiftId';
    }
    if (code != null) filterQuery = '&code=$code';
    if (billCode != null) filterQuery = '&billCode=$billCode';

    String url = '$domainOrder/Pending?page=$page&size=$size&$filterQuery';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/Admin/Site
  static NetRequest site() {
    String url = '$domainSite';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/App/Shift
  static NetRequest checkCloseShift() {
    String url = '$printApi/Shift';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

  //https://api.thuho.service.dienmaycholon.vn/App/Shift/{id}
  static NetRequest checkCloseShiftInfo(String id) {
    String url = '$printApi/Shift/${id}';

    NetRequest req = NetRequest(url, 'get')..withAuthen();

    return req;
  }

  // https://api.thuho.service.dienmaycholon.vn/App/Shift/{id}/Print
  static NetRequest orderPrint(String orderId) {
    String url = '$printApi/Shift/${orderId}/Print';

    NetRequest req = NetRequest(url, 'post')..withAuthen();
    return req;
  }

}