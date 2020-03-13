import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:ravel/models/page.dart';
import 'package:provider/provider.dart';
import 'package:ravel/services/firestore_service.dart';

class BookPageScreen extends StatefulWidget {
  final String bookId;
  final int pageNumber;

  BookPageScreen({@required this.bookId, @required this.pageNumber});
  @override
  _BookPageScreenState createState() => _BookPageScreenState();
}

class _BookPageScreenState extends State<BookPageScreen> {
  Future<Page> futurePage;

  @override
  void initState() {
    super.initState();
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    futurePage = firestoreService.getPage(
        bookId: widget.bookId, pageNumber: widget.pageNumber);
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
              Expanded(child: PageBody(futurePage: futurePage)),
            ],
          ),
        ),
      ),
    );
  }

  _saveEverything() async {
    //upload the page content (text and images that are stored in the state)
  }
}

class PageBody extends StatelessWidget {
  final Future<Page> futurePage;
  PageBody({@required this.futurePage});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
        Page page = snapshot.data;

        return Column(
          children: <Widget>[
            PageText(initialText: page.text),
            Expanded(
              child: Container(
                color: Colors.green,
              ),
            ),
            CupertinoButton(
              child: Text('Add Image'),
              onPressed: _onAddButtonPressed,
            ),
            ImagesSection(),
          ],
        );
      },
    );
  }

  _onAddButtonPressed() async {
    //get images and save them in the state
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

class ImagesSection extends StatefulWidget {
  @override
  _ImagesSectionState createState() => _ImagesSectionState();
}

class _ImagesSectionState extends State<ImagesSection> {
  List<Asset> images = List<Asset>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
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
