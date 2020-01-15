import 'package:dio/dio.dart';

import 'api.dart';
import 'base_service.dart';

class UserService extends BaseServices {
  static UserService instance;
  static UserService getInstance() {
    if (instance != null) {
      return instance;
    } else {
      instance = UserService();
    }
    return instance;
  }


  // 保存用户信息
  Future<Response> save(Map data) async {
    try {
      Response response = await http.put(API_USER, data: data);
      return response;
    } on DioError catch (e) {
      return error(e, API_USER);
    }
  }

  
}
