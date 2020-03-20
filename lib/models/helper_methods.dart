import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ravel/constants.dart';

class HelperMethods {
  static String convertTimeToString({@required DateTime time}) {
    if (time == null) {
      return '';
    }
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

  static Future<bool> showDelete(
      {BuildContext context, RelativeRect position}) async {
    String deleteString = await showMenu(
        elevation: 0,
        color: kLightRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        context: context,
        position: position,
        items: [
          PopupMenuItem<String>(
            child: Text(
              'Delete',
              style: TextStyle(
                  fontFamily: 'OpenSansBold', fontSize: 15, color: kRed),
            ),
            value: 'delete',
          )
        ]);
    if (deleteString == 'delete') {
      return true;
    }
    return false;
  }
}
