import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class StorageService {
  final StorageReference _storageReference = FirebaseStorage().ref();

  Future<String> uploadImage(
      {@required String bookId,
      @required int pageNumber,
      @required Asset image}) async {
    try {
      ByteData byteData = await image.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      var uuid = new Uuid();
      String fileName = uuid.v1();
      final StorageUploadTask uploadTask = _storageReference
          .child('$bookId/$pageNumber/images/$fileName.png')
          .putData(imageData);
      return await (await uploadTask.onComplete).ref.getDownloadURL();
    } catch (e) {
      print('Could not upload image');
      print(e);
      return null;
    }
  }

  Future<String> getImageUrl({@required String fileName}) async {
    try {
      final String downloadUrl =
          await _storageReference.child('images/$fileName').getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Could not get image url');
      return null;
    }
  }
}
