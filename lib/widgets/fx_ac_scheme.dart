import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/repository/checkout_repository.dart';
import 'package:sor_inventory/widgets/fx_black_text.dart';
import 'package:sor_inventory/widgets/fx_green_dark_text.dart';

import '../app/constants.dart';
import '../model/ac_material_model.dart';
import '../provider/dio_provider.dart';
import '../repository/po_repository.dart';
import 'fx_text_field.dart';

class FxAutoCompletionScheme extends HookConsumerWidget {
  final double? width;
  final String value;
  final String? labelText;
  final String? hintText;
  final String? cpID;
  final String? staffID;
  final double? optionWidth;

  final void Function(SchemeLookupModel? model)? onSelectedScheme;

  final String errorMessage;
  final TextEditingController ctrl;
  final FocusNode fc;
  final bool withReset;
  final bool withoutPrice;
  final bool withZebraColor;

  const FxAutoCompletionScheme({
    Key? key,
    this.width,
    this.optionWidth,
    this.hintText,
    this.labelText,
    this.value = "",
    this.errorMessage = "",
    this.cpID = "0",
    this.staffID = "0",
    this.onSelectedScheme,
    this.withReset = false,
    this.withoutPrice = false,
    required this.ctrl,
    required this.fc,
    this.withZebraColor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final cancelToken = useState(CancelToken());
    final firstModel = useState<SchemeLookupModel?>(null);
    final selectedModel = useState<SchemeLookupModel?>(null);
    final prevSelectedFileNum = useState<String>("");
    selectedModel.addListener(() {
      if (onSelectedScheme != null) {
        if (prevSelectedFileNum.value != selectedModel.value?.fileNum) {
          prevSelectedFileNum.value = selectedModel.value!.fileNum!;
          onSelectedScheme!(selectedModel.value);
        }
      }
    });
    if (ctrl.text == "") {
      selectedModel.value = null;
    }
    ctrl.addListener(() {
      if (ctrl.text.length < 5 && selectedModel.value != null) {
        selectedModel.value = null;
      }
    });
    double xoptionWidth = optionWidth ?? maxWidth;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: RawAutocomplete<SchemeLookupModel>(
            focusNode: fc,
            textEditingController: ctrl,
            onSelected: (model) {
              if (model.fileNum != selectedModel.value?.fileNum) {
                selectedModel.value = model;
              }
            },
            displayStringForOption: (model) {
              return model.scheme ?? "";
            },
            fieldViewBuilder: (ctx, ctrlX, fcX, fn) {
              String? prefix;
              if (selectedModel.value?.cpFileNum != null) {
                prefix = selectedModel.value!.cpFileNum! + ". ";
              }
              return FxTextField(
                errorMessage: errorMessage,
                // labelText: labelText,
                hintText: hintText,
                ctrl: ctrlX,
                prefixFormat: prefix,
                focusNode: fcX,
                onChanged: (v) {
                  fc.requestFocus();
                },
                prefix: selectedModel.value == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.transparent)),
                          width: 60,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  selectedModel.value?.cpFileNum ?? "",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                width: maxWidth - 42,
                onSubmitted: (v) {
                  if (firstModel.value != null) {
                    ctrl.text = firstModel.value!.scheme ?? "";
                    selectedModel.value = firstModel.value;
                  }
                },
                suffix: withReset && selectedModel.value != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          child: Icon(
                            Icons.clear,
                            color: Constants.red,
                          ),
                          hoverColor: Colors.red,
                          onTap: () {
                            ctrlX.text = "";
                            selectedModel.value = null;
                          },
                        ),
                      )
                    : null,
              );
            },
            optionsViewBuilder: (context, onSelected, listModel) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.greenDark),
                    ),
                    width: xoptionWidth,
                    height: 500,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          itemCount: listModel.length,
                          itemBuilder: (context, idx) {
                            final model = listModel.elementAt(idx);
                            return InkWell(
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                onSelected(model);
                              },
                              child: Container(
                                color: (idx % 2 == 1 && withZebraColor)
                                    ? Colors.blue.withOpacity(0.2)
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        model.cpFileNum ?? "",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Text(
                                          overflow: TextOverflow.ellipsis,
                                          model.scheme ?? "",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            optionsBuilder: (editingValue) async {
              if (editingValue.text == "") {
                return [];
              }
              try {
                cancelToken.value.cancel("Cancel Mine");
                cancelToken.value = CancelToken();
              } catch (_) {}
              final dio = ref.read(dioProvider);
              try {
                final result = await CheckoutRepository(dio: dio)
                    .lookupSchemeV2(
                        search: editingValue.text,
                        cpID: cpID ?? "0",
                        staffID: staffID ?? "0");
                if (result.isNotEmpty) {
                  firstModel.value = result[0];
                }
                if (ctrl.text.length > 5 && result.isNotEmpty) {
                  for (var element in result) {
                    if (element.scheme == ctrl.text) {
                      selectedModel.value = element;
                    }
                  }
                }
                return result;
              } catch (e) {
                return [];
              }
            },
          ),
        ),
        Positioned(
          top: 5,
          left: 10,
          child: Container(
              color: Constants.colorAppBarBg,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  labelText ?? "",
                  style: TextStyle(fontSize: 12, color: Constants.greenDark),
                ),
              )),
        )
      ],
    );
  }
}
