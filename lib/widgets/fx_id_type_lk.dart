import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';

class IdTypeLkModel extends Equatable {
  final String code;
  final String name;

  IdTypeLkModel(this.code, this.name);

  @override
  List<Object?> get props => [code];
}

final listFilter = [
  IdTypeLkModel("BRN", "BRN"),
  IdTypeLkModel("NRIC", "NRIC"),
];

class FxFilterIdTypeLk extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final IdTypeLkModel? initialValue;
  final void Function(IdTypeLkModel)? onChanged;
  final bool looseFocus;
  final double labelLength;
  final EdgeInsets? contentPadding;
  const FxFilterIdTypeLk({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.looseFocus = false,
    this.labelLength = 20.0,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? double.infinity : width!;
    final selectedValue = useState<IdTypeLkModel?>(initialValue);
    final listValue = useState<List<IdTypeLkModel>>(listFilter);

    final fcDropDown = FocusNode();
    final isFocused = useState(false);
    if (looseFocus) {
      isFocused.value = false;
    }
    fcDropDown.addListener(() {
      if (fcDropDown.hasFocus) {
        isFocused.value = true;
      } else {
        isFocused.value = false;
      }
    });
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(
              Size(maxWidth, 50),
            ),
            child: Container(
              width: maxWidth,
              height: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(
                  color: isFocused.value
                      ? Constants.greenDark
                      : Colors.grey.withOpacity(0.4),
                ),
              ),
              child: DropdownButton<IdTypeLkModel>(
                focusNode: fcDropDown,
                menuMaxHeight: MediaQuery.of(context).size.height / 3,
                isExpanded: true,
                icon: Image.asset(
                  "images/icon_triangle_down.png",
                  height: 36,
                ),
                hint: Text(
                  hintText ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                value: selectedValue.value,
                underline: const SizedBox.shrink(),
                onChanged: (value) {
                  if (value != null) selectedValue.value = value;
                  if (onChanged != null && value != null) {
                    onChanged!(value);
                  }
                },
                items: listValue.value
                    .map<DropdownMenuItem<IdTypeLkModel>>(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                          ),
                          child: Text(
                            value.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              /* color: Constants.greenDark, */
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          width: labelLength,
          height: 6,
        ),
        if (initialValue != null)
          Container(
            height: 20,
            width: 80,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                hintText ?? "",
                style: const TextStyle(
                  color: Constants.greenDark,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
