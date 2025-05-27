class VendorLookupMaterialModel {
  late String description;
  late String materialCode;
  late String materialId;
  late String packQty;
  late String packUnitId;
  late String puUnit;
  late String unit;
  late String unitId;

  VendorLookupMaterialModel({
    required this.description,
    required this.materialCode,
    required this.materialId,
    required this.packQty,
    required this.packUnitId,
    required this.puUnit,
    required this.unit,
    required this.unitId,
  });

  VendorLookupMaterialModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    materialCode = json['material_code'];
    materialId = json['material_id'].toString();
    packQty = json['pack_qty'] ?? "";
    packUnitId = (json['pack_unit_id'] ?? "").toString();
    puUnit = json['pu_unit'] ?? "";
    unit = json['unit'] ?? "";
    unitId = (json['unit_id'] ?? "").toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['pack_qty'] = packQty;
    data['pack_unit_id'] = packUnitId;
    data['pu_unit'] = puUnit;
    data['unit'] = unit;
    data['unit_id'] = unitId;
    return data;
  }
}
