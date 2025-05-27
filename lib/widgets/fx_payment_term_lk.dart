import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../model/payment_term_response_model.dart';
import '../provider/dio_provider.dart';
import '../repository/base_repository.dart';
import '../repository/po_repository.dart';
import '../screen/po/selected_payment_term.dart';

class FxPaymentTermLk extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final PaymentTermResponseModel? initialValue;
  final String Function(PaymentTermResponseModel)? formatOption;
  final void Function(PaymentTermResponseModel)? onChanged;
  final bool looseFocus;
  final String vendorID;
  final bool readOnly;

  const FxPaymentTermLk({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.formatOption,
    this.onChanged,
    this.looseFocus = false,
    required this.vendorID,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 200.0 : width!;
    final isReady = useState(false);
    final isInit = useState(true);
    final selectedValue = useState<PaymentTermResponseModel?>(null);
    final listValue = useState<List<PaymentTermResponseModel>>(List.empty());
    final errorMessage = useState("");

    ref.listen(selectedVendorProvider, (prev, next) async {
      try {
        String theVendorID = next.toString();
        if (next == "0") return;
        final resp = await PoRepository(dio: ref.read(dioProvider))
            .paymentTermLookup(vendorID: theVendorID);
        if (resp.isNotEmpty) {
          listValue.value = resp;
          bool found = false;
          for (int idx = 0; idx < resp.length; idx++) {
            if (selectedValue.value != null) {
              if (selectedValue.value!.paymentTermID ==
                  resp[idx].paymentTermID) {
                selectedValue.value = resp[idx];
                found = true;
                break;
              }
            }
            if (!found && resp[idx].isDefault == "Y") {
              selectedValue.value = resp[idx];
              found = true;
              break;
            }
          }
          if (!found) {
            selectedValue.value = resp[0];
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
    if (isInit.value) {
      isInit.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) async {
        try {
          final resp = await PoRepository(dio: ref.read(dioProvider))
              .paymentTermLookup(vendorID: vendorID);
          if (resp.isNotEmpty) {
            listValue.value = resp;
            bool found = false;

            for (int idx = 0; idx < resp.length; idx++) {
              if (initialValue != null) {
                if (initialValue!.paymentTermID == resp[idx].paymentTermID) {
                  selectedValue.value = resp[idx];
                  found = true;
                  break;
                }
              }
              if (resp[idx].isDefault == "Y") {
                selectedValue.value = resp[idx];
                found = true;
              }
            }
            if (!found) {
              selectedValue.value = resp[0];
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
    final fcDropDown = FocusNode();
    final isFocused = useState(false);
    if (looseFocus) {
      isFocused.value = false;
    }
    fcDropDown.addListener(() {
      if (fcDropDown.hasFocus) {
        isFocused.value = true;
      } else {
        isFocused.value = false;
      }
    });
    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        Size(maxWidth, 40),
      ),
      child: Container(
        width: maxWidth,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(
            color: isFocused.value
                ? Constants.greenDark
                : Colors.grey.withOpacity(0.4),
          ),
        ),
        child: isReady.value
            ? DropdownButton<PaymentTermResponseModel>(
                focusNode: fcDropDown,
                isExpanded: true,
                icon: readOnly
                    ? null
                    : Image.asset(
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
                onChanged: (value) {
                  if (value != null) selectedValue.value = value;
                  if (onChanged != null && value != null) onChanged!(value);
                },
                items: listValue.value
                    .map<DropdownMenuItem<PaymentTermResponseModel>>(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            (formatOption != null)
                                ? formatOption!(value)
                                : value.paymentTermName,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              /* color: Constants.greenDark, */
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            : Padding(
                padding: const EdgeInsets.all(
                  10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorMessage.value == "")
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      ),
                    (errorMessage.value == "")
                        ? Expanded(
                            child: Text(
                              "$labelText",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Constants.greenDark,
                              ),
                            ),
                          )
                        : Expanded(
                            child: Text(
                              errorMessage.value,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Constants.red,
                              ),
                            ),
                          )
                  ],
                ),
              ),
      ),
    );
  }
}
