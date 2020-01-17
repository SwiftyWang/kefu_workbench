import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/robot.dart';
import 'package:provider/provider.dart';

class RobotsPage extends StatelessWidget {
  final Map<dynamic, dynamic> arguments;
  RobotsPage({this.arguments});

  @override
  Widget build(_) {
    return ChangeNotifierProvider<RobotProvide>(
      create: (_) => RobotProvide.getInstance(),
      child: Consumer<RobotProvide>(builder: (context, robotState, _){
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
                      onPressed: () => robotState.goAdd(context)
                    ),
                  ],
                ),
              body: 
              robotState.isLoading && robotState.robots.length == 0 ? Center(
                child: loadingIcon(size: ToPx.size(50)),
              ): 
              RefreshIndicator(
                color: themeData.primaryColorLight,
                backgroundColor: themeData.primaryColor,
                onRefresh: robotState.onRefresh,
                child: CustomScrollView(
                slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Offstage(
                        offstage: robotState.robots.length > 0 || robotState.isLoading,
                        child: Padding(
                          padding: EdgeInsets.only(top: ToPx.size(50)),
                          child: Text("暂无数据~", style: themeData.textTheme.body1, textAlign: TextAlign.center,),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index){
                        RobotModel robot = robotState.robots[index];
                        return Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () => Navigator.pushNamed(context, "/robot_detail",arguments: {
                                "knowledge": robot
                              }),
                              trailing: Text("${Utils.formatDate(robot.createAt)}", style: themeData.textTheme.caption),
                              title: Row(children: <Widget>[
                                Avatar(
                                  size: ToPx.size(60),
                                  imgUrl: robot.avatar == null || robot.avatar.isEmpty ?
                                  "http://qiniu.cmp520.com/avatar_default.png" : robot.avatar
                                ),
                                Expanded(
                                  child: Text("  ${robot.nickname}", style: themeData.textTheme.title, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                )
                              ],),
                            ),
                            Divider(height: 1.0,)
                          ],
                        );
                      },
                      childCount: robotState.robots.length
                      ),
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

