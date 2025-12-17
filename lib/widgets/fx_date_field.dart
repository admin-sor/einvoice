import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../app/constants.dart';
import 'fx_green_dark_text.dart';

class FxDateField extends HookWidget {
  final double? width;
  final double? height;
  final DateTime dateValue;
  final void Function(DateTime)? onDateChange;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? hintText;
  final String? labelText;
  final FocusNode? fcNode;
  final bool readOnly;
  final bool isFixedTitle;
  final EdgeInsets? contentPadding;
  const FxDateField({
    Key? key,
    this.width,
    this.height,
    required this.dateValue,
    required this.firstDate,
    required this.lastDate,
    this.onDateChange,
    this.labelText,
    this.hintText,
    this.fcNode,
    this.isFixedTitle = false,
    this.contentPadding,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = width == null ? 400.0 : width!;
    final sdf = DateFormat("dd MMM y");
    TextEditingController ctrl = useTextEditingController(text: "");
    final inFocus = useState(false);

    ctrl.text = sdf.format(dateValue);
    if (fcNode != null) {
      useEffect(() {
        fcNode!.addListener(() {
          if (fcNode!.hasFocus) {
            inFocus.value = true;
          } else {
            inFocus.value = false;
          }
        });
        return null;
      });
    }
    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        Size(maxWidth, height ?? 50),
      ),
      child: Stack(
        children: [
          Padding(
            padding: isFixedTitle
                ? const EdgeInsets.only(top: 5.0)
                : const EdgeInsets.only(top: 10.0),
            child: TextField(
              controller: ctrl,
              readOnly: true,
              focusNode: fcNode,
              decoration: InputDecoration(
                fillColor: inFocus.value
                    ? Constants.greenDark.withOpacity(0.05)
                    : Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: inFocus.value
                        ? Constants.greenDark
                        : Colors.grey.withOpacity(0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: inFocus.value
                        ? Constants.greenDark
                        : Colors.grey.withOpacity(0.4),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: inFocus.value
                        ? Constants.greenDark
                        : Colors.grey.withOpacity(0.4),
                  ),
                ),
                contentPadding: const EdgeInsets.all(10),
                // labelText: labelText,
                //hintText: hintText,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  color: Constants.greenDark,
                ),
                hintStyle: const TextStyle(fontSize: 16),
                suffixIcon: readOnly
                    ? null
                    : InkWell(
                        onTap: () async {
                          final newDate = await showDatePicker(
                            context: context,
                            initialDate: dateValue,
                            firstDate: firstDate,
                            lastDate: lastDate,
                          );
                          if (newDate != null) {
                            ctrl.text = sdf.format(newDate);
                            if (onDateChange != null) {
                              onDateChange!(newDate);
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            "images/icon_calendar.png",
                            width: 18,
                            height: 18,
                          ),
                        ),
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
          if (!isFixedTitle)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 100,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: FxGreenDarkText(
                    title: labelText ?? "PO Date",
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
