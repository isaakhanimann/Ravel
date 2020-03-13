class Page {
  String text;
  String pageId;
  int pageNumber;
  List<String> imageNames;

  Page({
    this.text,
    this.pageId,
    this.pageNumber,
    this.imageNames,
  });

  Page.fromMap({Map<String, dynamic> map}) {
    this.text = map['text'];
    this.pageId = map['pageId'];
    this.pageNumber = map['pageNumber'];
    this.imageNames = map['imageNames'];
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'pageId': pageId,
      'pageNumber': pageNumber,
      'imageNames': imageNames,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ text: $text, ';
    toPrint += 'pageId: $pageId, ';
    toPrint += 'pageNumber: $pageNumber, ';
    toPrint += 'imageNames: $imageNames }\n';
    return toPrint;
  }
}
