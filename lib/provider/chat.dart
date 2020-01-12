import 'package:image_picker/image_picker.dart';
import 'package:kefu_workbench/provider/global.dart';

import '../core_flutter.dart';

class ChatProvide with ChangeNotifier {

  ChatProvide(){
    focusNode = FocusNode();
    focusNode.addListener((){
      if(focusNode.hasFocus){
        onHideEmoJiPanel();
        onToggleShortcutPanel(false);
      }
    });
    GlobalProvide globalProvide =GlobalProvide.getInstance();
    if(globalProvide.shortcuts.length == 0){
      globalProvide.getShortcuts();
    }
  }

  /// 选中快捷语
  void onSelectedShortcut(String shortcut){
    editingController.text = shortcut;
    editingController.selection = TextSelection.collapsed(offset: shortcut.length);
  }

  /// 是否显示表情面板
  bool isShowEmoJiPanel = false;

  /// 是否显示快捷语面板
  bool isShowShortcutPanel = false;

  /// 输入键盘相关
  FocusNode focusNode;
  TextEditingController editingController = TextEditingController();

  /// 滚动条控制器
  ScrollController scrollController = ScrollController();

  /// 是否显示loading
  bool get isChatFullLoading => GlobalProvide.getInstance().isChatFullLoading;

  /// 发送消息
  void onSubmit(){
    GlobalProvide globalState = GlobalProvide.getInstance();
    var text = editingController.value.text.trim();
    if(text.isEmpty) return;
    if(globalState.currentContact == null || globalState.currentContact.isSessionEnd == 1){
      UX.showToast("当前会话已结束！");
      return;
    }
    if(isShowShortcutPanel){
      isShowShortcutPanel = false;
    }
    GlobalProvide.getInstance().sendTextMessage(text);
    editingController.clear();
    notifyListeners();
  }

  /// 输入框改动
  void onInputChanged(String value){

  }

  
  /// 选择图片
  void onPickImage(ImageSource imageSource) async{
    GlobalProvide globalState = GlobalProvide.getInstance();
    if(globalState.currentContact == null || globalState.currentContact.isSessionEnd == 1){
      UX.showToast("当前会话已结束！");
      return;
    }
    if(imageSource == ImageSource.camera && !await checkPermission(globalState.rooContext, permissionGroupType: PermissionGroup.camera)){
      UX.showToast("未授权使用相机！");
      return;
    }
    if(imageSource == ImageSource.gallery && !await checkPermission(globalState.rooContext, permissionGroupType: PermissionGroup.photos)){
      UX.showToast("未授权使用相册！");
      return;
    }
    File _file = await ImagePicker.pickImage(source: imageSource, maxWidth: 2000);
    if (_file == null) return;
    globalState.sendPhotoMessage(_file);
  }

  /// 显示或隐藏转接面板
  void onToggleTransferPanel(){

  }

   /// 显示或隐藏快捷语
  void onToggleShortcutPanel(bool isShow) async{
    GlobalProvide globalState = GlobalProvide.getInstance();
    if(globalState.currentContact == null || globalState.currentContact.isSessionEnd == 1) {
      if(isShow)UX.showToast("当前会话已结束！");
      return;
    }
    if(isShow){
      FocusScope.of(GlobalProvide.getInstance().rooContext).requestFocus(FocusNode());
      await Future.delayed(Duration(milliseconds: 100));
    }
    onHideEmoJiPanel();
    isShowShortcutPanel = isShow;
    notifyListeners();
  }

  /// 撤会消息
  void onCancelMessage(ImMessageModel msg){
    GlobalProvide globalState = GlobalProvide.getInstance();
    globalState.sendCancelMessage(msg);
    globalState.deleteMessage(msg.toAccount, msg.key);
  } 

  /// 结束会话
  void onShowEndMessageAlert(BuildContext context){
     GlobalProvide globalState = GlobalProvide.getInstance();
    UX.alert(context,
      content: "您确定结束当前会话吗?\r\n强制结束可能会被客户投诉！",
      confirmText: "结束",
      cancelText: "取消",
      onConfirm: () => globalState.sendEndMessage()
    );
  }


  /// 隐藏表情背面板
  void onHideEmoJiPanel(){
    isShowEmoJiPanel = false;
    notifyListeners();
  }

  /// 显示表情背面板
  void onShowEmoJiPanel() async{
    GlobalProvide globalState = GlobalProvide.getInstance();
    if(globalState.currentContact == null || globalState.currentContact.isSessionEnd == 1){
      UX.showToast("当前会话已结束！");
      return;
    }
    isShowShortcutPanel = false;
    notifyListeners();
    FocusScope.of(GlobalProvide.getInstance().rooContext).requestFocus(FocusNode());
    await Future.delayed(Duration(milliseconds: 100));
    isShowEmoJiPanel = true;
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
