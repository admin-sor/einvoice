import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';

class FxMultilineTextField extends HookConsumerWidget {
  final String initialValue;
  final void Function(String value) onChange;
  final bool isReadOnly;
  FxMultilineTextField({
    super.key,
    required this.initialValue,
    required this.onChange,
    required this.isReadOnly,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> arrInput = initialValue.split("\n");
    List<TextEditingController> arrCtrl = [
      TextEditingController(text: arrInput.length >= 1 ? arrInput[0] : ""),
      TextEditingController(text: arrInput.length >= 2 ? arrInput[1] : ""),
      TextEditingController(text: arrInput.length >= 3 ? arrInput[2] : ""),
      TextEditingController(text: arrInput.length >= 4 ? arrInput[3] : ""),
      TextEditingController(text: arrInput.length >= 5 ? arrInput[4] : ""),
      TextEditingController(text: arrInput.length >= 6 ? arrInput[5] : ""),
      TextEditingController(text: arrInput.length >= 7 ? arrInput[6] : ""),
      TextEditingController(text: arrInput.length >= 8 ? arrInput[7] : ""),
      TextEditingController(text: arrInput.length >= 9 ? arrInput[8] : ""),
      TextEditingController(text: arrInput.length >= 10 ? arrInput[9] : ""),
    ];
    for (int i = 0; i < arrCtrl.length; i++) {
      arrCtrl[i].selection = TextSelection.fromPosition(
          TextPosition(offset: arrCtrl[i].text.length));
      arrCtrl[i].removeListener(() {});
      arrCtrl[i].addListener(() {
        String result = "";
        for (int j = 0; j < arrCtrl.length; j++) {
          if (j > 0) result += "\n";
          result += arrCtrl[j].text;
        }
        onChange(result);
      });
    }
    final isFocused = useState(false);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isFocused.value
              ? Constants.greenDark
              : Colors.grey.withOpacity(0.4),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 520,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Focus(
          onFocusChange: (val) {
            isFocused.value = val;
            if (!val) {
              String result = "";
              for (int j = 0; j < arrCtrl.length; j++) {
                if (j > 0) result += "\n";
                result += arrCtrl[j].text;
              }
              onChange(result);
            }
          },
          child: Column(children: [
            TextField(controller: arrCtrl[0], readOnly: isReadOnly),
            TextField(controller: arrCtrl[1], readOnly: isReadOnly),
            TextField(controller: arrCtrl[2], readOnly: isReadOnly),
            TextField(controller: arrCtrl[3], readOnly: isReadOnly),
            TextField(controller: arrCtrl[4], readOnly: isReadOnly),
            TextField(controller: arrCtrl[5], readOnly: isReadOnly),
            TextField(controller: arrCtrl[6], readOnly: isReadOnly),
            TextField(controller: arrCtrl[7], readOnly: isReadOnly),
            TextField(controller: arrCtrl[8], readOnly: isReadOnly),
            TextField(controller: arrCtrl[9], readOnly: isReadOnly),
          ]),
        ),
      ),
    );
  }
}
