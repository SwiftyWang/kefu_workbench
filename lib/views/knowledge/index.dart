import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/knowledge.dart';
import 'package:provider/provider.dart';

class KnowledgePage extends StatelessWidget{
  final Map<dynamic, dynamic> arguments;
  KnowledgePage({this.arguments});

  @override
  Widget build(_) {
    return ChangeNotifierProvider<KnowledgeProvide>(
      create: (_) => KnowledgeProvide.getInstance(),
      child: Consumer<KnowledgeProvide>(builder: (context, knowledgeProvide, _){
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
                      onPressed: () => knowledgeProvide.goAdd(context)
                    ),
                  ],
                ),
              body: 
              knowledgeProvide.isLoading && knowledgeProvide.knowledges.length == 0 ? Center(
                child: loadingIcon(size: ToPx.size(50)),
              ): 
              RefreshIndicator(
                color: themeData.primaryColorLight,
                backgroundColor: themeData.primaryColor,
                onRefresh: knowledgeProvide.onRefresh,
                child: CustomScrollView(
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(),
                controller: knowledgeProvide.scrollController,
                slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Offstage(
                        offstage: knowledgeProvide.knowledges.length > 0 || knowledgeProvide.isLoading,
                        child: Padding(
                          padding: EdgeInsets.only(top: ToPx.size(50)),
                          child: Text("暂无数据~", style: themeData.textTheme.body1, textAlign: TextAlign.center,),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index){
                        KnowledgeModel knowledge = knowledgeProvide.knowledges[index];
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
                      childCount: knowledgeProvide.knowledges.length
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
                        offstage: !knowledgeProvide.isLoading || knowledgeProvide.isLoadEnd
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
                        offstage: !knowledgeProvide.isLoadEnd
                      )
                    ),

                ],
              )
              ),
            );
          });
      },),
    );

  }
}
