import 'package:dio/dio.dart';
import 'package:sor_inventory/model/checkout_model_v2.dart';
import 'package:sor_inventory/model/store_model.dart';

import '../model/checkout_scan_response_model.dart';
import '../model/contractor_lookup_model.dart';
import 'base_repository.dart';

class ResponseCheckoutScan {
  final List<CheckoutScanResponseModel> list;
  final String message;
  final String slipNo;

  ResponseCheckoutScan({
    required this.list,
    required this.message,
    required this.slipNo,
  });
}

class CheckoutSlipModel {
  final ContractorLookupModel contractor;
  final String slipNo;
  final String slipDate;
  final String fileNum;
  final String cpFileNum;
  final String scheme;
  final String isDone;
  final List<CheckoutScanResponseModel> items;
  final StoreModel? store;

  CheckoutSlipModel(this.contractor, this.slipNo, this.slipDate, this.items,
      this.fileNum, this.scheme, this.isDone, this.store, this.cpFileNum);
}

class SchemeLookupModel {
  String? fileNum;
  String? scheme;
  String? cpFileNum;

  SchemeLookupModel({this.fileNum, this.scheme, this.cpFileNum});

  SchemeLookupModel.fromJson(Map<String, dynamic> json) {
    fileNum = json['file_num'];
    cpFileNum = json['cp_file_num'];
    scheme = json['scheme'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_num'] = fileNum;
    data['cp_file_num'] = cpFileNum;
    data['scheme'] = scheme;
    return data;
  }
}

class CheckoutRepository extends BaseRepository {
  CheckoutRepository({
    required dio,
  }) : super(dio: dio);

  Future<bool> setDone({
    required String slipNo,
    required String token,
    required String status,
  }) async {
    await post(
        param: {"slipNo": slipNo, "status": status},
        service: "/checkout/set_done",
        token: token);
    return true;
  }

  Future<bool> looseQtySave({
    required String barcode,
    required String checkoutID,
    required String token,
    required String qty,
    required String oldQty,
  }) async {
    await post(param: {
      "barcode": barcode,
      "qty": qty,
      "oldQty": oldQty,
      "checkoutID": checkoutID,
    }, service: "/checkout/loose_qty_save", token: token);
    return true;
  }

  Future<bool> delete({
    required String checkoutID,
    required String token,
  }) async {
    await post(
        param: {"checkoutID": checkoutID},
        service: "/checkout/delete",
        token: token);
    return true;
  }

  Future<List<MaterialC1>> listC1({
    required String fileNum,
    required String slipNo,
  }) async {
    final List<MaterialC1> list = List.empty(growable: true);
    var resp = await postWoToken(
        param: {}, service: "/checkout/list_c1/$fileNum/$slipNo");
    resp["data"].forEach((e) {
      list.add(MaterialC1.fromJson(e));
    });
    return list;
  }

  Future<List<SchemeLookupModel>> lookupScheme(
      {required String search, String cpID = "0"}) async {
    final param = {"cpID": cpID, "search": search};
    final List<SchemeLookupModel> list = List.empty(growable: true);
    var resp =
        await postWoToken(param: param, service: "/checkout/lookup_scheme");
    resp["data"].forEach((e) {
      list.add(SchemeLookupModel.fromJson(e));
    });
    return list;
  }

  Future<List<SchemeLookupModel>> lookupSchemeV2({
    required String search,
    String cpID = "0",
    String staffID = "0",
  }) async {
    final param = {
      "cpID": cpID,
      "staffID": staffID,
      "search": search,
    };
    final List<SchemeLookupModel> list = List.empty(growable: true);
    var resp =
        await postWoToken(param: param, service: "/checkout/lookup_scheme_v2");
    resp["data"].forEach((e) {
      list.add(SchemeLookupModel.fromJson(e));
    });
    return list;
  }

  Future<CheckoutSlipModel> getBySlip(String slipNo) async {
    var param = {"slipNo": slipNo};
    var resp = await postWoToken(param: param, service: "/checkout/by_no");
    var c = resp["contractor"];
    String fileNum = c["file_num"];
    String cpFileNum = c["cp_file_num"];
    String scheme = c["scheme"];
    ContractorLookupModel contractor = ContractorLookupModel(
        cpId: c["cp_id"],
        name: c["name"],
        dbName: c["dbName"],
        shortName: c["short_name"],
        staffName: c["staffName"] ?? "",
        staffId: c["staffId"] ?? "0",
        scheme: c["scheme"] ?? "");
    String slipDate = resp["checkoutDate"];
    String isDone = resp["checkoutIsDone"];
    List<CheckoutScanResponseModel> items = List.empty(growable: true);
    resp["items"].forEach((e) {
      items.add(CheckoutScanResponseModel.fromJson(e));
    });
    StoreModel store = StoreModel.fromJson(resp["store"]);
    return CheckoutSlipModel(
        contractor, slipNo, slipDate, items, fileNum, scheme, isDone, store,
       cpFileNum);
  }

  Future<List<CheckoutLisModel>> listV2({
    String vendorID = "0",
    String isReturn = "N",
    String staffId = "0",
    String storeID = "0",
    String search = "",
    required String token,
  }) async {
    final param = {
      "isReturn": isReturn,
      "cpID": vendorID,
      "staffID": staffId,
      "storeID": storeID,
      "search": search,
    };
    final List<CheckoutLisModel> list = List.empty(growable: true);
    var resp =
        await post(param: param, service: "/checkout/xlist_v2", token: token);
    resp["data"].forEach((e) {
      list.add(CheckoutLisModel.fromJson(e));
    });
    return list;
  }

  Future<List<CheckoutLisModel>> list(
      {String vendorID = "0", String isReturn = "N"}) async {
    final param = {"isReturn": isReturn, "cpID": vendorID};
    final List<CheckoutLisModel> list = List.empty(growable: true);
    var resp = await postWoToken(param: param, service: "/checkout/xlist");
    resp["data"].forEach((e) {
      list.add(CheckoutLisModel.fromJson(e));
    });
    return list;
  }

  Future<ResponseCheckoutScan> scanV2({
    required String token,
    required List<String> barcode,
    required ContractorLookupModel contractor,
    required String slipNo,
    required String fileNum,
    required String storeID,
  }) async {
    final param = {
      "cp": contractor,
      "barcode": barcode,
      "slipNo": slipNo,
      "file_num": fileNum,
      "storeID": storeID
    };
    final resp = await post(
      token: token,
      param: param,
      service: "/checkout/scan_v2",
    );
    final List<CheckoutScanResponseModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(CheckoutScanResponseModel.fromJson(e));
    });
    final ResponseCheckoutScan result = ResponseCheckoutScan(
        list: list, message: resp["message"], slipNo: resp["slipNo"]);
    return result;
  }

  Future<ResponseCheckoutScan> scan({
    required String token,
    required List<String> barcode,
    required ContractorLookupModel contractor,
    required String slipNo,
    required String fileNum,
  }) async {
    final param = {
      "cp": contractor,
      "barcode": barcode,
      "slipNo": slipNo,
      "file_num": fileNum
    };
    final resp = await post(
      token: token,
      param: param,
      service: "/checkout/scan",
    );
    final List<CheckoutScanResponseModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(CheckoutScanResponseModel.fromJson(e));
    });
    final ResponseCheckoutScan result = ResponseCheckoutScan(
        list: list, message: resp["message"], slipNo: resp["slipNo"]);
    return result;
  }

  Future<List<ContractorLookupModel>> contractorLookupV2({
    CancelToken? cancelToken,
  }) async {
    final resp = await postWoToken(
      param: {},
      service: "/checkout/lookup_contractor_v2",
      cancelToken: cancelToken,
    );
    final List<ContractorLookupModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(ContractorLookupModel.fromJson(e));
    });
    return list;
  }

  Future<List<ContractorLookupModel>> contractorLookup({
    CancelToken? cancelToken,
  }) async {
    final resp = await postWoToken(
      param: {},
      service: "/checkout/lookup_contractor",
      cancelToken: cancelToken,
    );
    final List<ContractorLookupModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(ContractorLookupModel.fromJson(e));
    });
    return list;
  }
}
