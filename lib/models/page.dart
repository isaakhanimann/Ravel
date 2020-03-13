class Page {
  String text;
  int pageNumber;
  List<String> imageNames;

  Page({
    this.text,
    this.pageNumber,
    this.imageNames,
  });

  Page.fromMap({Map<String, dynamic> map}) {
    this.text = map['text'];
    this.pageNumber = map['pageNumber'];
    this.imageNames = _convertFirebaseList(firebaseList: map['imageNames']);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'pageNumber': pageNumber,
      'imageNames': imageNames,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ text: $text, ';
    toPrint += 'pageNumber: $pageNumber, ';
    toPrint += 'imageNames: $imageNames }\n';
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
