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
import '../model/checkout_model_v2.dart';
import '../model/material_return_scan_response.dart';
import '../screen/checkout/loose_qty_save_provider.dart';
import '../screen/material_return/save_material_return_provider.dart';
import 'fx_gray_dark_text.dart';
import 'fx_green_dark_text.dart';
import 'fx_text_field.dart';
import 'dart:html' as html;

class FxMaterialIssueInfo extends HookConsumerWidget {
  final bool isFirst;
  final bool inEditMode;
  final int index;
  final MaterialC1 model;
  final TextEditingController ctrlEdit;
  final void Function(
      MaterialC1 model, String strQty, bool status, String message) onSave;
  final String fileNum;
  final String slipNo;

  const FxMaterialIssueInfo({
    super.key,
    required this.model,
    this.isFirst = false,
    required this.ctrlEdit,
    this.inEditMode = false,
    required this.index,
    required this.onSave,
    required this.fileNum,
    required this.slipNo,
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
    final isInIssueLooseQty = useState(false);
    ref.listen(looseQtySaveStateProvider, (prev, next) {
      if (next is LooseQtySaveStateLoading) {
        isLoading.value = true;
      } else if (next is LooseQtySaveStateDone) {
        isLoading.value = false;
      } else if (next is LooseQtySaveStateError) {
        errorMessage.value = next.message;
      }
    });
    return ResponsiveBuilder(builder: (context, sizeinfo) {
      return Card(
        color: Constants.firstYellow,
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
                  flex: 2,
                  child: Column(
                    children: [
                      _LeftColumn(
                        label: "Material Code",
                        value: model.materialCode ?? "",
                        index: index,
                      ),
                      _LeftColumn(
                        label: "Description",
                        value: model.description ?? "",
                        index: index,
                      ),
                      _LeftColumn(
                        label: "Serial No",
                        value: model.barcode ?? "",
                        index: index,
                      ),
                      _LeftColumn(
                        label: "Balance",
                        value: "",
                        index: index,
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
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FxGreenDarkText(title: "Issued Qty :"),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FxTextFieldHuge(
                        width: 150,
                        ctrl: ctrlEdit,
                        textAlign: TextAlign.right,
                        readOnly: !isInIssueLooseQty.value,
                        enabled: isInIssueLooseQty.value,
                        errorMessage: "",
                        labelText: "",
                        hintText: "",
                        showErrorMessage: false,
                        onChanged: (p0) {
                          // onChanged(p0);
                        },
                        autoFocus: true,
                      ),
                    )
                  ]),
                ),
                if (!isInIssueLooseQty.value)
                  InkWell(
                    onTap: () {
                      isInIssueLooseQty.value = true;
                    },
                    child: Center(
                      child: Image.asset(
                        "images/issue_loose.png",
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                if (isInIssueLooseQty.value)
                  InkWell(
                    onTap: () {
                      isInIssueLooseQty.value = false;
                      var value = -1.00;
                      // try {
                      //   value = double.parse(ctrlEdit.text);
                      //   if (value > double.parse(model.issueQty ?? "")) {
                      //     errorMessage.value = "Loose Qty > Issued";
                      //     onSave(
                      //         model, ctrlEdit.text, false, errorMessage.value);
                      //     return;
                      //   } else if (value ==
                      //       double.parse(model.issueQty ?? "")) {
                      //     onSave(model, ctrlEdit.text, true, "");
                      //     return;
                      //   }
                      // } catch (_) {
                      //   onSave(model, ctrlEdit.text, false, "Error Parsing");
                      // }
                      // do loose qty save
                      ref.read(looseQtySaveStateProvider.notifier).looseQtySave(
                            checkoutID: model.checkoutID ?? "0",
                            slipNo: slipNo,
                            fileNum: fileNum,
                            barcode: model.barcode ?? "",
                            oldQty: model.issueQty ?? "",
                            qty: ctrlEdit.text,
                          );
                      onSave(model, ctrlEdit.text, true, "");
                    },
                    child: Center(
                      child: Image.asset(
                        "images/save_loose.png",
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     InkWell(
                //       onTap: () async {
                //         final snow = "&t=${DateTime.now().toIso8601String()}";
                //         // String jSplit;
                //         // jSplit = model.mergeMaterialID;
                //         // final url =
                //         //     "https://${Constants.host}/reports/merge_material.php?c=$jSplit$snow";
                //         // if (kIsWeb) {
                //         //   html.window.open(url, "rpttab");
                //         //   return;
                //         // }
                //       },
                //       child: Image.asset(
                //         "images/icon_printer.png",
                //         height: 27,
                //       ),
                //     ),
                //     InkWell(
                //       onTap: () async {
                //         final snow = "&t=${DateTime.now().toIso8601String()}";
                //         // String jSplit;
                //         // jSplit = model.mergeMaterialID;
                //         // final url =
                //         //     "https://${Constants.host}/reports/merge_material.php?c=$jSplit$snow";
                //         // if (kIsWeb) {
                //         //   html.window.open(url, "rpttab");
                //         //   return;
                //         // }
                //       },
                //       child: Image.asset(
                //         "images/icon_delete.png",
                //         height: 27,
                //       ),
                //     )
                //   ],
                // ),
                SizedBox(width: 10),
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
            width: 110,
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
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: FxTextFieldHuge(
                        width: 200,
                        ctrl: ctrlEdit,
                        textAlign: TextAlign.right,
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
                        right: 15,
                        bottom: 15,
                        child: FxGreenDarkText(title: unit ?? "")),
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
