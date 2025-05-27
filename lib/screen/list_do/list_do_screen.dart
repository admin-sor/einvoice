import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/ac_material_model.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/lis_do_response_model.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_ac_material_po.dart';
import '../../widgets/fx_auto_completion_vendor.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_store_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../do/get_do_provider.dart';
import '../login/login_provider.dart';
import 'list_do_provider.dart';
import 'selected_do_provider.dart';

class ListDoScreen extends HookConsumerWidget {
  const ListDoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);

    final ctrlDoNumber = useTextEditingController(text: "");
    final ctrlPoNumber = useTextEditingController(text: "");
    final selectedVendor =
        useState<VendorModel?>(VendorModel(vendorID: "0", vendorName: "All"));
    final isLoading = useState(false);
    final errorMessageLoadDo = useState("");

    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listDo = useState<List<ListDoResponseModel>>(List.empty());

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

    const horiSpace = SizedBox(width: 10);
    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(listDoStateProvider.notifier).list(
              doNo: "",
              storeID: selectedStore.value!["id"],
              vendorID: "",
              poNo: "",
              materialID: "0",
            );
      });
    }
    final lookupInProgress = useState(false);
    ref.listen(listDoStateProvider, (prev, next) {
      if (next is ListDoStateLoading) {
        isLoading.value = true;
        lookupInProgress.value = true;
      } else if (next is ListDoStateError) {
        isLoading.value = false;
        lookupInProgress.value = false;
        errorMessageLoadDo.value = next.message;
      } else if (next is ListDoStateDone) {
        lookupInProgress.value = false;
        listDo.value = next.list;
      }
    });
    double filterWidth = MediaQuery.of(context).size.width - 20;
    if (kIsWeb && MediaQuery.of(context).size.width > Constants.webWidth) {
      filterWidth = Constants.webWidth;
    }
    final ctrlMaterial = useTextEditingController(text: "");
    final fcMaterial = FocusNode();
    final selectedMaterial = useState<AcMaterialModel?>(null);
    // selectedMaterial.addListener(
    //   () {
    //     if (lookupInProgress.value) {
    //       return;
    //     }
    //     ref.read(listDoStateProvider.notifier).list(
    //         doNo: ctrlDoNumber.text,
    //         poNo: ctrlPoNumber.text,
    //         vendorID: selectedVendor.value?.vendorID ?? "0",
    //         storeID: selectedStore.value?["id"] ?? "0",
    //         materialID: selectedMaterial.value?.materialId ?? "0");
    //   },
    // );
    // selectedStore.addListener(() {
    //   if (lookupInProgress.value) {
    //     return;
    //   }
    //   ref.read(listDoStateProvider.notifier).list(
    //       doNo: ctrlDoNumber.text,
    //       poNo: ctrlPoNumber.text,
    //       vendorID: selectedVendor.value?.vendorID ?? "0",
    //       storeID: selectedStore.value?["id"] ?? "0",
    //       materialID: selectedMaterial.value?.materialId ?? "0");
    // });
    var screenWidth = MediaQuery.of(context).size.width + 20;
    if (screenWidth > Constants.webWidth) {
      screenWidth = Constants.webWidth + 12;
    }
    if (selectedMaterial.value != null) {
      screenWidth = 245;
    }
    final ctrlMaterialDesc = useTextEditingController(text: "");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "DO Summary",
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
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: kIsWeb
              ? Constants.webWidth
              : MediaQuery.of(context).size.width - 20,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: Constants.paddingTopContent,
                ),
                SizedBox(
                  width: filterWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: FxAutoCompletionVendor(
                          width: 180,
                          initialValue: const TextEditingValue(text: "All"),
                          labelText: "Vendor",
                          hintText: "Vendor",
                          value: selectedVendor.value?.vendorName ?? "",
                          onSelected: (model) {
                            selectedVendor.value = model;
                            ref.read(listDoStateProvider.notifier).list(
                                doNo: ctrlDoNumber.text,
                                poNo: ctrlPoNumber.text,
                                vendorID: model.vendorID,
                                storeID: selectedStore.value?["id"] ?? "0",
                                materialID:
                                    selectedMaterial.value?.materialId ?? "0");
                          },
                          withAll: true,
                          optionWidth: kIsWeb
                              ? Constants.webWidth - 40
                              : MediaQuery.of(context).size.width,
                        ),
                      ),
                      horiSpace,
                      Expanded(
                        child: FxTextField(
                            isFixedTitle: true,
                            ctrl: ctrlDoNumber,
                            labelText: "DO Number",
                            hintText: "",
                            textCapitalization: TextCapitalization.characters,
                            onChanged: (v) {
                              ref.read(listDoStateProvider.notifier).list(
                                  doNo: ctrlDoNumber.text,
                                  poNo: ctrlPoNumber.text,
                                  vendorID:
                                      selectedVendor.value?.vendorID ?? "0",
                                  storeID: selectedStore.value?["id"] ?? "0",
                                  materialID:
                                      selectedMaterial.value?.materialId ??
                                          "0");
                            }),
                      ),
                      horiSpace,
                      Expanded(
                        child: FxTextField(
                          isFixedTitle: true,
                          ctrl: ctrlPoNumber,
                          labelText: "PO Number",
                          hintText: "",
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (v) {
                            ref.read(listDoStateProvider.notifier).list(
                                  doNo: ctrlDoNumber.text,
                                  poNo: ctrlPoNumber.text,
                                  vendorID:
                                      selectedVendor.value?.vendorID ?? "0",
                                  storeID: selectedStore.value?["id"] ?? "0",
                                  materialID:
                                      selectedMaterial.value?.materialId ?? "0",
                                );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: selectedMaterial.value == null ? 2 : 1,
                      child: FxAutoCompletionMaterialPo(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        fromVendorStyling: false,
                        width: double.infinity,
                        ctrl: ctrlMaterial,
                        fc: fcMaterial,
                        withoutPrice: true,
                        onSelectedMaterial: (model) {
                          selectedMaterial.value = model;
                          ctrlMaterialDesc.text = model?.description ?? "";
                          ref.read(listDoStateProvider.notifier).list(
                              doNo: ctrlDoNumber.text,
                              poNo: ctrlPoNumber.text,
                              vendorID: selectedVendor.value?.vendorID ?? "0",
                              storeID: selectedStore.value?["id"] ?? "0",
                              materialID: model?.materialId ?? "0");
                        },
                        labelText: selectedMaterial.value == null
                            ? "Material Code/Description"
                            : "Material Code",
                        hintText: "",
                        // withReset: selectedMaterial.value != null,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    if (selectedMaterial.value != null)
                      Expanded(
                        flex: 1,
                        child: FxTextField(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 18),
                          hintText: "Description",
                          labelText: "Description",
                          ctrl: ctrlMaterialDesc,
                          readOnly: true,
                          enabled: false,
                        ),
                      ),
                    if (selectedMaterial.value != null)
                      SizedBox(
                        width: 10,
                      ),
                    Expanded(
                      flex: 1,
                      child: FxStoreLk(
                        withAll: true,
                        labelText: "Store Location",
                        hintText: "Select Store",
                        readOnly: false,
                        isGrey: true,
                        onChanged: (model) {
                          selectedStore.value = {
                            "id": model.storeID,
                            "name": model.storeName
                          };

                          ref.read(listDoStateProvider.notifier).list(
                              doNo: ctrlDoNumber.text,
                              poNo: ctrlPoNumber.text,
                              vendorID: selectedVendor.value?.vendorID ?? "0",
                              storeID: model.storeID ?? "0",
                              materialID:
                                  selectedMaterial.value?.materialId ?? "0");
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                const _DoHeader(),
                const Divider(color: Constants.greenDark, thickness: 1),
                Expanded(
                    child: ListView.builder(
                        itemCount: listDo.value.length,
                        itemBuilder: (context, idx) {
                          final model = listDo.value[idx];
                          return _DoDisplay(
                            model: model,
                            isOdd: idx % 2 == 1,
                            onTap: () {
                              ref.read(selectedDoProvider.notifier).state =
                                  SelectedDoModel(
                                doID: model.doID,
                                doNo: model.doNo,
                                poNo: model.poNo,
                                poID: model.poID,
                                storeID: model.doStoreID,
                                doDate: model.doDate,
                                vendorModel: VendorModel(
                                  vendorID: model.doVendorID,
                                  vendorName: model.vendorName,
                                ),
                              );
                              ref.read(getDoDetailStateProvider.notifier).get(
                                    vendorID: model.doVendorID,
                                    doNo: model.doNo,
                                    storeID: model.doStoreID,
                                  );
                              Navigator.of(context)
                                  .pushNamed(doRoute, arguments: true);
                            },
                          );
                        }))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoHeader extends StatelessWidget {
  const _DoHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      // SizedBox(width: 80, child: FxGreenDarkText(title: "Date")),
      // SizedBox(width: 10),
      // SizedBox(width: 150, child: FxGreenDarkText(title: "DO No.")),
      // SizedBox(width: 10),
      // SizedBox(width: 180, child: FxGreenDarkText(title: "PO No.")),
      // SizedBox(width: 10),
      // Expanded(child: FxGreenDarkText(title: "Vendor")),
      Expanded(flex: 10, child: FxGreenDarkText(title: "Date")),
      SizedBox(width: 10),
      Expanded(flex: 20, child: FxGreenDarkText(title: "Do No.")),
      SizedBox(width: 10),
      Expanded(flex: 20, child: FxGreenDarkText(title: "PO No.")),
      SizedBox(width: 10),
      Expanded(flex: 30, child: FxGreenDarkText(title: "Vendor")),
      SizedBox(width: 10),
      Expanded(flex: 20, child: FxGreenDarkText(title: "Store")),
    ]);
  }
}

class _DoDisplay extends StatelessWidget {
  const _DoDisplay({
    Key? key,
    required this.model,
    required this.isOdd,
    this.onTap,
  }) : super(key: key);

  final ListDoResponseModel model;
  final bool isOdd;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final sdf = DateFormat("yyyy-MM-dd");
    String fdate = model.doDate;
    try {
      fdate = DateFormat("dd/MM/yy").format(sdf.parse(model.doDate));
    } catch (_) {}
    return Container(
      color: isOdd ? null : Constants.greenLight.withOpacity(0.2),
      child: InkWell(
        onTap: () {
          if (onTap != null) onTap!();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // SizedBox(width: 80, child: FxBlackText(title: fdate)),
              // const SizedBox(width: 10),
              // SizedBox(width: 150, child: FxBlackText(title: model.doNo)),
              // const SizedBox(width: 10),
              // SizedBox(width: 180, child: FxBlackText(title: model.poNo)),
              // const SizedBox(width: 10),
              // Expanded(
              //   child: FxBlackText(title: model.vendorName),
              // ),
              Expanded(flex: 10, child: FxBlackText(title: fdate)),
              const SizedBox(width: 10),
              Expanded(flex: 20, child: FxBlackText(title: model.doNo)),
              const SizedBox(width: 10),
              Expanded(flex: 20, child: FxBlackText(title: model.poNo)),
              const SizedBox(width: 10),
              Expanded(flex: 30, child: FxBlackText(title: model.vendorName)),
              const SizedBox(width: 10),
              Expanded(flex: 20, child: FxBlackText(title: model.storeName)),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
