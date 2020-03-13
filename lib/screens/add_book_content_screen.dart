import 'package:flutter/cupertino.dart';
import 'package:ravel/models/book.dart';

class AddBookContentScreen extends StatefulWidget {
  final Book book;

  AddBookContentScreen({@required this.book});

  @override
  _AddBookContentScreenState createState() => _AddBookContentScreenState();
}

class _AddBookContentScreenState extends State<AddBookContentScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Text('Day One in ...'),
      ),
    );
  }
}
