import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ravel/models/book.dart';
import 'package:ravel/screens/book_page_screen.dart';

class AddBookContentScreens extends StatefulWidget {
  final Book book;

  AddBookContentScreens({@required this.book});

  @override
  _AddBookContentScreensState createState() => _AddBookContentScreensState();
}

class _AddBookContentScreensState extends State<AddBookContentScreens> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, position) {
        return BookPageScreen(book: widget.book, pageNumber: position + 1);
      },
      itemCount: widget.book.numberOfPages,
    );
  }
}
