import 'package:sor_inventory/model/material_stock_model.dart';
import 'package:sor_inventory/model/materialmd_model.dart';
import 'package:sor_inventory/repository/base_repository.dart';

class MaterialMdRepository extends BaseRepository {
  MaterialMdRepository({required super.dio});

  Future<List<MaterialStockModel>> stock({
    required String materialID,
    required String storeID,
    required String token,
  }) async {
    final service = "materialmd/material_stock/$materialID/$storeID";
    final resp = await post(
      param: {},
      service: service,
      token: token,
    );
    List<MaterialStockModel> result = List.empty(growable: true);
    resp["data"].forEach((e) {
      final obj = MaterialStockModel.fromJson(e);
      result.add(obj);
    });
    return result;
  }

  Future<List<MaterialMdModel>> search({
    required String query,
    required String token,
  }) async {
    const service = "materialmd/search";
    final param = {
      "query": query,
    };
    final resp = await post(
      param: param,
      service: service,
      token: token,
    );
    List<MaterialMdModel> result = List.empty(growable: true);
    resp["data"].forEach((e) {
      final obj = MaterialMdModel.fromJson(e);
      result.add(obj);
    });
    return result;
  }

  Future<bool> editPrice({
    required String token,
    required String refID,
    required String xID,
    required String refType,
    required String materialId,
    required String price,
    required String isAll,
    required String storeID,
  }) async {
    const service = "materialmd/edit_price";
    final param = {
      "ref": refType,
      "refID": refID,
      "xID": xID,
      "material_id": materialId,
      "price": price,
      "isAll": isAll,
      "storeID": storeID,
    };

    await post(param: param, service: service, token: token);
    return true;
  }

  Future<MaterialMdModel> edit({
    required String token,
    required String description,
    required String isCable,
    required String materialCode,
    required String materialId,
    required String packQty,
    required String packUnitId,
    required String unitId,
  }) async {
    const service = "materialmd/edit";
    final param = {
      "description": description,
      "is_cable": isCable,
      "material_code": materialCode,
      "material_id": materialId,
      "pack_qty": packQty,
      "pack_unit_id": packUnitId,
      "unit_id": unitId
    };

    final resp = await post(param: param, service: service, token: token);

    final result = MaterialMdModel.fromJson(resp["data"]);
    return result;
  }

  Future<bool> delete({
    required String token,
    required String materialId,
  }) async {
    const service = "materialmd/delete";
    final param = {
      "material_id": materialId,
    };

    await post(param: param, service: service, token: token);
    return true;
  }
}
