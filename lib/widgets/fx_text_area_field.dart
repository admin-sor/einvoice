import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../app/constants.dart';
import 'fx_text_field.dart';

class FxTextAreaField extends HookWidget {
  final double? width;
  final double? maxHeight;
  final String? hintText;
  final String? labelText;
  final TextEditingController ctrl;
  final bool readOnly;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputAction action;
  final bool enabled;
  final String errorMessage;
  final void Function(String)? onChanged;
  final TextAlign textAlign;
  final void Function()? onEditingComplete;
  final TextCapitalization textCapitalization;
  final bool isMoney;
  final int maxLength;
  final int? maxLengthOld;
  final bool autoFocus;
  final bool showErrorMessage;
  final TextInputType? textInputType;
  final EdgeInsets? contentPadding;
  final bool isFixedTitle;
  final bool forceHighlight;
  final int minLines;
  final int? maxLines;

  const FxTextAreaField({
    Key? key,
    this.width,
    this.maxHeight,
    this.contentPadding,
    this.textInputType,
    this.labelText,
    this.hintText,
    this.readOnly = false,
    required this.ctrl,
    this.focusNode,
    this.onSubmitted,
    this.prefix,
    this.suffix,
    this.action = TextInputAction.newline,
    this.enabled = true,
    this.errorMessage = "",
    this.onChanged,
    this.onEditingComplete,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength = 0,
    this.isMoney = false,
    this.autoFocus = false,
    this.showErrorMessage = true,
    this.maxLengthOld,
    this.isFixedTitle = false,
    this.forceHighlight = false,
    this.minLines = 1,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = width ?? 400.0;
    final inFocus = useState(false);
    if (focusNode != null) {
      useEffect(() {
        focusNode!.addListener(() {
          inFocus.value = focusNode!.hasFocus;
        });
        return null;
      });
    }
    final myFormatter = <TextInputFormatter>[];
    if (textCapitalization == TextCapitalization.characters) {
      myFormatter.add(MyUcFormatter());
    } else {
      myFormatter.add(MyMoneyFormater(isMoney));
    }
    if (maxLength > 0) {
      myFormatter.add(LengthLimitingTextInputFormatter(maxLength));
    }
    if (textInputType == TextInputType.number) {
      myFormatter.add(FilteringTextInputFormatter.allow(
        RegExp(r'[0-9]'),
      ));
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: isFixedTitle ? 5.0 : 0.0,
                ),
                child: TextField(
                  inputFormatters: myFormatter,
                  keyboardType: textInputType ?? TextInputType.multiline,
                  textAlign: textAlign,
                  minLines: minLines,
                  maxLines: maxLines,
                  maxLength: maxLengthOld,
                  autofocus: autoFocus,
                  textInputAction: action,
                  onEditingComplete: onEditingComplete,
                  onChanged: onChanged,
                  focusNode: focusNode,
                  controller: ctrl,
                  textCapitalization: textCapitalization,
                  style: readOnly || !enabled
                      ? TextStyle(color: Constants.greyDark)
                      : null,
                  enabled: enabled,
                  readOnly: readOnly,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    contentPadding: contentPadding ??
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    isDense: true,
                    filled: true,
                    suffixIconConstraints:
                        const BoxConstraints(maxHeight: 32, maxWidth: 32),
                    fillColor: (inFocus.value || forceHighlight)
                        ? Constants.greenDark.withOpacity(0.05)
                        : Colors.white,
                    prefixIcon: prefix,
                    suffixIcon: suffix,
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: (errorMessage != "")
                            ? Constants.red
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: (errorMessage != "")
                            ? Constants.red
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: (errorMessage != "")
                            ? Constants.red
                            : Constants.greenDark,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: (errorMessage != "")
                            ? Constants.red
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    labelText: isFixedTitle ? "" : labelText,
                    hintText: isFixedTitle ? "" : hintText,
                    labelStyle: TextStyle(
                      fontSize: 16,
                      color: readOnly ? Constants.greyLight : Constants.greenDark,
                    ),
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Constants.greyLight,
                    ),
                  ),
                ),
              ),
              if (isFixedTitle)
                Positioned(
                  left: 10,
                  top: -2,
                  child: Container(
                      color: Constants.colorAppBarBg,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          labelText ?? "",
                          style: TextStyle(
                            color: Constants.greenDark,
                            fontSize: 12,
                          ),
                        ),
                      )),
                ),
            ],
          ),
          if (errorMessage != "" && showErrorMessage)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Constants.red,
                  fontSize: 14,
                ),
              ),
            )
        ],
      ),
    );
  }
}
