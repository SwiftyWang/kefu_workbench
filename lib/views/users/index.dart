import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/global.dart';
import 'package:kefu_workbench/provider/user.dart';
import 'package:provider/provider.dart';

class UsersPage extends StatelessWidget {
  final Map<dynamic, dynamic> arguments;
  UsersPage({this.arguments});

  @override
  Widget build(_) {
    return ChangeNotifierProvider<UserProvide>(
      create: (_) => UserProvide.getInstance(),
      child: Consumer<UserProvide>(builder: (context, userState, _){
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
                      onPressed: () => userState.goAdd(context)
                    ),
                  ],
                ),
              body: 
              userState.isLoading && userState.robots.length == 0 ? Center(
                child: loadingIcon(size: ToPx.size(50)),
              ): 
              RefreshIndicator(
                color: themeData.primaryColorLight,
                backgroundColor: themeData.primaryColor,
                onRefresh: userState.onRefresh,
                child: CustomScrollView(
                slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Offstage(
                        offstage: userState.users.length > 0 || userState.isLoading,
                        child: Padding(
                          padding: EdgeInsets.only(top: ToPx.size(50)),
                          child: Text("暂无数据~", style: themeData.textTheme.body1, textAlign: TextAlign.center,),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index){
                        UserModel user = userState.users[index];
                        return Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () => Navigator.pushNamed(context, "/user_detail",arguments: {
                                "user": user
                              }),
                              subtitle: Row(
                                children: <Widget>[
                                  Text("服务平台：", style: themeData.textTheme.caption),
                                  Text("sss", style: themeData.textTheme.caption),
                                ],
                              ),
                              trailing: RichText(
                                text: TextSpan(
                                  style: themeData.textTheme.caption,
                                  children: [
                                    TextSpan(text: "状态："),
                                    TextSpan(text: "暂停中", style: themeData.textTheme.caption.copyWith(
                                      color:  Colors.amber
                                    )),
                                  ]
                                ),
                              ),
                              leading: Avatar(
                                size: ToPx.size(100),
                                imgUrl: user.avatar == null || user.avatar.isEmpty ?
                                "http://qiniu.cmp520.com/avatar_default.png" : user.avatar
                              ),
                              title: Text("${user.nickname}", style: themeData.textTheme.title, maxLines: 2, overflow: TextOverflow.ellipsis,),
                            ),
                            Divider(height: 1.0,)
                          ],
                        );
                      },
                      childCount: userState.robots.length
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

