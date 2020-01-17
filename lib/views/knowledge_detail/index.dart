import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/global.dart';
import 'package:kefu_workbench/provider/knowledge.dart';
import 'package:provider/provider.dart';


class KnowledgeDetailPage extends StatelessWidget {
  final Map<dynamic, dynamic> arguments;
  KnowledgeDetailPage({this.arguments});
  
  @override
  Widget build(context) {
     KnowledgeModel knowledge = arguments['knowledge'];
      return Consumer<KnowledgeProvide>(builder: (context, knowledgeProvide, _){
          knowledge =  knowledgeProvide.getItem(knowledge.id);
          return PageContext(builder: (context){
            ThemeData themeData = Theme.of(context);
            Widget _lineItem({
              String label,
              String content,
              TextStyle style,
              Widget subChild = const SizedBox()
            }){
              return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: themeData.dividerColor))
                  ),
                  padding: EdgeInsets.symmetric(horizontal: ToPx.size(20), vertical: ToPx.size(40)),
                  child: DefaultTextStyle(
                    style: style,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("$label"),
                          Expanded(
                            child: Text("$content", textAlign: TextAlign.left,),
                          )
                        ],
                      ),
                      subChild
                    ],)
                  )
                );
            }
            return Scaffold(
              backgroundColor: themeData.primaryColorLight,
              appBar: customAppBar(
                  title: Text(
                    "${knowledge.title}",
                    style: themeData.textTheme.display1,
                  ),
                  actions: [
                    Button(
                      height: ToPx.size(90),
                      useIosStyle: true,
                      color: Colors.transparent,
                      width: ToPx.size(150),
                      child: Text("编辑"),
                      onPressed: () => Navigator.pushNamed(context, "/knowledge_edit",arguments: {
                        "knowledge": knowledge
                      })
                    ),
                  ],
                ),
              body: ListView(
                children: <Widget>[
                    _lineItem(
                      label: "主标题：",
                      content: "${knowledge.title}",
                      style: themeData.textTheme.title,
                      subChild: DefaultTextStyle(
                        style: themeData.textTheme.caption,
                        child: Padding(
                          padding: EdgeInsets.only(top: ToPx.size(30)),
                          child: Row(
                        children: <Widget>[
                          Text(
                            "展示平台：${GlobalProvide.getInstance().getPlatformTitle(knowledge.platform)}     ",
                          ),
                          Text("创建时间：${Utils.formatDate(knowledge.createAt)}")
                        ],
                      ),
                        ),
                      )
                    ),
                    _lineItem(
                      label: "副标题：",
                      content: "${knowledge.subTitle.replaceAll("|", "、")}",
                      style: themeData.textTheme.body1,
                    ),
                    _lineItem(
                      label: "内容：",
                      content: "${knowledge.content}",
                      style: themeData.textTheme.body1,
                    ),
                    Button(
                      margin: EdgeInsets.symmetric(horizontal: ToPx.size(40), vertical: ToPx.size(50)),
                      child: Text("删除"),
                      withAlpha: 200,
                      color: Colors.redAccent,
                      onPressed: (){},
                    )
                ],
              )

            );
          }); 
    });
  }
}
