import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sor_inventory/model/materialmd_model.dart';
import 'package:sor_inventory/model/vendor_material_model.dart';
import 'package:sor_inventory/screen/checkout_summary/checkout_summary_screen.dart';
import 'package:sor_inventory/screen/dispose/dispose_screen.dart';
import 'package:sor_inventory/screen/dispose_summary/dispose_summary_screen.dart';
import 'package:sor_inventory/screen/home/homev3_screen.dart';
import 'package:sor_inventory/screen/list_barcode/list_barcode_screen.dart';
import 'package:sor_inventory/screen/material_md/material_md_edit_screen.dart';
import 'package:sor_inventory/screen/material_md/material_md_screen.dart';
import 'package:sor_inventory/screen/merge/merge_list_screen.dart';
import 'package:sor_inventory/screen/merge/merge_screen.dart';
import 'package:sor_inventory/screen/mr_auto/mr_auto_screen.dart';
import 'package:sor_inventory/screen/mr_manual/mr_manual_screen.dart';
import 'package:sor_inventory/screen/mr_summary/mr_summary_screen.dart';
import 'package:sor_inventory/screen/split/split_screen.dart';
import 'package:sor_inventory/screen/split_list/split_list_screen.dart';
import 'package:sor_inventory/screen/store/store_edit_screen.dart';
import 'package:sor_inventory/screen/store/store_screen.dart';
import 'package:sor_inventory/screen/tx_in/tx_in_screen.dart';
import 'package:sor_inventory/screen/vendor/vendor_edit_screen.dart';
import 'package:sor_inventory/screen/vendor_material/vendor_material_screen.dart';

import '../model/store_model.dart';
import '../model/vendor_model.dart';
import '../screen/checkin/checkin_screen.dart';
import '../screen/checkin_scan/checkin_scan_screen.dart';
import '../screen/checkout/checkout_screen.dart';
import '../screen/do/do_receive_screen.dart';
import '../screen/home/home_screen.dart';
import '../screen/home/sub_home_screen.dart';
import '../screen/list_do/list_do_screen.dart';
import '../screen/login/login_screen.dart';
import '../screen/material_return/material_return_screen.dart';
import '../screen/material_status/material_status_screen.dart';
import '../screen/po/po_screen.dart';
import '../screen/po_summary/po_summary_screen.dart';
import '../screen/stock_take/stock_take_screen.dart';
import '../screen/stock_take_history/stock_take_history_screen.dart';
import '../screen/stock_take_menu_screen/stock_take_menu_screen.dart';
import '../screen/stock_take_summary/stock_take_summary_screen.dart';
import '../screen/tx_out/tx_out_screen.dart';
import '../screen/tx_sum/tx_sum_screen.dart';
import '../screen/vendor/vendor_screen.dart';
import '../screen/vendor_material/vendor_material_edit_screen.dart';
import '../widgets/fx_pdf_viewer.dart';

const loginRoute = "/loginScreen";
const homeRoute = "/homeScreen";
const homeV3Route = "/homeV3Screen";
const subHomeRoute = "/subHomeRoute";
const doListRoute = "/doListScreen";
const doRoute = "/doReceiveScreen";
const pdfViewer = "/pdfViewer";
const checkinRoute = "/checkinRoute";
const checkinScan = "/checkinScan";
const checkoutRoute = "/checkoutRoute";
const poRoute = "/poRoute";
const poSummaryRoute = "/poSummaryRoute";
const stockTakeMenuRoute = "/stockTakeMenuRoute";
const stockTakeRoute = "/stockTakeRoute";
const stockTakeHistoryRoute = "/stockTakeHistoryRoute";
const stockTakeSummaryRoute = "/stockTakeSummaryRoute";

const materialReturnRoute = "/materialReturnRoute";

const materialStatusRoute = "/materialStatusRoute";
const vendorRoute = "/vendorRoute";
const vendorEditRoute = "/vendorEditRoute";
const vendorMaterialRoute = "/vendorMaterialRoute";
const vendorMaterialEditRoute = "/vendorMaterialEditRoute";
const materialMdRoute = "/materialMdRoute";
const materialMdEditRoute = "/materialMdEditRoute";

const splitMaterialRoute = "/splitMaterialRoute";
const splitMaterialListRoute = "/listSplitMaterialRoute";

const mergeMaterialRoute = "/mergeMaterialRoute";
const mergeListMaterialRoute = "/mergeListMaterialRoute";

const checkoutSummaryRoute = "/checkoutSummaryRoute";
const mrSummaryRoute = "/mrSummaryRoute";

const listBarcodeRoute = "/listBarcodeRoute";
const mrAutoRoute = "/mrAutoRoute";
const mrManualRoute = "/mrManualRoute";

const storeRoute = "/storeRoute";
const storeEditRoute = "/storeEditRoute";

const disposeMaterialRoute = "/disposeMaterialRoute";
const disposeMaterialSummaryRoute = "/disposeMaterialSummaryRoute";

const transferSummaryRoute = "/transferSum";
const transferOutRoute = "/transferOut";
const transferInRoute = "/transferIn";

class AppRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == transferSummaryRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: TxSumScreen(),
        ),
      );
    }
    if (settings.name == transferInRoute) {
      var slipNo = "";
      if (settings.arguments != null) {
        slipNo = settings.arguments as String;
      }
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: TxInScreen(materialSlipNo: slipNo),
        ),
      );
    }
    if (settings.name == transferOutRoute) {
      var slipNo = "";
      if (settings.arguments != null) {
        slipNo = settings.arguments as String;
      }
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: TxOutScreen(materialSlipNo: slipNo),
        ),
      );
    }
    if (settings.name == subHomeRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: SubHomeScreen(),
        ),
      );
    }
    if (settings.name == disposeMaterialSummaryRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: DisposeSummaryScreen(),
        ),
      );
    }
    if (settings.name == disposeMaterialRoute) {
      var slipNo = "";
      if (settings.arguments != null) {
        slipNo = settings.arguments as String;
      }
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: DisposeScreen(
            slipNo: slipNo,
          ),
        ),
      );
    }
    if (settings.name == splitMaterialListRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: SplitListScreen(),
        ),
      );
    }
    if (settings.name == storeRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: StoreScreen(),
        ),
      );
    }
    if (settings.name == storeEditRoute) {
      bool isNew = false;
      String query = "";
      StoreModel? store;
      try {
        var prm = settings.arguments as Map<String, dynamic>;
        isNew = prm["isNew"];
        query = prm["query"];
        store = prm["store"];
      } catch (_) {}

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: StoreEditScreen(
            isNew: isNew,
            query: query,
            store: store,
          ),
        ),
      );
    }
    if (settings.name == listBarcodeRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: ListBarcodeScreen(),
        ),
      );
    }
    if (settings.name == mrSummaryRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: MrSummaryScreen(),
        ),
      );
    }
    if (settings.name == mergeListMaterialRoute) {
      String? mergeMaterialID;
      try {
        mergeMaterialID = settings.arguments as String;
      } catch (_) {}
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: MergeListScreen(mergeMaterialID: mergeMaterialID),
        ),
      );
    }
    if (settings.name == checkoutSummaryRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: CheckoutSummaryScreen(),
        ),
      );
    }
    if (settings.name == mergeMaterialRoute) {
      String? mergeMaterialID;
      try {
        mergeMaterialID = settings.arguments as String;
      } catch (_) {}
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: MergeScreen(
            mergeMaterialID: mergeMaterialID,
          ),
        ),
      );
    }

    if (settings.name == materialMdRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: MaterialMdScreen(),
        ),
      );
    }
    if (settings.name == splitMaterialRoute) {
      String? splitMaterialID;
      try {
        splitMaterialID = settings.arguments as String;
      } catch (_) {}
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: SplitScreen(
            splitMaterialID: splitMaterialID,
          ),
        ),
      );
    }
    if (settings.name == materialMdEditRoute) {
      final Map<String, dynamic> param =
          settings.arguments as Map<String, dynamic>;
      MaterialMdModel materialMd = param["materialMd"] as MaterialMdModel;
      String query = param["query"] as String? ?? "";

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: MaterialMdEditScreen(
            materialMd: materialMd,
            query: query,
          ),
        ),
      );
    }
    if (settings.name == vendorMaterialEditRoute) {
      final Map<String, dynamic> param =
          settings.arguments as Map<String, dynamic>;
      VendorModel vendor = param["vendor"] as VendorModel;
      VendorMaterialModel material = param["material"] as VendorMaterialModel;
      String query = param["query"] as String? ?? "";

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: VendorMaterialEditScreen(
            vendor: vendor,
            material: material,
            query: query,
          ),
        ),
      );
    }
    if (settings.name == vendorEditRoute) {
      final Map<String, dynamic> param =
          settings.arguments as Map<String, dynamic>;
      bool isNew = param["isNew"] ?? true;
      String query = param["query"] ?? "";
      VendorModel? vendor;
      if (param["vendor"] != null) {
        vendor = param["vendor"] as VendorModel;
      }

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: VendorEditScreen(
            isNew: isNew,
            query: query,
            vendor: vendor,
          ),
        ),
      );
    }
    if (settings.name == vendorMaterialRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: const VendorMaterialScreen(),
        ),
      );
    }
    if (settings.name == vendorRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: const VendorScreen(),
        ),
      );
    }

    if (settings.name == materialStatusRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: const MaterialStatusScreen(),
        ),
      );
    }
    if (settings.name == materialReturnRoute) {
      var slipNo = "";
      if (settings.arguments != null) {
        slipNo = settings.arguments as String;
      }

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: MaterialReturnScreen(mrSlipNo: slipNo),
        ),
      );
    }
    if (settings.name == mrManualRoute) {
      var slipNo = "";
      if (settings.arguments != null) {
        slipNo = settings.arguments as String;
      }

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: MrManualScreen(mrSlipNo: slipNo),
        ),
      );
    }
    if (settings.name == mrAutoRoute) {
      var slipNo = "";
      if (settings.arguments != null) {
        slipNo = settings.arguments as String;
      }

      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: MrAutoScreen(mrSlipNo: slipNo),
        ),
      );
    }
    if (settings.name == stockTakeRoute) {
      bool isContinue = settings.arguments as bool;
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: StockTakeScreen(isContinue: isContinue),
        ),
      );
    }

    if (settings.name == stockTakeSummaryRoute) {
      Map<String, dynamic> param = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: StockTakeSummaryScreen(
              isCurrent: param["isCurrent"],
              id: param["id"],
              date: param["date"]),
        ),
      );
    }
    if (settings.name == stockTakeHistoryRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: StockTakeHistoryScreen(),
        ),
      );
    }
    if (settings.name == stockTakeMenuRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: const StockTakeMenuScreen(),
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
    if (settings.name == poSummaryRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: const PoSummaryScreen(),
        ),
      );
    }

    if (settings.name == poRoute) {
      bool fromPoSummary = false;
      if (settings.arguments != null && (settings.arguments as bool) == true) {
        fromPoSummary = true;
      }
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: PoScreen(
            fromSummary: fromPoSummary,
          ),
        ),
      );
    }
    if (settings.name == checkoutRoute) {
      var slipNo = "";
      if (settings.arguments != null) {
        slipNo = settings.arguments as String;
      }
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: CheckOutScreen(
            materialSlipNo: slipNo,
          ),
        ),
      );
    }
    if (settings.name == checkinScan) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: const CheckInScanScreen(),
        ),
      );
    }
    if (settings.name == checkinRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: const CheckInScreen(),
        ),
      );
    }
    if (settings.name == pdfViewer) {
      final String url = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: FxPdfViewer(url: url),
        ),
      );
    }
    if (settings.name == doListRoute) {
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: const ListDoScreen(),
        ),
      );
    }
    if (settings.name == doRoute) {
      bool fromSummary;
      try {
        fromSummary = settings.arguments as bool;
      } catch (_) {
        fromSummary = false;
      }
      return MaterialPageRoute(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: DoReceiveScreen(fromSummary: fromSummary),
        ),
      );
    }
    return MaterialPageRoute(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: const LoginScreen(),
      ),
    );
  }
}
