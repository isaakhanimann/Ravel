import 'package:flutter/cupertino.dart';

class HelperMethods {
  static String convertTimeToString({@required DateTime time}) {
    String stringTime = '${time.day}. ${_shortMonths[time.month]} ${time.year}';

    return stringTime;
  }

  static const List<String> _shortMonths = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}
