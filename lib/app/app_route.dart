import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sor_inventory/screen/client/client_edit_screen.dart';
import 'package:sor_inventory/screen/invoice_screen/invoice_edit_screen.dart';
import 'package:sor_inventory/screen/invoice_screen/invoice_screen.dart';
import 'package:sor_inventory/screen/invoice_v2/invoice_v2_screen.dart';
import 'package:sor_inventory/screen/invoice_v2/invoice_v2_sum_screen.dart';
import 'package:sor_inventory/screen/product/product_edit_screen.dart';
import 'package:sor_inventory/screen/self_bill_screen/self_bill_screen.dart';
import 'package:sor_inventory/screen/self_bill_screen/self_bill_sum_screen.dart';

import '../model/client_model.dart';
import '../model/invoice_model.dart';
import '../model/invoice_v2_model.dart';
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

const invoiceRoute = "/invoiceRoute";
const invoiceEditRoute = "/invoiceEditRoute";
const invoiceSumRoute = "/invoiceSumRoute";

const invoiceEvRoute = "/invoiceV2Route";
const invoiceEvEditRoute = "/invoiceV2EditRoute";
const selfBillRoute = "/selfBillRoute";
const selfBillSumRoute = "/selfBillSumRoutexx";

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

    //InvoiceSumScreen
    if (settings.name == invoiceSumRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: InvoiceSummaryScreen(),
        ),
      );
    }
    if (settings.name == selfBillRoute) {
      final args = settings.arguments as Map<String, dynamic>?;
      final fromSummary = (args?['fromSummary'] ?? false) as bool;
      final invoiceModel = args?['invoiceModel'] as InvoiceModel?;
      final detail = args?['detail'] as List<InvoiceDetailModel>?;

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: SelfBillScreen(
            fromSummary: fromSummary,
            invoiceModel: invoiceModel,
            detail: detail,
          ),
        ),
      );
    }
    // if (settings.name == selfBillSumRoute) {
    //   return MaterialPageRoute(
    //     builder: (context) => MediaQuery(
    //       data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    //       child: const SelfBillSummaryScreen(),
    //     ),
    //   );
    // }
    //InvoiceScreen
    if (settings.name == invoiceRoute) {
      final args = settings.arguments as Map<String, dynamic>?;
      final invoiceModel = args?['model'] as InvoiceV2Model?;
      final fromSummary = (args?['fromSummary'] ?? false) as bool;
      final client = args?['client'] as ClientModel?;
      final startDate = (args?['startDate'] ?? "") as String;
      final endDate = (args?['endDate'] ?? "") as String;
      final detail = args?['detail'] as List<InvoiceDetailModel>?;

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: InvoiceV2Screen(
            fromSummary: fromSummary,
            startDate: startDate,
            endDate: endDate,
            client: client,
            invoiceModel: invoiceModel,
            detail: detail,
          ),
        ),
      );
    }
    if (settings.name == invoiceEditRoute) {
      final args = settings.arguments as Map<String, dynamic>?;
      final invoice = args?['invoice'] as InvoiceModel?;
      final query = (args?['query'] ?? "") as String;

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: InvoiceEditScreen(invoice: invoice!, query: query),
        ),
      );
    }
    if (settings.name == productRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: const ProductScreen(),
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
