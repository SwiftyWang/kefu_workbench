import 'package:dio/dio.dart';
import 'package:kefu_workbench/core_flutter.dart';

class KnowledgePage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  KnowledgePage({this.arguments});
  @override
  _KnowledgePageState createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {

  List<KnowledgeModel> knowledges = [];
  int pageOn = 0;
  int pageSize = 20;
  bool isLoadEnd = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getKnowledges();
  }

  /// 获取数据
  Future<void> _getKnowledges() async{
    pageOn = pageOn +1;
    isLoading = true;
    setState(() { });
    Response response = await KnowledgeService.getInstance().getList(pageOn: pageOn, pageSize: pageSize);
    isLoading = false;
    setState(() { });
    if (response.data["code"] == 200) {
      List<KnowledgeModel> _knowledges = (response.data["data"]['list'] as List).map((i) => KnowledgeModel.fromJson(i)).toList();
      if(_knowledges.length < pageSize){
        isLoadEnd = false;
      }
      knowledges = _knowledges;
      setState(() { });
    } else {
      UX.showToast("${response.data["message"]}");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(_) {
    return PageContext(builder: (context){
      ThemeData themeData = Theme.of(context);
      return Scaffold(
        backgroundColor: themeData.primaryColorLight,
        appBar: customAppBar(
            title: Text(
              "知识库列表",
              style: themeData.textTheme.display1,
            ),
            actions: [
              Button(
                height: ToPx.size(90),
                useIosStyle: true,
                color: Colors.transparent,
                width: ToPx.size(150),
                child: Text("新增"),
                onPressed: () => Navigator.pushNamed(context, "/add_knowledge")
              ),
            ],
          ),
        body: RefreshIndicator(
          color: themeData.primaryColorLight,
          backgroundColor: themeData.primaryColor,
          onRefresh: (){},
          child: CustomScrollView(
          slivers: <Widget>[
              SliverToBoxAdapter(
                child: Offstage(
                  offstage: knowledges.length > 0 || isLoading,
                  child: Padding(
                    padding: EdgeInsets.only(top: ToPx.size(50)),
                    child: Text("暂无数据~", style: themeData.textTheme.body1, textAlign: TextAlign.center,),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index){
                  KnowledgeModel knowledge = knowledges[index];
                  return Column(
                    children: <Widget>[
                      ListTile(
                        onTap: (){},
                        subtitle: Text("添加时间：2019/10/17", style: themeData.textTheme.caption,),
                        title: Text("${index+1}、 ${knowledge.title}", style: themeData.textTheme.title, maxLines: 2, overflow: TextOverflow.ellipsis,),
                      ),
                      Divider(height: 1.0,)
                    ],
                  );
                },
                childCount: knowledges.length
                ),
              )

          ],
        )
        ),
      );
    });
  }
}
