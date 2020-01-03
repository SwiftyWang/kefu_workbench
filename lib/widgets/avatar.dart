
import '../core_flutter.dart';

class Avatar extends StatelessWidget{
  Avatar({this.size, this.onPressed, this.imgUrl});
  final double size;
  final VoidCallback onPressed;
  final String imgUrl;
  @override
  Widget build(BuildContext context) {
    if(imgUrl == null) return Container();
    return Button(
      width: size == null ? ToPx.size(135) : size,
      height:  size == null ? ToPx.size(135) : size,
      color: Colors.transparent,
      disabledColor: Colors.transparent,
      onPressed: onPressed,
      child: ClipOval(
        child: SizedBox(
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            src: imgUrl,
          ),
        ),
      ),
    );
  }
}