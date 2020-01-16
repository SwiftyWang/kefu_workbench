import 'package:kefu_workbench/core_flutter.dart';
class KnowledgeEditPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  KnowledgeEditPage({this.arguments});
  @override
  _KnowledgeEditPageState createState() => _KnowledgeEditPageState(
    knowledge: arguments != null ? arguments['knowledge'] : null
  );
}

class _KnowledgeEditPageState extends State<KnowledgeEditPage> {
  final KnowledgeModel knowledge;
  bool isEdit = false;
  _KnowledgeEditPageState({this.knowledge});

  @override
  void initState() {
    super.initState();
    if(mounted){
      if(knowledge == null){
        isEdit = true;
      }
    }
  }

  @override
  Widget build(_) {
    return PageContext(builder: (context){
      ThemeData themeData = Theme.of(context);

      Widget _lineItem({
        String label,
        String placeholder,
        TextStyle style,
        int minLines = 1,
        int maxLines = 1,
        Widget subChild = const SizedBox()
      }){
        return Container(
            padding: EdgeInsets.symmetric(horizontal: ToPx.size(20),vertical: ToPx.size(8)),
            child: DefaultTextStyle(
              style: style,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("$label"),
                    Expanded(
                      child: Input(
                        minLines: minLines,
                        maxLines: maxLines,
                        border: Border.all(style: BorderStyle.none, color: Colors.transparent),
                        height: ToPx.size(90),
                        textInputAction: maxLines > 1 ? TextInputAction.newline : null,
                        placeholder: placeholder,
                      )
                    )
                  ],
                ),
                Divider(height: 1.0,),
                subChild
              ],)
            )
          );
      }
      return Scaffold(
        backgroundColor: themeData.primaryColorLight,
        appBar: customAppBar(
            title: Text(
              "${isEdit ? "编辑知识库" : "添加知识库"}",
              style: themeData.textTheme.display1,
            ),
          ),
        body: ListView(
          children: <Widget>[
              _lineItem(
                label: "主标题：",
                placeholder: "请输入主标题",
                style: themeData.textTheme.title,
              ),
              _lineItem(
                minLines: 1,
                maxLines: 8,
                label: "副标题：",
                placeholder: "请输入副标题(每行一条)",
                style: themeData.textTheme.title,
              ),
              _lineItem(
                minLines: 1,
                maxLines: 8,
                label: "    内容：",
                placeholder: "请输入内容",
                style: themeData.textTheme.title,
              ),
              Button(
                margin: EdgeInsets.symmetric(horizontal: ToPx.size(40), vertical: ToPx.size(50)),
                child: Text("保存"),
                withAlpha: 200,
                onPressed: (){},
              )
          ],
        )

      );
    });
  }
}
