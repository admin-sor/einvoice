class StoreModel {
  String? storeAddress1;
  String? storeAddress2;
  String? storeAddress3;
  String? storeEmail;
  String? storeID;
  String? storeIsActive;
  String? storeName;
  String? storePIC;
  String? storePhone;
  String? region;
  String? region_id;
  String? isDefault;
  int? storeLimit;

  StoreModel({
    this.storeAddress1,
    this.storeAddress2,
    this.storeAddress3,
    this.storeEmail,
    this.storeID,
    this.storeIsActive,
    this.storeName,
    this.storePIC,
    this.storePhone,
    this.region,
    this.region_id,
    this.isDefault,
    this.storeLimit =0
  });

  StoreModel.fromJson(Map<String, dynamic> json) {
    storeAddress1 = json['storeAddress1'];
    storeAddress2 = json['storeAddress2'];
    storeAddress3 = json['storeAddress3'];
    storeEmail = json['storeEmail'];
    storeID = json['storeID'];
    storeIsActive = json['storeIsActive'];
    storeName = json['storeName'];
    storePIC = json['storePIC'];
    storePhone = json['storePhone'];
    region = json['region'];
    region_id = json['region_id'];
    isDefault = json['isDefault'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['storeAddress1'] = storeAddress1;
    data['storeAddress2'] = storeAddress2;
    data['storeAddress3'] = storeAddress3;
    data['storeEmail'] = storeEmail;
    data['storeID'] = storeID;
    data['storeIsActive'] = storeIsActive;
    data['storeName'] = storeName;
    data['storePIC'] = storePIC;
    data['storePhone'] = storePhone;
    data['region'] = region;
    data['region_id'] = region_id;
    data['store_limit'] = storeLimit;
    return data;
  }
}
