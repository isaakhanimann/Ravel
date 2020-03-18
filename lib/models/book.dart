import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String bookId;
  String ownerUid;
  String title = '';
  int numberOfPages = 3;
  String content = '';
  GeoPoint location;
  String city = '';
  DateTime fromDate;
  DateTime toDate;
  var whenCreated;

  Book(
      {this.bookId,
      this.ownerUid,
      this.title,
      this.numberOfPages,
      this.content,
      this.location,
      this.city,
      this.fromDate,
      this.toDate,
      this.whenCreated});

  Book.fromMap({Map<String, dynamic> map}) {
    this.bookId = map['bookId'];
    this.ownerUid = map['ownerUid'];
    this.title = map['title'];
    this.numberOfPages = map['numberOfPages'] ?? 3;
    this.content = map['content'];
    this.location = map['location'];
    this.city = map['city'];
    this.fromDate = map['fromDate']?.toDate();
    this.toDate = map['toDate']?.toDate();
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
      'fromDate': fromDate,
      'toDate': toDate,
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
    toPrint += 'fromDate: $fromDate, ';
    toPrint += 'toDate: $toDate, ';
    toPrint += 'whenCreated: $whenCreated }\n';
    return toPrint;
  }
}
