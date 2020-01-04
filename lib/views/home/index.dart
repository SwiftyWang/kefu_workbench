import 'package:flutter/gestures.dart';
import 'package:kefu_workbench/core_flutter.dart';

class HomePage extends StatelessWidget {
  final Map<dynamic, dynamic> arguments;
  HomePage({this.arguments});

  void openDrawer(context){
    Scaffold.of(context).openDrawer();
  }
  
  @override
  Widget build(_) {
    return PageContext(builder: (context){
      ThemeData themeData = Theme.of(context);


      Widget _listItem(){
        return Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Dismissible(
              dragStartBehavior: DragStartBehavior.down,
              confirmDismiss: (DismissDirection direction) async{
                if(direction.index != 2) return false;
                return true;
              },
              secondaryBackground: Container(
                color:  Colors.red.withAlpha(200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(child: Icon(Icons.delete, color: Colors.white,), width: ToPx.size(150),),
                ],),
              ),
              background: Container(
                color: Colors.white,
              ),
              child: ListTile(
              onTap: (){},
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("访客165165", style: themeData.textTheme.title,),
                  Text("下午 12:00", style: themeData.textTheme.caption,),
                ],
              ),
              leading: SizedBox(
                width: ToPx.size(100),
                child: Stack(
                  children: <Widget>[
                    Avatar(
                      size: ToPx.size(90),
                      imgUrl: "http://qiniu.cmp520.com/avatar_default.png",
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                      child: Center(child: Text("1", style: themeData.textTheme.caption.copyWith(
                        color: Colors.white,
                        fontSize: ToPx.size(20)
                      ),),),
                      width: ToPx.size(35),
                      height: ToPx.size(35),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle
                      ),
                    ),
                    )
                  ],
                ),
              ),
              subtitle: Text("有什么办法水电费是水电费没水电费水电费", style: themeData.textTheme.body2, maxLines: 1, overflow: TextOverflow.ellipsis,),
            ), key: GlobalKey(),
            ),
            ),
            Divider(height: 1.0,)
          ],
        );
      }


      return Scaffold(
        appBar: customAppBar(
            leading: Avatar(
              onPressed: () => openDrawer(context),
              size: ToPx.size(60),
              imgUrl: "http://qiniu.cmp520.com/avatar_default.png",
            ),
            title: Text(
              "工作台",
              style: themeData.textTheme.display1,
            )),
        body: CustomScrollView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[

             sliverRefreshControl(
                onRefresh: () async {
                  await Future.delayed(Duration(milliseconds: 5000));
                  return true;
                },
              ),

            SliverList(
              delegate: SliverChildBuilderDelegate((context, index){
                return _listItem();
              })
            )

          ],
        ),
        drawer: Drawer(
          child: Container(
            color: themeData.primaryColor,
            child: Text("Drawer"),
          ),
        ),
      );
    });
  }
}

class SliverChildListBuildrDelegate {
}
