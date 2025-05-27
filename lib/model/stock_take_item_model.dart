class StockItemInfoModel {
  String? checkinAddOnCode;
  String? checkinAddOnMacAddress;
  String? checkinAddOnSerialNo;
  String? checkinCheckoutQty;
  String? checkinDate;
  String? checkinID;
  String? checkinInternalCode;
  String? checkinItemID;
  String? checkinQty;
  String? checkinStoreID;
  String? checkinUserID;
  String? itemDescription;
  String? itemName;
  String? itemUnit;

  StockItemInfoModel(
      {this.checkinAddOnCode,
      this.checkinAddOnMacAddress,
      this.checkinAddOnSerialNo,
      this.checkinCheckoutQty,
      this.checkinDate,
      this.checkinID,
      this.checkinInternalCode,
      this.checkinItemID,
      this.checkinQty,
      this.checkinStoreID,
      this.checkinUserID,
      this.itemDescription,
      this.itemName,
      this.itemUnit});

  StockItemInfoModel.fromJson(Map<String, dynamic> json) {
    checkinAddOnCode = json['checkinAddOnCode'];
    checkinAddOnMacAddress = json['checkinAddOnMacAddress'];
    checkinAddOnSerialNo = json['checkinAddOnSerialNo'];
    checkinCheckoutQty = json['checkinCheckoutQty'];
    checkinDate = json['checkinDate'];
    checkinID = json['checkinID'];
    checkinInternalCode = json['checkinInternalCode'];
    checkinItemID = json['checkinItemID'];
    checkinQty = json['checkinQty'];
    checkinStoreID = json['checkinStoreID'];
    checkinUserID = json['checkinUserID'];
    itemDescription = json['itemDescription'];
    itemName = json['itemName'];
    itemUnit = json['itemUnit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['checkinAddOnCode'] = checkinAddOnCode;
    data['checkinAddOnMacAddress'] = checkinAddOnMacAddress;
    data['checkinAddOnSerialNo'] = checkinAddOnSerialNo;
    data['checkinCheckoutQty'] = checkinCheckoutQty;
    data['checkinDate'] = checkinDate;
    data['checkinID'] = checkinID;
    data['checkinInternalCode'] = checkinInternalCode;
    data['checkinItemID'] = checkinItemID;
    data['checkinQty'] = checkinQty;
    data['checkinStoreID'] = checkinStoreID;
    data['checkinUserID'] = checkinUserID;
    data['itemDescription'] = itemDescription;
    data['itemName'] = itemName;
    data['itemUnit'] = itemUnit;
    return data;
  }
}
