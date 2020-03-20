import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:io';

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

  Future<String> uploadFile(
      {@required String bookId,
      @required int pageNumber,
      @required File file}) async {
    try {
      var uuid = new Uuid();
      String fileName = uuid.v1();
      final StorageUploadTask uploadTask = _storageReference
          .child('$bookId/$pageNumber/files/$fileName')
          .putFile(file);
      return await (await uploadTask.onComplete).ref.getDownloadURL();
    } catch (e) {
      print('Could not upload file');
      print(e);
      return null;
    }
  }

  deleteImageOrFile({@required String downloadUrl}) async {
    try {
      StorageReference reference =
          await FirebaseStorage().getReferenceFromUrl(downloadUrl);
      await reference.delete();
    } catch (e) {
      print('Could not delete file with downloadUrl = $downloadUrl');
      print(e);
    }
  }
}
