import 'package:flutter/material.dart';
import 'package:ravel/constants.dart';

class ExplanationTwo extends StatelessWidget {
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
                'Choose when you want to go there',
                style: kExplanationTitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 70,
              ),
              Flexible(child: Image.asset('assets/images/daterange.png')),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
