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





}
