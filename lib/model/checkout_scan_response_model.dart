class CheckoutScanResponseModel {
  late String checkinDate;
  late String checkinID;
  late String checkinIsCheckout;
  late String checkoutID;
  late String description;
  late String doDetailBarcode;
  late String doDetailDrumNo;
  late String doDetailPackQty;
  late String doDetailQty;
  late String isCable;
  late String materialCode;
  late String materialId;
  late String packUnit;
  late String unit;
  late String reqPoQty;

  CheckoutScanResponseModel({
    required this.checkinDate,
    required this.checkinID,
    required this.checkinIsCheckout,
    required this.checkoutID,
    required this.description,
    required this.doDetailBarcode,
    required this.doDetailDrumNo,
    required this.doDetailPackQty,
    required this.doDetailQty,
    required this.isCable,
    required this.materialCode,
    required this.materialId,
    required this.packUnit,
    required this.unit,
    required this.reqPoQty,
  });

  CheckoutScanResponseModel.fromJson(Map<String, dynamic> json) {
    checkinDate = json['checkinDate'] ?? "" ;
    checkinID = json['checkinID'].toString();
    checkinIsCheckout = json['checkinIsCheckout'] ?? "";
    checkoutID = json['checkoutID'].toString();
    description = json['description'];
    doDetailBarcode = json['doDetailBarcode'];
    doDetailDrumNo = json['doDetailDrumNo'];
    doDetailPackQty = json['doDetailPackQty'];
    doDetailQty = json['doDetailQty'];
    isCable = json['isCable'];
    materialCode = json['material_code'];
    materialId = json['material_id'].toString();
    packUnit = json['packUnit'];
    unit = json['unit'];
    reqPoQty= json['req_po_qty'] ?? "0";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['checkinDate'] = this.checkinDate;
    data['checkinID'] = this.checkinID;
    data['checkinIsCheckout'] = this.checkinIsCheckout;
    data['checkoutID'] = this.checkoutID;
    data['description'] = this.description;
    data['doDetailBarcode'] = this.doDetailBarcode;
    data['doDetailDrumNo'] = this.doDetailDrumNo;
    data['doDetailPackQty'] = this.doDetailPackQty;
    data['doDetailQty'] = this.doDetailQty;
    data['isCable'] = this.isCable;
    data['material_code'] = this.materialCode;
    data['material_id'] = this.materialId;
    data['packUnit'] = this.packUnit;
    data['unit'] = this.unit;
    data['req_po_qty'] = this.reqPoQty;
    return data;
  }
}
