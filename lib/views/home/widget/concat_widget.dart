import 'package:flutter/gestures.dart';
import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/home.dart';
import 'package:provider/provider.dart';

class ConcatWidget extends StatelessWidget{
  ConcatWidget(this.concat);
  final ConcatModel concat;
  @override
  Widget build(BuildContext context) {
     ThemeData themeData = Theme.of(context);
     HomeProvide homeState = Provider.of<HomeProvide>(context);
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
              onTap: () => homeState.selectConcat(concat),
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
                              style: themeData.textTheme.caption
                                  .copyWith(
                                      color: Colors.white,
                                      fontSize: ToPx.size(20)),
                            ),
                          ),
                          width: ToPx.size(35),
                          height: ToPx.size(35),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle),
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
                : concat.lastMessageType ==
                "transfer"
                ? "客服转接..."
                : concat.lastMessageType ==
                "system"
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
}