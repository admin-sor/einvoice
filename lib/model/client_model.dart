class ClientModel {
  String? evClientID;
  String? evClientName;
  String? evClientBusinessRegNo;
  String? evClientSstNo;
  String? evClientTinNo;
  String? evClientAddr1;
  String? evClientAddr2;
  String? evClientAddr3;
  String? evClientPic;
  String? evClientEmail;
  String? evClientPhone;

  ClientModel({
    this.evClientID,
    this.evClientName,
    this.evClientBusinessRegNo,
    this.evClientSstNo,
    this.evClientTinNo,
    this.evClientAddr1,
    this.evClientAddr2,
    this.evClientAddr3,
    this.evClientPic,
    this.evClientEmail,
    this.evClientPhone,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      evClientID: json['evClientID'] ?? "0",
      evClientName: json['evClientName'] ?? "",
      evClientBusinessRegNo: json['evClientBusinessRegNo'] ?? "",
      evClientSstNo: json['evClientSstNo'] ?? "",
      evClientTinNo: json['evClientTinNo'] ?? "",
      evClientAddr1: json['evClientAddr1'] ?? "",
      evClientAddr2: json['evClientAddr2'] ?? "",
      evClientAddr3: json['evClientAddr3'] ?? "",
      evClientPic: json['evClientPic'] ?? "",
      evClientEmail: json['evClientEmail'] ?? "",
      evClientPhone: json['evClientPhone'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evClientID': evClientID,
      'evClientName': evClientName,
      'evClientBusinessRegNo': evClientBusinessRegNo,
      'evClientSstNo': evClientSstNo,
      'evClientTinNo': evClientTinNo,
      'evClientAddr1': evClientAddr1,
      'evClientAddr2': evClientAddr2,
      'evClientAddr3': evClientAddr3,
      'evClientPic': evClientPic,
      'evClientEmail': evClientEmail,
      'evClientPhone': evClientPhone,
    };
  }
}
