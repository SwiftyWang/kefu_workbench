import 'package:kefu_workbench/core_flutter.dart';

class KnowledgePage extends StatelessWidget {
  final Map<dynamic, dynamic> arguments;
  KnowledgePage({this.arguments});
  
  @override
  Widget build(_) {
    return PageContext(builder: (context){
      ThemeData themeData = Theme.of(context);
      return Scaffold(
        appBar: customAppBar(
            title: Text(
              "知识库列表",
              style: themeData.textTheme.display1,
            )),
        body: Text("TemplatePage"),
      );
    });
  }
}
