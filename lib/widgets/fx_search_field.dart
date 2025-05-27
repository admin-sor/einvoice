import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../app/constants.dart';

class FxSearchField extends HookWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final String? errorMessage;
  final bool isLoading;
  final void Function(String search)? onSearch;
  const FxSearchField({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    this.onSearch,
    this.isLoading = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = width == null ? 400.0 : width!;
    final TextEditingController ctrl = useTextEditingController(text: "");
    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        Size(maxWidth, 200),
      ),
      child: TextField(
        controller: ctrl,
        onSubmitted: (v) {
          if (onSearch != null) {
            onSearch!(v);
          }
        },
        decoration: InputDecoration(
          suffixIcon: InkWell(
            onTap: () {
              if (onSearch != null) {
                final String v = ctrl.text;
                onSearch!(v);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    )
                  : Image.asset(
                      "images/icon_search.png",
                      width: 24,
                    ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: (errorMessage != null && errorMessage != "")
                ? const BorderSide(color: Constants.red)
                : const BorderSide(
                    color: Constants.greenDark,
                  ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Constants.greenDark),
          ),
          contentPadding: const EdgeInsets.all(10),
          labelText: labelText,
          hintText: hintText,
          labelStyle: const TextStyle(fontSize: 16),
          hintStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
