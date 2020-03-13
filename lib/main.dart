import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ravel/screens/navigation_screen.dart';
import 'package:ravel/services/auth_service.dart';
import 'package:ravel/services/firestore_service.dart';
import 'package:ravel/services/geocoding_service.dart';
import 'package:ravel/services/storage_service.dart';
import 'package:provider/provider.dart';

void main() async {
  // This app is designed only to work vertically, so we limit
  // orientations to portrait up and down.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  return runApp(Ravel());
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
        Provider<GeocodingService>(
          create: (_) => GeocodingService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: CupertinoColors.white,
          textTheme: TextTheme(
            headline: TextStyle(fontSize: 25.0, fontFamily: 'CatamaranBold'),
            title: TextStyle(fontSize: 20.0, fontFamily: 'CatamaranBold'),
            body1: TextStyle(fontSize: 12.0, fontFamily: 'OpenSansRegular'),
          ),
        ),
        home: CupertinoPageScaffold(child: NavigationScreen()),
      ),
    );
  }
}
