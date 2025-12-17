class MobileConfigModel {
  late String mobileConfigAutoInvoice;
  late String mobileconfigID;

  MobileConfigModel({
    required this.mobileConfigAutoInvoice,
    required this.mobileconfigID,
  });

  MobileConfigModel.fromJson(Map<String, dynamic> json) {
    mobileConfigAutoInvoice = json['mobileConfigAutoInvoice'];
    mobileconfigID = json['mobileconfigID'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobileConfigAutoInvoice'] = mobileConfigAutoInvoice;
    data['mobileconfigID'] = mobileconfigID;
    return data;
  }
}
