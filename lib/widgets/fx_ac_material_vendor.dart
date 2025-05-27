import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/vendor_lookup_material_model.dart';
import 'package:sor_inventory/repository/vendor_repository.dart';

import '../app/constants.dart';
import '../provider/dio_provider.dart';
import '../repository/po_repository.dart';
import 'fx_text_field.dart';

class FxAutoCompletionMaterialVendor extends HookConsumerWidget {
  final double? width;
  final String value;
  final String? labelText;
  final String? hintText;
  final String vendorID;

  final void Function(
    double qty,
    String drumNum,
  )? onUpdateQty;
  final void Function(VendorLookupMaterialModel? model)? onSelectedMaterial;

  final String errorMessage;
  final TextEditingController ctrl;
  final FocusNode fc;

  const FxAutoCompletionMaterialVendor({
    Key? key,
    this.width,
    this.hintText,
    this.labelText,
    this.value = "",
    this.onUpdateQty,
    this.onSelectedMaterial,
    this.errorMessage = "",
    required this.ctrl,
    required this.fc,
    required this.vendorID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final cancelToken = useState(CancelToken());
    final firstModel = useState<VendorLookupMaterialModel?>(null);
    final selectedModel = useState<VendorLookupMaterialModel?>(null);
    selectedModel.addListener(() {
      if (onSelectedMaterial != null) onSelectedMaterial!(selectedModel.value);
    });
    if (ctrl.text == "") {
      selectedModel.value = null;
    }
    return Column(
      children: [
        RawAutocomplete<VendorLookupMaterialModel>(
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
                  width: MediaQuery.of(context).size.width - 50,
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
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        model.description,
                                        style: const TextStyle(
                                            fontSize: 14,
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
              final result = await VendorRepository(dio: dio).lookupMaterial(
                query: editingValue.text,
                vendorID: vendorID,
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
