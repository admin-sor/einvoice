import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../provider/dio_provider.dart';
import '../repository/po_repository.dart';
import 'fx_text_field.dart';

class DummyPo {
  final int id;
  final String poNo;
  DummyPo({
    required this.id,
    required this.poNo,
  });
}

class FxAutoCompletionPo extends HookConsumerWidget {
  final double? width;
  final String value;
  final String? labelText;
  final String? hintText;
  final void Function(DummyPo po)? onSelected;
  final String errorMessage;
  final TextEditingController ctrl;
  final FocusNode fc;
  final String vendorID;
  final bool withZebraColor;
  final bool withReset;
  final void Function()? onReset;

  const FxAutoCompletionPo({
    Key? key,
    this.width,
    this.hintText,
    this.labelText,
    this.value = "",
    this.onSelected,
    this.errorMessage = "",
    this.withZebraColor = false,
    this.withReset = false,
    this.onReset,
    required this.vendorID,
    required this.fc,
    required this.ctrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final cancelToken = useState(CancelToken());
    final firstDpo = useState<DummyPo?>(null);
    final selectedPo = useState<DummyPo?>(null);
    late TextEditingController txtCtrl;
    
    return Autocomplete<DummyPo>(
      onSelected: (dPo) {
        if (onSelected != null) onSelected!(dPo);
        selectedPo.value = dPo;
        firstDpo.value = null;
      },
      displayStringForOption: (dPo) {
        return dPo.poNo;
      },
      fieldViewBuilder: (ctx, ctrlX, fcX, fn) {
        txtCtrl = ctrlX;
        return FxTextField(
          labelText: labelText,
          hintText: hintText,
          ctrl: ctrlX,
          focusNode: fcX,
          onChanged: (v) {
            fc.requestFocus();
          },
          suffix: withReset
              ? InkWell(
                  child: Padding(
                    padding: const EdgeInsets.only(right:10.0),
                    child: Icon(
                      Icons.clear,
                      color: Constants.red,
                    ),
                  ),
                  onTap: () {
                  ctrlX.text = "";
                  if (onReset != null ) {
                onReset!();
              }
            }) 
              : null,
          width: maxWidth,
          onSubmitted: (v) {
            if (firstDpo.value != null) {
              ctrl.text = firstDpo.value!.poNo;
              if (onSelected != null) onSelected!(firstDpo.value!);
            }
          },
          errorMessage: errorMessage,
        );
      },
      optionsViewBuilder: (context, onSelected, listPo) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(Size(maxWidth, 400)),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Constants.greenDark),
                ),
                width: maxWidth,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: listPo.length,
                    itemBuilder: (context, idx) {
                      final dPo = listPo.elementAt(idx);
                      return InkWell(
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          onSelected(dPo);
                        },
                        child: Container(
                          color: (idx % 2 == 1 && withZebraColor)
                              ? Colors.blue.withOpacity(0.2)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              dPo.poNo,
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
          ),
        );
      },
      optionsBuilder: (editingValue) async {
        if (editingValue.text == "") {
          if (onSelected != null) {
            onSelected!(DummyPo(id: 0, poNo: ""));
          }
          return [];
        }
        try {
          cancelToken.value.cancel("Cancel Mine");
          cancelToken.value = CancelToken();
        } catch (_) {}
        final dio = ref.read(dioProvider);
        try {
          final result = await PoRepository(dio: dio).search(
            search: editingValue.text,
            vendorID: vendorID,
            cancelToken: cancelToken.value,
          );
          if (result.isNotEmpty) firstDpo.value = result[0];
          return result;
        } catch (e) {
          return [];
        }
      },
    );
  }
}
