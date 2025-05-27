class MergeMaterialModel {
  String? description;
  String? mergeMaterialBarcode;
  String? mergeMaterialCheckoutID;
  String? mergeMaterialDate;
  String? mergeMaterialDrumNo;
  String? mergeMaterialID;
  String? mergeMaterialIsActive;
  String? mergeMaterialIsCheckOut;
  String? mergeMaterialMaterialID;
  String? mergeMaterialPackQty;
  String? mergeMaterialPackUnitID;
  String? mergeMaterialPrice;
  String? mergeMaterialStoreID;
  String? mergeMaterialUserID;
  String? storeID;
  String? storeName;

  MergeMaterialModel(
      {this.description,
      this.mergeMaterialBarcode,
      this.mergeMaterialCheckoutID,
      this.mergeMaterialDate,
      this.mergeMaterialDrumNo,
      this.mergeMaterialID,
      this.mergeMaterialIsActive,
      this.mergeMaterialIsCheckOut,
      this.mergeMaterialMaterialID,
      this.mergeMaterialPackQty,
      this.mergeMaterialPackUnitID,
      this.mergeMaterialPrice,
      this.mergeMaterialStoreID,
      this.mergeMaterialUserID,
      this.storeID,
      this.storeName});

  MergeMaterialModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    mergeMaterialBarcode = json['mergeMaterialBarcode'];
    mergeMaterialCheckoutID = json['mergeMaterialCheckoutID'];
    mergeMaterialDate = json['mergeMaterialDate'];
    mergeMaterialDrumNo = json['mergeMaterialDrumNo'];
    mergeMaterialID = json['mergeMaterialID'];
    mergeMaterialIsActive = json['mergeMaterialIsActive'];
    mergeMaterialIsCheckOut = json['mergeMaterialIsCheckOut'];
    mergeMaterialMaterialID = json['mergeMaterialMaterialID'];
    mergeMaterialPackQty = json['mergeMaterialPackQty'];
    mergeMaterialPackUnitID = json['mergeMaterialPackUnitID'];
    mergeMaterialPrice = json['mergeMaterialPrice'];
    mergeMaterialStoreID = json['mergeMaterialStoreID'];
    mergeMaterialUserID = json['mergeMaterialUserID'];
    storeID = json['storeID'];
    storeName = json['storeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['mergeMaterialBarcode'] = mergeMaterialBarcode;
    data['mergeMaterialCheckoutID'] = mergeMaterialCheckoutID;
    data['mergeMaterialDate'] = mergeMaterialDate;
    data['mergeMaterialDrumNo'] = mergeMaterialDrumNo;
    data['mergeMaterialID'] = mergeMaterialID;
    data['mergeMaterialIsActive'] = mergeMaterialIsActive;
    data['mergeMaterialIsCheckOut'] = mergeMaterialIsCheckOut;
    data['mergeMaterialMaterialID'] = mergeMaterialMaterialID;
    data['mergeMaterialPackQty'] = mergeMaterialPackQty;
    data['mergeMaterialPackUnitID'] = mergeMaterialPackUnitID;
    data['mergeMaterialPrice'] = mergeMaterialPrice;
    data['mergeMaterialStoreID'] = mergeMaterialStoreID;
    data['mergeMaterialUserID'] = mergeMaterialUserID;
    data['storeID'] = storeID;
    data['storeName'] = storeName;
    return data;
  }
}
