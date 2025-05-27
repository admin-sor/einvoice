import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/regional_office_model.dart';
import 'package:sor_inventory/repository/store_repository.dart';

import '../app/constants.dart';
import '../provider/dio_provider.dart';
import '../repository/base_repository.dart';

class FxRegionalOfficeLk extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final String? initialValueId;
  final String Function(RegionalOfficeModel)? formatOption;
  final void Function(RegionalOfficeModel)? onChanged;
  final bool withAll;
  final bool readOnly;
  const FxRegionalOfficeLk({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    this.initialValueId,
    this.formatOption,
    this.onChanged,
    this.withAll = false,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? double.infinity : width!;
    final isReady = useState(false);
    final isInit = useState(true);
    final selectedValue = useState<RegionalOfficeModel?>(null);
    final listValue = useState<List<RegionalOfficeModel>>(List.empty());
    final errorMessage = useState("");

    if (isInit.value) {
      isInit.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) async {
        try {
          final resp = await StoreRepository(dio: ref.read(dioProvider))
              .getRegional();
          if (resp.isNotEmpty) {
            var xlist = List<RegionalOfficeModel>.empty(growable: true);
            if (withAll) {
              xlist.add(RegionalOfficeModel(
                regionId: "0",
                region: "All",
              ));
              xlist.addAll(resp);
            } else {
              xlist = resp;
            }
            listValue.value = xlist;

            selectedValue.value = listValue.value[0];
            if (initialValueId != null ) {
              try {
                selectedValue.value = listValue.value.firstWhere((e) => e.regionId == initialValueId);
              } catch(e) {
              }
            }
            if (onChanged != null && selectedValue.value != null) {
              onChanged!(selectedValue.value!);
            }
            isReady.value = true;
          }
        } catch (e) {
          if (e is BaseRepositoryException) {
            errorMessage.value = e.message;
          } else {
            errorMessage.value = e.toString();
          }
        }
      });
    }
    return Container(
      width: maxWidth,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: Constants.greenDark,
        ),
      ),
      child: isReady.value
          ? ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<RegionalOfficeModel>(
                icon: Image.asset(
                  "images/icon_triangle_down.png",
                  height: 36,
                ),
                hint: Text(
                  hintText ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                value: selectedValue.value,
                underline: const SizedBox.shrink(),
                isExpanded: true,
                onChanged: readOnly ? null : (value) {
                  if (value != null) selectedValue.value = value;
                  if (onChanged != null && value != null) onChanged!(value);
                },
                items: listValue.value
                    .map<DropdownMenuItem<RegionalOfficeModel>>(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          (formatOption != null)
                              ? formatOption!(value)
                              : value.region! == "All"
                                  ? "All"
                                  : value.region!,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            /* color: Constants.greenDark, */
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(
                10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (errorMessage.value == "")
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    ),
                  const SizedBox(width: 10),
                  (errorMessage.value == "")
                      ? Text(
                          "Loading $labelText",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Constants.greenDark,
                          ),
                        )
                      : Text(
                          "Error ${errorMessage.value}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Constants.red,
                          ),
                        )
                ],
              ),
            ),
    );
  }
}
