class AcMaterialModel {
  late String description;
  late String isCable;
  late String materialCode;
  late String materialId;
  late String unit;
  late String unitId;
  late String packUnitId;
  late String packUnit;
  late String packQty;
  late String packUnitDesc;
  late String unitPrice;
  late String remainingQty;
  late String remainingItemQty;
  late String poDetailItemQty;
  late String fromVendor;
  AcMaterialModel(
      {required this.description,
      required this.isCable,
      required this.materialCode,
      required this.materialId,
      required this.unit,
      this.unitPrice = "0.00",
      this.remainingQty = "0.00",
      this.fromVendor = "Y"});

  AcMaterialModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    isCable = json['is_cable'];
    materialCode = json['material_code'];
    materialId = json['material_id'];
    unit = json['unit'];
    unitId = json['unit_id'];
    packUnit = json['pack_unit'] ?? "";
    packUnitId = json['pack_unit_id'] ?? "";
    packQty = json['pack_qty'] ?? "";
    packUnitDesc = json['pack_unit_desc'] ?? "";
    unitPrice = json['unitPrice'] ?? "0.000";
    remainingQty = json["remainingQty"] ?? "0.00";
    remainingItemQty = json["remainingItemQty"]?.toString() ?? "0.00";
    poDetailItemQty = json["poDetailItemQty"]?.toString() ?? "0.00";
    fromVendor = json["fromVendor"] ?? "Y";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['is_cable'] = isCable;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['unit'] = unit;
    data['unit_id'] = unitId;
    data['pack_unit'] = packUnit;
    data['pack_qty'] = packQty;
    data['pack_unit_id'] = packUnitId;
    data['unitPrice'] = unitPrice;
    data['remainingQty'] = remainingQty;
    data['remainingItemQty'] = remainingItemQty;
    data['poDetailItemQty'] = poDetailItemQty;
    return data;
  }
}
