import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../app/constants.dart';

class FxTextField extends HookWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final TextEditingController ctrl;
  final bool readOnly;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputAction? action;
  final bool enabled;
  final String errorMessage;
  final void Function(String)? onChanged;
  final TextAlign textAlign;
  final void Function()? onEditingComplete;
  final TextCapitalization textCapitalization;
  final bool isMoney;
  final double maxHeight;
  final int maxLength;
  final int? maxLengthOld;
  final bool autoFocus;
  final bool showErrorMessage;
  final TextInputType? textInputType;
  final String? prefixFormat;
  final EdgeInsets? contentPadding;
  final bool isFixedTitle;
  final bool forceHighlight;
  final bool isMultiline;
  const FxTextField({
    Key? key,
    this.width,
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
    this.action = TextInputAction.next,
    this.enabled = true,
    this.errorMessage = "",
    this.onChanged,
    this.onEditingComplete,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.maxHeight = 80.0,
    this.maxLength = 0,
    this.isMoney = false,
    this.autoFocus = false,
    this.showErrorMessage = true,
    this.prefixFormat,
    this.maxLengthOld,
    this.isFixedTitle = false,
    this.forceHighlight = false,
    this.isMultiline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = width == null ? 400.0 : width!;
    final inFocus = useState(false);
    if (focusNode != null) {
      useEffect(() {
        focusNode!.addListener(() {
          if (focusNode!.hasFocus) {
            inFocus.value = true;
          } else {
            inFocus.value = false;
          }
        });
        return null;
      });
    }
    List<TextInputFormatter> myFormatter = List.empty(growable: true);
    if (textCapitalization == TextCapitalization.characters) {
      myFormatter.add(MyUcFormatter());
    } else {
      myFormatter.add(MyMoneyFormater(isMoney));
    }
    // if (prefixFormat != null) {
    //   myFormatter.add(PrefixFormater(prefixFormat!));
    // }
    if (maxLength > 0) {
      myFormatter.add(LengthLimitingTextInputFormatter(maxLength));
    }
    if (textInputType == TextInputType.number) {
      myFormatter.add(FilteringTextInputFormatter.allow(
        RegExp(r'[0-9]'),
      ));
    }
    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        Size(maxWidth, maxHeight),
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
                  keyboardType:
                      isMultiline ? TextInputType.multiline : textInputType,
                  textAlign: textAlign,
                  maxLines: isMultiline ? 5 : 1,
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

class MyUcFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}

class MyMoneyFormater extends TextInputFormatter {
  final bool isMoney;

  MyMoneyFormater(this.isMoney);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String fmtValue = newValue.text;
    if (isMoney) {
      try {
        double dval = double.parse(newValue.text);
        final nbf = NumberFormat("###,##0.00", "en_US");
        fmtValue = nbf.format(dval);
      } catch (_) {}
    }
    return TextEditingValue(
      text: fmtValue,
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}

class PrefixFormater extends TextInputFormatter {
  final String prefix;

  PrefixFormater(this.prefix);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String fmtValue = newValue.text;
    if (!fmtValue.startsWith(prefix)) {
      fmtValue = prefix + newValue.text;
      if (fmtValue.length > 50) {
        fmtValue = fmtValue.substring(0, 50);
      }
    }
    return TextEditingValue(
      text: fmtValue,
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}

class FxTextFieldHuge extends HookWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final TextEditingController ctrl;
  final bool readOnly;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputAction? action;
  final bool enabled;
  final String errorMessage;
  final void Function(String)? onChanged;
  final TextAlign textAlign;
  final void Function()? onEditingComplete;
  final TextCapitalization textCapitalization;
  final bool isMoney;
  final double maxHeight;
  final int maxLength;
  final int? maxLengthOld;
  final bool autoFocus;
  final bool showErrorMessage;
  final TextInputType? textInputType;
  final String? prefixFormat;

  const FxTextFieldHuge(
      {Key? key,
      this.width,
      this.textInputType,
      this.labelText,
      this.hintText,
      this.readOnly = false,
      required this.ctrl,
      this.focusNode,
      this.onSubmitted,
      this.prefix,
      this.suffix,
      this.action = TextInputAction.next,
      this.enabled = true,
      this.errorMessage = "",
      this.onChanged,
      this.onEditingComplete,
      this.textAlign = TextAlign.start,
      this.textCapitalization = TextCapitalization.none,
      this.maxHeight = 80.0,
      this.maxLength = 0,
      this.isMoney = false,
      this.autoFocus = false,
      this.showErrorMessage = true,
      this.prefixFormat,
      this.maxLengthOld})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = width == null ? 400.0 : width!;
    final inFocus = useState(false);
    if (focusNode != null) {
      useEffect(() {
        focusNode!.addListener(() {
          if (focusNode!.hasFocus) {
            inFocus.value = true;
          } else {
            inFocus.value = false;
          }
        });
        return null;
      });
    }
    List<TextInputFormatter> myFormatter = List.empty(growable: true);
    if (textCapitalization == TextCapitalization.characters) {
      myFormatter.add(MyUcFormatter());
    } else {
      myFormatter.add(MyMoneyFormater(isMoney));
    }
    // if (prefixFormat != null) {
    //   myFormatter.add(PrefixFormater(prefixFormat!));
    // }
    if (maxLength > 0) {
      myFormatter.add(LengthLimitingTextInputFormatter(maxLength));
    }
    if (textInputType == TextInputType.number) {
      myFormatter.add(FilteringTextInputFormatter.allow(
        RegExp(r'[0-9]'),
      ));
    }
    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        Size(maxWidth, maxHeight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            inputFormatters: myFormatter,
            keyboardType: textInputType,
            textAlign: textAlign,
            style: TextStyle(fontSize: 36),
            maxLength: maxLengthOld,
            autofocus: autoFocus,
            textInputAction: action,
            onEditingComplete: onEditingComplete,
            onChanged: onChanged,
            focusNode: focusNode,
            controller: ctrl,
            textCapitalization: textCapitalization,
            enabled: enabled,
            readOnly: readOnly,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
              isDense: true,
              filled: true,
              suffixIconConstraints:
                  const BoxConstraints(maxHeight: 32, maxWidth: 32),
              fillColor: inFocus.value
                  ? Constants.greenDark.withOpacity(0.05)
                  : Colors.white,
              prefixIcon: prefix,
              suffixIcon: suffix,
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
              labelText: labelText,
              hintText: hintText,
              labelStyle: const TextStyle(
                fontSize: 36,
                color: Constants.greenDark,
              ),
              hintStyle: const TextStyle(
                fontSize: 36,
                color: Colors.grey,
              ),
            ),
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
