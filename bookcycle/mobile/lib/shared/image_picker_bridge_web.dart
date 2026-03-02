// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'image_picker_types.dart';

Future<PickedImageData?> pickImageForUpload() async {
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.click();

  await input.onChange.first;
  if (input.files == null || input.files!.isEmpty) {
    return null;
  }

  final file = input.files!.first;
  final reader = html.FileReader();
  final completer = Completer<PickedImageData?>();

  reader.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  });

  reader.onLoadEnd.listen((_) {
    final bytes = _extractBytes(reader.result);
    if (bytes != null && !completer.isCompleted) {
      completer.complete(
        PickedImageData(
          bytes: bytes,
          fileName: file.name,
        ),
      );
      return;
    }
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  });

  reader.readAsArrayBuffer(file);
  return completer.future;
}

Uint8List? _extractBytes(Object? value) {
  if (value is ByteBuffer) {
    return Uint8List.view(value);
  }
  if (value is Uint8List) {
    return value;
  }
  if (value is ByteData) {
    return value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes);
  }
  return null;
}
