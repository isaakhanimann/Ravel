import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ravel/models/book.dart';

class FirestoreService {
  final _fireStore = Firestore.instance;

  addBook({@required Book book}) async {
    try {
      await _fireStore.collection('books').add(book.toMap());
    } catch (e) {
      print('Could not add book = $book');
      print(e);
    }
  }

  deleteBook({@required Book book}) async {
    //the whole book has to be passed because firestore needs to verify that the owner is the loggedInUser
    try {
      await _fireStore.collection('books').document(book.bookId).delete();
    } catch (e) {
      print('Could not delete book = $book');
      print(e);
    }
  }

  updateBook({@required Book book}) async {
    //if the book should be added its bookId should be one that doesn't exist yet, e.g. null
    try {
      DocumentReference ref =
          _fireStore.collection('books').document(book.bookId);
      book.bookId = ref.documentID;
      await ref.setData(book.toMap(), merge: true);
    } catch (e) {
      print('Could not update book = $book');
      print(e);
    }
  }

  Stream<List<Book>> getStreamOfBooks({@required String uid}) {
    try {
      Stream<List<Book>> booksStream = _fireStore
          .collection('books')
          .where('ownerUid', isEqualTo: uid)
          .snapshots()
          .map((snap) => snap.documents
              .map((doc) => Book.fromMap(map: doc.data))
              .toList());
      return booksStream;
    } catch (e) {
      print('Could not get stream of books with uid = $uid');
      print(e);
      return null;
    }
  }
}
