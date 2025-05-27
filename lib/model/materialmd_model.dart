class MaterialMdModel {
  late String description;
  late String isCable;
  late String materialCode;
  late String materialId;
  late String packUnit;
  late String packQty;
  late String packUnitId;
  late String unitId;
  late String uom;
  late bool allowAvgPrice;

  MaterialMdModel({
    required this.description,
    required this.isCable,
    required this.materialCode,
    required this.materialId,
    required this.packUnit,
    required this.packQty,
    required this.packUnitId,
    required this.unitId,
    required this.uom,
    this.allowAvgPrice = false,
  });

  MaterialMdModel.fromJson(Map<String, dynamic> json) {
    try {
      description = json['description'] ?? "";
      isCable = json['is_cable'] ?? "N";
      materialCode = json['material_code'] ?? "";
      materialId = json['material_id'].toString();
      packUnit = json['packUnit'] ?? "";
      packQty = json['pack_qty'] ?? "";
      packUnitId = json['pack_unit_id'] ?? "";
      unitId = json['unit_id'] ?? "";
      uom = json['uom'] ?? "";
      allowAvgPrice = (json['flag_allow_avg_price'] == "Y");
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['is_cable'] = isCable;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['packUnit'] = packUnit;
    data['pack_qty'] = packQty;
    data['pack_unit_id'] = packUnitId;
    data['unit_id'] = unitId;
    data['uom'] = uom;
    data['flag_allow_avg_price'] = allowAvgPrice;
    return data;
  }
}
