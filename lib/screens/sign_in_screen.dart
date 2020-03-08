import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ravel/screens/navigation_screen.dart';
import 'package:ravel/services/auth_service.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:ravel/services/apple_sign_in_available.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (appleSignInAvailable.isAvailable)
                AppleSignInButton(
                  style: ButtonStyle.black,
                  type: ButtonType.continueButton,
                  onPressed: () {
                    _signInWithApple(context);
                  },
                ),
              GoogleLoginButton(
                text: 'Sign Up with Google',
                color: Color(0xFFDD4B39),
                textColor: CupertinoColors.white,
                onPressed: () {
                  _signInWithGoogle(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _signInWithGoogle(BuildContext context) async {
    try {
      setState(() {
        showSpinner = true;
      });
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithGoogle();
      setState(() {
        showSpinner = false;
      });
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        CupertinoPageRoute(
            builder: (BuildContext context) => NavigationScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print(e);
      setState(() {
        showSpinner = false;
      });
    }
  }

  _signInWithApple(BuildContext context) async {
    setState(() {
      showSpinner = true;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithApple();
      setState(() {
        showSpinner = false;
      });
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        CupertinoPageRoute(
            builder: (BuildContext context) => NavigationScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      switch (e.code) {
        case 'ERROR_AUTHORIZATION_DENIED':
          {
            _showAlert(
                context: context,
                title: "Authorization Denied",
                description: "Please sign up with email");
            break;
          }
        default:
          {
            _showAlert(
                context: context,
                title: "Apple Sign In didn't work",
                description: "Apple Sign In didn't work");
            print(e);
          }
      }
      setState(() {
        showSpinner = false;
      });
    }
  }

  void _showAlert({BuildContext context, String title, String description}) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text('\n' + description),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Ok'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class GoogleLoginButton extends StatelessWidget {
  GoogleLoginButton(
      {@required this.color,
      this.textColor,
      @required this.onPressed,
      @required this.text,
      this.paddingInsideHorizontal = 40,
      this.paddingInsideVertical = 15});

  final Color color;
  final Color textColor;
  final Function onPressed;
  final String text;
  final double paddingInsideHorizontal;
  final double paddingInsideVertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(6.0),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: CupertinoButton(
            onPressed: onPressed,
            padding: EdgeInsets.symmetric(
                horizontal: paddingInsideHorizontal,
                vertical: paddingInsideVertical),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontFamily: 'MuliRegular',
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
