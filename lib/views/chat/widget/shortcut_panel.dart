import 'package:flutter/material.dart';
import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/utils//index.dart';
class ShortcutPanel extends StatelessWidget{
  ShortcutPanel({
    this.isShowShortcutPanel,
    this.shortcuts,
    this.onSelectedShortcut
  });
  final bool isShowShortcutPanel;
  final List<ShortcutModel> shortcuts;
  final ValueChanged<String> onSelectedShortcut;
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Offstage(
      offstage: !isShowShortcutPanel,
      child: Container(
      width: double.infinity,
      height: ToPx.size(500),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1.0, color: themeData.dividerColor))
      ),
      child: ListView.builder(
        itemCount: shortcuts.length,
        itemBuilder: (context, index){
          return Column(
            children: <Widget>[
              Button(
                alignment: Alignment.centerLeft,
                radius: 0.0,
                height: ToPx.size(135),
                padding: EdgeInsets.symmetric(horizontal: ToPx.size(20)),
                color: Colors.white,
                withAlpha: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("${shortcuts[index].title}", style: themeData.textTheme.body1, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    Text("${shortcuts[index].content}", style: themeData.textTheme.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                onPressed: () => onSelectedShortcut(shortcuts[index].content),
              ),
              Divider(height: 1.0,)
            ],
          );
        }
      ),
    ),
    );
  }
}