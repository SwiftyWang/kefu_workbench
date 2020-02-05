import 'package:kefu_workbench/core_flutter.dart';
class StatisticalPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  StatisticalPage({this.arguments});
  @override
  State<StatefulWidget> createState() {
    return _StatisticalPage();
  }
}
class _StatisticalPage extends State<StatisticalPage> {
  
  @override
  Widget build(_) {
    return PageContext(builder: (context){
      ThemeData themeData = Theme.of(context);
      
      return Scaffold(
        appBar: customAppBar(
            title: Text(
              "统计",
              style: themeData.textTheme.display1,
            )),
        body:CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
            )

          ],
        ),
      );
    });
  }
}
