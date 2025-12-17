String _stringValue(Map<String, dynamic> json, List<String> keys,
    {String fallback = ""}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      return value.toString();
    }
  }
  return fallback;
}

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
  final String? evInvoiceSupplierID;
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
  final String? evInvoiceValidationDate;

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
    this.evInvoiceSupplierID,
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
    this.evInvoiceValidationDate,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      evInvoiceID: _stringValue(json, const ["evInvoiceID", "invoiceID"]),
      evInvoiceNo: _stringValue(json, const ["evInvoiceNo", "invoiceNo"]),
      evInvoiceLongID:
          _stringValue(json, const ["evInvoiceLongID", "invoiceEvInvoiceID"]),
      evInvoiceUUID: _stringValue(json, const ["evInvoiceUUID"]),
      evInvoiceLastSubmissionDate: _stringValue(
        json,
        const ["evInvoiceLastSubmissionDate", "invoiceLHDNLastUpdated"],
      ),
      evInvoiceIssueDate:
          _stringValue(json, const ["evInvoiceIssueDate", "invoiceDate"]),
      evInvoiceIssueTime: _stringValue(json, const ["evInvoiceIssueTime"]),
      evInvoiceTypeCode: _stringValue(json, const ["evInvoiceTypeCode"]),
      evInvoiceCurrency: _stringValue(json, const ["evInvoiceCurrency"]),
      evInvoicePeriodStartDate:
          _stringValue(json, const ["evInvoicePeriodStartDate"]),
      evInvoicePeriodEndDate:
          _stringValue(json, const ["evInvoicePeriodEndDate"]),
      evInvoicePeriodDescription:
          _stringValue(json, const ["evInvoicePeriodDescription"]),
      evInvoiceCustomerName:
          _stringValue(json, const ["evInvoiceCustomerName"]),
      evInvoiceCustomerPhone:
          _stringValue(json, const ["evInvoiceCustomerPhone"]),
      evInvoiceCustomerEmail:
          _stringValue(json, const ["evInvoiceCustomerEmail"]),
      evInvoiceCustomerCity:
          _stringValue(json, const ["evInvoiceCustomerCity"]),
      evInvoiceCustomerPostal:
          _stringValue(json, const ["evInvoiceCustomerPostal"]),
      evInvoiceCustomerState:
          _stringValue(json, const ["evInvoiceCustomerState"]),
      evInvoiceCustomerCountry:
          _stringValue(json, const ["evInvoiceCustomerCountry"]),
      evInvoiceCustomerAddressLine1:
          _stringValue(json, const ["evInvoiceCustomerAddressLine1"]),
      evInvoiceCustomerAddressLine2:
          _stringValue(json, const ["evInvoiceCustomerAddressLine2"]),
      evInvoiceCustomerAddressLine3:
          _stringValue(json, const ["evInvoiceCustomerAddressLine3"]),
      evInvoiceCustomerIDTIN:
          _stringValue(json, const ["evInvoiceCustomerID_TIN"]),
      evInvoiceCustomerIDBRN:
          _stringValue(json, const ["evInvoiceCustomerID_BRN"]),
      evInvoiceCustomerIDSST:
          _stringValue(json, const ["evInvoiceCustomerID_SST"]),
      evInvoiceSupplierName:
          _stringValue(json, const ["evInvoiceSupplierName", "evsupplierName"]),
      evInvoiceSupplierID:
          _stringValue(json, const ["evInvoiceSupplierID", "invoiceEvSupplierID"]),
      evInvoiceSupplierPhone:
          _stringValue(json, const ["evInvoiceSupplierPhone"]),
      evInvoiceSupplierEmail:
          _stringValue(json, const ["evInvoiceSupplierEmail"]),
      evInvoiceSupplierIndustry:
          _stringValue(json, const ["evInvoiceSupplierIndustry"]),
      evInvoiceSupplierIndustryName:
          _stringValue(json, const ["evInvoiceSupplierIndustryName"]),
      evInvoiceSupplierCity:
          _stringValue(json, const ["evInvoiceSupplierCity"]),
      evInvoiceSupplierPostal:
          _stringValue(json, const ["evInvoiceSupplierPostal"]),
      evInvoiceSupplierState:
          _stringValue(json, const ["evInvoiceSupplierState"]),
      evInvoiceSupplierCountry:
          _stringValue(json, const ["evInvoiceSupplierCountry"]),
      evInvoiceSupplierAddressLine1:
          _stringValue(json, const ["evInvoiceSupplierAddressLine1"]),
      evInvoiceSupplierAddressLine2:
          _stringValue(json, const ["evInvoiceSupplierAddressLine2"]),
      evInvoiceSupplierAddressLine3:
          _stringValue(json, const ["evInvoiceSupplierAddressLine3"]),
      evInvoiceSupplierIDTIN:
          _stringValue(json, const ["evInvoiceSupplierID_TIN"]),
      evInvoiceSupplierIDNRIC:
          _stringValue(json, const ["evInvoiceSupplierID_NRIC"]),
      evInvoiceTaxTotalAmount:
          _stringValue(json, const ["evInvoiceTaxTotalAmount"]),
      evInvoiceTaxTotalTaxable:
          _stringValue(json, const ["evInvoiceTaxTotalTaxable"]),
      evInvoiceTaxTotalCategoryID:
          _stringValue(json, const ["evInvoiceTaxTotalCategoryID"]),
      evInvoiceMonetaryExclusive:
          _stringValue(json, const ["evInvoiceMonetaryExclusive"]),
      evInvoiceMonetaryInclusive:
          _stringValue(json, const ["evInvoiceMonetaryInclusive"]),
      evInvoiceMonetaryPayable:
          _stringValue(json, const ["evInvoiceMonetaryPayable"]),
      evInvoiceStatus:
          _stringValue(json, const ["evInvoiceStatus", "invoiceLHDNStatus"]),
      evInvoiceValidationDate:
          _stringValue(json, const ["evInvoiceValidationDate"]),
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
      'evInvoiceSupplierID': evInvoiceSupplierID,
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
      'evInvoiceValidationDate': evInvoiceValidationDate,
    };
  }
}
