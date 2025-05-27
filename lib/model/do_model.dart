class DoModel {
  late String date;
  late String doID;
  late String doNo;
  late String doStoreID;

  DoModel({
    required this.date,
    required this.doID,
    required this.doNo,
    required this.doStoreID,
  });

  DoModel.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    doID = json['doID'].toString();
    doNo = json['doNo'];
    doStoreID = json['doStoreID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['doID'] = doID.toString();
    data['doNo'] = doNo;
    data['doStoreID'] = doStoreID;
    return data;
  }
}

class DoDetailModel {
  late String description;
  late String doDetailBarcode;
  late String doDetailDrumNo;
  late String doDetailPoNo;
  late String doDetailQty;
  late String doDetailPackQty;
  late String materialCode;
  late String materialId;
  late String unit;
  late String packUnit;
  late String isCable;
  late String doDetailID;
  late String isAllowDelete;
  late String doDetailEntryID;

  DoDetailModel({
    required this.description,
    required this.doDetailBarcode,
    required this.doDetailDrumNo,
    required this.doDetailPoNo,
    required this.doDetailQty,
    required this.doDetailPackQty,
    required this.materialCode,
    required this.materialId,
    required this.unit,
    this.packUnit = "",
    this.isCable = "N",
    this.doDetailID = "0",
    this.doDetailEntryID = "0",
    this.isAllowDelete = "Y",
  });

  DoDetailModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    doDetailBarcode = json['doDetailBarcode'];
    doDetailDrumNo = json['doDetailDrumNo'];
    doDetailPoNo = json['doDetailPoNo'];
    doDetailQty = json['doDetailQty'];
    doDetailPackQty = json['doDetailPackQty'];
    materialCode = json['material_code'];
    materialId = json['material_id'].toString();
    unit = json['unit'];
    packUnit = json['packUnit'] ?? "";
    isCable = json['isCable'] ?? "N";
    isAllowDelete = json['isAllowDelete'] ?? "Y";
    doDetailID = json['doDetailID'] ?? "0";
    doDetailEntryID = json['doDetailEntryID'] ?? "0";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['doDetailBarcode'] = doDetailBarcode;
    data['doDetailDrumNo'] = doDetailDrumNo;
    data['doDetailPoNo'] = doDetailPoNo;
    data['doDetailQty'] = doDetailQty;
    data['doDetailPackQty'] = doDetailPackQty;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['isAllowDelete'] = isAllowDelete;
    data['unit'] = unit;
    data['doDetailEntryID'] = doDetailEntryID;
    return data;
  }
}

class DoResponseModel {
  final DoModel doModel;
  final List<DoDetailModel> detail;

  DoResponseModel({
    required this.doModel,
    required this.detail,
  });
}
