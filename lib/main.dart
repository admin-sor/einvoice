import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app/app_route.dart';
import 'app/constants.dart';
import 'provider/device_size_provider.dart';
import 'screen/login/login_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    ref.read(deviceSizeProvider.notifier).state = Size(width, height);
    if (kIsWeb) {
      final height = window.physicalSize.height;

      return FlutterWebFrame(
          maximumSize: Size(Constants.webWidth, height),
          enabled: kIsWeb,
          builder: (context) {
            return MaterialApp(
              title: Constants.appTitle,
              scrollBehavior: MyCustomScrollBehavior(),
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
                scaffoldBackgroundColor: Colors.white,
                canvasColor: Colors.white,
                primaryColor: Constants.green,
                splashColor: Constants.orange,
                brightness: Brightness.light,
              ),
              onGenerateRoute: AppRoute.generateRoute,
              home: const LoginScreen(),
            );
          });
    }
    return MaterialApp(
      title: Constants.appTitle,
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        primaryColor: Constants.green,
        splashColor: Constants.orange,
        brightness: Brightness.light,
      ),
      onGenerateRoute: AppRoute.generateRoute,
      home: const LoginScreen(),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
