import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../provider/dio_provider.dart';
import '../repository/do_repository.dart';
import 'fx_text_field.dart';

class UnitModel {
  late String unit;
  late String unitDesc;
  late String unitId;

  UnitModel({
    required this.unit,
    required this.unitDesc,
    required this.unitId,
  });

  UnitModel.fromJson(Map<String, dynamic> json) {
    unit = json['unit'];
    unitDesc = json['unit_desc'] ?? "";
    unitId = json['unit_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unit'] = unit;
    data['unit_desc'] = unitDesc;
    data['unit_id'] = unitId;
    return data;
  }
}

class FxAutoCompletionUnit extends HookConsumerWidget {
  final double? width;
  final String? labelText;
  final String? hintText;
  final void Function(UnitModel)? onSelected;
  final FocusNode focusNode;
  final TextEditingController ctrlUnit;
  final bool readOnly;

  FxAutoCompletionUnit(
      {Key? key,
      this.width,
      this.hintText,
      this.labelText,
      this.onSelected,
      required this.focusNode,
      required this.ctrlUnit,
      this.readOnly = false})
      : super(key: key);

  final _textFieldKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final cancelToken = useState(CancelToken());
    final firstModel = useState<UnitModel?>(null);
    final selectedModel = useState<UnitModel?>(null);

    return RawAutocomplete<UnitModel>(
      onSelected: (model) {
        if (onSelected != null) onSelected!(model);
        selectedModel.value = model;
        firstModel.value = null;
      },
      displayStringForOption: (model) {
        return model.unit;
      },
      fieldViewBuilder: (ctx, ctrl, fc, onChanged) {
        return FxTextField(
          key: _textFieldKey,
          labelText: labelText,
          hintText: hintText,
          focusNode: readOnly ? null : fc,
          ctrl: ctrl,
          readOnly: readOnly,
          enabled: !readOnly,
          width: maxWidth,
          onChanged: (v) {
            //onChanged();
          },
          onSubmitted: (v) {
            if (firstModel.value != null) {
              ctrl.text = firstModel.value!.unit;
              if (onSelected != null) onSelected!(firstModel.value!);
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, listModel) {
        final textFieldBox =
            _textFieldKey.currentContext!.findRenderObject() as RenderBox;
        final textFieldWidth = textFieldBox.size.width;
        focusNode.requestFocus();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Constants.greenDark),
              ),
              width: textFieldWidth,
              height: MediaQuery.of(context).size.height / 3,
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
                        // color: (idx % 2 == 1)
                        //     ? Colors.blue.withOpacity(0.2)
                        //     : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          child: Text(
                            model.unit,
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
          final result = await DoRepository(dio: dio).unitLookup(
            search: editingValue.text,
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
