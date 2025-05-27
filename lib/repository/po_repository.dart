import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../model/ac_material_model.dart';
import '../model/payment_term_response_model.dart';
import '../model/po_response_model.dart';
import '../model/po_summary_response_model.dart';
import '../widgets/fx_auto_completion_po.dart';
import '../widgets/fx_auto_completion_unit.dart';
import '../widgets/fx_auto_completion_vendor.dart';
import 'base_repository.dart';

class PoRepository extends BaseRepository {
  PoRepository({
    required dio,
  }) : super(dio: dio);

  Future<String> autoPo({
    required String vendorID,
  }) async {
    final resp = await postWoToken(
      param: {},
      service: "/po/auto_po/$vendorID",
    );
    return resp["poNo"];
  }

  Future<bool> checkPoNo({
    required String poNo,
  }) async {
    await postWoToken(
      param: {"poNo": poNo},
      service: "/po/check_po",
    );
    return true;
  }

  Future<bool> saveTerm({
    required String token,
    required String poID,
    required String vendorTerm,
  }) async {
    await post(
      token: token,
      param: {
        "poID": poID,
        "vendorTerm": vendorTerm,
      },
      service: "/po/saveTerm",
    );
    return true;
  }

  Future<bool> delete({
    required String token,
    required String poDetailID,
  }) async {
    await post(
      token: token,
      param: {"poDetailID": poDetailID},
      service: "/po/delete",
    );
    return true;
  }

  Future<List<PoSummaryResponseModel>> summary({
    required String search,
    required String vendorID,
    required String status,
    CancelToken? cancelToken,
  }) async {
    final param = {
      "search": search,
      "vendorID": vendorID,
      "status": status,
    };
    final resp = await postWoToken(
      param: param,
      service: "/po/summary",
      cancelToken: cancelToken,
    );
    final List<PoSummaryResponseModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(PoSummaryResponseModel.fromJson(e));
    });
    return list;
  }

  Future<List<DummyPo>> search({
    required String search,
    required String vendorID,
    CancelToken? cancelToken,
  }) async {
    final param = {
      "search": search,
      "vendorID": vendorID,
    };
    final resp = await postWoToken(
      param: param,
      service: "/sor_do/po_lookup_v2",
      cancelToken: cancelToken,
    );
    final List<DummyPo> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(DummyPo(
        id: int.parse(e["id"].toString()),
        poNo: e["po_no"],
      ));
    });
    return list;
  }

  Future<List<VendorModel>> vendorLookup({
    required String search,
    CancelToken? cancelToken,
  }) async {
    final param = {
      "search": search,
    };
    final resp = await postWoToken(
      param: param,
      service: "/po/vendor_lookup",
      cancelToken: cancelToken,
    );
    final List<VendorModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(VendorModel.fromJson(e));
    });
    return list;
  }

  Future<List<AcMaterialModel>> acMaterial({
    required String search,
    required String vendorID,
    required String poID,
    CancelToken? cancelToken,
  }) async {
    final param = {
      "search": search,
      "vendorID": vendorID,
      "poID": poID,
    };
    final resp = await postWoToken(
        param: param, service: "/po/material_lookup", cancelToken: cancelToken);
    final List<AcMaterialModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(AcMaterialModel.fromJson(e));
    });
    return list;
  }

  Future<List<UnitModel>> unitLookup({
    required String search,
    String isPack = "N",
    CancelToken? cancelToken,
  }) async {
    final param = {
      "search": search,
      "isPack": isPack,
    };
    final resp = await postWoToken(
      param: param,
      service: "/po/unit_lookup",
      cancelToken: cancelToken,
    );
    final List<UnitModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(UnitModel.fromJson(e));
    });
    return list;
  }

  Future<List<PaymentTermResponseModel>> paymentTermLookup({
    required String vendorID,
  }) async {
    final resp = await postWoToken(
      param: {"vendorID": vendorID},
      service: "/po/payment_term_lookup",
    );
    final List<PaymentTermResponseModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(PaymentTermResponseModel.fromJson(e));
    });
    return list;
  }

  Future<PoSaveResponseModel> get({
    required String poNo,
    required String vendorID,
    CancelToken? cancelToken,
  }) async {
    final param = {
      "poNo": poNo,
      "vendorID": vendorID,
    };
    final resp = await postWoToken(
      param: param,
      service: "/po/po_get",
      cancelToken: cancelToken,
    );
    final xdo = PoResponseModel.fromJson(resp["po"]);
    final List<PoDetailResponseModel> list = List.empty(growable: true);
    resp["detail"].forEach((e) {
      try {
        final detail = PoDetailResponseModel.fromJson(e);
        list.add(detail);
      } catch (_) {}
    });
    final result = PoSaveResponseModel(
      po: xdo,
      detail: list,
    );
    return result;
  }

  Future<PoSaveResponseModel> save({
    required DateTime date,
    required String poNo,
    required String storeID,
    required String vendorID,
    required DateTime deliveryDate,
    required String paymentTermID,
    required String paymentTermName,
    required String materialID,
    required String qty,
    required String packUnitID,
    required String price,
    required String packQty,
    required String token,
    required String fromVendor,
    String poID = "0",
    CancelToken? cancelToken,
  }) async {
    final sdf = DateFormat("yyyy-MM-dd");
    final sDate = sdf.format(date);
    final sDeliveryDate = sdf.format(deliveryDate);
    final param = {
      "date": sDate,
      "poID": poID,
      "poNo": poNo,
      "storeID": storeID,
      "vendorID": vendorID,
      "deliveryDate": sDeliveryDate,
      "paymentTermID": paymentTermID,
      "paymentTermName": paymentTermName,
      "materialID": materialID,
      "qty": qty,
      "packUnitID": packUnitID,
      "price": price,
      "packQty": packQty,
      "fromVendor": fromVendor,
    };
    final resp = await post(
      param: param,
      service: "/po/save",
      cancelToken: cancelToken,
      token: token,
    );
    final xdo = PoResponseModel.fromJson(resp["po"]);
    final List<PoDetailResponseModel> list = List.empty(growable: true);
    resp["detail"].forEach((e) {
      try {
        final detail = PoDetailResponseModel.fromJson(e);
        list.add(detail);
      } catch (_) {}
    });
    final result = PoSaveResponseModel(
      po: xdo,
      detail: list,
    );
    return result;
  }

  Future<bool> saveHeader({
    required DateTime date,
    required String poNo,
    required String paymentTermID,
    required String token,
    required String poID,
    CancelToken? cancelToken,
  }) async {
    final sdf = DateFormat("yyyy-MM-dd");
    final sDate = sdf.format(date);
    final param = {
      "date": sDate,
      "poID": poID,
      "poNo": poNo,
      "paymentTermID": paymentTermID,
    };
    await post(
      param: param,
      service: "/po/save_header",
      cancelToken: cancelToken,
      token: token,
    );
    return true;
  }
}
