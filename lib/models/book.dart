import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String bookId;
  String ownerUid;
  String title;
  String content;
  GeoPoint location;
  var whenCreated;

  Book(
      {this.bookId,
      this.ownerUid,
      this.title,
      this.content,
      this.location,
      this.whenCreated});

  Book.fromMap({Map<String, dynamic> map}) {
    this.bookId = map['bookId'];
    this.ownerUid = map['ownerUid'];
    this.title = map['title'];
    this.content = map['content'];
    this.location = map['location'];
    this.whenCreated = map['whenCreated']?.toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'ownerUid': ownerUid,
      'title': title,
      'content': content,
      'location': location,
      'whenCreated': whenCreated,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ bookId: $bookId, ';
    toPrint += 'ownerUid: $ownerUid, ';
    toPrint += 'title: $title, ';
    toPrint += 'content: $content, ';
    toPrint += 'location: $location, ';
    toPrint += 'whenCreated: $whenCreated }\n';
    return toPrint;
  }
}
