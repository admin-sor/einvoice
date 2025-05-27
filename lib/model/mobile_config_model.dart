class MobileConfigModel {
  late String mobileConfigAutoPo;
  late String mobileconfigID;

  MobileConfigModel({
    required this.mobileConfigAutoPo,
    required this.mobileconfigID,
  });

  MobileConfigModel.fromJson(Map<String, dynamic> json) {
    mobileConfigAutoPo = json['mobileConfigAutoPo'];
    mobileconfigID = json['mobileconfigID'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobileConfigAutoPo'] = mobileConfigAutoPo;
    data['mobileconfigID'] = mobileconfigID;
    return data;
  }
}
