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
import 'package:ravel/services/multi_image_picker_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  Stream<List<FileInfo>> fileInfosStream;
  List<FileInfo> fileInfos;

  @override
  void initState() {
    super.initState();
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final book = Provider.of<Book>(context, listen: false);
    final pageNumber = Provider.of<int>(context, listen: false);
    fileInfosStream = firestoreService.getStreamOfFileInfos(
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
          stream: fileInfosStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return CupertinoActivityIndicator();
            }

            fileInfos = snapshot.data;

            return Wrap(
              children: <Widget>[
                for (FileInfo fileInfo in fileInfos)
                  CupertinoButton(
                    child: Text(fileInfo.fileName),
                    onPressed: () {
                      //view file
                      _launchURL(url: fileInfo.downloadUrl);
                    },
                  ),
              ],
            );
          },
        )
      ],
    );
  }

  _launchURL({@required String url}) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
  Stream<List<FileInfo>> imageInfoStream;
  List<FileInfo> imageInfos;

  @override
  void initState() {
    super.initState();
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final book = Provider.of<Book>(context, listen: false);
    final pageNumber = Provider.of<int>(context, listen: false);
    imageInfoStream = firestoreService.getStreamOfImageInfos(
        bookId: book.bookId, pageNumber: pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CupertinoButton(
          child: Text('Add Image'),
          onPressed: () {
            _onAddImageButtonPressed(context);
          },
        ),
        SizedBox(
          height: 120,
          child: StreamBuilder(
              stream: imageInfoStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.none) {
                  return CupertinoActivityIndicator();
                }

                imageInfos = snapshot.data;

                List<Widget> images = imageInfos
                    .map((info) => CachedNetworkImage(
                          imageUrl: info.downloadUrl,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ))
                    .toList();

                return Wrap(
                  children: images,
                );
              }),
        ),
      ],
    );
  }

  _onAddImageButtonPressed(BuildContext context) async {
    //get the images
    final imagePickerService =
        Provider.of<MultiImagePickerService>(context, listen: false);
    List<Asset> imagesPicked = await imagePickerService.getImages();

    //upload them to storage
    final storageService = Provider.of<StorageService>(context, listen: false);
    final book = Provider.of<Book>(context, listen: false);
    final pageNumber = Provider.of<int>(context, listen: false);
    for (Asset image in imagesPicked) {
      String downloadUrl = await storageService.uploadImage(
          bookId: book.bookId, pageNumber: pageNumber, image: image);
      imageInfos.add(FileInfo(downloadUrl: downloadUrl));
    }
    //update the pages imageInfos
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    firestoreService.updateImageInfos(
        bookId: book.bookId, pageNumber: pageNumber, imageInfos: imageInfos);
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
