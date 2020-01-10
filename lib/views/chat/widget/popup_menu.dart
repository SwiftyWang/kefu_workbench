import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/global.dart';
import 'package:provider/provider.dart';

class PopupMenu extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return Consumer<GlobalProvide>(
      builder: (context, globalState, _){
        ThemeData themeData = Theme.of(context);
        GlobalProvide  globalState = Provider.of<GlobalProvide>(context);
        Color lineColor = globalState?.serviceUser?.online == 1  ? Colors.green[400] :
                    globalState?.serviceUser?.online == 0 ? Colors.grey :
                    globalState?.serviceUser?.online == 2 ? Colors.amber : Colors.grey;
        return PopupMenuButton<int>(
        onSelected: (int status) =>
            globalState?.setOnline(online: status),
        child: Align(
          child: Container(
              width: ToPx.size(80),
              height: ToPx.size(40),
              child: Icon(Icons.more_vert)
          ),
        ),
        itemBuilder: (BuildContext context) {
          List<PopupMenuEntry<int>> menus = [
            PopupMenuItem<int>(
              value: 0,
              child: Text(
                '转接客服',
                style: themeData.textTheme.title.copyWith(
                    color: themeData.primaryColorLight
                ),
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: Text(
                '结束会话',
                style: themeData.textTheme.title.copyWith(
                    color: Colors.amber),
              ),
            )
          ];
          return menus;
        });
        
      }
    );

  }
}