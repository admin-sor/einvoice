import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/vendor_lookup_material_model.dart';
import 'package:sor_inventory/model/vendor_material_model.dart';
import 'package:sor_inventory/model/vendor_model.dart';
import 'package:sor_inventory/screen/vendor_material/vendor_material_save_provider.dart';
import 'package:sor_inventory/widgets/fx_ac_material_vendor.dart';
import 'package:sor_inventory/widgets/fx_text_field.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_button.dart';
import '../login/login_provider.dart';

class VendorMaterialEditScreen extends HookConsumerWidget {
  final VendorModel vendor;
  final VendorMaterialModel material;
  final String query;

  const VendorMaterialEditScreen({
    Key? key,
    required this.vendor,
    required this.material,
    required this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);
    final errorMessage = useState("");
    final isLoading = useState(false);

    final selectedMaterial = useState<VendorLookupMaterialModel?>(
        material.vendorPriceID == "0"
            ? null
            : VendorLookupMaterialModel(
                description: material.description,
                materialCode: material.materialCode,
                materialId: material.materialId,
                packQty: material.packQty,
                packUnitId: material.packUnitId,
                puUnit: material.puUnit,
                unit: material.unit,
                unitId: material.unitId));
    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
      }
    });
    bool isNew = true;
    if (material.vendorPriceID != "0") {
      isNew = false;
    }
    final ctrlMaterial = useTextEditingController(
        text: material.vendorPriceID == "0" ? "" : material.materialCode);
    final ctrlPrice = useTextEditingController(
        text: material.vendorPriceID == "0" ? "" : material.vendorPriceAmount);
    final ctrlDeliveryTime = useTextEditingController(
        text: material.vendorPriceID == "0"
            ? ""
            : material.vendorMaterialLeadTime);
    final ctrlPackQty = useTextEditingController(
        text: material.vendorPriceID == "0" ? "" : material.packQty);
    //no login
    final errorPrice = useState("");
    final errorDeliveryTime = useState("");
    final errorPackQty = useState("");

    if (loginModel.value == null) {
      if (isInit.value) {
        isInit.value = false;
        Timer(const Duration(milliseconds: 500), () {
          ref.read(loginStateProvider.notifier).checkLocalToken();
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

    const horiSpace = SizedBox(width: 10);
    final focusNode = useFocusNode();
    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {});
    }

    ref.listen(vendorMaterialSaveProvider, (previous, next) {
      if (next is VendorMaterialSaveStateLoading) {
        isLoading.value = true;
      } else if (next is VendorMaterialSaveStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
      } else if (next is VendorMaterialSaveStateDone) {
        isLoading.value = false;
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          isNew ? "Add Material" : "Edit Material",
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
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height - 80,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: Constants.paddingTopContent,
                ),
                _VendorInfo(vendor: vendor),
                const SizedBox(
                  height: 10,
                ),
                FxAutoCompletionMaterialVendor(
                  width: double.infinity,
                  vendorID: vendor.vendorID,
                  ctrl: ctrlMaterial,
                  fc: focusNode,
                  labelText: "Search Code/Description",
                  hintText: "Search Code/Description",
                  onSelectedMaterial: (m) {
                    selectedMaterial.value = m;
                    if (m?.packQty != null) {
                      ctrlPackQty.text = m!.packQty;
                    }
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                if (selectedMaterial.value != null)
                  _MaterialInfo(selectedMaterial: selectedMaterial),
                if (selectedMaterial.value != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FxTextField(
                          labelText: 'Price',
                          ctrl: ctrlPrice,
                          isMoney: true,
                          textAlign: TextAlign.end,
                          errorMessage: errorPrice.value,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FxTextField(
                          labelText: 'Pack Size',
                          enabled: true,
                          readOnly: false,
                          ctrl: ctrlPackQty,
                          textAlign: TextAlign.end,
                          errorMessage: errorPackQty.value,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FxTextField(
                          labelText: 'Delivery Time (days)',
                          ctrl: ctrlDeliveryTime,
                          textAlign: TextAlign.end,
                          errorMessage: errorDeliveryTime.value,
                        ),
                      ),
                    ],
                  ),
                if (errorMessage.value != "")
                  FxBlackText(
                    title: errorMessage.value,
                    color: Constants.red,
                  ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: FxButton(
                        title: "Cancel",
                        onPress: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: FxButton(
                        title: "Save",
                        color: Constants.greenDark,
                        isLoading: isLoading.value,
                        onPress: () {
                          if (ctrlPrice.text == "") {
                            errorPrice.value = "Price is mandatory";
                          } else {
                            errorPrice.value = "";
                          }
                          if (ctrlPackQty.text == "") {
                            errorPackQty.value = "Pack Size is mandatory";
                          } else {
                            errorPackQty.value = "";
                          }
                          if (ctrlDeliveryTime.text == "") {
                            errorDeliveryTime.value =
                                "Delivery time is mandatory";
                          } else {
                            errorDeliveryTime.value = "";
                          }
                          if (errorPrice.value != "" ||
                              errorPackQty.value != "" ||
                              errorDeliveryTime.value != "") {
                            return;
                          }
                          ref.read(vendorMaterialSaveProvider.notifier).save(
                                vendorPriceID:
                                    isNew ? "0" : material.vendorPriceID,
                                vendorPriceVendorID: vendor.vendorID,
                                vendorPriceAmount: ctrlPrice.text,
                                vendorPricePackQty: ctrlPackQty.text,
                                vendorMaterialID:
                                    selectedMaterial.value!.materialId,
                                vendorMaterialLeadTime: ctrlDeliveryTime.text,
                                query: query,
                              );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaterialInfo extends StatelessWidget {
  const _MaterialInfo({
    Key? key,
    required this.selectedMaterial,
  }) : super(key: key);

  final ValueNotifier<VendorLookupMaterialModel?> selectedMaterial;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        FxTextField(
          width: double.infinity,
          readOnly: true,
          enabled: false,
          labelText: 'Description',
          ctrl:
              TextEditingController(text: selectedMaterial.value!.description),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: FxTextField(
                readOnly: true,
                enabled: false,
                labelText: 'Code',
                ctrl: TextEditingController(
                    text: selectedMaterial.value!.materialCode),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: FxTextField(
                readOnly: true,
                enabled: false,
                labelText: 'Unit',
                ctrl: TextEditingController(text: selectedMaterial.value!.unit),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: FxTextField(
                readOnly: true,
                enabled: false,
                labelText: 'Pack Unit',
                ctrl:
                    TextEditingController(text: selectedMaterial.value!.puUnit),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

class _VendorInfo extends StatelessWidget {
  final VendorModel vendor;
  const _VendorInfo({Key? key, required this.vendor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxBlackText(title: vendor.vendorName),
        const SizedBox(
          height: 5,
        ),
        FxBlackText(title: vendor.vendorAdd1),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
