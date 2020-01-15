import 'package:dio/dio.dart';
import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/global.dart';
class EditUserPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  EditUserPage({this.arguments});
  @override
  EditUserPageState createState() => EditUserPageState(arguments['user']);
}
class EditUserPageState extends State<EditUserPage> {
  final ContactModel currentContact;
  EditUserPageState(this.currentContact);

  TextEditingController nicknameCtr;
  TextEditingController addrCtr;
  TextEditingController phoneCtr;
  TextEditingController remarksCtr;
  TextEditingController idCtr;

  /// save
  void saveUser() async{
    String nickname = nicknameCtr.value.text.trim();
    UserModel user = UserModel(
      nickname: nickname,
      address: addrCtr.value.text.trim(),
      phone: phoneCtr.value.text.trim(),
      remarks: remarksCtr.value.text.trim(),
      id: int.parse(idCtr.value.text),
    );
    Map useMap = user.toJson();
    useMap.removeWhere((key, value) => value == null);
    /// 判断昵称不能为空
    if(nickname.isEmpty || nickname == ""){
      UX.showToast("用户昵称不能为空");
      return;
    }
    UX.showLoading(context, content: "保存中...");
    Response response = await UserService.getInstance().save(useMap);
    UX.hideLoading(context);
    if(response.statusCode == 200){
      UX.showToast("保存成功");
      Navigator.pop(context);
      GlobalProvide.getInstance().getContacts();
    }else{
      UX.showToast(response.data["message"]);
    }
  }
  
  @override
  void initState() {
    super.initState();
    if(mounted && currentContact!= null){
      nicknameCtr = TextEditingController(text: currentContact.nickname);
      addrCtr = TextEditingController(text: currentContact.address);
      phoneCtr = TextEditingController(text: currentContact.phone);
      remarksCtr = TextEditingController(text: currentContact.remarks);
      idCtr = TextEditingController(text: currentContact.id.toString());
    }
  }

  @override
  void dispose() {
    nicknameCtr?.dispose();
    addrCtr?.dispose();
    phoneCtr?.dispose();
    idCtr?.dispose();
    remarksCtr?.dispose();
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
        bool enabled = true
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
              "编辑用户信息",
              style: themeData.textTheme.display1,
            )),
        body: ListView(
          children: <Widget>[
              SizedBox(
                height: ToPx.size(40),
              ),

              
              _fromInput(
                label: "   用户 ID：",
                placeholder: "请输入用户昵称",
                controller: idCtr,
                enabled: false
              ),
              _fromInput(
                label: "用户昵称：",
                placeholder: "请输入用户昵称",
                controller: nicknameCtr
              ),
               _fromInput(
                label: "所在地区：",
                placeholder: "请输入用户所在地区",
                controller: addrCtr
              ),
              _fromInput(
                label: "联系方式：",
                placeholder: "请输入用户联系方式",
                controller: phoneCtr
              ),
              _fromInput(
                label: "备注信息：",
                placeholder: "请输入用户备注信息",
                controller: remarksCtr
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
