import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../model/ac_material_model.dart';
import '../provider/dio_provider.dart';
import '../repository/po_repository.dart';
import 'fx_text_field.dart';

class FxAcMr extends HookConsumerWidget {
  final double? width;
  final String value;
  final String? labelText;
  final String? hintText;
  final String? soID;
  final double? optionWidth;

  final void Function(
    double qty,
    String drumNum,
  )? onUpdateQty;
  final void Function(AcMaterialModel? model)? onSelectedMaterial;

  final String errorMessage;
  final TextEditingController ctrl;
  final FocusNode fc;
  final bool withReset;
  final bool withoutPrice;
  final bool withZebraColor;

  const FxAcMr({
    Key? key,
    this.width,
    this.optionWidth,
    this.hintText,
    this.labelText,
    this.value = "",
    this.onUpdateQty,
    this.onSelectedMaterial,
    this.errorMessage = "",
    this.soID = "0",
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
    final firstModel = useState<AcMaterialModel?>(null);
    final selectedModel = useState<AcMaterialModel?>(null);
    selectedModel.addListener(() {
      if (onSelectedMaterial != null) onSelectedMaterial!(selectedModel.value);
    });
    if (ctrl.text == "") {
      selectedModel.value = null;
    }
    ctrl.addListener(() {
      if (ctrl.text.length < 10 && selectedModel.value != null) {
        selectedModel.value = null;
      }
    });
    double xoptionWidth = optionWidth ?? maxWidth;
    return Column(
      children: [
        RawAutocomplete<AcMaterialModel>(
          focusNode: fc,
          textEditingController: ctrl,
          onSelected: (model) {
            selectedModel.value = model;
          },
          displayStringForOption: (model) {
            return model.materialCode;
          },
          fieldViewBuilder: (ctx, ctrlX, fcX, fn) {
            return FxTextField(
              errorMessage: errorMessage,
              labelText: labelText,
              hintText: hintText,
              ctrl: ctrlX,
              focusNode: fcX,
              onChanged: (v) {
                fc.requestFocus();
              },
              width: maxWidth - 42,
              onSubmitted: (v) {
                if (firstModel.value != null) {
                  ctrl.text = firstModel.value!.materialCode;
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
                              FocusScope.of(context).requestFocus(FocusNode());
                              onSelected(model);
                            },
                            child: Container(
                              color: (idx % 2 == 1 && withZebraColor)
                                  ? Colors.blue.withOpacity(0.2)
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      model.materialCode,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        model.description,
                                        style: TextStyle(
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    if (!withoutPrice)
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    if (!withoutPrice &&
                                        model.fromVendor == "Y")
                                      Text(
                                        "L/Price  ",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    if (!withoutPrice)
                                      Text(
                                        model.unitPrice,
                                        style: TextStyle(
                                          fontSize: 16,
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
              final result = await PoRepository(dio: dio).acMaterial(
                search: editingValue.text,
                vendorID:  "0",
                poID:"0",
                cancelToken: cancelToken.value,
              );
              if (result.isNotEmpty) firstModel.value = result[0];
              return result;
            } catch (e) {
              return [];
            }
          },
        ),
      ],
    );
  }
}
