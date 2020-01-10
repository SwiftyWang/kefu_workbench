import 'package:flutter/material.dart';
import 'package:kefu_workbench/models/index.dart';

class SystemMessage extends StatelessWidget {
  SystemMessage({this.message, this.isSelf});
  final ImMessageModel message;
  final bool isSelf;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Container(
        height: 23.0,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        constraints: BoxConstraints(
          minWidth: 200.0,
        ),
        alignment: Alignment.center,
        child: DefaultTextStyle(
            style: TextStyle(color: Colors.black38),
            child: Builder(builder: (_) {
              switch (message.bizType) {
                case "cancel":
                  return Text(isSelf ? "您撤回了一条消息" : "对方撤回了一条消息");
                case "end":
                  return Text(isSelf ? "你结束了会话" : "对方结束了会话");
                case "timeout":
                  return Text('用户长时间无应答，会话结束');
                case "system":
                case "transfer":
                  return Text('${message.payload}');
                default:
                  return SizedBox();
              }
            })),
      ),
    );
  }
}
