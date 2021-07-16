import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ButtonComponent extends StatelessWidget {
  VoidCallback? onPressed;
  String? name;
  ButtonComponent({required this.onPressed, required this.name});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0XFF30B700)),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        ),
      ),
      onPressed: onPressed,
      child: Text(name!),
    );
  }
}
