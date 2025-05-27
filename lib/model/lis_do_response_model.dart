class ListDoResponseModel {
  late String doDate;
  late String doID;
  late String doNo;
  late String doStoreID;
  late String doUserID;
  late String doVendorID;
  late String vendorName;
  late String poNo;
  late String poID;
  late String storeName;

  ListDoResponseModel({
    required this.doDate,
    required this.doID,
    required this.doNo,
    required this.doStoreID,
    required this.doUserID,
    required this.doVendorID,
    required this.vendorName,
    required this.poNo,
    required this.poID,
    required this.storeName,
  });

  ListDoResponseModel.fromJson(Map<String, dynamic> json) {
    doDate = json['doDate'];
    doID = json['doID'];
    doNo = json['doNo'];
    doStoreID = json['doStoreID'];
    doUserID = json['doUserID'];
    doVendorID = json['doVendorID'];
    vendorName = json['vendorName'];
    storeName = json['storeName'];
    poNo = json['poNo'];
    poID = json['poID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['doDate'] = doDate;
    data['doID'] = doID;
    data['doNo'] = doNo;
    data['doStoreID'] = doStoreID;
    data['doUserID'] = doUserID;
    data['doVendorID'] = doVendorID;
    data['vendorName'] = vendorName;
    data['storeName'] = storeName;
    data['poNo'] = poNo;
    data['poID'] = poID;
    return data;
  }
}
