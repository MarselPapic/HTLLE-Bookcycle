import 'image_picker_bridge_stub.dart'
    if (dart.library.html) 'image_picker_bridge_web.dart' as impl;
import 'image_picker_types.dart';

Future<PickedImageData?> pickImageForUpload() {
  return impl.pickImageForUpload();
}
