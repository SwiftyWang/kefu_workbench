import 'package:kefu_workbench/provider/global.dart';

import '../core_flutter.dart';

class LoginProvide with ChangeNotifier {

  TextEditingController accountCtr;

  TextEditingController paswordCtr;

  bool isSavePassword = false;

  void setIsSavePassword(bool isSave){
    isSavePassword = isSave;
    notifyListeners();
  }

  Future<void> login() async{
    String account = accountCtr.value.text.trim();
    String pasword = paswordCtr.value.text.trim();
    GlobalProvide.getInstance().prefs.setString("account", account);
    if(isSavePassword){
      GlobalProvide.getInstance().prefs.setString("pasword", pasword);
    }else{
      GlobalProvide.getInstance().prefs.remove("password");
    }
    printf("account==$account");
    printf("pasword==$pasword");
    printf("登录成功");

  }


  @override
  void dispose() {
    accountCtr?.dispose();
    paswordCtr?.dispose();
    super.dispose();
  }




}