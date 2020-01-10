import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/global.dart';
import 'package:kefu_workbench/provider/home.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    HomeProvide homeState = Provider.of<HomeProvide>(context);
    GlobalProvide  globalState = Provider.of<GlobalProvide>(context);
    Color lineColor = globalState?.serviceUser?.online == 1  ? Colors.green[400] :
    globalState?.serviceUser?.online == 0 ? Colors.grey :
    globalState?.serviceUser?.online == 2 ? Colors.amber : Colors.grey;
    Widget _listTile(
        {IconData icon,
        String title,
        VoidCallback onTap,
        Color selectedColor = Colors.white}) {
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
                    child: Text(
                      title,
                      style: themeData.textTheme.title.copyWith(
                          color: themeData.primaryColorLight,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: themeData.primaryColorLight.withAlpha(30))
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
            color: themeData.primaryColorDark,
            width: double.infinity,
            height: ToPx.size(260),
            padding: EdgeInsets.only(
                top: ToPx.size(80), left: ToPx.size(20), right: ToPx.size(20)),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Avatar(
                        size: ToPx.size(100),
                        imgUrl: globalState.serviceUser?.avatar ??
                            "http://qiniu.cmp520.com/avatar_default.png",
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: ToPx.size(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "${globalState.serviceUser?.nickname ?? '未知昵称'} ",
                              style: themeData.textTheme.title
                                  .copyWith(color: themeData.primaryColorLight),
                            ),
                            Container(
                              width: ToPx.size(10),
                              height: ToPx.size(10),
                              decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: lineColor
                            ),
                            ),
                            Text(
                              globalState?.serviceUser?.online == 0 ? " 离线" :
                              globalState?.serviceUser?.online == 1 ? " 在线" :
                              globalState?.serviceUser?.online == 2 ? " 离开" : "未知",
                              style: themeData.textTheme.caption.copyWith(
                              fontSize: ToPx.size(22),
                              color: lineColor
                            ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Button(
                      useIosStyle: true,
                      width: ToPx.size(100),
                      onPressed: () {},
                      color: Colors.transparent,
                      child: Text(
                        "编辑资料",
                        style: themeData.textTheme.caption,
                      ),
                    ))
              ],
            ),
          ),
          Divider(
            height: 1.0,
            color: Colors.black12,
          ),
          Column(
            children: <Widget>[
              _listTile(
                  icon: Icons.home,
                  title: "工作台",
                  onTap: () => Navigator.pop(context)),
              _listTile(
                  icon: Icons.library_books,
                  title: "知识库",
                  onTap: () => Navigator.pop(context)),
              _listTile(
                  icon: Icons.android,
                  title: "机器人",
                  onTap: () => Navigator.pop(context)),
              _listTile(
                  icon: Icons.supervised_user_circle,
                  title: "客服管理",
                  onTap: () => Navigator.pop(context)),
              _listTile(
                  icon: Icons.supervisor_account,
                  title: "用户管理",
                  onTap: () => Navigator.pop(context)),
              _listTile(
                  icon: Icons.featured_play_list,
                  title: "服务记录",
                  onTap: () => Navigator.pop(context)),
              _listTile(
                  icon: Icons.assignment,
                  title: "快捷语设置",
                  onTap: () => Navigator.pop(context)),
              _listTile(
                  icon: Icons.settings,
                  title: "系统设置",
                  onTap: () => Navigator.pop(context)),
            ],
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Button(
                    margin: EdgeInsets.only(bottom: ToPx.size(50)),
                    color: Colors.grey,
                    width: ToPx.size(180),
                    height: ToPx.size(60),
                    onPressed: () => homeState.logout(context),
                    child: Text(
                      "退出登录",
                      style: themeData.textTheme.title
                          .copyWith(color: themeData.primaryColorLight),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
