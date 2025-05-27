import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../provider/dio_provider.dart';
import '../repository/do_repository.dart';
import 'fx_text_field.dart';

class VendorModel {
  late String vendorID;
  late String vendorName;
  late String paymentTermID;
  late String autoPo;

  VendorModel(
      {required this.vendorID,
      required this.vendorName,
      this.paymentTermID = "3",
      this.autoPo = "Y"});

  VendorModel.fromJson(Map<String, dynamic> json) {
    vendorID = json['vendorID'];
    vendorName = json['vendorName'];
    paymentTermID = json['paymentTermID'] ?? "3";
    autoPo = json['autoPo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vendorID'] = vendorID;
    data['vendorName'] = vendorName;
    data['paymentTermID'] = paymentTermID;
    data['autoPo'] = autoPo;
    return data;
  }
}

class FxAutoCompletionVendor extends HookConsumerWidget {
  final double? width;
  final String value;
  final String? labelText;
  final String? hintText;
  final void Function(VendorModel)? onSelected;
  final String errorMessage;
  final FocusNode? fc;
  final TextEditingController? ctrl;
  final TextEditingValue? initialValue;
  final bool withAll;
  final double? optionWidth;
  final EdgeInsets? contentPadding;
  final bool withZebraColor;
  const FxAutoCompletionVendor(
      {Key? key,
      this.width,
      this.hintText,
      this.labelText,
      this.value = "",
      this.onSelected,
      this.errorMessage = "",
      this.initialValue,
      this.ctrl,
      this.fc,
      this.optionWidth,
      this.withZebraColor = false,
      this.withAll = false,
      this.contentPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final cancelToken = useState(CancelToken());
    final firstModel = useState<VendorModel?>(null);
    final selectedModel = useState<VendorModel?>(null);
    if (initialValue?.text == "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        selectedModel.value = null;
      });
    }
    final fc = FocusNode(canRequestFocus: true);
    return Autocomplete<VendorModel>(
      initialValue: initialValue,
      onSelected: (model) {
        if (onSelected != null) onSelected!(model);
        selectedModel.value = model;
        firstModel.value = null;
      },
      displayStringForOption: (model) {
        return model.vendorName;
      },
      fieldViewBuilder: (ctx, ctrl, fcN, fn) {
        return FxTextField(
          contentPadding: contentPadding,
          errorMessage: errorMessage,
          labelText: labelText,
          hintText: hintText,
          ctrl: ctrl,
          onChanged: (v) {
            fcN.requestFocus();
          },
          onEditingComplete: () {
            fc.requestFocus();
          },
          focusNode: fcN,
          width: maxWidth,
          onSubmitted: (v) {
            if (firstModel.value != null) {
              ctrl.text = firstModel.value!.vendorName;
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
              decoration: BoxDecoration(
                border: Border.all(color: Constants.greenDark),
              ),
              width: xoptionWidth,
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
                        color: (idx % 2 == 1 && withZebraColor)
                            ? Colors.blue.withOpacity(0.2)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            model.vendorName,
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
        if (editingValue.text == "") {
          return [];
        }
        try {
          cancelToken.value.cancel("Cancel Mine");
          cancelToken.value = CancelToken();
        } catch (_) {}
        final dio = ref.read(dioProvider);
        try {
          final result = await DoRepository(dio: dio).vendorLookup(
            search: editingValue.text,
            cancelToken: cancelToken.value,
          );
          if (withAll) {
            result.insert(
              0,
              VendorModel(vendorID: "", vendorName: "All"),
            );
          }
          if (result.isNotEmpty) firstModel.value = result[0];
          return result;
        } catch (e) {
          return [];
        }
      },
    );
  }
}
