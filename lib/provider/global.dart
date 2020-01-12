
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_mimc/flutter_mimc.dart';
import 'package:kefu_workbench/services/api.dart';

import '../core_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 创建消息辅助对象
///  [sendMessage] 发送对象
///  [imMessage]  本地显示对象
class MessageHandle {
  MessageHandle({this.sendMessage, this.localMessage});
  MIMCMessage sendMessage;
  ImMessageModel localMessage;
  MessageHandle clone() {
    return MessageHandle(
      sendMessage: MIMCMessage.fromJson(sendMessage.toJson()),
      localMessage: ImMessageModel.fromJson(localMessage.toJson()),
    );
  }
}

/// GlobalProvide
class GlobalProvide with ChangeNotifier {

  /// root context
  BuildContext rooContext;

  /// 当前主题
  ThemeProvide get themeProvide =>  ThemeProvide.getInstance();
  ThemeData get getCurrentTheme => themeProvide.getCurrentTheme();
  
  /// MessageService
  MessageService messageService = MessageService.getInstance();

  /// AdminService
  AdminService adminService = AdminService.getInstance();

  /// PublicService
  PublicService publicService = PublicService.getInstance();

  /// ContactService
  ContactService contactService = ContactService.getInstance();

  /// ShortcutService
  ShortcutService shortcutService = ShortcutService.getInstance();

  /// GlobalProvide实例
  static GlobalProvide instance;

  /// 聊天列表数据
  List<ContactModel> contacts = [];

  /// 快捷语
  List<ShortcutModel> shortcuts = [];

  /// 客服信息
  ServiceUserModel serviceUser;

  /// 当前服务谁
  ContactModel currentContact;

  /// IM 签名对象
  ImTokenInfoModel imTokenInfo;

  /// 缓存对象
  SharedPreferences prefs;

  /// 机器人对象
  RobotModel robot;

  /// 上传配置对象
  UploadSecretModel uploadSecret;

  /// IM 插件对象
  FlutterMIMC flutterMImc;

  /// 聊天记录
  Map<dynamic, List<ImMessageModel>> messagesRecords = {};

  /// 当前聊天用户的消息记录
  List<ImMessageModel> get currentUserMessagesRecords{
    return messagesRecords[currentContact.fromAccount] ?? [];
  }

  /// 是否显示loading
  bool isChatFullLoading = false;

  /// 显示对方输入中...
  bool isPong = false;
  String advanceText = "";

  /// 当前用户ID
  int toAccount;

  /// set rooContext
  void setRooContext(BuildContext context){
    rooContext = context;
  }

  // 单列 获取对象
  static GlobalProvide getInstance() {
    if (instance == null) {
      instance = GlobalProvide();
    }
    return instance;
  }

  /// 初始化
  /// return bool
  Future<void> init() async {
    await _prefsInstance();
    await _getUploadSecret();
    await _getOnlineRobot();
    if(isLogin){
      await _registerImAccount();
      await _flutterMImcInstance();
      await _addMimcEvent();
      await _getMe();
      await getContacts();
      await _upImLastActivity();
      await getShortcuts();
    }
  }

  /// is login
  bool get isLogin{
    String authorization = prefs.getString("Authorization");
    String serviceUserString = prefs.getString("serviceUser");
    if(serviceUserString != null){
      serviceUser = ServiceUserModel.fromJson(json.decode(serviceUserString));
    }
    if(authorization != null && serviceUser != null){
      return true;
    }else{
      printf("未登录~");
      return false;
    }
  }

  /// APP应用级别退出登录
  /// 重置一些默认初始化
  void applicationLogout() async{
    await AuthService.getInstance().logout();
    prefs.remove("serviceUser");
    prefs.remove("Authorization");
    setServiceUser(null);
    flutterMImc?.logout();
  }

  /// 获取个人信息
  Future<void> _getMe() async {
     Response response = await adminService.getMe();
      if (response.data["code"] == 200) {
        serviceUser = ServiceUserModel.fromJson(response.data['data']);
        setServiceUser(serviceUser);
        if(serviceUser.online != 0){
          flutterMImc?.login();
        }
      } else {
        UX.showToast(response.data['message']);
      }
  }

  /// 获取快捷语
  Future<void> getShortcuts() async {
     Response response = await shortcutService.getShortcuts();
      if (response.data["code"] == 200) {
        shortcuts = (response.data['data'] as List).map((i) => ShortcutModel.fromJson(i)).toList();
        notifyListeners();
      } else {
        UX.showToast(response.data['message']);
      }
  }

  /// 设置serviceUser
  void setServiceUser(ServiceUserModel user){
    serviceUser = user;
    notifyListeners();
    if(user == null) return;
    prefs.setString("serviceUser", jsonEncode(user.toJson()));
  }

  /// 实例化 FlutterMImc
  Future<void> _flutterMImcInstance() async {
    if(flutterMImc != null) return;
    try{
      String tokenString = '{"code": 200, "message": "success", "data": ${jsonEncode(imTokenInfo?.toJson())}}';
      flutterMImc = FlutterMIMC.stringTokenInit(tokenString, debug: true);
    } catch(_) {
      Navigator.pushNamedAndRemoveUntil(rooContext, "/login", ModalRoute.withName('/'), arguments: {"isAnimate": false});
    }
  }

  /// 注册IM账号
  Future<void> _registerImAccount() async {
    try {
      Response response = await publicService.registerImAccount(accountId: serviceUser.id);
      if (response.data["code"] == 200) {
        imTokenInfo =ImTokenInfoModel.fromJson(response.data["data"]["token"]["data"]);
      } else {
        // 1秒重
        await Future.delayed(Duration(milliseconds: 1000));
        _registerImAccount();
      }
    } catch (e) {
      debugPrint(e);
    }
  }

  /// 获取一个在线机器人
  Future<void> _getOnlineRobot() async {
    try {
      Response response = await publicService.getOnlineRobot();
      if (response.data["code"] == 200) {
        robot = RobotModel.fromJson(response.data["data"]);
      } else {
        // 1秒重
        await Future.delayed(Duration(milliseconds: 1000));
        _registerImAccount();
      }
    } catch (e) {
      debugPrint(e);
    }
  }

  /// 实例化 SharedPreferences
  Future<void> _prefsInstance() async {
    if(prefs != null) return;
    prefs = await SharedPreferences.getInstance();
  }

  /// 设置当前服务谁
  setCurrentContact(ContactModel contact){
    currentContact = contact;
    toAccount = currentContact.fromAccount;
    Navigator.pushNamed(rooContext, "/chat", arguments: {}).then((_){
     getContacts();
    });
    notifyListeners();
    GlobalProvide.getInstance().getMessageRecord(isFirstLoad: true);
    getContacts();
  }

  /// 更新客服上线状态
  Future<void> updateUserOnlineStatus({int online}) async{
    Response response = await adminService.updateUserOnlineStatus(status: online);
    if (response.data["code"] == 200) {
      _getMe();
      if(online == 0){
        UX.showToast("当前状态为离线");
        flutterMImc.logout();
      }else if(online == 1){
        UX.showToast("当前状态为在线");
        flutterMImc.login();
      }else{
        UX.showToast("当前状态为离开");
        if(!await flutterMImc.isOnline()) flutterMImc.login();
      }
    } else {
      UX.showToast("${response.data["message"]}");
    }
  }

  /// 设置上下线
  void setOnline({int online}){
    if(serviceUser.online == online) return;
    UX.alert(rooContext,
     content: "您确定" + (online == 0 ? "下线" : online == 1 ? "上线": "设置繁忙") +"吗！",
     onConfirm: (){
       updateUserOnlineStatus(online: online);
    });
  }

  /// 获取服务器消息列表
  Future<void> getMessageRecord({int timestamp, int pageSize = 20, int account, bool isFirstLoad = false}) async {
    try {
      if(currentContact == null) return;
      int timer = timestamp ?? DateTime.now().millisecondsSinceEpoch;
      if(isFirstLoad && currentUserMessagesRecords.length <= 0){
        isChatFullLoading = true;
        notifyListeners();
      }
      if(currentUserMessagesRecords.length > 0 && !isFirstLoad){
        timer = currentUserMessagesRecords[0].timestamp;
      }
      Response response = await messageService.getMessageRecord(timestamp: timer, pageSize: pageSize, account: account ?? currentContact.fromAccount);
      isChatFullLoading = false;
      notifyListeners();
      if (response.data["code"] == 200) {
        int total = response.data['data']['total'];
        if(isFirstLoad) messagesRecords[currentContact.fromAccount] = [];
        (response.data['data']['list'] as List).forEach((i){
          pushLocalMessage(ImMessageModel.fromJson(i), currentContact.fromAccount);
        });
      } else {
        UX.showToast("${response.data["message"]}");
      }

    } catch (e) {
      debugPrint(e);
    }
  }

  /// 上报IM最后活动时间
  Future<void> _upImLastActivity() async {
    Timer.periodic(Duration(milliseconds: 20000), (_timer) {
      printf("上报IM最后活动时间");
      if (serviceUser != null) publicService.upImLastActivity();
    });
  }

  /// 获取上传文件配置
  Future<void> _getUploadSecret() async {
    Response response = await publicService.getUploadSecret();
    if (response.data["code"] == 200) {
      uploadSecret = UploadSecretModel.fromJson(response.data["data"]);
    } else {
      await Future.delayed(Duration(milliseconds: 1000));
      _getUploadSecret();
    }
  }

  /// 创建消息
  /// [toAccount] 接收方账号
  /// [msgType]   消息类型
  /// [content]   消息内容
  MessageHandle createMessage(
      {int toAccount, String msgType, dynamic content}) {
    MIMCMessage message = MIMCMessage();
    String millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch.toString();
    int timestamp = int.parse(millisecondsSinceEpoch.substring(0, millisecondsSinceEpoch.length - 3));
    message.timestamp = timestamp;
    message.bizType = msgType;
    message.toAccount = toAccount.toString();
    message.fromAccount = serviceUser.id.toString();
    Map<String, dynamic> payloadMap = {
      "from_account": serviceUser.id,
      "to_account": toAccount,
      "biz_type": msgType,
      "version": "0",
      "key": DateTime.now().millisecondsSinceEpoch,
      "platform": Platform.isAndroid ? 6 : 2,
      "timestamp": timestamp,
      "read": 0,
      "transfer_account": 0,
      "payload": "$content"
    };
    printf(payloadMap);
    message.payload = base64Encode(utf8.encode(json.encode(payloadMap)));
    return MessageHandle(
        sendMessage: message,
        localMessage: ImMessageModel.fromJson(payloadMap)..isShowCancel = true);
  }

  /// 发送消息处理
  void sendMessage(MessageHandle msgHandle) async {
    //  发送失败提示
    if (!await flutterMImc.isOnline()) {
      MessageHandle tipsMsg = createMessage(toAccount: toAccount, msgType: "system", content: "您的网络异常，发送失败了~");
      pushLocalMessage(tipsMsg.localMessage, toAccount);
      return;
    }
    Timer.periodic(Duration(milliseconds: 150), (timer){
      flutterMImc.sendMessage(msgHandle.sendMessage);
      timer.cancel();
    });

    /// 消息入库（远程）
    MessageHandle cloneMsgHandle = msgHandle.clone();
    String type = cloneMsgHandle.localMessage.bizType;
    if (type == "contacts" ||
        type == "pong" ||
        type == "welcome" ||
        type == "handshake") return;
    cloneMsgHandle.sendMessage.toAccount = robot.id.toString();
    cloneMsgHandle.sendMessage.payload = ImMessageModel(
      bizType: "into",
      payload: cloneMsgHandle.localMessage.toBase64(),
    ).toBase64();
    flutterMImc.sendMessage(cloneMsgHandle.sendMessage);
    if (type != "photo") pushLocalMessage(cloneMsgHandle.localMessage, toAccount);
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 10000));
    cloneMsgHandle.localMessage.isShowCancel = false;
    notifyListeners();
  }

  // 更新某个消息
  void updateMessage(ImMessageModel msg) {
    int index = currentUserMessagesRecords.indexWhere((i) => i.key == msg.key);
    currentUserMessagesRecords[index] = msg;
    notifyListeners();
  }

  /// 获取工作台聊天列表
  Future<void> getContacts({bool isFullLoading = false}) async{
     Response response = await contactService.getContacts();
     if(response.statusCode == 200){
      contacts = (response.data['data'] as List).map((i){
        ContactModel contact = ContactModel.fromJson(i);
        if(currentContact != null && contact.fromAccount == currentContact.fromAccount){
          currentContact = contact;
        }
        return ContactModel.fromJson(i);
      }).toList();
      notifyListeners();
    }else{
      UX.showToast(response.data["message"]);
    }
  }

  /// 撤回消息
  void sendCancelMessage(ImMessageModel msg) {
    MessageHandle msgHandle = createMessage(toAccount: toAccount, msgType: "cancel", content: msg.key);
    sendMessage(msgHandle);
  }

  /// 结束会话
  void sendEndMessage() {
    if(currentContact == null || toAccount == null) return;
    MessageHandle msgHandle = createMessage(toAccount: toAccount, msgType: "end", content: "");
    sendMessage(msgHandle);
    currentContact.isSessionEnd = 1;
    notifyListeners();
  }

  /// 删除本地消息
  void deleteMessage(int account, int key){
    try{
      int index = messagesRecords[account].indexWhere((i) => i.key == key);
      messagesRecords[account].removeAt(index);
      notifyListeners();
    }catch(e){
      printf(e);
    }
  }

  // 处理头像昵称
  ImMessageModel _handlerMessage(ImMessageModel msg) {
    const String defaultAvatar = 'http://qiniu.cmp520.com/avatar_degault_3.png';
    msg.avatar = defaultAvatar;
    // 消息是我发的
    if (msg.fromAccount != serviceUser.id && msg.fromAccount != robot.id && msg.fromAccount > 5000) {
      /// 这里如果是接入业务平台可替换成用户头像和昵称
      /// if (uid == myUid)  msg.avatar = MyAvatar
      /// if (uid == myUid)  msg.nickname = MyNickname
      msg.nickname = "我";
    } else {
      if (serviceUser != null && serviceUser.id == msg.fromAccount) {
        msg.nickname = serviceUser.nickname ?? "客服";
        msg.avatar = serviceUser.avatar != null && serviceUser.avatar.isNotEmpty
            ? serviceUser.avatar
            : defaultAvatar;
      } else {
        String _localServiceUserStr =
            prefs.getString("service_user_" + msg.fromAccount.toString());
        if (_localServiceUserStr != null) {
          ServiceUserModel _localServiceUser =
              ServiceUserModel.fromJson(json.decode(_localServiceUserStr));
          msg.nickname = _localServiceUser.nickname ?? "客服";
          msg.avatar = _localServiceUser.avatar != null &&
                  _localServiceUser.avatar.isNotEmpty
              ? _localServiceUser.avatar
              : defaultAvatar;
        } else if (robot != null && robot.id == msg.fromAccount) {
          msg.nickname = robot.nickname ?? "客服";
          msg.avatar = robot.avatar != null && robot.avatar.isNotEmpty
              ? robot.avatar
              : defaultAvatar;
        } else {
          String _localRobotStr =
              prefs.getString("robot_" + msg.fromAccount.toString());
          if (_localRobotStr != null) {
            RobotModel _localRobot = RobotModel.fromJson(json.decode(_localRobotStr));
            msg.nickname = _localRobot.nickname ?? "机器人";
            msg.avatar =
                _localRobot.avatar != null && _localRobot.avatar.isNotEmpty
                    ? _localRobot.avatar
                    : defaultAvatar;
          } else {
            msg.nickname = "未知";
            msg.avatar = defaultAvatar;
          }
        }
      }
    }
    return msg;
  }

  /// mimc事件监听
  StreamSubscription _subStatus;
  StreamSubscription _subHandleMessage;
  Future<void> _addMimcEvent() async {
    _subStatus?.cancel();
    _subHandleMessage?.cancel();
    try {
      /// 状态发生改变
      _subStatus = flutterMImc
          ?.addEventListenerStatusChanged()
          ?.listen((bool login) async {
        debugPrint("状态发生改变===$login");
      });

      /// 消息监听
      _subHandleMessage = flutterMImc
          ?.addEventListenerHandleMessage()
          ?.listen((MIMCMessage msg) async {
        ImMessageModel message = ImMessageModel.fromJson(
            json.decode(utf8.decode(base64Decode(msg.payload))));

        printf("收到消息===${message.toJson()}");
        switch (message.bizType) {
          case "contacts":
            contacts = (json.decode(message.payload) as List).map((i){
              ContactModel contact = ContactModel.fromJson(i);
              if(currentContact != null && contact.fromAccount == currentContact.fromAccount){
                currentContact = contact;
              }
              return ContactModel.fromJson(i);
            }).toList();
            break;
          case "handshake":
            MessageHandle msgHandle = createMessage(toAccount: message.fromAccount, msgType: "text", content: serviceUser.autoReply);
            sendMessage(msgHandle);
            break;
          case "text":
            advanceText = "";
            break;
          case "end":
          case "timeout":
            advanceText = "";
            getContacts();
            break;
          case "pong":
            advanceText = message.payload;
            notifyListeners();
            if (isPong) return;
            isPong = true;
            notifyListeners();
            await Future.delayed(Duration(milliseconds: 1500));
            isPong = false;
            notifyListeners();
            break;
          case "cancel":
            message.key = int.parse(message.payload);
            deleteMessage(message.fromAccount, message.key);
            break;
        }
        pushLocalMessage(message, message.fromAccount);
        notifyListeners();
      });
    } catch (e) {
      debugPrint(e);
    }
  }

  /// 处理接收消息
  void pushLocalMessage(ImMessageModel message, int account){
    if(message.bizType == 'pong' || message.bizType == "handshake" ||  message.bizType == "contacts"){
      return;
    }
    ImMessageModel newMsg = _handlerMessage(message);
    List<ImMessageModel> messages = messagesRecords[account] ?? [];
    messages.add(newMsg);
    messagesRecords[account] = messages;
    notifyListeners();
  }


  /// 发送文本消息
  void sendTextMessage(String text){
    MessageHandle msgHandle = createMessage(toAccount: toAccount, msgType: "text", content: text);
    sendMessage(msgHandle);
  }

  /// 发送图片
  void sendPhotoMessage(File file) async {
    debugPrint("${uploadSecret.toJson()}");
    MessageHandle msgHandle;
    try {
      if (file == null) return;
      msgHandle = createMessage(toAccount: toAccount, msgType: "photo", content: file.path);
      pushLocalMessage(msgHandle.localMessage, toAccount);
      notifyListeners();

      String filePath = file.path;
      String fileName = "${DateTime.now().microsecondsSinceEpoch}_" +
          (filePath.lastIndexOf('/') > -1
              ? filePath.substring(filePath.lastIndexOf('/') + 1)
              : filePath);

      FormData formData = new FormData.fromMap({
        "fileType": "image",
        "fileName": "file",
        "file_name": fileName,
        "key": fileName,
        "token": uploadSecret.secret ?? "",
        "file": MultipartFile.fromFileSync(file.path, filename: fileName)
      });

      void uploadSuccess(url) async {
        String img = uploadSecret.host + "/" + url;
        msgHandle.localMessage.isShowCancel = true;
        msgHandle.localMessage.payload = img;
        notifyListeners();
        ImMessageModel sendMsg = ImMessageModel.fromJson(json
            .decode(utf8.decode(base64Decode(msgHandle.sendMessage.payload))));
        sendMsg.payload = img;
        msgHandle.sendMessage.payload =
            base64Encode(utf8.encode(json.encode(sendMsg.toJson())));
        sendMessage(msgHandle.clone()..localMessage.payload = img);
        await Future.delayed(Duration(milliseconds: 10000));
        msgHandle.localMessage.isShowCancel = false;
        notifyListeners();
      }

      String uploadUrl;

      /// 系统自带
      if (uploadSecret.mode == 1) {
        uploadUrl = API_UPLOAD_FILE;
      }

      /// 七牛上传
      else if (uploadSecret.mode == 2) {
        uploadUrl = API_QINIU_UPLOAD_FILE;

        /// 其他
      } else {}

      Response response = await PublicService.instance.http.post(uploadUrl, data: formData,
          onSendProgress: (int sent, int total) {
        msgHandle.localMessage.uploadProgress = (sent / total * 100).ceil();
        notifyListeners();
      });
      debugPrint("${response.data}");
      if (response.statusCode == 200) {
        switch (uploadSecret.mode) {
          case 1:
            uploadSuccess(response.data["data"]);
            break;
          case 2:
            uploadSuccess(response.data["key"]);
            break;
        }
      } else {
        deleteMessage(msgHandle.localMessage.toAccount, msgHandle.localMessage.key);
        MessageHandle systemMsgHandle = createMessage(
            toAccount: toAccount, msgType: "system", content: "图片上传失败~");
            pushLocalMessage(systemMsgHandle.localMessage, toAccount);
      }
    } catch (e) {
      deleteMessage(msgHandle.localMessage.toAccount, msgHandle.localMessage.key);
      MessageHandle systemMsgHandle = createMessage(
          toAccount: toAccount, msgType: "system", content: "图片上传失败~");
     pushLocalMessage(systemMsgHandle.localMessage, toAccount);
    }
  }

  // 消息内容变,ping, pong
  bool isSendPong = false;
  void sendPongMessage(String value) async {
    if (isSendPong) return;
    if(currentContact == null) return;
    isSendPong = true;
    MessageHandle _msgHandle =
        createMessage(toAccount: toAccount, msgType: "pong", content: value);
    sendMessage(_msgHandle);
    await Future.delayed(Duration(milliseconds: 200));
    isSendPong = false;
    notifyListeners();
  }


  @override
  void dispose() {
    printf("GlobalProvide被销毁了");
    _subStatus?.cancel();
    _subHandleMessage?.cancel();
    super.dispose();
  }
}