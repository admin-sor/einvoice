import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/screen/merge/byid_provider.dart';
import 'package:sor_inventory/screen/merge/fx_merge_item_info.dart';
import 'package:sor_inventory/screen/merge/merge_item_provider.dart';
import 'package:sor_inventory/screen/merge/merge_scan_provider.dart';
import 'package:sor_inventory/widgets/fx_button.dart';
import 'package:sor_inventory/widgets/fx_merge_info.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../repository/merge_repository.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_store_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'fx_merge_scan_info.dart';
import 'merge_save_provider.dart';

class MergeScreen extends HookConsumerWidget {
  const MergeScreen({
    super.key,
    this.mergeMaterialID,
  });
  final String? mergeMaterialID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInit = useState(true);
    final loginModel = useState<SorUser?>(null);
    final ctrlBarcode = useTextEditingController(text: "");
    final fcBarcode = FocusNode();
    final isLoading = useState(false);
    final errorMessage = useState("");
    final firstScanItem = useState<ResponseMergeScan?>(null);
    final scanItem = useState<ResponseMergeScan?>(null);
    final selectedStoreID = useState<String>("");

    final mergeItem = useState<ResponseMergeSave?>(null);

    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
      }
    });
    final scanBarcodeIsActive = useState(false);
    fcBarcode.addListener(() {
      if (fcBarcode.hasFocus) {
        scanBarcodeIsActive.value = true;
      } else {
        scanBarcodeIsActive.value = false;
      }
    });
    //no login
    final listScanItem = useState<List<ResponseMergeScan>>(List.empty());
    if (loginModel.value == null) {
      if (isInit.value) {
        isInit.value = false;
        Timer(const Duration(milliseconds: 500), () {
          ref.read(loginStateProvider.notifier).checkLocalToken();
        });
        listScanItem.value = List.empty();
        if (mergeMaterialID != null) {
          Timer(const Duration(milliseconds: 500), () {
            ref
                .read(mergeByIDStateProvider.notifier)
                .list(mergeMaterialID: mergeMaterialID!);
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

    ref.listen(mergeSaveStateProvider, (prev, next) {
      if (next is MergeSaveStateLoading) {
        isLoading.value = true;
      } else if (next is MergeSaveStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
      } else if (next is MergeSaveStateDone) {
        isLoading.value = false;
        errorMessage.value = "";
        mergeItem.value = next.model;
        ref.read(mergeItemProvider.notifier).state = List.empty();
      }
    });

    ref.listen(mergeByIDStateProvider, (previous, next) {
      if (next is MergeByIDStateLoading) {
        isLoading.value = true;
      } else if (next is MergeByIDStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is MergeByIDStateDone) {
        isLoading.value = false;
        ref.read(mergeItemProvider.notifier).state = next.list;
      }
    });
    ref.listen<List<ResponseMergeScan>>(mergeItemProvider, (previous, next) {
      if (next.isEmpty) {
        firstScanItem.value = null;
      }
    });
    ref.listen(mergeScanStateProvider, (prev, next) {
      if (next is MergeScanStateLoading) {
        isLoading.value = true;
      } else if (next is MergeScanStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(Duration(seconds: 3), () {
          errorMessage.value = "";
        });
        ctrlBarcode.text = "";
        fcBarcode.requestFocus();
      } else if (next is MergeScanStateDone) {
        isLoading.value = false;
        ctrlBarcode.text = "";
        for (var item in ref.read(mergeItemProvider)) {
          if (next.model.barcode == item.barcode) {
            errorMessage.value = "Barcode ${item.barcode} already in merged";
            Timer(Duration(seconds: 3), () {
              errorMessage.value = "";
            });
            return;
          }
        }
        scanItem.value = next.model;
        var tmpList = listScanItem.value.toList();
        for (var item in tmpList) {
          if (next.model.barcode == item.barcode) {
            errorMessage.value = "Barcode ${next.model.barcode} already scan";
            Timer(Duration(seconds: 3), () {
              errorMessage.value = "";
            });
            return;
          }
        }
        tmpList.add(next.model);
        listScanItem.value = tmpList;
        firstScanItem.value ??= next.model;
        fcBarcode.requestFocus();
      } else if (next is MergeScanStateDone) {}
    });

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.colorAppBarBg,
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: const Text(
            "Merge Materials",
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
              listScanItem.value = List.empty();
              Timer(Duration(milliseconds: 500), () {
                Navigator.of(context).pop();
              });
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          width: double.infinity,
                          maxHeight: 52,
                          readOnly: selectedStoreID.value == "",
                          focusNode: fcBarcode,
                          ctrl: ctrlBarcode,
                          labelText: "Scan Barcode",
                          hintText: "Scan Barcode",
                          onSubmitted: (val) {
                            if (selectedStoreID.value == "") {
                              return;
                            }
                            if (val == "") {
                              return;
                            }
                            scanItem.value = null;
                            ref.read(mergeScanStateProvider.notifier).scan(
                                  // storeID: firstScanItem.value?.storeID ?? "",
                                  storeID: selectedStoreID.value,
                                  barcode: val,
                                  materialID: firstScanItem.value?.materialID
                                          .toString() ??
                                      "0",
                                );
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
                                    text: ref
                                            .watch(mergeStoreIDProvider)
                                            ?.storeName ??
                                        "No Store"),
                                enabled: false,
                                readOnly: true,
                              )
                            : FxStoreLk(
                                labelText: "Store Location",
                                hintText: "Select Store",
                                onChanged: (model) {
                                  selectedStoreID.value = model.storeID ?? "0";
                                  ref
                                      .read(mergeStoreIDProvider.notifier)
                                      .state = model;
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
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: (mergeItem.value == null)
                            ? Text(
                                "Materials to be merged :",
                                style: TextStyle(fontSize: 16),
                              )
                            : Text("Materials merged :",
                                style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      if (mergeItem.value == null)
                        Expanded(
                          child: FxButton(
                            title: "Merge",
                            color: Constants.greenDark,
                            onPress: (listScanItem.value.length <= 1 &&
                                    ref.read(mergeItemProvider).isEmpty)
                                ? null
                                : () {
                                    if (isLoading.value) return;
                                    if (listScanItem.value.isNotEmpty) {
                                      var items =
                                          ref.read(mergeItemProvider).toList();
                                      var scanItems =
                                          listScanItem.value.toList();
                                      items.addAll(scanItems);
                                      ref
                                          .read(mergeItemProvider.notifier)
                                          .state = items;
                                      ctrlBarcode.text = "";
                                      scanItem.value = null;
                                      listScanItem.value = List.empty();
                                    }
                                    List<ParamMergeSave> merge =
                                        List.empty(growable: true);
                                    for (var item
                                        in ref.read(mergeItemProvider)) {
                                      final prm = ParamMergeSave(item.barcode,
                                          item.ref, item.refID, item.storeID);
                                      merge.add(prm);
                                    }
                                    if (merge.isNotEmpty) {
                                      ref
                                          .read(mergeSaveStateProvider.notifier)
                                          .save(
                                              merge: merge,
                                              storeID: ref
                                                      .read(
                                                          mergeStoreIDProvider)
                                                      ?.storeID ??
                                                  "0");
                                    }
                                    // Timer(Duration(milliseconds: 500), () {
                                    //   Navigator.of(context)
                                    //       .pushNamed(mergeListMaterialRoute);
                                    // });
                                  },
                          ),
                        )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (mergeItem.value != null)
                    FxMergeInfo(model: mergeItem.value!),
                  if (listScanItem.value.isNotEmpty && mergeItem.value == null)
                    Expanded(
                      child: ListView.builder(
                          itemCount: listScanItem.value.length,
                          itemBuilder: (context, idx) {
                            var model = listScanItem.value[idx];
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  fcBarcode.unfocus();
                                  scanBarcodeIsActive.value = false;
                                },
                                child: FxMergeScanInfo(
                                    model: model,
                                    isFirst: true,
                                    onDelete: () {
                                      var xlist = listScanItem.value.toList();
                                      xlist.removeAt(idx);
                                      listScanItem.value = xlist;
                                    }),
                              ),
                            );
                          }),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        width: 10,
                      )),
                      SizedBox(
                        width: 10,
                      ),
                      if (mergeItem.value != null)
                        Expanded(
                          child: FxButton(
                            title: "Done",
                            color: Constants.greenDark,
                            onPress: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      // if (mergeItem.value == null)
                      //   Expanded(
                      //     child: FxButton(
                      //       title: "Merge",
                      //       color: Constants.greenDark,
                      //       onPress: (listScanItem.value.length <= 1 &&
                      //               ref.read(mergeItemProvider).isEmpty)
                      //           ? null
                      //           : () {
                      //               if (isLoading.value) return;
                      //               if (listScanItem.value.isNotEmpty) {
                      //                 var items =
                      //                     ref.read(mergeItemProvider).toList();
                      //                 var scanItems =
                      //                     listScanItem.value.toList();
                      //                 items.addAll(scanItems);
                      //                 ref
                      //                     .read(mergeItemProvider.notifier)
                      //                     .state = items;
                      //                 ctrlBarcode.text = "";
                      //                 scanItem.value = null;
                      //                 listScanItem.value = List.empty();
                      //               }
                      //               List<ParamMergeSave> merge =
                      //                   List.empty(growable: true);
                      //               for (var item
                      //                   in ref.read(mergeItemProvider)) {
                      //                 final prm = ParamMergeSave(item.barcode,
                      //                     item.ref, item.refID, item.storeID);
                      //                 merge.add(prm);
                      //               }
                      //               if (merge.isNotEmpty) {
                      //                 ref
                      //                     .read(mergeSaveStateProvider.notifier)
                      //                     .save(
                      //                         merge: merge,
                      //                         storeID: ref
                      //                                 .read(
                      //                                     mergeStoreIDProvider)
                      //                                 ?.storeID ??
                      //                             "0");
                      //               }
                      //               // Timer(Duration(milliseconds: 500), () {
                      //               //   Navigator.of(context)
                      //               //       .pushNamed(mergeListMaterialRoute);
                      //               // });
                      //             },
                      //     ),
                      //   ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
