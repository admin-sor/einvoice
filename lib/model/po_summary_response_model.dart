class PoSummaryResponseModel {
  late String paymentTermCode;
  late String paymentTermName;
  late String poCreated;
  late String poDate;
  late String poDeliveryDate;
  late String poID;
  late String poIsActive;
  late String poIsReceived;
  late String poNo;
  late String poPaymentTermID;
  late String poVendorID;
  late String vendorName;

  PoSummaryResponseModel(
      {required this.paymentTermCode,
      required this.paymentTermName,
      required this.poCreated,
      required this.poDate,
      required this.poDeliveryDate,
      required this.poID,
      required this.poIsActive,
      required this.poIsReceived,
      required this.poNo,
      required this.poPaymentTermID,
      required this.poVendorID,
      required this.vendorName});

  PoSummaryResponseModel.fromJson(Map<String, dynamic> json) {
    paymentTermCode = json['paymentTermCode'];
    paymentTermName = json['paymentTermName'];
    poCreated = json['poCreated'];
    poDate = json['poDate'];
    poDeliveryDate = json['poDeliveryDate'];
    poID = json['poID'];
    poIsActive = json['poIsActive'];
    poIsReceived = json['poIsReceived'];
    poNo = json['poNo'];
    poPaymentTermID = json['poPaymentTermID'];
    poVendorID = json['poVendorID'];
    vendorName = json['vendorName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentTermCode'] = paymentTermCode;
    data['paymentTermName'] = paymentTermName;
    data['poCreated'] = poCreated;
    data['poDate'] = poDate;
    data['poDeliveryDate'] = poDeliveryDate;
    data['poID'] = poID;
    data['poIsActive'] = poIsActive;
    data['poIsReceived'] = poIsReceived;
    data['poNo'] = poNo;
    data['poPaymentTermID'] = poPaymentTermID;
    data['poVendorID'] = poVendorID;
    data['vendorName'] = vendorName;
    return data;
  }
}
