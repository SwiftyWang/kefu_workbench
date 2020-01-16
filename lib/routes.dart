import 'core_flutter.dart';
import 'provider/global.dart';
import 'views/auth/index.dart';
import 'views/chat/index.dart';
import 'views/edit_profile/index.dart';
import 'views/edit_user/index.dart';
import 'views/home/index.dart';
import 'views/knowledge/index.dart';

class Routers {
  static Widget buildPage(String path, {Object arguments}) {

    bool isLogin = GlobalProvide.getInstance().isLogin;

    if(!isLogin) return LoginPage(arguments: arguments);

    switch (path) {
      case "/login":
        return LoginPage(arguments: arguments);
        break;
      case "/home":
        return HomePage(arguments: arguments);
        break;
      case "/chat":
        return ChatPage(arguments: arguments);
        break;
      case "/edit_user":
        return EditUserPage(arguments: arguments);
      case "/knowledge":
        return KnowledgePage(arguments: arguments);
      case "/edit_profile":
        return EditProfilePage(arguments: arguments);
        break;
      default:
        return Scaffold(
          body: Center(
            child: Text("not fund page"),
          ),
        );
    }
  }
}
