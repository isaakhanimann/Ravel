import 'package:flutter/cupertino.dart';

class AddBookContentScreen extends StatefulWidget {
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
