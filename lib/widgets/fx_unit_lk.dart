import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../model/payment_term_response_model.dart';
import '../provider/dio_provider.dart';
import '../repository/base_repository.dart';
import '../repository/po_repository.dart';
import '../screen/po/selected_payment_term.dart';
import 'fx_auto_completion_unit.dart';

class FxUnitLk extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final UnitModel? initialValue;
  final String Function(UnitModel)? formatOption;
  final void Function(UnitModel)? onChanged;
  final bool looseFocus;
  final bool isPackUnit;
  final bool readOnly;
  final double labelLength;

  const FxUnitLk({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.formatOption,
    this.onChanged,
    this.looseFocus = false,
    this.isPackUnit = false,
    this.readOnly = false,
    this.labelLength = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 300.0 : width!;
    final isReady = useState(false);
    final isInit = useState(true);
    final selectedValue = useState<UnitModel?>(null);
    final listValue = useState<List<UnitModel>>(List.empty());
    final errorMessage = useState("");

    ref.listen(selectedVendorProvider, (prev, next) async {
      try {
        if (next == "0") return;
        final resp = await PoRepository(dio: ref.read(dioProvider)).unitLookup(
          search: "",
          isPack: isPackUnit ? "Y" : "N",
        );
        if (resp.isNotEmpty) {
          listValue.value = resp;
          bool found = false;
          if (initialValue != null) {
            for (int idx = 0; idx < resp.length; idx++) {
              if (initialValue!.unitId == resp[idx].unitId) {
                selectedValue.value = resp[idx];
                found = true;
              }
            }
          }
          if (!found) {
            selectedValue.value = resp[0];
          }
          if (onChanged != null && selectedValue.value != null) {
            onChanged!(selectedValue.value!);
          }
          isReady.value = true;
        }
      } catch (e) {
        if (e is BaseRepositoryException) {
          errorMessage.value = e.message;
        } else {
          errorMessage.value = e.toString();
        }
      }
    });
    if (isInit.value) {
      isInit.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) async {
        try {
          final resp = await PoRepository(dio: ref.read(dioProvider))
              .unitLookup(search: "", isPack: isPackUnit ? "Y" : "N");
          if (resp.isNotEmpty) {
            listValue.value = resp;
            bool found = false;
            if (initialValue != null) {
              for (int idx = 0; idx < resp.length; idx++) {
                if (initialValue!.unitId == resp[idx].unitId) {
                  selectedValue.value = resp[idx];
                  found = true;
                }
              }
            }
            if (!found) {
              selectedValue.value = resp[0];
            }
            if (onChanged != null && selectedValue.value != null) {
              onChanged!(selectedValue.value!);
            }
            isReady.value = true;
          }
        } catch (e) {
          if (e is BaseRepositoryException) {
            errorMessage.value = e.message;
          } else {
            errorMessage.value = e.toString();
          }
        }
      });
    }
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
              child: isReady.value
                  ? DropdownButton<UnitModel>(
                      focusNode: fcDropDown,
                      menuMaxHeight: MediaQuery.of(context).size.height / 3,
                      isExpanded: true,
                      icon: readOnly
                          ? null
                          : Image.asset(
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
                      onChanged: readOnly
                          ? null
                          : (value) {
                              if (value != null) selectedValue.value = value;
                              if (onChanged != null && value != null)
                                onChanged!(value);
                            },
                      items: listValue.value
                          .map<DropdownMenuItem<UnitModel>>(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  (formatOption != null)
                                      ? formatOption!(value)
                                      : value.unit,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: readOnly ?  Constants.greyDark : null, 
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(
                        10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (errorMessage.value == "")
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            ),
                          (errorMessage.value == "")
                              ? Expanded(
                                  child: Text(
                                    "$labelText",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Constants.greenDark,
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: Text(
                                    errorMessage.value,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Constants.red,
                                    ),
                                  ),
                                )
                        ],
                      ),
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
                style: TextStyle(
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
