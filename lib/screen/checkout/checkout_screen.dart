import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/checkout_model_v2.dart';
import 'package:sor_inventory/repository/checkout_repository.dart';
import 'package:sor_inventory/screen/checkout/by_no_provider.dart';
import 'package:sor_inventory/screen/checkout/delete_checkout_provider.dart';
import 'package:sor_inventory/screen/checkout/list_c1_provider.dart';
import 'package:sor_inventory/screen/checkout/set_done_provider.dart';
import 'package:sor_inventory/widgets/fx_ac_scheme.dart';
import 'package:sor_inventory/widgets/fx_button.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/checkout_scan_response_model.dart';
import '../../model/contractor_lookup_model.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_contractor_lk.dart';
import '../../widgets/fx_material_issue_info.dart';
import '../../widgets/fx_store_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../checkout_summary/list_provider.dart';
import '../login/login_provider.dart';
import 'loose_qty_save_provider.dart';
import 'scan_checkout_provider.dart';
import 'dart:html' as html;

class CheckOutScreen extends HookConsumerWidget {
  final String materialSlipNo;
  const CheckOutScreen({
    Key? key,
    this.materialSlipNo = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);

    final ctrlBarcode = useTextEditingController(text: "");
    final isLoading = useState(false);
    final isLoadingLooseQty = useState(false);
    final errorMessage = useState("");
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listBarcode = useState<List<String>>(List.empty());
    final listScanned = useState<List<String>>(List.empty());
    final listResponseModel =
        useState<List<CheckoutScanResponseModel>>(List.empty());
    final fcBarcode = FocusNode();
    final ctrlContractorReadOnly = useTextEditingController(text: "SO");
    final ctrlStoreReadOnly = useTextEditingController(text: "");
    final alreadyHaveScannedMaterial = useState(false);

    final looseQtyBarcodeList = useState<HashMap>(HashMap());

    final nullContractor = ContractorLookupModel(
        cpId: "0",
        name: "Select SO",
        shortName: "Select SO",
        staffId: "0",
        staffName: "",
        scheme: "");
    final selectedContractor = useState<ContractorLookupModel?>(null);
    final ctrlSlipNo = useTextEditingController(text: "");

    final ctrlScheme = useTextEditingController(text: "");
    final fcScheme = FocusNode();
    final selectedScheme = useState<SchemeLookupModel?>(null);
    final isFromScan = useState<bool>(false);

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
      if (materialSlipNo != "") {
        Timer(Duration(milliseconds: 300), () {
          ref.read(byNoStateProvider.notifier).byNo(slipNo: materialSlipNo);
        });
      }
      return () {};
    }, [materialSlipNo]);

    final deletedBarcode = useState<String?>(null);
    useEffect(() {
      Timer? timer;
      listBarcode.addListener(() {
        if (timer != null && timer!.isActive) {
          timer!.cancel();
        }
        timer = Timer(const Duration(seconds: 1), () {
          final barcodes = listBarcode.value;
          if (barcodes.isEmpty) return;
          List<String> param = List.empty();
          if (listScanned.value.isNotEmpty) {
            param = barcodes
                .where((barcode) =>
                    listScanned.value
                        .indexWhere((scanned) => scanned == barcode) ==
                    -1)
                .toList();
          } else {
            param = barcodes;
          }
          var delBarcode = deletedBarcode.value ?? "";
          //TODO: filterout delBarcode
          // print(param);
          param = param.where((b) => b != delBarcode).toList();
          // print("after filter delete");
          // print(param);
          if (param.isEmpty) return;
          if (selectedContractor.value == null) return;
          if (selectedContractor.value?.cpId == "0") return;
          if (selectedScheme.value?.fileNum == null) return;
          isFromScan.value = true;
          ref.read(scanCheckoutStateProvider.notifier).scan(
                storeID: selectedStore.value?["id"],
                barcode: param,
                contractor: selectedContractor.value!,
                slipNo: ctrlSlipNo.text,
                fileNum: selectedScheme.value!.fileNum!,
              );
        });
      });

      return () {
        if (timer != null) timer!.cancel();
      };
    }, []);

    final inScanMode = useState(true);
    final ctrlSchemeReadOnly = useTextEditingController(text: "");
    final enableDone = useState(false);
    final enablePrint = useState(false);
    final alreadyDone = useState(false);
    final selectedItemIndex = useState<int>(-1);

    alreadyDone.addListener(() {
      inScanMode.value = !alreadyDone.value;
      enablePrint.value = alreadyDone.value;
    });
    ref.listen(setDoneStateProvider, (previous, next) {
      if (next is SetDoneStateLoading) {
        isLoading.value = true;
      } else if (next is SetDoneStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is SetDoneStateDone) {
        isLoading.value = false;
        enablePrint.value = true;
        if (alreadyDone.value) {
          inScanMode.value = true;
          alreadyDone.value = false;
        } else {
          inScanMode.value = false;
          alreadyDone.value = true;
        }
      }
    });
    ref.listen(byNoStateProvider, (previous, next) {
      try {
        if (next is ByNoStateLoading) {
          isLoading.value = true;
        } else if (next is ByNoStateError) {
          isLoading.value = false;
          errorMessage.value = next.message;
          Timer(Duration(seconds: 3), () {
            errorMessage.value = "";
          });
        } else if (next is ByNoStateDone) {
          isLoading.value = false;
          ctrlContractorReadOnly.text = next.model.contractor.staffName;
          ctrlSlipNo.text = next.model.slipNo;
          listResponseModel.value = next.model.items;
          selectedStore.value = {
            "id": next.model.store?.storeID ?? "0",
            "name": next.model.store?.storeName ?? "No Store",
          };
          ctrlStoreReadOnly.text = next.model.store?.storeName ?? "";
          selectedScheme.value = SchemeLookupModel(
              fileNum: next.model.fileNum, scheme: next.model.scheme);
          selectedContractor.value = next.model.contractor;
          ctrlScheme.text = next.model.scheme.trim() + "\n";
          inScanMode.value = true;
          ctrlSchemeReadOnly.text =
              next.model.cpFileNum + " " + next.model.scheme;
          enableDone.value = true;
          if (next.model.isDone == "Y") {
            alreadyDone.value = true;
          } else {
            alreadyDone.value = false;
          }
          ref
              .read(listC1StateProvider.notifier)
              .listC1(fileNum: next.model.fileNum, slipNo: next.model.slipNo);
        }
      } catch (e) {
        print(e);
      }
    });

    ref.listen(scanCheckoutStateProvider, (prev, next) {
      if (next is ScanCheckoutStateLoading) {
        isLoading.value = true;
      } else if (next is ScanCheckoutStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is ScanCheckoutStateDone) {
        isLoading.value = false;
        errorMessage.value = next.message;
        if (next.message == "") {
          enableDone.value = true;
        }
        if (next.scanBarcode.isNotEmpty) {
          if (!alreadyHaveScannedMaterial.value) {
            alreadyHaveScannedMaterial.value = true;
            ctrlStoreReadOnly.text = selectedStore.value?["name"] ?? "No Store";
            ctrlContractorReadOnly.text =
                selectedContractor.value?.name ?? "No SO";
            ctrlSchemeReadOnly.text = (selectedScheme.value?.cpFileNum ?? "") +
                "|" +
                (selectedScheme.value?.scheme ?? "");
          }
          final List<String> newScanned = List.empty(growable: true);
          if (listScanned.value.isNotEmpty) {
            newScanned.addAll(listScanned.value);
            for (var str in next.scanBarcode) {
              newScanned.add(str);
            }
            listScanned.value = newScanned;
          } else {
            listScanned.value = next.scanBarcode;
          }
        }
        if (next.list.isNotEmpty) {
          final List<CheckoutScanResponseModel> xlist =
              List.empty(growable: true);
          xlist.addAll(next.list);
          xlist.addAll(listResponseModel.value);
          listResponseModel.value = xlist;
        }
        if (ctrlSlipNo.text == "") {
          ctrlSlipNo.text = next.slipNo;
        }
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      }
    });
    fcBarcode.requestFocus();
    final ctrlEditIssueQty = useTextEditingController(text: "");
    final listMaterialC1 = useState<List<MaterialC1>>(List.empty());
    ref.listen(looseQtySaveStateProvider, (prev, next) {
      if (next is LooseQtySaveStateDone) {
        isLoadingLooseQty.value = false;
        var lqs = looseQtyBarcodeList.value;
        if (lqs.containsKey(next.barcode)) {
          var lq = lqs[next.barcode];
          lqs[next.barcode] = lq + 1;
        } else {
          lqs.addEntries({next.barcode: 1}.entries);
        }
        looseQtyBarcodeList.value = lqs;
        var ylist = listBarcode.value.toList();
        ylist.remove(next.barcode);
        listBarcode.value = ylist;
        var xlist = listScanned.value.toList();
        xlist.remove(next.barcode);

        listScanned.value = xlist;
      } else if (next is LooseQtySaveStateLoading) {
        isLoadingLooseQty.value = true;
      } else if (next is LooseQtySaveStateError) {
        isLoadingLooseQty.value = false;
        errorMessage.value = next.message;
        Timer(Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      }
    });

    final deleteMessage =
        useState<String>("Are you sure you want to delete this item?");

    final prevIssueQty = useState<Map<String, double>>(HashMap());

    ref.listen(listC1StateProvider, (prev, next) {
      if (next is ListC1StateLoading) {
        isLoading.value = true;
        selectedItemIndex.value = -1;
      } else if (next is ListC1StateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
        isLoadingLooseQty.value = false;
        selectedItemIndex.value = -1;
      } else if (next is ListC1StateDone) {
        isLoading.value = false;
        isLoadingLooseQty.value = false;
        listMaterialC1.value = next.model;
        int countC1 = 0;
        Map<String, double> prevCurrIssue = HashMap();
        int prevCheckoutID = 0;
        int idxCheckoutID = 0;
        int selectedIdxCheckoutID = -1;
        for (var c1 in next.model.toList()) {
          try {
            if (int.parse(c1.checkoutID ?? "0") > prevCheckoutID) {
              selectedIdxCheckoutID = idxCheckoutID;
              prevCheckoutID = int.parse(c1.checkoutID ?? "0");
            }
            idxCheckoutID++;
          } catch (_) {}
          var idx = "${c1.checkoutID}-${c1.materialId!}";
          var x = prevIssueQty.value;
          x[idx] = prevCurrIssue[c1.materialId] ?? 0.0;
          try {
            x[idx] = x[idx]! + double.parse(c1.dueQty!);
          } catch (_) {}
          prevIssueQty.value = x;

          if (!prevCurrIssue.containsKey(c1.materialId)) {
            prevCurrIssue.addAll({c1.materialId!: double.parse(c1.issueQty!)});
          } else {
            prevCurrIssue[c1.materialId!] =
                prevCurrIssue[c1.materialId!]! + double.parse(c1.issueQty!);
          }
          if (c1.checkoutID != "0") {
            countC1++;
          }
        }

        if (countC1 == 1) {
          deleteMessage.value =
              "Are you sure you want to delete the material & the slip?";
        } else {
          deleteMessage.value = 'Are you sure you want to delete this item?';
        }
        if (listMaterialC1.value.isNotEmpty && errorMessage.value == "") {
          selectedItemIndex.value = selectedIdxCheckoutID;
        }
        var xlist = listScanned.value.toList();
        if (isFromScan.value) {
          isFromScan.value = false;
          if (listMaterialC1.value.isNotEmpty) {
            if (next.model[next.model.length - 1].allowDelete == "Y") {
              var nbf = NumberFormat("##0", "en_US");
              try {
                ctrlEditIssueQty.text = nbf.format(double.parse(
                    listMaterialC1.value[selectedItemIndex.value].issueQty ??
                        ""));
              } catch (_) {
                ctrlEditIssueQty.text =
                    listMaterialC1.value[selectedItemIndex.value].issueQty ??
                        "";
              }
            } else {
              selectedItemIndex.value = -1;
            }
          } else {
            selectedItemIndex.value = -1;
          }
        } else {
          selectedItemIndex.value = -1;
        }
        if (deletedBarcode.value != null) {
          if (listScanned.value.isNotEmpty) {
            xlist.remove(deletedBarcode.value);
          }
          deletedBarcode.value = null;
        }
        listScanned.value = xlist;
      }
    });
    double xwidth = MediaQuery.of(context).size.width;
    if (xwidth > 800) xwidth = 800;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Material Issue",
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
            ref
                .read(listCheckoutStateProvider.notifier)
                .listV2(vendorID: "", isReturn: "Y", staffID: "");
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
      // floatingActionButton:
      //     ctrlSlipNo.text == "" || listResponseModel.value.isEmpty
      //         ? null
      //         : FxFloatingABPrint(
      //             preUrl:
      //                 "http://${Constants.host}/reports/material_slip.php?=${base64Encode(utf8.encode(ctrlSlipNo.text.trim()))}",
      //           ),
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
            (materialSlipNo == "" && !alreadyHaveScannedMaterial.value)
                ? Row(
                    children: [
                      Expanded(
                        child: FxContractorLk(
                          width:
                              (kIsWeb) ? Constants.webWidth : double.infinity,
                          labelText: "Select SO",
                          hintText: "Select SO",
                          onChanged: (ctr) {
                            selectedContractor.value = ctr;
                            ctrlScheme.text = "";
                            selectedScheme.value = null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: FxStoreLk(
                          labelText: "Store",
                          hintText: "Store",
                          readOnly: materialSlipNo != "" ||
                              alreadyHaveScannedMaterial.value,
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
                          ctrl: ctrlContractorReadOnly,
                          width:
                              (kIsWeb) ? Constants.webWidth : double.infinity,
                          readOnly: true,
                          enabled: false,
                          labelText: "SO",
                          hintText: "So",
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: FxTextField(
                          ctrl: ctrlStoreReadOnly,
                          width:
                              (kIsWeb) ? Constants.webWidth : double.infinity,
                          readOnly: true,
                          enabled: false,
                          labelText: "Store",
                          hintText: "Store",
                        ),
                      ),
                    ],
                  ),
            const SizedBox(
              height: 10,
            ),
            (materialSlipNo == "" && !alreadyHaveScannedMaterial.value)
                ? FxAutoCompletionScheme(
                    labelText: "File No | Scheme ",
                    hintText: "Select Scheme",
                    width: (kIsWeb) ? Constants.webWidth : double.infinity,
                    optionWidth:
                        kIsWeb ? Constants.webWidth - 20 : double.infinity,
                    ctrl: ctrlScheme,
                    fc: fcScheme,
                    cpID: selectedContractor.value?.cpId,
                    staffID: selectedContractor.value?.staffId,
                    onSelectedScheme: (model) {
                      selectedScheme.value = model;
                      if (model?.fileNum != null) {
                        ref.read(listC1StateProvider.notifier).listC1(
                            fileNum: model!.fileNum!, slipNo: ctrlSlipNo.text);
                      }
                    },
                  )
                : FxTextField(
                    ctrl: ctrlSchemeReadOnly,
                    width: (kIsWeb) ? Constants.webWidth : double.infinity,
                    labelText: "Scheme",
                    readOnly: true,
                    enabled: false,
                  ),
            const SizedBox(height: 10),
            if (selectedScheme.value != null)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: xwidth + 75 + 20,
                    height: MediaQuery.of(context).size.height - 350,
                    child: Column(
                      children: [
                        const _C1ListHeader(),
                        const Divider(
                          color: Constants.greenDark,
                          thickness: 0.4,
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: listMaterialC1.value.length,
                              itemBuilder: (context, idx) {
                                final val = listMaterialC1.value[idx];

                                var color = Colors.black;

                                if (val.isExist == "N") {
                                  color = Constants.orange;
                                }
                                var bgColor = Colors.transparent;
                                // if (idx == listMaterialC1.value.length - 1) {
                                if (idx == selectedItemIndex.value) {
                                  if (ctrlSlipNo.text != "") {
                                    bgColor = Constants.yellowLight;
                                  }
                                }
                                String balQty = "";
                                String reqQty = val.qty ?? "0";
                                String issueQty = val.issueQty ?? "0";
                                final nbf = NumberFormat("##0", "en_US");
                                try {
                                  issueQty = nbf.format(double.parse(issueQty));
                                } catch (_) {}
                                try {
                                  reqQty = nbf.format(double.parse(reqQty));
                                } catch (_) {}
                                var dueQty = prevIssueQty.value[
                                        "${val.checkoutID!}-${val.materialId}"] ??
                                    0.0;
                                var strDueQty = "0";
                                try {
                                  strDueQty = nbf.format(dueQty);
                                } catch (_) {}
                                bool balQtyIsNegative = false;
                                try {
                                  balQty = nbf.format(double.parse(val.qty!) -
                                      double.parse(issueQty) -
                                      dueQty);
                                  if (double.parse(val.qty!) -
                                          double.parse(issueQty) -
                                          dueQty <
                                      0.0) {
                                    balQtyIsNegative = true;
                                  }
                                } catch (_) {}
                                String mcode = val.materialCode ?? "";
                                String description = val.description ?? "";
                                bool isNewMatGroup = false;
                                if (idx > 0 &&
                                    val.materialCode !=
                                        listMaterialC1
                                            .value[idx - 1].materialCode) {
                                  isNewMatGroup = true;
                                }
                                if (idx == 0) isNewMatGroup = true;
                                // if (!isNewMatGroup) {
                                //   mcode = "";
                                //   description = "";
                                //   reqQty = "";
                                // }
                                // if (val.isPO != 'Y') {
                                //   balQty = "";
                                // }
                                const textAlign = TextAlign.end;
                                const textAlignCenter = TextAlign.center;
                                return Container(
                                  color: bgColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              if (val.isExist == 'N') {
                                                selectedItemIndex.value = idx;
                                                var sQty = "";
                                                try {
                                                  final xbf = NumberFormat(
                                                      "##0", "en_US");
                                                  sQty = xbf.format(
                                                      double.parse(
                                                          val.issueQty ?? ""));
                                                } catch (_) {}
                                                ctrlEditIssueQty.text = sQty;
                                              } else {
                                                ctrlEditIssueQty.text = "";
                                                selectedItemIndex.value = -1;
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 120,
                                                  child: Text(
                                                    mcode,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    description,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    reqQty,
                                                    textAlign: textAlignCenter,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: 90,
                                                  child: Text(
                                                    strDueQty,
                                                    textAlign: textAlignCenter,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    issueQty,
                                                    textAlign: textAlignCenter,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    balQty,
                                                    textAlign: textAlignCenter,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: balQtyIsNegative
                                                          ? Colors.black
                                                          : color, // TODO: -ve color
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: 120,
                                                  child: Center(
                                                    child: Text(
                                                      val.barcode ?? "",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: color,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        SizedBox(
                                          width: 60,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              _RightDelete(
                                                  show: !alreadyDone.value &&
                                                      val.allowDelete == "Y",
                                                  val: val,
                                                  selectedScheme:
                                                      selectedScheme,
                                                  ctrlSlipNo: ctrlSlipNo,
                                                  deletedBarcode:
                                                      deletedBarcode,
                                                  message: deleteMessage.value,
                                                  onDelete: (barcode) {
                                                    var xlist = listBarcode
                                                        .value
                                                        .toList();
                                                    xlist = xlist
                                                        .where(
                                                            (b) => b != barcode)
                                                        .toList();
                                                    listBarcode.value = xlist;
                                                  }),
                                              _RightButton(
                                                val: val,
                                                showPrinter:
                                                    val.checkoutID != "0" &&
                                                        alreadyDone.value,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (listMaterialC1.value.isEmpty) Spacer(),
            if (isLoadingLooseQty.value)
              Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    color: Constants.greenDark,
                  ),
                ),
              ),
            if (selectedItemIndex.value >= 0 &&
                (listMaterialC1.value[selectedItemIndex.value].checkoutRef ==
                        "checkin" ||
                    listMaterialC1.value[selectedItemIndex.value].checkoutRef ==
                        "merge" ||
                    listMaterialC1.value[selectedItemIndex.value].checkoutRef ==
                        "split"))
              FxMaterialIssueInfo(
                  fileNum: selectedScheme.value?.fileNum ?? "",
                  slipNo: ctrlSlipNo.text,
                  onSave: (model, strQty, isOK, msg) {
                    selectedItemIndex.value = -1;
                    if (!isOK) {
                      errorMessage.value = msg;
                      Timer(Duration(seconds: 3), () {
                        errorMessage.value = "";
                      });
                    }
                  },
                  model: listMaterialC1.value[selectedItemIndex.value],
                  index: selectedItemIndex.value,
                  ctrlEdit: ctrlEditIssueQty),
            if (selectedScheme.value != null)
              if (inScanMode.value)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: FxTextField(
                    width: double.infinity,
                    maxHeight: 50,
                    focusNode: fcBarcode,
                    ctrl: ctrlBarcode,
                    labelText: "Scan Barcode",
                    hintText: "Enter|Scan Barcode",
                    enabled: selectedScheme.value != null,
                    onSubmitted: (val) {
                      // if (looseQtyBarcodeList.value.containsKey(val)) {
                      //   if (looseQtyBarcodeList.value[val] >= 2) {
                      //     errorMessage.value =
                      //         "Barcode " + val + " already used 2 time";
                      //     Timer(Duration(seconds: 3), () {
                      //       errorMessage.value = "";
                      //     });
                      //   }
                      // }
                      final List<String> list = List.empty(growable: true);
                      list.addAll(listBarcode.value.toList());
                      list.add(val);
                      listBarcode.value = list;
                      ctrlBarcode.text = "";
                      fcBarcode.requestFocus();
                      // print(listBarcode.value.toList().toString());
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
                            child: Image.asset("images/icon_scan_barcode.png",
                                height: 48),
                          ),
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
            if (inScanMode.value)
              Row(
                children: [
                  Expanded(
                    child: FxButton(
                      maxWidth: double.infinity,
                      title: "Done",
                      color: Constants.greenDark,
                      onPress: enableDone.value
                          ? () {
                              selectedItemIndex.value = -1;
                              ref.read(setDoneStateProvider.notifier).setDone(
                                    slipNo: ctrlSlipNo.text,
                                    status: "Y",
                                  );
                            }
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: FxButton(
                      maxWidth: double.infinity,
                      color: Constants.blue,
                      title: "Print Issue Slips",
                      onPress: enablePrint.value
                          ? () {
                              final snow =
                                  "&t=${DateTime.now().toIso8601String()}";
                              var url =
                                  "http://${Constants.host}/reports/material_slip.php?no=${base64Encode(utf8.encode(ctrlSlipNo.text.trim()))}$snow";
                              if (kIsWeb) {
                                html.window.open(url, "rpttab");
                                return;
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            if (!inScanMode.value)
              Row(
                children: [
                  alreadyDone.value
                      ? Expanded(
                          child: FxButton(
                            maxWidth: double.infinity,
                            title: "Edit",
                            color: Constants.orange,
                            onPress: () {
                              ref.read(setDoneStateProvider.notifier).setDone(
                                    slipNo: ctrlSlipNo.text,
                                    status: "N",
                                  );
                            },
                          ),
                        )
                      : Expanded(
                          child: FxButton(
                            maxWidth: double.infinity,
                            title: "Scan",
                            onPress: selectedScheme.value != null
                                ? () {
                                    inScanMode.value = true;
                                  }
                                : null,
                            color: Constants.greenDark,
                          ),
                        ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: alreadyDone.value
                        ? FxButton(
                            maxWidth: double.infinity,
                            color: Constants.blue,
                            title: "Print Issued Materials",
                            onPress: enablePrint.value
                                ? () {
                                    final snow =
                                        "&t=${DateTime.now().toIso8601String()}";
                                    var url =
                                        "http://${Constants.host}/reports/material_slip.php?no=${base64Encode(utf8.encode(ctrlSlipNo.text.trim()))}$snow";
                                    if (kIsWeb) {
                                      html.window.open(url, "rpttab");
                                      return;
                                    }
                                  }
                                : null,
                          )
                        : FxButton(
                            maxWidth: double.infinity,
                            title: "Print Required Materials",
                            color: Constants.blue,
                            onPress: selectedScheme.value == null
                                ? null
                                : () {
                                    final snow =
                                        "&t=${DateTime.now().toIso8601String()}";
                                    final url =
                                        "https://${Constants.host}/reports/material_list_redir.php?file_num=${selectedScheme.value!.fileNum}" +
                                            snow;

                                    if (kIsWeb) {
                                      html.window.open(url, "rpttab");
                                      return;
                                    }
                                  },
                          ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RightDelete extends HookConsumerWidget {
  const _RightDelete({
    super.key,
    required this.val,
    required this.selectedScheme,
    required this.ctrlSlipNo,
    required this.deletedBarcode,
    required this.show,
    required this.message,
    required this.onDelete,
  });

  final MaterialC1 val;
  final ValueNotifier<SchemeLookupModel?> selectedScheme;
  final TextEditingController ctrlSlipNo;
  final ValueNotifier<String?> deletedBarcode;
  final void Function(String) onDelete;
  final bool show;
  final String message;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!show) {
      return SizedBox.shrink();
    }
    return InkWell(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete'),
              content: Text(message),
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
                        .read(deleteCheckoutStateProvider.notifier)
                        .deleteCheckout(
                          checkoutID: val.checkoutID ?? "0",
                          fileNum: selectedScheme.value?.fileNum ?? "0",
                          slipNo: ctrlSlipNo.text,
                        );
                    deletedBarcode.value = val.barcode;
                    onDelete(val.barcode ?? "");
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
        height: 20,
      ),
    );
  }
}

class _RightButton extends StatelessWidget {
  const _RightButton({
    super.key,
    required this.val,
    required this.showPrinter,
  });

  final MaterialC1 val;
  final bool showPrinter;
  @override
  Widget build(BuildContext context) {
    if (!showPrinter) {
      return SizedBox.shrink();
    }
    return InkWell(
      onTap: () {
        final snow = "&t=${DateTime.now().toIso8601String()}";
        final url =
            "https://${Constants.host}/reports/checkout_material.php?cid=${val.checkoutID}$snow";
        if (kIsWeb) {
          html.window.open(url, "rpttab");
          return;
        }
      },
      child: Image.asset(
        "images/icon_printer.png",
        height: 20,
      ),
    );
  }
}

class _C1ListHeader extends StatelessWidget {
  const _C1ListHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textAlign = TextAlign.end;
    const textAlignCenter = TextAlign.center;
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "Code",
            style: TextStyle(
              fontSize: 16,
              color: Constants.greenDark,
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: Text(
            "Description",
            style: TextStyle(
              fontSize: 16,
              color: Constants.greenDark,
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            "Required",
            textAlign: textAlignCenter,
            style: TextStyle(
              fontSize: 16,
              color: Constants.greenDark,
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            "Prev. Issued",
            textAlign: textAlignCenter,
            style: TextStyle(
              fontSize: 16,
              color: Constants.greenDark,
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            "Cur. Issue",
            textAlign: textAlignCenter,
            style: TextStyle(
              fontSize: 16,
              color: Constants.greenDark,
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            "Balance ",
            textAlign: textAlignCenter,
            style: TextStyle(
              fontSize: 16,
              color: Constants.greenDark,
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: Center(
            child: Text(
              "Serial No",
              style: TextStyle(
                fontSize: 16,
                color: Constants.greenDark,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(width: 24),
      ],
    );
  }
}
