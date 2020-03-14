class Page {
  String text;
  int pageNumber;
  List<String> imageUrls;

  Page({
    this.text,
    this.pageNumber,
    this.imageUrls,
  });

  Page.fromMap({Map<String, dynamic> map}) {
    this.text = map['text'];
    this.pageNumber = map['pageNumber'];
    this.imageUrls = _convertFirebaseList(firebaseList: map['imageUrls']);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'pageNumber': pageNumber,
      'imageUrls': imageUrls,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ text: $text, ';
    toPrint += 'pageNumber: $pageNumber, ';
    toPrint += 'imageUrls: $imageUrls }\n';
    return toPrint;
  }

  List<String> _convertFirebaseList({List<dynamic> firebaseList}) {
    if (firebaseList == null) {
      return [];
    }
    List<String> list = [];
    for (var item in firebaseList) {
      list.add(item);
    }
    return list;
  }
}
