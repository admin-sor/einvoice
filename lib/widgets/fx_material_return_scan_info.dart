import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sor_inventory/screen/material_return/mr_delete_provider.dart';
import 'package:sor_inventory/screen/material_return/selected_mr_cp_provider.dart';

import '../app/constants.dart';
import '../model/material_return_scan_response.dart';
import '../screen/material_return/save_material_return_provider.dart';
import 'fx_gray_dark_text.dart';
import 'fx_green_dark_text.dart';
import 'fx_text_field.dart';
import 'dart:html' as html;

class FxMaterialReturnScanInfo extends HookConsumerWidget {
  final bool isFirst;
  final bool inEditMode;
  final bool isDeleteOnly;
  final int index;
  final MaterialReturnScanResponseModelV2 model;
  final Function(String packSize) packsizeChange;
  final TextEditingController ctrlEdit;
  final Function(String checkoutID)? afterDelete;
  final String errorEditMessage;
  final Function(String value, int idx)? onEditChange;
  final Function(int idx)? requestEdit;
  final Function()? resetIsDone;
  final Function(int idx)? doSave;
  final Function(String isScrap)? isScrapChange;
  final Function(MaterialReturnScanResponseModelV2 model) onCancel;
  final Function(MaterialReturnScanResponseModelV2 model) onDelete;
  final bool isNew;

  const FxMaterialReturnScanInfo({
    super.key,
    required this.model,
    this.isFirst = false,
    required this.packsizeChange,
    required this.ctrlEdit,
    this.afterDelete,
    this.inEditMode = false,
    required this.index,
    this.isDeleteOnly = false,
    this.requestEdit,
    this.doSave,
    this.onEditChange,
    this.resetIsDone,
    required this.onCancel,
    required this.onDelete,
    this.isScrapChange,
    this.isNew = false,
    this.errorEditMessage = "",
  });

  String removeZeroQty(String inp) {
    String sResultQty = inp;
    try {
      double dCheckoutQty = double.parse(inp);
      if (dCheckoutQty - dCheckoutQty.toInt() == 0) {
        sResultQty = dCheckoutQty.toInt().toString();
      }
    } catch (e) {}
    return sResultQty;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final isDeleteLoading = useState(false);
    final errorMessage = useState("");
    final packsizeCurrent = useState(model.packsizeCurrent);
    final isScrap = useState("N");
    WidgetsBinding.instance.addPostFrameCallback((tmr) async {
      if (model.mrID != "0") {
        isScrap.value = model.isScrap;
      }
    });
    ref.listen(saveMaterialReturnStateProvider, (prev, next) {
      if (next is SaveMaterialReturnStateLoading) {
        isLoading.value = true;
      } else if (next is SaveMaterialReturnStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is SaveMaterialReturnStateDone) {
        isLoading.value = false;
        packsizeChange(next.packQty);
      }
    });
    ref.listen(mrDeleteStateProvider, ((previous, next) {
      if (next is DeleteMaterialReturnStateLoading) {
        isDeleteLoading.value = true;
      } else if (next is DeleteMaterialReturnStateError) {
        isDeleteLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is DeleteMaterialReturnStateDone) {
        isDeleteLoading.value = false;
        if (afterDelete != null) afterDelete!(next.checkoutID);
      }
    }));
    return ResponsiveBuilder(builder: (context, sizeinfo) {
      String itemQty = "-";
      try {
        itemQty = "1"; //(double.parse(model.doDetailQty)).round().toString();
      } catch (_) {}

      String totalQty = "-";
      try {
        totalQty = (double.parse(model.packsizeCurrent)).round().toString();
      } catch (e) {
        /* print(e.toString()); */
      }
      String packQty = "-";
      try {
        packQty = double.parse(model.packsizeCurrent).round().toString();
      } catch (_) {}
      String packsizeOriginal = model.packsizeOriginal;
      try {
        packsizeOriginal =
            double.parse(model.packsizeOriginal).round().toString();
      } catch (_) {}
      return Card(
        color: isFirst ? Constants.firstYellow : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: isFirst
                  ? Colors.yellow.shade500.withOpacity(0.5)
                  : Constants.greenDark.withOpacity(0.5)),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _LeftColumn(
                        label: "SO",
                        value: model.contractor.staffName,
                        index: index,
                      ),
                      _LeftColumn(
                        label: "Scheme",
                        value: model.contractor.scheme,
                        index: index,
                      ),
                      _LeftColumn(
                        label: "Serial No",
                        value: model.packsizeBarcode,
                        index: index,
                      ),
                      _LeftColumn(
                        label: "Material Code",
                        value: model.materialCode,
                        index: index,
                      ),
                      _LeftColumn(
                        label: "Description",
                        value: model.description,
                        index: index,
                      ),
                      _QtyColumn(
                        label: "Pack Size",
                        unit: "${model.unit}/${model.packUnit}",
                        value: packsizeOriginal,
                      ),
                      const SizedBox(height: 10),
                      if (errorMessage.value != "")
                        Text(
                          errorMessage.value,
                          style: const TextStyle(
                              fontSize: 16, color: Constants.red),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 225,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxGreenDarkText(title: "Return Qty"),
                      _QtyColumnEdit(
                          label: "",
                          value: packQty,
                          unit: model.unit,
                          errorEditMessage:
                              ref.watch(selectedEditIndex) == index
                                  ? errorEditMessage
                                  : "",
                          inEditMode: ref.watch(selectedEditIndex) == index &&
                              inEditMode &&
                              !isDeleteOnly,
                          ctrlEdit: ctrlEdit,
                          onChanged: (val) {
                            packsizeCurrent.value = val;
                            if (onEditChange != null) {
                              onEditChange!(val, index);
                            }
                          }),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Checkbox(
                            side: MaterialStateBorderSide.resolveWith((states) {
                              if (inEditMode) {
                                return BorderSide(
                                    width: 1.0, color: Constants.greenDark);
                              }
                              return BorderSide(
                                  width: 1.0, color: Constants.greyDark);
                            }),
                            //value: model.isScrap == "Y",
                            value: isScrap.value == "Y",
                            onChanged: (inEditMode &&
                                    !isDeleteOnly &&
                                    index == ref.watch(selectedEditIndex))
                                ? (val) {
                                    if (val == null) return;
                                    isScrap.value = val ? "Y" : "N";
                                    String xval = val ? "Y" : "N";
                                    if (isScrapChange != null) {
                                      isScrapChange!(xval);
                                    }
                                  }
                                : null,
                          ),
                          FxGreenDarkText(title: "Scrap Material"),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      if (inEditMode && ref.read(selectedEditIndex) == index)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isDeleteOnly)
                                InkWell(
                                  onTap: errorEditMessage == "" && !isDeleteOnly
                                      ? () {
                                          if (errorEditMessage != "") {
                                            return;
                                          }
                                          if (doSave != null) {
                                            doSave!(index);
                                          }
                                        }
                                      : null,
                                  child: FxGreenDarkText(
                                    title: "Save",
                                  ),
                                ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              // InkWell(
                              //   onTap: () {
                              //     if (resetIsDone != null) resetIsDone!();
                              //     onCancel(model);
                              //   },
                              //   child: FxGreenDarkText(
                              //     title: "Cancel",
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      if (inEditMode && ref.read(selectedEditIndex) != index)
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                              onTap: () {
                                if (requestEdit != null) {
                                  ref.read(selectedEditIndex.notifier).state =
                                      index;
                                  requestEdit!(index);
                                }
                              },
                              child: FxGreenDarkText(title: "Edit")),
                        ),
                      if (!inEditMode)
                        Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () {
                                final snow =
                                    "&t=${DateTime.now().toIso8601String()}";
                                final url =
                                    "https://${Constants.host}/reports/sor_inv_material_one.php?xid=${model.mrID}&c=${model.packsizeBarcode}$snow";
                                if (kIsWeb) {
                                  html.window.open(url, "rpttab");
                                  return;
                                }
                              },
                              child: Image.asset(
                                "images/icon_printer.png",
                                height: 27,
                              ),
                            )),
                      Spacer(),
                      if (inEditMode && ref.read(selectedEditIndex) == index)
                        Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              child: Image.asset(
                                "images/icon_delete.png",
                                width: 24,
                              ),
                              onTap: () {
                                onDelete(model);
                              },
                            )),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _LeftColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool showEdit;
  final bool inEditMode;
  final bool isLoading;
  final String barcode;
  final int index;
  final Function(int index)? onProcess;
  const _LeftColumn(
      {Key? key,
      required this.label,
      required this.value,
      this.inEditMode = false,
      this.showEdit = false,
      this.isLoading = false,
      this.barcode = "",
      required this.index,
      this.onProcess})
      : super(key: key);

  void doPrint() async {
    final snow = "&t=${DateTime.now().toIso8601String()}";
    if (barcode == "") {
      return;
    }
    var url =
        "https://tkdev.sor.my/reports/sor_inv_material.php?c=" + barcode + snow;
    if (kIsWeb) {
      html.window.open(url, "rpttab");
      return;
    }
    /* print("Url : $url"); */
    try {
      await Printing.layoutPdf(
        name: "Material Return",
        onLayout: (fmt) async {
          final response = await Dio().get(
            url,
            options: Options(responseType: ResponseType.bytes),
          );
          return response.data;
        },
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 100,
            child: FxGreenDarkText(
              title: label,
            )),
        const FxGreenDarkText(title: ":"),
        const SizedBox(width: 5),
        Expanded(
          child: FxGrayDarkText(
            title: value,
            maxLines: 2,
          ),
        ),
        const SizedBox(width: 30),
        if (showEdit) const Spacer(),
        if (showEdit && !inEditMode && !isLoading)
          FxTextLink(
            title: "Print Barcode",
            onPress: () {
              doPrint();
            },
          ),
        if (showEdit && inEditMode && !isLoading)
          FxTextLink(
            title: "Edit",
            onPress: () {
              if (onProcess != null) {
                onProcess!(index);
              }
            },
          ),
        if (isLoading)
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

class _QtyColumnEdit extends HookConsumerWidget {
  final String label;
  final String value;
  final String? unit;
  final bool inEditMode;
  final Function(String val) onChanged;
  final TextEditingController ctrlEdit;
  final String errorEditMessage;
  const _QtyColumnEdit(
      {Key? key,
      required this.label,
      required this.value,
      this.unit,
      required this.inEditMode,
      required this.onChanged,
      required this.ctrlEdit,
      this.errorEditMessage = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (inEditMode)
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: FxTextFieldHuge(
                        width: 150,
                        ctrl: ctrlEdit,
                        textAlign: TextAlign.end,
                        errorMessage: errorEditMessage,
                        labelText: "",
                        hintText: "",
                        showErrorMessage: false,
                        onChanged: (p0) {
                          onChanged(p0);
                        },
                        autoFocus: true,
                      ),
                    ),
                    FxGreenDarkText(title: unit ?? ""),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: SizedBox(
                  width: 600,
                  height: 65,
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 52.0, top: 10),
                          child: FxGrayDarkText(
                            title: ctrlEdit.text,
                            fontSize: 36,
                            align: TextAlign.end,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        bottom: 15,
                        child: FxGreenDarkText(title: unit ?? ""),
                      ),
                    ],
                  ),
                ),
              ),
        if (errorEditMessage != "")
          Text(
            errorEditMessage,
            style: const TextStyle(
              color: Constants.red,
              fontSize: 14,
            ),
          )
      ],
    );
  }
}

class _QtyColumn extends HookConsumerWidget {
  final String label;
  final String value;
  final String? unit;
  final bool showDelete;
  final Function(String)? onDelete;
  final bool isLoading;
  final String checkoutID;

  const _QtyColumn(
      {Key? key,
      required this.label,
      required this.value,
      this.unit,
      this.showDelete = false,
      this.onDelete,
      this.isLoading = false,
      this.checkoutID = "0"})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: FxGreenDarkText(
            title: label,
          ),
        ),
        const FxGreenDarkText(title: ":"),
        const SizedBox(width: 5),
        FxGrayDarkText(
          title: value,
        ),
        const SizedBox(width: 5),
        if (unit != null) FxGrayDarkText(title: unit ?? ""),
        if (showDelete) const Spacer(),
        if (showDelete)
          InkWell(
            child: Image.asset(
              "images/icon_delete.png",
              width: 24,
            ),
            onTap: () {
              if (onDelete != null) {
                onDelete!(checkoutID);
              }
            },
          ),
        if (isLoading)
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

class FxTextSaveCancel extends StatelessWidget {
  final Function(bool isConfirm)? onPress;

  const FxTextSaveCancel({Key? key, this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: InkWell(
            onTap: () {
              if (onPress != null) {
                onPress!(false);
              }
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                fontSize: 16,
                color: Constants.greenDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          "|",
          style: TextStyle(
            fontSize: 16,
            color: Constants.greenDark,
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: 40,
          child: InkWell(
            onTap: () {
              if (onPress != null) {
                onPress!(true);
              }
            },
            child: const Text(
              "Save",
              style: TextStyle(
                fontSize: 16,
                color: Constants.greenDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}

class FxTextLink extends StatelessWidget {
  final String title;
  final VoidCallback? onPress;

  const FxTextLink({Key? key, required this.title, this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Constants.greenDark,
          ),
        ),
      ),
    );
  }
}
