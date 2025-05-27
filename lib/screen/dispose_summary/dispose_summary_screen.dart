import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/dispose_slip_model.dart';
import 'package:sor_inventory/screen/dispose_summary/dispose_list_param_provider.dart';
import 'package:sor_inventory/screen/dispose_summary/dispose_list_slip_provider.dart';
import 'package:sor_inventory/widgets/fx_store_lk.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';

class DisposeSummaryScreen extends HookConsumerWidget {
  const DisposeSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);

    final isLoading = useState(false);
    final errorMessage = useState("");
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listDispose = useState<List<DisposeSlipModel>>(List.empty());
    final ctrlSearch = useTextEditingController(text: "");

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

    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref
            .read(disposeListSlipStateProvider.notifier)
            .list(storeID: "0", search: "");
      });
    }
    ref.listen(disposeListSlipStateProvider, (prev, next) {
      if (next is DisposeListSlipStateLoading) {
        isLoading.value = true;
      } else if (next is DisposeListSlipStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is DisposeListSlipStateDone) {
        listDispose.value = next.list;
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
          "Material Disposal Summary",
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
                        child: FxStoreLk(
                          labelText: "Store",
                          hintText: "Store",
                          withAll: true,
                          onChanged: (value) {
                            selectedStore.value = {
                              "id": value.storeID,
                              "name": value.storeName,
                            };
                            ref
                                    .read(disposeListParamSearchProvider.notifier)
                                    .state =
                                DisposeSearchParamModel(
                                    value.storeID ?? "0", ctrlSearch.text);
                            ref
                                .read(disposeListSlipStateProvider.notifier)
                                .list(
                                  storeID: value.storeID ?? "0",
                                  search: ctrlSearch.text,
                                );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      FxTextField(
                        ctrl: ctrlSearch,
                        labelText: "Search Slip No",
                        contentPadding: EdgeInsets.all(20),
                        hintText: "Search Slip No",
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (v) {
                          ref
                                  .read(disposeListParamSearchProvider.notifier)
                                  .state =
                              DisposeSearchParamModel(
                                  selectedStore.value?["id"] ?? "0",
                                  ctrlSearch.text);
                          ref.read(disposeListSlipStateProvider.notifier).list(
                                storeID: selectedStore.value?["id"] ?? "0",
                                search: ctrlSearch.text,
                              );
                        },
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
                const _DisposeHeader(),
                const Divider(color: Constants.greenDark, thickness: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: listDispose.value.length,
                    itemBuilder: (context, idx) {
                      final model = listDispose.value[idx];
                      return _DisposeDisplay(
                        model: model,
                        isOdd: idx % 2 == 1,
                        onTap: () {
                          Navigator.of(context).pushNamed(disposeMaterialRoute,
                              arguments: model.scrapDisposeSlipNo);
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

class _DisposeHeader extends StatelessWidget {
  const _DisposeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Expanded(flex: 10, child: FxGreenDarkText(title: "Date")),
      SizedBox(width: 10),
      Expanded(flex: 20, child: FxGreenDarkText(title: "Slip No")),
      SizedBox(width: 10),
      Expanded(flex: 20, child: FxGreenDarkText(title: "Store")),
    ]);
  }
}

class _DisposeDisplay extends StatelessWidget {
  const _DisposeDisplay({
    Key? key,
    required this.model,
    required this.isOdd,
    this.onTap,
  }) : super(key: key);

  final DisposeSlipModel model;
  final bool isOdd;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final sdf = DateFormat("yyyy-MM-dd");
    String fdate = model.scrapDisposeDate ?? "";
    try {
      fdate = DateFormat("dd/MM/yy")
          .format(sdf.parse(model.scrapDisposeDate ?? ""));
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
              Expanded(flex: 10, child: FxBlackText(title: fdate)),
              const SizedBox(width: 10),
              Expanded(
                  flex: 30,
                  child: FxBlackText(title: model.scrapDisposeSlipNo ?? "")),
              const SizedBox(width: 10),
              Expanded(
                  flex: 20, child: FxBlackText(title: model.storeName ?? "")),
            ],
          ),
        ),
      ),
    );
  }
}
