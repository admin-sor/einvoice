import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/scrap_model.dart';
import 'package:sor_inventory/repository/dispose_repository.dart';
import 'package:sor_inventory/screen/dispose/dispose_store_provider.dart';
import 'package:sor_inventory/screen/dispose/req_reload_dispose_material.dart';

import '../app/constants.dart';
import '../provider/dio_provider.dart';
import '../provider/shared_preference_provider.dart';
import '../repository/base_repository.dart';

class FxDisposableMaterialLk extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final ScrapModel? initialValue;
  final String Function(ScrapModel)? formatOption;
  final void Function(ScrapModel)? onChanged;
  final bool looseFocus;
  final bool readOnly;
  final String storeID;
  final void Function(ScrapModel)? onBarcodeChoose;
  final bool enabled;
  const FxDisposableMaterialLk({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.formatOption,
    this.onChanged,
    this.looseFocus = false,
    this.readOnly = false,
    this.storeID = "0",
    this.onBarcodeChoose,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 200.0 : width!;
    final isReady = useState(false);
    final isInit = useState(true);
    final selectedValue = useState<ScrapModel?>(null);
    final listValue = useState<List<ScrapModel>>(List.empty());
    final errorMessage = useState("");
    final isBarcodeClicked = useState(false);
    ref.listen(reqReloadDisposeMaterial, (previous, next) async {
      try {
        final loginModel = await ref.read(localAuthProvider.future);
        var xstoreID = ref.read(disposeSelectedStoreProvider)["id"];
        final resp = await DisposeRepository(dio: ref.read(dioProvider))
            .getMaterial(xstoreID, loginModel?.token ?? "");
        if (resp.isNotEmpty) {
          listValue.value = resp;
          bool found = false;
          for (int idx = 0; idx < resp.length; idx++) {
            if (selectedValue.value != null) {
              if (selectedValue.value!.scrapBarcode == resp[idx].scrapBarcode) {
                // selectedValue.value = resp[idx];
                found = true;
                break;
              }
            }
          }
          if (!found) {
            // selectedValue.value = resp[0];
          }
          if (onChanged != null && selectedValue.value != null) {
            // onChanged!(selectedValue.value!);
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
    ref.listen(disposeSelectedStoreProvider, (prev, next) async {
      try {
        if (next == null) return;
        Map<String,dynamic> store = jsonDecode(next.toString());
        if (store["id"] == "0") {
          isReady.value = true;
          return;
        }
        final loginModel = await ref.read(localAuthProvider.future);
        final resp = await DisposeRepository(dio: ref.read(dioProvider))
            .getMaterial(store["id"], loginModel?.token ?? "");
        if (resp.isNotEmpty) {
          listValue.value = resp;
          bool found = false;
          for (int idx = 0; idx < resp.length; idx++) {
            if (selectedValue.value != null) {
              if (selectedValue.value!.scrapBarcode == resp[idx].scrapBarcode) {
                 //selectedValue.value = resp[idx];
                found = true;
                break;
              }
            }
          }
          // if (!found) {
          //   selectedValue.value = resp[0];
          // }
          // if (onChanged != null && selectedValue.value != null) {
          //   onChanged!(selectedValue.value!);
          // }
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
          final loginModel = await ref.read(localAuthProvider.future);
          final resp = await DisposeRepository(dio: ref.read(dioProvider))
              .getMaterial(storeID, loginModel?.token ?? "");
          if (resp.isNotEmpty) {
            listValue.value = resp;
            bool found = false;

            for (int idx = 0; idx < resp.length; idx++) {
              if (initialValue != null) {
                if (initialValue!.scrapBarcode == resp[idx].scrapBarcode) {
                  // selectedValue.value = resp[idx];
                  found = true;
                  break;
                }
              }
            }
            if (!found) {
              // selectedValue.value = resp[0];
            }
            if (onChanged != null && selectedValue.value != null) {
              // onChanged!(selectedValue.value!);
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
                      child: DropdownButton<ScrapModel>(
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
                                if (value != null) selectedValue.value = value;
                                if (onChanged != null && value != null) {}
                                isBarcodeClicked.value = false;
                              },
                        items:
                            listValue.value.map<DropdownMenuItem<ScrapModel>>(
                          (value) {
                            String sDate = value.scrapDate ?? "";
                            try {
                              final sdf = DateFormat("y-M-d H:m:s");
                              final sdfshort = DateFormat("d/M/y");
                              sDate = sdfshort.format(sdf.parse(sDate));
                            } catch (e) {}
                            String sCheckoutQty = value.scrapPackQty ?? "";
                            try {
                              double dCheckoutQty =
                                  double.parse(value.scrapPackQty ?? "");
                              if (dCheckoutQty - dCheckoutQty.toInt() == 0) {
                                sCheckoutQty = dCheckoutQty.toInt().toString();
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
                                            onBarcodeChoose!(value);
                                            if (value.scrapBarcode == "")
                                              return;
                                            Timer(Duration(seconds: 1), () {
                                              var xlist = listValue.value;
                                              xlist.remove(value);
                                              listValue.value = xlist;
                                              if (xlist.isEmpty) {
                                                selectedValue.value = null;
                                              } else {
                                                selectedValue.value = xlist[0];
                                              }
                                            });
                                          }
                                        : null,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                value.materialCode ?? "",
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  /* color: Constants.greenDark, */
                                                  // height: 1.2,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                value.description ?? "",
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  /* color: Constants.greenDark, */
                                                  // height: 1.2,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          value.scrapBarcode ?? "",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            /* color: Constants.greenDark, */
                                            fontSize: 16,
                                            // height: 1.2,
                                          ),
                                        ),
                                        SizedBox(width: 10),
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
                                    padding: const EdgeInsets.only(left: 10.0),
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
  }
}
