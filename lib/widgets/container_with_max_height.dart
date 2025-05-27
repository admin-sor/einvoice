import 'package:flutter/material.dart';

class ContainerWithMaxHeight extends StatelessWidget {
  final double maxHeight;
  final Widget child;

  ContainerWithMaxHeight({required this.maxHeight, required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }
}
