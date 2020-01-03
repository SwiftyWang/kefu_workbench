import 'package:kefu_workbench/core_flutter.dart';

class HomePage extends StatefulWidget{
  HomePage({this.arguments});
  final Map<dynamic, dynamic> arguments;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: Button(
          width: ToPx.size(200),
          onPressed: (){
            Navigator.pushNamed(context, '/chat', arguments: {"index": 123});
          },
          child: Text("go chat"),
        ),
      ),
    );
  }
}