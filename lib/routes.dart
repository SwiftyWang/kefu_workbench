import 'core_flutter.dart';
import 'provider/global.dart';
import 'views/auth/index.dart';
import 'views/chat/index.dart';
import 'views/edit_password/index.dart';
import 'views/edit_profile/index.dart';
import 'views/edit_user/index.dart';
import 'views/home/index.dart';
import 'views/knowledge/index.dart';
import 'views/knowledge_detail/index.dart';
import 'views/knowledge_edit/index.dart';

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
      case "/edit_password":
        return EditPasswordPage(arguments: arguments);
      case "/knowledge_detail":
        return KnowledgeDetailPage(arguments: arguments);
      case "/knowledge_add":
      case "/knowledge_edit":
        return KnowledgeEditPage(arguments: arguments);
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
