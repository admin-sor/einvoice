import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/mobile_config_model.dart';

import '../app/app_route.dart';
import '../app/constants.dart';
import '../provider/setting_get_provider.dart';
import '../provider/setting_update_provider.dart';
import '../screen/login/login_provider.dart';

class EndDrawer extends HookConsumerWidget {
  final bool isHome;
  const EndDrawer({
    Key? key,
    this.isHome = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double vSpacing = 5.0;
    final mobileConfig = useState<MobileConfigModel?>(null);
    final isLoading = useState(false);
    final errorMessage = useState("");
    final isInit = useState(true);
    if (isInit.value) {
      isInit.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(settingGetProvider.notifier).get();
      });
    }
    ref.listen(settingGetProvider, (prev, next) {
      if (next is SettingGetStateLoading) {
        isLoading.value = true;
      } else if (next is SettingGetStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is SettingGetStateDone) {
        mobileConfig.value = next.model;
        isLoading.value = false;
      }
    });
    ref.listen(settingUpdateProvider, (prev, next) {
      if (next is SettingUpdateStateLoading) {
        isLoading.value = true;
      } else if (next is SettingUpdateStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is SettingUpdateStateDone) {
        mobileConfig.value = next.model;
        isLoading.value = false;
      }
    });
    return Drawer(
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                color: Constants.greenDark,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    Constants.appTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: vSpacing),
            FxItemMenuDrawer(
                imageString: "images/icon_home.png",
                title: "Home",
                onPress: () {
                  // Navigator.of(context).pop();
                  // if (!isHome) {
                  // Navigator.of(context).pop();
                  // }
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(homeV3Route, (route) => false);
                }),
            const SizedBox(height: vSpacing),
            // FxItemMenuDrawer(
            //     imageString: "images/icon_profile.png",
            //     title: "Profile",
            //     onPress: () {
            //       Navigator.of(context).pop();
            //       //Navigator.of(context).pushNamed(ChangePasswordRoute);
            //     }),
            // const SizedBox(height: vSpacing),
            FxItemMenuDrawer(
                imageString: "images/icon_setting.png",
                title: "Setting",
                onPress: () {
                  Navigator.of(context).pop();
                  //Navigator.of(context).pushNamed(ChangePasswordRoute);
                }),
            Row(
              children: [
                const SizedBox(width: 40),
                Text(
                  errorMessage.value == ""
                      ? "Auto PO Number"
                      : "Auto PO Err ${errorMessage.value}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: errorMessage.value == ""
                        ? Constants.greenDark
                        : Constants.red,
                  ),
                ),
                const SizedBox(width: 32),
                InkWell(
                  onTap: () {
                    if (mobileConfig.value == null) return;
                    final MobileConfigModel model = MobileConfigModel(
                      mobileConfigAutoPo:
                          mobileConfig.value!.mobileConfigAutoPo == "N"
                              ? "Y"
                              : "N",
                      mobileconfigID: mobileConfig.value!.mobileconfigID,
                    );
                    ref
                        .read(settingUpdateProvider.notifier)
                        .update(model: model);
                  },
                  child: isLoading.value
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Image.asset(
                          mobileConfig.value?.mobileConfigAutoPo == "Y"
                              ? "./images/icon_on.png"
                              : "./images/icon_off.png",
                          width: 32,
                          height: 32,
                        ),
                ),
              ],
            ),
            const SizedBox(height: vSpacing),
            FxItemMenuDrawer(
                imageString: "images/icon_logout.png",
                title: "Logout",
                onPress: () async {
                  ref.read(loginStateProvider.notifier).logout();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (args) => false);
                }),
          ],
        ),
      ),
    );
  }
}

class FxItemMenuDrawer extends StatelessWidget {
  final String title;
  final String imageString;
  final VoidCallback? onPress;
  const FxItemMenuDrawer({
    Key? key,
    required this.title,
    required this.imageString,
    this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: InkWell(
        onTap: onPress,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Row(children: [
            Image.asset(
              imageString,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Constants.greenDark,
                )),
          ]),
        ),
      ),
    );
  }
}
