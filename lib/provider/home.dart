import 'package:dio/dio.dart';
import 'package:kefu_workbench/provider/global.dart';

import '../core_flutter.dart';

class HomeProvide with ChangeNotifier {

  /// 是否显示loading
  bool isFullLoading = false;

  /// 设置是否显示loading
  void setFullLoading(bool isShow){
    isFullLoading = isShow;
    notifyListeners();
  }

   /// ImService
  ImService imService = ImService.getInstance();

  /// 退出登录
  void logout(BuildContext context) {
    UX.alert(context, content: "您确定退出登录吗？", onConfirm: () {
      GlobalProvide.getInstance().applicationLogout();
      Navigator.popAndPushNamed(context, "/login", arguments: {"modal": true});
      UX.showToast("已成功退出登录~");
    });
  }

  /// 获取聊天列表
  void getConcats(BuildContext context, {bool isFullLoading = false}) async{
     setFullLoading(isFullLoading);
     Response response = await imService.getConcats();
     if(response.statusCode == 200){
      printf(response.data['data']);
    }else{
      UX.showToast(response.data["message"]);
    }
     setFullLoading(false);
  }

  
}
