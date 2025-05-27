import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sor_inventory/screen/checkin/scan_barcode_provider.dart';
import 'package:sor_inventory/screen/material_return/mr_delete_provider.dart';
import 'package:sor_inventory/screen/material_return/selected_mr_cp_provider.dart';

import '../app/constants.dart';
import '../model/material_return_scan_response.dart';
import '../screen/material_return/save_material_return_provider.dart';
import 'fx_button.dart';
import 'fx_gray_dark_text.dart';
import 'fx_green_dark_text.dart';
import 'fx_text_field.dart';
import 'dart:html' as html;

class FxMaterialReturnScanInfoV2 extends HookConsumerWidget {
  final bool isFirst;
  final bool inEditMode;
  final bool confirmDone;
  final bool isManual;
  final int index;
  final MaterialReturnScanResponseModelV2 model;
  final Function(String packSize, String slipNo) packsizeChange;
  final TextEditingController ctrlEdit;
  final FocusNode? ctrlFocus;
  final Function(String checkoutID)? afterDelete;
  final String errorEditMessage;
  final Function(String value, int idx)? onEditChange;
  final Function(int idx)? requestEdit;
  final Function(int idx, String packQty)? cancelEdit;
  final String initSlipNo;
  final bool showCancel;
  const FxMaterialReturnScanInfoV2(
      {super.key,
      required this.model,
      required this.confirmDone,
      this.isFirst = false,
      required this.packsizeChange,
      required this.ctrlEdit,
      this.showCancel = false,
      this.afterDelete,
      this.inEditMode = false,
      required this.index,
      this.requestEdit,
      this.onEditChange,
      this.cancelEdit,
      this.ctrlFocus,
      this.isManual = false,
      this.errorEditMessage = "",
      required this.initSlipNo});

  String removeZeroQty(String inp) {
    String sResultQty = inp;
    try {
      double dCheckoutQty = double.parse(inp);
      if (dCheckoutQty - dCheckoutQty.toInt() == 0) {
        sResultQty = dCheckoutQty.toInt().toString();
      }
    } catch (_) {}
    return sResultQty;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final isDeleteLoading = useState(false);
    final errorMessage = useState("");
    String xpacksizeCurrent;
    try {
      xpacksizeCurrent = model.packsizeCurrent;
    } catch (_) {
      xpacksizeCurrent = "";
    }
    final packsizeCurrent = useState(xpacksizeCurrent);
    final slipNo = useState(initSlipNo);

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
        slipNo.value = next.slipNo;
        packsizeChange(next.packQty, next.slipNo);
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
                    if (model.isCable == "Y")
                      _LeftColumn(
                        label: "Drum No",
                        value: model.doDetailDrumNo,
                        index: index,
                      ),
                    _LeftColumn(
                        label: "Material Code",
                        value: model.materialCode,
                        index: index),
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
                        style:
                            const TextStyle(fontSize: 16, color: Constants.red),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FxGreenDarkText(title: "Return Qty"),
                    _QtyColumnEdit(
                        label: "",
                        value: packQty,
                        unit: model.unit,
                        packsizeOriginal: model.packsizeOriginal,
                        errorEditMessage: errorEditMessage,
                        inEditMode:
                            index == ref.watch(selectedEditIndex) && inEditMode,
                        ctrlEdit: ctrlEdit,
                        onChanged: (val) {
                          packsizeCurrent.value = val;
                          if (onEditChange != null) {
                            onEditChange!(val, index);
                          }
                        }),
                  ],
                ),
              ),
              confirmDone
                  ? SizedBox(
                      width: 100,
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Spacer(),
                          isManual || confirmDone
                              ? InkWell(
                                  onTap: () {
                                    final snow =
                                        "&t=${DateTime.now().toIso8601String()}&qty=${model.editQty}&dr=${model.doDetailDrumNo}";
                                    final url =
                                        "https://${Constants.host}/reports/sor_inv_material_one.php?c=${model.packsizeBarcode}&mid=${model.materialId}$snow";
                                    if (kIsWeb) {
                                      html.window.open(url, "rpttab");
                                      return;
                                    }
                                  },
                                  child: Image.asset(
                                    "images/icon_printer.png",
                                    height: 27,
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Delete'),
                                          content: const Text(
                                              'Are you sure you want to delete this item?'),
                                          actions: <Widget>[
                                            FxButton(
                                              maxWidth: 80,
                                              height: 34,
                                              title: "No",
                                              color: Constants.greenDark,
                                              onPress: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            FxButton(
                                              maxWidth: 80,
                                              height: 34,
                                              title: "Yes",
                                              color: Constants.red,
                                              onPress: () {
                                                ref
                                                    .read(mrDeleteStateProvider
                                                        .notifier)
                                                    .delete(
                                                        mrID: model.mrID,
                                                        checkoutID:
                                                            model.checkoutID,
                                                        slipNo: '');
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Image.asset(
                                    "images/icon_delete.png",
                                    height: 27,
                                  ),
                                ),
                        ],
                      ))
                  : SizedBox(
                      width: 100,
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          inEditMode && index == ref.watch(selectedEditIndex)
                              ? InkWell(
                                  onTap: ctrlEdit.text != "" &&
                                          errorEditMessage == "" &&
                                          inEditMode
                                      ? () {
                                          //do Save
                                          ref
                                              .read(
                                                  saveMaterialReturnStateProvider
                                                      .notifier)
                                              .save(
                                                  slipNo: slipNo.value,
                                                  storeID: "0",
                                                  isScrap: model.isScrap,
                                                  barcode:
                                                      model.packsizeBarcode,
                                                  mrID: model.mrID,
                                                  packQty: ctrlEdit.text);
                                        }
                                      : null,
                                  child: ctrlEdit.text != "" &&
                                          errorEditMessage == ""
                                      ? const FxGreenDarkText(title: "Save")
                                      : const FxGrayDarkText(title: "Save"),
                                )
                              : InkWell(
                                  onTap: () {
                                    ref.read(selectedEditIndex.notifier).state =
                                        index;
                                    if (requestEdit != null) {
                                      requestEdit!(index);
                                    }
                                  },
                                  child: const FxGreenDarkText(title: "Edit"),
                                ),
                          const Spacer(),
                          if (!inEditMode || confirmDone)
                            isManual
                                ? InkWell(
                                    onTap: () {
                                      final snow =
                                          "&t=${DateTime.now().toIso8601String()}";
                                      final url =
                                          "https://${Constants.host}/reports/sor_inv_material_one.php?c=${model.packsizeBarcode}$snow";
                                      if (kIsWeb) {
                                        html.window.open(url, "rpttab");
                                        return;
                                      }
                                    },
                                    child: Image.asset(
                                      "images/icon_printer.png",
                                      height: 27,
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      showDialog<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Delete'),
                                            content: const Text(
                                                'Are you sure you want to delete this item?'),
                                            actions: <Widget>[
                                              FxButton(
                                                maxWidth: 80,
                                                height: 34,
                                                title: "No",
                                                color: Constants.greenDark,
                                                onPress: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              FxButton(
                                                maxWidth: 80,
                                                height: 34,
                                                title: "Yes",
                                                color: Constants.red,
                                                onPress: () {
                                                  ref
                                                      .read(
                                                          mrDeleteStateProvider
                                                              .notifier)
                                                      .delete(
                                                        mrID: model.mrID,
                                                          checkoutID:
                                                              model.checkoutID,
                                                          slipNo: "");
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Image.asset(
                                      "images/icon_delete.png",
                                      height: 27,
                                    ),
                                  ),
                        ],
                      ),
                    ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _LeftColumn extends StatelessWidget {
  final String label;
  final String value;
  final int index;
  const _LeftColumn({
    Key? key,
    required this.label,
    required this.value,
    required this.index,
  }) : super(key: key);

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
      ],
    );
  }
}

class _QtyColumnEdit extends HookConsumerWidget {
  final String label;
  final String value;
  final String packsizeOriginal;
  final String? unit;
  final bool inEditMode;
  final Function(String val) onChanged;
  final TextEditingController ctrlEdit;
  final FocusNode? ctrlFocus;
  final String errorEditMessage;
  const _QtyColumnEdit(
      {Key? key,
      required this.label,
      required this.value,
      required this.packsizeOriginal,
      this.unit,
      this.ctrlFocus,
      required this.inEditMode,
      required this.onChanged,
      required this.ctrlEdit,
      this.errorEditMessage = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var sPacksizeOriginal = packsizeOriginal;
    try {
      final nbf = NumberFormat("###0");
      sPacksizeOriginal = nbf.format(double.parse(packsizeOriginal));
    } catch (_) {}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (inEditMode)
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: FxTextFieldHuge(
                        width: 180,
                        textInputType: TextInputType.number,
                        ctrl: ctrlEdit,
                        textAlign: TextAlign.right,
                        focusNode: ctrlFocus,
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
                    Positioned(
                        right: 10,
                        bottom: 15,
                        child: FxGreenDarkText(title: unit ?? "")),
                  ],
                ),
              )
            : SizedBox(
                width: 180,
                height: 70,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: FxGrayDarkText(
                        title: ctrlEdit.text,
                        fontSize: 36,
                        align: TextAlign.end,
                      ),
                    ),
                    const SizedBox(width: 10),
                    FxGreenDarkText(title: unit ?? ""),
                  ],
                ),
              ),
        if (errorEditMessage != "" && inEditMode)
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
