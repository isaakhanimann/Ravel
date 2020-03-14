import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:ravel/models/page.dart';
import 'package:provider/provider.dart';
import 'package:ravel/services/firestore_service.dart';
import 'package:ravel/services/storage_service.dart';
import 'package:ravel/models/book.dart';
import 'dart:io';
import 'package:ravel/services/file_picker_service.dart';

class BookPageScreen extends StatefulWidget {
  final Book book;
  final int pageNumber;

  BookPageScreen({@required this.book, @required this.pageNumber});
  @override
  _BookPageScreenState createState() => _BookPageScreenState();
}

class _BookPageScreenState extends State<BookPageScreen> {
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
    return Scaffold(
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
    );
  }

  _saveEverything() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    List<String> imageUrls = [];
    for (var image in images) {
      String downloadUrl = await storageService.uploadImage(
          bookId: widget.book.bookId,
          pageNumber: widget.pageNumber,
          image: image);
      imageUrls.add(downloadUrl);
    }

    editedPage.imageUrls = imageUrls;
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
  List<File> files = [];

  @override
  Widget build(BuildContext context) {
    print(files);
    return Column(
      children: <Widget>[
        CupertinoButton(
          child: Text('Add Files'),
          onPressed: _onAddFilesPressed,
        ),
      ],
    );
  }

  _onAddFilesPressed() async {
    final filePickerService =
        Provider.of<FilePickerService>(context, listen: false);
    List<File> filesPicked = await filePickerService.getFiles();
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
