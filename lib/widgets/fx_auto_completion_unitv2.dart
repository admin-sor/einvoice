import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../provider/dio_provider.dart';
import '../repository/do_repository.dart';
import 'fx_auto_completion_unit.dart';
import 'fx_text_field.dart';

class FxAutoCompletionUnitV2 extends HookConsumerWidget {
  final double? width;
  final String value;
  final String? labelText;
  final String? hintText;
  final void Function(UnitModel)? onSelected;
  final bool requestFocus;
  final UnitModel? initialModel;
  const FxAutoCompletionUnitV2({
    Key? key,
    this.width,
    this.hintText,
    this.labelText,
    this.value = "",
    this.onSelected,
    this.requestFocus = false,
    this.initialModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final cancelToken = useState(CancelToken());
    final firstModel = useState<UnitModel?>(null);
    final selectedModel = useState<UnitModel?>(null);
    final ctrlUnit = useTextEditingController(text: "");

    if (initialModel != null) {
      selectedModel.value = initialModel;
      ctrlUnit.text = initialModel!.unit;
    } else {
      selectedModel.value = null;
      ctrlUnit.text = "";
    }
    final fcUnit = FocusNode();

    return RawAutocomplete<UnitModel>(
      textEditingController: ctrlUnit,
      focusNode: fcUnit,
      onSelected: (model) {
        selectedModel.value = model;
        firstModel.value = null;
        if (onSelected != null) onSelected!(model);
      },
      displayStringForOption: (model) {
        return model.unit;
      },
      fieldViewBuilder: (ctx, ctrl, fc, fn) {
        return FxTextField(
          labelText: labelText,
          hintText: hintText,
          ctrl: ctrl,
          focusNode: fc,
          width: maxWidth,
          onSubmitted: (v) {
            if (firstModel.value != null) {
              ctrl.text = firstModel.value!.unit;
              if (onSelected != null) onSelected!(firstModel.value!);
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, listModel) {
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
                    itemCount: listModel.length,
                    itemBuilder: (context, idx) {
                      final model = listModel.elementAt(idx);
                      return InkWell(
                        onTap: () {
                          onSelected(model);
                        },
                        child: Container(
                          color: (idx % 2 == 1)
                              ? Colors.blue.withOpacity(0.2)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
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
