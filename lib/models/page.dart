import 'dart:io';

class Page {
  String text;
  int pageNumber;
  DateTime date;
  List<FileInfo> fileInfos;
  List<FileInfo> imageInfos;

  Page({
    this.text,
    this.pageNumber,
    this.date,
    this.fileInfos,
    this.imageInfos,
  });

  Page.fromMap({Map<String, dynamic> map}) {
    this.text = map['text'];
    this.pageNumber = map['pageNumber'];
    this.date = map['date']?.toDate();
    this.fileInfos =
        _convertFirebaseListOfFileInfos(firebaseList: map['fileInfos']);
    this.imageInfos =
        _convertFirebaseListOfFileInfos(firebaseList: map['imageInfos']);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'pageNumber': pageNumber,
      'date': date,
      'fileInfos': fileInfos?.map((FileInfo f) => f.toMap())?.toList(),
      'imageInfos': imageInfos?.map((FileInfo i) => i.toMap())?.toList(),
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ text: $text, ';
    toPrint += 'pageNumber: $pageNumber, ';
    toPrint += 'date: $date, ';
    toPrint += 'fileInfos: $fileInfos, ';
    toPrint += 'imageInfos: $imageInfos }\n';
    return toPrint;
  }

  static List<FileInfo> _convertFirebaseListOfFileInfos(
      {List<dynamic> firebaseList}) {
    if (firebaseList == null) {
      return [];
    }
    List<FileInfo> files =
        firebaseList.map((d) => FileInfo.fromMap(map: d)).toList();
    return files;
  }
}

class FileInfo {
  String fileName;
  String downloadUrl;

  FileInfo({
    this.fileName,
    this.downloadUrl,
  });

  FileInfo.fromMap({Map<String, dynamic> map}) {
    this.fileName = map['fileName'];
    this.downloadUrl = map['downloadUrl'];
  }

  FileInfo.fromFile({File file, String downloadUrl}) {
    String path = file.path;
    String fileName = path.toString().split('/').last;
    this.fileName = fileName;
    this.downloadUrl = downloadUrl;
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'downloadUrl': downloadUrl,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ fileName: $fileName, ';
    toPrint += 'downloadUrl: $downloadUrl }\n';
    return toPrint;
  }
}
