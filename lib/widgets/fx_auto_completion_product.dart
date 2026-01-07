import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/product_model.dart';
import 'package:sor_inventory/repository/product_repository.dart';

import '../app/constants.dart';
import '../provider/dio_provider.dart';
import '../repository/do_repository.dart';
import 'fx_text_field.dart';

class FxAutoCompletionProduct extends HookConsumerWidget {
  final double? width;
  final String value;
  final String? labelText;
  final String? hintText;
  final String invoiceID;
  final void Function(
    double qty,
    String drumNum,
  )? onUpdateQty;
  final void Function(ProductModel? model)? onSelectedProduct;

  final String errorMessage;
  final TextEditingController ctrl;
  final FocusNode fc;

  const FxAutoCompletionProduct({
    Key? key,
    this.width,
    this.hintText,
    this.labelText,
    this.value = "",
    this.onUpdateQty,
    this.onSelectedProduct,
    this.errorMessage = "",
    required this.invoiceID,
    required this.ctrl,
    required this.fc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final cancelToken = useState(CancelToken());
    final firstModel = useState<ProductModel?>(null);
    final selectedModel = useState<ProductModel?>(null);
    selectedModel.addListener(() {
      if (onSelectedProduct != null) onSelectedProduct!(selectedModel.value);
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RawAutocomplete<ProductModel>(
          focusNode: fc,
          textEditingController: ctrl,
          onSelected: (model) {
            selectedModel.value = model;
          },
          displayStringForOption: (model) {
            return model.evProductCode ?? "";
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
              suffix: Image.asset(
                "images/icon_triangle_down.png",
                height: 48,
                width: 48,
              ),
              width: maxWidth,
              onSubmitted: (v) {
                if (firstModel.value != null) {
                  ctrl.text = firstModel.value!.evProductCode ?? "";
                  selectedModel.value = firstModel.value;
                }
              },
            );
          },
          optionsViewBuilder: (context, onSelected, listModel) {
            const optionsWidth = 310.0;
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Constants.colorAppBarBg,
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: optionsWidth,
                  maxWidth: optionsWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.greenDark),
                      color: Constants.colorAppBarBg,
                    ),
                    width: optionsWidth,
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
                              // color: (idx % 2 == 1)
                              //     ? Colors.blue.withOpacity(0.2)
                              //     : null,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      model.evProductCode ?? "",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        model.evProductDescription ?? "",
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
              ),
            );
          },
          optionsBuilder: (editingValue) async {
            // if (editingValue.text == "") {
            //   return [];
            // }
            // if (editingValue.text.length >= 10) {
            //   return [];
            // }
            try {
              cancelToken.value.cancel("Cancel Mine");
              cancelToken.value = CancelToken();
            } catch (_) {}
            final dio = ref.read(dioProvider);
            try {
              final result = await ProductRepository(dio: dio).search(
                query: editingValue.text,
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
