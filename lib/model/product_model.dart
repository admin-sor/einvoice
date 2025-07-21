class ProductModel {
  String? evProductID;
  String? evProductCode;
  String? evProductDescription;
  String? evProductUnit;
  String? evProductPrice;
  String? evProductIsActive;
  String? evProductCreated;
  String? evProductTaxPercent;
  String? evProductTaxReason;
  String? evProductTaxCategory;
  String? evProductClassification;
  ProductModel({
    this.evProductID,
    this.evProductCode,
    this.evProductDescription,
    this.evProductUnit,
    this.evProductPrice,
    this.evProductIsActive,
    this.evProductCreated,
    this.evProductTaxCategory,
    this.evProductTaxPercent,
    this.evProductTaxReason,
    this.evProductClassification,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      evProductID: json['evProductID'] ?? "0",
      evProductCode: json['evProductCode'] ?? "",
      evProductDescription: json['evProductDescription'] ?? "",
      evProductUnit: json['evProductUnit'] ?? "",
      evProductPrice: json['evProductPrice'] ?? "0.00",
      evProductIsActive: json['evProductIsActive'] ?? "N",
      evProductCreated: json['evProductCreated'] ?? "",
      evProductTaxCategory: json['evProductTaxCategory'] ?? "",
      evProductClassification: json['evProductClassification'] ?? "",
      evProductTaxPercent: json['evProductTaxPercent'] ?? "",
      evProductTaxReason: json['evProductTaxReason'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evProductID': evProductID,
      'evProductCode': evProductCode,
      'evProductDescription': evProductDescription,
      'evProductUnit': evProductUnit,
      'evProductPrice': evProductPrice,
      'evProductIsActive': evProductIsActive,
      'evProductCreated': evProductCreated,
      'evProductTaxReason': evProductTaxReason,
      'evProductTaxPercent': evProductTaxPercent,
      'evProductTaxCategory': evProductTaxCategory,
      'evProductClassification': evProductClassification,
    };
  }
}
