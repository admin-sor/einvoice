import 'dart:async';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/material_stock_model.dart';
import 'package:sor_inventory/screen/material_md/material_md_save_provider.dart';
import 'package:sor_inventory/screen/material_md/material_md_stock_provider.dart';
import 'package:sor_inventory/widgets/fx_auto_completion_pack_unitv2.dart';
import 'package:sor_inventory/widgets/fx_auto_completion_unit.dart';
import 'package:sor_inventory/widgets/fx_green_dark_text.dart';
import 'package:sor_inventory/widgets/fx_store_lk.dart';
import 'package:sor_inventory/widgets/fx_unit_lk.dart';

import 'package:printing/printing.dart';
import 'dart:html' as html;
import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/materialmd_model.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_gray_dark_text.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'material_md_delete_provider.dart';
import 'material_md_edit_price_provider.dart';

final mdStoreIDProvider = StateProvider<String>((ref) => "0");

class MaterialMdEditScreen extends HookConsumerWidget {
  final MaterialMdModel materialMd;
  final String query;
  const MaterialMdEditScreen({
    Key? key,
    required this.materialMd,
    required this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final errorMessage = useState("");
    final isLoading = useState(false);
    final inEditMode = useState(false);
    final selectedStore = useState<Map<String, dynamic>?>(null);
    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
      }
      if (loginModel.value?.storeID != null) {
        selectedStore.value = {
          "id": loginModel.value!.storeID,
          "name": "User Store"
        };
        ref.read(mdStoreIDProvider.notifier).state = loginModel.value!.storeID;
      }
    });
    //no login

    if (loginModel.value == null) {
      if (isInit.value) {
        isInit.value = false;
        Timer(const Duration(milliseconds: 499), () {
          if (loginModel.value == null)
            ref.read(loginStateProvider.notifier).checkLocalToken();
          ref.read(materialStockSearchProvider.notifier).search(
              materialID: materialMd.materialId,
              storeID: selectedStore.value?["id"] ?? "0");
        });
      } else {
        Timer(const Duration(milliseconds: 500), () {
          isInit.value = true;
          if (loginModel.value == null) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (args) => false);
          }
        });
      }
      return Scaffold(
        body: Container(
          color: Colors.white,
        ),
      );
    }
    final ctrlCode = useTextEditingController(text: materialMd.materialCode);
    final ctrlDescription =
        useTextEditingController(text: materialMd.description);
    final ctrlPackSize = useTextEditingController(text: materialMd.packQty);
    final ctrlUnit = useTextEditingController(text: materialMd.uom);
    final selectedUnit = useState<UnitModel>(UnitModel(
      unit: materialMd.uom,
      unitDesc: materialMd.uom,
      unitId: materialMd.unitId,
    ));
    final ctrlPackUnit = useTextEditingController(text: materialMd.packUnit);
    final selectedPackUnit = useState<UnitModel>(UnitModel(
      unit: materialMd.packUnit,
      unitDesc: materialMd.packUnit,
      unitId: materialMd.packUnitId,
    ));

    final isCable = useState<bool>(materialMd.isCable == "Y");
    final errorMessageMaterial = useState("");
    ref.listen(materialMdSaveProvider, (prev, next) {
      if (next is MaterialMdSaveStateLoading) {
        isLoading.value = true;
      } else if (next is MaterialMdSaveStateError) {
        if (next.message.contains("Duplicat")) {
          errorMessageMaterial.value = next.message;
          Timer(const Duration(seconds: 3), () {
            errorMessageMaterial.value = "";
          });
        } else {
          errorMessage.value = next.message;
          Timer(const Duration(seconds: 3), () {
            errorMessage.value = "";
          });
        }
        isLoading.value = false;
      } else if (next is MaterialMdSaveStateDone) {
        isLoading.value = false;
        Navigator.of(context).pop();
      }
    });

    ref.listen(materialMdDeleteProvider, (prev, next) {
      if (next is MaterialMdDeleteStateLoading) {
        isLoading.value = true;
      } else if (next is MaterialMdDeleteStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
      } else if (next is MaterialMdDeleteStateDone) {
        isLoading.value = false;
        Navigator.of(context).pop();
      }
    });
    final fcUnit = FocusNode();
    final fcPackUnit = FocusNode();
    final isStockShow = useState(false);

    final listStock = useState<List<MaterialStockModel>>(List.empty());
    final totalStock = useState("");
    final stockError = useState("");
    final stockIsLoading = useState(false);
    ref.listen(materialStockSearchProvider, (prev, next) {
      if (next is MaterialStockSearchStateLoading) {
        stockIsLoading.value = true;
      } else if (next is MaterialStockSearchStateError) {
        stockIsLoading.value = false;
        stockError.value = next.message;
        Timer(const Duration(seconds: 3), () {
          stockError.value = "";
        });
      } else if (next is MaterialStockSearchStateDone) {
        stockIsLoading.value = false;
        listStock.value = next.model;
        if (next.model.isEmpty) {
          totalStock.value = "0";
        } else {
          var itotal = 0;

          final nbf = NumberFormat("###,##0", "en_US");
          for (MaterialStockModel m in next.model) {
            itotal += nbf.parse(m.packsizeCurrent ?? "0").toInt();
          }
          totalStock.value = nbf.format(itotal);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          materialMd.materialId == "0" ? "New Material" : "Edit Material",
          style: const TextStyle(
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
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxTextField(
                    enabled:
                        !(!inEditMode.value && materialMd.materialId != "0"),
                    readOnly: !inEditMode.value && materialMd.materialId != "0",
                    ctrl: ctrlCode,
                    width: 110,
                    maxLength: 10,
                    labelText: "Code",
                    hintText: "Code",
                    errorMessage: errorMessageMaterial.value,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: (errorMessageMaterial.value != "") ? 20.0 : 0.0,
                      ),
                      child: FxTextField(
                        enabled: !(!inEditMode.value &&
                            materialMd.materialId != "0"),
                        readOnly:
                            !inEditMode.value && materialMd.materialId != "0",
                        labelText: "Description",
                        hintText: "Description",
                        ctrl: ctrlDescription,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  FxUnitLk(
                    isPackUnit: true,
                    width: 110,
                    readOnly: !inEditMode.value && materialMd.materialId != "0",
                    labelLength: 60,
                    labelText: "Pack Unit",
                    hintText: "Pack Unit",
                    initialValue: UnitModel(
                      unit: materialMd.packUnit,
                      unitDesc: "",
                      unitId: materialMd.packUnitId,
                    ),
                    onChanged: (v) {
                      selectedPackUnit.value = v;
                    },
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: FxTextField(
                          textAlign: TextAlign.right,
                          ctrl: ctrlPackSize,
                          width: 100,
                          enabled: !(!inEditMode.value &&
                              materialMd.materialId != "0"),
                          readOnly:
                              !inEditMode.value && materialMd.materialId != "0",
                          labelText: "Pack Size",
                          hintText: "Pack Size"),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: FxUnitLk(
                      isPackUnit: true,
                      labelLength: 50,
                      width: 110,
                      readOnly:
                          !inEditMode.value && materialMd.materialId != "0",
                      labelText: "UOM",
                      hintText: "UOM",
                      initialValue: UnitModel(
                        unit: materialMd.uom,
                        unitDesc: "",
                        unitId: materialMd.unitId,
                      ),
                      onChanged: (v) {
                        selectedUnit.value = v;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              if (!inEditMode.value && materialMd.materialId != "0")
                Row(
                  children: [
                    Expanded(
                      child: FxButton(
                        color: Constants.red,
                        title: "Delete",
                        onPress: () async {
                          if (await confirm(
                            context,
                            title: FxBlackText(
                                title:
                                    "Delete Material ${materialMd.materialCode}"),
                            content: FxBlackText(title: materialMd.description),
                          )) {
                            ref.read(materialMdDeleteProvider.notifier).delete(
                                  materialId: materialMd.materialId,
                                  query: query,
                                );
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: FxButton(
                        maxWidth: MediaQuery.of(context).size.width,
                        color: Constants.greenDark,
                        title: "Edit",
                        onPress: () {
                          inEditMode.value = !inEditMode.value;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: FxButton(
                        title: isStockShow.value ? "Hide stock" : "Show stock",
                        onPress: () {
                          if (isStockShow.value) {
                          } else {}
                          isStockShow.value = !isStockShow.value;
                        },
                      ),
                    ),
                  ],
                ),
              // const Spacer(),
              // SizedBox(height: 15),
              if (errorMessage.value != "")
                FxGrayDarkText(
                  color: Constants.red,
                  title: errorMessage.value,
                ),
              if (inEditMode.value || materialMd.materialId == "0")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: FxButton(
                        title: "Cancel",
                        color: Constants.red,
                        onPress: () {
                          inEditMode.value = false;
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: FxButton(
                        title: "Save",
                        color: Constants.greenDark,
                        isLoading: isLoading.value,
                        onPress: () {
                          if (ctrlCode.text == "") {
                            errorMessage.value = "Material Code is mandatory";
                            return;
                          }
                          if (ctrlDescription.text == "") {
                            errorMessage.value =
                                "Material Description is mandatory";
                            return;
                          }
                          if (selectedUnit.value.unitId == 0) {
                            errorMessage.value = "Unit is mandatory";
                            return;
                          }
                          if (selectedPackUnit.value.unitId == 0) {
                            errorMessage.value = "Pack Size is mandatory";
                            return;
                          }
                          if (ctrlPackSize.text == "") {
                            errorMessage.value = "Pack Size is mandatory";
                            return;
                          }
                          ref.read(materialMdSaveProvider.notifier).edit(
                                materialId: materialMd.materialId,
                                description: ctrlDescription.text,
                                isCable: isCable.value ? "Y" : "N",
                                materialCode: ctrlCode.text,
                                packQty: ctrlPackSize.text,
                                packUnitId: selectedPackUnit.value.unitId,
                                unitId: selectedUnit.value.unitId,
                                query: query,
                              );
                        },
                      ),
                    ),
                  ],
                ),
              if (isStockShow.value)
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Divider(
                    color: Constants.greenDark,
                  ),
                ),
              if (isStockShow.value)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    bottom: 15.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FxStoreLk(
                          labelText: "Store",
                          hintText: "Store",
                          withAll: true,
                          onChanged: (value) {
                            ref.read(mdStoreIDProvider.notifier).state =
                                value?.storeID ?? "0";
                            ref
                                .read(materialStockSearchProvider.notifier)
                                .search(
                                    materialID: materialMd.materialId,
                                    storeID: value.storeID ?? "0");
                          },
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, bottom: 5.0),
                              child: Text(
                                "have",
                                style: TextStyle(
                                    fontSize: 16, color: Constants.greenDark),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 10.0, top: 10.0, left: 10.0),
                              child: Text(
                                totalStock.value,
                                style: const TextStyle(
                                    fontSize: 32, color: Constants.greyDark),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Text(
                                materialMd.uom,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Constants.greenDark,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              if (isStockShow.value)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: ListView.builder(
                        itemCount: listStock.value.length,
                        itemBuilder: (context, idx) {
                          final model = listStock.value[idx];
                          return _StockCardInfo(
                            model: model,
                            allowAvgPrice: materialMd.allowAvgPrice,
                            originalQuery: query,
                          );
                        }),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class _StockCardInfo extends HookConsumerWidget {
  const _StockCardInfo({
    super.key,
    required this.model,
    required this.allowAvgPrice,
    required this.originalQuery,
  });

  final MaterialStockModel model;
  final bool allowAvgPrice;
  final String originalQuery;
  String formatNumber(String? inp) {
    try {
      double dval = double.parse(inp!);
      final nbf = NumberFormat("###,##0", "en_US");
      return nbf.format(dval);
    } catch (_) {}
    return inp ?? "";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String packsize = formatNumber(model.packsizeCurrent);
    packsize = "$packsize ";
    packsize = "$packsize${model.itemUnit ?? ""}/";
    packsize = packsize + (model.packUnit ?? "");
    final ctrlPrice = useTextEditingController(text: model.avgPrice);
    final isLoading = useState(false);
    final errorMessage = useState("");

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Constants.greenDark.withOpacity(0.5)),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    _StockCardRow(
                      label: "PO No",
                      value: model.poNo,
                      print: true,
                      // save: true,
                      // isLoading: isLoading.value,
                      // onAvgPriceSave: () {
                      //   if (model.materialId != null &&
                      //       model.refType != null &&
                      //       model.refID != null) {
                      //     editedCard.value =
                      //         "${model.refType!}-${model.refID!}";
                      //     ref.read(materialMdEditPriceProvider.notifier).edit(
                      //           materialId: model.materialId ?? "0",
                      //           refType: model.refType ?? "",
                      //           refID: model.refID ?? "0",
                      //           xID: model.xID ?? "0",
                      //           price: ctrlPrice.text,
                      //           query: originalQuery,
                      //         );
                      //   }
                      // },
                      model: model,
                    ),
                    _StockCardRow(
                      label: "S/N",
                      value: model.packsizeBarcode,
                      model: model,
                    ),
                    if (model.isCable == "Y")
                      _StockCardRow(
                        label: "Drum No",
                        value: model.drumNo,
                        model: model,
                      ),
                    _StockCardRow(
                      label: "Pack Size",
                      value: packsize,
                      model: model,
                    ),
                    _StockCardRow(
                      label: "Total Item",
                      value: "1",
                      model: model,
                    ),
                    _StockCardRow(
                      label: "Total Qty",
                      value: formatNumber(model.packsizeCurrent),
                      model: model,
                    ),
                    _StockCardRow(
                      label: "Location",
                      value: model.storeName,
                      model: model,
                    ),
                    if (allowAvgPrice)
                      _StockCardRowEdit(
                        label: "Price",
                        value: formatNumber("0.0"),
                        model: model,
                        ctrlPrice: ctrlPrice,
                        onAvgPriceSave: (price, isAll) {
                          if (model.materialId != null &&
                              model.refType != null &&
                              model.refID != null) {
                            ref.read(materialMdEditPriceProvider.notifier).edit(
                                  materialId: model.materialId ?? "0",
                                  refType: model.refType ?? "",
                                  refID: model.refID ?? "0",
                                  xID: model.xID ?? "0",
                                  price: price,
                                  query: originalQuery,
                                  isAll: isAll ? "Y" : "N",
                                );
                          }
                        },
                      ),
                    if (isLoading.value)
                      const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class _StockCardRowEdit extends HookConsumerWidget {
  _StockCardRowEdit({
    required this.label,
    required this.value,
    required this.model,
    required this.ctrlPrice,
    this.onAvgPriceSave,
  });

  final String label;
  final String? value;
  final MaterialStockModel model;
  final TextEditingController ctrlPrice;
  final void Function(String, bool)? onAvgPriceSave;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");

    final ctrl = TextEditingController(text: model.avgPrice);
    ref.listen(materialMdEditPriceProvider, (prev, next) {
      if (next is MaterialMdEditPriceStateLoading) {
        isLoading.value = true;
      } else if (next is MaterialMdEditPriceStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is MaterialMdEditPriceStateDone) {
        isLoading.value = false;
      }
    });
    return Row(
      children: [
        SizedBox(
            width: 90,
            child: FxGreenDarkText(
              title: label,
            )),
        const FxGreenDarkText(title: ":"),
        const SizedBox(
          width: 20,
        ),
        FxTextField(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          width: 150,
          ctrl: ctrl,
          hintText: "",
          labelText: "",
        ),
        const SizedBox(
          width: 20,
        ),
        if (isLoading.value)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(),
          ),
        if (!isLoading.value)
          InkWell(
            onTap: () {
              if (onAvgPriceSave != null) {
                onAvgPriceSave!(ctrl.text, false);
              }
            },
            child: const FxGreenDarkText(title: "Save this"),
          ),
        if (!isLoading.value)
          const Padding(
            padding: EdgeInsets.only(right: 10.0, left: 10.0),
            child: FxGreenDarkText(
              title: "|",
            ),
          ),
        if (!isLoading.value)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                if (onAvgPriceSave != null) {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete'),
                        content: const Text(
                            'Do you want update the price for this material on all PO?'),
                        actions: <Widget>[
                          FxButton(
                            maxWidth: 120,
                            height: 34,
                            title: "No",
                            color: Constants.greenDark,
                            onPress: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FxButton(
                            maxWidth: 120,
                            height: 34,
                            title: "Yes",
                            color: Constants.red,
                            onPress: () {
                              onAvgPriceSave!(ctrl.text, true);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const FxGreenDarkText(
                title: "Save all",
              ),
            ),
          )
      ],
    );
  }
}

class _StockCardRow extends StatelessWidget {
  const _StockCardRow({
    required this.label,
    required this.value,
    this.print = false,
    this.save = false,
    this.onAvgPriceSave,
    this.isLoading = false,
    required this.model,
  });

  final String label;
  final String? value;
  final MaterialStockModel model;
  final bool print;
  final bool save;
  final bool isLoading;
  final void Function()? onAvgPriceSave;
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 90,
            child: FxGreenDarkText(
              title: label,
            )),
        const FxGreenDarkText(title: ":"),
        const SizedBox(
          width: 20,
        ),
        (value == "split" || value == "merged")
            ? Expanded(
                child: FxGreenDarkText(
                title:
                    (value == "split") ? "Split Material" : "Merged Material",
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ))
            : Expanded(
                child: FxGreenDarkText(
                title: value ?? "",
                color: Colors.black,
              )),
        if (print)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                String type = model.poNo ?? "";
                final snow = "&ts=${DateTime.now().toIso8601String()}";
                String url =
                    "https://${Constants.host}/reports/sor_inv_material_md.php?c=${model.packsizeBarcode}&mid=${model.materialId}$snow";
                if (type == "split" || type == "merge") {
                  url =
                      "https://${Constants.host}/reports/split_merge_one.php?type=$type&c=${model.packsizeBarcode}$snow";
                }
                if (kIsWeb) {
                  html.window.open(url, "rpttab");
                  return;
                }
              },
              child: Image.asset(
                "images/icon_printer.png",
                height: 22,
              ),
            ),
          ),
      ],
    );
  }
}

class _MaterialMdDetail extends HookConsumerWidget {
  const _MaterialMdDetail({
    Key? key,
    required this.materialMd,
    required this.query,
  }) : super(key: key);

  final MaterialMdModel materialMd;
  final String query;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Constants.greenDark),
          borderRadius: BorderRadius.circular(10),
          color: Constants.greenLight.withOpacity(0.01),
        ),
        child: Stack(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 10.0,
                top: 10.0,
                bottom: 10.0,
                right: 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: Constants.paddingTopContent),
                ],
              ),
            ),
            Positioned(
              child: InkWell(
                  onTap: () {},
                  child: const Icon(Icons.edit,
                      size: 24, color: Constants.greenDark)),
              // I
              // Icon(Icons.edit,size:24,color: Constants.greenDark),mage.asset(
              //   "images/icon_printer.png",
              //   width: 24,
              // ),
              top: 20,
              right: 20,
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: InkWell(
                onTap: () async {
                  if (await confirm(
                    context,
                    title: FxBlackText(
                        title: "Delete Material ${materialMd.materialCode}"),
                    content: FxBlackText(title: materialMd.description),
                  )) {}
                },
                child: Image.asset(
                  "images/icon_delete.png",
                  width: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoField extends StatelessWidget {
  final String label;
  final String value;
  final double width;
  const _RoField({
    Key? key,
    this.width = 100,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FxTextField(
      labelText: label,
      width: width,
      ctrl: TextEditingController(text: value),
      readOnly: true,
      enabled: false,
    );
  }
}
