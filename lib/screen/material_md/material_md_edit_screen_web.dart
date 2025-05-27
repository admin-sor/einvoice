import 'dart:async';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/screen/material_md/material_md_save_provider.dart';
import 'package:sor_inventory/widgets/fx_auto_completion_pack_unitv2.dart';
import 'package:sor_inventory/widgets/fx_auto_completion_unit.dart';

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

class MaterialMdEditScreenWeb extends HookConsumerWidget {
  final MaterialMdModel materialMd;
  final String query;
  const MaterialMdEditScreenWeb({
    Key? key,
    required this.materialMd,
    required this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final ctrlSearch = useTextEditingController(text: "");
    final errorMessage = useState("");
    final isLoading = useState(false);
    final inEditMode = useState(false);

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
          if (loginModel.value == null)
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
    ref.listen(materialMdSaveProvider, (prev, next) {
      if (next is MaterialMdSaveStateLoading) {
        isLoading.value = true;
      } else if (next is MaterialMdSaveStateError) {
        errorMessage.value = next.message;
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
      body: Center(
        child: Container(
          width: Constants.webWidth,
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
                  children: [
                    FxTextField(
                      ctrl: ctrlCode,
                      width: 110,
                      maxLength: 10,
                      labelText: "Code",
                      hintText: "Code",
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: FxTextField(
                        labelText: "Description",
                        hintText: "Description",
                        ctrl: ctrlDescription,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    FxAutoCompletionPackUnitV2(
                      width: 110,
                      labelText: "Pack Unit",
                      hintText: "Pack Unit",
                      ctrlUnit: ctrlPackUnit,
                      focusNode: useFocusNode(),
                      onSelected: (v) {
                        selectedPackUnit.value = v;
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: FxTextField(
                          textAlign: TextAlign.right,
                          ctrl: ctrlPackSize,
                          width: 100,
                          enabled: true,
                          readOnly: false,
                          labelText: "Pack Size",
                          hintText: "Pack Size"),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: FxAutoCompletionUnit(
                        width: 100,
                        ctrlUnit: ctrlUnit,
                        hintText: "UOM",
                        labelText: "UOM",
                        focusNode: useFocusNode(),
                        onSelected: (v) {
                          selectedUnit.value = v;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Spacer(),
                    if (!inEditMode.value && materialMd.materialId != "0")
                      FxButton(
                        maxWidth: MediaQuery.of(context).size.width / 3,
                        color: Constants.greenDark,
                        title: "Edit",
                        onPress: () {
                          inEditMode.value = !inEditMode.value;
                        },
                      ),
                  ],
                ),
                const Spacer(),
                if (errorMessage.value != "")
                  FxGrayDarkText(
                    color: Constants.red,
                    title: errorMessage.value,
                  ),
                if (inEditMode.value || materialMd.materialId == "0")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (materialMd.materialId != "0")
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
                                content:
                                    FxBlackText(title: materialMd.description),
                              )) {
                                ref
                                    .read(materialMdDeleteProvider.notifier)
                                    .delete(
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
                  )
              ],
            ),
          ),
        ),
      ),
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
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                top: 10.0,
                bottom: 10.0,
                right: 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: Constants.paddingTopContent),
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
