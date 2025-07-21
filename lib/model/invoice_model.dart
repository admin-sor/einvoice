class InvoiceModel {
  final String evInvoiceID;
  final String evInvoiceNo;
  final String? evInvoiceLastSubmissionDate;
  final String? evInvoiceLongID;
  final String? evInvoiceUUID;
  final String evInvoiceIssueDate;
  final String evInvoiceIssueTime;
  final String evInvoiceTypeCode;
  final String evInvoiceCurrency;
  final String evInvoicePeriodStartDate;
  final String evInvoicePeriodEndDate;
  final String evInvoicePeriodDescription;
  final String evInvoiceCustomerName;
  final String evInvoiceCustomerPhone;
  final String evInvoiceCustomerEmail;
  final String evInvoiceCustomerCity;
  final String evInvoiceCustomerPostal;
  final String evInvoiceCustomerState;
  final String evInvoiceCustomerCountry;
  final String evInvoiceCustomerAddressLine1;
  final String evInvoiceCustomerAddressLine2;
  final String? evInvoiceCustomerAddressLine3;
  final String evInvoiceCustomerIDTIN;
  final String evInvoiceCustomerIDBRN;
  final String? evInvoiceCustomerIDSST;
  final String evInvoiceSupplierName;
  final String evInvoiceSupplierPhone;
  final String evInvoiceSupplierEmail;
  final String evInvoiceSupplierIndustry;
  final String evInvoiceSupplierIndustryName;
  final String evInvoiceSupplierCity;
  final String evInvoiceSupplierPostal;
  final String evInvoiceSupplierState;
  final String evInvoiceSupplierCountry;
  final String evInvoiceSupplierAddressLine1;
  final String evInvoiceSupplierAddressLine2;
  final String? evInvoiceSupplierAddressLine3;
  final String evInvoiceSupplierIDTIN;
  final String evInvoiceSupplierIDNRIC;
  final String evInvoiceTaxTotalAmount;
  final String evInvoiceTaxTotalTaxable;
  final String evInvoiceTaxTotalCategoryID;
  final String evInvoiceMonetaryExclusive;
  final String evInvoiceMonetaryInclusive;
  final String evInvoiceMonetaryPayable;
  final String evInvoiceStatus;

  InvoiceModel({
    required this.evInvoiceID,
    required this.evInvoiceNo,
    required this.evInvoiceLastSubmissionDate,
    required this.evInvoiceLongID,
    required this.evInvoiceUUID,
    required this.evInvoiceIssueDate,
    required this.evInvoiceIssueTime,
    required this.evInvoiceTypeCode,
    required this.evInvoiceCurrency,
    required this.evInvoicePeriodStartDate,
    required this.evInvoicePeriodEndDate,
    required this.evInvoicePeriodDescription,
    required this.evInvoiceCustomerName,
    required this.evInvoiceCustomerPhone,
    required this.evInvoiceCustomerEmail,
    required this.evInvoiceCustomerCity,
    required this.evInvoiceCustomerPostal,
    required this.evInvoiceCustomerState,
    required this.evInvoiceCustomerCountry,
    required this.evInvoiceCustomerAddressLine1,
    required this.evInvoiceCustomerAddressLine2,
    this.evInvoiceCustomerAddressLine3,
    required this.evInvoiceCustomerIDTIN,
    required this.evInvoiceCustomerIDBRN,
    this.evInvoiceCustomerIDSST,
    required this.evInvoiceSupplierName,
    required this.evInvoiceSupplierPhone,
    required this.evInvoiceSupplierEmail,
    required this.evInvoiceSupplierIndustry,
    required this.evInvoiceSupplierIndustryName,
    required this.evInvoiceSupplierCity,
    required this.evInvoiceSupplierPostal,
    required this.evInvoiceSupplierState,
    required this.evInvoiceSupplierCountry,
    required this.evInvoiceSupplierAddressLine1,
    required this.evInvoiceSupplierAddressLine2,
    this.evInvoiceSupplierAddressLine3,
    required this.evInvoiceSupplierIDTIN,
    required this.evInvoiceSupplierIDNRIC,
    required this.evInvoiceTaxTotalAmount,
    required this.evInvoiceTaxTotalTaxable,
    required this.evInvoiceTaxTotalCategoryID,
    required this.evInvoiceMonetaryExclusive,
    required this.evInvoiceMonetaryInclusive,
    required this.evInvoiceMonetaryPayable,
    required this.evInvoiceStatus,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      evInvoiceID: json['evInvoiceID'] as String,
      evInvoiceNo: json['evInvoiceNo'] as String,
      evInvoiceLongID: json['evInvoiceLongID'] ?? "",
      evInvoiceUUID: json['evInvoiceUUID'] ?? "",
      evInvoiceLastSubmissionDate: json['evInvoiceLastSubmissionDate'] ?? "",
      evInvoiceIssueDate: json['evInvoiceIssueDate'] as String,
      evInvoiceIssueTime: json['evInvoiceIssueTime'] as String,
      evInvoiceTypeCode: json['evInvoiceTypeCode'] as String,
      evInvoiceCurrency: json['evInvoiceCurrency'] as String,
      evInvoicePeriodStartDate: json['evInvoicePeriodStartDate'] as String,
      evInvoicePeriodEndDate: json['evInvoicePeriodEndDate'] as String,
      evInvoicePeriodDescription: json['evInvoicePeriodDescription'] as String,
      evInvoiceCustomerName: json['evInvoiceCustomerName'] as String,
      evInvoiceCustomerPhone: json['evInvoiceCustomerPhone'] as String,
      evInvoiceCustomerEmail: json['evInvoiceCustomerEmail'] as String,
      evInvoiceCustomerCity: json['evInvoiceCustomerCity'] as String,
      evInvoiceCustomerPostal: json['evInvoiceCustomerPostal'] as String,
      evInvoiceCustomerState: json['evInvoiceCustomerState'] as String,
      evInvoiceCustomerCountry: json['evInvoiceCustomerCountry'] as String,
      evInvoiceCustomerAddressLine1:
          json['evInvoiceCustomerAddressLine1'] ?? "",
      evInvoiceCustomerAddressLine2:
          json['evInvoiceCustomerAddressLine2'] ?? "",
      evInvoiceCustomerAddressLine3:
          json['evInvoiceCustomerAddressLine3'] ?? "",
      evInvoiceCustomerIDTIN: json['evInvoiceCustomerID_TIN'] ?? "",
      evInvoiceCustomerIDBRN: json['evInvoiceCustomerID_BRN'] ?? "",
      evInvoiceCustomerIDSST: json['evInvoiceCustomerID_SST'] ?? "",
      evInvoiceSupplierName: json['evInvoiceSupplierName'] as String,
      evInvoiceSupplierPhone: json['evInvoiceSupplierPhone'] as String,
      evInvoiceSupplierEmail: json['evInvoiceSupplierEmail'] as String,
      evInvoiceSupplierIndustry: json['evInvoiceSupplierIndustry'] as String,
      evInvoiceSupplierIndustryName:
          json['evInvoiceSupplierIndustryName'] as String,
      evInvoiceSupplierCity: json['evInvoiceSupplierCity'] as String,
      evInvoiceSupplierPostal: json['evInvoiceSupplierPostal'] as String,
      evInvoiceSupplierState: json['evInvoiceSupplierState'] as String,
      evInvoiceSupplierCountry: json['evInvoiceSupplierCountry'] as String,
      evInvoiceSupplierAddressLine1:
          json['evInvoiceSupplierAddressLine1'] ?? "",
      evInvoiceSupplierAddressLine2:
          json['evInvoiceSupplierAddressLine2'] ?? "",
      evInvoiceSupplierAddressLine3:
          json['evInvoiceSupplierAddressLine3'] ?? "",
      evInvoiceSupplierIDTIN: json['evInvoiceSupplierID_TIN'] ?? "",
      evInvoiceSupplierIDNRIC: json['evInvoiceSupplierID_NRIC'] ?? "",
      evInvoiceTaxTotalAmount: json['evInvoiceTaxTotalAmount'] as String,
      evInvoiceTaxTotalTaxable: json['evInvoiceTaxTotalTaxable'] as String,
      evInvoiceTaxTotalCategoryID:
          json['evInvoiceTaxTotalCategoryID'] as String,
      evInvoiceMonetaryExclusive: json['evInvoiceMonetaryExclusive'] as String,
      evInvoiceMonetaryInclusive: json['evInvoiceMonetaryInclusive'] as String,
      evInvoiceMonetaryPayable: json['evInvoiceMonetaryPayable'] as String,
      evInvoiceStatus: json['evInvoiceStatus'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evInvoiceID': evInvoiceID,
      'evInvoiceNo': evInvoiceNo,
      'evInvoiceLongID': evInvoiceLongID,
      'evInvoiceUUID': evInvoiceUUID,
      'evInvoiceLastSubmissionDate': evInvoiceLastSubmissionDate,
      'evInvoiceIssueDate': evInvoiceIssueDate,
      'evInvoiceIssueTime': evInvoiceIssueTime,
      'evInvoiceTypeCode': evInvoiceTypeCode,
      'evInvoiceCurrency': evInvoiceCurrency,
      'evInvoicePeriodStartDate': evInvoicePeriodStartDate,
      'evInvoicePeriodEndDate': evInvoicePeriodEndDate,
      'evInvoicePeriodDescription': evInvoicePeriodDescription,
      'evInvoiceCustomerName': evInvoiceCustomerName,
      'evInvoiceCustomerPhone': evInvoiceCustomerPhone,
      'evInvoiceCustomerEmail': evInvoiceCustomerEmail,
      'evInvoiceCustomerCity': evInvoiceCustomerCity,
      'evInvoiceCustomerPostal': evInvoiceCustomerPostal,
      'evInvoiceCustomerState': evInvoiceCustomerState,
      'evInvoiceCustomerCountry': evInvoiceCustomerCountry,
      'evInvoiceCustomerAddressLine1': evInvoiceCustomerAddressLine1,
      'evInvoiceCustomerAddressLine2': evInvoiceCustomerAddressLine2,
      'evInvoiceCustomerAddressLine3': evInvoiceCustomerAddressLine3,
      'evInvoiceCustomerID_TIN': evInvoiceCustomerIDTIN,
      'evInvoiceCustomerID_BRN': evInvoiceCustomerIDBRN,
      'evInvoiceCustomerID_SST': evInvoiceCustomerIDSST,
      'evInvoiceSupplierName': evInvoiceSupplierName,
      'evInvoiceSupplierPhone': evInvoiceSupplierPhone,
      'evInvoiceSupplierEmail': evInvoiceSupplierEmail,
      'evInvoiceSupplierIndustry': evInvoiceSupplierIndustry,
      'evInvoiceSupplierIndustryName': evInvoiceSupplierIndustryName,
      'evInvoiceSupplierCity': evInvoiceSupplierCity,
      'evInvoiceSupplierPostal': evInvoiceSupplierPostal,
      'evInvoiceSupplierState': evInvoiceSupplierState,
      'evInvoiceSupplierCountry': evInvoiceSupplierCountry,
      'evInvoiceSupplierAddressLine1': evInvoiceSupplierAddressLine1,
      'evInvoiceSupplierAddressLine2': evInvoiceSupplierAddressLine2,
      'evInvoiceSupplierAddressLine3': evInvoiceSupplierAddressLine3,
      'evInvoiceSupplierID_TIN': evInvoiceSupplierIDTIN,
      'evInvoiceSupplierID_NRIC': evInvoiceSupplierIDNRIC,
      'evInvoiceTaxTotalAmount': evInvoiceTaxTotalAmount,
      'evInvoiceTaxTotalTaxable': evInvoiceTaxTotalTaxable,
      'evInvoiceTaxTotalCategoryID': evInvoiceTaxTotalCategoryID,
      'evInvoiceMonetaryExclusive': evInvoiceMonetaryExclusive,
      'evInvoiceMonetaryInclusive': evInvoiceMonetaryInclusive,
      'evInvoiceMonetaryPayable': evInvoiceMonetaryPayable,
      'evInvoiceStatus': evInvoiceStatus,
    };
  }
}
