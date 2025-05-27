class CheckoutLisModel {
  String? checkoutDate;
  String? checkoutSlipNo;
  String? checkoutCpName;
  String? scheme;
  String? projectNum;
  String? staffName;
  String? storeName;

  CheckoutLisModel(
      {this.checkoutDate, this.checkoutSlipNo, this.checkoutCpName});

  CheckoutLisModel.fromJson(Map<String, dynamic> json) {
    checkoutDate = json['checkoutDate'];
    checkoutSlipNo = json['checkoutSlipNo'];
    checkoutCpName = json['checkout_cpName'];
    staffName = json['staffName'] ?? "";
    storeName = json['storeName'] ?? "";
    scheme = json['scheme'] ?? "";
    projectNum = json['project_num'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['checkoutDate'] = checkoutDate;
    data['checkoutSlipNo'] = checkoutSlipNo;
    data['checkout_cpName'] = checkoutCpName;
    data['staffName'] = staffName;
    data['storeName'] = storeName;
    data['scheme'] = scheme;
    data['project_num'] = projectNum;
    return data;
  }
}

//Material C1 Response based on file_num
class MaterialC1 {
  String? description;
  String? materialCode;
  String? materialId;
  String? barcode;
  String? qty;
  String? isExist;
  String? issueQty;
  String? dueQty;
  String? isPO;
  String? allowDelete;
  String? checkoutID;
  String? checkoutRef;

  MaterialC1({this.description, this.materialCode, this.materialId, this.qty});

  MaterialC1.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    materialCode = json['material_code'];
    materialId = json['material_id'];
    qty = json['qty'];
    isExist = json['is_exist'];
    isPO = json['is_po'];
    issueQty = json['issue_qty'].toString();
    dueQty = json['due'].toString();
    barcode = json['barcode'] ?? "";
    allowDelete = json['allow_delete'] ?? "";
    checkoutID = json['checkoutID'].toString();
    checkoutRef = json['checkoutRef'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['qty'] = qty;
    data['is_exist'] = isExist;
    data['is_po'] = isPO;
    data['issue_qty'] = issueQty;
    data['due'] = dueQty;
    data['barcode'] = barcode;
    data['allow_delete'] = allowDelete;
    data['checkoutID'] = checkoutID;
    data['checkoutRef'] = allowDelete;
    return data;
  }
}
