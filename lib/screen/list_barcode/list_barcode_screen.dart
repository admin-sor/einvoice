import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/repository/merge_repository.dart';
import 'package:sor_inventory/screen/list_barcode/list_barcode_provider.dart';
import 'package:sor_inventory/screen/merge/byid_provider.dart';
import 'package:sor_inventory/widgets/fx_date_field.dart';
import 'package:sor_inventory/widgets/fx_text_field.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_filter_lk.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../login/login_provider.dart';
import '../merge/merge_item_provider.dart';
import 'dart:html' as html;

class ListBarcodeScreen extends HookConsumerWidget {
  const ListBarcodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);

    final selectedFilter = useState<FilterModel>(FilterModel("all", "All"));
    final ctrlSearch = useTextEditingController(text: "");
    final isLoading = useState(false);
    final errorMessage = useState("");
    final listBarcode = useState<List<SplitMergeResponse>>(List.empty());

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

    final fromDate = useState<DateTime>(DateTime.now());
    final toDate = useState<DateTime>(DateTime.now());
    final firstDate = DateTime.now().subtract(Duration(days: 730));
    final lastDate = DateTime.now();
    
    const horiSpace = SizedBox(width: 10);
    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(listBarcodeStateProvider.notifier).list(
              filter: "all",
              search: "",
              from: fromDate.value,
              to: toDate.value,
            );
      });
    }
    // ctrlSearch.addListener(() {
    //   ref.read(listBarcodeStateProvider.notifier).list(
    //         filter: selectedFilter.value.code,
    //         search: ctrlSearch.text,
    //       );
    // });
    ref.listen(listBarcodeStateProvider, (prev, next) {
      if (next is ListBarcodeStateLoading) {
        isLoading.value = true;
      } else if (next is ListBarcodeStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is ListBarcodeStateDone) {
        listBarcode.value = next.list;
      }
    });
    final selectedMergeMaterialID = useState<String?>(null);

    ref.listen(mergeByIDStateProvider, (previous, next) {
      if (next is MergeByIDStateLoading) {
        isLoading.value = true;
      } else if (next is MergeByIDStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is MergeByIDStateDone) {
        isLoading.value = false;
        ref.read(mergeItemProvider.notifier).state = next.list;
        if (selectedMergeMaterialID.value != null) {
          Navigator.of(context).pushNamed(mergeListMaterialRoute,
              arguments: selectedMergeMaterialID.value!);
        }
      }
    });
    double filterWidth = MediaQuery.of(context).size.width - 20;
    if (kIsWeb && MediaQuery.of(context).size.width > Constants.webWidth) {
      filterWidth = Constants.webWidth;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Split/Merge Summary",
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
                  child: Focus(
                    onKey: (fc, keyEvent) {
                      if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter)) {
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: FxDateField(
                            hintText: "From",
                            labelText: "From",
                            dateValue: fromDate.value,
                            firstDate: firstDate,
                            lastDate: lastDate,
                            onDateChange: (val) {
                              fromDate.value = val; 
                              ref.read(listBarcodeStateProvider.notifier).list(
                                    filter: selectedFilter.value.code,
                                    search: ctrlSearch.text,
                                    from : fromDate.value,
                                    to: toDate.value,
                                  );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: FxDateField(
                            hintText: "To",
                            labelText: "To",
                            dateValue: toDate.value,
                            firstDate: firstDate,
                            lastDate: lastDate,
                            onDateChange: (val){
                              toDate.value = val;   
                              ref.read(listBarcodeStateProvider.notifier).list(
                                    filter: selectedFilter.value.code,
                                    search: ctrlSearch.text,
                                    from : fromDate.value,
                                    to: toDate.value,
                                  );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: FxFilterLk(
                            labelText: "Filter",
                            labelLength: 40,
                            hintText: "Filter",
                            initialValue: FilterModel("all", "All"),
                            onChanged: (value) {
                              selectedFilter.value = value;
                              ref.read(listBarcodeStateProvider.notifier).list(
                                    filter: selectedFilter.value.code,
                                    search: ctrlSearch.text,
                                    from : fromDate.value,
                                    to: toDate.value,
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                const _BarcodeHeader(),
                const Divider(color: Constants.greenDark, thickness: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: listBarcode.value.length,
                    itemBuilder: (context, idx) {
                      final model = listBarcode.value[idx];
                      return _BarcodeDisplay(
                        model: model,
                        isOdd: idx % 2 == 1,
                        onTap: () {
                          if (model.action == "split") {
                            Navigator.of(context).pushNamed(splitMaterialRoute,
                                arguments: model.id);
                          } else if (model.action == "merge") {
                            if (model.id != null) {
                              selectedMergeMaterialID.value = model.id;
                              ref
                                  .read(mergeByIDStateProvider.notifier)
                                  .list(mergeMaterialID: model.id!);
                              Navigator.of(context).pushNamed(
                                  mergeListMaterialRoute,
                                  arguments: model.id);
                            }
                          }
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarcodeDisplay extends StatelessWidget {
  final SplitMergeResponse model;

  final bool isOdd;
  final void Function()? onTap;
  const _BarcodeDisplay({
    Key? key,
    required this.model,
    required this.isOdd,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sdf = DateFormat("yyyy-MM-dd");
    String fdate = model.date ?? "";
    try {
      fdate = DateFormat("dd/MM/yy").format(sdf.parse(model.date ?? ""));
    } catch (_) {}
    String act = "Split";
    if (model.action == "merge") {
      act = "Merge";
    }
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
              SizedBox(width: 80, child: FxBlackText(title: fdate)),
              // const SizedBox(width: 10),
              // SizedBox(
              //     width: 150,
              //     child: FxBlackText(title: model.oldBarcode ?? "")),
              const SizedBox(width: 30),
              SizedBox(width: 150, child: FxBlackText(title: act)),
              const SizedBox(width: 10),
              InkWell(
                  onTap: () {
                    if (model.action == "split") {
                      if (model.id != null) {
                        final snow = "&t=${DateTime.now().toIso8601String()}";
                        String jSplit = model.id!;
                        final url =
                            "https://${Constants.host}/reports/split_material.php?c=$jSplit$snow";
                        if (kIsWeb) {
                          html.window.open(url, 'rpttab');
                          return;
                        }
                      }
                    } else if (model.action == "merge") {
                      if (model.id != null) {
                        final snow = "&t=${DateTime.now().toIso8601String()}";
                        String jSplit = model.id!;
                        final url =
                            "https://${Constants.host}/reports/merge_material.php?c=$jSplit$snow";
                        if (kIsWeb) {
                          html.window.open(url, 'rpttab');
                          return;
                        }
                      }
                    }
                  },
                  child: Image.asset("images/icon_printer.png", width: 24)),
              // SizedBox(
              //     width: 150, child: FxBlackText(title: model.barcode ?? "")),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarcodeHeader extends StatelessWidget {
  const _BarcodeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      SizedBox(width: 80, child: FxGreenDarkText(title: "Date")),
      // SizedBox(width: 10),
      // SizedBox(width: 150, child: FxGreenDarkText(title: "Old Barcode")),
      SizedBox(width: 30),
      SizedBox(width: 150, child: FxGreenDarkText(title: "Activity")),
      SizedBox(width: 10),
      SizedBox(width: 40, child: FxGreenDarkText(title: "")),
    ]);
  }
}
