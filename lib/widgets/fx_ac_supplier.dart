import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../model/supplier_model.dart';
import '../provider/dio_provider.dart';
import '../repository/supplier_repository.dart';
import 'fx_text_field.dart';

class FxAcSupplier extends HookConsumerWidget {
  final double? width;
  final String value;
  final String? labelText;
  final String? hintText;
  final void Function(SupplierModel)? onSelected;
  final String errorMessage;
  final TextEditingValue? initialValue;
  final bool readOnly;
  final double? optionWidth;
  final EdgeInsets? contentPadding;

  const FxAcSupplier({
    Key? key,
    this.width,
    this.hintText,
    this.labelText,
    this.value = "",
    this.onSelected,
    this.errorMessage = "",
    this.initialValue,
    this.readOnly = false,
    this.optionWidth,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final cancelToken = useState(CancelToken());
    final firstModel = useState<SupplierModel?>(null);
    final selectedModel = useState<SupplierModel?>(null);
    if (initialValue?.text == "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        selectedModel.value = null;
      });
    }
    final fc = FocusNode(canRequestFocus: true);
    return Autocomplete<SupplierModel>(
      initialValue: initialValue,
      onSelected: (model) {
        if (onSelected != null) onSelected!(model);
        selectedModel.value = model;
        firstModel.value = null;
      },
      displayStringForOption: (model) {
        return model.evSupplierName ?? "";
      },
      fieldViewBuilder: (ctx, ctrl, fcN, fn) {
        return FxTextField(
          errorMessage: errorMessage,
          readOnly: readOnly,
          enabled: !readOnly,
          labelText: labelText,
          hintText: hintText,
          suffix: Image.asset(
            "images/icon_triangle_down.png",
            height: 48,
            width: 48,
          ),
          contentPadding: contentPadding,
          ctrl: ctrl,
          onChanged: (v) {
            fcN.requestFocus();
          },
          onEditingComplete: () {
            fc.requestFocus();
          },
          focusNode: readOnly ? null : fcN,
          width: maxWidth,
          onSubmitted: (v) {
            if (firstModel.value != null) {
              ctrl.text = firstModel.value!.evSupplierName ?? "";
              if (onSelected != null) onSelected!(firstModel.value!);
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, listModel) {
        double xoptionWidth = maxWidth;
        if (optionWidth != null) {
          xoptionWidth = optionWidth!;
        }
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              width: xoptionWidth,
              decoration: BoxDecoration(
                border: Border.all(color: Constants.greenDark),
              ),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  itemCount: listModel.length,
                  itemBuilder: (context, idx) {
                    final model = listModel.elementAt(idx);
                    return InkWell(
                      onTap: () {
                        onSelected(model);
                      },
                      child: Container(
                        color: (idx % 2 == 1)
                            ? Colors.blue.withOpacity(0.05)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            model.evSupplierName ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
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
        // if (editingValue.text == "") {
        //   return [];
        // }
        try {
          cancelToken.value.cancel("Cancel Mine");
          cancelToken.value = CancelToken();
        } catch (_) {}
        final dio = ref.read(dioProvider);
        try {
          final result = await SupplierRepository(dio: dio).search(
            query: editingValue.text,
            cancelToken: cancelToken.value,
          );
          if (result.isNotEmpty) firstModel.value = result[0];
          return result;
        } catch (e) {
          return [];
        }
      },
    );
  }
}
