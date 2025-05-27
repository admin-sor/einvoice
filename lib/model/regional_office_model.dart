
class RegionalOfficeModel {
  String? address1;
  String? address2;
  String? address3;
  String? email;
  String? region;
  String? regionCode;
  String? regionId;
  String? tel1;

  RegionalOfficeModel(
      {this.address1,
      this.address2,
      this.address3,
      this.email,
      this.region,
      this.regionCode,
      this.regionId,
      this.tel1});

  RegionalOfficeModel.fromJson(Map<String, dynamic> json) {
    address1 = json['address1'];
    address2 = json['address2'];
    address3 = json['address3'];
    email = json['email'];
    region = json['region'];
    regionCode = json['region_code'];
    regionId = json['region_id'];
    tel1 = json['tel1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address1'] = address1;
    data['address2'] = address2;
    data['address3'] = address3;
    data['email'] = email;
    data['region'] = region;
    data['region_code'] = regionCode;
    data['region_id'] = regionId;
    data['tel1'] = tel1;
    return data;
  }
}
