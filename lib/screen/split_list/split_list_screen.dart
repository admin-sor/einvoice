import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/split_material_model.dart';
import 'package:sor_inventory/screen/split_list/split_list_provider.dart';
import 'package:sor_inventory/widgets/fx_filter_lk.dart';
import 'dart:html' as html;

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_store_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';

class SplitListScreen extends HookConsumerWidget {
  const SplitListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);
    final ctrlSearch = useTextEditingController(text: "");
    final errorMessage = useState("");
    final isLoading = useState(false);
    final selectedFilter = useState<FilterModel>(FilterModel("all", "All"));

    final selectedStore = useState<Map<String, dynamic>?>(null);
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

    final listSplitMaterial = useState<List<SplitMaterialModel>>(List.empty());

    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref
            .read(splitListStateProvider.notifier)
            .search(search: ctrlSearch.text, storeID: "", type: "");
      });
    }
    ref.listen(splitListStateProvider, (prev, next) {
      if (next is SplitListStateLoading) {
        isLoading.value = true;
      } else if (next is SplitListStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is SplitListStateDone) {
        isLoading.value = false;
        listSplitMaterial.value = next.list;
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Split & Merge Summary",
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
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FxTextField(
                          ctrl: ctrlSearch,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10,
                          ),
                          labelText: "Search description/barcode",
                          width: MediaQuery.of(context).size.width,
                          suffix: InkWell(
                            onTap: () {
                              ref.read(splitListStateProvider.notifier).search(
                                    search: ctrlSearch.text,
                                    storeID: selectedStore.value?["id"] ?? "",
                                    type: selectedFilter.value.code,
                                  );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FxFilterLk(
                          hintText: "Material Type",
                          labelLength: 80,
                          initialValue: selectedFilter.value,
                          onChanged: (model) {
                            selectedFilter.value = model;
                            ref.read(splitListStateProvider.notifier).search(
                                  storeID: selectedStore.value?["id"] ?? "",
                                  search: ctrlSearch.text,
                                  type: selectedFilter.value.code,
                                );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FxStoreLk(
                            withAll: true,
                            isGrey: false,
                            labelText: "Store Location",
                            hintText: "Select Store",
                            readOnly: false,
                            onChanged: (model) {
                              selectedStore.value = {
                                "id": model.storeID,
                                "name": model.storeName
                              };
                              ref.read(splitListStateProvider.notifier).search(
                                    storeID: model.storeID ?? "",
                                    search: ctrlSearch.text,
                                    type: selectedFilter.value.code,
                                  );
                            }),
                      ),
                    ],
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: kIsWeb ? Constants.webWidth : 600,
                    child: Column(
                      children: [
                        const _SplitMaterialHeader(),
                        const Divider(
                          color: Constants.greenDark,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: listSplitMaterial.value.length,
                            itemBuilder: (context, idx) {
                              final model = listSplitMaterial.value[idx];
                              return _SplitMaterialDetailRow(
                                isOdd: (idx % 2 == 0),
                                model: model,
                                query: ctrlSearch.text,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplitMaterialHeader extends StatelessWidget {
  const _SplitMaterialHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      SizedBox(
        width: 100,
        child: FxBlackText(
          title: "Date",
          color: Constants.greenDark,
          isBold: false,
        ),
      ),
      Expanded(
        child: FxBlackText(
          title: "Description",
          color: Constants.greenDark,
          isBold: false,
        ),
      ),
      SizedBox(
        width: 100,
        child: FxBlackText(
          title: "Type",
          color: Constants.greenDark,
          isBold: false,
        ),
      ),
      SizedBox(
        width: 130,
        child: FxBlackText(
          title: "Barcode",
          color: Constants.greenDark,
          isBold: false,
        ),
      ),
      SizedBox(width: 70),
    ]);
  }
}

class _SplitMaterialDetailRow extends HookConsumerWidget {
  const _SplitMaterialDetailRow({
    Key? key,
    required this.model,
    required this.query,
    this.isOdd = false,
  }) : super(key: key);

  final SplitMaterialModel model;
  final String query;
  final bool isOdd;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: FxBlackText(
              title: model.date.format(),
              isBold: false,
            ),
          ),
          Expanded(
            flex: 3,
            child: FxBlackText(
              title: model.description ?? "",
              isBold: false,
            ),
          ),
          SizedBox(
              width: 100,
              child: FxBlackText(
                title: model.type ?? "",
                isBold: false,
              )),
          SizedBox(
            width: 130,
            child: FxBlackText(
              title: model.barcode ?? "",
              isBold: false,
            ),
          ),
          InkWell(
            onTap: () {
              final snow = "&t=${DateTime.now().toIso8601String()}";
              final url =
                  "https://${Constants.host}/reports/split_merge_one.php?type=${model.type}&c=${model.barcode}$snow";
              if (kIsWeb) {
                html.window.open(url, "rpttab");
                return;
              }
            },
            child: SizedBox(
              width: 70,
              child: Image.asset(
                "images/icon_printer.png",
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension DateFormatOnString on String? {
  String format() {
    if (this == null) return "";
    final myDf = DateFormat("y-M-d H:m:s");
    final sdf = DateFormat("d/M/yy");
    try {
      return sdf.format(myDf.parse(this!));
    } catch (e) {
      return this!;
    }
  }
}
