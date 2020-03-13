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
    this.imageNames = map['imageNames'];
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
}
