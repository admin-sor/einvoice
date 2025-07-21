class InvoiceV2Model {
  final String invoiceID;
  final String invoiceNo;
  final String invoiceDate;
  final String invoiceEvClientID;
  final String evClientName;
  final String invoiceIsActive;
  final String invoiceUserID;
  final String invoiceCreated;
  final String invoiceLastUpdated;
  final String invoicePaymentTermID;
  final String invoiceTerm;
  final String invoiceEvInvoiceID;
  final String invoiceLHDNStatus;
  final String invoiceLHDNLastUpdated;
  final String validationDate;
  InvoiceV2Model({
    required this.invoiceID,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.invoiceEvClientID,
    required this.evClientName,
    required this.invoiceIsActive,
    required this.invoiceUserID,
    required this.invoiceCreated,
    required this.invoiceLastUpdated,
    required this.invoicePaymentTermID,
    required this.invoiceTerm,
    required this.invoiceEvInvoiceID,
    required this.invoiceLHDNLastUpdated,
    required this.invoiceLHDNStatus,
    required this.validationDate,
  });

  factory InvoiceV2Model.fromJson(Map<String, dynamic> json) {
    return InvoiceV2Model(
      invoiceID: json['invoiceID'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      invoiceDate: json['invoiceDate'] ?? '',
      validationDate: json['evInvoiceValidationDate'] ?? '',
      invoiceEvClientID: json['invoiceEvClientID'] ?? '',
      evClientName: json['evClientName'] ?? '',
      invoiceIsActive: json['invoiceIsActive'] ?? '',
      invoiceUserID: json['invoiceUserID'] ?? '',
      invoiceCreated: json['invoiceCreated'] ?? '',
      invoiceLastUpdated: json['invoiceLastUpdated'] ?? '',
      invoicePaymentTermID: json['invoicePaymentTermID'] ?? '',
      invoiceTerm: json['invoiceTerm'] ?? '',
      invoiceLHDNStatus: json['invoiceLHDNStatus'] ?? '',
      invoiceLHDNLastUpdated: json['invoiceLHDNLastUpdated'] ?? '',
      invoiceEvInvoiceID: json['invoiceEvInvoiceID'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceID': invoiceID,
      'invoiceNo': invoiceNo,
      'invoiceDate': invoiceDate,
      'evInvoiceValidationDate': validationDate,
      'invoiceEvClientID': invoiceEvClientID,
      'evClientName': evClientName,
      'invoiceIsActive': invoiceIsActive,
      'invoiceUserID': invoiceUserID,
      'invoiceCreated': invoiceCreated,
      'invoiceLastUpdated': invoiceLastUpdated,
      'invoicePaymentTermID': invoicePaymentTermID,
      'invoiceTerm': invoiceTerm,
    };
  }
}

class InvoiceDetailModel {
  final String invoiceDetailID;
  final String invoiceDetailInvoiceID;
  final String invoiceDetailEvProductID;
  final String evProductCode;
  final String evProductDescription;
  final String invoiceDetailQty;
  final String invoiceDetailPrice;
  final String invoiceDetailUnit;
  final String invoiceDetailIsActive;

  InvoiceDetailModel({
    required this.invoiceDetailID,
    required this.invoiceDetailInvoiceID,
    required this.invoiceDetailEvProductID,
    required this.evProductCode,
    required this.invoiceDetailQty,
    required this.invoiceDetailPrice,
    required this.invoiceDetailUnit,
    required this.invoiceDetailIsActive,
    required this.evProductDescription,
  });

  factory InvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailModel(
      invoiceDetailID: json['invoiceDetailID'] ?? '',
      invoiceDetailInvoiceID: json['invoiceDetailInvoiceID'] ?? '',
      invoiceDetailEvProductID: json['invoiceDetailEvProductID'] ?? '',
      evProductCode: json['evProductCode'] ?? '',
      invoiceDetailQty: json['invoiceDetailQty'] ?? '',
      invoiceDetailPrice: json['invoiceDetailPrice'] ?? '',
      invoiceDetailUnit: json['invoiceDetailUnit'] ?? '',
      invoiceDetailIsActive: json['invoiceDetailIsActive'] ?? '',
      evProductDescription: json['evProductDescription'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceDetailID': invoiceDetailID,
      'invoiceDetailInvoiceID': invoiceDetailInvoiceID,
      'invoiceDetailEvProductID': invoiceDetailEvProductID,
      'evProductCode': evProductCode,
      'invoiceDetailQty': invoiceDetailQty,
      'invoiceDetailPrice': invoiceDetailPrice,
      'invoiceDetailUnit': invoiceDetailUnit,
      'invoiceDetailIsActive': invoiceDetailIsActive,
      'evProductDescription': evProductDescription,
    };
  }
}
