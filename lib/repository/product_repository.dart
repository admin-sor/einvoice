import 'package:sor_inventory/repository/base_repository.dart';
import '../model/product_model.dart';

class ProductRepository extends BaseRepository {
  ProductRepository({required super.dio});

  /// Searches for products based on a query.
  Future<List<ProductModel>> search({
    required String query,
  }) async {
    const service = "product/search";
    final param = {"query": query};
    final resp = await postWoToken(param: param, service: service);
    // Assuming the response data is a list of product maps
    final List<ProductModel> list = [];
    if (resp["data"] is List) {
      resp["data"].forEach((e) {
        final model = ProductModel.fromJson(e);
        list.add(model);
      });
    }
    return list;
  }

  /// Edits an existing product.
  Future<bool> edit({
    required String evProductID,
    required String evProductCode,
    required String evProductDescription,
    required String evProductUnit,
    required String evProductPrice,
    required String evProductTaxCategory,
    required String evProductClassification,
    required String evProductTaxPercent,
    required String evProductTaxReason,
    required String token,
  }) async {
    const service = "product/edit";
    final param = {
      "evProductDescription": evProductDescription,
      "evProductID": evProductID,
      "evProductCode": evProductCode,
      "evProductUnit": evProductUnit,
      "evProductPrice": evProductPrice,
      "evProductTaxReason": evProductTaxReason,
      "evProductTaxPercent": evProductTaxPercent,
      "evProductClassification": evProductClassification,
      "evProductTaxCategory": evProductTaxCategory,
    };
    await post(param: param, service: service, token: token);
    return true;
  }

  /// Deletes a product.
  Future<bool> delete({
    required int evProductID,
    required String token,
  }) async {
    const service = "product/delete";
    final param = {
      "evProductID": evProductID,
    };
    await post(param: param, service: service, token: token);
    return true;
  }
}
