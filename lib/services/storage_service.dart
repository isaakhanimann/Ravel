import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StorageService {
  final StorageReference _storageReference = FirebaseStorage().ref();

  Future<void> uploadImageForUser(
      {@required String uid,
      @required String fileName,
      @required File image}) async {
    try {
      final StorageUploadTask uploadTask =
          _storageReference.child('$uid/images/$fileName').putFile(image);
      await uploadTask.onComplete;
    } catch (e) {
      print('Could not upload image for user');
      print(e);
    }
  }

  Future<void> uploadImage(
      {@required String fileName, @required File image}) async {
    try {
      //the imagefilename and imageversionnumber of the user document is updated with cloud functions
      final StorageUploadTask uploadTask =
          _storageReference.child('images/$fileName').putFile(image);
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
