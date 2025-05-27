class ResponseReturnableMaterialModel {
  String? barcode;
  String? checkoutDate;
  String? checkoutPackQty;
  String? code;
  String? description;
  String? drumNo;
  String? isCable;
  String? packUnit;
  String? type;
  String? unit;

  ResponseReturnableMaterialModel(
      {this.barcode,
      this.checkoutDate,
      this.checkoutPackQty,
      this.code,
      this.description,
      this.drumNo,
      this.isCable,
      this.packUnit,
      this.type,
      this.unit});

  ResponseReturnableMaterialModel.fromJson(Map<String, dynamic> json) {
    barcode = json['barcode'];
    checkoutDate = json['checkoutDate'];
    checkoutPackQty = json['checkoutPackQty'];
    code = json['code'];
    description = json['description'];
    drumNo = json['drumNo'];
    isCable = json['is_cable'];
    packUnit = json['packUnit'];
    type = json['type'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['barcode'] = barcode;
    data['checkoutDate'] = checkoutDate;
    data['checkoutPackQty'] = checkoutPackQty;
    data['code'] = code;
    data['description'] = description;
    data['drumNo'] = drumNo;
    data['is_cable'] = isCable;
    data['packUnit'] = packUnit;
    data['type'] = type;
    data['unit'] = unit;
    return data;
  }
}
