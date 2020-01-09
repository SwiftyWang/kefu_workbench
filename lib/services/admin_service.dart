import 'package:dio/dio.dart';

import 'api.dart';
import 'base_service.dart';

class AdminService extends BaseServices {
  static AdminService instance;
  static AdminService getInstance() {
    if (instance != null) {
      return instance;
    } else {
      instance = AdminService();
    }
    return instance;
  }

  // 获取个人信息
  Future<Response> getMe({int accountId}) async {
    try {
      Response response = await http.get(API_GET_ME);
      return response;
    } on DioError catch (e) {
      return error(e, API_REGISTER);
    }
  }

  // 更新登录状态
  Future<Response> updateUserOnlineStatus({int status}) async {
    try {
      Response response = await http.put(API_UPDATE_ONLINE_STATUS + status.toString());
      return response;
    } on DioError catch (e) {
      return error(e, API_REGISTER);
    }
  }


}
