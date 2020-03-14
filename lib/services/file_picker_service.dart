import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FilePickerService {
  Future<List<MyFile>> getFiles() async {
    List<File> files = await FilePicker.getMultiFile(type: FileType.ANY);
    List<MyFile> myFiles = files.map((f) {
      String path = f.path;
      String fileName = path.toString().split('/').last;
      MyFile myFile = MyFile(file: f, filename: fileName);
      return myFile;
    }).toList();

    return myFiles;
  }
}

class MyFile {
  File file;
  String filename;

  MyFile({this.file, this.filename});
}
