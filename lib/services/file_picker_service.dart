import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FilePickerService {
  Future<List<File>> getFiles() async {
    List<File> files = await FilePicker.getMultiFile(type: FileType.ANY);
    return files;
  }
}
