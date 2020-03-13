import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class BookPageScreen extends StatefulWidget {
  final int pageNumber;

  BookPageScreen({@required this.pageNumber});
  @override
  _BookPageScreenState createState() => _BookPageScreenState();
}

class _BookPageScreenState extends State<BookPageScreen> {
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
              CupertinoTextField(
                decoration: BoxDecoration(border: null),
                style: TextStyle(fontSize: 15, fontFamily: 'OpenSansRegular'),
                autofocus: true,
                maxLines: 10,
                minLines: 1,
              ),
              Expanded(
                child: Container(
                  color: Colors.green,
                ),
              ),
              ImagesSection(),
              CupertinoButton(
                  child: Text('Add pdf'), onPressed: _onAddButtonPressed)
            ],
          ),
        ),
      ),
    );
  }

  _saveEverything() async {
    //upload the page content (text and images that are stored in the state)
  }

  _onAddButtonPressed() async {
    //get images and save them in the state
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
          'Day ${pageNumber + 1}',
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