import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../model/ac_material_model.dart';
import '../model/barcode_scan_response.dart';
import '../model/do_model.dart';
import '../model/lis_do_response_model.dart';
import '../widgets/fx_auto_completion_material.dart';
import '../widgets/fx_auto_completion_unit.dart';
import '../widgets/fx_auto_completion_vendor.dart';
import 'base_repository.dart';

class BarcodeScanResponseMessage {
  final List<BarcodeScanResponseModel> list;
  final String message;

  BarcodeScanResponseMessage({
    required this.list,
    required this.message,
  });
}

class DoRepository extends BaseRepository {
  DoRepository({
    required dio,
  }) : super(dio: dio);

  Future<bool> checkDoNo({
    required String doNo,
  }) async {
    final param = {
      "doNo": doNo,
    };
    await postWoToken(param: param, service: "/sor_do/check_no");
    return true;
  }

  Future<bool> deleteDetail({
    required String token,
    required String doDetailID,
    CancelToken? cancelToken,
  }) async {
    final param = {
      "doDetailID": doDetailID,
    };
    await post(
        token: token,
        param: param,
        service: "/sor_do/delete_detail",
        cancelToken: cancelToken);
    return true;
  }

  Future<BarcodeScanResponseMessage> barcodeScan({
    required List<String> barcode,
    required String token,
    required String storeID,
    CancelToken? cancelToken,
  }) async {
    final param = {
      "barcode": barcode,
      "storeID": storeID,
    };
    final resp = await post(
        token: token,
        param: param,
        service: "/sor_do/get_barcode",
        cancelToken: cancelToken);
    final List<BarcodeScanResponseModel> result = List.empty(growable: true);
    for (final el in resp["data"]) {
      final obj = BarcodeScanResponseModel.fromJson(el);
      result.add(obj);
    }
    final BarcodeScanResponseMessage resmsg = BarcodeScanResponseMessage(
        list: result, message: resp["message"] ?? "");
    return resmsg;
  }

  Future<List<AcMaterialModel>> acMaterial({
    required String search,
    required String poID,
    CancelToken? cancelToken,
  }) async {
    final param = {
      "search": search,
      "poID": poID,
    };
    final resp = await postWoToken(
        param: param, service: "/sor_do/material", cancelToken: cancelToken);
    final List<AcMaterialModel> list = List.empty(growable: true);
    for (var e in resp["data"]) {
      list.add(AcMaterialModel.fromJson(e));
    }
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
      service: "/sor_do/unit_lookup",
      cancelToken: cancelToken,
    );
    final List<UnitModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(UnitModel.fromJson(e));
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
      service: "/sor_do/vendor_lookup",
      cancelToken: cancelToken,
    );
    final List<VendorModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(VendorModel.fromJson(e));
    });
    return list;
  }

  Future<DoResponseModel> save({
    required String doNo,
    required DateTime date,
    required String storeID,
    required String poNo,
    required String poID,
    required String materialID,
    required String qty,
    required String drumNo,
    required String vendorID,
    required String packUnitID,
    required String packQty,
    required String token,
    required String doID,
    required String poPackQty,
    CancelToken? cancelToken,
  }) async {
    final sdf = DateFormat("yyyy-MM-dd");
    final sDate = sdf.format(date);
    final param = {
      "date": sDate,
      "doID": doID,
      "doNo": doNo,
      "poNo": poNo,
      "poID": poID,
      "storeID": storeID,
      "materialID": materialID,
      "drumNo": drumNo,
      "vendorID": vendorID,
      "packUnitID": packUnitID,
      "packQty": packQty,
      "poPackQty": poPackQty,
      "qty": qty
    };
    final resp = await post(
      param: param,
      service: "/sor_do/save",
      cancelToken: cancelToken,
      token: token,
    );
    final xdo = DoModel.fromJson(resp["do"]);
    final List<DoDetailModel> list = List.empty(growable: true);
    resp["detail"].forEach((e) {
      try {
        final detail = DoDetailModel.fromJson(e);
        list.add(detail);
      } catch (e) {}
    });
    final result = DoResponseModel(
      doModel: xdo,
      detail: list,
    );
    return result;
  }

  Future<List<ListDoResponseModel>> list({
    required String doNo,
    required String poNo,
    required String storeID,
    required String vendorID,
    required String materialID,
    required String token,
    CancelToken? cancelToken,
  }) async {
    final param = {
      "doNo": doNo,
      "poNo": poNo,
      "storeID": storeID,
      "vendorID": vendorID,
      "materialID": materialID,
    };
    final resp = await post(
      token: token,
      param: param,
      service: "/sor_do/list_do",
      cancelToken: cancelToken,
    );
    if (resp["do"].toString() == "[]") {
      throw BaseRepositoryException(message: "No result.");
    }
    final List<ListDoResponseModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      try {
        final detail = ListDoResponseModel.fromJson(e);
        list.add(detail);
      } catch (e) {}
    });
    return list;
  }

  Future<DoResponseModel> get({
    required String doNo,
    required String storeID,
    required String vendorID,
    required String token,
    CancelToken? cancelToken,
  }) async {
    final param = {
      "doNo": doNo,
      "storeID": storeID,
      "vendorID": vendorID,
    };
    final resp = await post(
      param: param,
      service: "/sor_do/do_get",
      cancelToken: cancelToken,
      token: token,
    );
    if (resp["do"].toString() == "[]") {
      throw BaseRepositoryException(message: "$doNo not found");
    }
    final xdo = DoModel.fromJson(resp["do"]);
    final List<DoDetailModel> list = List.empty(growable: true);
    resp["detail"].forEach((e) {
      try {
        final detail = DoDetailModel.fromJson(e);
        list.add(detail);
      } catch (e) {}
    });
    final result = DoResponseModel(
      doModel: xdo,
      detail: list,
    );
    return result;
  }
}
