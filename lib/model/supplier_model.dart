class SupplierModel {
  String? evSupplierID;
  String? evSupplierName;
  String? evSupplierType;
  String? evSupplierBusinessRegNo;
  String? evSupplierSstNo;
  String? evSupplierTinNo;
  String? evSupplierAddr1;
  String? evSupplierAddr2;
  String? evSupplierAddr3;
  String? evSupplierPic;
  String? evSupplierEmail;
  String? evSupplierPhone;
  String? evSupplierIsActive;
  String? evSupplierCurrency;
  String? evSupplierCurrencyConverter;
  String? evSupplierCountry;
  String? evSupplierIndustryClassificationCode;
  String? evSupplierCity;
  String? evSupplierPostal;
  String? evSupplierState;
  String? evSupplierIndustryClassificationName;
  String? evSupplierInvoiceType;
  String? evSupplierCountryTaxCode;
  String? evSupplierBusinessRegType;
  String? evSupplierBankName;
  String? evSupplierBankNo;

  SupplierModel({
    this.evSupplierID,
    this.evSupplierName,
    this.evSupplierType,
    this.evSupplierBusinessRegNo,
    this.evSupplierSstNo,
    this.evSupplierTinNo,
    this.evSupplierAddr1,
    this.evSupplierAddr2,
    this.evSupplierAddr3,
    this.evSupplierPic,
    this.evSupplierEmail,
    this.evSupplierPhone,
    this.evSupplierIsActive,
    this.evSupplierCurrency,
    this.evSupplierCurrencyConverter,
    this.evSupplierCountry,
    this.evSupplierIndustryClassificationCode,
    this.evSupplierCity,
    this.evSupplierPostal,
    this.evSupplierState,
    this.evSupplierIndustryClassificationName,
    this.evSupplierInvoiceType,
    this.evSupplierCountryTaxCode,
    this.evSupplierBusinessRegType,
    this.evSupplierBankName,
    this.evSupplierBankNo,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    String? _string(dynamic v) => v?.toString();
    return SupplierModel(
      evSupplierID: _string(json['evsupplierID']) ?? "0",
      evSupplierName: _string(json['evsupplierName']) ?? "",
      evSupplierType: _string(json['evsupplierType']),
      evSupplierBusinessRegNo: _string(json['evsupplierBusinessRegNo']),
      evSupplierSstNo: _string(json['evsupplierSstNo']),
      evSupplierTinNo: _string(json['evsupplierTinNo']),
      evSupplierAddr1: _string(json['evsupplierAddr1']),
      evSupplierAddr2: _string(json['evsupplierAddr2']),
      evSupplierAddr3: _string(json['evsupplierAddr3']),
      evSupplierPic: _string(json['evsupplierPic']),
      evSupplierEmail: _string(json['evsupplierEmail']),
      evSupplierPhone: _string(json['evsupplierPhone']),
      evSupplierIsActive: _string(json['evsupplierIsActive']),
      evSupplierCurrency: _string(json['evsupplierCurrency']),
      evSupplierCurrencyConverter: _string(json['evsupplierCurrencyConverter']),
      evSupplierCountry: _string(json['evsupplierCountry']),
      evSupplierIndustryClassificationCode:
          _string(json['evsupplierIndustryClassificationCode']),
      evSupplierCity: _string(json['evsupplierCity']),
      evSupplierPostal: _string(json['evsupplierPostal']),
      evSupplierState: _string(json['evsupplierState']),
      evSupplierIndustryClassificationName:
          _string(json['evsupplierIndustryClassificationName']),
      evSupplierInvoiceType: _string(json['evsupplierInvoiceType']),
      evSupplierCountryTaxCode: _string(json['evsupplierCountryTaxCode']),
      evSupplierBusinessRegType: _string(json['evsupplierBusinessRegType']),
      evSupplierBankName: _string(json['evsupplierBankName']),
      evSupplierBankNo: _string(json['evsupplierBankNo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evsupplierID': evSupplierID,
      'evsupplierName': evSupplierName,
      'evsupplierType': evSupplierType,
      'evsupplierBusinessRegNo': evSupplierBusinessRegNo,
      'evsupplierSstNo': evSupplierSstNo,
      'evsupplierTinNo': evSupplierTinNo,
      'evsupplierAddr1': evSupplierAddr1,
      'evsupplierAddr2': evSupplierAddr2,
      'evsupplierAddr3': evSupplierAddr3,
      'evsupplierPic': evSupplierPic,
      'evsupplierEmail': evSupplierEmail,
      'evsupplierPhone': evSupplierPhone,
      'evsupplierIsActive': evSupplierIsActive,
      'evsupplierCurrency': evSupplierCurrency,
      'evsupplierCurrencyConverter': evSupplierCurrencyConverter,
      'evsupplierCountry': evSupplierCountry,
      'evsupplierIndustryClassificationCode':
          evSupplierIndustryClassificationCode,
      'evsupplierCity': evSupplierCity,
      'evsupplierPostal': evSupplierPostal,
      'evsupplierState': evSupplierState,
      'evsupplierIndustryClassificationName':
          evSupplierIndustryClassificationName,
      'evsupplierInvoiceType': evSupplierInvoiceType,
      'evsupplierCountryTaxCode': evSupplierCountryTaxCode,
      'evsupplierBusinessRegType': evSupplierBusinessRegType,
      'evsupplierBankName': evSupplierBankName,
      'evsupplierBankNo': evSupplierBankNo,
    };
  }
}
