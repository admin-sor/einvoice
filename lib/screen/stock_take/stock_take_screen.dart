// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sor_inventory/widgets/fx_store_lk.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../model/stock_take_model.dart';
import '../../model/stock_take_summary_model.dart';
import '../../repository/stock_take_repository.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_material_stock_take.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import '../stock_take_menu_screen/stock_take_get_provider.dart';
import 'stock_take_close_provider.dart';
import 'stock_take_current_provider.dart';
import 'stock_take_multiscan_provider.dart';
import 'stock_take_provider.dart';
import 'stock_take_stream_provider.dart';

class StockTakeScreen extends HookConsumerWidget {
  final bool isContinue;

  const StockTakeScreen({Key? key, required this.isContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");
    final isInit = useState(true);
    final stockTakeModel = useState<StockTakeModel?>(null);
    final ctrQrCode = useTextEditingController(text: "");
    final qrCodeFocusNode = FocusNode();
    final isScanLoading = useState(false);
    final scanErrorMessage = useState("");
    final multiScanErrorMessage = useState("");
    final scanResponse = useState<StockTakeScanResponse?>(null);
    final isDoneChecking = useState(false);
    final listSummary = useState<List<GroupSummaryModelV2>>(List.empty());
    final cbQrCode = useState<List<String>>(List.filled(100, ""));
    final cbHead = useState<int>(0);
    final cbTail = useState<int>(0);
    const maxCbCount = 100;
    final isProcessingQrCode = useState(false);
    final listScanError =
        useState<List<StockTakeMultiScanResponse>>(List.empty());
    final inUnGroupMode = useState(false);
    final curStreamValue = useState<int>(-1);

    final selectedStore = useState<Map<String, dynamic>?>(null);
    final storeIsReadOnly = useState(false);
    final loginModel = useState<SorUser?>(null);
    final selectedIdx = useState(-1);
    final ctrlScanQty = useTextEditingController();
    final isAfterSave = useState(false);
    final isAfterScan = useState(false);
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
    final isInitStockTake = useState(true);
    if (isInitStockTake.value) {
      isInitStockTake.value = false;
      Timer(const Duration(milliseconds: 500), () {
        if (isContinue == false) {
          ref.read(stockTakeProvider.notifier).create();
        } else {
          ref.read(stockTakeGetProvider.notifier).getOpenEvent();
        }
      });
    }
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

    ref.read(stockTakeStreamProvider).when(
          data: (value) {
            if (curStreamValue.value == value) return;
            curStreamValue.value = value;
            if (listScanError.value.isNotEmpty) {
              final curList = listScanError.value;
              final first = curList.first;
              curList.removeAt(0);
              listScanError.value = curList;
              multiScanErrorMessage.value = "${first.qrCode}  ${first.message}";
            } else {
              if (multiScanErrorMessage.value != "") {
                multiScanErrorMessage.value = "";
              }
            }
          },
          loading: () {},
          error: (e, s) {},
        );

    final Function(String) cbPush = (prm) {
      final tmpList = cbQrCode.value;
      int tmpTail = cbTail.value;
      tmpList[tmpTail] = prm;
      tmpTail++;
      if (tmpTail >= maxCbCount) tmpTail = 0;
      cbQrCode.value = tmpList;
      cbTail.value = tmpTail;
    };

    final List<String> Function() cbPop = () {
      final tmpList = cbQrCode.value;
      int tmpTail = cbTail.value;
      int tmpHead = cbHead.value;
      if (tmpHead == tmpTail) {
        return List<String>.empty();
      }
      List<String> retList = List.empty(growable: true);
      if (tmpTail < tmpHead) {
        retList.addAll(tmpList.sublist(tmpHead));
        tmpHead = 0;
      }
      retList.addAll(tmpList.sublist(tmpHead, tmpTail));
      cbHead.value = tmpTail;
      return retList;
    };

    ref.listen(stockTakeProvider, (prev, next) {
      if (next is StockTakeStateLoading) {
        isLoading.value = true;
      } else if (next is StockTakeStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
          Navigator.of(context).pop();
        });
      } else if (next is StockTakeStateDone) {
        stockTakeModel.value = next.event;
        isLoading.value = false;
        if (next.event.stockTakeStoreID != "0") {
          storeIsReadOnly.value = true;
        } else {
          storeIsReadOnly.value = false;
        }
        // move to stockTakeProvider
        // ref.read(stockTakeCurrentProvider.notifier).currentSummary(
        //     stockTakeID: stockTakeModel.value?.stockTakeID ?? "0");
      }
    });
    ref.listen(stockTakeGetProvider, (prev, next) {
      if (next is StockTakeGetStateLoading) {
        isLoading.value = true;
        stockTakeModel.value = null;
      } else if (next is StockTakeGetStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
        isDoneChecking.value = true;
      } else if (next is StockTakeGetStateDone) {
        isLoading.value = false;
        if (next.event != null) {
          stockTakeModel.value = next.event;
          if (next.event!.stockTakeStoreID != null) {
            if (next.event!.stockTakeStoreID != "0") {
              storeIsReadOnly.value = true;
            } else {
              storeIsReadOnly.value = false;
            }
          } else {
            storeIsReadOnly.value = false;
          }
          // ref.read(stockTakeCurrentProvider.notifier).currentSummary(
          //     stockTakeID: stockTakeModel.value?.stockTakeID ?? "0");
        } else {
          stockTakeModel.value = null;
        }
        isDoneChecking.value = true;
      }
    });
    //qrCodeFocusNode.requestFocus();

    ref.listen(stockTakeCloseProvider, (prev, next) {
      if (next is StockTakeCloseStateLoading) {
        isLoading.value = true;
      } else if (next is StockTakeCloseStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is StockTakeCloseStateDone) {
        isLoading.value = false;
        // ref.read(stockTakeGetProvider.notifier).getOpenEvent();
        Navigator.of(context).pop();
      }
    });
    VoidCallback cbProcessQrCode = () {
      if (isProcessingQrCode.value == true) {
        // print("is processing qr code");
        return;
      }
      isProcessingQrCode.value = true;
      if (isScanLoading.value) {
        isProcessingQrCode.value = false;
        print("is scan loading ");
        return;
      }
      final paramQrCode = cbPop();
      //submit to backend
      if (paramQrCode.isNotEmpty && stockTakeModel.value?.stockTakeID != null) {
        ref.read(stockTakeMultiScanProvider.notifier).multiScan(
            stockTakeModel.value!.stockTakeID!.toString(),
            paramQrCode,
            selectedStore.value?["id"] ?? "0");
            isAfterScan.value = true;
      } else {
        isProcessingQrCode.value = false;
      }
    };

    cbTail.addListener(() {
      cbProcessQrCode();
    });

    ref.listen(stockTakeCurrentProvider, (prev, next) {
      if (next is StockTakeCurrentStateLoading) {
        isScanLoading.value = true;
      } else if (next is StockTakeCurrentStateError) {
        scanErrorMessage.value = next.message;
        isScanLoading.value = false;
        Timer(const Duration(seconds: 3), () {
          scanErrorMessage.value = "";
        });
      } else if (next is StockTakeCurrentStateDone) {
        isScanLoading.value = false;
        listSummary.value = next.list;
        if (next.list.isNotEmpty) {
          if (isAfterScan.value && !isAfterSave.value) {
            selectedIdx.value = 0;
          }
          final nbf = NumberFormat("##0");
          try {
            ctrlScanQty.text =
                nbf.format(double.parse(next.list[0].scanQty ?? ""));
          } catch (_) {
            ctrlScanQty.text = "";
          }
        } else {
          selectedIdx.value = -1;
          ctrlScanQty.text = "";
        }
        isAfterScan.value = false;
        cbProcessQrCode();
      }
    });

    addToScanErrorList(List<StockTakeMultiScanResponse> list) {
      List<StockTakeMultiScanResponse> curList = List.empty(growable: true);
      curList.addAll(listScanError.value);
      List<StockTakeMultiScanResponse> tmpList = list.where((l) {
        return l.isValid == false;
      }).toList();
      if (tmpList.isNotEmpty) {
        curList.addAll(tmpList);
      }
      listScanError.value = curList;
    }

    ref.listen(stockTakeMultiScanProvider, (prev, next) {
      if (next is StockTakeMultiScanStateLoading) {
        isScanLoading.value = true;
      } else if (next is StockTakeMultiScanStateError) {
        isProcessingQrCode.value = false;
        scanErrorMessage.value = next.message;
        isScanLoading.value = false;
        Timer(const Duration(seconds: 3), () {
          scanErrorMessage.value = "";
          ctrQrCode.clear();
        });
      } else if (next is StockTakeMultiScanStateDone) {
        isScanLoading.value = false;
        isProcessingQrCode.value = false;
        addToScanErrorList(next.list);
        // ref.read(stockTakeCurrentProvider.notifier).currentSummary(
        //     stockTakeID: stockTakeModel.value?.stockTakeID ?? "0");
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Stock Take",
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: FxTextField(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    ctrl: ctrQrCode,
                    focusNode: qrCodeFocusNode,
                    hintText: "Scan Barcode",
                    labelText: "Scan Barcode",
                    onSubmitted: (qrCode) {
                      cbPush(ctrQrCode.text);
                      ctrQrCode.clear();
                      qrCodeFocusNode.requestFocus();
                    },
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Image.asset("images/icon_scan_barcode.png",
                          height: 48),
                    ),
                    width: double.infinity,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: FxStoreLk(
                    labelText: "Store",
                    hintText: "Store",
                    withAll: true,
                    readOnly: storeIsReadOnly.value,
                    onChanged: (value) {
                      selectedStore.value = {
                        "id": value.storeID,
                        "name": value.storeName,
                      };
                    },
                  ),
                ),
              ],
            ),
          ),
          const _TabButton(
            isWeb: true,
            isCamera: false,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Center(
                child: ResponsiveBuilder(
                  builder: (context, sizeInfo) {
                    double screenWidth = MediaQuery.of(context).size.width;
                    return SizedBox(
                      width: screenWidth,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          // const SizedBox(height: 10),
                          // FxTextField(
                          //   ctrl: ctrQrCode,
                          //   focusNode: qrCodeFocusNode,
                          //   hintText: "Scan Barcode",
                          //   labelText: "Scan Barcode",
                          //   /* obscuredText: false, */
                          //   /* autofocus: false, */
                          //   onSubmitted: (qrCode) {
                          //     cbPush(ctrQrCode.text);
                          //     ctrQrCode.clear();
                          //     qrCodeFocusNode.requestFocus();
                          //   },
                          //   suffix: Padding(
                          //     padding: const EdgeInsets.only(right: 10.0),
                          //     child: Image.asset("images/icon_scan_barcode.png",
                          //         height: 48),
                          //   ),
                          //   width: double.infinity,
                          // ),
                          // const SizedBox(
                          //   height: 20,
                          // ),
                          if (multiScanErrorMessage.value != "")
                            _ScanInfoWidget(
                              errorMessage: multiScanErrorMessage.value,
                            ),
                          if (scanResponse.value != null ||
                              scanErrorMessage.value != "")
                            _ScanInfoWidget(
                              info: scanResponse.value,
                              errorMessage: scanErrorMessage.value,
                            ),
                          _ListItemHeader(listSummary: listSummary),
                          const Divider(
                            color: Constants.greenDark,
                          ),
                          Expanded(
                            child: _ListItemSummary(
                              listSummary: listSummary,
                              model: stockTakeModel.value,
                            ),
                          ),
                          if (listSummary.value.isNotEmpty &&
                              selectedIdx.value > -1)
                            SizedBox(height: 10),
                          if (listSummary.value.isNotEmpty &&
                              selectedIdx.value > -1)
                            FxMaterialStockTake(
                                model: listSummary.value[selectedIdx.value],
                                ctrlEdit: ctrlScanQty,
                                index: selectedIdx.value,
                                onSave: (model, str, bln, str2) {
                                  selectedIdx.value = -1;
                                  isAfterSave.value = true;
                                }),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                  child: SizedBox(
                                width: 20,
                              )),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: _StokeTakeButton(
                                  title: "End Stock Take",
                                  color: Constants.greenDark,
                                  press: (stockTakeModel.value?.stockTakeID ==
                                          null)
                                      ? null
                                      : () {
                                          ref
                                              .read(stockTakeCloseProvider
                                                  .notifier)
                                              .close(stockTakeModel
                                                  .value!.stockTakeID!);
                                        },
                                  maxWidth: 200,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItemHeader extends StatelessWidget {
  const _ListItemHeader({
    super.key,
    required this.listSummary,
  });

  final ValueNotifier<List<GroupSummaryModelV2>> listSummary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "Item (${listSummary.value.length})",
            style: const TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const Expanded(
          flex: 2,
          child: Text(
            "Mat Code",
            style: TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const SizedBox(
          width: 50,
          child: Text(
            "Scan Qty",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        // const SizedBox(
        //   width: 50,
        //   child: Text(
        //     "Book Count",
        //     textAlign: TextAlign.right,
        //     style: TextStyle(
        //       fontSize: Constants.fontMediumSize,
        //       color: Constants.greenDark,
        //     ),
        //   ),
        // ),
        // const SizedBox(
        //   width: 10,
        // ),
        // const SizedBox(
        //   width: 50,
        //   child: Text(
        //     "Tot Count",
        //     textAlign: TextAlign.right,
        //     style: TextStyle(
        //       fontSize: Constants.fontMediumSize,
        //       color: Constants.greenDark,
        //     ),
        //   ),
        // ),
        // SizedBox(
        //   width: 10,
        // ),
        const SizedBox(
          width: 50,
          child: Text(
            "Store Qty",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const SizedBox(
          width: 50,
          child: Text(
            "Diff",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const Expanded(
          child: Text(
            "Adjustment",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanInfoWidget extends StatelessWidget {
  final StockTakeScanResponse? info;
  final String errorMessage;
  const _ScanInfoWidget({
    Key? key,
    this.info,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool haveInfo = info != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Constants.greenDark),
        color: Colors.grey[100],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (errorMessage == "" && haveInfo)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  info!.isValid
                      ? Image.asset(
                          "images/ok.png",
                          height: 32,
                          width: 32,
                        )
                      : Image.asset(
                          "images/warning.png",
                          height: 32,
                          width: 32,
                        ),
                  const SizedBox(
                    width: 20,
                  ),
                  Center(
                    child: Text(
                      info!.message,
                      style: TextStyle(
                        color:
                            info!.isValid ? Constants.greenDark : Constants.red,
                        fontSize: Constants.fontMediumSize,
                      ),
                    ),
                  ),
                ],
              ),
            if (errorMessage != "")
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/warning.png",
                    height: 32,
                    width: 32,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Constants.red,
                      fontSize: Constants.fontMediumSize,
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 10,
            ),
            if (haveInfo)
              Text(
                "Name : ${info!.info.itemName ?? " Item not found"}",
                style: const TextStyle(
                  color: Constants.greenDark,
                  fontSize: Constants.fontMediumSize,
                ),
              ),
            const SizedBox(
              height: 5,
            ),
            if (haveInfo)
              Text(
                "Serial No. : ${info!.info.checkinAddOnSerialNo ?? "-"}",
                style: const TextStyle(
                  color: Constants.greenDark,
                  fontSize: Constants.fontMediumSize,
                ),
              ),
            const SizedBox(
              height: 5,
            ),
            if (haveInfo)
              Text(
                "QR Code. : ${info!.info.checkinInternalCode ?? "-"}",
                style: const TextStyle(
                  color: Constants.greenDark,
                  fontSize: Constants.fontMediumSize,
                ),
              ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}

/* class _StokeEventWidget extends HookWidget { */
/*   final bool isLoading; */
/*   final String errorMessage; */
/*   final StockTakeModel? event; */
/*   final bool isDoneChecking; */
/*   const _StokeEventWidget({ */
/*     Key? key, */
/*     required this.isLoading, */
/*     required this.errorMessage, */
/*     this.event, */
/*     required this.isDoneChecking, */
/*   }) : super(key: key); */

/*   @override */
/*   Widget build(BuildContext context) { */
/*     bool haveEvent = false; */
/*     String eventName = ""; */
/*     String eventDate = ""; */
/*     if (event != null) { */
/*       haveEvent = true; */
/*       final sdf = DateFormat("d MMM y h:m a"); */
/*       final xSdf = DateFormat("y-M-d H:m:s"); */
/*       String userName = "user"; */
/*       if (event?.userName != null) userName = event!.userName!; */
/*       String sdate = ""; */
/*       if (event?.stockTakeDate != null) { */
/*         sdate = " on " + sdf.format(xSdf.parse(event!.stockTakeDate!)); */
/*       } */
/*       eventName = "Stock Take created by $userName"; */
/*       eventDate = sdate; */
/*     } */
/*     return Container( */
/*       width: double.infinity, */
/*       decoration: BoxDecoration( */
/*         borderRadius: const BorderRadius.all(Radius.circular(10)), */
/*         border: Border.all(color: Constants.greenDark), */
/*         color: Constants.greenLight, */
/*       ), */
/*       child: Padding( */
/*         padding: const EdgeInsets.all(10.0), */
/*         child: Column( */
/*           mainAxisSize: MainAxisSize.max, */
/*           children: [ */
/*             if (isLoading) */
/*               const Center( */
/*                   child: SizedBox( */
/*                 width: 32, */
/*                 height: 32, */
/*                 child: CircularProgressIndicator(), */
/*               )), */
/*             if (errorMessage != "") */
/*               Text( */
/*                 errorMessage, */
/*                 style: const TextStyle( */
/*                   color: Constants.red, */
/*                   fontSize: Constants.fontMediumSize, */
/*                 ), */
/*               ), */
/*             if (haveEvent) */
/*               Text( */
/*                 eventName, */
/*                 style: const TextStyle( */
/*                   color: Constants.greenDark, */
/*                   fontSize: Constants.fontMediumSize, */
/*                 ), */
/*               ), */
/*             if (haveEvent) */
/*               Text( */
/*                 eventDate, */
/*                 style: const TextStyle( */
/*                   color: Constants.greenDark, */
/*                   fontSize: Constants.fontMediumSize, */
/*                 ), */
/*               ), */
/*             if ((!isLoading) && */
/*                 (errorMessage == "") && */
/*                 (!haveEvent) && */
/*                 (isDoneChecking)) */
/*               _StokeTakeButton( */
/*                 title: "New Stock Take", */
/*                 press: () { */
/*                   context.read(stockTakeProvider.notifier).create(); */
/*                 }, */
/*               ) */
/*           ], */
/*         ), */
/*       ), */
/*     ); */
/*   } */
/* } */

class _StokeTakeButton extends StatelessWidget {
  final VoidCallback? press;
  final String title;
  final Color color;
  final double maxWidth;
  final IconData icon;
  const _StokeTakeButton(
      {Key? key,
      required this.press,
      this.title = 'Scan',
      this.color = Colors.orange,
      this.icon = Icons.picture_as_pdf_sharp,
      this.maxWidth = 200.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      height: 40,
      child: OutlinedButton(
          style: ButtonStyle(
            alignment: Alignment.center,
            backgroundColor: MaterialStateColor.resolveWith(
              (states) {
                Color resultColor = color;
                for (var element in states) {
                  if (element == MaterialState.disabled) {
                    resultColor = Colors.grey.shade400;
                  }
                }
                return resultColor;
              },
            ),
          ),
          onPressed: press,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          )),
    );
  }
}

class _TextField extends StatelessWidget {
  final String hintText;
  final bool obscuredText;
  final TextEditingController control;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final double width;

  const _TextField(
      {Key? key,
      required this.hintText,
      required this.obscuredText,
      required this.control,
      this.focusNode,
      this.onSubmitted,
      this.autofocus = false,
      this.width = 400,
      this.textInputAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = width;
    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        Size(maxWidth, 200),
      ),
      child: TextField(
        controller: control,
        textAlign: TextAlign.center,
        onSubmitted: onSubmitted,
        focusNode: focusNode,
        autofocus: autofocus,
        textInputAction: textInputAction,
        style: const TextStyle(
          color: Constants.greenDark,
          fontSize: 20,
        ),
        obscureText: obscuredText,
        decoration: InputDecoration(
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Image.asset(
              "images/scanner.png",
              height: 24 - (0.15 * 24),
            ),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Constants.greenDark.withOpacity(0.6),
            fontSize: 20,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: Constants.greenDark,
              width: 2.0,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              color: Constants.orange,
              width: 2.0,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              color: Constants.greenDark,
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends HookWidget {
  final bool isCamera;
  final bool isWeb;
  const _TabButton({
    this.isCamera = false,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);
    return Container(
      color: Colors.grey.shade300,
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: isWeb
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isWeb
                          ? Colors.grey.shade300
                          : isCamera
                              ? Colors.white
                              : Constants.greenLight,
                      borderRadius: isCamera
                          ? null
                          : const BorderRadius.only(
                              /* bottomRight: Radius.circular(10), */
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                    ),
                    child: Center(
                      child: Text(
                        "List by serial no",
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              isWeb ? Constants.greyDark : Constants.greenDark,
                          fontWeight:
                              isCamera ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 0.4,
                    width: double.infinity,
                    color: Constants.greenDark,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCamera ? Constants.greenLight : Colors.white,
                      border: Border.all(color: Constants.greenDark),
                      borderRadius: isWeb
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            )
                          : null,
                    ),
                    child: InkWell(
                      onTap: isLoading.value
                          ? null
                          : () {
                              // context.read(privateIsbnProvider.notifier).getNo();
                            },
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              "List by material code",
                              style: TextStyle(
                                fontSize: 16,
                                color: Constants.greenDark,
                                fontWeight: isCamera
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            if (isLoading.value)
                              const Positioned(
                                right: 20,
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Container(
                    height: 10,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ListItemSummary extends HookConsumerWidget {
  const _ListItemSummary({
    Key? key,
    required this.listSummary,
    required this.model,
  }) : super(key: key);

  final ValueNotifier<List<GroupSummaryModelV2>> listSummary;
  final StockTakeModel? model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listDropDownIndex = useState(-1);
    return ListView.builder(
      itemCount: listSummary.value.length,
      itemBuilder: (context, idx) {
        final item = listSummary.value[idx];
        Color color = Constants.greenLight.withOpacity(0.2);
        if (idx % 2 == 0) {
          color = Colors.white;
        }
        if (idx == 0) {
          color = Constants.firstYellow;
        }
        Color textColor = Colors.black;

        double storeQty = double.parse(item.storeQty ?? "0");
        double bookCount = double.parse(item.bookCount ?? "0");
        double totCount = double.parse(item.totCount ?? "0");
        double scannedQty = double.parse(item.scanQty ?? "0");
        double diffQty = scannedQty - storeQty;
        final nbf = NumberFormat("##0");
        return Container(
          color: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.itemName ?? " --- ",
                        style: TextStyle(
                          color: textColor,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.itemCode ?? "",
                        style: TextStyle(
                          color: textColor,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        nbf.format(scannedQty),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: textColor,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    // SizedBox(
                    //   width: 50,
                    //   child: Text(
                    //     nbf.format(bookCount),
                    //     textAlign: TextAlign.right,
                    //     style: TextStyle(
                    //       color: textColor,
                    //       fontSize: Constants.fontMediumSize,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    // SizedBox(
                    //   width: 50,
                    //   child: Text(
                    //     nbf.format(totCount),
                    //     textAlign: TextAlign.right,
                    //     style: TextStyle(
                    //       color: textColor,
                    //       fontSize: Constants.fontMediumSize,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        nbf.format(storeQty),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: textColor,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        nbf.format(diffQty),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: textColor,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        "",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Constants.red,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension on String {
  String formatDate() {
    if (this == "") return "";
    final mydf = DateFormat("yyyy-MM-dd HH:mm:ss");
    final sdf = DateFormat("ddMMMyyy");
    try {
      return " (${sdf.format(mydf.parse(this))})";
    } catch (_) {
      return "";
    }
  }
}

class _ReportButton extends StatelessWidget {
  final VoidCallback? press;
  final String title;
  final Color color;
  final double maxWidth;
  const _ReportButton(
      {Key? key,
      required this.press,
      this.title = 'Print Report',
      this.color = Colors.orange,
      this.maxWidth = 200.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(maxWidth, 200)),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
            style: ButtonStyle(
              alignment: Alignment.center,
              backgroundColor: MaterialStateColor.resolveWith(
                (states) {
                  Color resultColor = color;
                  for (var element in states) {
                    if (element == MaterialState.disabled) {
                      resultColor = Colors.grey.shade400;
                    }
                  }
                  return resultColor;
                },
              ),
            ),
            onPressed: press,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            )),
      ),
    );
  }
}
