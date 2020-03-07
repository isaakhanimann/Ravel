import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ravel/services/auth_service.dart';
import 'package:ravel/services/firestore_service.dart';
import 'package:ravel/services/storage_service.dart';
import 'screens/map_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  // This app is designed only to work vertically, so we limit
  // orientations to portrait up and down.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(Ravel());
}

class Ravel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          barBackgroundColor: CupertinoColors.white,
          scaffoldBackgroundColor: CupertinoColors.white,
        ),
        home: CupertinoPageScaffold(child: MapScreen()),
      ),
    );
  }
}
