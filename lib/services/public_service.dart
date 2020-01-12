import 'package:dio/dio.dart';

import 'api.dart';
import 'base_service.dart';

class PublicService extends BaseServices {
  static PublicService instance;
  static PublicService getInstance() {
    if (instance != null) {
      return instance;
    } else {
      instance = PublicService();
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

  // 获取上传配置信息
  Future<Response> getUploadSecret() async {
    try {
      Response response = await http.get(API_UPLOAD_SECRET);
      return response;
    } on DioError catch (e) {
      return error(e, API_UPLOAD_SECRET);
    }
  }

   // 获取一个在线机器人
  Future<Response> getOnlineRobot() async {
    try {
      Response response = await http.get(API_GET_ROBOT);
      return response;
    } on DioError catch (e) {
      return error(e, API_GET_ROBOT);
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





}
