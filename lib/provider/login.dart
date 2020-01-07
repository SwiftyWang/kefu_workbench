import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kefu_workbench/provider/global.dart';

import '../core_flutter.dart';

class LoginProvide with ChangeNotifier {
  AuthService authService = AuthService.getInstance();
  TextEditingController accountCtr;

  TextEditingController passwordCtr;

  bool isSavePassword = false;

  void setIsSavePassword(bool isSave) {
    isSavePassword = isSave;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    String account = accountCtr.value.text.trim();
    String password = passwordCtr.value.text.trim();
    GlobalProvide.getInstance().prefs.setString("account", account);
    if (isSavePassword) {
      GlobalProvide.getInstance().prefs.setString("password", password);
    } else {
      GlobalProvide.getInstance().prefs.remove("password");
    }
    if(account.isEmpty){
      UX.showToast("请输入用户名~");
    }
    if(password.isEmpty){
      UX.showToast("请输入密码~");
    }
    Response response = await authService.login(username: account, password: password);
    if(response.statusCode == 200){
      printf(response.data['data']);
      ServiceUserModel user = ServiceUserModel.fromJson(response.data['data']);
      GlobalProvide.getInstance().setServiceUser(user);
      GlobalProvide.getInstance().prefs.setString("serviceUser", json.encode(response.data['data']));
      GlobalProvide.getInstance().prefs.setString("Authorization", user.token);
      UX.showToast("登录成功~");
      GlobalProvide.getInstance().init();
      Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/'));
    }else{
      UX.showToast(response.data["message"], position: ToastPosition.top);
    }
  }

  @override
  void dispose() {
    accountCtr?.dispose();
    passwordCtr?.dispose();
    super.dispose();
  }
}
