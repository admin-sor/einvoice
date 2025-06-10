class ProductModel {
  String? evProductID;
  String? evProductDescription;
  String? evProductUnit;
  String? evProductPrice;
  String? evProductIsActive;
  String? evProductCreated;

  ProductModel({
    this.evProductID,
    this.evProductDescription,
    this.evProductUnit,
    this.evProductPrice,
    this.evProductIsActive,
    this.evProductCreated,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      evProductID: json['evProductID'] ?? "0",
      evProductDescription: json['evProductDescription'] ?? "",
      evProductUnit: json['evProductUnit'] ?? "",
      evProductPrice: json['evProductPrice'] ?? "0.00",
      evProductIsActive: json['evProductIsActive'] ?? "N",
      evProductCreated: json['evProductCreated'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evProductID': evProductID,
      'evProductDescription': evProductDescription,
      'evProductUnit': evProductUnit,
      'evProductPrice': evProductPrice,
      'evProductIsActive': evProductIsActive,
      'evProductCreated': evProductCreated,
    };
  }
}
