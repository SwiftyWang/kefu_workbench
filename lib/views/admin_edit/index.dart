import 'package:dio/dio.dart';
import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/global.dart';
class AdminEditPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  AdminEditPage({this.arguments});
  @override
  _AdminEditPagePageState createState() => _AdminEditPagePageState();
}
class _AdminEditPagePageState extends State<AdminEditPage> {
  AdminModel admin;
  String account = "";
  String avatar = "";
  TextEditingController nicknameCtr;
  TextEditingController phoneCtr;
  TextEditingController autoReplyCtr;

  /// 选择图片上传
  void _pickerImage() async{
    String imgUser = await uploadImage<String>(context, maxWidth: 300.0);
    if(imgUser == null) return;
    avatar = imgUser;
    setState(() {});
  }


  /// save
  void saveAdmin() async{
    String nickname = nicknameCtr.value.text.trim();
    AdminModel user = AdminModel(
      nickname: nickname,
      phone: phoneCtr.value.text.trim(),
      autoReply: autoReplyCtr.value.text.trim(),
      id: admin.id,
      avatar: admin.avatar,
      username: account.trim(),
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
    if(mounted && widget.arguments != null){
      admin = (widget.arguments['admin'] as AdminModel);
      account = admin.username;
      nicknameCtr = TextEditingController(text: admin.nickname);
      phoneCtr = TextEditingController(text: admin.phone);
      autoReplyCtr = TextEditingController(text: admin.autoReply);
    }
  }

  @override
  void dispose() {
    nicknameCtr?.dispose();
    autoReplyCtr?.dispose();
    phoneCtr?.dispose();
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
        bool autofocus = false,
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
                autofocus: autofocus,
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
       Widget _fromItem({
        String label,
        String content
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
                child: Text("$content")
              )
            ],
          ),
        );
      }
      return Scaffold(
        appBar: customAppBar(
          title: Text(
            "编辑客服资料",
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
                          imgUrl: admin.avatar.isEmpty ? "http://qiniu.cmp520.com/avatar_default.png" : admin?.avatar,
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
              
              _fromItem(
                label: "客服账号：",
                content: account
              ),
              _fromInput(
                label: "客服昵称：",
                placeholder: "请输入昵称",
                autofocus: true,
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
                onPressed: saveAdmin,
                child: Text("保存"),
              )

          ],
        )
      );
    });
  }
}
