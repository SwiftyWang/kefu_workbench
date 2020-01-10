import 'package:dio/dio.dart';

import 'api.dart';
import 'base_service.dart';

class ImService extends BaseServices {
  static ImService instance;
  static ImService getInstance() {
    if (instance != null) {
      return instance;
    } else {
      instance = ImService();
    }
    return instance;
  }

  // 注册IM
  Future<Response> registerImAccount({int accountId}) async {
    try {
      Response response = await http
          .post(API_REGISTER, data: {"type": 1, "account_id": accountId});
      return response;
    } on DioError catch (e) {
      return error(e, API_REGISTER);
    }
  }

  // 获取服务器消息列表
  Future<Response> getMessageRecord(
      {int timestamp, int pageSize = 15, int account}) async {
    try {
      Response response = await http.post(API_GET_MESSAGE, data: {
        "timestamp": timestamp,
        "page_size": pageSize,
        "account": account
      });
      return response;
    } on DioError catch (e) {
      return error(e, API_GET_MESSAGE);
    }
  }

  // 获取聊天列表
  Future<Response> getContacts() async {
    try {
      Response response = await http.get(API_CONTACTS);
      return response;
    } on DioError catch (e) {
      return error(e, API_CONTACTS);
    }
  }
}
