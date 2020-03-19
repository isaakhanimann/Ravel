import 'package:flutter/material.dart';
import 'package:ravel/constants.dart';

class ExplanationOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              Text(
                'Tap on the map to add a pin',
                style: kExplanationTitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
