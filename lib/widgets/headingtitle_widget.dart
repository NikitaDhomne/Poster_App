import 'package:flutter/material.dart';

class HeadingTitleWidget extends StatelessWidget {
  final String title;
  const HeadingTitleWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }
}
