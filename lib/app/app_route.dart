import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sor_inventory/screen/client/client_edit_screen.dart';
import 'package:sor_inventory/screen/product/product_edit_screen.dart';

import '../model/client_model.dart';
import '../model/product_model.dart';
import '../screen/client/client_screen.dart';
import '../screen/home/home_screen.dart';
import '../screen/home/homev3_screen.dart';
import '../screen/home/sub_home_screen.dart';
import '../screen/login/login_screen.dart';
import '../screen/product/product_screen.dart';

const loginRoute = "/loginScreen";
const homeRoute = "/homeScreen";
const homeV3Route = "/homeV3Screen";
const subHomeRoute = "/subHomeRoute";
const clientRoute = "/clientRoute";
const clientEditRoute = "/clientEditRoute";

const productRoute = "/productRoute";
const productEditRoute = "/productEditRoute";

class AppRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == subHomeRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: SubHomeScreen(),
        ),
      );
    }
    if (settings.name == productRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: ProductScreen(),
        ),
      );
    }
    if (settings.name == productEditRoute) {
      final args = settings.arguments as Map<String, dynamic>?;
      final product = args?['product'] as ProductModel?;
      final query = (args?['query'] ?? "") as String;

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: ProductEditScreen(product: product!, query: query),
        ),
      );
    }
    if (settings.name == clientRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: ClientScreen(),
        ),
      );
    }

    if (settings.name == clientEditRoute) {
      final args = settings.arguments as Map<String, dynamic>?;
      final client = args?['client'] as ClientModel?;
      final query = (args?['query'] ?? "") as String;

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: ClientEditScreen(client: client!, query: query),
        ),
      );
    }
    if (settings.name == homeRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: HomeScreen(),
        ),
      );
    }

    if (settings.name == homeV3Route) {
      return MaterialPageRoute(builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: LayoutBuilder(
            builder: (context, constraint) {
              // if (constraint.maxWidth <= 500) {
              return Homev3Screen();
              // }
              // return HomeScreen();
            },
          ),
        );
      });
    }
    return MaterialPageRoute(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: const LoginScreen(),
      ),
    );
  }
}
