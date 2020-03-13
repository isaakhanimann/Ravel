import 'package:flutter/material.dart';
import 'package:ravel/models/book.dart';

class AddBookContentScreen extends StatefulWidget {
  final Book book;

  AddBookContentScreen({@required this.book});

  @override
  _AddBookContentScreenState createState() => _AddBookContentScreenState();
}

class _AddBookContentScreenState extends State<AddBookContentScreen> {
  static const double pi = 3.14159265359;
  final pageController = PageController();
  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.book.numberOfPages; i++) {
      pages.add(Center(
          child: Text(
        i.toString(),
        style: TextStyle(fontSize: 30),
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: pages,
    );
  }
}
