import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:ravel/models/page.dart';
import 'package:provider/provider.dart';
import 'package:ravel/services/firestore_service.dart';
import 'package:ravel/services/storage_service.dart';
import 'package:ravel/models/book.dart';
import 'package:ravel/services/file_picker_service.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

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
  List<Asset> images = []; //imageSection muss nur diese List erweitern

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
                  saveEverything: _saveEverything,
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

  _saveEverything() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    List<FileInfo> f
    for (Asset image in images) {
      String downloadUrl = await storageService.uploadImage(
          bookId: widget.book.bookId,
          pageNumber: widget.pageNumber,
          image: image);
      imageUrls.add(downloadUrl);
    }

    editedPage.imageInfos = FileInfo(downloadUrl: im);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    await firestoreService.updatePage(
        bookId: widget.book.bookId, page: editedPage);
  }
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
        ImagesSection(),
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
  Stream<List<FileInfo>> filesStream;

  @override
  void initState() {
    super.initState();
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    filesStream = firestoreService.getStreamOfFileInfos(
        bookId: bookId, pageNumber: pageNumber);
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
          stream: filesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return CupertinoActivityIndicator();
            }

            final List<FileInfo> files = snapshot.data;

            return Wrap(
              children: <Widget>[
                for (MyFile file in files)
                  CupertinoButton(
                    child: Text(file.filename),
                    onPressed: () {
                      //view file
                    },
                  ),
              ],
            );
          },
        )
      ],
    );
  }

  _onAddFilesPressed() async {
    final filePickerService =
        Provider.of<FilePickerService>(context, listen: false);
    List<File> filesPicked = await filePickerService.getFiles();
dddd
    setState(() {
      files = filesPicked;
    });
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
    //get images and save them in the state
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
