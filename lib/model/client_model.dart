/*
evClientCurrency
evClientCurrencyConverter
evClientCountry
evClientCity
evClientPostal
evClientState
evClientBusinessRegType 
*/
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
  String? evClientType;
  String? evClientCountry;
  String? evClientCity;
  String? evClientPostal;
  String? evClientState;
  String? evClientBusinessRegType;

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
    this.evClientType,
    this.evClientCountry,
    this.evClientCity,
    this.evClientPostal,
    this.evClientState,
    this.evClientBusinessRegType,
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
      evClientType: json['evClientType'] ?? "",
      evClientCountry: json['evClientCountry'] ?? "",
      evClientCity: json['evClientCity'] ?? "",
      evClientPostal: json['evClientPostal'] ?? "",
      evClientState: json['evClientState'] ?? "",
      evClientBusinessRegType: json['evClientBusinessRegType'] ?? "",
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
      'evClientType': evClientType,
      'evClientCountry': evClientCountry,
      'evClientCity': evClientCity,
      'evClientPostal': evClientPostal,
      'evClientState': evClientState,
      'evClientBusinessRegType': evClientBusinessRegType,
    };
  }
}
