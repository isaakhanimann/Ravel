import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ravel/models/book.dart';

class AddBookContentScreen extends StatefulWidget {
  final Book book;

  AddBookContentScreen({@required this.book});

  @override
  _AddBookContentScreenState createState() => _AddBookContentScreenState();
}

class _AddBookContentScreenState extends State<AddBookContentScreen> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, position) {
            return _buildPage(pageNumber: position);
          },
          itemCount: widget.book.numberOfPages,
        ),
      ),
    );
  }

  Widget _buildPage({@required int pageNumber}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: <Widget>[
          Text(
            'Day ${pageNumber + 1}',
            style: TextStyle(fontSize: 40, fontFamily: 'CatamaranBold'),
          ),
          CupertinoTextField(
            autofocus: true,
          ),
        ],
      ),
    );
  }
}
