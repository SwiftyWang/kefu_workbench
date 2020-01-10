import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/chat.dart';
import 'package:kefu_workbench/provider/global.dart';
import 'package:provider/provider.dart';

import 'widget/bottom_bar.dart';
import 'widget/emoji_panel.dart';
import 'widget/knowledge_message.dart';
import 'widget/photo_message.dart';
import 'widget/popup_menu.dart';
import 'widget/system_message.dart';
import 'widget/text_message.dart';
class ChatPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  ChatPage({this.arguments});
  @override
  ChatPageState createState() => ChatPageState();
}
class ChatPageState extends State<ChatPage> {

  /// 是否显示表情面板
  bool _isShowEmoJiPanel = false;

  /// 输入键盘相关
  FocusNode _focusNode = FocusNode();
  TextEditingController _editingController = TextEditingController();

  @override
  void initState(){

    super.initState();
  }


  _onHideEmoJiPanel(){

  }

  @override
  Widget build(_) {
    return Consumer<GlobalProvide>(
      builder: (context, globalState, _){
        return PageContext(builder: (context){
          ThemeData themeData = Theme.of(context);
          return Consumer<ChatProvide>(
            builder: (context, chatState , _){
              return Scaffold(
                appBar: customAppBar(
                  title: Text(
                    globalState.isPong ? "对方正在输入..." : "${globalState.currentContact?.nickname}",
                    style: themeData.textTheme.display1,
                  ),
                  actions: [
                    PopupMenu()
                  ]
                ),
                body: Column(children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onPanDown: (_) {
                        _onHideEmoJiPanel();
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: 
                      chatState.isChatFullLoading ?
                      Center(
                        child: loadingIcon(size: ToPx.size(50)),
                      ) :
                      CustomScrollView(
                        reverse: true,
                        slivers: <Widget>[
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 20.0),
                            sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((ctx, i) {
                              var currentUserMessagesRecords = globalState.currentUserMessagesRecords;
                                int index = currentUserMessagesRecords.length - i - 1;
                              ImMessageModel _msg = currentUserMessagesRecords[index];

                              /// 判断是否需要显示时间
                              if (i == currentUserMessagesRecords.length - 1 ||
                                  (_msg.timestamp - 120) >
                                      currentUserMessagesRecords[index - 1]
                                          .timestamp) {
                                _msg.isShowDate = true;
                              }

                              switch (_msg.bizType) {
                                case "text":
                                case "welcome":
                                  return TextMessage(
                                    message: _msg,
                                    isSelf: _msg.fromAccount == globalState.serviceUser.id,
                                    onCancel: () => {},
                                    onOperation: () => {},
                                  );
                                case "photo":
                                  return PhotoMessage(
                                    message: _msg,
                                    isSelf:
                                        _msg.fromAccount == globalState.serviceUser.id,
                                    onCancel: () =>  {},
                                    onOperation: () => {},
                                  );
                                case "end":
                                case "transfer":
                                case "cancel":
                                case "timeout":
                                case "system":
                                  return SystemMessage(
                                    message: _msg,
                                    isSelf:
                                        _msg.fromAccount == globalState.serviceUser.id,
                                  );
                                case "knowledge":
                                  return KnowledgeMessage(
                                    message: _msg,
                                    onSend: (msg) {},
                                  );
                                default:
                                  return SizedBox();
                              }
                            }, childCount: globalState.currentUserMessagesRecords.length)),
                          ),
                          SliverToBoxAdapter(
                            child: Offstage(
                              offstage: !chatState.isChatFullLoading,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Platform.isAndroid
                                        ? SizedBox(
                                            width: 10.0,
                                            height: 10.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                            ))
                                        : CupertinoActivityIndicator(),
                                    Text(
                                      "  加载更多",
                                      style: TextStyle(color: Colors.black38),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: SafeArea(
                      top: false,
                      child: Column(
                        children: <Widget>[
                          BottomBar(),
                          EmoJiPanel(),
                        ],
                      ),
                    ),
                  )
                ],)
              );
            },
          );
        });
      }
    );
  }
}
