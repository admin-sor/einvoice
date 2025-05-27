class SplitMaterialModel {
  String? description;
  String? barcode;
  String? date;
  String? type;
  String? storeID;
  String? storeName;

  SplitMaterialModel(
      {this.description,
      this.barcode,
      this.date,
      this.type,
      this.storeID,
      this.storeName});

  SplitMaterialModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    barcode = json['barcode'];
    type = json['type'];
    date = json['date'];
    storeID = json['storeID'];
    storeName = json['storeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['barcode'] = barcode;
    data['date'] = date;
    data['type'] = type;
    data['storeID'] = storeID;
    data['storeName'] = storeName;
    return data;
  }
}
