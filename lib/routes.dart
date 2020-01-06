import 'core_flutter.dart';
import 'provider/global.dart';
import 'views/auth/index.dart';
import 'views/chat/index.dart';
import 'views/home/index.dart';

class Routers {
  static Widget buildPage(String path, {Object arguments}) {

    bool isLogin = GlobalProvide.getInstance().checkIsForAuthorization();

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
      default:
        return Scaffold(
          body: Center(
            child: Text("not fund page"),
          ),
        );
    }
  }
}
