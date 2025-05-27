import 'dart:async';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/vendor_material_model.dart';
import 'package:sor_inventory/model/vendor_model.dart';
import 'package:sor_inventory/screen/vendor_material/vendor_material_delete_provider.dart';
import 'package:sor_inventory/screen/vendor_material/vendor_material_search_provider.dart';
import 'package:sor_inventory/screen/vendor_material/vendor_material_selected_provider.dart';
import 'package:sor_inventory/widgets/fx_black_text.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';

class VendorMaterialScreen extends HookConsumerWidget {
  const VendorMaterialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);
    final errorMessage = useState("");
    final isLoading = useState(false);
    final listMaterial = useState<List<VendorMaterialModel>>(List.empty());
    final ctrlSearch = useTextEditingController(text: "");

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
          if (loginModel.value == null) {
            ref.read(loginStateProvider.notifier).checkLocalToken();
          }
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
        if (ref.watch(vendorMaterialSelectedVendorProvider) == null) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              vendorRoute, (route) => route.settings.name == vendorRoute);
          return;
        }
        ref.read(vendorMaterialSearchProvider.notifier).search(
            vendorID: ref.watch(vendorMaterialSelectedVendorProvider)!.vendorID,
            query: ctrlSearch.text);
      });
    }
    ref.listen(vendorMaterialSearchProvider, (prev, next) {
      if (next is VendorMaterialSearchStateLoading) {
        isLoading.value = true;
      } else if (next is VendorMaterialSearchStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is VendorMaterialSearchStateDone) {
        isLoading.value = false;
        listMaterial.value = next.list;
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Vendor Material",
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.grey,
        foregroundColor: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(
            color: Constants.greenDark,
            width: 2.0,
          ),
        ),
        onPressed: () {
          final vendor =
              ref.watch(vendorMaterialSelectedVendorProvider) as VendorModel;
          final material = VendorMaterialModel(
              vendorPriceID: "0",
              description: "",
              materialCode: "",
              materialId: "0",
              packQty: "0",
              packUnitId: "0",
              puUnit: "",
              unit: "",
              unitId: "0",
              vendorMaterialLeadTime: "0",
              vendorPriceAmount: "0");
          Navigator.of(context).pushNamed(vendorMaterialEditRoute, arguments: {
            "vendor": vendor,
            "material": material,
            "query": ctrlSearch.text,
          });
        },
        child: Image.asset(
          "./images/icon_add_green.png",
          width: 32,
          height: 32,
        ),
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
              _VendorInfo(
                vendor: ref.read(vendorMaterialSelectedVendorProvider)
                    as VendorModel,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  FxTextField(
                    ctrl: ctrlSearch,
                    labelText: "Search Material",
                    width: MediaQuery.of(context).size.width,
                    suffix: InkWell(
                      onTap: () {
                        ref.read(vendorMaterialSearchProvider.notifier).search(
                            vendorID: ref
                                .watch(vendorMaterialSelectedVendorProvider)!
                                .vendorID,
                            query: ctrlSearch.text);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.search),
                      ),
                    ),
                  ),
                  if (isLoading.value)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: const CircularProgressIndicator(),
                    )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: listMaterial.value.length,
                  itemBuilder: (context, idx) {
                    final material = listMaterial.value[idx];
                    final vendor =
                        ref.read(vendorMaterialSelectedVendorProvider)
                            as VendorModel;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _MaterialDetail(
                        material: material,
                        query: ctrlSearch.text,
                        vendor: vendor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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

class _MaterialDetail extends HookConsumerWidget {
  const _MaterialDetail({
    Key? key,
    required this.material,
    required this.vendor,
    required this.query,
  }) : super(key: key);

  final VendorMaterialModel material;
  final VendorModel vendor;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");

    ref.listen(vendorMaterialDeleteProvider, (prev, next) {
      if (next is VendorMaterialDeleteStateLoading) {
        isLoading.value = true;
      } else if (next is VendorMaterialDeleteStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is VendorMaterialDeleteStateDone) {
        isLoading.value = false;
      }
    });
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(10.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 10.0,
              left: 10.0,
              right: 60.0,
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _RoField(
                value: material.description,
                width: MediaQuery.of(context).size.width,
                label: "Description",
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _RoField(
                      value: material.materialCode,
                      label: "Code",
                      width: 150,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 1,
                    child: _RoField(
                      textAlign: TextAlign.right,
                      value: material.vendorPriceAmount,
                      label: "Price",
                      width: 150,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _RoField(
                      value: material.unit,
                      label: "Unit",
                      width: 150,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 1,
                    child: _RoField(
                      value: material.puUnit,
                      label: "Pack Unit",
                      width: 150,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 1,
                    child: _RoField(
                      textAlign: TextAlign.right,
                      value: material.packQty,
                      label: "Pack Size",
                      width: 150,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 1,
                    child: _RoField(
                      textAlign: TextAlign.right,
                      value: material.vendorMaterialLeadTime,
                      label: "Lead Time",
                      width: 150,
                    ),
                  ),
                ],
              ),
            ]),
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: InkWell(
              onTap: () {
                final param = {
                  "vendor": vendor,
                  "material": material,
                  "query": query,
                };
                Navigator.of(context)
                    .pushNamed(vendorMaterialEditRoute, arguments: param);
              },
              child: Image.asset(
                "images/icon_edit.png",
                width: 24,
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: InkWell(
              onTap: () async {
                if (await confirm(context,
                    title: FxBlackText(
                        title:
                            "Confirm delete material ${material.materialCode}?"),
                    content: FxBlackText(title: material.description))) {
                  ref.read(vendorMaterialDeleteProvider.notifier).delete(
                      vendorPriceID: material.vendorPriceID,
                      query: query,
                      vendorID: vendor.vendorID);
                }
              },
              child: Image.asset(
                "images/icon_delete.png",
                width: 24,
              ),
            ),
          ),
        ],
      ),
    );
    // ]);
  }
}

class _MaterialHeader extends StatelessWidget {
  const _MaterialHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      SizedBox(
        width: 58,
      ),
      SizedBox(width: 100, child: FxGreenDarkText(title: "Code")),
      SizedBox(width: 10),
      Expanded(child: FxGreenDarkText(title: "Description")),
      SizedBox(width: 10),
      SizedBox(
          width: 120,
          child: FxGreenDarkText(
            title: "Price",
            align: TextAlign.end,
          )),
      SizedBox(width: 10),
      SizedBox(
          width: 120,
          child: FxGreenDarkText(
            title: "Delivery Time",
            align: TextAlign.end,
          )),
    ]);
  }
}

class _RoField extends StatelessWidget {
  final String label;
  final String value;
  final double width;
  final TextAlign textAlign;
  const _RoField({
    Key? key,
    this.width = 100,
    required this.label,
    required this.value,
    this.textAlign = TextAlign.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FxTextField(
      textAlign: textAlign,
      labelText: label,
      width: width,
      ctrl: TextEditingController(text: value),
      readOnly: true,
      enabled: false,
    );
  }
}
