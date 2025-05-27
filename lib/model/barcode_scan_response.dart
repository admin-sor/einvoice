class BarcodeScanResponseModel {
  late String description;
  late String doDate;
  late String doDetailBarcode;
  late String doDetailDrumNo;
  late String doDetailPackQty;
  late String doDetailPoNo;
  late String doDetailQty;
  late String doNo;
  late String materialCode;
  late String materialId;
  late String packUnit;
  late String unit;
  late String vendorName;
  late String isCable;

  BarcodeScanResponseModel({
    required this.description,
    required this.doDate,
    required this.doDetailBarcode,
    required this.doDetailDrumNo,
    required this.doDetailPackQty,
    required this.doDetailPoNo,
    required this.doDetailQty,
    required this.doNo,
    required this.materialCode,
    required this.materialId,
    required this.packUnit,
    required this.unit,
    required this.vendorName,
    this.isCable = "Y",
  });

  BarcodeScanResponseModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    doDate = json['doDate'];
    doDetailBarcode = json['doDetailBarcode'];
    doDetailDrumNo = json['doDetailDrumNo'];
    doDetailPackQty = json['doDetailPackQty'];
    doDetailPoNo = json['doDetailPoNo'];
    doDetailQty = json['doDetailQty'];
    doNo = json['doNo'];
    materialCode = json['material_code'];
    materialId = json['material_id'];
    packUnit = json['packUnit'];
    unit = json['unit'];
    vendorName = json['vendorName'];
    isCable = json['isCable'] ?? "N";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['doDate'] = doDate;
    data['doDetailBarcode'] = doDetailBarcode;
    data['doDetailDrumNo'] = doDetailDrumNo;
    data['doDetailPackQty'] = doDetailPackQty;
    data['doDetailPoNo'] = doDetailPoNo;
    data['doDetailQty'] = doDetailQty;
    data['doNo'] = doNo;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['packUnit'] = packUnit;
    data['unit'] = unit;
    data['vendorName'] = vendorName;
    return data;
  }
}
