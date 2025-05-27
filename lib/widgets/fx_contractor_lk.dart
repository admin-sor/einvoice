import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../model/contractor_lookup_model.dart';
import '../provider/dio_provider.dart';
import '../repository/base_repository.dart';
import '../repository/checkout_repository.dart';

class FxContractorLk extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final ContractorLookupModel? initialValue;
  final String Function(ContractorLookupModel)? formatOption;
  final void Function(ContractorLookupModel)? onChanged;
  final bool withAll;
  final bool readOnly;
  const FxContractorLk({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.formatOption,
    this.onChanged,
    this.withAll = false,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final isReady = useState(false);
    final isInit = useState(true);
    final selectedValue = useState<ContractorLookupModel?>(null);
    final listValue = useState<List<ContractorLookupModel>>(List.empty());
    final errorMessage = useState("");

    if (isInit.value) {
      isInit.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) async {
        try {
          final resp = await CheckoutRepository(dio: ref.read(dioProvider))
              .contractorLookupV2();
          if (resp.isNotEmpty) {
            final nullContractor = ContractorLookupModel(
              cpId: "0",
              name: "Select Contractor",
              shortName: "Select Contractor",
              staffId: "0",
              staffName: "Select SO",
              scheme: "",
            );
            //resp.add(nullContractor);
            var xlist = List<ContractorLookupModel>.empty(growable: true);
            if (withAll) {
              xlist.add(ContractorLookupModel(
                cpId: "0",
                name: "All",
                shortName: "All",
                staffId: "0",
                staffName: "All",
                scheme: "",
              ));
              xlist.addAll(resp);
            } else {
              xlist = resp;
            }
            listValue.value = xlist;

            selectedValue.value = listValue.value[0];
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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Container(
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
                    child: DropdownButton<ContractorLookupModel>(
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
                      onChanged: readOnly
                          ? null
                          : (value) {
                              if (value != null) selectedValue.value = value;
                              if (onChanged != null && value != null)
                                onChanged!(value);
                            },
                      items: listValue.value
                          .map<DropdownMenuItem<ContractorLookupModel>>(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                (formatOption != null)
                                    ? formatOption!(value)
                                    : value.name == "All"
                                        ? "All"
                                        : value.staffName,
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 10.0,
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
          ),
        ),
        Positioned(
          left: 10,
          top: -2,
          child: Container(
            color: Colors.white,
            child: const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "SO",
                style: TextStyle(
                  fontSize: 14,
                  color: Constants.greenDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
