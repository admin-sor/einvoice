import 'dart:async';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/screen/material_md/material_md_delete_provider.dart';
import 'package:sor_inventory/screen/material_md/material_md_search_provider.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/materialmd_model.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';

class MaterialMdScreenWeb extends HookConsumerWidget {
  const MaterialMdScreenWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);
    final ctrlSearch = useTextEditingController(text: "");
    final errorMessage = useState("");
    final isLoading = useState(false);

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

    const horiSpace = SizedBox(width: 10);
    final listMaterialMd = useState<List<MaterialMdModel>>(List.empty());

    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref
            .read(materialMdSearchProvider.notifier)
            .search(query: ctrlSearch.text);
      });
    }
    ref.listen(materialMdSearchProvider, (prev, next) {
      if (next is MaterialMdSearchStateLoading) {
        isLoading.value = true;
      } else if (next is MaterialMdSearchStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is MaterialMdSearchStateDone) {
        isLoading.value = false;
        listMaterialMd.value = next.model;
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Material",
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
          Navigator.of(context).pushNamed(
            materialMdEditRoute,
            arguments: {
              "query": ctrlSearch.text,
              "materialMd": MaterialMdModel(
                  isCable: "N",
                  description: "",
                  materialId: "0",
                  materialCode: "",
                  unitId: "0",
                  uom: "",
                  packUnit: "",
                  packUnitId: "",
                  packQty: "")
            },
          );
        },
        child: Image.asset(
          "images/icon_add_green.png",
          width: 32,
          height: 32,
        ),
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
                FxTextField(
                  ctrl: ctrlSearch,
                  labelText: "Search Code / Description",
                  width: MediaQuery.of(context).size.width,
                  suffix: InkWell(
                    onTap: () {
                      ref
                          .read(materialMdSearchProvider.notifier)
                          .search(query: ctrlSearch.text);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 800,
                      child: Column(
                        children: [
                          const _Header(),
                          const Divider(
                            color: Constants.greenDark,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: listMaterialMd.value.length,
                              itemBuilder: (context, idx) {
                                final mat = listMaterialMd.value[idx];
                                return InkWell(
                                    onTap: () {
                                      final param = {
                                        "materialMd": mat,
                                        "query": ctrlSearch.text
                                      };
                                      Navigator.of(context).pushNamed(
                                          materialMdEditRoute,
                                          arguments: param);
                                    },
                                    child: _MaterialMdDetailRow(
                                      isOdd: (idx % 2 == 0),
                                      material: mat,
                                      query: ctrlSearch.text,
                                    ));
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        SizedBox(
            width: 100,
            child: FxBlackText(
              title: "Code",
              color: Constants.greenDark,
              isBold: false,
            )),
        Expanded(
            child: FxBlackText(
          title: "Description",
          color: Constants.greenDark,
          isBold: false,
        )),
        SizedBox(
            width: 100,
            child: FxBlackText(
              title: "Pack Unit",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 100,
            child: FxBlackText(
              title: "Pack Size",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 100,
            child: FxBlackText(
              title: "UOM",
              color: Constants.greenDark,
              isBold: false,
            )),
      ],
    );
  }
}

class _MaterialMdDetailRow extends StatelessWidget {
  final MaterialMdModel material;
  final String query;
  final bool isOdd;
  const _MaterialMdDetailRow(
      {Key? key,
      required this.material,
      required this.query,
      required this.isOdd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isOdd ? null : Constants.greenLight.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            SizedBox(
                width: 100,
                child: FxBlackText(
                  title: material.materialCode,
                  isBold: false,
                )),
            Expanded(
                child: FxBlackText(
              title: material.description,
              isBold: false,
            )),
            SizedBox(
                width: 100,
                child: FxBlackText(
                  title: material.packUnit,
                  isBold: false,
                )),
            SizedBox(
                width: 100,
                child: FxBlackText(
                  title: material.packQty,
                  isBold: false,
                )),
            SizedBox(
                width: 100,
                child: FxBlackText(
                  title: material.uom,
                  isBold: false,
                )),
          ],
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

    ref.listen(materialMdDeleteProvider, (prev, next) {
      if (next is MaterialMdDeleteStateLoading) {
        isLoading.value = true;
      } else if (next is MaterialMdDeleteStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is MaterialMdDeleteStateDone) {
        isLoading.value = false;
      }
    });
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
                  _RoField(
                    value: materialMd.description,
                    width: MediaQuery.of(context).size.width,
                    label: "Description",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: _RoField(
                            value: materialMd.materialCode,
                            label: "Code",
                            width: 150,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        flex: 1,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.4)),
                                ),
                                child: materialMd.isCable == "Y"
                                    ? Image.asset(
                                        "images/icon_on.png",
                                        height: 32,
                                      )
                                    : Image.asset(
                                        "images/icon_off.png",
                                        height: 32,
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 5,
                              child: Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                  ),
                                  child: Text(
                                    "is Cable",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Constants.greenDark
                                            .withOpacity(0.7)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: _RoField(
                                label: "Unit",
                                value: materialMd.uom,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _RoField(
                                value: materialMd.packUnit,
                                label: "Pack Unit",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: _RoField(
                          value: materialMd.packQty,
                          textAlign: TextAlign.right,
                          label: "Pack Size",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: InkWell(
                onTap: () {
                  final param = {"materialMd": materialMd, "query": query};
                  Navigator.of(context)
                      .pushNamed(materialMdEditRoute, arguments: param);
                },
                child: Image.asset(
                  "images/icon_edit.png",
                  width: 24,
                ),
              ),
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
                  )) {
                    ref.read(materialMdDeleteProvider.notifier).delete(
                          materialId: materialMd.materialId,
                          query: query,
                        );
                  }
                },
                child: Stack(
                  children: [
                    Image.asset(
                      "images/icon_delete.png",
                      width: 24,
                    ),
                    if (isLoading.value)
                      const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator()),
                  ],
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
