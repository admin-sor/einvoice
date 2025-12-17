import 'package:dio/dio.dart';
import 'package:sor_inventory/repository/base_repository.dart';

import '../model/supplier_model.dart';

class SupplierRepository extends BaseRepository {
  SupplierRepository({required super.dio});

  Future<List<SupplierModel>> search({
    required String query,
    CancelToken? cancelToken,
  }) async {
    const service = "supplier/search";
    final param = {"query": query};
    final resp =
        await postWoToken(param: param, service: service, cancelToken: cancelToken);
    final List<SupplierModel> list = [];
    if (resp["data"] is List) {
      resp["data"].forEach((e) {
        final model = SupplierModel.fromJson(e);
        list.add(model);
      });
    }
    return list;
  }
}
