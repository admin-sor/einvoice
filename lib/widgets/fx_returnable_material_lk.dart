import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sor_inventory/model/material_return_model_v2.dart';
import 'package:sor_inventory/repository/material_return_repository.dart';
import 'package:sor_inventory/screen/material_return/req_reload_material.dart';
import 'package:sor_inventory/screen/material_return/selected_mr_cp_provider.dart';
import 'package:sor_inventory/screen/mr_auto/selected_mr_cp_provider.dart';

import '../app/constants.dart';
import '../model/payment_term_response_model.dart';
import '../provider/dio_provider.dart';
import '../repository/base_repository.dart';
import '../repository/po_repository.dart';
import '../screen/po/selected_payment_term.dart';

class FxReturnableMaterialLk extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final ResponseReturnableMaterialModel? initialValue;
  final String Function(ResponseReturnableMaterialModel)? formatOption;
  final void Function(ResponseReturnableMaterialModel)? onChanged;
  final bool looseFocus;
  final bool readOnly;
  final String soID;
  final void Function(String)? onBarcodeChoose;
  final bool enabled;
  final bool isMobile;
  const FxReturnableMaterialLk({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.formatOption,
    this.onChanged,
    this.looseFocus = false,
    this.readOnly = false,
    this.soID = "0",
    this.onBarcodeChoose,
    this.isMobile = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 200.0 : width!;
    final isReady = useState(false);
    final isInit = useState(true);
    final selectedValue = useState<ResponseReturnableMaterialModel?>(null);
    final listValue =
        useState<List<ResponseReturnableMaterialModel>>(List.empty());
    final errorMessage = useState("");
    final isBarcodeClicked = useState(false);

    ref.listen(reqReloadMaterial, (previous, next) async {
      try {
        String soID = ref.watch(selectedMrSoIDProvider).toString();
        if (soID == "0") {
          isReady.value = true;
          return;
        }
        final resp = await MaterialReturnRepository(dio: ref.read(dioProvider))
            .getMaterial(soID);
        if (resp.isNotEmpty) {
          listValue.value = resp;
          bool found = false;
          for (int idx = 0; idx < resp.length; idx++) {
            if (selectedValue.value != null) {
              if (selectedValue.value!.barcode == resp[idx].barcode) {
                selectedValue.value = resp[idx];
                found = true;
                break;
              }
            }
          }
          if (!found) {
            selectedValue.value = resp[0];
          }
          if (onChanged != null && selectedValue.value != null) {
            onChanged!(selectedValue.value!);
          }
          isReady.value = true;
        } else {
          listValue.value = List.empty();
          selectedValue.value = null;
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
    ref.listen(selectedMrSoIDProvider, (prev, next) async {
      try {
        String soID = next.toString();
        if (soID == "0") {
          isReady.value = true;
          return;
        }
        final resp = await MaterialReturnRepository(dio: ref.read(dioProvider))
            .getMaterial(soID);
        if (resp.isNotEmpty) {
          listValue.value = resp;
          bool found = false;
          for (int idx = 0; idx < resp.length; idx++) {
            if (selectedValue.value != null) {
              if (selectedValue.value!.barcode == resp[idx].barcode) {
                selectedValue.value = resp[idx];
                found = true;
                break;
              }
            }
          }
          if (!found) {
            selectedValue.value = resp[0];
          }
          if (onChanged != null && selectedValue.value != null) {
            onChanged!(selectedValue.value!);
          }
          isReady.value = true;
        } else {
          listValue.value = List.empty();
          selectedValue.value = null;
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
          final resp =
              await MaterialReturnRepository(dio: ref.read(dioProvider))
                  .getMaterial(soID);
          if (resp.isNotEmpty) {
            listValue.value = resp;
            bool found = false;

            for (int idx = 0; idx < resp.length; idx++) {
              if (initialValue != null) {
                if (initialValue!.barcode == resp[idx].barcode) {
                  selectedValue.value = resp[idx];
                  found = true;
                  break;
                }
              }
            }
            if (!found) {
              selectedValue.value = resp[0];
            }
            if (onChanged != null && selectedValue.value != null) {
              onChanged!(selectedValue.value!);
            }
            isReady.value = true;
          } else {
            isReady.value = true;
            listValue.value = List.empty();
            selectedValue.value = null;
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
    return ResponsiveBuilder(builder: (context, sz) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(
                Size(maxWidth, 50),
              ),
              child: Container(
                alignment: Alignment.centerLeft,
                width: maxWidth,
                height: 50,
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
                    ? ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<ResponseReturnableMaterialModel>(
                          focusNode: fcDropDown,
                          isExpanded: true,
                          isDense: true,
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
                          onChanged: !enabled
                              ? null
                              : (value) {
                                  if (value != null)
                                    selectedValue.value = value;
                                  if (onChanged != null && value != null) {
                                    //onChanged!(value);
                                    // onBarcodeChoose!(value.barcode!);
                                    // Timer(Duration(seconds: 1), () {
                                    //   var xlist = listValue.value;
                                    //   xlist.remove(value);
                                    //   listValue.value = xlist;
                                    // });
                                    // if (isBarcodeClicked.value) {
                                    //   Navigator.of(context).pop();
                                    // }
                                  }
                                  isBarcodeClicked.value = false;
                                },
                          items: listValue.value.map<
                              DropdownMenuItem<
                                  ResponseReturnableMaterialModel>>(
                            (value) {
                              String sDate = value.checkoutDate ?? "";
                              try {
                                final sdf = DateFormat("y-M-d H:m:s");
                                final sdfshort = DateFormat("d/M/y");
                                sDate = sdfshort.format(sdf.parse(sDate));
                              } catch (e) {}
                              String sCheckoutQty = value.checkoutPackQty ?? "";
                              try {
                                double dCheckoutQty =
                                    double.parse(value.checkoutPackQty ?? "");
                                if (dCheckoutQty - dCheckoutQty.toInt() == 0) {
                                  sCheckoutQty =
                                      dCheckoutQty.toInt().toString();
                                }
                              } catch (e) {}
                              return DropdownMenuItem(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    removeBottom: true,
                                    child: InkWell(
                                      onTap: enabled && onBarcodeChoose != null
                                          ? () {
                                              isBarcodeClicked.value = true;
                                              onBarcodeChoose!(value.barcode!);
                                              if (value.barcode == "") return;
                                              Timer(Duration(seconds: 1), () {
                                                var xlist = listValue.value;
                                                //disable remove barcode
                                                //xlist.remove(value);
                                                listValue.value = xlist;
                                                if (xlist.isEmpty) {
                                                  selectedValue.value = null;
                                                } else {
                                                  selectedValue.value =
                                                      xlist[0];
                                                }
                                              });
                                            }
                                          : null,
                                      child: Row(
                                        children: [
                                          Text(
                                            value.barcode ?? "",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              /* color: Constants.greenDark, */
                                              // height: 1.2,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              value.description ?? "",
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                /* color: Constants.greenDark, */
                                                // height: 1.2,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          if (!isMobile) SizedBox(width: 10),
                                          if (!isMobile)
                                            Text(
                                              value.code ?? "",
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                /* color: Constants.greenDark, */
                                                fontSize: 16,
                                                // height: 1.2,
                                              ),
                                            ),
                                          if (!isMobile) SizedBox(width: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
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
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        "$labelText",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Constants.greenDark,
                                        ),
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              color: Colors.white,
              width: 150,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  labelText ?? "",
                  style: TextStyle(color: Constants.greenDark),
                ),
              ),
            ),
          )
        ],
      );
    });
  }
}
