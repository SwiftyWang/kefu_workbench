import 'package:dio/dio.dart';

import 'api.dart';
import 'base_service.dart';

class KnowledgeService extends BaseServices {
  static KnowledgeService instance;
  static KnowledgeService getInstance() {
    if (instance != null) {
      return instance;
    } else {
      instance = KnowledgeService();
    }
    return instance;
  }

  // 获取数据
  Future<Response> getList({int pageOn = 1, int pageSize = 20}) async {
    try {
      Response response = await http.post(API_GET_KNOWLEDGE, data: {"page_on": pageOn, "page_size": pageSize});
      return response;
    } on DioError catch (e) {
      return error(e, API_GET_KNOWLEDGE);
    }
  }



}
