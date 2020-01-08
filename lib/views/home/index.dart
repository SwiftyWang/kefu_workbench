import 'package:flutter/gestures.dart';
import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/global.dart';
import 'package:kefu_workbench/provider/home.dart';
import 'package:provider/provider.dart';

import 'widget/drawer_menu.dart';

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

enum LineType { online, offline, leave }

class HomePage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  HomePage({this.arguments});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeProvide homeProvide = HomeProvide();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      GlobalProvide.getInstance().setRooContext(context);
      homeProvide.getConcats(context, isFullLoading: true);
    }
  }

  void openDrawer(context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(_) {
    return PageContext(builder: (context) {
      ThemeData themeData = Theme.of(context);

      Widget _listItem(ConcatModel concat) {
        return Dismissible(
          dragStartBehavior: DragStartBehavior.down,
          confirmDismiss: (DismissDirection direction) async {
            if (direction.index != 2) return false;
            return true;
          },
          secondaryBackground: Container(
            color: Colors.red.withAlpha(200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  width: ToPx.size(150),
                ),
              ],
            ),
          ),
          background: Container(
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                onTap: () {},
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "${concat.nickname}",
                      style: themeData.textTheme.title,
                    ),
                    Text(
                      "${Utils.epocFormat(concat?.contactCreateAt)}",
                      style: themeData.textTheme.caption,
                    ),
                  ],
                ),
                leading: SizedBox(
                  width: ToPx.size(100),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Avatar(
                          size: ToPx.size(90),
                          imgUrl:
                              "${concat.avatar.isEmpty ? 'http://qiniu.cmp520.com/avatar_default.png' : concat.avatar}",
                        ),
                      ),
                      Offstage(
                        offstage: concat.read == 0,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.only(top: ToPx.size(5)),
                            child: Center(
                              child: Text(
                                "${concat.read}",
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
                  ),
                ),
                subtitle: Text(
                  concat.lastMessageType == "text"
                      ? concat.lastMessage
                      : concat.lastMessageType == "photo"
                          ? "图片文件"
                          : concat.lastMessageType == "video"
                              ? "视频文件"
                              : concat.lastMessageType == "end"
                                  ? "会话结束"
                                  : concat.lastMessageType == "timeout"
                                      ? "会话超时，结束对话"
                                      : concat.lastMessageType == "transfer"
                                          ? "客服转接..."
                                          : concat.lastMessageType == "system"
                                              ? "系统提示..."
                                              : concat.lastMessageType ==
                                                      "cancel"
                                                  ? "撤回了消息"
                                                  : "未知消息内容~",
                  style: themeData.textTheme.body2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Divider(
                height: 1.0,
              )
            ],
          ),
          key: GlobalKey(),
        );
      }

      return ChangeNotifierProvider<HomeProvide>.value(
          value: homeProvide,
          child: Builder(builder: (context) {
            GlobalProvide globalState = GlobalProvide.getInstance();
            HomeProvide homeState = Provider.of<HomeProvide>(context);
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
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Avatar(
                                    size: ToPx.size(60),
                                    imgUrl:
                                        "${globalState?.serviceUser?.avatar ?? 'http://qiniu.cmp520.com/avatar_default.png'}",
                                  ))
                            ],
                          ),
                        );
                      },
                    ),
                    actions: [
                      PopupMenuButton<LineType>(
                        onSelected: (LineType result) {},
                        child: Align(
                          child: Container(
                              width: ToPx.size(80),
                              height: ToPx.size(40),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: ToPx.size(10),
                                    height: ToPx.size(10),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green),
                                  ),
                                  Text(
                                    " 在线",
                                    style: themeData.textTheme.caption.copyWith(
                                        fontSize: ToPx.size(22),
                                        color: Colors.green),
                                  ),
                                ],
                              )),
                        ),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<LineType>>[
                          PopupMenuItem<LineType>(
                            value: LineType.online,
                            child: Text(
                              '我要上线',
                              style: themeData.textTheme.title
                                  .copyWith(color: themeData.primaryColorLight),
                            ),
                          ),
                          PopupMenuItem<LineType>(
                            value: LineType.offline,
                            child: Text('我要下线',
                                style: themeData.textTheme.title.copyWith(
                                    color: themeData.primaryColorLight)),
                          ),
                          PopupMenuItem<LineType>(
                            value: LineType.leave,
                            child: Text('我要离开',
                                style: themeData.textTheme.title.copyWith(
                                    color: themeData.primaryColorLight)),
                          ),
                        ],
                      )
                    ],
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "工作台",
                          style: themeData.textTheme.display1,
                        ),
                        Offstage(
                          offstage: homeState.concatReadCount == 0,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: EdgeInsets.only(top: ToPx.size(5)),
                              child: Center(
                                child: Text(
                                  "${homeState.concatReadCount}",
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
                body: homeState.isFullLoading
                    ? Center(
                        child: loadingIcon(size: ToPx.size(50)),
                      )
                    : 
                    RefreshIndicator(
                      color: themeData.primaryColorLight,
                      backgroundColor: themeData.primaryColor,
                      onRefresh: () => homeState.onRefresh(context),
                      child: CustomScrollView(
                        scrollDirection: Axis.vertical,
                        physics: AlwaysScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: Offstage(
                              offstage: homeProvide.concats.length > 0 ||
                                  homeProvide.isFullLoading,
                              child: SizedBox(
                                height: ToPx.size(350),
                                child: Center(
                                  child: Text(
                                    "暂无聊天记录~",
                                    style: themeData.textTheme.title,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                            return _listItem(homeProvide.concats[index]);
                          }, childCount: homeProvide.concats.length)),
                        ],
                      )
                    ),
                drawer: Drawer(
                  child: DrawerMenu(),
                ),
              ),
            );
          }));
    });
  }
}

