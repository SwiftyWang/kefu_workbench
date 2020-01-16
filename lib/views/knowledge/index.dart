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
  ScrollController scrollController = ScrollController();
  int pageOn = 0;
  int pageSize = 25;
  bool isLoadEnd = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getKnowledges();
    // 监听滚动
    scrollController?.addListener(() => _onScrollViewControllerAddListener());
  }

  // 监听滚动条
void _onScrollViewControllerAddListener() async{
  try {
    ScrollPosition position = scrollController.position;
    if (position.pixels + 10.0 > position.maxScrollExtent &&
        !isLoadEnd && !isLoading) {
      // 判断网络
      if (!await checkNetWork()) {
        UX.showToast('您的网络异常，请检查您的网络!', position: ToastPosition.top);
        return;
      }
      _getKnowledges();
    }
  }catch(e){
    printf(e);
  }
}

  /// 获取数据
  Future<void> _getKnowledges() async{
    if(isLoadEnd) return;
    pageOn = pageOn +1;
    isLoading = true;
    setState(() { });
    Response response = await KnowledgeService.getInstance().getList(pageOn: pageOn, pageSize: pageSize);
    isLoading = false;
    setState(() { });
    if (response.data["code"] == 200) {
      List<KnowledgeModel> _knowledges = (response.data["data"]['list'] as List).map((i) => KnowledgeModel.fromJson(i)).toList();
      if(_knowledges.length < pageSize){
        isLoadEnd = true;
      }
      if(pageOn > 1){
        knowledges.addAll(_knowledges);
      }else{
        knowledges = _knowledges;
      }
      setState(() { });
    } else {
      UX.showToast("${response.data["message"]}");
    }
  }

  // onRefresh
  Future<bool> onRefresh() async{
    pageOn = 0;
    isLoadEnd = false;
    await _getKnowledges();
    UX.showToast("刷新成功", position: ToastPosition.top);
    return true;
  }

  @override
  void dispose() {
    scrollController?.dispose();
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
                onPressed: () => Navigator.pushNamed(context, "/knowledge_add")
              ),
            ],
          ),
        body: 
        isLoading && knowledges.length == 0 ? Center(
          child: loadingIcon(size: ToPx.size(50)),
        ): 
        RefreshIndicator(
          color: themeData.primaryColorLight,
          backgroundColor: themeData.primaryColor,
          onRefresh: onRefresh,
          child: CustomScrollView(
          controller: scrollController,
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
                        onTap: () => Navigator.pushNamed(context, "/knowledge_detail",arguments: {
                          "knowledge": knowledge
                        }),
                        trailing: Text("${Utils.formatDate(knowledge.createAt)}", style: themeData.textTheme.caption),
                        title: Row(children: <Widget>[
                          Text("${index+1}、", style: themeData.textTheme.title),
                          Expanded(
                            child: Text("${knowledge.title}", style: themeData.textTheme.title, maxLines: 2, overflow: TextOverflow.ellipsis,),
                          )
                        ],),
                      ),
                      Divider(height: 1.0,)
                    ],
                  );
                },
                childCount: knowledges.length
                ),
              ),
              SliverToBoxAdapter(
                child: Offstage(
                  child: Center(
                    child: SizedBox(
                      height: ToPx.size(150),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          loadingIcon(),
                          Text('  内容加载中...',
                              style: themeData.textTheme.caption)
                        ],
                      ),
                    ),
                  ),
                  offstage: !isLoading || isLoadEnd
                )
              ),
              SliverToBoxAdapter(
                child: Offstage(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: ToPx.size(40)),
                    child: Center(
                        child: Text(
                            '没有更多了', style: themeData.textTheme.caption)
                    ),),
                  offstage: !isLoadEnd
                )
              ),

          ],
        )
        ),
      );
    });
  }
}
