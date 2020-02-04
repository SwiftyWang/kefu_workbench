import 'package:dio/dio.dart';

import 'api.dart';
import 'base_service.dart';

class ShortcutService extends BaseServices {
  static ShortcutService instance;
  static ShortcutService getInstance() {
    if (instance != null) {
      return instance;
    } else {
      instance = ShortcutService();
    }
    return instance;
  }

  // 获取快捷语列表
  Future<Response> getShortcuts() async {
    try {
      Response response = await http.get(API_GET_SHORTCUT);
      return response;
    } on DioError catch (e) {
      return error(e, API_GET_SHORTCUT);
    }
  }


  // 添加
  Future<Response> add() async {
    try {
      Response response = await http.get(API_GET_SHORTCUT);
      return response;
    } on DioError catch (e) {
      return error(e, API_GET_SHORTCUT);
    }
  }
  

  // 修改
  Future<Response> update() async {
    try {
      Response response = await http.get(API_GET_SHORTCUT);
      return response;
    } on DioError catch (e) {
      return error(e, API_GET_SHORTCUT);
    }
  }

  // 删除
  Future<Response> delete() async {
    try {
      Response response = await http.get(API_GET_SHORTCUT);
      return response;
    } on DioError catch (e) {
      return error(e, API_GET_SHORTCUT);
    }
  }
  


  
}
