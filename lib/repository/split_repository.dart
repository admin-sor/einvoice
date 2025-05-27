import 'package:sor_inventory/model/split_material_model.dart';

import 'base_repository.dart';

class ResponseSplitHistoryModel {
  int? originQty;
  String? description;
  String? materialCode;
  String? originBarcode;
  String? splitMaterialBarcode;
  String? splitMaterialDrumNo;
  String? splitMaterialPackQty;
  String? unit;
  String? packUnit;
  String? isCable;
  String? ref;
  String? refID;
  String? splitMaterialID;
  String? storeID;
  String? storeName;

  ResponseSplitHistoryModel({
    this.originQty,
    this.description,
    this.materialCode,
    this.originBarcode,
    this.splitMaterialBarcode,
    this.splitMaterialDrumNo,
    this.splitMaterialPackQty,
    this.unit,
    this.packUnit,
    this.isCable,
    this.ref,
    this.refID,
    this.splitMaterialID,
  });

  ResponseSplitHistoryModel.fromJson(Map<String, dynamic> json) {
    originQty = json['OriginQty'];
    description = json['description'];
    materialCode = json['material_code'];
    originBarcode = json['originBarcode'];
    splitMaterialBarcode = json['splitMaterialBarcode'];
    splitMaterialDrumNo = json['splitMaterialDrumNo'];
    splitMaterialPackQty = json['splitMaterialPackQty'];
    unit = json['unit'];
    packUnit = json['packUnit'];
    isCable = json['is_cable'];
    ref = json['ref'];
    refID = json['refID'];
    splitMaterialID = json['splitMaterialID'];
    storeID = json['storeID'];
    storeName = json['storeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['OriginQty'] = originQty;
    data['description'] = description;
    data['material_code'] = materialCode;
    data['originBarcode'] = originBarcode;
    data['splitMaterialBarcode'] = splitMaterialBarcode;
    data['splitMaterialDrumNo'] = splitMaterialDrumNo;
    data['splitMaterialPackQty'] = splitMaterialPackQty;
    data['packUnit'] = packUnit;
    data['is_cable'] = isCable;
    data['storeID'] = storeID;
    data['storeName'] = storeName;
    data['unit'] = unit;
    data['splitMaterialID'] = isCable;
    return data;
  }
}

class ResponseSplitScan {
  late String ref;
  late String refID;
  late String code;
  late String description;
  late String barcode;
  late String drumNo;
  late String packSizeCurrent;
  late String unit;
  late String packUnit;
  late String isCable;
  late String storeID;
  late String storeName;

  ResponseSplitScan({
    required this.ref,
    required this.refID,
    required this.code,
    required this.description,
    required this.barcode,
    required this.drumNo,
    required this.packSizeCurrent,
    required this.packUnit,
    required this.unit,
    required this.isCable,
    required this.storeID,
    required this.storeName,
  });

  ResponseSplitScan.fromJson(Map<String, dynamic> e) {
    ref = e["ref"];
    refID = e["refID"];
    code = e["material_code"];
    description = e["description"];
    barcode = e["barcode"];
    drumNo = e["drumNo"];
    packSizeCurrent = e["packSizeCurrent"];
    unit = e["unit"];
    packUnit = e["packUnit"];
    if (packUnit == "") packUnit = "No Pack Unit";
    isCable = e["isCable"];
    storeID = e["storeID"];
    storeName = e["storeName"];
  }
}

class SplitRepository extends BaseRepository {
  SplitRepository({
    required dio,
  }) : super(dio: dio);

  Future<List<SplitMaterialModel>> search({
    required String storeID,
    required String search,
    required String type,
  }) async {
    var param = {"storeID": storeID, "search": search, "type": type};
    final resp = await postWoToken(
      param: param,
      service: "/split/search",
    );
    var result = List<SplitMaterialModel>.empty(growable: true);
    for (var e in resp["data"]) {
      var obj = SplitMaterialModel.fromJson(e);
      result.add(obj);
    }
    return result;
  }

  Future<List<ResponseSplitHistoryModel>> byId({
    required String splitID,
  }) async {
    var param = {"splitID": splitID};
    final resp = await postWoToken(
      param: param,
      service: "/split/by_split_id",
    );
    var result = List<ResponseSplitHistoryModel>.empty(growable: true);
    for (var e in resp["data"]) {
      var obj = ResponseSplitHistoryModel.fromJson(e);
      result.add(obj);
    }
    return result;
  }

  Future<List<String>> save({
    required String token,
    required String ref,
    required String refID,
    required String storeID,
    required List<String> split,
  }) async {
    final param = {
      "ref": ref,
      "refID": refID,
      "split": split,
      "storeID": storeID,
    };
    final resp = await post(
      token: token,
      param: param,
      service: "/split/save",
    );
    List<String> result = List.empty(growable: true);
    for (var e in resp["result"]) {
      result.add(e.toString());
    }
    return result;
  }

  Future<ResponseSplitScan> scan({
    required String token,
    required String barcode,
    required String storeID,
  }) async {
    final param = {
      "barcode": barcode,
      "storeID": storeID,
    };
    final resp = await post(
      token: token,
      param: param,
      service: "/split/scan",
    );
    var result = ResponseSplitScan.fromJson(resp["data"]);
    return result;
  }
}
