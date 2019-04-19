import 'package:flutter/material.dart';

Future popupMenuBuilder(BuildContext context, Widget child,
    {bool dismiss = false}) async {
  return showDialog(
      context: context,
      barrierDismissible: dismiss,
      builder: (BuildContext context) =>
          WillPopScope(child: child, onWillPop: () async => dismiss));
}
