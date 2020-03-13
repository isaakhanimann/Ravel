import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String bookId;
  String ownerUid;
  String title;
  int numberOfPages;
  String content;
  GeoPoint location;
  String city;
  var whenCreated;

  Book(
      {this.bookId,
      this.ownerUid,
      this.title,
      this.numberOfPages = 3,
      this.content,
      this.location,
      this.city,
      this.whenCreated});

  Book.fromMap({Map<String, dynamic> map}) {
    this.bookId = map['bookId'];
    this.ownerUid = map['ownerUid'];
    this.title = map['title'];
    this.numberOfPages = map['numberOfPages'] ?? 3;
    this.content = map['content'];
    this.location = map['location'];
    this.city = map['city'];
    this.whenCreated = map['whenCreated']?.toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'ownerUid': ownerUid,
      'title': title,
      'numberOfPages': numberOfPages,
      'content': content,
      'location': location,
      'city': city,
      'whenCreated': whenCreated,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ bookId: $bookId, ';
    toPrint += 'ownerUid: $ownerUid, ';
    toPrint += 'title: $title, ';
    toPrint += 'numberOfPages: $numberOfPages, ';
    toPrint += 'content: $content, ';
    toPrint += 'location: $location, ';
    toPrint += 'city: $city, ';
    toPrint += 'whenCreated: $whenCreated }\n';
    return toPrint;
  }
}
