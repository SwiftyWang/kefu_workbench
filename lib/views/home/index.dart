import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/global.dart';
import 'package:kefu_workbench/provider/home.dart';
import 'package:provider/provider.dart';

import 'widget/contact_widget.dart';
import 'widget/drawer_menu.dart';
import 'widget/popup_menu_button.dart';

// 点击两次返回退出
int lastExitTime = 0;
Future<bool> onBackPressed() async {
  int nowExitTime = DateTime.now().millisecondsSinceEpoch;
  if (nowExitTime - lastExitTime > 2000) {
    lastExitTime = nowExitTime;
    UX.showToast('再按一次退出程序');
    return await Future.value(false);
  }
  return await Future.value(true);
}

class HomePage extends StatelessWidget {

  final Map<dynamic, dynamic> arguments;
  HomePage({this.arguments});

  void openDrawer(context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(ctx) {
    return ChangeNotifierProvider<HomeProvide>(
      create: (_) => HomeProvide.getInstance(),
      child: Builder(builder: (context){
        return Consumer<HomeProvide>(
          builder: (context, homeState, _){
            return PageContext(builder: (context) {
              GlobalProvide.getInstance().setRooContext(context);
              ThemeData themeData = Theme.of(context);
              HomeProvide homeState = Provider.of<HomeProvide>(context);
              GlobalProvide globalState = Provider.of<GlobalProvide>(context);
              return WillPopScope(
                  onWillPop: onBackPressed,
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    appBar: customAppBar(
                        leading: Builder(
                          builder: (context) {
                            return GestureDetector(
                              onTap: () => openDrawer(context),
                              child: Stack(
                                children: <Widget>[
                                  Positioned(
                                    left: ToPx.size(-20),
                                    top: ToPx.size(25),
                                    child: Icon(
                                      Icons.menu,
                                      size: ToPx.size(45),
                                      color: Colors.white.withAlpha(100),
                                    ),
                                  ),
                                  Consumer<GlobalProvide>(
                                    builder: (context, globalState, _){
                                      return Align(
                                        alignment: Alignment.centerRight,
                                        child: Avatar(
                                          size: ToPx.size(70),
                                          imgUrl: "${globalState?.serviceUser?.avatar ?? 'http://qiniu.cmp520.com/avatar_default.png'}",
                                      ));
                                    },
                                  ),
                                  
                                ],
                              ),
                            );
                          },
                        ),
                        actions: [
                          LinePopupMenuButton()
                        ],
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "工作台",
                              style: themeData.textTheme.display1,
                            ),
                            Offstage(
                              offstage: homeState.contactReadCount == 0,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: EdgeInsets.only(top: ToPx.size(5)),
                                  child: Center(
                                    child: Text(
                                      "${homeState.contactReadCount}",
                                      style: themeData.textTheme.caption.copyWith(
                                          color: Colors.white,
                                          fontSize: ToPx.size(20)),
                                    ),
                                  ),
                                  width: ToPx.size(35),
                                  height: ToPx.size(35),
                                  decoration: BoxDecoration(
                                      color: Colors.red, shape: BoxShape.circle),
                                ),
                              ),
                            )
                          ],
                        )),
                    body: 
                    globalState.isContactShowLoading
                    ? Center(
                        child: loadingIcon(size: ToPx.size(50)),
                      )
                    : RefreshIndicator(
                            color: themeData.primaryColorLight,
                            backgroundColor: themeData.primaryColor,
                            onRefresh: () => homeState.onRefresh(),
                            child: CustomScrollView(
                              scrollDirection: Axis.vertical,
                              physics: AlwaysScrollableScrollPhysics(),
                              slivers: <Widget>[
                                Consumer<GlobalProvide>(
                                  builder: (context, globalState, _){
                                    return SliverToBoxAdapter(
                                      child: Offstage(
                                        offstage: globalState.contacts.length > 0 || globalState.isContactShowLoading,
                                        child: SizedBox(
                                          height: ToPx.size(200),
                                          child: Center(
                                            child: Text(
                                              "暂无聊天记录~",
                                              style: themeData.textTheme.body1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Consumer<GlobalProvide>(
                                  builder: (context, globalState, _){
                                    return SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                                      return ContactWidget(globalState.contacts[index]);
                                    }, childCount: globalState.contacts.length));
                                  },
                                ),
                              ],
                            )),
                    drawer: Drawer(
                      child: DrawerMenu(),
                    ),
                  ),
                );
            });
        });
      },)
    );
  }
}
