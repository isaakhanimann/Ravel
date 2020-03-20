import 'package:flutter/material.dart';
import 'package:ravel/constants.dart';

class ExplanationThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              Text(
                'The pin will reveal a book with one page for every day',
                style: kExplanationTitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 60,
              ),
              Text(
                'Describe your plans for that day. Put all the documents you need into the page.During the trip add images to be remembered.',
                style: kExplanationSubTitle,
                textAlign: TextAlign.center,
              ),
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
