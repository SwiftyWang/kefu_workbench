import 'package:flutter/gestures.dart';
import 'package:kefu_workbench/core_flutter.dart';

// 点击两次返回退出
int lastExitTime = 0;
Future<bool> onBackPressed() async {
  int nowExitTime = DateTime.now().millisecondsSinceEpoch;
  if(nowExitTime - lastExitTime > 2000) {
    lastExitTime = nowExitTime;
    UX.showToast('再按一次退出程序');
    return await Future.value(false);
  }
  return await Future.value(true);
}
enum LineType { online, offline, leave}
class HomePage extends StatelessWidget {
  final Map<dynamic, dynamic> arguments;
  HomePage({this.arguments});

  void openDrawer(context){
    Scaffold.of(context).openDrawer();
  }
  
  @override
  Widget build(_) {
    return PageContext(builder: (context){
      ThemeData themeData = Theme.of(context);


      Widget _listItem(){
        return Column(
          children: <Widget>[
           Dismissible(
              dragStartBehavior: DragStartBehavior.down,
              confirmDismiss: (DismissDirection direction) async{
                if(direction.index != 2) return false;
                return true;
              },
              secondaryBackground: Container(
                color:  Colors.red.withAlpha(200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(child: Icon(Icons.delete, color: Colors.white,), width: ToPx.size(150),),
                ],),
              ),
              background: Container(
                color: Colors.white,
              ),
              child: ListTile(
              onTap: (){},
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("访客165165", style: themeData.textTheme.title,),
                  Text("下午 12:00", style: themeData.textTheme.caption,),
                ],
              ),
              leading: SizedBox(
                width: ToPx.size(100),
                child: Stack(
                  children: <Widget>[
                    Avatar(
                      size: ToPx.size(90),
                      imgUrl: "http://qiniu.cmp520.com/avatar_default.png",
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                      child: Center(child: Text("1", style: themeData.textTheme.caption.copyWith(
                        color: Colors.white,
                        fontSize: ToPx.size(20)
                      ),),),
                      width: ToPx.size(35),
                      height: ToPx.size(35),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle
                      ),
                    ),
                    )
                  ],
                ),
              ),
              subtitle: Text("有什么办法水电费是水电费没水电费水电费", style: themeData.textTheme.body2, maxLines: 1, overflow: TextOverflow.ellipsis,),
            ), key: GlobalKey(),
            ),
            Divider(height: 1.0,)
          ],
        );
      }


      return WillPopScope(
        onWillPop: onBackPressed,
        child: Scaffold(
        backgroundColor: Colors.white,
        appBar: customAppBar(
            leading: Builder(builder: (context){
              return GestureDetector(
                onTap: () => openDrawer(context),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: ToPx.size(-20),
                      top: ToPx.size(25),
                      child: Icon(Icons.menu, size: ToPx.size(45),color: Colors.white.withAlpha(100),),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Avatar(
                      size: ToPx.size(70),
                      imgUrl: "http://qiniu.cmp520.com/avatar_default.png",
                    ),
                    )
                  ],
                ),
              );
            },),
            actions: [
                PopupMenuButton<LineType>(
                onSelected: (LineType result) {

                },
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
                            color: Colors.green
                          ),
                        ),
                        Text(" 在线", style: themeData.textTheme.caption.copyWith(
                          fontSize: ToPx.size(22),
                          color: Colors.green
                        ),),
                      ],
                    )
                  ),
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<LineType>>[
                 PopupMenuItem<LineType>(
                    value: LineType.online,
                    child: Text('我要上线', style: themeData.textTheme.title.copyWith(
                      color: themeData.primaryColorLight
                    ),),
                  ),
                 PopupMenuItem<LineType>(
                    value: LineType.offline,
                    child: Text('我要下线', style: themeData.textTheme.title.copyWith(
                      color: themeData.primaryColorLight
                    )),
                  ),
                 PopupMenuItem<LineType>(
                    value: LineType.leave,
                    child: Text('我要离开', style: themeData.textTheme.title.copyWith(
                      color: themeData.primaryColorLight
                    )),
                  ),
                ],
              )
            ],
            title: Text(
              "工作台",
              style: themeData.textTheme.display1,
            )),
        body: CustomScrollView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[

             sliverRefreshControl(
                onRefresh: () async {
                  await Future.delayed(Duration(milliseconds: 5000));
                  return true;
                },
              ),

            SliverList(
              delegate: SliverChildBuilderDelegate((context, index){
                return _listItem();
              })
            )

          ],
        ),
        drawer: Drawer(
          child: DrawerMenu(),
        ),
      ),
      );
    });
  }
}


class DrawerMenu extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);


    Widget _listTile({
      IconData icon,
      String title,
      VoidCallback onTap,
      Color selectedColor = Colors.white
    }){
      return Button(
        onPressed: onTap,
        withAlpha: 200,
        padding: EdgeInsets.symmetric(horizontal: ToPx.size(40)),
        height: ToPx.size(100),
        color: themeData.primaryColor,
        radius: 0.0,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Icon(icon, color: themeData.primaryColorLight),
                  Padding(
                    padding: EdgeInsets.only(left: ToPx.size(50)),
                    child: Text(title, style: themeData.textTheme.title.copyWith(
                      color: themeData.primaryColorLight,
                      fontWeight: FontWeight.w500
                    ),),
                  )
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: themeData.primaryColorLight.withAlpha(100))
          ],
        ),
      );
    }


    return Container(
      color: themeData.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: themeData.primaryColor,
            width: double.infinity,
            height: ToPx.size(260),
            padding: EdgeInsets.only(top: ToPx.size(80), left: ToPx.size(20), right: ToPx.size(20)),
            child: Column(children: <Widget>[
              Avatar(
                size: ToPx.size(100),
                imgUrl: "http://qiniu.cmp520.com/avatar_default.png",
              ),
              Padding(
                padding: EdgeInsets.only(top: ToPx.size(20)),
                child: Text("Keith", style: themeData.textTheme.title.copyWith(
                color: themeData.primaryColorLight
              ),),
              )
            ],),
          ),
          Divider(height: 1.0, color: Colors.black12,),
          Column(children: <Widget>[
            _listTile(
              icon: Icons.home,
              title: "工作台",
              onTap: () => Navigator.pop(context)
            ),
            _listTile(
              icon: Icons.library_books,
              title: "知识库",
              onTap: () => Navigator.pop(context)
            ),
            _listTile(
              icon: Icons.android,
              title: "机器人",
              onTap: () => Navigator.pop(context)
            ),
            _listTile(
              icon: Icons.supervised_user_circle,
              title: "客服管理",
              onTap: () => Navigator.pop(context)
            ),
            _listTile(
              icon: Icons.supervisor_account,
              title: "用户管理",
              onTap: () => Navigator.pop(context)
            ),
            _listTile(
              icon: Icons.featured_play_list,
              title: "服务记录",
              onTap: () => Navigator.pop(context)
            ),
            _listTile(
              icon: Icons.settings,
              title: "系统设置",
              onTap: () => Navigator.pop(context)
            ),
          ],)

      ],),
    );
  }
}