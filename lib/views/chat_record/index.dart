import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/chat_record.dart';
import 'package:kefu_workbench/provider/global.dart';
import 'package:provider/provider.dart';

import 'widget/popup_button.dart';

class ChatReCordPage extends StatelessWidget {
  final Map<dynamic, dynamic> arguments;
  ChatReCordPage({this.arguments});

  @override
  Widget build(_) {
    return ChangeNotifierProvider<ChatReCordProvide>(
      create: (_) => ChatReCordProvide.getInstance(),
      child: Consumer<ChatReCordProvide>(builder: (context, chatReCordState, _){
         return PageContext(builder: (context){
            ThemeData themeData = Theme.of(context);
            return Scaffold(
              backgroundColor: themeData.primaryColorLight,
              appBar: customAppBar(
                  title: Text(
                    "服务记录",
                    style: themeData.textTheme.display1,
                  ),
                  actions: [
                    PopupButton()
                  ],
                ),
              body: chatReCordState.isLoading && chatReCordState.admins.length == 0 ? Center(
                child: loadingIcon(size: ToPx.size(50)),
              ): 
              RefreshIndicator(
                color: themeData.primaryColorLight,
                backgroundColor: themeData.primaryColor,
                onRefresh: chatReCordState.onRefresh,
                child: CustomScrollView(
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(),
                controller: chatReCordState.scrollController,
                slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: ToPx.size(20)),
                        child: Row(children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => chatReCordState.onSelectDate(context),
                          child: Row(
                            children: [
                              Text("选择时间：", style: themeData.textTheme.title,),
                              Text("${chatReCordState.date ?? '今天'} ", style: themeData.textTheme.title,),
                              Icon(Icons.touch_app, size: ToPx.size(40), color: themeData.textTheme.body1.color)
                            ]
                          )
                        ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("去重：", style: themeData.textTheme.title,),
                            Platform.isAndroid
                          ? Switch(
                              value: chatReCordState.isDeWeighting,
                              onChanged: (bool isSwitch) => chatReCordState.setDeWeighting(isSwitch),
                              activeColor: Colors.black)
                          : Transform.scale(
                              scale: .7,
                              child: CupertinoSwitch(
                              value: chatReCordState.isDeWeighting,
                              onChanged: (bool isSwitch) => chatReCordState.setDeWeighting(isSwitch),
                              activeColor: Colors.black))
                          ],
                        ),
                      ],)
                      )
                    ),
                    SliverToBoxAdapter(
                      child: Divider(),
                    ),
                    SliverToBoxAdapter(
                      child: Offstage(
                        offstage: chatReCordState.total == 0,
                        child: Padding(
                        padding: EdgeInsets.symmetric(vertical: ToPx.size(5)),
                        child: Text("当天总服务人次（${chatReCordState.total}人）", style: themeData.textTheme.caption, textAlign: TextAlign.center,)
                      )
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Offstage(
                        offstage: chatReCordState.servicesStatisticals.length > 0 || chatReCordState.isLoading,
                        child: Padding(
                          padding: EdgeInsets.only(top: ToPx.size(50)),
                          child: Text("暂无数据~", style: themeData.textTheme.body1, textAlign: TextAlign.center,),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index){
                        ServicesStatisticalModel _servicesStatistical = chatReCordState.servicesStatisticals[index];
                        return Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () => Navigator.pushNamed(context, "/chat",arguments: {
                                "isReadOnly": true,
                                "accountId": int.parse(_servicesStatistical.userAccount),
                                "serviceId": chatReCordState.selectedAdmin.id,
                                "title": "${chatReCordState.selectedAdmin.nickname} 与 ${_servicesStatistical.nickname} 的聊天记录",
                              }),
                              subtitle: Row(
                                children: <Widget>[
                                  Text("平台：", style: themeData.textTheme.caption),
                                  Text("${GlobalProvide.getInstance().getPlatformTitle(int.parse(_servicesStatistical.platform))}")
                                ],
                              ),
                              trailing: Text("${Utils.epocFormat(int.parse(_servicesStatistical.createAt))}",
                                style: themeData.textTheme.caption.copyWith(
                                fontSize: ToPx.size(22),
                              ),),
                              title: Text("${_servicesStatistical.nickname}", style: themeData.textTheme.title, maxLines: 2, overflow: TextOverflow.ellipsis,),
                            ),
                            Divider(height: 1.0,)
                          ],
                        );
                      },
                      childCount: chatReCordState.servicesStatisticals.length
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
                        offstage: !chatReCordState.isLoading || chatReCordState.isLoadEnd
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
                        offstage: !chatReCordState.isLoadEnd || chatReCordState.servicesStatisticals.length == 0
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


