import 'package:flutter/material.dart';

class FxButton extends StatelessWidget {
  final double maxWidth;
  final Color color;
  final VoidCallback? onPress;
  final String title;
  final bool isLoading;
  final Widget? prefix;
  final double? height;

  const FxButton({
    this.maxWidth = 200,
    this.color = Colors.orange,
    this.onPress,
    required this.title,
    this.isLoading = false,
    this.prefix,
    this.height = 40.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(maxWidth, 200)),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              alignment: Alignment.center,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: WidgetStateColor.resolveWith(
                (states) {
                  Color resultColor = color;
                  for (var element in states) {
                    if (element == WidgetState.disabled) {
                      resultColor = Colors.grey.shade400;
                    }
                  }
                  if (onPress == null) {
                    resultColor = Colors.grey.shade400;
                  }
                  return resultColor;
                },
              ),
            ),
            onPressed: onPress,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (prefix != null) prefix!,
                        Text(
                          title,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
