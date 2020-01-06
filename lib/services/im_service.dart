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

  // 一分钟上报一次我的活动
  Future<Response> upImLastActivity() async {
    try {
      Response response = await http.get(API_RUN_LAST_ACTiIVITY);
      return response;
    } on DioError catch (e) {
      return error(e, API_RUN_LAST_ACTiIVITY);
    }
  }

  // 获取上传配置信息
  Future<Response> getUploadSecret() async {
    try {
      Response response = await http.get(API_UPLOAD_SECRET);
      return response;
    } on DioError catch (e) {
      return error(e, API_UPLOAD_SECRET);
    }
  }




}
