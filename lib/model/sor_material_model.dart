class SorMaterialModel {
  late String materialId;
  late String description;
  String? materialCode;
  late String unit;
  late String poNum;
  late double qty;
  SorMaterialModel({
    required this.description,
    this.materialCode,
    required this.materialId,
    required this.unit,
    this.poNum = "",
    this.qty = 0.0,
  });

  SorMaterialModel.fromJson(Map<String, dynamic> json) {
    description = json['description'] ?? "";
    materialCode = json['material_code'] ?? "";
    materialId = json['material_id'] ?? "";
    unit = json['unit'] ?? "";
    poNum = "";
    qty = 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['unit'] = unit;
    return data;
  }
}

class ResponseSorMaterialModel {
  final List<SorMaterialModel> list;
  final int totalRecords;

  ResponseSorMaterialModel({
    required this.list,
    required this.totalRecords,
  });
}
