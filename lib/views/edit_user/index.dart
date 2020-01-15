import 'package:kefu_workbench/core_flutter.dart';
class EditUserPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  EditUserPage({this.arguments});
  @override
  EditUserPageState createState() => EditUserPageState(arguments['user']);
}
class EditUserPageState extends State<EditUserPage> {
  final ContactModel currentContact;
  EditUserPageState(this.currentContact);
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(_) {
    return PageContext(builder: (context){
      ThemeData themeData = Theme.of(context);
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: customAppBar(
            title: Text(
              "编辑用户信息",
              style: themeData.textTheme.display1,
            )),
        body: ListView(
          children: <Widget>[

              Container(
                height: ToPx.size(90),
                padding: EdgeInsets.symmetric(horizontal: ToPx.size(40)),
                child: Row(
                children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: ToPx.size(20)),
                      child: Text("用户昵称:", style: themeData.textTheme.title,),
                    ),
                    Expanded(
                      child: Input(
                      border: Border.all(style: BorderStyle.none, color: Colors.transparent),
                      bgColor: Colors.black.withAlpha(5),
                      padding: EdgeInsets.symmetric(horizontal: ToPx.size(10)),
                      borderRadius: BorderRadius.all(Radius.circular(ToPx.size(8))),
                      placeholder: "请输入用户昵称~",
                      showClear: true,
                    ),
                    )
                  ],
                ),
              )


          ],
        )
      );
    });
  }
}
