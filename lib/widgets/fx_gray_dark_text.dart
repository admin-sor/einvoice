import 'package:flutter/material.dart';

class FxGrayDarkText extends StatelessWidget {
  final String title;
  final bool isBold;
  final int? maxLines;
  final TextAlign? align;
  final Color? color;
  final double? fontSize;
  final TextOverflow overflow;
  final bool softWrap;
  const FxGrayDarkText({
    Key? key,
    required this.title,
    this.isBold = false,
    this.maxLines,
    this.align,
    this.color,
    this.fontSize = 16,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      textAlign: align,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
