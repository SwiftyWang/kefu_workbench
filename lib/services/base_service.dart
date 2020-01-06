import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../configs.dart';
import '../core_flutter.dart';

class BaseServices{

  // dio 实例
  Dio get http => getDioInstance();


  // 去除空字段
  Map<String, dynamic> removeNull(Map<String, dynamic> json){
    json.removeWhere((key, value) => value == null);
    return json;
  }

  // 全局服务器错误返回信息
  Response error(DioError e, String url){
    printf("$url =====服务器错误返回信息=====$e====${e.response}");
    var errStr = '';
    var code = -9999;
    switch(e.type){
      case DioErrorType.CONNECT_TIMEOUT:
        errStr = '1000M光纤也没用，请求超时了，请稍后再试！';
        code = -6666;
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        errStr = '哎呀，数据接收超时了，请再试一次看看！！';
        code = -3333;
        break;
      case DioErrorType.RESPONSE:
        errStr = '哎呀，前方拥堵，请稍后再试！';
        code = -2222;
        break;
      case DioErrorType.CANCEL:
        errStr = '请求被取消！';
        code = -1111;
        break;
      default:
        errStr = '啊哦，办理业务的人太多了，请稍后再试！';
        code = -188264;
    }
    if(e.message.contains('401')){
      return Response(data: {"code": 401, "msg": '您还没有登录！', "data": null});
    }
    return Response(data: {"code": code, "msg": errStr, "data": null});
  }

  Dio getDioInstance(){
     final dio = Dio();
     dio.options.baseUrl = Configs.HOST;
     dio.options.connectTimeout = 60000;
     dio.options.receiveTimeout = 60000;
     dio.options.headers = {

      };
     dio.interceptors.add(InterceptorsWrapper(
      onRequest:(RequestOptions options) async{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final String authorization = prefs.getString('Authorization');
        printf('调用了API=${options.uri}');
        printf('request body=${options.data}');
        printf('Authorization=$authorization');
        if(authorization != null){
          options.headers = {
            "Authorization": authorization
          };
        }
        // 判断网络是否可用
        if(!await checkNetWork()){
          return dio.resolve(Response(data: {"code": 503, "msg": '您的网络异常，请检查您的网络！', "data": null}));
        }
        return options;
      },
      onResponse:(Response response) async{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // 如果有authorization 换掉本地的
        if(response.headers['authorization'] != null){
          prefs.setString('Authorization', response.headers['authorization'][0]);
        }
        return response; // continue
      },
      onError: (DioError e) {
        return e;
      }
  ));
    return dio;
  }
}
