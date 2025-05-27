import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/contractor_lookup_model.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../model/tx_sum_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_green_dark_text.dart';
// import '../../widgets/fx_store_lk.dart';
import '../login/login_provider.dart';
import 'tx_sum_list_provider.dart';

class TxSumScreen extends HookConsumerWidget {
  const TxSumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);

    final isLoading = useState(false);
    final errorMessageLoadDo = useState("");
    final selectedContractor = useState<ContractorLookupModel?>(null);
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listSum = useState<List<TxSumModel>>(List.empty());

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
        ref.read(txSumListStateProvider.notifier).list();
      });
    }
    ref.listen(txSumListStateProvider, (prev, next) {
      if (next is TxSumListStateLoading) {
        isLoading.value = true;
      } else if (next is TxSumListStateError) {
        isLoading.value = false;
        errorMessageLoadDo.value = next.message;
      } else if (next is TxSumListStateDone) {
        listSum.value = next.list;
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
          "Transfer Summary",
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
                // SizedBox(
                //   width: filterWidth,
                //   child: Expanded(
                //     child: FxStoreLk(
                //         withAll: true,
                //         isGrey: false,
                //         labelText: "Store Location",
                //         hintText: "Select Store",
                //         readOnly: false,
                //         onChanged: (model) {
                //           selectedStore.value = {
                //             "id": model.storeID,
                //             "name": model.storeName
                //           };
                //           ref.read(mrListStateProvider.notifier).list(
                //                 cpID: selectedContractor.value?.cpId ?? "0",
                //                 soID: selectedContractor.value?.staffId ??
                //                     "0",
                //                 storeID: model.storeID ?? "0",
                //               );
                //         }),
                //   ),
                // ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                const _TxSumHeader(),
                const Divider(color: Constants.greenDark, thickness: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: listSum.value.length,
                    itemBuilder: (context, idx) {
                      final model = listSum.value[idx];
                      return _TxSumDisplay(
                        model: model,
                        isOdd: idx % 2 == 1,
                        onTap: () {
                          if (model.type == "In") {
                            Navigator.of(context).pushNamed(transferInRoute,
                                arguments: model.slipNo);
                          } else if (model.type == "Out") {
                            Navigator.of(context).pushNamed(transferOutRoute,
                                arguments: model.slipNo);
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

class _TxSumHeader extends StatelessWidget {
  const _TxSumHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Expanded(flex: 20, child: FxGreenDarkText(title: "Date")),
      SizedBox(width: 10),
      Expanded(flex: 15, child: FxGreenDarkText(title: "Type")),
      SizedBox(width: 10),
      Expanded(flex: 30, child: FxGreenDarkText(title: "From")),
      SizedBox(width: 10),
      Expanded(flex: 30, child: FxGreenDarkText(title: "To")),
      SizedBox(width: 10),
      Expanded(flex: 50, child: FxGreenDarkText(title: "Slip No")),
      SizedBox(width: 10),
      Expanded(flex: 20, child: FxGreenDarkText(title: "Status")),
    ]);
  }
}

class _TxSumDisplay extends StatelessWidget {
  const _TxSumDisplay({
    Key? key,
    required this.model,
    required this.isOdd,
    this.onTap,
  }) : super(key: key);

  final TxSumModel model;
  final bool isOdd;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final sdf = DateFormat("yyyy-MM-dd");
    String fdate = model.xDate;
    try {
      fdate = DateFormat("dd/MM/yy").format(sdf.parse(model.xDate));
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
              Expanded(flex: 20, child: FxBlackText(title: fdate)),
              const SizedBox(width: 10),
              Expanded(flex: 15, child: FxBlackText(title: model.type)),
              const SizedBox(width: 10),
              Expanded(flex: 30, child: FxBlackText(title: model.storeName)),
              const SizedBox(width: 10),
              Expanded(flex: 30, child: FxBlackText(title: model.toStoreName)),
              const SizedBox(width: 10),
              Expanded(flex: 50, child: FxBlackText(title: model.slipNo)),
              const SizedBox(width: 10),
              Expanded(flex: 20, child: FxBlackText(title: model.status)),
            ],
          ),
        ),
      ),
    );
  }
}
