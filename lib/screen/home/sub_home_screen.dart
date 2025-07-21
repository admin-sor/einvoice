import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/dynamic_screen_model.dart';
import 'package:sor_inventory/screen/invoice_v2/invoice_id_provider.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/screen_group_model.dart';
import '../../model/sor_user_model.dart';
import '../../model/stock_take_model.dart';
import '../../provider/device_size_provider.dart';
import '../../widgets/end_drawer.dart';
import '../login/login_provider.dart';
import '../tx_in/tx_in_acl_store_provider.dart';
import '../tx_in/tx_in_store_provider.dart';
import '../tx_in/user_all_store_provider.dart';
import 'active_screen_provider.dart';
import 'select_screen_group_provider.dart';

class SubHomeScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final isInit = useState(true);
    final selectedScreenGroup = ref.watch(selectScreenGroupProvider);
    final quickScreenGroup = ref.watch(quickScreenGroupProvider);
    final activeScreen = useState<List<DynamicScreenModel>>(List.empty());
    final stockTakeModel = useState<StockTakeModel?>(null);

    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
        if (loginModel.value?.storeID != null) {
          selectedStore.value = {"id": loginModel.value!.storeID, "name": ""};
        }
      }
      if (selectedScreenGroup?.screenGroupID != null) {
        ref
            .read(activeScreenStateProvider.notifier)
            .active(selectedScreenGroup!.screenGroupID!);
      }
    });

    ref.listen(activeScreenStateProvider, (prev, next) {
      if (next is ActiveScreenStateDone) {
        activeScreen.value = next.active;
      }
    });
    //no login
    if (loginModel.value == null) {
      if (isInit.value) {
        isInit.value = false;
        Timer(const Duration(milliseconds: 500), () {
          ref.read(loginStateProvider.notifier).checkLocalToken();
          ref.read(txInStoreStateProvider.notifier).list();
          ref.read(txInAclStoreStateProvider.notifier).list();
        });
      } else {
        Timer(const Duration(milliseconds: 500), () {
          isInit.value = true;
          Navigator.of(context)
              .pushNamedAndRemoveUntil(loginRoute, (args) => false);
        });
      }
      return FlutterWebFrame(
        maximumSize: Size(450, MediaQuery.of(context).size.height),
        builder: (context) => Scaffold(
          body: Container(
            color: Colors.white,
          ),
        ),
      );
    }
    final deviceSize = ref.read(deviceSizeProvider);

    ref.listen(txInStoreStateProvider, (prev, next) {
      if (next is TxInStoreStateLoading) {
      } else if (next is TxInStoreStateError) {
      } else if (next is TxInStoreStateDone) {
        ref.read(userAllStoreProvider.notifier).state = next.list;
      }
    });

    ref.listen(txInAclStoreStateProvider, (prev, next) {
      if (next is TxInAclStoreStateLoading) {
      } else if (next is TxInAclStoreStateError) {
      } else if (next is TxInAclStoreStateDone) {
        ref.read(userAclStoreProvider.notifier).state = next.list;
      }
    });
    return FlutterWebFrame(
      maximumSize: Size(450, MediaQuery.of(context).size.height),
      builder: (context) => Scaffold(
        endDrawer: const EndDrawer(isHome: true),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
              selectedScreenGroup?.screenGroupName?.replaceAll("\n", " ") ??
                  "Loading ...",
              style: const TextStyle(
                fontSize: 26.3,
                color: Constants.colorHomeV3GreenDark,
                fontWeight: FontWeight.bold,
              )),
          actions: [
            Builder(
              builder: (context) => InkWell(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    "images/icon_menu_blue.png",
                    width: 24,
                    height: 24,
                  ),
                ),
                onTap: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
          iconTheme: const IconThemeData(color: Constants.colorAppBar),
        ),
        body: Column(
          children: [
            Container(
              height: deviceSize.width < 600
                  ? deviceSize.height - 136
                  : MediaQuery.of(context).size.height - 136,
              color: Constants.colorHomeV3TopBg,
              child: SingleChildScrollView(
                child: Column(children: [
                  Container(
                    color: Colors.white,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Quick Actions",
                          style: TextStyle(
                            fontSize: 11.7,
                            color: Constants.colorHomeV3GreenDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 80,
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width + 500,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          if (quickScreenGroup != null &&
                              quickScreenGroup.isNotEmpty)
                            ...quickScreenGroup.map((x) {
                              String icon = x.screenGroupIcon ?? "";
                              icon = icon.replaceAll(".png", "_black.png");
                              return _QuickBox(icon: icon, model: x);
                            }).toList(),
                        ])),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 10),
                  if (activeScreen.value.isNotEmpty)
                    ...activeScreen.value.map((x) {
                      var icon = x.screenImage!.replaceAll(".png", "_v3.png");
                      return InkWell(
                        onTap: () {
                          if (x.screenRoute == "/invoiceRoute") {
                            ref.read(invoiceIDProvider.notifier).state = "0";
                          }
                          if (x.screenRoute == "/stockTakeRoute") {
                            bool isStockTakeInProgress = false;
                            if (stockTakeModel.value != null) {
                              isStockTakeInProgress = true;
                            }
                            Navigator.of(context).pushNamed(x.screenRoute!,
                                arguments: isStockTakeInProgress);
                          } else {
                            Navigator.of(context)
                                .pushNamed(x.screenRoute ?? "");
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: deviceSize.width < 600 ? 20.0 : 0.0,
                          ),
                          child: Container(
                            height: 100,
                            width: 400,
                            decoration: const BoxDecoration(
                              color: Constants.colorHomeV3GreenDark,
                              boxShadow: [
                                BoxShadow(
                                  color: Constants.colorHomeV3GreenDark30,
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(
                                      5, 5), // changes position of shadow
                                ),
                              ],
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                Image.asset(
                                  icon,
                                  height: 60,
                                  errorBuilder: (ctx, obj, st) => Container(
                                    width: 70,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      x.screenTitle ?? "=",
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                ]),
              ),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _QuickBox extends HookConsumerWidget {
  const _QuickBox({
    super.key,
    required this.icon,
    required this.model,
  });

  final String icon;
  final ScreenGroupModel model;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        var models = ref.read(allScreenGroupProvider);

        var quick = models
            ?.where((x) => x.screenGroupID != model.screenGroupID)
            .toList();
        ref.read(quickScreenGroupProvider.notifier).state = quick;
        ref
            .read(activeScreenStateProvider.notifier)
            .active(model.screenGroupID ?? "0");
        ref.read(selectScreenGroupProvider.notifier).state = model;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
            height: 150,
            width: 110,
            child: Column(
              children: [
                Image.asset(
                  icon,
                  height: 40,
                  errorBuilder: (context, obj, st) => Container(
                    width: 90,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Text(model.screenGroupName?.replaceAll("\n", " ") ?? ""),
              ],
            )),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacementNamed(homeV3Route);
      },
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.transparent,
            border: Border(
              top: BorderSide(color: Colors.grey, width: 1),
            )),
        height: 80,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  "images/v3_home.png",
                  width: 40,
                  height: 40,
                ),
                const Text(
                  "Home",
                  style: TextStyle(
                    color: Constants.colorHomeV3GreenDark,
                    fontSize: 14,
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
