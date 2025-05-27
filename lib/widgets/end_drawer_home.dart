import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/app/app_route.dart';

import '../app/constants.dart';
import '../screen/login/login_provider.dart';
import 'end_drawer.dart';

class EndDrawerHome extends ConsumerWidget {
  const EndDrawerHome({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double vSpace = 5.0;
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
            const SizedBox(height: vSpace),
            FxItemMenuDrawer(
                imageString: "images/icon_password.png",
                title: "Change Password",
                onPress: () {
                  Navigator.of(context).pop();
                  //Navigator.of(context).pushNamed(ChangePasswordRoute);
                }),
            const SizedBox(height: vSpace),
            FxItemMenuDrawer(
                imageString: "images/icon_logout.png",
                title: "Logout",
                onPress: () async {
                  ref.read(loginStateProvider.notifier).logout();
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (args) => false);
                }),
          ],
        ),
      ),
    );
  }
}
