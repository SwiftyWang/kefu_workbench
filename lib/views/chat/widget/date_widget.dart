import 'package:flutter/material.dart';
import 'package:kefu_workbench/core_flutter.dart';

class DateWidget extends StatelessWidget {
  DateWidget({this.date});
  final int date;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      constraints: BoxConstraints(
        minWidth: 200.0,
      ),
      alignment: Alignment.center,
      child: Text(
        "${Utils.epocFormat(date)}",
        style: TextStyle(color: Colors.black38),
      ),
    );
  }
}
