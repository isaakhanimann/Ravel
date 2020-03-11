import 'package:flutter/cupertino.dart';
import 'package:ravel/screens/map_screen.dart';
import 'explanation_one.dart';
import 'explanation_two.dart';
import 'explanation_three.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ExplanationScreens extends StatelessWidget {
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        PageView(
          controller: pageController,
          children: <Widget>[
            ExplanationOne(),
            ExplanationTwo(),
            ExplanationThree(),
          ],
        ),
        Positioned(
          top: 25,
          right: 0,
          child: CupertinoButton(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Text(
              'Skip',
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute<void>(
                  builder: (context) {
                    return MapScreen();
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 50,
          child: SmoothPageIndicator(
            controller: pageController, // PageController
            count: 3,
            effect: WormEffect(
              dotColor: CupertinoColors.white,
            ),
            // your preferred effect
          ),
        )
      ],
    );
  }
}
