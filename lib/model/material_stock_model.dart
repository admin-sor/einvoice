class MaterialStockModel {
  String? description;
  String? itemUnit;
  String? materialId;
  String? packUnit;
  String? packsizeBarcode;
  String? packsizeCurrent;
  String? poNo;
  String? isCable;
  String? drumNo;
  String? storeName;
  String? avgPrice;
  String? refType;
  String? refID;
  String? xID;

  MaterialStockModel({
    this.description,
    this.itemUnit,
    this.materialId,
    this.packUnit,
    this.packsizeBarcode,
    this.packsizeCurrent,
    this.isCable,
    this.drumNo,
    this.storeName,
    this.avgPrice,
    this.poNo,
    this.refType,
    this.refID,
    this.xID,
  });

  MaterialStockModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    itemUnit = json['itemUnit'];
    materialId = json['material_id'];
    packUnit = json['packUnit'];
    packsizeBarcode = json['packsizeBarcode'];
    packsizeCurrent = json['packsizeCurrent'];
    poNo = json['poNo'];
    drumNo = json['drumNo'];
    isCable = json['is_cable'];
    storeName = json['storeName'];
    avgPrice = json['avgPrice'];
    refID = json['refID'];
    xID = json['xID'];
    refType = json['ref'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['itemUnit'] = itemUnit;
    data['material_id'] = materialId;
    data['packUnit'] = packUnit;
    data['packsizeBarcode'] = packsizeBarcode;
    data['packsizeCurrent'] = packsizeCurrent;
    data['poNo'] = poNo;
    data['drumNo'] = drumNo;
    data['is_cable'] = isCable;
    data['storeName'] = storeName;
    data['avgPrice'] = avgPrice;
    data['refID'] = refID;
    data['xID'] = xID;
    data['ref'] = refType;
    return data;
  }
}
