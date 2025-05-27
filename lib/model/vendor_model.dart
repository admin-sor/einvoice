class VendorModel {
  late String paymentTermName;
  late String vendorAdd1;
  late String vendorAdd2;
  late String vendorAdd3;
  late String vendorCode;
  late String vendorID;
  late String vendorLastPoSequence;
  late String vendorName;
  late String vendorPaymentTermID;
  late String vendorPoYear;
  late String vendorRegNo;
  late String vendorPicName;
  late String vendorPicPhone;
  late String vendorPicEmail;
  late String vendorTerm;

  VendorModel({
    required this.paymentTermName,
    required this.vendorAdd1,
    required this.vendorAdd2,
    required this.vendorAdd3,
    required this.vendorCode,
    required this.vendorID,
    required this.vendorLastPoSequence,
    required this.vendorName,
    required this.vendorPaymentTermID,
    required this.vendorPoYear,
    required this.vendorRegNo,
    this.vendorPicEmail = "",
    this.vendorPicPhone = "",
    this.vendorPicName = "",
    this.vendorTerm = "",
  });

  VendorModel.fromJson(Map<String, dynamic> json) {
    paymentTermName = json['paymentTermName'];
    vendorAdd1 = json['vendorAdd1'];
    vendorAdd2 = json['vendorAdd2'];
    vendorAdd3 = json['vendorAdd3'];
    vendorCode = json['vendorCode'];
    vendorID = json['vendorID'].toString();
    vendorLastPoSequence = json['vendorLastPoSequence'];
    vendorName = json['vendorName'];
    vendorPaymentTermID = json['vendorPaymentTermID'].toString();
    vendorPoYear = json['vendorPoYear'] ?? "";
    vendorRegNo = json['vendorRegNo'] ?? "";
    vendorPicName = json['vendorPicName'] ?? "";
    vendorPicEmail = json['vendorPicEmail'] ?? "";
    vendorPicPhone = json['vendorPicPhone'] ?? "";
    vendorTerm = json['vendorTerm'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['paymentTermName'] = paymentTermName;
    data['vendorAdd1'] = vendorAdd1;
    data['vendorAdd2'] = vendorAdd2;
    data['vendorAdd3'] = vendorAdd3;
    data['vendorCode'] = vendorCode;
    data['vendorID'] = vendorID;
    data['vendorLastPoSequence'] = vendorLastPoSequence;
    data['vendorName'] = vendorName;
    data['vendorPaymentTermID'] = vendorPaymentTermID;
    data['vendorPoYear'] = vendorPoYear;
    data['vendorRegNo'] = vendorRegNo;
    data['vendorPicName'] = vendorPicName;
    data['vendorPicPhone'] = vendorPicPhone;
    data['vendorPicEmail'] = vendorPicEmail;
    data['vendorTerm'] = vendorTerm;
    return data;
  }
}
