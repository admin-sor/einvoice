import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sor_inventory/model/material_return_model_v2.dart';
import 'package:sor_inventory/model/mr_model_v2.dart';

import '../model/contractor_lookup_model.dart';
import '../model/material_return_scan_response.dart';
import 'base_repository.dart';

class ResponseMaterialReturnScanV2 {
  final List<MaterialReturnScanResponseModelV2> list;
  final String message;
  final String slipNo;
  ResponseMaterialReturnScanV2({
    required this.list,
    required this.message,
    required this.slipNo,
  });
}

class ResponseMaterialReturnScan {
  final List<MaterialReturnScanResponseModel> list;
  final String message;
  final String slipNo;
  ResponseMaterialReturnScan({
    required this.list,
    required this.message,
    required this.slipNo,
  });
}

class MrSlipModel {
  final ContractorLookupModel contractor;
  final String slipNo;
  final String slipDate;
  final String isDone;
  final List<MaterialReturnScanResponseModelV2> items;
  final String storeID;
  final String storeName;
  MrSlipModel(
    this.contractor,
    this.slipNo,
    this.slipDate,
    this.items,
    this.isDone,
    this.storeID,
    this.storeName,
  );
}

class MaterialReturnRepository extends BaseRepository {
  MaterialReturnRepository({
    required dio,
  }) : super(dio: dio);

  Future<MrSlipModel> getBySlip(String slipNo) async {
    var param = {"slipNo": slipNo};
    var resp =
        await postWoToken(param: param, service: "/materialreturn/by_no");
    var c = resp["contractor"];
    ContractorLookupModel contractor = ContractorLookupModel(
        cpId: c["cp_id"],
        name: c["name"],
        shortName: c["short_name"],
        staffId: c["staffId"],
        staffName: c["staffName"],
        scheme: c["scheme"] ?? "");
    String slipDate = resp["MrDate"];
    String isDone = resp["MrIsDone"];
    List<MaterialReturnScanResponseModelV2> items = List.empty(growable: true);
    String storeID = "0";
    String storeName = "";
    resp["items"].forEach((e) {
      items.add(MaterialReturnScanResponseModelV2.fromJson(e));
      if (storeID == "0") {
        storeID = e["checkoutStoreID"];
        storeName = e["storeName"];
      }
    });
    return MrSlipModel(
      contractor,
      slipNo,
      slipDate,
      items,
      isDone,
      storeID,
      storeName,
    );
  }

  Future<bool> setDone({
    required String slipNo,
    required String token,
    required String status,
  }) async {
    await post(
        param: {"slipNo": slipNo, "status": status},
        service: "/materialreturn/set_done",
        token: token);
    return true;
  }

  Future<bool> delete({
    required String checkoutID,
    required String mrID,
    required String token,
  }) async {
    var param = {"mrID": mrID, "checkoutID": checkoutID, "token": token};
    await post(param: param, token: token, service: "/materialreturn/delete");
    return true;
  }

  Future<List<MrListModel>> list({
    String cpID = "0",
    String soID = "0",
    String storeID = "0",
    String search = "",
    required String token,
  }) async {
    final param = {
      "cpID": cpID,
      "soID": soID,
      "search": search,
      "storeID": storeID,
    };
    final List<MrListModel> list = List.empty(growable: true);
    var resp = await post(
        param: param, service: "/materialreturn/xlistv2", token: token);
    resp["data"].forEach((e) {
      list.add(MrListModel.fromJson(e));
    });
    return list;
  }

  Future<List<ResponseReturnableMaterialModel>> getMaterial(String cpID) async {
    final param = {"soID": cpID};
    var resp = await postWoToken(
        param: param, service: "/materialreturn/by_contractor");
    var result = List<ResponseReturnableMaterialModel>.empty(growable: true);
    result.add(ResponseReturnableMaterialModel(
        description: "Select returnable material", barcode: "", code: ""));
    resp["data"].forEach((e) {
      result.add(ResponseReturnableMaterialModel.fromJson(e));
    });
    return result;
  }

  Future<ResponseMaterialReturnScanV2> materialLookupReturned(
    String cpID,
    String soID,
    String dbName,
    String search,
    String slipNo,
  ) async {
    final param = {
      "cpID": cpID,
      "soID": soID,
      "dbName": dbName,
      "search": search,
      "returned": "Y",
      "slipNo": slipNo
    };
    var resp = await postWoToken(
        param: param, service: "/materialreturn/material_lookup");
    final List<MaterialReturnScanResponseModelV2> list =
        List.empty(growable: true);
    resp["data"].forEach((e) {
      try {
        list.add(MaterialReturnScanResponseModelV2.fromJson(e));
      } catch (_) {}
    });
    final ResponseMaterialReturnScanV2 result = ResponseMaterialReturnScanV2(
        list: list, message: resp["message"], slipNo: resp["slipNo"]);
    return result;
  }

  Future<ResponseMaterialReturnScanV2> materialLookup(
    String cpID,
    String soID,
    String dbName,
    String search,
    String slipNo,
  ) async {
    final param = {
      "cpID": cpID,
      "soID": soID,
      "dbName": dbName,
      "search": search,
      "slipNo": slipNo,
    };
    var resp = await postWoToken(
        param: param, service: "/materialreturn/material_lookup_v2");
    final List<MaterialReturnScanResponseModelV2> list =
        List.empty(growable: true);
    resp["data"].forEach((e) {
      try {
        list.add(MaterialReturnScanResponseModelV2.fromJson(e));
      } catch (_) {}
    });
    final ResponseMaterialReturnScanV2 result = ResponseMaterialReturnScanV2(
        list: list, message: resp["message"], slipNo: resp["slipNo"]);
    return result;
  }

  Future<String> save({
    required String token,
    required String barcode,
    required String packQty,
    required String mrID,
    required String storeID,
    required String slipNo,
    required String isScrap,
  }) async {
    final param = {
      "barcode": barcode,
      "packQty": packQty,
      "mrID": mrID,
      "storeID": storeID,
      "slipNo": slipNo,
      "isScrap": isScrap,
    };
    var resp = await post(
      token: token,
      param: param,
      service: "/materialreturn/save_v2",
    );
    return resp["slipNo"];
  }

  Future<List<MaterialReturnScanResponseModel>> get({
    required String slipNo,
  }) async {
    final param = {
      "slipNo": slipNo,
    };
    final resp = await postWoToken(
      param: param,
      service: "/materialreturn/get",
    );
    final List<MaterialReturnScanResponseModel> list =
        List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(MaterialReturnScanResponseModel.fromJson(e));
    });
    return list;
  }

  Future<ResponseMaterialReturnScanV2> scanOnlyV2({
    required String token,
    required String barcode,
  }) async {
    final param = {
      "barcode": barcode,
    };
    final resp = await post(
      token: token,
      param: param,
      service: "/materialreturn/scan_only_v2",
    );
    final List<MaterialReturnScanResponseModelV2> list =
        List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(MaterialReturnScanResponseModelV2.fromJson(e));
    });
    final ResponseMaterialReturnScanV2 result = ResponseMaterialReturnScanV2(
        list: list, message: resp["message"], slipNo: resp["slipNo"]);
    return result;
  }

  Future<ResponseMaterialReturnScan> scanOnly({
    required String token,
    required String barcode,
    required ContractorLookupModel? contractor,
    required String slipNo,
  }) async {
    final param = {
      "cp": contractor ?? "",
      "barcode": barcode,
      "slipNo": slipNo,
    };
    final resp = await post(
      token: token,
      param: param,
      service: "/materialreturn/scan_only",
    );
    final List<MaterialReturnScanResponseModel> list =
        List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(MaterialReturnScanResponseModel.fromJson(e));
    });
    final ResponseMaterialReturnScan result = ResponseMaterialReturnScan(
        list: list, message: resp["message"], slipNo: resp["slipNo"]);
    return result;
  }

  Future<ResponseMaterialReturnScan> scan({
    required String token,
    required List<String> barcode,
    required ContractorLookupModel contractor,
    required String slipNo,
  }) async {
    final param = {
      "cp": contractor,
      "barcode": barcode,
      "slipNo": slipNo,
    };
    final resp = await post(
      token: token,
      param: param,
      service: "/materialreturn/scan",
    );
    final List<MaterialReturnScanResponseModel> list =
        List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(MaterialReturnScanResponseModel.fromJson(e));
    });
    final ResponseMaterialReturnScan result = ResponseMaterialReturnScan(
        list: list, message: resp["message"], slipNo: resp["slipNo"]);
    return result;
  }

  Future<List<ContractorLookupModel>> contractorLookup({
    CancelToken? cancelToken,
  }) async {
    final resp = await postWoToken(
      param: {},
      service: "/materialreturn/lookup_contractor",
      cancelToken: cancelToken,
    );
    final List<ContractorLookupModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(ContractorLookupModel.fromJson(e));
    });
    return list;
  }
}
