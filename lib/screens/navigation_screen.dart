import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ravel/screens/map_screen.dart';
import 'package:ravel/screens/map_screen_loading.dart';
import 'package:ravel/services/auth_service.dart';
import 'explanationscreens/explanation_screens.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  String loggedInUid;
  bool isFirstTime = false;

  @override
  void initState() {
    super.initState();
    _getUid();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstTime) {
      return ExplanationScreens();
    }
    if (loggedInUid == null) {
      return MapScreenLoading();
    }
    return MapScreen(loggedUid: loggedInUid);
  }

  _getUid() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    String uid = await authService.getCurrentUid();
    if (uid == null) {
      setState(() {
        isFirstTime = true;
      });
      uid = await authService.signInAnonymously();
    }
    setState(() {
      loggedInUid = uid;
    });
  }
}
