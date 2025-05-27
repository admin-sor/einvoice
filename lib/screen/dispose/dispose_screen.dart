import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:sor_inventory/model/scrap_model.dart';
import 'package:sor_inventory/screen/dispose/dispose_byno_provider.dart';
import 'package:sor_inventory/screen/dispose/dispose_delete_provider.dart';
import 'package:sor_inventory/screen/dispose/dispose_save_provider.dart';
import 'package:sor_inventory/screen/dispose/dispose_store_provider.dart';
import 'package:sor_inventory/screen/dispose/req_reload_dispose_material.dart';
import 'package:sor_inventory/screen/mr_auto/selected_mr_cp_provider.dart';
import 'package:sor_inventory/widgets/fx_button.dart';
import 'package:sor_inventory/widgets/fx_disposable_material_lk.dart';
import 'package:sor_inventory/widgets/fx_scrap_info.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_store_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'dart:html' as html;

class DisposeScreen extends HookConsumerWidget {
  final String slipNo;
  const DisposeScreen({this.slipNo = "", Key? key}) : super(key: key);

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

    final isLoading = useState(false);
    final errorMessage = useState("");
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listScrapModel = useState<List<ScrapModel>>(List.empty());
    final ctrlSlipNo = useTextEditingController(text: slipNo);
    final isDone = useState(slipNo != "");
    final ctrlStoreReadOnly = useTextEditingController(text: "");
    final isLastItem = useState(false);

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
      ref.read(selectedEditIndex.notifier).state = 0;
      if (slipNo != "") {
        Timer(Duration(milliseconds: 300), () {
          ref.read(disposeByNoStateProvider.notifier).byNo(slipNo: slipNo);
        });
      }
      return () {};
    }, [slipNo]);

    final errorMessageEdit = useState("");

    ref.listen(disposeByNoStateProvider, (prev, next) {
      if (next is DisposeByNoStateLoading) {
        isLoading.value = true;
      } else if (next is DisposeByNoStateError) {
        if (!isLastItem.value || !next.message.contains("not found")) {
          errorMessage.value = next.message;
        }
        isLoading.value = false;
        Timer(Duration(milliseconds: 30000), () {
          errorMessage.value = "";
        });
        listScrapModel.value = List.empty();
        ref.read(disposeSelectedStoreProvider.notifier).state =
            selectedStore.value ?? {"id": "0", "name": ""};
        if (isLastItem.value) {
          print("last item pop");
          Navigator.of(context).pop();
        }
      } else if (next is DisposeByNoStateDone) {
        isLoading.value = false;
        listScrapModel.value = next.list;
        if (listScrapModel.value.length == 1) {
          print("last item");
          isLastItem.value = true;
        } else {
          isLastItem.value = false;
        }
        if (next.list.isNotEmpty) {
          ctrlSlipNo.text = next.list[0].scrapDisposeSlipNo ?? "";
          ctrlStoreReadOnly.text =
              ref.read(disposeSelectedStoreProvider)["name"];
        } else {
          ctrlSlipNo.text = slipNo;
        }
        // ref.read(disposeSelectedStoreProvider.notifier).state =
        // selectedStore.value?["id"] ?? "0";
      }
    });
    // fcBarcode.requestFocus();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Material Disposal",
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
            if (!isDone.value && listScrapModel.value.isNotEmpty) {
              //return;
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
            slipNo == ""
                ? Row(
                    children: [
                      Expanded(
                        child: FxStoreLk(
                          labelText: "Store",
                          hintText: "Select Store",
                          readOnly:
                              slipNo != "" || listScrapModel.value.isNotEmpty,
                          onChanged: (model) {
                            selectedStore.value = {
                              "id": model.storeID,
                              "name": model.storeName
                            };
                            if (model != null) {
                              ref
                                  .read(disposeSelectedStoreProvider.notifier)
                                  .state = {
                                "id": model.storeID,
                                "name": model.storeName,
                              };
                            }
                          },
                        ),
                      )
                    ],
                  )
                : Row(
                    children: [
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
            FxDisposableMaterialLk(
              enabled: true, //lstScrapModel.value.isEmpty || isDone.value,
              width: kIsWeb ? Constants.webWidth : double.infinity,
              labelText: "Scrap Material",
              hintText: "Select Material",
              storeID: selectedStore.value?["id"] ?? "0",
              onBarcodeChoose: (model) {
                if (model.scrapBarcode == "") return;

                if (model.scrapID == null) return;
                ref
                    .read(disposeSaveStateProvider.notifier)
                    .save(scrapID: model.scrapID!, slipNo: ctrlSlipNo.text);
                Navigator.of(context).popUntil((route) {
                  if (route is MaterialPageRoute) {
                    return true;
                  }
                  return false;
                });
              },
            ),
            const SizedBox(height: 10),
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
            if (listScrapModel.value.isNotEmpty) const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                  itemCount: listScrapModel.value.length,
                  itemBuilder: (context, idx) {
                    final m = listScrapModel.value[idx];

                    return FxScrapInfo(
                      requestEdit: (idx) {
                        isDone.value = false;
                      },
                      onDelete: (model) {
                        if (listScrapModel.value.length == 1) {
                          // last item
                          var confirmDlg = AlertDialog(
                            title: Text("Delete Confirmation"),
                            content: Text(
                                "Do you want to delete the scrap material & material disposal slip ?"),
                            actions: [
                              FxButton(
                                title: "Cancel",
                                color: Constants.greenDark,
                                onPress: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FxButton(
                                title: "Delete",
                                color: Constants.red,
                                onPress: () {
                                  ref
                                      .read(disposeDeleteStateProvider.notifier)
                                      .delete(
                                          scrapID: model.scrapID ?? "0",
                                          slipNo: ctrlSlipNo.text);
                                  ref
                                      .read(
                                          disposeSelectedStoreProvider.notifier)
                                      .state = {"id": "0", "name": ""};
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                          showDialog(
                              context: context,
                              builder: (context) {
                                return confirmDlg;
                              });
                        } else {
                          ref.read(disposeDeleteStateProvider.notifier).delete(
                              scrapID: model.scrapID ?? "0",
                              slipNo: ctrlSlipNo.text);
                        }
                      },
                      onCancel: (model) {
                        errorMessageEdit.value = "";
                      },
                      doSave: (idx) {},
                      errorEditMessage: errorMessageEdit.value,
                      resetIsDone: () {
                        isDone.value = true;
                      },
                      index: idx,
                      inEditMode: !isDone.value,
                      model: m,
                      isFirst: idx == 0,
                    );
                  }),
            ),
            Row(children: [
              Expanded(
                child: SizedBox(width: 20),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: FxButton(
                  title: isWebMobile
                      ? "Print Disposal Slip"
                      : "Print Material Disposal Slip",
                  color: Constants.greenDark,
                  onPress: listScrapModel.value.isEmpty
                      ? null
                      : (() async {
                          final snow = "&t=${DateTime.now().toIso8601String()}";
                          final url =
                              "https://${Constants.host}/reports/material_disposal.php?no=${base64Encode(utf8.encode(ctrlSlipNo.text.trim()))}" +
                                  snow;

                          if (kIsWeb) {
                            html.window.open(url, "rpttab");
                            return;
                          }
                          try {
                            await Printing.layoutPdf(
                              name: "Material Disposal",
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
          ],
        ),
      ),
    );
  }
}
