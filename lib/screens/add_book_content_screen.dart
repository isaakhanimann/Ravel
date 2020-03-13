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
        body: PageView.builder(
      controller: _pageController,
      itemBuilder: (context, position) {
        return _buildPage(pageNumber: position);
      },
      itemCount: widget.book.numberOfPages,
    ));
  }

  Widget _buildPage({@required int pageNumber}) {
    return Container(
      color: (pageNumber % 2 == 0) ? Colors.blue : Colors.green,
      child: Center(
        child: Text(pageNumber.toString()),
      ),
    );
  }
}
