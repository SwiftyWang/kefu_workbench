 import 'package:image_picker/image_picker.dart';
import 'package:kefu_workbench/core_flutter.dart';
import 'package:kefu_workbench/provider/global.dart';
import 'package:kefu_workbench/utils//permission.dart';

/// 选择图片上传
  Future<T> uploadImage<T>(BuildContext context, {double maxWidth = 2000}) async{
    ImageSource imageSource = await UX.selectImageSheet(context);
    if(imageSource == null){
       return null;
    }
    if(imageSource == ImageSource.camera && !await checkPermission(context, permissionGroupType: PermissionGroup.camera)){
      UX.showToast("未授权使用相机！");
      return null;
    }
    if(Platform.isAndroid && imageSource == ImageSource.gallery && !await checkPermission(context, permissionGroupType: PermissionGroup.storage)){
      UX.showToast("未授权使用相册！");
       return null;
    }
    if(Platform.isIOS && imageSource == ImageSource.gallery && !await checkPermission(context, permissionGroupType: PermissionGroup.photos)){
      UX.showToast("未授权使用相册！");
      return null;
    }
    File _file = await ImagePicker.pickImage(source: imageSource, maxWidth: maxWidth);
    if(_file == null){
       return null;
    }
    if(T == String){
      String imgUser = await GlobalProvide.getInstance().uploadImage(_file);
      if(imgUser != null && imgUser.isNotEmpty){
        return (imgUser as T);
      }else{
        UX.showToast("上传失败了，请重新尝试");
        return null;
      }
    }else{
      return (_file as T);
    }
  }