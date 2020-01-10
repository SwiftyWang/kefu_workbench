import 'package:kefu_workbench/provider/global.dart';

import '../core_flutter.dart';

class ChatProvide with ChangeNotifier {

  /// 是否显示loading
  bool get isChatFullLoading => GlobalProvide.getInstance().isChatFullLoading;




  
}
