import 'package:flutter/material.dart';

class FxGrayDarkText extends StatelessWidget {
  final String title;
  final bool isBold;
  final int? maxLines;
  final TextAlign? align;
  final Color? color;
  final double? fontSize;
  const FxGrayDarkText({
    Key? key,
    required this.title,
    this.isBold = false,
    this.maxLines,
    this.align,
    this.color,
    this.fontSize = 16
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      textAlign: align,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
