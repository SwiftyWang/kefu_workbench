import '../core_flutter.dart';
Widget loadingIcon(){
  return SizedBox(
    width: ToPx.size(35),
    height: ToPx.size(35),
    child: Platform.isAndroid ?
    CircularProgressIndicator(
      strokeWidth: 2.0,
    ):
    CupertinoActivityIndicator(radius: ToPx.size(22),)
  );
}