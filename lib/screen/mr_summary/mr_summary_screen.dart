import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/contractor_lookup_model.dart';
import 'package:sor_inventory/model/mr_model_v2.dart';
import 'package:sor_inventory/screen/mr_summary/mr_summary_list_provider.dart';
import 'package:sor_inventory/widgets/fx_contractor_lk.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_auto_completion_vendor.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_store_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';

class MrSummaryScreen extends HookConsumerWidget {
  const MrSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);

    final ctrlDoNumber = useTextEditingController(text: "");
    final ctrlPoNumber = useTextEditingController(text: "");
    final isLoading = useState(false);
    final errorMessageLoadDo = useState("");
    final selectedContractor = useState<ContractorLookupModel?>(null);
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listMr = useState<List<MrListModel>>(List.empty());

    final ctrlScheme = useTextEditingController(text: "");
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
        ref.read(mrListStateProvider.notifier).list(
              cpID: "",
              soID: "",
              search: ctrlScheme.text,
            );
      });
    }
    Timer? debounce;

    void onSchemeChanged() {
      if (debounce?.isActive ?? false) debounce!.cancel();
      // Start a new timer
      debounce = Timer(const Duration(milliseconds: 350), () {
        ref.read(mrListStateProvider.notifier).list(
              cpID: selectedContractor.value?.cpId ?? "0",
              soID: selectedContractor.value?.staffId ?? "0",
              storeID: selectedStore.value?["id"] ?? "0",
              search: ctrlScheme.text,
            );
      });
    }

    ref.listen(mrListStateProvider, (prev, next) {
      if (next is MrListStateLoading) {
        isLoading.value = true;
      } else if (next is MrListStateError) {
        isLoading.value = false;
        errorMessageLoadDo.value = next.message;
      } else if (next is MrListStateDone) {
        isLoading.value = false;
        listMr.value = next.list;
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
          "Material Return Summary",
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
          width: kIsWeb ? 1024 : MediaQuery.of(context).size.width - 20,
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
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: FxTextField(
                            labelText: "Scheme/Project No",
                            hintText: "Scheme/Project No",
                            onChanged: (qry) {
                              onSchemeChanged();
                            },
                            prefix: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                "images/icon_search_70.png",
                                width: 20,
                              ),
                            ),
                            ctrl: ctrlScheme,
                            contentPadding: EdgeInsets.only(
                              top: 16,
                              bottom: 18,
                              left: 10,
                              right: 10,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FxContractorLk(
                          labelText: "Contractor",
                          hintText: "Contractor",
                          withAll: true,
                          onChanged: (value) {
                            selectedContractor.value = value;
                            ref.read(mrListStateProvider.notifier).list(
                                search: ctrlScheme.text,
                                cpID: value.cpId,
                                soID: value.staffId,
                                storeID: selectedStore.value?["id"] ?? "0");
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
                            labelText: "Store",
                            hintText: "Store",
                            readOnly: false,
                            onChanged: (model) {
                              selectedStore.value = {
                                "id": model.storeID,
                                "name": model.storeName
                              };
                              ref.read(mrListStateProvider.notifier).list(
                                    search: ctrlScheme.text,
                                    cpID: selectedContractor.value?.cpId ?? "0",
                                    soID: selectedContractor.value?.staffId ??
                                        "0",
                                    storeID: model.storeID ?? "0",
                                  );
                            }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                const _MrHeader(),
                const Divider(color: Constants.greenDark, thickness: 1),
                Expanded(
                    child: Stack(
                  children: [
                    ListView.builder(
                        itemCount: listMr.value.length,
                        itemBuilder: (context, idx) {
                          final model = listMr.value[idx];
                          return _MrDisplay(
                            model: model,
                            isOdd: idx % 2 == 1,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  materialReturnRoute,
                                  arguments: model.mrSlipNo);
                            },
                          );
                        }),
                    if (isLoading.value)
                      const Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MrHeader extends StatelessWidget {
  const _MrHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Expanded(flex: 8, child: FxGreenDarkText(title: "Date")),
      SizedBox(width: 10),
      Expanded(flex: 12, child: FxGreenDarkText(title: "Project No")),
      SizedBox(width: 10),
      Expanded(flex: 23, child: FxGreenDarkText(title: "Scheme")),
      SizedBox(width: 10),
      Expanded(flex: 12, child: FxGreenDarkText(title: "Contractor")),
      SizedBox(width: 10),
      Expanded(flex: 10 + 5, child: FxGreenDarkText(title: "SO")),
      SizedBox(width: 10),
      Expanded(flex: 15, child: FxGreenDarkText(title: "Slip No")),
      SizedBox(width: 10),
      Expanded(flex: 16, child: FxGreenDarkText(title: "Store")),
      SizedBox(width: 15),
    ]);
  }
}

class _MrDisplay extends StatelessWidget {
  const _MrDisplay({
    Key? key,
    required this.model,
    required this.isOdd,
    this.onTap,
  }) : super(key: key);

  final MrListModel model;
  final bool isOdd;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final sdf = DateFormat("yyyy-MM-dd");
    String fdate = model.mrDate ?? "";
    try {
      fdate = DateFormat("dd/MM/yy").format(sdf.parse(model.mrDate ?? ""));
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
              Expanded(flex: 8, child: FxBlackText(title: fdate)),
              const SizedBox(width: 10),
              Expanded(flex: 12, child: FxBlackText(title: model.projectNum ?? "")),
              const SizedBox(width: 10),
              Expanded(flex: 23, child: FxBlackText(title: model.scheme ?? "")),
              const SizedBox(width: 10),
              Expanded(flex: 12, child: FxBlackText(title: model.cpName ?? "")),
              const SizedBox(width: 10),
              Expanded(
                  flex: 10 + 5, child: FxBlackText(title: model.staffName ?? "")),
              const SizedBox(width: 10),
              Expanded(
                  flex: 15, child: FxBlackText(title: model.mrSlipNo ?? "")),
              const SizedBox(width: 10),
              Expanded(
                  flex: 16, child: FxBlackText(title: model.storeName ?? "")),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }
}
