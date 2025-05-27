class PoSaveResponseModel {
  final PoResponseModel po;
  final List<PoDetailResponseModel> detail;

  PoSaveResponseModel({
    required this.po,
    required this.detail,
  });
}

class PoResponseModel {
  late String paymentTermName;
  late String date;
  late String deliveryDate;
  late String paymentTermID;
  late String poID;
  late String poNo;
  late String vendorTerm;

  PoResponseModel({
    required this.paymentTermName,
    required this.date,
    required this.deliveryDate,
    required this.paymentTermID,
    required this.poID,
    required this.poNo,
    required this.vendorTerm,
  });

  PoResponseModel.fromJson(Map<String, dynamic> json) {
    paymentTermName = json['PaymentTermName'];
    date = json['date'];
    deliveryDate = json['deliveryDate'];
    paymentTermID = json['paymentTermID'].toString();
    poID = json['poID'].toString();
    poNo = json['poNo'];
    vendorTerm = json['vendorTerm'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PaymentTermName'] = paymentTermName;
    data['date'] = date;
    data['deliveryDate'] = deliveryDate;
    data['paymentTermID'] = paymentTermID;
    data['poID'] = poID;
    data['poNo'] = poNo;
    data['vendorTerm'] = vendorTerm;
    return data;
  }
}

class PoDetailResponseModel {
  late String description;
  late String isCable;
  late String materialCode;
  late String materialId;
  late String packUnit;
  late String poDetailID;
  late String poDetailPackQty;
  late String poDetailPrice;
  late String poDetailQty;
  late String unit;
  late String leadTime;
  late String isReceived;

  PoDetailResponseModel({
    required this.description,
    required this.isCable,
    required this.materialCode,
    required this.materialId,
    required this.packUnit,
    required this.poDetailID,
    required this.poDetailPackQty,
    required this.poDetailPrice,
    required this.poDetailQty,
    required this.unit,
    this.leadTime = "",
    this.isReceived = "N",
  });

  PoDetailResponseModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    isCable = json['isCable'];
    materialCode = json['material_code'];
    materialId = json['material_id'].toString();
    packUnit = json['packUnit'];
    poDetailID = json['poDetailID'].toString();
    poDetailPackQty = json['poDetailPackQty'];
    poDetailPrice = json['poDetailPrice'];
    poDetailQty = json['poDetailQty'];
    unit = json['unit'];
    leadTime = json['leadTime'].toString();
    isReceived = json['isReceived'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['isCable'] = isCable;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['packUnit'] = packUnit;
    data['poDetailID'] = poDetailID;
    data['poDetailPackQty'] = poDetailPackQty;
    data['poDetailPrice'] = poDetailPrice;
    data['poDetailQty'] = poDetailQty;
    data['unit'] = unit;
    data['leadTime'] = leadTime;
    data['isReceived'] = isReceived;
    return data;
  }
}
