import 'package:dio/dio.dart';

import 'api.dart';
import 'base_service.dart';

class PlatformService extends BaseServices {
  static PlatformService instance;
  static PlatformService getInstance() {
    if (instance != null) {
      return instance;
    } else {
      instance = PlatformService();
    }
    return instance;
  }


  // 获取平台列表
  Future<Response> getPlatforms() async {
    try {
      Response response = await http.get(API_GET_PLATFORM);
      return response;
    } on DioError catch (e) {
      return error(e, API_GET_PLATFORM);
    }
  }

  
}
