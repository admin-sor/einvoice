import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../provider/dio_provider.dart';
import '../repository/do_repository.dart';
import 'fx_auto_completion_unit.dart';
import 'fx_text_field.dart';

class FxAutoCompletionPackUnit extends HookConsumerWidget {
  final double? width;
  final String? labelText;
  final String? hintText;
  final void Function(UnitModel)? onSelected;
  final FocusNode fc;
  final TextEditingController ctrl;
  final String? errorMessage;
  final bool enabled;
  final bool readOnly;
  final bool withZebraColor;
  const FxAutoCompletionPackUnit({
    Key? key,
    this.width,
    this.hintText,
    this.labelText,
    this.onSelected,
    this.errorMessage,
    this.enabled = true,
    this.readOnly = false,
    required this.ctrl,
    required this.fc,
    this.withZebraColor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final firstModel = useState<UnitModel?>(null);
    final selectedModel = useState<UnitModel?>(null);
    return RawAutocomplete<UnitModel>(
      textEditingController: ctrl,
      focusNode: fc,
      onSelected: (model) {
        if (onSelected != null) onSelected!(model);
        selectedModel.value = model;
        firstModel.value = null;
      },
      displayStringForOption: (model) {
        return model.unit;
      },
      fieldViewBuilder: (ctx, ctrlX, fcX, onChanged) {
        return FxTextField(
          labelText: labelText,
          focusNode: fcX,
          hintText: hintText,
          errorMessage: errorMessage ?? "",
          enabled: enabled,
          readOnly: readOnly,
          ctrl: ctrlX,
          width: maxWidth,
          onEditingComplete: () {
            fcX.requestFocus();
          },
          onSubmitted: (v) {
            if (firstModel.value != null) {
              ctrl.text = firstModel.value!.unit;
              if (onSelected != null) {
                onSelected!(firstModel.value!);
              }
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
                          FocusScope.of(context).requestFocus(FocusNode());
                          onSelected(model);
                        },
                        child: Container(
                          color: (idx % 2 == 1 && withZebraColor)
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
        final dio = ref.read(dioProvider);
        try {
          final result = await DoRepository(dio: dio).unitLookup(
            search: "", //editingValue.text,
            isPack: "Y",
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
