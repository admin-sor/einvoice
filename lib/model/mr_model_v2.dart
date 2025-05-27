class MrListModel {
  String? mrDate;
  String? mrSlipNo;
  String? cpName;
  String? scheme;
  String? projectNum;
  String? staffName;
  String? storeName;

  MrListModel({this.mrDate, this.mrSlipNo, this.cpName});

  MrListModel.fromJson(Map<String, dynamic> json) {
    mrDate = json['MrDate'];
    mrSlipNo = json['MrSlipNo'];
    cpName = json['cpName'];
    scheme = json['scheme'] ?? "";
    projectNum = json['project_num'] ?? "";
    staffName = json['staffName'] ?? "";
    storeName = json['storeName'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MrDate'] = mrDate;
    data['MrSlipNo'] = mrSlipNo;
    data['cpName'] = cpName;
    data['scheme'] = scheme;
    data['project_num'] = projectNum;
    data['staffName'] = staffName;
    data['storeName'] = storeName;
    return data;
  }
}
