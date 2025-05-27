import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:sor_inventory/screen/material_return/mr_by_no_provider.dart';
import 'package:sor_inventory/screen/material_return/mr_delete_provider.dart';
import 'package:sor_inventory/screen/material_return/req_reload_material.dart';
import 'package:sor_inventory/screen/mr_auto/selected_mr_cp_provider.dart';
import 'package:sor_inventory/widgets/fx_button.dart';
import 'package:sor_inventory/widgets/fx_returnable_material_lk.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/contractor_lookup_model.dart';
import '../../model/material_return_scan_response.dart';
import '../../model/sor_user_model.dart';
import '../../provider/device_size_provider.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_contractor_lk.dart';
import '../../widgets/fx_material_return_scan_info.dart';
import '../../widgets/fx_store_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'dart:html' as html;

import 'save_material_return_provider.dart';
import 'scan_only_material_return_provider.dart';

class MaterialReturnScreen extends HookConsumerWidget {
  final String mrSlipNo;
  const MaterialReturnScreen({this.mrSlipNo = "", Key? key}) : super(key: key);

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
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final selectedStoreID = useState<String?>(null);

    final ctrlBarcode = useTextEditingController(text: "");
    final isLoading = useState(false);

    final isLessThan1Day = useState(true);
    final isDeleteOnly = useState(mrSlipNo != "");
    final errorMessage = useState("");
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listBarcode = useState<List<String>>(List.empty());
    final listScanned = useState<List<String>>(List.empty());
    final listResponseModel =
        useState<List<MaterialReturnScanResponseModelV2>>(List.empty());
    final fcBarcode = FocusNode();
    final selectedContractor = useState<ContractorLookupModel?>(null);
    final ctrlSlipNo = useTextEditingController(text: "");
    final isDone = useState(mrSlipNo != "");
    final ctrlContractorReadOnly = useTextEditingController(text: "");
    final ctrlSoReadOnly = useTextEditingController(text: "");
    final ctrlStoreReadOnly = useTextEditingController(text: "");
    final selectedSoID = useState("0");

    List<TextEditingController> listCtrl = List.empty();
    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
        if (loginModel.value?.storeID != null) {
          selectedStore.value = {
            "id": loginModel.value!.storeID,
            "name": "User Store"
          };
        }
      }
    });
    //no login
    if (loginModel.value == null) {
      if (isInit.value) {
        isInit.value = false;
        Timer(const Duration(milliseconds: 500), () {
          ref.read(loginStateProvider.notifier).checkLocalToken();
        });
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
    final isEditValid = useState(false);
    useEffect(() {
      ref.read(selectedEditIndex.notifier).state = 0;
      if (mrSlipNo != "") {
        Timer(Duration(milliseconds: 300), () {
          ref.read(mrMrByNoStateProvider.notifier).byNo(slipNo: mrSlipNo);
        });
      }
      return () {};
    }, [mrSlipNo]);

    final errorMessageEdit = useState("");
    final havingPartialReturn = useState(false);
    ref.listen(mrMrByNoStateProvider, (previous, next) {
      try {
        if (next is MrByNoStateLoading) {
          isLoading.value = true;
        } else if (next is MrByNoStateError) {
          isLoading.value = false;
          if (next.message.contains("not found")) {
            return;
          }
          errorMessage.value = next.message;
          Timer(Duration(seconds: 3), () {
            errorMessage.value = "";
          });
        } else if (next is MrByNoStateDone) {
          isLoading.value = false;
          selectedContractor.value = next.model.contractor;
          ctrlContractorReadOnly.text = next.model.contractor.name;
          ctrlSlipNo.text = next.model.slipNo;

          ctrlSoReadOnly.text = next.model.contractor.staffName;
          selectedSoID.value = next.model.contractor.staffId;
          ref.read(selectedMrSoIDProvider.notifier).state = selectedSoID.value;
          if (mrSlipNo != "") {
            var xstate = ref.read(reqReloadMaterial) + 1;
            ref.read(reqReloadMaterial.notifier).state = xstate;
          }
          if (next.model.items.isNotEmpty) {
            if (next.model.items[0].isLessThan1Day == "Y") {
              isLessThan1Day.value = true;
            } else {
              isLessThan1Day.value = false;
            }
          }
          listResponseModel.value = next.model.items;
          havingPartialReturn.value = false;
          //for (var m in next.model.items) {
          //  if (m.checkoutIsPartial == "Y") {
          //    havingPartialReturn.value = true;
          //    break;
          //  }
          //}
          if (mrSlipNo != "") {
            if (next.model.items.isNotEmpty) {
              ctrlStoreReadOnly.text = next.model.storeName;
              selectedStore.value = {
                "id": next.model.storeID,
                "name": next.model.storeName
              };
            }
          }
          //if (next.model.storeID != "0") {
          //  ctrlStoreReadOnly.text = next.model.storeName;
          //  selectedStore.value = {
          //    "id": next.model.storeID,
          //    "name": next.model.storeName
          //  };
          //}
        }
      } catch (e) {
        print(e);
      }
    });

    ref.listen(saveMaterialReturnStateProvider, (prev, next) {
      if (next is SaveMaterialReturnStateDone) {
        ctrlSlipNo.text = next.slipNo;
      } else if (next is SaveMaterialReturnStateError) {
        Timer(Duration(seconds: 2), () {
          if (ctrlSlipNo.text == "") {
            var xlist = listResponseModel.value.toList();
            xlist.removeLast();
            listResponseModel.value = xlist;
          } else {
            //ref
            //    .read(mrMrByNoStateProvider.notifier)
            //    .byNo(slipNo: ctrlSlipNo.text);
          }
        });
      }
    });

    void saveEdited(prevIdx) {
      double ctrlVal = 0.0;
      double modelVal = 0.0;
      try {
        ctrlVal = double.parse(listCtrl[prevIdx].text);
      } catch (e) {}
      try {
        modelVal =
            double.parse(listResponseModel.value[prevIdx].packsizeCurrent);
      } catch (e) {}
      if (prevIdx < listResponseModel.value.length) {
        var model = listResponseModel.value[prevIdx];

        // print("model : $modelVal, ctrl : $ctrlVal, mrid : ${model.mrID}");
        // if (modelVal != ctrlVal && model.mrID != "null") {
        //   return;
        // }
        if (selectedStore.value == null) {
          return;
        }
        var storeID = selectedStore.value!["id"];
        if (model.mrID == "0" || model.mrID == "null") {
          //add
          ref.read(saveMaterialReturnStateProvider.notifier).save(
                barcode: model.packsizeBarcode,
                mrID: "0",
                storeID: storeID,
                packQty: ctrlVal.toString(),
                slipNo: ctrlSlipNo.text,
                isScrap: model.isScrap,
              );
        } else {
          ref.read(saveMaterialReturnStateProvider.notifier).save(
                barcode: model.packsizeBarcode,
                mrID: model.mrID,
                storeID: storeID,
                isScrap: model.isScrap,
                packQty: ctrlVal.toString(),
                slipNo: ctrlSlipNo.text,
              );
        }
      }
    }

    // useEffect(() {
    //   Timer? timer;
    //   listBarcode.addListener(() {
    //     if (timer != null && timer!.isActive) {
    //       timer!.cancel();
    //     }
    //     timer = Timer(const Duration(seconds: 1), () {
    //       final barcodes = listBarcode.value;
    //       if (barcodes.isEmpty) return;
    //       List<String> param = List.empty();
    //         param = barcodes
    //             .where((barcode) =>
    //                 listScanned.value
    //                     .indexWhere((scanned) => scanned == barcode) ==
    //                 -1)
    //             .toList();
    //       } else {
    //         param = barcodes;
    //       }
    //       if (param.isEmpty) return;
    //       if (selectedContractor.value == null) return;
    //       if (ref.watch(selectedEditIndex) > 0) {
    //         saveEdited(ref.watch(selectedEditIndex));
    //       }
    //       ref.read(scanMaterialReturnStateProvider.notifier).scan(
    //             barcode: param,
    //             contractor: selectedContractor.value!,
    //             slipNo: ctrlSlipNo.text,
    //           );
    //     });
    //   });

    //   return () {
    //     if (timer != null) timer!.cancel();
    //   };
    // }, []);

    ref.listen(scanOnlyMaterialReturnStateProvider, (prev, next) {
      if (next is ScanOnlyMaterialReturnStateLoading) {
        isLoading.value = true;
      } else if (next is ScanOnlyMaterialReturnStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is ScanOnlyMaterialReturnStateDone) {
        isLoading.value = false;
        errorMessage.value = next.message;
        final List<String> newScanned = List.empty(growable: true);
        if (listScanned.value.isNotEmpty) {
          newScanned.addAll(listScanned.value);
        }
        newScanned.add(next.scanBarcode);
        listScanned.value = newScanned;
        final List<MaterialReturnScanResponseModelV2> xlist =
            List.empty(growable: true);
        if (next.list.isNotEmpty) {
          xlist.addAll(next.list);
          xlist.addAll(listResponseModel.value);
          listResponseModel.value = xlist;
          isDone.value = false;
          if (next.list[0].isLessThan1Day == "Y") {
            isLessThan1Day.value = true;
          } else {
            isLessThan1Day.value = false;
          }
        } else {
          listResponseModel.value = xlist;
          isDone.value = false;
          isLessThan1Day.value = true;
        }
        if (ctrlSlipNo.text == "") {
          ctrlSlipNo.text = next.slipNo;
        }
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
        if (true || mrSlipNo == "") {
          isDeleteOnly.value = false;
        } else {
          isDeleteOnly.value = true;
        }
      }
    });
    // fcBarcode.requestFocus();

    ref.listen(selectedEditIndex, ((previous, next) {
      // int prevIdx = previous as int;
      //saveEdited(prevIdx);
    }));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Material Return",
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
            if (!isDone.value && listResponseModel.value.isNotEmpty) {
              return;
            }
            ref.read(selectedMrCpProvider.notifier).state = "0";
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: Constants.paddingTopContent,
            ),
            mrSlipNo == ""
                ? Row(
                    children: [
                      Expanded(
                        child: FxContractorLk(
                          width: kIsWeb ? Constants.webWidth : double.infinity,
                          labelText: "Contractor",
                          hintText: "Contractor",
                          onChanged: (ctr) {
                            selectedContractor.value = ctr;
                            ref.read(selectedMrCpProvider.notifier).state =
                                ctr.cpId.toString();
                            ref.read(selectedMrSoIDProvider.notifier).state =
                                ctr.staffId.toString();
                            //reset listScan
                            ref.read(reqReloadMaterial.notifier).state =
                                ref.read(reqReloadMaterial) + 1;
                            listResponseModel.value = List.empty();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FxStoreLk(
                          labelText: "Store",
                          hintText: "Select Store",
                          readOnly: mrSlipNo != "" ||
                              listResponseModel.value.isNotEmpty,
                          onChanged: (model) {
                            selectedStore.value = {
                              "id": model.storeID,
                              "name": model.storeName
                            };
                          },
                        ),
                      )
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: FxTextField(
                          ctrl: ctrlSoReadOnly,
                          readOnly: true,
                          enabled: false,
                          labelText: "SO",
                          hintText: "SO",
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FxTextField(
                          ctrl: ctrlStoreReadOnly,
                          readOnly: true,
                          enabled: false,
                          labelText: "Store",
                          hintText: "Store",
                        ),
                      )
                    ],
                  ),
            const SizedBox(height: 10),
            FxReturnableMaterialLk(
              enabled: listResponseModel.value.isEmpty || isDone.value,
              isMobile: ref.read(deviceSizeProvider).width < 600,
              width: kIsWeb ? Constants.webWidth : double.infinity,
              labelText: "Returnable Material",
              hintText: "Returnable Material",
              soID: selectedSoID.value,
              onBarcodeChoose: (barcode) {
                if (selectedContractor.value == null) return;
                if (barcode == "") return;
                ref.read(scanOnlyMaterialReturnStateProvider.notifier).scanOnly(
                    barcode: barcode,
                    contractor: selectedContractor.value!,
                    slipNo: ctrlSlipNo.text);
                ctrlBarcode.text = "";
                fcBarcode.requestFocus();
                Navigator.of(context).popUntil((route) {
                  if (route is MaterialPageRoute) {
                    return true;
                  }
                  return false;
                });
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FxTextField(
                    width: double.infinity,
                    focusNode: fcBarcode,
                    enabled:
                        (listResponseModel.value.isEmpty || isDone.value) &&
                            isLessThan1Day.value,
                    ctrl: ctrlBarcode,
                    labelText: "Scan Barcode",
                    hintText: "Scan Barcode",
                    onSubmitted: (val) {
                      if (selectedContractor.value == null) return;
                      ref
                          .read(scanOnlyMaterialReturnStateProvider.notifier)
                          .scanOnly(
                              barcode: ctrlBarcode.text,
                              contractor: selectedContractor.value!,
                              slipNo: ctrlSlipNo.text);
                      ctrlBarcode.text = "";
                      fcBarcode.requestFocus();
                    },
                    suffix: isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator())
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset("images/icon_scan_barcode.png",
                                height: 18),
                          ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: SizedBox(
                  width: 20,
                )),
                // Expanded(
                //   child: FxStoreLk(
                //     labelText: "Store Location",
                //     hintText: "Select Store",
                //     onChanged: (model) {
                //       selectedStoreID.value = model.storeID ?? "0";
                //     },
                //   ),
                // )
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
            if (listResponseModel.value.isNotEmpty) const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                  itemCount: listResponseModel.value.length,
                  itemBuilder: (context, idx) {
                    final m = listResponseModel.value[idx];
                    if (idx == 0) {
                      listCtrl = List.empty(growable: true);
                    }

                    //String curPackSize;
                    //try {
                    //  curPackSize =
                    //      double.parse(m.packsizeCurrent).round().toString();
                    //} catch (_) {}
                    var ctrl = TextEditingController(text: m.editQty);
                    ctrl.selection = TextSelection.fromPosition(
                        TextPosition(offset: ctrl.text.length));
                    listCtrl.add(ctrl);
                    double xwidth = MediaQuery.of(context).size.width;
                    if (xwidth < 300) xwidth = 300;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: xwidth,
                        child: FxMaterialReturnScanInfo(
                            isNew: m.mrID == "0" ,
                            requestEdit: (idx) {
                              isDone.value = false;
                            },
                            isDeleteOnly: isDeleteOnly.value,
                            onDelete: (model) {
                              if (ctrlSlipNo.text == "") {
                                if (listResponseModel.value.length == 1) {
                                  listResponseModel.value =
                                      List.empty(growable: true);
                                } else {
                                  ref
                                      .read(mrMrByNoStateProvider.notifier)
                                      .byNo(slipNo: ctrlSlipNo.text);
                                }
                              } else {
                                ref.read(mrDeleteStateProvider.notifier).delete(
                                    mrID: model.mrID,
                                    checkoutID: model.checkoutID,
                                    slipNo: ctrlSlipNo.text);
                              }
                            },
                            onCancel: (model) {
                              errorMessageEdit.value = "";
                              if (ctrlSlipNo.text == "") {
                                listResponseModel.value =
                                    List.empty(growable: true);
                              } else {
                                ref
                                    .read(mrMrByNoStateProvider.notifier)
                                    .byNo(slipNo: ctrlSlipNo.text);
                              }
                              ref.read(reqReloadMaterial.notifier).state =
                                  ref.read(reqReloadMaterial) + 1;
                            },
                            doSave: (idx) {
                              saveEdited(idx);
                              isDone.value = true;
                            },
                            errorEditMessage: errorMessageEdit.value,
                            ctrlEdit: listCtrl[idx],
                            resetIsDone: () {
                              isDone.value = true;
                            },
                            index: idx,
                            inEditMode:
                                !isDone.value && m.isLessThan1Day == 'Y',
                            packsizeChange: (packSize) {
                              final xl = listResponseModel.value;
                              xl[idx].packsizeCurrent = listCtrl[idx].text;
                              listResponseModel.value = xl;
                            },
                            isScrapChange: (val) {
                              final xl = listResponseModel.value;
                              xl[idx].isScrap = val;
                              listResponseModel.value = xl;
                            },
                            onEditChange: (val, idx) {
                              listResponseModel.value[idx].editQty = val;
                              if (val == "") {
                                isEditValid.value = false;
                              } else {
                                double ctrlVal = 0;
                                double curPackSizeVal = 0;
                                try {
                                  ctrlVal = double.parse(val);
                                } catch (e) {
                                  errorMessageEdit.value = e.toString();
                                  isEditValid.value = false;
                                  return;
                                }
                                try {
                                  curPackSizeVal = double.parse(
                                      //listResponseModel.value[idx].packsizeCurrent);
                                      listResponseModel
                                          .value[idx].checkoutPackQty);
                                } catch (e) {
                                  errorMessageEdit.value = e.toString();
                                  isEditValid.value = false;
                                  return;
                                }
                                if (ctrlVal <= curPackSizeVal) {
                                  errorMessageEdit.value = "";
                                  isEditValid.value = true;
                                } else {
                                  errorMessageEdit.value =
                                      "Returned Qty > Issued Qty";
                                  isEditValid.value = false;
                                }
                              }
                            },
                            afterDelete: (checkoutID) {
                              if (m.checkoutID != checkoutID) {
                                return;
                              }
                              final xl = listResponseModel.value.toList();
                              xl.remove(m);
                              listResponseModel.value = xl;
                              int xstate = ref.read(reqReloadMaterial).abs();
                              xstate = xstate + 1;
                              ref.read(reqReloadMaterial.notifier).state =
                                  xstate;
                              //remove from listBarcode
                              final xls = listScanned.value.toList();
                              xls.remove(m.packsizeBarcode);
                              listScanned.value = xls;
                            },
                            model: m,
                            isFirst: idx == 0),
                      ),
                    );
                  }),
            ),
            (isDone.value)
                ? Row(children: [
                    Expanded(
                      child: FxButton(
                        title: "Edit",
                        onPress: havingPartialReturn.value ||
                                !isLessThan1Day.value
                            ? null
                            : () {
                                isDone.value = false;
                                isDeleteOnly.value = true;
                                if (listResponseModel.value.isNotEmpty) {
                                  ref.read(selectedEditIndex.notifier).state =
                                      0;
                                }
                              },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: FxButton(
                        title: isWebMobile
                            ? "Print Return Slip"
                            : "Print Material Return Slip",
                        color: Constants.greenDark,
                        onPress: (() async {
                          final snow = "&t=${DateTime.now().toIso8601String()}";
                          final url =
                              "https://${Constants.host}/reports/material_return.php?no=${base64Encode(utf8.encode(ctrlSlipNo.text.trim()))}" +
                                  snow;

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
                                  options:
                                      Options(responseType: ResponseType.bytes),
                                );
                                return response.data;
                              },
                            );
                          } catch (e) {
                            errorMessage.value = "Error printing document";
                            Timer(const Duration(seconds: 3), () {
                              errorMessage.value = "";
                            });
                          }
                        }),
                      ),
                    ),
                  ])
                : Row(
                    children: [
                      Expanded(
                        child: FxButton(
                          maxWidth: double.infinity,
                          color: Constants.greenDark,
                          title: "Done",
                          onPress: (ctrlSlipNo.text == "" ||
                                      listResponseModel.value.isEmpty) &&
                                  (!isEditValid.value)
                              ? null
                              : () async {
                                  int prevIdx = ref.watch(selectedEditIndex);
                                  if (!isDeleteOnly.value) {
                                    saveEdited(prevIdx);
                                  }
                                  isDone.value = true;
                                },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FxButton(
                          title: isWebMobile
                              ? "Print Return Slip"
                              : "Print Material Return Slip",
                          color: Constants.greenDark,
                          onPress: null,
                        ),
                      )
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
