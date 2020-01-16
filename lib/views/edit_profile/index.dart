import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/global.dart';
class EditProfilePage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  EditProfilePage({this.arguments});
  @override
  EditProfilePageState createState() => EditProfilePageState();
}
class EditProfilePageState extends State<EditProfilePage> {
  ServiceUserModel serviceUser = GlobalProvide.getInstance().serviceUser;

  TextEditingController nicknameCtr;
  TextEditingController phoneCtr;
  TextEditingController autoReplyCtr;
  TextEditingController usernameCtr;

  /// 选择图片上传
  void _pickerImage() async{
    ImageSource imageSource = await UX.selectImageSheet(context);
    if(imageSource == ImageSource.camera && !await checkPermission(context, permissionGroupType: PermissionGroup.camera)){
      UX.showToast("未授权使用相机！");
      return;
    }
    if(Platform.isAndroid && imageSource == ImageSource.gallery && !await checkPermission(context, permissionGroupType: PermissionGroup.storage)){
      UX.showToast("未授权使用相册！");
      return;
    }
    if(Platform.isIOS && imageSource == ImageSource.gallery && !await checkPermission(context, permissionGroupType: PermissionGroup.photos)){
      UX.showToast("未授权使用相册！");
      return;
    }
    File _file = await ImagePicker.pickImage(source: imageSource, maxWidth: 300);
    String imgUser = await GlobalProvide.getInstance().uploadImage(_file);
    if(imgUser != null && imgUser.isNotEmpty){
      serviceUser.avatar = imgUser;
      setState(() {});
    }else{
      UX.showToast("上传失败了，请重新尝试");
    }
  }


  /// save
  void saveUser() async{
    String nickname = nicknameCtr.value.text.trim();
    ServiceUserModel user = ServiceUserModel(
      nickname: nickname,
      phone: phoneCtr.value.text.trim(),
      autoReply: autoReplyCtr.value.text.trim(),
      id: serviceUser.id,
      avatar: serviceUser.avatar,
      username: usernameCtr.value.text.trim(),
    );
    Map useMap = user.toJson();
    useMap.removeWhere((key, value) => value == null);
    /// 判断昵称不能为空
    if(nickname.isEmpty || nickname == ""){
      UX.showToast("昵称不能为空");
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    UX.showLoading(context, content: "保存中...");
    Response response = await AdminService.getInstance().saveAdminInfo(useMap);
    UX.hideLoading(context);
    if(response.statusCode == 200){
      UX.showToast("保存成功");
      Navigator.pop(context);
      GlobalProvide.getInstance().getMe();
    }else{
      UX.showToast(response.data["message"]);
    }
  }
  
  @override
  void initState() {
    super.initState();
    if(mounted && serviceUser!= null){
      usernameCtr = TextEditingController(text: serviceUser.username);
      nicknameCtr = TextEditingController(text: serviceUser.nickname);
      phoneCtr = TextEditingController(text: serviceUser.phone);
      autoReplyCtr = TextEditingController(text: serviceUser.autoReply);
    }
  }

  @override
  void dispose() {
    nicknameCtr?.dispose();
    autoReplyCtr?.dispose();
    phoneCtr?.dispose();
    usernameCtr?.dispose();
    super.dispose();
  }

  @override
  Widget build(_) {
    return PageContext(builder: (context){
      ThemeData themeData = Theme.of(context);

      Widget _fromInput({
        String label,
        TextEditingController controller,
        String placeholder,
        bool enabled = true,
      }){
        return Container(
          height: ToPx.size(90),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: themeData.dividerColor,width: ToPx.size(2)))
          ),
          padding: EdgeInsets.symmetric(horizontal: ToPx.size(40)),
          child: Row(
          children: <Widget>[
              Text("$label", style: themeData.textTheme.title,),
              Expanded(
                child: Input(
                enabled: enabled,
                border: Border.all(style: BorderStyle.none, color: Colors.transparent),
                padding: EdgeInsets.symmetric(horizontal: ToPx.size(10)),
                placeholder: "$placeholder",
                showClear: true,
                controller: controller,
              ),
              )
            ],
          ),
        );
      }
      return Scaffold(
        appBar: customAppBar(
            title: Text(
              "编辑个人资料",
              style: themeData.textTheme.display1,
            )),
        body: ListView(
          children: <Widget>[
              SizedBox(
                height: ToPx.size(40),
              ),


              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: ToPx.size(30)),
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Avatar(
                          size: ToPx.size(150),
                          imgUrl: serviceUser.avatar.isEmpty ? "http://qiniu.cmp520.com/avatar_default.png" : serviceUser?.avatar,
                          onPressed: _pickerImage
                        )
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: ToPx.size(120), left: ToPx.size(80)),
                        child: Icon(Icons.camera_alt, color:themeData.primaryColor.withAlpha(150), size: ToPx.size(35),),
                      )
                    )
                  ],
                ),
              ),
              
              _fromInput(
                label: "        账号：",
                placeholder: "请输入账号",
                controller: usernameCtr,
                enabled: false
              ),
              _fromInput(
                label: "用户昵称：",
                placeholder: "请输入昵称",
                controller: nicknameCtr
              ),
              _fromInput(
                label: "联系方式：",
                placeholder: "请输入联系方式",
                controller: phoneCtr
              ),
              Container(
                height: ToPx.size(250),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: themeData.dividerColor,width: ToPx.size(2)))
                ),
                padding: EdgeInsets.symmetric(horizontal: ToPx.size(40), vertical: ToPx.size(10)),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text("自动回复语：", style: themeData.textTheme.title,),
                    Expanded(
                      child: Input(
                      border: Border.all(style: BorderStyle.none, color: Colors.transparent),
                      placeholder: "请输入自动回复语",
                      controller: autoReplyCtr,
                      textAlign: TextAlign.start,
                      minLines: 5,
                      maxLength: 100,
                      placeholderAlignment: Alignment.topLeft,
                      textInputAction: TextInputAction.newline,
                      maxLines: 5,
                    ),
                    )
                  ],
                ),
              ),

              Button(
                margin: EdgeInsets.symmetric(horizontal: ToPx.size(40), vertical: ToPx.size(80)),
                onPressed: saveUser,
                child: Text("保存"),
              )

          ],
        )
      );
    });
  }
}
