import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../model/ac_material_model.dart';
import '../provider/dio_provider.dart';
import '../repository/do_repository.dart';
import 'fx_text_field.dart';

class FxAutoCompletionMaterial extends HookConsumerWidget {
  final double? width;
  final String value;
  final String? labelText;
  final String? hintText;
  final String poID;
  final void Function(
    double qty,
    String drumNum,
  )? onUpdateQty;
  final void Function(AcMaterialModel? model)? onSelectedMaterial;

  final String errorMessage;
  final TextEditingController ctrl;
  final FocusNode fc;

  const FxAutoCompletionMaterial({
    Key? key,
    this.width,
    this.hintText,
    this.labelText,
    this.value = "",
    this.onUpdateQty,
    this.onSelectedMaterial,
    this.errorMessage = "",
    required this.poID,
    required this.ctrl,
    required this.fc,
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
    ctrl.addListener(
      () {
        if (ctrl.text.length < 10) {
          if (selectedModel.value != null) {
            selectedModel.value = null;
          }
        }
      },
    );
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
              width: maxWidth,
              onSubmitted: (v) {
                if (firstModel.value != null) {
                  ctrl.text = firstModel.value!.materialCode;
                  selectedModel.value = firstModel.value;
                }
              },
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
                  width: kIsWeb
                      ? Constants.webWidth - 40
                      : MediaQuery.of(context).size.width - 50,
                  height: 500,
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
                            color: (idx % 2 == 1)
                                ? Colors.blue.withOpacity(0.2)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Text(
                                    model.materialCode,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      model.description,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  )
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
            );
          },
          optionsBuilder: (editingValue) async {
            if (editingValue.text == "") {
              return [];
            }
            if (editingValue.text.length >= 10) {
              return [];
            }
            try {
              cancelToken.value.cancel("Cancel Mine");
              cancelToken.value = CancelToken();
            } catch (_) {}
            final dio = ref.read(dioProvider);
            try {
              final result = await DoRepository(dio: dio).acMaterial(
                search: editingValue.text,
                poID: poID,
                cancelToken: cancelToken.value,
              );
              if (result.isNotEmpty) firstModel.value = result[0];
              return result;
            } catch (e) {
              return [];
            }
          },
        ),
        /*
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            FxTextField(
              errorMessage: errorMessageDrumNo,
              enabled: selectedModel.value?.isCable == "Y",
              width: maxWidth / 2 - 40,
              ctrl: ctrlDrumNum,
              focusNode: fcDrumNum,
              hintText: "Drum No.",
              labelText: "Drum No.",
            ),
            FxTextField(
                errorMessage: errorMessageQty,
                width: maxWidth / 2,
                ctrl: ctrlQty,
                hintText: "Received Qty",
                labelText: "Received Qty"),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            FxTextField(
              enabled: false,
              width: maxWidth / 3 - 10,
              ctrl: ctrlUnit,
              hintText: "Unit",
              labelText: "Unit",
            ),
            FxAutoCompletionUnit(
              width: maxWidth / 3 - 10,
              labelText: "Pack Unit",
              hintText: "Pack Unit",
              value: selectedPackUnit.value?.unit ?? "",
              onSelected: (model) {
                selectedPackUnit.value = model;
              },
              initialModel: selectedPackUnit.value,
            ),
            FxTextField(
              errorMessage: errorMessagePackQty,
              width: maxWidth / 3 - 10,
              ctrl: ctrlPackQty,
              hintText: "Pack Qty",
              labelText: "Pack Qty",
            ),
          ],
        )
        */
      ],
    );
  }
}
