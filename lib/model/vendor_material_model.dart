class VendorMaterialModel {
  late String description;
  late String materialCode;
  late String materialId;
  late String vendorMaterialLeadTime;
  late String vendorPriceAmount;
  late String packQty;
  late String packUnitId;
  late String puUnit;
  late String unit;
  late String unitId;
  late String vendorPriceID;

  VendorMaterialModel({
    required this.description,
    required this.materialCode,
    required this.materialId,
    required this.vendorMaterialLeadTime,
    required this.vendorPriceAmount,
    required this.packQty,
    required this.packUnitId,
    required this.puUnit,
    required this.unit,
    required this.unitId,
    required this.vendorPriceID,
  });

  VendorMaterialModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    materialCode = json['material_code'];
    materialId = json['material_id'].toString();
    vendorMaterialLeadTime = json['vendorMaterialLeadTime'] ?? "";
    vendorPriceAmount = json['vendorPriceAmount'];
    packQty = json['pack_qty'] ?? "";
    packUnitId = (json['pack_unit_id'] ?? "").toString();
    puUnit = json['pu_unit'] ?? "";
    unit = json['unit'] ?? "";
    unitId = (json['unit_id'] ?? "").toString();
    vendorPriceID = (json['vendorPriceID'] ?? "").toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['vendorMaterialLeadTime'] = vendorMaterialLeadTime;
    data['vendorPriceAmount'] = vendorPriceAmount;
    return data;
  }
}
