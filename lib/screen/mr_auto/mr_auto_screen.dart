import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:sor_inventory/screen/mr_auto/mr_set_done_provider.dart';
import 'package:sor_inventory/widgets/fx_button.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/contractor_lookup_model.dart';
import '../../model/material_return_scan_response.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_material_return_scan_info_v2.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'dart:html' as html;

import 'mr_by_no_provider.dart';
import 'req_reload_material.dart';
import 'save_material_return_provider.dart';
import 'scan_only_material_return_provider.dart';
import 'selected_mr_cp_provider.dart';

class MrAutoScreen extends HookConsumerWidget {
  final String mrSlipNo;
  const MrAutoScreen({this.mrSlipNo = "", Key? key}) : super(key: key);

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

    final ctrlBarcode = useTextEditingController(text: "");
    final isLoading = useState(false);

    final isHavingContent = useState(false);
    final errorMessage = useState("");
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listScanned = useState<List<String>>(List.empty());
    final listResponseModel =
        useState<List<MaterialReturnScanResponseModelV2>>(List.empty());
    final fcBarcode = FocusNode();
    final selectedContractor = useState<ContractorLookupModel?>(null);
    final ctrlSlipNo = useTextEditingController(text: mrSlipNo);

    final isDone = useState(mrSlipNo != "");
    final confirmDone = useState(false);
    final ctrlContractorReadOnly = useTextEditingController(text: "");

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

    useEffect(() {
      if (mrSlipNo != "") {
        Timer(const Duration(milliseconds: 300), () {
          ref.read(mrMrByNoStateProvider.notifier).byNo(slipNo: mrSlipNo);
        });
      }
      return () {};
    }, [mrSlipNo]);

    final isEditValid = useState(false);
    final errorMessageEdit = useState("");
    ref.listen(mrMrByNoStateProvider, (previous, next) {
      try {
        if (next is MrByNoStateLoading) {
          isLoading.value = true;
        } else if (next is MrByNoStateError) {
          isLoading.value = false;
          errorMessage.value = next.message;
          Timer(const Duration(seconds: 3), () {
            errorMessage.value = "";
          });
        } else if (next is MrByNoStateDone) {
          isLoading.value = false;
          selectedContractor.value = next.model.contractor;
          ctrlContractorReadOnly.text = next.model.contractor.name;
          ctrlSlipNo.text = next.model.slipNo;
          listResponseModel.value = next.model.items;
          isDone.value = true;
          if (next.model.isDone == "Y") {
            confirmDone.value = true;
          } else {
            confirmDone.value = false;
          }
        }
      } catch (_) {}
    });

    ref.listen(mrSetDoneStateProvider, (previous, next) {
      if (next is MrSetDoneStateLoading) {
        isLoading.value = true;
      } else if (next is MrSetDoneStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
      } else if (next is MrSetDoneStateDone) {
        isLoading.value = false;
        if (next.status == "Y") {
          confirmDone.value = true;
        } else {
          confirmDone.value = false;
        }
      }
    });
    void saveEdited(prevIdx) {
      double ctrlVal = 0.0;
      double modelVal = 0.0;
      try {
        ctrlVal = double.parse(listCtrl[prevIdx].text);
      } catch (_) {}
      try {
        modelVal =
            double.parse(listResponseModel.value[prevIdx].packsizeCurrent);
      } catch (_) {}
      if (!(modelVal == ctrlVal)) {
        if (prevIdx < listResponseModel.value.length) {
          var model = listResponseModel.value[prevIdx];
          if (model.mrID == "0" || model.mrID == "null") {
            //add
          } else {
            ref.read(saveMaterialReturnStateProvider.notifier).save(
                  barcode: model.packsizeBarcode,
                  storeID: selectedStore.value?["id"] ?? "0",
                  mrID: model.mrID,
                  packQty: ctrlVal.toString(),
                  slipNo: ctrlSlipNo.text,
                );
          }
        }
      }
    }

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
        } else {
          listResponseModel.value = xlist;
          isDone.value = false;
        }
        if (ctrlSlipNo.text == "") {
          ctrlSlipNo.text = next.slipNo;
        }
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      }
    });
    // fcBarcode.requestFocus();

    ref.listen(selectedEditIndex, ((previous, next) {
      int prevIdx = previous as int;
      saveEdited(prevIdx);
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
            Expanded(
              child: ListView.builder(
                  itemCount: listResponseModel.value.length,
                  itemBuilder: (context, idx) {
                    final m = listResponseModel.value[idx];
                    if (idx == 0) {
                      listCtrl = List.empty(growable: true);
                    }
                    try {
                      String curPackSize = m.packsizeCurrent;
                      curPackSize =
                          double.parse(m.packsizeCurrent).round().toString();
                    } catch (_) {}
                    TextEditingController ctrl;
                    try {
                      ctrl = TextEditingController(text: m.editQty);
                    } catch (_) {
                      ctrl = TextEditingController(text: "");
                    }
                    ctrl.selection = TextSelection.fromPosition(
                       TextPosition(offset: ctrl.text.length));
                    listCtrl.add(ctrl);
                    return FxMaterialReturnScanInfoV2(
                        confirmDone: confirmDone.value,
                        initSlipNo: mrSlipNo,
                        showCancel: mrSlipNo != "",
                        requestEdit: (idx) {
                          isDone.value = false;
                        },
                        cancelEdit: (idx, packQty) {
                          listCtrl[idx].text = packQty;

                          final xtmp = listResponseModel.value.toList();
                          xtmp[idx].editQty = packQty;
                          listResponseModel.value = xtmp;
                          isDone.value = true;
                        },
                        errorEditMessage: errorMessageEdit.value,
                        ctrlEdit: listCtrl[idx],
                        index: idx,
                        inEditMode: !isDone.value,
                        packsizeChange: (packSize, slipNo) {
                          final xl = listResponseModel.value;
                          xl[idx].packsizeCurrent = listCtrl[idx].text;
                          listResponseModel.value = xl;
                          ctrlSlipNo.text = slipNo;
                          isDone.value = true;
                        },
                        onEditChange: (val, idx) {
                          listResponseModel.value[idx].editQty = val;
                          if (val == "") {
                            isEditValid.value = false;
                          } else {
                            double ctrlVal = 0;
                            double curPackSizeVal = 0;
                            double orgPackSizeVal = 0;
                            // Timer(const Duration(seconds: 3), () {
                            //   if (errorMessageEdit.value != "") {
                            //     errorMessageEdit.value = "";
                            //   }
                            // });
                            try {
                              ctrlVal = double.parse(val);
                            } catch (e) {
                              errorMessageEdit.value = e.toString();
                              isEditValid.value = false;
                              return;
                            }
                            try {
                              curPackSizeVal = double.parse(
                                  listResponseModel.value[idx].packsizeCurrent);
                              orgPackSizeVal = double.parse(listResponseModel
                                  .value[idx].packsizeOriginal);
                            } catch (e) {
                              errorMessageEdit.value = e.toString();
                              isEditValid.value = false;
                              return;
                            }
                            if (ctrlVal <= orgPackSizeVal) {
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
                          ref.read(reqReloadMaterial.notifier).state = xstate;
                          //remove from listBarcode
                          final xls = listScanned.value.toList();
                          xls.remove(m.packsizeBarcode);
                          listScanned.value = xls;
                        },
                        model: m,
                        isFirst: idx == 0);
                  }),
            ),
            FxTextField(
              width: double.infinity,
              focusNode: fcBarcode,
              enabled: (listResponseModel.value.isEmpty || isDone.value) &&
                  !confirmDone.value,
              ctrl: ctrlBarcode,
              labelText: "Scan Barcode",
              hintText: "Enter|Scan Barcode",
              onSubmitted: (val) {
                ref
                    .read(scanOnlyMaterialReturnStateProvider.notifier)
                    .scanOnlyV2(barcode: ctrlBarcode.text);
                ctrlBarcode.text = "";
                fcBarcode.requestFocus();
              },
              suffix: isLoading.value
                  ? const SizedBox(
                      width: 22, height: 22, child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset("images/icon_scan_barcode.png",
                          height: 18),
                    ),
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
            const SizedBox(height: 10),
            Row(children: [
              confirmDone.value
                  ? Expanded(
                      child: FxButton(
                        title: "Edit",
                        onPress: (() {
                          if (ctrlSlipNo.text != "") {
                            ref
                                .read(mrSetDoneStateProvider.notifier)
                                .setDone(slipNo: ctrlSlipNo.text, status: "N");
                          }
                        }),
                      ),
                    )
                  : Expanded(
                      child: FxButton(
                        color: Constants.greenDark,
                        title: "Done",
                        onPress: listResponseModel.value.isEmpty ||
                                ctrlSlipNo.text == ""
                            ? null
                            : (() {
                                if (ctrlSlipNo.text != "") {
                                  ref
                                      .read(mrSetDoneStateProvider.notifier)
                                      .setDone(
                                          slipNo: ctrlSlipNo.text, status: "Y");
                                }
                              }),
                      ),
                    ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: FxButton(
                  title: "Print Return Slip",
                  color: Constants.greenDark,
                  onPress: !confirmDone.value
                      ? null
                      : (() async {
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
            ]),
          ],
        ),
      ),
    );
  }
}
