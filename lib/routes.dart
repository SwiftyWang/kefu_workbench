import 'core_flutter.dart';
import 'views/chat/index.dart';
import 'views/home/index.dart';

class Routers {
  static Widget buildPage(String path, {Object arguments}) {
    switch (path) {
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
