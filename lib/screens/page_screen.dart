import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:ravel/models/page.dart';
import 'package:provider/provider.dart';
import 'package:ravel/services/firestore_service.dart';
import 'package:ravel/services/storage_service.dart';
import 'package:ravel/models/book.dart';
import 'package:ravel/services/file_picker_service.dart';
import 'dart:io';
//import 'package:url_launcher/url_launcher.dart';

class PageScreen extends StatefulWidget {
  final Book book;
  final int pageNumber;

  PageScreen({@required this.book, @required this.pageNumber});
  @override
  _PageScreenState createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  Future<Page> futurePage;
  Page editedPage;

  @override
  void initState() {
    super.initState();
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    futurePage = firestoreService.getPage(
        bookId: widget.book.bookId, pageNumber: widget.pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Book>.value(
          value: widget.book,
        ),
        Provider<int>.value(
          value: widget.pageNumber,
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Header(
                  pageNumber: widget.pageNumber,
                  saveEverything: _saveText,
                ),
                Expanded(
                  child: FutureBuilder(
                    future: futurePage,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return CupertinoActivityIndicator();
                      }
                      if (snapshot.hasError) {
                        return Container(
                          color: Colors.red,
                          child: const Text('Something went wrong'),
                        );
                      }
                      editedPage = snapshot.data;

                      return Provider<Page>.value(
                          value: editedPage, child: PageBody());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _saveText() async {}
}

class PageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Page page = Provider.of<Page>(context);
    return Column(
      children: <Widget>[
        PageText(initialText: page.text),
        Expanded(
          child: Container(
            color: Colors.green,
          ),
        ),
        FilesSection(),
//        ImagesSection(),
      ],
    );
  }
}

class PageText extends StatefulWidget {
  final String initialText;

  PageText({@required this.initialText});

  @override
  _PageTextState createState() => _PageTextState();
}

class _PageTextState extends State<PageText> {
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _textEditingController,
      decoration: BoxDecoration(border: null),
      style: TextStyle(fontSize: 15, fontFamily: 'OpenSansRegular'),
      autofocus: true,
      maxLines: 10,
      minLines: 1,
    );
  }
}

class FilesSection extends StatefulWidget {
  @override
  _FilesSectionState createState() => _FilesSectionState();
}

class _FilesSectionState extends State<FilesSection> {
  Stream<Page> pageStream;
  List<FileInfo> fileInfos;

  @override
  void initState() {
    super.initState();
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final book = Provider.of<Book>(context, listen: false);
    final pageNumber = Provider.of<int>(context, listen: false);
    pageStream = firestoreService.getStreamOfPage(
        bookId: book.bookId, pageNumber: pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CupertinoButton(
          child: Text('Add Files'),
          onPressed: _onAddFilesPressed,
        ),
        StreamBuilder(
          stream: pageStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return CupertinoActivityIndicator();
            }

            if (snapshot.hasError) {
              return Text('the error is = ${snapshot.error.toString()}');
            }

            Page page = snapshot.data;

            return Container(
              color: Colors.purple,
              height: 30,
              width: 30,
            );

//            return Wrap(
//              children: <Widget>[
//                for (FileInfo fileInfo in fileInfos)
//                  CupertinoButton(
//                    child: Text(fileInfo.fileName),
//                    onPressed: () {
//                      //todo view file
//                    },
//                  ),
//              ],
//            );
          },
        )
      ],
    );
  }

  _onAddFilesPressed() async {
    //get the files
    final filePickerService =
        Provider.of<FilePickerService>(context, listen: false);
    List<File> filesPicked = await filePickerService.getFiles();
    //upload them to storage
    final storageService = Provider.of<StorageService>(context, listen: false);
    final book = Provider.of<Book>(context, listen: false);
    final pageNumber = Provider.of<int>(context, listen: false);
    for (File file in filesPicked) {
      String downloadUrl = await storageService.uploadFile(
          bookId: book.bookId, pageNumber: pageNumber, file: file);
      fileInfos.add(FileInfo.fromFile(file: file, downloadUrl: downloadUrl));
    }
    //update the pages fileInfos
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    firestoreService.updateFileInfos(
        bookId: book.bookId, pageNumber: pageNumber, fileInfos: fileInfos);
  }
}

class ImagesSection extends StatefulWidget {
  @override
  _ImagesSectionState createState() => _ImagesSectionState();
}

class _ImagesSectionState extends State<ImagesSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CupertinoButton(
          child: Text('Add Image'),
          onPressed: _onAddButtonPressed,
        ),
        SizedBox(
          height: 120,
          child: Wrap(
            children: <Widget>[
              Container(
                color: Colors.blue,
                height: 60,
                width: 60,
              ),
              Container(
                color: Colors.yellow,
                height: 60,
                width: 60,
              ),
              Container(
                color: Colors.green,
                height: 60,
                width: 60,
              ),
              Container(
                color: Colors.brown,
                height: 60,
                width: 60,
              ),
              Container(
                color: Colors.red,
                height: 60,
                width: 60,
              ),
              Container(
                color: Colors.pink,
                height: 60,
                width: 60,
              ),
              Container(
                color: Colors.purple,
                height: 60,
                width: 60,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _onAddButtonPressed() async {
    //todo get images with multifile picker
    //List<Asset> images = [];

//    //add the image infos to the ones that are already there
//    final storageService = Provider.of<StorageService>(context, listen: false);
//    List<FileInfo> imageInfos = herewritetheimageInfosThat are here;
//    for (Asset image in images) {
//      String downloadUrl = await storageService.uploadImage(
//          bookId: widget.book.bookId,
//          pageNumber: widget.pageNumber,
//          image: image);
//      imageInfos.add(FileInfo(downloadUrl: downloadUrl));
//    }
//    //upload the picked images without overriding the old image infos
//    final firestoreService =
//    Provider.of<FirestoreService>(context, listen: false);
//    await firestoreService.addImageInfos(
//        bookId: widget.book.bookId, pageNumber: pageNumber, imageInfos:oldImageInfos + newImageInfos);
  }
}

class Header extends StatelessWidget {
  final int pageNumber;
  final Function saveEverything;

  Header({@required this.pageNumber, @required this.saveEverything});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Text(
          'Day $pageNumber',
          style: TextStyle(fontSize: 40, fontFamily: 'CatamaranBold'),
        ),
        Positioned(
          right: 10,
          child:
              CupertinoButton(child: Text('Save'), onPressed: saveEverything),
        ),
      ],
    );
  }
}
