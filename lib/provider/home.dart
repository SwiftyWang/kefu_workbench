import 'package:dio/dio.dart';
import 'package:kefu_workbench/provider/global.dart';

import '../core_flutter.dart';

class HomeProvide with ChangeNotifier {

  /// 是否显示loading
  bool isFullLoading = false;

  /// 聊天列表数据
  List<ConcatModel> concats = [];

  ///  所有未读消息
  int get concatReadCount{
    int count = 0;
    for(var i =0; i<concats.length; i++){
      count = count + concats[i].read;
    }
    return count;
  }

  /// 刷新
  Future<bool> onRefresh(BuildContext context) async{
    await getConcats(context);
    UX.showToast("刷新成功~", position: ToastPosition.top);
    return true;
  }

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
      Navigator.pushNamedAndRemoveUntil(context, "/login", ModalRoute.withName('/'), arguments: {"isAnimate": false});
      UX.showToast("已成功退出登录~");
      GlobalProvide.getInstance().applicationLogout();
    });
  }

  /// 获取聊天列表
  Future<void> getConcats(BuildContext context, {bool isFullLoading = false}) async{
     setFullLoading(isFullLoading);
     Response response = await imService.getConcats();
     if(response.statusCode == 200){
      concats = (response.data['data'] as List).map((i) => ConcatModel.fromJson(i)).toList();
    }else{
      UX.showToast(response.data["message"]);
    }
     setFullLoading(false);
  }

  
}
