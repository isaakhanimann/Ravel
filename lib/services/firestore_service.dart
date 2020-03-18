import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ravel/models/book.dart';
import 'package:ravel/models/page.dart';

class FirestoreService {
  final _fireStore = Firestore.instance;

  addBookWithPages({@required Book book}) async {
    try {
      DocumentReference ref = _fireStore
          .collection('books')
          .document(null); //if the books id is null its added
      book.bookId = ref.documentID;
      await ref.setData(book.toMap(), merge: true);
      for (int i = 0; i < book.numberOfPages; i++) {
        DateTime date = book.fromDate.add(Duration(days: i));
        Page page =
            Page(text: '', pageNumber: i + 1, imageInfos: [], date: date);
        _addPage(bookId: book.bookId, page: page);
      }
    } catch (e) {
      print('Could not add book = $book with pages');
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

  deleteBook({@required Book book}) async {
    //the whole book has to be passed because firestore needs to verify that the owner is the loggedInUser
    try {
      await _fireStore.collection('books').document(book.bookId).delete();
    } catch (e) {
      print('Could not delete book = $book');
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

  updatePage({@required String bookId, @required Page page}) async {
    try {
      DocumentReference ref =
          _fireStore.document('books/$bookId/pages/${page.pageNumber}');
      await ref.setData(page.toMap(), merge: true);
    } catch (e) {
      print('Could not upload page');
      print(e);
    }
  }

  Future<Page> getPage(
      {@required String bookId, @required int pageNumber}) async {
    try {
      DocumentSnapshot document = await _fireStore
          .document('books/$bookId/pages/' + pageNumber.toString())
          .get();
      Page page = Page.fromMap(map: document.data);
      return page;
    } catch (e) {
      print('Could not get page');
      print(e);
      return null;
    }
  }

  Stream<Page> getStreamOfPage(
      {@required String bookId, @required int pageNumber}) {
    try {
      Stream<Page> pageStream = _fireStore
          .document('books/$bookId')
          .collection('pages')
          .where('pageNumber', isEqualTo: pageNumber)
          .snapshots()
          .map((snap) => Page.fromMap(map: snap.documents[0]?.data));
      return pageStream;
    } catch (e) {
      print(
          'Could not get stream of page with bookId = $bookId and pageNumber = $pageNumber');
      print(e);
      return null;
    }
  }

  Stream<List<FileInfo>> getStreamOfFileInfos(
      {@required String bookId, @required int pageNumber}) {
    try {
      Stream<Page> pageStream =
          getStreamOfPage(bookId: bookId, pageNumber: pageNumber);
      Stream<List<FileInfo>> filesStream =
          pageStream.map((page) => page.fileInfos).distinct();
      return filesStream;
    } catch (e) {
      print(
          'Could not get stream of fileinfos with bookId = $bookId and pageNumber = $pageNumber');
      print(e);
      return null;
    }
  }

  Stream<List<FileInfo>> getStreamOfImageInfos(
      {@required String bookId, @required int pageNumber}) {
    try {
      Stream<Page> pageStream =
          getStreamOfPage(bookId: bookId, pageNumber: pageNumber);
      Stream<List<FileInfo>> imagesStream =
          pageStream.map((page) => page.imageInfos).distinct();
      return imagesStream;
    } catch (e) {
      print(
          'Could not get stream of imageInfo with bookId = $bookId and pageNumber = $pageNumber');
      print(e);
      return null;
    }
  }

  updateFileInfos(
      {@required String bookId,
      @required int pageNumber,
      @required List<FileInfo> fileInfos}) async {
    try {
      DocumentReference ref =
          _fireStore.document('books/$bookId/pages/$pageNumber');
      await ref.updateData(
          {'fileInfos': fileInfos?.map((FileInfo f) => f.toMap())?.toList()});
    } catch (e) {
      print('Could not update fileInfos');
      print(e);
    }
  }

  updateImageInfos(
      {@required String bookId,
      @required int pageNumber,
      @required List<FileInfo> imageInfos}) async {
    try {
      DocumentReference ref =
          _fireStore.document('books/$bookId/pages/$pageNumber');
      await ref.updateData(
          {'imageInfos': imageInfos?.map((FileInfo i) => i.toMap())?.toList()});
    } catch (e) {
      print('Could not update imageInfos');
      print(e);
    }
  }

  updatePageText(
      {@required String bookId,
      @required int pageNumber,
      @required String text}) async {
    try {
      DocumentReference ref =
          _fireStore.document('books/$bookId/pages/$pageNumber');
      await ref.updateData({'text': text});
    } catch (e) {
      print('Could not update page text');
      print(e);
    }
  }

  _addPage({@required String bookId, @required Page page}) async {
    try {
      DocumentReference ref = _fireStore
          .document('books/$bookId/pages/' + page.pageNumber.toString());
      Map<String, dynamic> map = page.toMap();
      await ref.setData(map, merge: true);
    } catch (e) {
      print('Could not add page');
      print(e);
    }
  }
}
