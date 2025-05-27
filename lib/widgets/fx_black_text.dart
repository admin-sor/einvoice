import 'package:flutter/material.dart';

class FxBlackText extends StatelessWidget {
  final String title;
  final bool isBold;
  final int? maxLines;
  final TextAlign? align;
  final Color? color;
  const FxBlackText({
    Key? key,
    required this.title,
    this.isBold = false,
    this.maxLines,
    this.align,
    this.color = Colors.black,
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
        fontSize: 16,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
