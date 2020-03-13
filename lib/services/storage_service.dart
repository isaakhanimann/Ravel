import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StorageService {
  final StorageReference _storageReference = FirebaseStorage().ref();

  Future<void> uploadImage(
      {@required String bookId,
      @required int pageNumber,
      @required String fileName,
      @required List<int> image}) async {
    try {
      final StorageUploadTask uploadTask = _storageReference
          .child('$bookId/$pageNumber/images/$fileName')
          .putData(image);
      await uploadTask.onComplete;
    } catch (e) {
      print('Could not upload image');
      print(e);
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
