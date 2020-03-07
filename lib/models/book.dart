import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String bookId;
  String title;
  String content;
  GeoPoint location;
  var whenCreated;

  Book({this.title, this.content, this.location, this.whenCreated});

  Book.fromMap({Map<String, dynamic> map}) {
    this.bookId = map['bookId'];
    this.title = map['title'];
    this.content = map['content'];
    this.location = map['location'];
    this.whenCreated = map['whenCreated']?.toDate() ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'content': content,
      'location': location,
      'whenCreated': whenCreated,
    };
  }
}
