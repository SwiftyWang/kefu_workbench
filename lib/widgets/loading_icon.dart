import '../core_flutter.dart';
Widget loadingIcon(){
  return SizedBox(
    width: ToPx.size(25),
    height: ToPx.size(25),
    child: Platform.isAndroid ?
    CircularProgressIndicator(
      strokeWidth: 2.0,
    ):
    CupertinoActivityIndicator(radius: ToPx.size(15),)
  );
}