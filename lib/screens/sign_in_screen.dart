import 'package:flutter/cupertino.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: SafeArea(
            child: Column(
      children: <Widget>[
        Text('Apple Signin'),
        Text('Google Signin'),
      ],
    )));
  }
}
