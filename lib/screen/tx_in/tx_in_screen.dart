import 'dart:async';
// import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../model/store_model.dart';
import '../../model/tx_in_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_material_tx_in_info.dart';
import '../../widgets/fx_store_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'dart:html' as html;

import 'tx_in_delete_provider.dart';
import 'tx_in_list_provider.dart';
import 'tx_in_scan_provider.dart';
import 'user_all_store_provider.dart';

class TxInScreen extends HookConsumerWidget {
  final String materialSlipNo;
  const TxInScreen({
    Key? key,
    this.materialSlipNo = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final ctrlBarcode = useTextEditingController(text: "");
    final isLoading = useState(false);
    final errorMessage = useState("");
    final selectedStore = useState<StoreModel?>(null);
    final selectedStoreTo = useState<StoreModel?>(null);
    final fcBarcode = FocusNode();
    final ctrlSlipNo = useTextEditingController(text: "");
    final ctrlEditReceiveQty = useTextEditingController(text: "");
    final isFromScan = useState(false);
    final isInEditMode = useState(false);

    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
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
        ctrlSlipNo.text = materialSlipNo;
        Timer(Duration(milliseconds: 300), () {
          ref.read(txInListStateProvider.notifier).list(slipNo: materialSlipNo);
        });
      }
      return () {};
    }, [materialSlipNo]);
    final listAclStore = ref.read(userAclStoreProvider);
    final stateForceAll = useState<bool>(listAclStore.length > 1);
    final listAllStore = ref.read(userAllStoreProvider);

    final lastTxInIdx = useState<int>(-1);
    final selectedIdxMaterial = useState<int>(-1);

    final listTxIn = useState<List<TxInListModel>>(List.empty());
    ref.listen(txInListStateProvider, (prev, next) {
      if (next is TxInListStateLoading) {
        isLoading.value = true;
      } else if (next is TxInListStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(Duration(seconds: 3), () {
          errorMessage.value = "";
        });
        isFromScan.value = false;
      } else if (next is TxInListStateDone) {
        if (next.list.isNotEmpty && next.list[0].isDeleted == "Y") {
          listTxIn.value = List.empty();
          lastTxInIdx.value = - 1;
        } else {
          listTxIn.value = next.list;
          lastTxInIdx.value = next.list.length - 1;
        }
        isLoading.value = false;
        if (isFromScan.value) {
          selectedIdxMaterial.value = lastTxInIdx.value;
          ctrlEditReceiveQty.text =
              next.list[lastTxInIdx.value].txInPackQty ?? "0";
        } else {
          selectedIdxMaterial.value = -1;
          ctrlEditReceiveQty.text = "";
        }
        isFromScan.value = false;
        final allStore = ref.read(userAllStoreProvider);
        if (selectedStore.value?.storeID == "0" ||
            selectedStore.value == null) {
          if (next.list.isNotEmpty) {
            final storeID = next.list[0].txOutStoreID;
            selectedStore.value =
                allStore.firstWhere((st) => st.storeID == storeID);
          }
        }
        if (selectedStoreTo.value?.storeID == "0" ||
            selectedStoreTo.value == null) {
          if (next.list.isNotEmpty) {
            final storeID = next.list[0].txOutToStoreID;
            selectedStoreTo.value =
                allStore.firstWhere((st) => st.storeID == storeID);
          }
        }
      }
    });

    ref.listen(txInScanStateProvider, (prev, next) {
      if (next is TxInScanStateLoading) {
        isLoading.value = true;
      } else if (next is TxInScanStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is TxInScanStateDone) {
        isFromScan.value = true;
        isLoading.value = false;
        ctrlSlipNo.text = next.model.slipNo ?? "";
        var store = listAllStore
            .firstWhere((st) => st.storeID == next.model.txOutStoreID);
        selectedStore.value = store;
        // var toStore = listAllStore.firstWhere((st) => st.storeID == next.model.txOutToStoreID);
        // selectedStoreTo.value = toStore;
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
          "Transfer In",
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
            Row(
              children: [
                Expanded(
                  child: _StoreLkText(
                      name: selectedStore.value?.storeName ?? "",
                      label: "From :"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: materialSlipNo == ""
                      ? FxStoreLk(
                          isTo: true,
                          hintText: "To Store",
                          readOnly: listTxIn.value.isNotEmpty,
                          isAll: false,
                          withAll: stateForceAll.value,
                          allText: "Select",
                          forceAll: stateForceAll.value,
                          onChanged: (model) {
                            selectedStoreTo.value = model;
                          },
                        )
                      : _StoreLkText(
                          label: "To Store",
                          name: selectedStoreTo.value?.storeName ?? ""),
                ),
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
            if (listTxIn.value.isNotEmpty) SizedBox(height: 10),
            if (listTxIn.value.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: xwidth + 75,
                    height: MediaQuery.of(context).size.height - 350,
                    child: Column(
                      children: [
                        const _TxInHeader(),
                        const Divider(
                          color: Constants.greenDark,
                          thickness: 0.4,
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: listTxIn.value.length,
                              itemBuilder: (context, idx) {
                                final val = listTxIn.value[idx];

                                var color = Colors.black;
                                var bgColor = Colors.transparent;
                                if (idx == lastTxInIdx.value) {
                                  if (ctrlSlipNo.text != "") {
                                    bgColor = Constants.yellowLight;
                                  }
                                }
                                final nbf = NumberFormat("##0", "en_US");
                                String qty = "";
                                try {
                                  qty = nbf.format(
                                      double.parse(val.txInPackQty ?? ""));
                                } catch (_) {}
                                const textAlignCenter = TextAlign.center;
                                return Container(
                                  color: bgColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  val.materialCode ?? "",
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
                                                  val.description ?? "",
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
                                                width: 100,
                                                child: Text(
                                                  qty,
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
                                                width: 120,
                                                child: Center(
                                                  child: Text(
                                                    val.txInBarcode ?? "",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                width: 60,
                                                child: isInEditMode.value &&
                                                        val.haveTransaction ==
                                                            "N"
                                                    ? Row(
                                                        children: [
                                                          //InkWell(
                                                          //    child:
                                                          //        Image.asset(
                                                          //      "images/icon_edit.png",
                                                          //      width: 24,
                                                          //    ),
                                                          //    onTap: () {}),
                                                          //SizedBox(width: 10),
                                                          InkWell(
                                                            child: Image.asset(
                                                              "images/icon_delete.png",
                                                              width: 24,
                                                            ),
                                                            onTap: () {
                                                              showDialog<void>(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Delete'),
                                                                    content:
                                                                        const Text(
                                                                            'Are you sure you want to delete this item?'),
                                                                    actions: <Widget>[
                                                                      FxButton(
                                                                        maxWidth:
                                                                            80,
                                                                        height:
                                                                            34,
                                                                        title:
                                                                            "No",
                                                                        color: Constants
                                                                            .greenDark,
                                                                        onPress:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                      FxButton(
                                                                        maxWidth:
                                                                            80,
                                                                        height:
                                                                            34,
                                                                        title:
                                                                            "Yes",
                                                                        color: Constants
                                                                            .red,
                                                                        onPress:
                                                                            () {
                                                                          ref
                                                                              .read(txInDeleteStateProvider.notifier)
                                                                              .delete(
                                                                                txInID: val.txInID ?? "",
                                                                                slipNo: ctrlSlipNo.text,
                                                                              );
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(
                                                width: 10,
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
            if (listTxIn.value.isEmpty)
              Expanded(
                child: const SizedBox(
                  height: 10,
                ),
              ),
            if (selectedIdxMaterial.value >= 0)
              FxMaterialTxInInfo(
                index: selectedIdxMaterial.value,
                slipNo: ctrlSlipNo.text,
                txInID: listTxIn.value[selectedIdxMaterial.value].txInID ?? "0",
                inEditMode: true,
                onSave: (txInID, model, strQty, isOK, msg) {
                  selectedIdxMaterial.value = -1;
                  if (!isOK) {
                    errorMessage.value = msg;
                    Timer(Duration(seconds: 3), () {
                      errorMessage.value = "";
                    });
                  }
                },
                model: listTxIn.value[selectedIdxMaterial.value],
                ctrlEdit: ctrlEditReceiveQty,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: FxTextField(
                width: double.infinity,
                maxHeight: 50,
                focusNode: fcBarcode,
                ctrl: ctrlBarcode,
                labelText: "Scan Barcode",
                hintText: "Enter|Scan Barcode",
                enabled: selectedStoreTo.value != null &&
                    selectedStoreTo.value!.storeID != "0",
                onSubmitted: (val) {
                  if (selectedStore.value?.storeID ==
                      selectedStoreTo.value?.storeID) {
                    errorMessage.value = "From Store must be <> To Store";
                    Timer(Duration(seconds: 3), () {
                      errorMessage.value = "";
                    });
                    return;
                  }
                  if (listTxIn.value.isEmpty) {
                    ref.read(txInScanStateProvider.notifier).scan(
                          slipNo: ctrlSlipNo.text,
                          storeID: "0",
                          storeToID: selectedStoreTo.value?.storeID ?? "0",
                          barcode: val,
                        );
                  } else {
                    ref.read(txInScanStateProvider.notifier).scan(
                          slipNo: ctrlSlipNo.text,
                          storeID: selectedStore.value?.storeID ?? "0",
                          storeToID: selectedStoreTo.value?.storeID ?? "0",
                          barcode: val,
                        );
                  }
                  ctrlBarcode.text = "";
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: (materialSlipNo != "" || ctrlSlipNo.text != "") &&
                          listTxIn.value.isNotEmpty &&
                          !isInEditMode.value
                      ? FxButton(
                          maxWidth: double.infinity,
                          title: "Edit",
                          color: Constants.orange,
                          onPress: listTxIn.value.isEmpty
                              ? null
                              : () {
                                  isInEditMode.value = true;
                                },
                        )
                      : FxButton(
                          maxWidth: double.infinity,
                          title: "Done",
                          color: Constants.greenDark,
                          onPress: listTxIn.value.isEmpty
                              ? null
                              : () {
                                  isInEditMode.value = false;
                                  //Navigator.of(context).pop();
                                },
                        ),
                ),
                //Expanded(
                //  child: FxButton(
                //    maxWidth: double.infinity,
                //    title: "Done",
                //    color: Constants.greenDark,
                //    onPress: listTxIn.value.isEmpty
                //        ? null
                //        : () {
                //            Navigator.of(context).pop();
                //          },
                //  ),
                //),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: FxButton(
                    maxWidth: double.infinity,
                    color: Constants.blue,
                    title: "Print Receive Slips",
                    onPress: listTxIn.value.isEmpty
                        ? null
                        : () {
                            final snow =
                                "&t=${DateTime.now().toIso8601String()}";
                            var url =
                                "http://${Constants.host}/reports/transfer_in_slip.php?no=${base64Encode(utf8.encode(ctrlSlipNo.text.trim()))}$snow";
                            if (kIsWeb) {
                              html.window.open(url, "rpttab");
                              return;
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _StoreLkText extends StatelessWidget {
  const _StoreLkText({
    super.key,
    required this.label,
    required this.name,
  });

  final String label;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Container(
            width: 400,
            // decoration: BoxDecoration(
            //   borderRadius: const BorderRadius.all(
            //     Radius.circular(10),
            //   ),
            //   border: Border.all(
            //     color: Constants.greenDark,
            //     width: 1,
            //   ),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 10,
          top: -2,
          child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Constants.greenDark,
                  ),
                ),
              )),
        )
      ],
    );
  }
}

class _TxInHeader extends StatelessWidget {
  const _TxInHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textAlign = TextAlign.end;
    const textAlignCenter = TextAlign.center;
    return Row(
      children: [
        SizedBox(
          width: 100,
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
          width: 100,
          child: Center(
            child: Text(
              "Qty",
              style: TextStyle(
                fontSize: 16,
                color: Constants.greenDark,
              ),
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
      ],
    );
  }
}
