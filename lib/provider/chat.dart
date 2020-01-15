import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mimc/flutter_mimc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kefu_workbench/provider/global.dart';

import '../core_flutter.dart';

class ChatProvide with ChangeNotifier {

  static ChatProvide instance;

  StreamSubscription _listener;

  // 单例
  static ChatProvide getInstance() {
    if (instance != null) {
      return instance;
    }
    instance = ChatProvide();
    return instance;
  }

  ChatProvide(){
    focusNode = FocusNode();
    focusNode.addListener((){
      if(focusNode.hasFocus){
        onHideEmoJiPanel();
        onToggleShortcutPanel(false);
        toScrollEnd();
      }
    });
    GlobalProvide globalProvide =GlobalProvide.getInstance();
    globalProvide.chatProvideIsDispose = false;
    if(globalProvide.shortcuts.length == 0){
      globalProvide.getShortcuts();
    }
    scrollController = ScrollController();
    scrollController.addListener(() => _onScrollViewControllerAddListener());
    _listener = globalProvide.flutterMImc.addEventListenerHandleMessage().listen((MIMCMessage msg) async{
      ImMessageModel message = ImMessageModel.fromJson(json.decode(utf8.decode(base64Decode(msg.payload))));
      if(!["pong", "contacts", "cancel"].contains(message.bizType)){
        toScrollEnd();
      }
    });
  } 

   // 监听滚动条
  void _onScrollViewControllerAddListener() async {
    try {
      GlobalProvide globalState = GlobalProvide.getInstance();
      ScrollPosition position = scrollController?.position;
      // 判断是否到底部
      if (position.pixels + 15.0 > position.maxScrollExtent &&
          !globalState.isLoadRecordEnd &&
          !globalState.isLoadingMorRecord) {
        globalState.setIsLoadingMorRecord(true);
        await Future.delayed(Duration(milliseconds: 1000));
        await globalState.getMessageRecord();
        globalState.setIsLoadingMorRecord(false);
      }
    } catch (e) {
      debugPrint(e);
    }
  }

   /// 选中客服
  void onSelectedSeviceUser(ServiceUserModel user){
    GlobalProvide globalState = GlobalProvide.getInstance();
     UX.alert(globalState.rooContext,
      content: "将该客户转接给 " + (user.nickname ?? user.username)+' ?',
      confirmText: "转接",
      cancelText: "取消",
      onConfirm: () async{
       Response response = await   globalState.messageService.transformerUser(userAccount: globalState.currentContact.fromAccount, toAccount: user.id);
        if (response.data["code"] == 200) {
          onToggleTransferPanel(false);
          UX.showToast("转接成功");
          globalState.getContacts();
        } else {
          UX.showToast(response.data['message']);
        }
      }
    );
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

  /// 是否显示转接面板
  bool isShowTransferPanel = false;

  /// 可转接的客服
  List<ServiceUserModel> get serviceOnlineUsers{
    GlobalProvide globalState = GlobalProvide.getInstance();
    return globalState.serviceOnlineUsers.where((user) => user.id != globalState.serviceUser.id && user.online != 0).toList();
  }

  /// 输入键盘相关
  FocusNode focusNode;
  TextEditingController editingController = TextEditingController();

  /// 滚动条控制器
  ScrollController scrollController;

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
    toScrollEnd();
  }

  /// 输入框改动
  void onInputChanged(String value){
     GlobalProvide globalState = GlobalProvide.getInstance();
     globalState.sendPongMessage("");
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
    toScrollEnd();
  }

  /// 显示或隐藏转接面板
  void onToggleTransferPanel(bool isShow) async{
    GlobalProvide globalState = GlobalProvide.getInstance();
    if(globalState.currentContact == null || globalState.currentContact.isSessionEnd == 1){
      if(isShow)UX.showToast("当前会话已结束！");
      return;
    }
    if(isShow){
      onHideEmoJiPanel();
      onToggleShortcutPanel(false);
      globalState.getOnlineAdmins();
      FocusScope.of(globalState.rooContext).requestFocus(FocusNode());
      await Future.delayed(Duration(milliseconds: 50));
    }
    isShowTransferPanel = isShow;
    notifyListeners();
  }

   /// 滚动条至底部
  void toScrollEnd() async {
    scrollController?.jumpTo(0);
  }

   /// 显示或隐藏快捷语
  void onToggleShortcutPanel(bool isShow) async{
    GlobalProvide globalState = GlobalProvide.getInstance();
    if(globalState.currentContact == null || globalState.currentContact.isSessionEnd == 1) {
      if(isShow)UX.showToast("当前会话已结束！");
      return;
    }
    if(isShow){
      onHideEmoJiPanel();
      onToggleTransferPanel(false);
      FocusScope.of(globalState.rooContext).requestFocus(FocusNode());
      await Future.delayed(Duration(milliseconds: 50));
    }
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


  /// 操作消息
  void onOperation(BuildContext context, ImMessageModel message){
    GlobalProvide globalState = GlobalProvide.getInstance();
    bool isLocalImage = message.payload != null && !message.payload.contains(RegExp(r'^(http://|https://)'));
    bool isPhoto = message.bizType == "photo";
    Widget _delete() {
      return CupertinoDialogAction(
        child: const Text('删除'),
        onPressed: () {
          if(message.fromAccount != globalState.serviceUser.id && message.fromAccount != globalState.robot.id){
            globalState.deleteMessage(message.fromAccount, message.key);
          }else{
            globalState.deleteMessage(message.toAccount, message.key);
          }
          globalState.messageService.removeMeessge(
            toAccount: message.toAccount,
            fromAccount: message.fromAccount,
            key: message.key,
          );
          Navigator.pop(context);
        },
      );
    }

    Widget _cancel() {
      return CupertinoDialogAction(
        child: const Text('撤回'),
        onPressed: () {
          onCancelMessage(message);
          Navigator.pop(context);
        },
      );
    }

    Widget _close() {
      return CupertinoDialogAction(
        child: const Text('取消'),
        isDestructiveAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }

    Widget _copy() {
      return CupertinoDialogAction(
        child: Text(isPhoto ? "复制图片链接" : '复制'),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: message.payload));
          Navigator.pop(context);
          UX.showToast("消息已复制到粘贴板");
        },
      );
    }

    List<Widget> actions = [];
    if (message.isShowCancel) actions.add(_cancel());
    actions.add(_delete());
    if (message.bizType == "text") actions.add(_copy());
    if (isPhoto && !isLocalImage) {
      actions.add(_copy());
    }
    actions.add(_close());

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
              title: Text(
                '消息操作',
                style: TextStyle(
                    color: Colors.black.withAlpha(150), fontSize: ToPx.size(32)),
              ),
              content: isPhoto
                  ? SizedBox(
                      width: ToPx.size(200),
                      height: ToPx.size(200),
                      child: CachedNetworkImage(
                          width: ToPx.size(200),
                          height: ToPx.size(200),
                          bgColor: Colors.transparent,
                          fit: BoxFit.contain,
                          src: "${message.payload}"),
                    )
                  : Text(
                      message.bizType == "knowledge" ? "相关问题列表..." : message.payload,
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(height: 1.5, color: Colors.black87),
                    ),
              actions: actions);
        });

  }


  /// 隐藏表情背面板
  void onHideEmoJiPanel(){
    isShowEmoJiPanel = false;
    notifyListeners();
  }

  /// 显示表情背面板
  void onShowEmoJiPanel() async{
    onToggleTransferPanel(false);
    GlobalProvide globalState = GlobalProvide.getInstance();
    if(globalState.currentContact == null || globalState.currentContact.isSessionEnd == 1){
      UX.showToast("当前会话已结束！");
      return;
    }
    isShowShortcutPanel = false;
    notifyListeners();
    FocusScope.of(GlobalProvide.getInstance().rooContext).requestFocus(FocusNode());
    await Future.delayed(Duration(milliseconds: 50));
    isShowEmoJiPanel = true;
    notifyListeners();
  }

  @override
  void dispose() {
    GlobalProvide globalProvide =GlobalProvide.getInstance();
    globalProvide.chatProvideIsDispose = true;
    focusNode?.dispose();
    editingController?.dispose();
    scrollController?.dispose();
    _listener?.cancel();
    instance = null;
    printf("销毁了GlobalProvide");
    super.dispose();
  }

  
}
