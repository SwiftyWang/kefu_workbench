import 'package:dio/dio.dart';

import 'api.dart';
import 'base_service.dart';

class MessageService extends BaseServices {
  static MessageService instance;
  static MessageService getInstance() {
    if (instance != null) {
      return instance;
    } else {
      instance = MessageService();
    }
    return instance;
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
  


  
}
