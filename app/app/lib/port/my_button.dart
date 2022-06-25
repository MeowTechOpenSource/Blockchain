import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function onPressed;
  final Widget child;

  late double width;
  late double height;
  late Color backgroundColor;
  late Color textColor;
  late double borderRadius;
  late double padding;

  MyButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.width = 90,
    this.height = 37,
    this.backgroundColor = const Color(0xFF0A59F7),
    this.textColor = Colors.white,
    this.borderRadius = 25,
    this.padding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        textStyle: TextStyle(
            color: textColor,
            fontFamily: 'HarmonyOS_Sans',
            fontWeight: FontWeight.w500),
        color: backgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius)),
        child: InkWell(
          onTap: () => onPressed(),
          splashColor: Color.fromARGB(0, 255, 94, 94),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Center(child: child),
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
