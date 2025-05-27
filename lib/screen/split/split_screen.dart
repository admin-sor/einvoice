import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:sor_inventory/repository/split_repository.dart';
import 'package:sor_inventory/screen/merge/merge_item_provider.dart';
import 'package:sor_inventory/screen/split/split_history_provider.dart';
import 'package:sor_inventory/screen/split/split_material_info.dart';
import 'package:sor_inventory/screen/split/split_save_provider.dart';
import 'package:sor_inventory/widgets/fx_button.dart';
import 'package:sor_inventory/widgets/fx_gray_dark_text.dart';
import 'dart:html' as html;

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_store_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'package:pdf/pdf.dart';
import 'split_scan_provider.dart';

class SplitScreen extends HookConsumerWidget {
  const SplitScreen({super.key, this.splitMaterialID});
  final String? splitMaterialID;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInit = useState(true);
    final loginModel = useState<SorUser?>(null);
    final ctrlBarcode = useTextEditingController(text: "");
    final fcBarcode = FocusNode();
    final fcQty = FocusNode();
    final isLoading = useState(false);
    final errorMessage = useState("");
    final selectedStoreID = useState("0");
    final selectedStoreName = useState("No Store");
    ref.listen(
      loginStateProvider,
      (prev, next) {
        if (next is LoginStateDone) {
          loginModel.value = next.loginModel;
        }
      },
    );
    //no login
    if (loginModel.value == null) {
      if (isInit.value) {
        isInit.value = false;
        Timer(const Duration(milliseconds: 500), () {
          ref.read(loginStateProvider.notifier).checkLocalToken();
        });
        if (splitMaterialID != null) {
          Timer(const Duration(milliseconds: 500), () {
            ref
                .read(splitHistoryStateProvider.notifier)
                .byID(splitID: splitMaterialID!);
          });
        }
      } else {
        Timer(const Duration(milliseconds: 500), () {
          isInit.value = true;
          Navigator.of(context)
              .pushNamedAndRemoveUntil(loginRoute, (args) => false);
        });
      }
      return Scaffold(
        body: Container(
          color: Colors.white,
        ),
      );
    }
    final scanBarcodeIsActive = useState(false);
    fcBarcode.addListener(() {
      if (fcBarcode.hasFocus) {
        scanBarcodeIsActive.value = true;
      } else {
        scanBarcodeIsActive.value = false;
      }
    });

    final scanItem = useState<ResponseSplitScan?>(null);

    final listSplit = useState<List<String>>(List.empty());
    final isDone = useState(false);
    final resultSplit = useState<List<String>>(List.empty());
    final currentPackSize = useState("");
    final inSplitMode = useState(false);
    ref.listen(splitHistoryStateProvider, (previous, next) {
      if (next is SplitHistoryStateLoading) {
        isLoading.value = true;
      } else if (next is SplitHistoryStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is SplitHistoryStateDone) {
        isLoading.value = false;
        isDone.value = true;
        if (next.list.isNotEmpty) {
          ctrlBarcode.text = next.list[0].originBarcode ?? "";
          var arrSplit = List<String>.empty(growable: true);
          var arrQtySplit = List<String>.empty(growable: true);
          var totalQty = 0.0;
          for (var hist in next.list) {
            arrSplit.add(hist.splitMaterialID ?? "");
            arrQtySplit.add(hist.splitMaterialPackQty ?? "");
            try {
              totalQty += double.parse(hist.splitMaterialPackQty ?? "0.0");
            } catch (_) {}
          }
          resultSplit.value = arrSplit;
          listSplit.value = arrQtySplit;
          var obj = next.list[0];
          scanItem.value = ResponseSplitScan(
            ref: obj.ref ?? "",
            refID: obj.refID ?? "",
            code: obj.materialCode ?? "",
            description: obj.description ?? "",
            barcode: obj.originBarcode ?? "",
            drumNo: obj.splitMaterialDrumNo ?? "",
            packSizeCurrent: totalQty.toStringAsFixed(0),
            packUnit: obj.packUnit ?? "",
            unit: obj.unit ?? "",
            isCable: obj.isCable ?? "",
            storeName: obj.storeName ?? "",
            storeID: obj.storeID ?? "",
          );
        }
      }
    });
    ref.listen(splitScanStateProvider, (prev, next) {
      if (next is SplitScanStateLoading) {
        isLoading.value = true;
      } else if (next is SplitScanStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is SplitScanStateDone) {
        isLoading.value = false;
        scanItem.value = next.model;
        int curSize = double.parse(next.model.packSizeCurrent).toInt();
        currentPackSize.value = curSize.toString();
        listSplit.value = List.empty();
        scanBarcodeIsActive.value = false;
        fcBarcode.unfocus();
      }
    });
    final saveIsLoading = useState(false);
    ref.listen(splitSaveStateProvider, (previous, next) {
      if (next is SplitSaveStateLoading) {
        saveIsLoading.value = true;
      } else if (next is SplitSaveStateError) {
        errorMessage.value = next.message;
        saveIsLoading.value = false;
      } else if (next is SplitSaveStateDone) {
        errorMessage.value = "";
        saveIsLoading.value = false;
        isDone.value = true;
        resultSplit.value = next.model;
      }
    });
    final ctrlQty = useTextEditingController(text: "");
    String qtyTitle = "Qty";
    if (scanItem.value != null) {
      qtyTitle = "Qty ( ${scanItem.value!.unit})";
    }
    final isValidQty = useState(false);
    ctrlQty.addListener(() {
      if (ctrlQty.text.trim() == "") {
        isValidQty.value = false;
      } else {
        isValidQty.value = true;
      }
    });
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.colorAppBarBg,
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: const Text(
            "Split Material",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Constants.colorAppBar,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Constants.colorAppBar,
          ),
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () {
              if (isLoading.value) return;
              Navigator.of(context).pop();
            },
          ),
          actions: [
            Builder(
              builder: (context) => InkWell(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    "images/icon_menu.png",
                    width: 36,
                    height: 36,
                  ),
                ),
                onTap: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        endDrawer: const EndDrawer(),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 80,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: Constants.paddingTopContent,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FxTextField(
                          action: TextInputAction.none,
                          width: double.infinity,
                          maxHeight: 60,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          focusNode: fcBarcode,
                          readOnly: splitMaterialID != null ||
                              selectedStoreID.value == "0",
                          ctrl: ctrlBarcode,
                          labelText: "Scan Barcode",
                          hintText: "Scan Barcode",
                          onSubmitted: (val) {
                            if (selectedStoreID.value == "0") {
                              return;
                            }
                            if (val == "") {
                              return;
                            }
                            scanItem.value = null;
                            ref.read(splitScanStateProvider.notifier).scan(
                                barcode: val, storeID: selectedStoreID.value);
                          },
                          suffix: isLoading.value
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: CircularProgressIndicator()),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Image.asset(
                                      "images/icon_scan_barcode.png",
                                      height: 48),
                                ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: scanBarcodeIsActive.value
                            ? FxTextField(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 10,
                                ),
                                ctrl: TextEditingController(
                                    text: selectedStoreName.value),
                                enabled: false,
                                readOnly: true,
                              )
                            : FxStoreLk(
                                labelText: "Store Location",
                                hintText: "Select Store",
                                readOnly: (!isDone.value &&
                                    listSplit.value.length >= 1),
                                onChanged: (model) {
                                  selectedStoreID.value = model.storeID ?? "0";
                                  selectedStoreName.value =
                                      model.storeName ?? "No Store";
                                },
                              ),
                      )
                    ],
                  ),
                  if (errorMessage.value != "")
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(errorMessage.value),
                        ),
                      ),
                    ),
                  if (scanItem.value != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: FxSplitScanInfo(model: scanItem.value!),
                    ),
                  if (scanItem.value != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: FxGreenDarkText(
                            title: "Item",
                          )),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FxGreenDarkText(title: qtyTitle),
                            ),
                          ),
                          Expanded(child: SizedBox(width: 100)),
                        ],
                      ),
                    ),
                  if (scanItem.value != null)
                    const Divider(
                      color: Colors.black,
                      height: 0.0,
                    ),
                  if (splitMaterialID != null)
                    SizedBox(
                      height: 10,
                    ),
                  if (scanItem.value != null && splitMaterialID == null)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: FxGrayDarkText(
                            title: "1",
                          )),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FxGrayDarkText(
                                title: currentPackSize.value,
                              ),
                            ),
                          ),
                          (isDone.value)
                              ? Expanded(
                                  child: SizedBox(
                                    width: 100,
                                  ),
                                )
                              : Expanded(
                                  child: SizedBox(
                                    child: Center(
                                      child: FxButton(
                                        maxWidth: 100,
                                        color: Constants.blue,
                                        onPress: inSplitMode.value
                                            ? null
                                            : () {
                                                inSplitMode.value = true;
                                              },
                                        title: "Split",
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  if (scanItem.value != null &&
                      inSplitMode.value &&
                      !isDone.value)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              child: SizedBox(
                            width: 10,
                          )),
                          Expanded(
                            child: FxTextField(
                              focusNode: fcQty,
                              width: 100,
                              ctrl: ctrlQty,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              child: Center(
                                child: FxButton(
                                  maxWidth: 100,
                                  onPress: isValidQty.value
                                      ? () {
                                          var arrSplit = listSplit.value
                                              .toList(growable: true);
                                          if (ctrlQty.text == "") return;
                                          double total = 0;
                                          for (var element in arrSplit) {
                                            try {
                                              total += double.parse(element);
                                            } catch (e) {}
                                          }
                                          double cur =
                                              double.parse(ctrlQty.text);
                                          double curPack = double.parse(
                                              currentPackSize.value);
                                          if (cur > curPack) {
                                            errorMessage.value =
                                                "Total Split > ${scanItem.value!.packSizeCurrent}";
                                            Timer(Duration(seconds: 3), () {
                                              errorMessage.value = "";
                                            });
                                            ctrlQty.text =
                                                (curPack - cur).toString();
                                            return;
                                          }
                                          currentPackSize.value =
                                              (curPack - cur)
                                                  .toInt()
                                                  .toString();
                                          arrSplit.add(ctrlQty.text);
                                          listSplit.value = arrSplit;
                                          ctrlQty.text = "";
                                          inSplitMode.value = false;
                                        }
                                      : null,
                                  color: Constants.greenDark,
                                  title: "Save",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (scanItem.value != null)
                    Expanded(
                      child: ListView.builder(
                        itemCount: listSplit.value.length,
                        itemBuilder: (context, index) {
                          String qty = listSplit.value[index];
                          String counter = (index + 2).toString();
                          if (splitMaterialID != null) {
                            counter = (index + 1).toString();
                          }
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, bottom: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                      width: 40,
                                      child: FxGreenDarkText(
                                        title: counter,
                                      )),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: FxGreenDarkText(
                                      title: qty,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                isDone.value
                                    ? Expanded(
                                        child: SizedBox(
                                        width: 100,
                                      ))
                                    : Expanded(
                                        child: SizedBox(
                                            width: 100,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: InkWell(
                                                  child: Image.asset(
                                                    "images/icon_delete.png",
                                                    height: 18,
                                                  ),
                                                  onTap: () {
                                                    listSplit.value
                                                        .removeAt(index);
                                                    currentPackSize
                                                        .value = (int.parse(
                                                                currentPackSize
                                                                    .value) +
                                                            int.parse(qty))
                                                        .toString();
                                                  }),
                                            )),
                                      )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (scanItem.value == null) Spacer(),
                  Row(
                    children: [
                      // Expanded(
                      //     child: FxButton(
                      //   title: "Undo",
                      //   color: Constants.red,
                      //   onPress: () {
                      //     if (isLoading.value) return;
                      //     Navigator.of(context).pop();
                      //   },
                      // )),
                      Expanded(
                          child: SizedBox(
                        width: 10,
                      )),
                      if (isDone.value)
                        Expanded(
                          child: FxButton(
                            title: "Print Label",
                            color: Constants.blue,
                            onPress: () async {
                              final snow =
                                  "&t=${DateTime.now().toIso8601String()}";
                              String jSplit = resultSplit.value.join(",");
                              final url =
                                  "https://${Constants.host}/reports/split_material.php?c=$jSplit$snow";
                              if (kIsWeb) {
                                html.window.open(url, "rpttab");
                                return;
                              }
                              await Printing.layoutPdf(
                                format: const PdfPageFormat(
                                    60 * PdfPageFormat.mm,
                                    29 * PdfPageFormat.mm),
                                name: "Split Material Barcode",
                                onLayout: (fmt) async {
                                  final response = await Dio().get(
                                    url,
                                    options: Options(
                                        responseType: ResponseType.bytes),
                                  );
                                  return response.data;
                                },
                              );
                            },
                          ),
                        ),
                      if (!isDone.value)
                        Expanded(
                            child: FxButton(
                          color: Constants.greenDark,
                          title: "Confirm",
                          isLoading: saveIsLoading.value,
                          onPress: listSplit.value.isEmpty || isDone.value
                              ? null
                              : () {
                                  var arrSplit =
                                      listSplit.value.toList(growable: true);
                                  double total = 0;
                                  for (var element in arrSplit) {
                                    try {
                                      total += double.parse(element);
                                    } catch (e) {}
                                  }
                                  double totalPack = double.parse(
                                      scanItem.value!.packSizeCurrent);
                                  arrSplit.insert(
                                      0, (totalPack - total).toString());
                                  ref
                                      .read(splitSaveStateProvider.notifier)
                                      .save(
                                        refOrigin: scanItem.value!.ref,
                                        refID: scanItem.value!.refID,
                                        split: arrSplit,
                                        storeID: selectedStoreID.value,
                                      );
                                },
                        ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
