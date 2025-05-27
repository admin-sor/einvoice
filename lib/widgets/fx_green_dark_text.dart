import 'package:flutter/material.dart';

import '../app/constants.dart';

class FxGreenDarkText extends StatelessWidget {
  final String title;
  final bool isBold;
  final int? maxLines;
  final double fontSize;
  final TextAlign? align;
  final FontStyle? fontStyle;
  final Color color;
  const FxGreenDarkText({
    Key? key,
    required this.title,
    this.isBold = false,
    this.maxLines,
    this.align,
    this.fontStyle,
    this.fontSize = 16,
    this.color = Constants.greenDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
        textAlign: align,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontStyle: fontStyle,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ));
  }
}
