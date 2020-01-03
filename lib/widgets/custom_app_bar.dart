import '../core_flutter.dart';
PreferredSize customAppBar({
  Widget title,
  leading,
  Color backgroundColor = Colors.white,
  double elevation,
  List<Widget> actions,
  PreferredSizeWidget bottom,
  bool isShowLeading = true,
  Brightness brightness = Brightness.light,
  double size
}){
  return PreferredSize(
    preferredSize: Size(double.infinity, size ?? ToPx.size(120)),
    child: AppBar(
      automaticallyImplyLeading: isShowLeading,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: true,
      title: title,
      actions: actions,
      brightness: brightness,
      leading: isShowLeading ? leading == null ? CustomBackButton() : leading : null,
      bottom: bottom,
    )
  );
}

class CustomBackButton extends StatelessWidget{
  CustomBackButton({this.color = Colors.black54});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Button(
      width: ToPx.size(120),
      useIosStyle: true,
      color: Colors.transparent,
      onPressed: () => Navigator.pop(context),
      child: Icon(IconData(0xe600, fontFamily: 'IconFont'),size: ToPx.size(50), color: color,),
    );
  }

}