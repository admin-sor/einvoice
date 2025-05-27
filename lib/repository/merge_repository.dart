import '../model/merge_material_model.dart';
import 'base_repository.dart';

class ResponseMergeScan {
  late String ref;
  late String refID;
  late String materialID;
  late String code;
  late String description;
  late String barcode;
  late String drumNo;
  late String packSizeCurrent;
  late String unit;
  late String packUnit;
  late String isCable;
  late String price;
  late String storeID;

  ResponseMergeScan({
    required this.ref,
    required this.refID,
    required this.materialID,
    required this.code,
    required this.description,
    required this.barcode,
    required this.drumNo,
    required this.packSizeCurrent,
    required this.packUnit,
    required this.unit,
    required this.isCable,
    required this.price,
    required this.storeID,
  });

  ResponseMergeScan.fromJson(Map<String, dynamic> e) {
    ref = e["ref"];
    refID = e["refID"];
    materialID = e["material_id"];
    code = e["material_code"];
    description = e["description"];
    barcode = e["barcode"];
    drumNo = e["drumNo"];
    packSizeCurrent = e["packSizeCurrent"] ?? "";
    unit = e["unit"];
    packUnit = e["packUnit"] ?? "";
    if (packUnit == "") packUnit = "No Pack Unit";
    isCable = e["isCable"];
    price = e["price"] ?? "";
    storeID = e["storeID"] ?? "";
  }
}

class ParamMergeSave {
  final String barcode;
  final String ref;
  final String refID;
  final String storeID;

  ParamMergeSave(this.barcode, this.ref, this.refID, this.storeID);
  Map<String, dynamic> toJson() {
    return {"barcode": barcode, "ref": ref, "refID": refID, "storeID": storeID};
  }
}

/*
{
   "result" : {
      "code" : "1000000018",
      "description" : "CABLE INTERNAL 100PR 0.5MM",
      "mergeMaterialBarcode" : "000120001-M",
      "mergeMaterialDate" : "2023-02-02 13:55:12",
      "mergeMaterialDrumNo" : "DRM001801",
      "mergeMaterialID" : "4",
      "mergeMaterialIsActive" : "Y",
      "mergeMaterialMaterialID" : "12",
      "mergeMaterialPackQty" : "10000.00",
      "mergeMaterialPackUnitID" : "39",
      "mergeMaterialPrice" : "0.71",
      "mergeMaterialUserID" : "1",
      "packUnit" : "DRUM",
      "unit" : "MTR"
   },
   "status" : "OK"
}
*/
class ResponseMergeSave {
  late String mergeMaterialID;
  late String mergeMaterialBarcode;
  late String mergeMaterialDrumNo;
  late String mergeMaterialPackUnitID;
  late String mergeMaterialPackQty;
  late String mergeMaterialPrice;
  late String code;
  late String description;
  late String unit;
  late String packUnit;

  ResponseMergeSave({
    required this.mergeMaterialID,
    required this.mergeMaterialBarcode,
    required this.mergeMaterialDrumNo,
    required this.mergeMaterialPackUnitID,
    required this.mergeMaterialPackQty,
    required this.mergeMaterialPrice,
    required this.code,
    required this.description,
    required this.unit,
    required this.packUnit,
  });
  ResponseMergeSave.fromJson(Map<String, dynamic> json) {
    code = json["code"];
    description = json["description"];
    unit = json["unit"];
    packUnit = json["packUnit"] ?? "";
    mergeMaterialPrice = json["mergeMaterialPrice"];
    mergeMaterialPackQty = json["mergeMaterialPackQty"];
    mergeMaterialPackUnitID = json["mergeMaterialPackUnitID"];
    mergeMaterialDrumNo = json["mergeMaterialDrumNo"];
    mergeMaterialBarcode = json["mergeMaterialBarcode"];
    mergeMaterialID = json["mergeMaterialID"];
  }
}

class SplitMergeResponse {
  String? action;
  String? barcode;
  String? date;
  String? id;
  String? oldBarcode;

  SplitMergeResponse(
      {this.action, this.barcode, this.date, this.id, this.oldBarcode});

  SplitMergeResponse.fromJson(Map<String, dynamic> json) {
    action = json['action'];
    barcode = json['barcode'];
    date = json['date'];
    id = json['id'];
    oldBarcode = json['old_barcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['action'] = action;
    data['barcode'] = barcode;
    data['date'] = date;
    data['id'] = id;
    data['old_barcode'] = oldBarcode;
    return data;
  }
}

class MergeRepository extends BaseRepository {
  MergeRepository({
    required dio,
  }) : super(dio: dio);

  Future<List<MergeMaterialModel>> search({
    required String storeID,
    required String search,
  }) async {
    var param = {"storeID": storeID, "search": search};
    final resp = await postWoToken(
      param: param,
      service: "/merge/search",
    );
    var result = List<MergeMaterialModel>.empty(growable: true);
    for (var e in resp["data"]) {
      var obj = MergeMaterialModel.fromJson(e);
      result.add(obj);
    }
    return result;
  }

  Future<List<SplitMergeResponse>> listSplitMerge({
    required String filter,
    required String search,
    required String from,
    required String to,
  }) async {
    var param = {
      "filter": filter,
      "search": search,
      "from": from,
      "to": to,
    };
    final resp = await postWoToken(
      param: param,
      service: "/merge/list_barcode",
    );
    List<SplitMergeResponse> list = List.empty(growable: true);
    for (var e in resp["data"]) {
      var result = SplitMergeResponse.fromJson(e);
      list.add(result);
    }
    return list;
  }

  Future<List<ResponseMergeScan>> byID({
    required String mergeMaterialID,
  }) async {
    var param = {
      "mergeMaterialID": mergeMaterialID,
    };
    final resp = await postWoToken(
      param: param,
      service: "/merge/by_id",
    );
    var result = List<ResponseMergeScan>.empty(growable: true);
    for (var e in resp["data"]) {
      var obj = ResponseMergeScan.fromJson(e);
      result.add(obj);
    }
    return result;
  }

  Future<ResponseMergeScan> scan({
    required String token,
    required String barcode,
    required String materialID,
    required String storeID,
  }) async {
    var param = {
      "barcode": barcode,
      "materialID": materialID,
      "storeID": storeID,
    };
    // if (materialID == "0") {
    //   param = {"barcode": barcode};
    // }
    final resp = await post(
      token: token,
      param: param,
      service: "/merge/scan",
    );
    var result = ResponseMergeScan.fromJson(resp["data"]);
    return result;
  }

  Future<ResponseMergeSave> save({
    required String token,
    required String storeID,
    required List<ParamMergeSave> merge,
  }) async {
    final param = {"merge": merge, "storeID": storeID};
    final resp = await post(
      token: token,
      param: param,
      service: "/merge/save",
    );
    var result = ResponseMergeSave.fromJson(resp["result"]);
    return result;
  }
}
