import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String title;

  final Color colorText;

  final VoidCallback onClicked;

  final Color colorBackground;

  const ButtonWidget({
    Key? key,
    required this.title,
    required this.colorText,
    required this.onClicked,
    required this.colorBackground,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onClicked,
        child: Text(
          title,
          style: TextStyle(fontSize: 18.0, color: colorText),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(colorBackground),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0,
            ),
          ),
        ),
      );
}
