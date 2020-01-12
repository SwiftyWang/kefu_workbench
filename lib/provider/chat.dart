import 'package:image_picker/image_picker.dart';
import 'package:kefu_workbench/provider/global.dart';

import '../core_flutter.dart';

class ChatProvide with ChangeNotifier {

    /// 是否显示表情面板
  bool isShowEmoJiPanel = false;

  /// 输入键盘相关
  FocusNode focusNode = FocusNode();
  TextEditingController editingController = TextEditingController();

  /// 滚动条控制器
  ScrollController scrollController = ScrollController();

  /// 是否显示loading
  bool get isChatFullLoading => GlobalProvide.getInstance().isChatFullLoading;

  /// 发送消息
  void onSubmit(){

  }

  /// 输入框改动
  void onInputChanged(String value){

  }

  
  /// 选择图片
  void onPickImage(ImageSource imageSource){

  }
  


  /// 隐藏表情背面板
  onHideEmoJiPanel(){
    isShowEmoJiPanel = false;
    notifyListeners();
  }

  @override
  void dispose() {
    focusNode?.dispose();
    editingController?.dispose();
    scrollController?.dispose();
    super.dispose();
  }

  
}
