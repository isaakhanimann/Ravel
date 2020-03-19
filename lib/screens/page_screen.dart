import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:ravel/models/helper_methods.dart';
import 'package:ravel/models/page.dart';
import 'package:provider/provider.dart';
import 'package:ravel/screens/image_screen.dart';
import 'package:ravel/services/firestore_service.dart';
import 'package:ravel/services/storage_service.dart';
import 'package:ravel/models/book.dart';
import 'package:ravel/services/file_picker_service.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:ravel/services/multi_image_picker_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ravel/constants.dart';

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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          left: false,
          right: false,
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
                  value: editedPage, child: PageScreenWithPageData());
            },
          ),
        ),
      ),
    );
  }
}

class PageScreenWithPageData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Page page = Provider.of<Page>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
            TextSpan(
                text: 'Day ${page.pageNumber} ',
                style: TextStyle(fontSize: 40, fontFamily: 'CatamaranBold')),
            TextSpan(
              text: HelperMethods.convertTimeToString(time: page.date),
              style: TextStyle(fontSize: 12, fontFamily: 'OpenSansRegular'),
            ),
          ]),
        ),
        Expanded(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: PageText(),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
              ),
              FilesSection(),
              ImagesSection(),
            ],
          ),
        ),
      ],
    );
  }
}

class PageText extends StatefulWidget {
  @override
  _PageTextState createState() => _PageTextState();
}

class _PageTextState extends State<PageText> {
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    Page page = Provider.of<Page>(context, listen: false);
    _textEditingController = TextEditingController(text: page.text);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        CupertinoTextField(
          controller: _textEditingController,
          decoration: BoxDecoration(border: null),
          style: TextStyle(fontSize: 15, fontFamily: 'OpenSansRegular'),
          autofocus: true,
          minLines: null,
          maxLines: null,
          expands: true,
        ),
        CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'OpenSansRegular',
              color: kGreen,
            ),
          ),
          onPressed: _uploadText,
        )
      ],
    );
  }

  _uploadText() async {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final book = Provider.of<Book>(context, listen: false);
    final pageNumber = Provider.of<int>(context, listen: false);
    await firestoreService.updatePageText(
        bookId: book.bookId,
        pageNumber: pageNumber,
        text: _textEditingController.text);
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            'Documents',
            style: kPageSubsectionTitle,
          ),
        ),
        SizedBox(
          height: 100,
          width: double.infinity,
          child: StreamBuilder(
            stream: fileInfosStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.none) {
                return Center(child: CupertinoActivityIndicator());
              }

              fileInfos = snapshot.data;

              return Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: Axis.horizontal,
                children: <Widget>[
                  for (FileInfo fileInfo in fileInfos)
                    CupertinoButton(
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                          decoration: BoxDecoration(
                              color: kLightGreen,
                              borderRadius: BorderRadius.circular(30)),
                          child: Text(
                            fileInfo.fileName,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'OpenSansSemiBold',
                              color: kGreen,
                            ),
                          )),
                      onPressed: () {
                        //view file
                        _launchURL(url: fileInfo.downloadUrl);
                      },
                    ),
                  CupertinoButton(
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 35,
                      color: kGreen,
                    ),
                    onPressed: _onAddFilesPressed,
                  ),
                ],
              );
            },
          ),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Text(
            'Photos',
            style: kPageSubsectionTitle,
          ),
        ),
        StreamBuilder(
            stream: imageInfoStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.none) {
                return Center(child: CupertinoActivityIndicator());
              }

              imageInfos = snapshot.data;

              List<Widget> listOfImagesAndButton = List.from(
                imageInfos.map(
                  (info) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (context) {
                            return ImageScreen(
                              url: info.downloadUrl,
                            );
                          },
                        ),
                      );
                    },
                    child: Hero(
                      tag: info.downloadUrl,
                      child: CachedNetworkImage(
                        imageUrl: info.downloadUrl,
                        fit: BoxFit.fill,
                        placeholder: (context, url) =>
                            CupertinoActivityIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              );

              listOfImagesAndButton.add(Container(
                color: kLightYellow,
                child: CupertinoButton(
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 35,
                    color: kYellow,
                  ),
                  onPressed: _onAddImageButtonPressed,
                ),
              ));

              return GridView.count(
                shrinkWrap: true,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                crossAxisCount: 3,
                children: listOfImagesAndButton,
              );
            }),
      ],
    );
  }

  _onAddImageButtonPressed() async {
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
