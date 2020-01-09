
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
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
  
  /// ImService
  ImService imService = ImService.getInstance();

  /// AdminService
  AdminService adminService = AdminService.getInstance();

  /// PublicService
  PublicService publicService = PublicService.getInstance();

  /// GlobalProvide实例
  static GlobalProvide instance;

  /// 客服信息
  ServiceUserModel serviceUser;

  /// IM 用户对象
  ImUserModel imUser;

  /// 当前服务谁
  ConcatModel currentConcat;

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
  List<Map<String, List<ImMessageModel>>> messagesRecords = [];

  /// 显示对方输入中...
  bool isPong = false;

  /// 没有更多记录了
  bool isScrollEnd = false;

  /// 为消息总数
  int messageReadCount = 0;

  /// 被踢出最长时间
  int tomeOutTime = 60 * 1000 * 8;

  /// 是否自动登录
  static bool isAutoLogin;

  /// 延迟登录(毫秒)
  static int delayLoginTime;

  /// 业务平台ID
  static int platformUserId;

  /// API 接口
  static String apiHost;

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
      await _getMe();
      await _registerImAccount();
      await _flutterMImcInstance();
      await _addMimcEvent();
    }
  }

  /// is login
  bool get isLogin{
    String authorization = prefs.getString("Authorization");
    String serviceUserString = prefs.getString("serviceUser");
    if(serviceUserString != null){
      ServiceUserModel user = ServiceUserModel.fromJson(json.decode(serviceUserString));
      setServiceUser(user);
    }
    if(authorization != null && serviceUser != null){
      printf("用户已登录~");
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
    setServiceUser(null);
    updateUserOnlineStatus(online: 0);
    prefs.remove("serviceUser");
    prefs.remove("Authorization");
  }

  /// 获取个人信息
  Future<void> _getMe() async {
     Response response = await adminService.getMe();
      if (response.data["code"] == 200) {
        serviceUser = ServiceUserModel.fromJson(response.data['data']);
        setServiceUser(serviceUser);
      } else {
        UX.showToast(response.data['message']);
      }


  }

  /// 设置serviceUser
  void setServiceUser(ServiceUserModel user){
    serviceUser = user;
    notifyListeners();
  }

  /// 实例化 FlutterMImc
  Future<void> _flutterMImcInstance() async {
    if(flutterMImc != null) return;
    try{
      String tokenString = '{"code": 200, "message": "success", "data": ${jsonEncode(imTokenInfo.toJson())}}';
      flutterMImc = FlutterMIMC.stringTokenInit(tokenString, debug: true);
    } catch(_) {
      printf("实例化失败");
      // 1秒重
      await Future.delayed(Duration(milliseconds: 1000));
      _flutterMImcInstance();
    }
  }

  /// 注册IM账号
  Future<void> _registerImAccount() async {
    try {
      Response response = await imService.registerImAccount(accountId: serviceUser.id);
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
  setCurrentConcat(ConcatModel concat){
    currentConcat = concat;
    toAccount = currentConcat.fromAccount;
    printf(concat.toJson());
    notifyListeners();
  }

  /// 更新客服上线状态
  void updateUserOnlineStatus({int online}) async{
    Response response = await adminService.updateUserOnlineStatus(status: online);
    if (response.data["code"] == 200) {
        _getMe();
        if(online == 0){
          UX.showToast("当前状态为离线");
        }else if(online == 1){
          UX.showToast("当前状态为在线");
        }else{
          UX.showToast("当前状态为离开");
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
  Future<void> getMessageRecord({int timestamp, int pageSize = 20, int account}) async {
    try {
      Response response = await imService.getMessageRecord(timestamp: timestamp, pageSize: pageSize, account: account);
    } catch (e) {
      debugPrint(e);
    }
  }

  /// 上报IM最后活动时间
  Future<void> _upImLastActivity() async {
    Timer.periodic(Duration(milliseconds: 20000), (_) {
      if (imUser != null) imService.upImLastActivity();
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
    String millisecondsSinceEpoch =
        DateTime.now().millisecondsSinceEpoch.toString();
    int timestamp = int.parse(
        millisecondsSinceEpoch.substring(0, millisecondsSinceEpoch.length - 3));
    message.timestamp = timestamp;
    message.bizType = msgType;
    message.toAccount = toAccount.toString();
    Map<String, dynamic> payloadMap = {
      "from_account": imUser.id,
      "to_account": toAccount,
      "biz_type": msgType,
      "version": "0",
      "key": DateTime.now().millisecondsSinceEpoch,
      "platform": Platform.isAndroid ? 6 : 2,
      "timestamp": timestamp,
      "read": 0,
      "transfer_account": 0,
      "payload": content
    };
    message.payload = base64Encode(utf8.encode(json.encode(payloadMap)));
    return MessageHandle(
        sendMessage: message,
        localMessage: ImMessageModel.fromJson(payloadMap)..isShowCancel = true);
  }

  /// 发送消息
  void sendMessage(MessageHandle msgHandle) async {
    //  发送失败提示
    if (!await flutterMImc.isOnline()) {
      MessageHandle tipsMsg = createMessage(
          toAccount: toAccount, msgType: "system", content: "您的网络异常，发送失败了~");
      // messagesRecord.add(tipsMsg.localMessage);
      return;
    }

    flutterMImc.sendMessage(msgHandle.sendMessage);

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
    ImMessageModel newMsg = _handlerMessage(cloneMsgHandle.localMessage);
    // if (type != "photo") messagesRecord.add(newMsg);
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 10000));
    newMsg.isShowCancel = false;
    notifyListeners();
  }

  // 更新某个消息
  void updateMessage(ImMessageModel msg) {
    // int index = messagesRecord.indexWhere((i) => i.key == msg.key);
    // messagesRecord[index] = msg;
    notifyListeners();
  }

  /// 删除消息
  void deleteMessage(ImMessageModel msg) {
    // if (msg == null) return;
    // int index = messagesRecord.indexWhere(
    //     (i) => i.key == msg.key && i.fromAccount == msg.fromAccount);
    // messagesRecord.removeAt(index);
    // notifyListeners();
  }

  // 处理头像昵称
  ImMessageModel _handlerMessage(ImMessageModel msg) {
    const String defaultAvatar = 'http://qiniu.cmp520.com/avatar_degault_3.png';
    msg.avatar = defaultAvatar;
    // 消息是我发的
    if (msg.fromAccount == imUser.id) {
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
    try {
      /// 状态发生改变
      _subStatus = flutterMImc
          .addEventListenerStatusChanged()
          .listen((bool isLogin) async {
        debugPrint("状态发生改变===$isLogin");
      });

      /// 消息监听
      _subHandleMessage = flutterMImc
          .addEventListenerHandleMessage()
          .listen((MIMCMessage msg) async {
        ImMessageModel message = ImMessageModel.fromJson(
            json.decode(utf8.decode(base64Decode(msg.payload))));


        switch (message.bizType) {
          case "handshake":
            serviceUser = ServiceUserModel.fromJson(json.decode(message.payload));
            prefs.setString("service_user_${serviceUser.id}", message.payload);
            MessageHandle msgHandle = createMessage(
                toAccount: toAccount, msgType: "handshake", content: "与客服握握手鸭");
            sendMessage(msgHandle);
            break;
          case "end":
          case "timeout":
            serviceUser = null;
            notifyListeners();
            break;
          case "pong":
            if (isPong) return;
            isPong = true;
            notifyListeners();
            await Future.delayed(Duration(milliseconds: 1500));
            isPong = false;
            notifyListeners();
            break;
          case "cancel":
            message.key = int.parse(message.payload);
            deleteMessage(message);
            break;
        }

        // if (window == 0 && message.bizType != 'pong') {
        //   messageReadCount = messageReadCount + 1;
        // }

        // 不处理的消息
        if (message.bizType == 'search_knowledge' || message.bizType == "pong")
          return;

        ImMessageModel newMsg = _handlerMessage(message);
        // messagesRecord.add(newMsg);
        notifyListeners();
      });
    } catch (e) {
      debugPrint(e);
    }
  }

  /// 登录Im
  Future<void> loginIm() async {
    if (!isAutoLogin) return;
    await Future.delayed(Duration(milliseconds: delayLoginTime));
    if (!await flutterMImc?.isOnline()) {
      debugPrint("登录中...");
      flutterMImc?.login();
      return;
    }
    await Future.delayed(Duration(milliseconds: 2000));
    loginIm();
  }

  /// 上传发送图片
  void sendPhoto(File file) async {
    debugPrint("${uploadSecret.toJson()}");
    MessageHandle msgHandle;
    try {
      if (file == null) return;
      msgHandle = createMessage(
          toAccount: toAccount, msgType: "photo", content: file.path);
      // messagesRecord.add(_handlerMessage(msgHandle.localMessage));
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

      Response response = await ImService.instance.http.post(uploadUrl, data: formData,
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
        deleteMessage(msgHandle.localMessage);
        MessageHandle systemMsgHandle = createMessage(
            toAccount: toAccount, msgType: "system", content: "图片上传失败！");
        // messagesRecord.add(_handlerMessage(systemMsgHandle.localMessage));
      }
    } catch (e) {
      deleteMessage(msgHandle.localMessage);
      MessageHandle systemMsgHandle = createMessage(
          toAccount: toAccount, msgType: "system", content: "图片上传失败~");
      // messagesRecord.add(_handlerMessage(systemMsgHandle.localMessage));
      debugPrint("图片上传失败！ =======$e");
    }
  }

  // 消息内容变,ping, pong
  bool isSendPong = false;
  void inputOnChanged(String value) async {
    if (isSendPong) return;
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
    _subStatus?.cancel();
    _subHandleMessage?.cancel();
    super.dispose();
  }
}