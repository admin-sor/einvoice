import 'dart:async';
// import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/screen/tx_out/tx_out_delete_provider.dart';
import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../model/store_model.dart';
import '../../model/tx_out_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_store_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'dart:html' as html;

import '../tx_in/user_all_store_provider.dart';
import 'tx_out_list_provider.dart';
import 'tx_out_scan_provider.dart';

class TxOutScreen extends HookConsumerWidget {
  final String materialSlipNo;
  const TxOutScreen({
    Key? key,
    this.materialSlipNo = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInEditMode = useState(false);
    final selectedEditIndex = useState(-1);
    final ctrlEditQty = useTextEditingController(text: "");
    final ctrlBarcode = useTextEditingController(text: "");
    final isLoading = useState(false);
    final errorMessage = useState("");
    final selectedStore = useState<StoreModel?>(null);
    final selectedStoreTo = useState<StoreModel?>(null);
    final fcBarcode = FocusNode();
    final ctrlSlipNo = useTextEditingController(text: "");
    final isFromScan = useState<bool>(false);
    final isLessThan1Day = useState<bool>(true);
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
        isLessThan1Day.value = false;
        Timer(const Duration(milliseconds: 300), () {
          ref
              .read(txOutListStateProvider.notifier)
              .list(slipNo: materialSlipNo);
        });
      }
      return () {};
    }, [materialSlipNo]);

    final listAclStore = ref.read(userAclStoreProvider);

    final stateForceAll = useState<bool>(listAclStore.length > 1);

    final lastTxOutIdx = useState<int>(-1);

    final listAllStore = ref.read(userAllStoreProvider);

    final listTxOut = useState<List<TxOutListModel>>(List.empty());
    ref.listen(txOutScanStateProvider, (prex, next) {
      if (next is TxOutScanStateDone) {
        ctrlSlipNo.text = next.model.slipNo ?? "";
        // if (listTxOut.value.isEmpty && selectedStore.value != null) {
        //   var store = listAllStore.value
        //       .firstWhere((st) => st.storeID == next.model.storeID);
        //   selectedStore.value = store;
        // }
      }
    });
    ref.listen(txOutListStateProvider, (prev, next) {
      if (next is TxOutListStateLoading) {
        isLoading.value = true;
      } else if (next is TxOutListStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is TxOutListStateDone) {
        if (next.list.isNotEmpty && next.list[0].isDeleted == "Y") {
          listTxOut.value = List.empty();
          lastTxOutIdx.value = -1;
          isLessThan1Day.value = true;
        } else if (next.list.isEmpty) {
          listTxOut.value = List.empty();
          lastTxOutIdx.value = -1;
          isLessThan1Day.value = true;
        } else {
          listTxOut.value = next.list;
          lastTxOutIdx.value = next.list.length - 1;
          if (next.list[0].isLess1Day == "Y") {
            isLessThan1Day.value = true;
          } else {
            isLessThan1Day.value = false;
          }
        }
        isLoading.value = false;
        final allStore = ref.read(userAllStoreProvider);
        if (selectedStore.value?.storeID == "0" ||
            selectedStore.value == null) {
          if (next.list.isNotEmpty) {
            final storeID = next.list[0].storeID;
            selectedStore.value =
                allStore.firstWhere((st) => st.storeID == storeID);
          }
        }
        if (selectedStoreTo.value?.storeID == "0" ||
            selectedStoreTo.value == null) {
          if (next.list.isNotEmpty) {
            final storeID = next.list[0].storeToID;
            selectedStoreTo.value =
                allStore.firstWhere((st) => st.storeID == storeID);
          }
        }
      }
    });

    ref.listen(txOutScanStateProvider, (prev, next) {
      if (next is TxOutScanStateLoading) {
        isLoading.value = true;
      } else if (next is TxOutScanStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is TxOutScanStateDone) {
        isLoading.value = false;
        ctrlSlipNo.text = next.model.slipNo ?? "";
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
          "Transfer Out",
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
                  child: materialSlipNo == ""
                      ? FxStoreLk(
                          hintText: "From / Sending Store:",
                          forceAll: stateForceAll.value,
                          withAll: stateForceAll.value,
                          allText: "Select",
                          initialValueId: selectedStore.value?.storeID,
                          readOnly: listTxOut.value.isNotEmpty,
                          onChanged: (model) {
                            selectedStore.value = model;
                          },
                        )
                      : _StoreLkText(
                          name: selectedStore.value?.storeName ?? "",
                          label: "From / Sending Store:"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: materialSlipNo == ""
                      ? FxStoreLk(
                          hintText: "To / Receiving Store:",
                          initialValueId: selectedStoreTo.value?.storeID,
                          isTo: true,
                          allText: "Select",
                          readOnly: listTxOut.value.isNotEmpty,
                          isAll: true,
                          forceAll: true,
                          withAll: true,
                          onChanged: (model) {
                            selectedStoreTo.value = model;
                          },
                        )
                      : _StoreLkText(
                          label: "To / Receiving Store:",
                          name: selectedStoreTo.value?.storeName ?? "",
                        ),
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
            if (listTxOut.value.isNotEmpty) const SizedBox(height: 10),
            if (listTxOut.value.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: xwidth + 75,
                    height: MediaQuery.of(context).size.height - 350,
                    child: Column(
                      children: [
                        const _TxOutHeader(),
                        const Divider(
                          color: Constants.greenDark,
                          thickness: 0.4,
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: listTxOut.value.length,
                              itemBuilder: (context, idx) {
                                final val = listTxOut.value[idx];

                                var color = Colors.black;
                                var bgColor = Colors.transparent;
                                if (idx == lastTxOutIdx.value) {
                                  if (ctrlSlipNo.text != "") {
                                    bgColor = Constants.yellowLight;
                                  }
                                }
                                final nbf = NumberFormat("##0", "en_US");
                                String qty = "";
                                try {
                                  qty = nbf.format(double.parse(val.qty ?? ""));
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
                                                  val.code ?? "",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: color,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
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
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child:
                                                    selectedEditIndex.value ==
                                                            idx
                                                        ? FxTextField(
                                                            ctrl: ctrlEditQty,
                                                            labelText: "")
                                                        : Text(
                                                            qty,
                                                            textAlign:
                                                                textAlignCenter,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: color,
                                                            ),
                                                          ),
                                              ),
                                              const SizedBox(
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
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              isInEditMode.value &&
                                                      val.isReceived == "N"
                                                  ? SizedBox(
                                                      width: 60,
                                                      child: Row(
                                                        children: [
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
                                                                              .read(txOutDeleteStateProvider.notifier)
                                                                              .delete(
                                                                                txOutID: val.txOutID ?? "",
                                                                                slipNo: materialSlipNo,
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
                                                      ),
                                                    )
                                                  : SizedBox(width: 60),
                                              SizedBox(width: 60),
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
            if (listTxOut.value.isEmpty)
              const Expanded(
                child: SizedBox(
                  height: 10,
                ),
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
                enabled: selectedStore.value != null &&
                    selectedStoreTo.value != null &&
                    selectedStore.value!.storeID !=
                        selectedStoreTo.value!.storeID &&
                    selectedStore.value!.storeID != "0" &&
                    selectedStoreTo.value!.storeID != "0" &&
                    isLessThan1Day.value,
                onSubmitted: (val) {
                  if (selectedStore.value?.storeID ==
                      selectedStoreTo.value?.storeID) {
                    errorMessage.value = "From Store must be <> To Store";
                    Timer(const Duration(seconds: 3), () {
                      errorMessage.value = "";
                    });
                    return;
                  }
                  // if (listTxOut.value.isEmpty) {
                  //   ref.read(txOutScanStateProvider.notifier).scan(
                  //         slipNo: ctrlSlipNo.text,
                  //         storeID: "0",
                  //         storeToID: selectedStoreTo.value?.storeID ?? "0",
                  //         barcode: val,
                  //       );
                  // } else {
                  ref.read(txOutScanStateProvider.notifier).scan(
                        slipNo: ctrlSlipNo.text,
                        storeID: selectedStore.value?.storeID ?? "0",
                        storeToID: selectedStoreTo.value?.storeID ?? "0",
                        barcode: val,
                      );
                  // }
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
                          listTxOut.value.isNotEmpty &&
                          !isInEditMode.value
                      ? FxButton(
                          maxWidth: double.infinity,
                          title: "Edit",
                          color: Constants.orange,
                          onPress:
                              listTxOut.value.isEmpty || !isLessThan1Day.value
                                  ? null
                                  : () {
                                      isInEditMode.value = true;
                                    },
                        )
                      : FxButton(
                          maxWidth: double.infinity,
                          title: "Done",
                          color: Constants.greenDark,
                          onPress: listTxOut.value.isEmpty
                              ? null
                              : () {
                                  isInEditMode.value = false;
                                  //Navigator.of(context).pop();
                                  //var isDirty = false;
                                  //if (selectedEditIndex.value > -1) {
                                  //  var xl = listTxOut.value.toList();
                                  //  xl[selectedEditIndex.value].qty =
                                  //      ctrlEditQty.text;
                                  //  listTxOut.value = xl;
                                  //  ctrlEditQty.text = "";
                                  //  selectedEditIndex.value = -1;
                                  //}
                                  //for (var item in listTxOut.value) {
                                  //  if (item.qty != item.originQty) {
                                  //    isDirty = true;
                                  //    break;
                                  //  }
                                  //}
                                  //if (!isDirty) {
                                  //} else {
                                  //  ref
                                  //      .read(txOutSaveStateProvider.notifier)
                                  //      .save(
                                  //          list: listTxOut.value,
                                  //          slipNo: materialSlipNo);
                                  //}
                                },
                        ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: FxButton(
                    maxWidth: double.infinity,
                    color: Constants.blue,
                    title: "Print Transfer Slips",
                    onPress: listTxOut.value.isEmpty
                        ? null
                        : () {
                            final snow =
                                "&t=${DateTime.now().toIso8601String()}";
                            var url =
                                "http://${Constants.host}/reports/transfer_out_slip.php?no=${base64Encode(utf8.encode(ctrlSlipNo.text.trim()))}$snow";
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

class _TxOutHeader extends StatelessWidget {
  const _TxOutHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textAlign = TextAlign.end;
    const textAlignCenter = TextAlign.center;
    return const Row(
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
        SizedBox(width: 60)
      ],
    );
  }
}

class _StoreLkText extends StatelessWidget {
  const _StoreLkText({
    super.key,
    required this.name,
    required this.label,
  });

  final String name;
  final String label;

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
          left: 4,
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

//class _StoreLkText extends StatelessWidget {
//  const _StoreLkText({
//    super.key,
//    required this.name,
//    required this.label,
//  });
//
//  final String name;
//  final String label;
//
//  @override
//  Widget build(BuildContext context) {
//    return Stack(
//      children: [
//        Padding(
//          padding: const EdgeInsets.only(top: 5.0),
//          child: Container(
//            width: 400,
//            decoration: BoxDecoration(
//              borderRadius: const BorderRadius.all(
//                Radius.circular(10),
//              ),
//              border: Border.all(
//                color: Constants.greenDark,
//                width: 1,
//              ),
//            ),
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: [
//                Padding(
//                  padding: const EdgeInsets.all(15),
//                  child: Text(
//                    name,
//                    style: TextStyle(
//                      fontSize: 16,
//                      color: Colors.black,
//                    ),
//                  ),
//                ),
//              ],
//            ),
//          ),
//        ),
//        Positioned(
//          left: 10,
//          top: -2,
//          child: Container(
//              color: Colors.white,
//              child: Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 10),
//                child: Text(
//                  label,
//                  style: TextStyle(
//                    fontSize: 14,
//                    color: Constants.greenDark,
//                  ),
//                ),
//              )),
//        )
//      ],
//    );
//  }
//}
