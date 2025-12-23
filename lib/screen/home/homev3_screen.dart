import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/screen/invoice_v2/invoice_id_provider.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/screen_group_model.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_store_lk.dart';
import '../login/login_provider.dart';
import '../self_bill_screen/self_bill_id_provider.dart';
import 'screen_group_provider.dart';
import 'select_screen_group_provider.dart';

class Homev3Screen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final isInit = useState(true);

    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
        if (loginModel.value?.storeID != null) {
          selectedStore.value = {"id": loginModel.value!.storeID, "name": ""};
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
      return FlutterWebFrame(
        maximumSize: Size(450, MediaQuery.of(context).size.height),
        builder: (context) => Scaffold(
          body: Container(
            color: Colors.white,
          ),
        ),
      );
    }
    return FlutterWebFrame(
      maximumSize: Size(450, MediaQuery.of(context).size.height),
      builder: (context) => Scaffold(
        backgroundColor: Colors.white,
        endDrawer: const EndDrawer(isHome: true),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: Text(Constants.appTitle,
              style: TextStyle(
                color: Constants.colorHomeV3GreenDark,
                fontSize: 26.3,
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  const _HomeTitle(),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _HomeUserLocation(
                        name: loginModel.value?.name,
                        storeID: selectedStore.value?["id"]),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: MediaQuery.of(context).size.height - 160,
                    color: Constants.colorHomeV3TopBg,
                    child: Column(children: [
                      const SizedBox(height: 30),
                      const Row(
                        children: [
                          SizedBox(width: 30),
                          Expanded(
                            child: _CardGroupMenuFix(
                              title: "Invoice",
                              icon: "images/v3_po.png",
                              route: invoiceRoute,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _CardGroupMenuFix(
                              title: "Invoice Summary",
                              icon: "images/v3_do.png",
                              route: invoiceSumRoute,
                            ),
                          ),
                          SizedBox(width: 30),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const SizedBox(width: 30),
                          const Expanded(
                            child: _CardGroupMenuFix(
                              title: "Self Bill",
                              icon: "images/v3_po.png",
                              route: selfBillRoute,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: _CardGroupMenuFix(
                              title: "Self Bill Summary",
                              icon: "images/v3_do.png",
                              route: selfBillSumRoute,
                            ),
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ]),
              ),
            ),
            const _HomeV3Footer(),
          ],
        ),
      ),
    );
  }
}

class _HomeV3Footer extends StatelessWidget {
  const _HomeV3Footer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent.withOpacity(0.0),
      height: 70,
      child: const Padding(
        padding: EdgeInsets.only(left: 30.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              _FooterIcon(
                icon: "images/v3_home.png",
                text: "Home",
                color: Constants.colorHomeV3GreenDark,
              ),
              // _FooterIcon(
              //   icon: "images/v3_scan_icon.png",
              //   text: "Scan",
              //   withBg: true,
              // ),
              // _FooterIcon(icon: "images/v3_summary_icon.png", text: "Summary"),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterIcon extends StatelessWidget {
  final String icon;
  final String text;
  final bool withBg;
  final Color color;
  const _FooterIcon({
    super.key,
    required this.icon,
    required this.text,
    this.withBg = false,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    if (withBg) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            color: withBg ? Constants.colorHomeV3GreenDark : Colors.transparent,
            shape: BoxShape.circle,
          ),
          width: 70,
          height: 70,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  icon,
                  height: 23.5,
                  width: 23.5,
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: withBg ? Colors.white : color,
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            height: 30,
            width: 30,
          ),
          Text(
            text,
            style: TextStyle(
              color: withBg ? Colors.white : color,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }
}

class _CardGroupMenu extends HookConsumerWidget {
  final int idx;
  final List<ScreenGroupModel> models;
  const _CardGroupMenu({
    super.key,
    required this.idx,
    required this.models,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double height = 180;
    if (models.length <= idx) {
      return Container(height: height, color: Colors.transparent);
    }
    String title = models[idx].screenGroupName ?? "-";
    String icon = models[idx].screenGroupIcon ?? "";

    return _CardGroupMenuBase(
      title: title,
      icon: icon,
      onTap: () {
        ref.read(selectScreenGroupProvider.notifier).state = models[idx];
        var quick = models
            .where((x) => x.screenGroupID != models[idx].screenGroupID)
            .toList();
        ref.read(allScreenGroupProvider.notifier).state = models;
        ref.read(quickScreenGroupProvider.notifier).state = quick;
        Navigator.of(context).pushNamed(subHomeRoute);
      },
    );
  }
}

class _CardGroupMenuFix extends HookConsumerWidget {
  final String title;
  final String icon;
  final String route;
  const _CardGroupMenuFix({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CardGroupMenuBase(
      title: title,
      icon: icon,
      onTap: () {
        if (route == selfBillRoute) {
          ref.read(selfBillIDProvider.notifier).state = "0";
        }
        Navigator.of(context).pushNamed(route);
      },
    );
  }
}

class _CardGroupMenuBase extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  const _CardGroupMenuBase({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double height = 180;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Constants.colorHomeV3GreenDark,
          boxShadow: [
            BoxShadow(
              color: Constants.colorHomeV3GreenDark30,
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(5, 5), // changes position of shadow
            ),
          ],
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        height: height,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(icon, height: 80),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _HomeUserLocation extends StatelessWidget {
  const _HomeUserLocation({
    super.key,
    required this.name,
    required this.storeID,
  });

  final String? name;
  final String? storeID;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 20),
        Image.asset("images/v3_store_location.png", height: 45),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  name ?? "Not Login",
                  style: const TextStyle(
                    color: Constants.colorHomeV3TextGray,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.1,
                  ),
                ),
              ),
              FxStoreLkBare(
                initialValueId: storeID ?? "0",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeTitle extends StatelessWidget {
  const _HomeTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: SizedBox(
          child: Text(
            Constants.clientName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Constants.colorHomeV3TextGray,
              fontSize: 22.3,
            ),
          ),
        ),
      ),
    );
  }
}
