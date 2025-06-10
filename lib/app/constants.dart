import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/*
dark 008a8d
normal 00b3b7
light b2e8e9

bgEntry e6f2f3

*/
final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

class Constants {
  //homev3
  static const Color colorHomeV3GreenDark = Color(0xff008a8d);
  static const Color colorHomeV3TextGray = Color(0xff606060);
  static const Color colorHomeV3GreenDark30 = Color(0x33545454);
  static const Color colorHomeV3TopBg = Color(0xffE6F1F0);
  static const paddingTopContent = 10.0;
  static const double kPadding = 10.0;
  //static const Color greenDark = Color(0xff5657fa);  blueish purple
  static const Color yellowDark = Color(0xffe2a624);
  static const Color grey = Color(0xfff9f9fb);
  static const Color greyDark = Color(0xff000000);
  static const Color greyLight = Color(0xffa4a4a4);

  static Color firstYellow = Colors.yellow.shade50;
  static Color buttonBlue = const Color.fromARGB(255, 100, 176, 211);

  static const Color greenDark = Color(0Xff008a8d);
  static const Color green = Color(0Xff00b3b7);
  static const Color blue = Color(0Xff4d77bb);
  static const Color greenLight = Color(0Xffb2e8e9);
  static const Color orange = Color(0XFFec8d2f);
  static const Color red = Color(0XFFf44336);
  static const Color colorAppBarBg = Color(0xfff9f9fb);
  static const Color colorIconDelete = Color(0xffd3d3d3);
  static const Color yellowLight = Color(0xfffffbd8);
  static const Color colorLoginBorderInactive = Colors.white54;

  static const Color blackTitle = Color(0Xff3b3b3b);
  static const Color colorAppBar = Color(0xff3b3b3b);

  static const Color textNotFromVendor = Color(0xff02a951);
  static String host = "tkdev.sor.my";
  /* static const host = "anddemo.sor.com.my"; */
  static String baseUrl = "https://$host/einvoice_api/";
  static String clientName = "clientName";
  static String reportUrl = "https://$host/einvoice_report/";

  static const Color buttonPositiveColor = Color(0xff65d372);
  static const fontExtraBigSize = 22.0;
  static const fontBigSize = 18.0;
  static const fontMediumSize = 16.0;
  static const fontSmallSize = 14.0;
  static String appTitle = "eInvoice";
  static String appSubTitle = "";
  static String appVersion = "v1.1";

  static const Color colorNegative = Color(0xff95424E);
  static const double webWidth = 800.0;
}
