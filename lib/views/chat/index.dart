import 'package:kefu_workbench/core_flutter.dart';

class ChatPage extends StatefulWidget{
  ChatPage({this.arguments});
  final Map<dynamic, dynamic> arguments;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>{
  @override
  Widget build(BuildContext context) {
    print("_ChatPageState==${widget.arguments['index']}");
    return Scaffold(
      body:Center(
        child: Button(
          width: ToPx.size(200),
          onPressed: (){
            Navigator.pop(context);
          },
          child: Text("back"),
        ),
      ),
    );
  }
}