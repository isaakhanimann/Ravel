import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ravel/screens/map_screen.dart';
import 'package:ravel/services/auth_service.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  String loggedInUid;

  @override
  void initState() {
    super.initState();
    _getUid();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<String>.value(value: loggedInUid, child: MapScreen());
  }

  _getUid() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    String uid = await authService.signInAnonymously();
    setState(() {
      loggedInUid = uid;
    });
  }
}
