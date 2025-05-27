import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:sor_inventory/model/contractor_lookup_model.dart';
import 'package:sor_inventory/model/material_return_scan_response.dart';
import 'package:sor_inventory/screen/mr_manual/mr_material_lookup.dart';
import 'package:sor_inventory/widgets/fx_button.dart';
import 'package:sor_inventory/widgets/fx_contractor_lk.dart';
import 'package:sor_inventory/widgets/fx_gray_dark_text.dart';
import 'package:sor_inventory/widgets/fx_text_field.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_material_return_scan_info_v3.dart';
import '../login/login_provider.dart';
import 'dart:html' as html;

import '../mr_auto/mr_set_done_provider.dart';

class MrManualScreen extends HookConsumerWidget {
  final String mrSlipNo;
  const MrManualScreen({this.mrSlipNo = "", Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final selectedStore = useState<Map<String, dynamic>?>(null);

    final confirmDone = useState(false);
    final isDone = useState(true);
    final allowChangeSo = useState(true);

    final slipNo = useState<String>("");
    final ctrlSearch = useTextEditingController(text: "");
    final selectedSo = useState<ContractorLookupModel?>(null);

    final editedIndex = useState<int?>(null);

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

    // fcBarcode.requestFocus();

    final listMaterial =
        useState<List<MaterialReturnScanResponseModelV2>>(List.empty());
    final isLoading = useState(false);
    final errorMessage = useState("");

    ref.listen(mrMrMaterialLookupStateProvider, (prev, next) {
      if (next is MrMaterialLookupStateLoading) {
        isLoading.value = true;
      } else if (next is MrMaterialLookupStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is MrMaterialLookupStateDone) {
        isLoading.value = false;
        listMaterial.value = next.model.list;
      }
    });

    // ref.listen(saveMaterialReturnStateProvider, (prev, next) {
    //   if (next is SaveMaterialReturnStateLoading) {
    //     isLoading.value = true;
    //   } else if (next is SaveMaterialReturnStateError) {
    //     isLoading.value = false;
    //     errorMessage.value = next.message;
    //     Timer(const Duration(seconds: 3), () {
    //       errorMessage.value = "";
    //     });
    //   } else if (next is SaveMaterialReturnStateDone) {
    //     isLoading.value = false;
    //     slipNo.value = next.slipNo;
    //   }
    // });

    ref.listen(mrSetDoneStateProvider, (previous, next) {
      if (next is MrSetDoneStateDone) {
        if (next.status == "Y") {
          confirmDone.value = true;
        } else {
          confirmDone.value = false;
          isDone.value = false;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Material Return (Manual)",
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
                FxContractorLk(
                  width: 250,
                  hintText: "Select SO",
                  labelText: "SO",
                  readOnly: !allowChangeSo.value,
                  onChanged: (model) {
                    selectedSo.value = model;
                    slipNo.value = "";
                    ref.read(mrMrMaterialLookupStateProvider.notifier).lookup(
                          soID: model.staffId,
                          cpID: model.cpId,
                          dbName: model.dbName,
                          search: ctrlSearch.text,
                          slipNo: slipNo.value,
                        );
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: FxTextField(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 19,
                      horizontal: 10,
                    ),
                    ctrl: ctrlSearch,
                    hintText: "Search Code/Description",
                    labelText: "Code Description",
                    onChanged: (val) {
                      if (selectedSo.value == null) {
                        return;
                      }
                      ref.read(mrMrMaterialLookupStateProvider.notifier).lookup(
                            soID: selectedSo.value!.staffId,
                            cpID: selectedSo.value!.cpId,
                            dbName: selectedSo.value!.dbName,
                            search: ctrlSearch.text,
                            slipNo: slipNo.value,
                          );
                    },
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            if (isLoading.value)
              const SizedBox(width: 20, child: CircularProgressIndicator()),
            if (errorMessage.value != "")
              FxGrayDarkText(
                title: errorMessage.value,
                color: Constants.red,
              ),
            if (listMaterial.value.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: listMaterial.value.length,
                  itemBuilder: (context, idx) {
                    var mat = listMaterial.value[idx];
                    return FxMaterialReturnScanInfoV3(
                      isManual: true,
                      isFirst: editedIndex.value == idx,
                      model: mat,
                      confirmDone: confirmDone.value,
                      packsizeChange: (packSize, retSlipNo) {
                        slipNo.value = retSlipNo;
                        editedIndex.value = null;
                        if (selectedSo.value == null) {
                          return;
                        }
                        ref
                            .read(mrMrMaterialLookupStateProvider.notifier)
                            .lookup(
                              dbName: selectedSo.value!.dbName,
                              search: ctrlSearch.text,
                              soID: selectedSo.value!.staffId,
                              cpID: selectedSo.value!.cpId,
                              slipNo: retSlipNo,
                            );
                      },
                      inEditMode: idx == editedIndex.value,
                      requestEdit: (idx) {
                        editedIndex.value = idx;
                      },
                      onEditChange: (val, idx) {},
                      cancelEdit: (idx, packQty) {
                        isDone.value = true;
                      },
                      index: idx,
                      initSlipNo: slipNo.value,
                    );
                  },
                ),
              ),
            if (listMaterial.value.isEmpty)
              const Expanded(
                  child: SizedBox(
                height: 20,
              )),
            Row(children: [
              confirmDone.value
                  ? Expanded(
                      child: FxButton(
                        title: "Edit",
                        onPress: slipNo.value == "" || !isDone.value
                            ? null
                            : () {
                                ref
                                    .read(mrSetDoneStateProvider.notifier)
                                    .setDone(slipNo: slipNo.value, status: "N");
                              },
                      ),
                    )
                  : Expanded(
                      child: FxButton(
                        color: Constants.greenDark,
                        title: "Done",
                        onPress: slipNo.value == ""
                            ? null
                            : () {
                                allowChangeSo.value = true;
                                ref
                                    .read(mrSetDoneStateProvider.notifier)
                                    .setDone(slipNo: slipNo.value, status: "Y");
                              },
                      ),
                    ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: confirmDone.value
                    ? FxButton(
                        title: "Print Return Slip",
                        color: Constants.greenDark,
                        onPress: !confirmDone.value
                            ? null
                            : (() async {
                                final snow =
                                    "&t=${DateTime.now().toIso8601String()}";
                                final url =
                                    "https://${Constants.host}/reports/material_return.php?no=${base64Encode(utf8.encode(slipNo.value))}" +
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
                                        options: Options(
                                            responseType: ResponseType.bytes),
                                      );
                                      return response.data;
                                    },
                                  );
                                } catch (e) {
                                  errorMessage.value =
                                      "Error printing document";
                                  Timer(const Duration(seconds: 3), () {
                                    errorMessage.value = "";
                                  });
                                }
                              }),
                      )
                    : SizedBox(width: 20),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
