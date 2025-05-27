import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/repository/store_repository.dart';
import 'package:sor_inventory/screen/dispose/dispose_store_provider.dart';
import 'package:sor_inventory/widgets/fx_green_dark_text.dart';

import '../app/constants.dart';
import '../model/store_model.dart';
import '../provider/dio_provider.dart';
import '../provider/shared_preference_provider.dart';
import '../repository/base_repository.dart';

class PoStatusModel {
  final String code;
  final String name;

  PoStatusModel({
    required this.code,
    required this.name,
  });
}

final List<PoStatusModel> listPoStatus = [
  PoStatusModel(code: "A", name: "All"),
  PoStatusModel(code: "P", name: "Partial"),
  PoStatusModel(code: "R", name: "To Receive"),
  PoStatusModel(code: "F", name: "Fulfilled"),
];

class FxPoStatusLk extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final String? initialValueId;
  final void Function(PoStatusModel)? onChanged;
  final bool readOnly;
  final bool isGrey;
  const FxPoStatusLk(
      {Key? key,
      this.width,
      this.labelText,
      this.hintText,
      this.initialValueId,
      this.readOnly = false,
      this.isGrey = false,
      this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? double.infinity : width!;
    final isReady = useState(false);
    final isInit = useState(true);
    final selectedValue = useState<PoStatusModel?>(null);
    final listValue = useState<List<PoStatusModel>>(List.empty());
    final errorMessage = useState("");

    if (isInit.value) {
      isInit.value = false;
      listValue.value = listPoStatus;

      selectedValue.value = listValue.value[0];
      if (initialValueId != null && initialValueId != "0") {
        try {
          selectedValue.value =
              listValue.value.firstWhere((e) => e.code == initialValueId);
        } catch (e) {}
      }
      WidgetsBinding.instance.addPostFrameCallback((tmr) async {
        if (onChanged != null && selectedValue.value != null) {
          onChanged!(selectedValue.value!);
        }
        isReady.value = true;
      });
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Container(
            width: maxWidth,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              border: Border.all(
                color: isGrey ? Colors.grey : Constants.greenDark,
                width: isGrey ? 0.8 : 1.0,
              ),
            ),
            child: isReady.value
                ? ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<PoStatusModel>(
                      icon: Image.asset(
                        "images/icon_triangle_down.png",
                        height: 36,
                      ),
                      onTap: null,
                      hint: Text(
                        hintText ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      value: selectedValue.value ?? listPoStatus[0],
                      underline: const SizedBox.shrink(),
                      isExpanded: true,
                      onChanged: readOnly
                          ? null
                          : (value) {
                              if (value != null) selectedValue.value = value;
                              if (onChanged != null && value != null)
                                onChanged!(value);
                            },
                      items: listValue.value
                          .map<DropdownMenuItem<PoStatusModel>>(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                value.name,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  /* color: Constants.greenDark, */
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(
                      15.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (errorMessage.value == "")
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          ),
                        const SizedBox(width: 10),
                        (errorMessage.value == "")
                            ? Text(
                                "Loading $labelText",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Constants.greenDark,
                                ),
                              )
                            : Text(
                                "Error ${errorMessage.value}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Constants.red,
                                ),
                              )
                      ],
                    ),
                  ),
          ),
        ),
        Positioned(
          left: 10,
          top: -2,
          child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Status",
                  style: TextStyle(
                    fontSize: 14,
                    color: Constants.greenDark,
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
