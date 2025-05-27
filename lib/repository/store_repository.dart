import 'package:sor_inventory/model/regional_office_model.dart';
import 'package:sor_inventory/repository/base_repository.dart';

import '../model/store_model.dart';

class StoreRepository extends BaseRepository {
  StoreRepository({required super.dio});

  Future<List<RegionalOfficeModel>> getRegional() async {
    const service = "store/get_regional";
    final resp = await postWoToken(param: {}, service: service);
    final List<RegionalOfficeModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      final model = RegionalOfficeModel.fromJson(e);
      list.add(model);
    });
    return list;
  }

  Future<List<StoreModel>> getStoreByUser({
    required String token,
    bool isAll = false,
  }) async {
    String service = "store/get_user_store";
    if (isAll) {
      service = "store/get_user_store/all";
    }
    final resp = await post(param: {}, service: service, token: token);
    final List<StoreModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      final model = StoreModel.fromJson(e);
      list.add(model);
    });
    return list;
  }

  Future<List<StoreModel>> search({
    required String query,
  }) async {
    const service = "store/search";
    final param = {"search": query};
    final resp = await postWoToken(param: param, service: service);
    final List<StoreModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      final model = StoreModel.fromJson(e);
      model.storeLimit = int.parse(resp["store_limit"]);
      list.add(model);
    });
    return list;
  }

  Future<bool> delete({
    required String storeID,
    required String token,
  }) async {
    const service = "store/delete";
    final param = {
      "storeID": storeID,
    };
    await post(param: param, service: service, token: token);
    return true;
  }

  Future<bool> edit({
    required String storeID,
    required String storeName,
    required String storeAdd1,
    required String storeAdd2,
    required String storeAdd3,
    required String storePicName,
    required String storePicEmail,
    required String storePicPhone,
    required String regionID,
    required String token,
  }) async {
    const service = "store/edit";
    final param = {
      "storeID": storeID,
      "storeName": storeName,
      "storeAddress1": storeAdd1,
      "storeAddress2": storeAdd2,
      "storeAddress3": storeAdd3,
      "storePic": storePicName,
      "storeEmail": storePicEmail,
      "storePhone": storePicPhone,
      "regionID": regionID,
    };
    await post(param: param, service: service, token: token);
    return true;
  }

  Future<bool> add({
    required String storeName,
    required String storeAdd1,
    required String storeAdd2,
    required String storeAdd3,
    required String storePicName,
    required String storePicEmail,
    required String storePicPhone,
    required String regionID,
    required String token,
  }) async {
    const service = "store/add";
    final param = {
      "storeName": storeName,
      "storeAddress1": storeAdd1,
      "storeAddress2": storeAdd2,
      "storeAddress3": storeAdd3,
      "storePic": storePicName,
      "storeEmail": storePicEmail,
      "storePhone": storePicPhone,
      "regionID": regionID,
    };
    await post(param: param, service: service, token: token);
    return true;
  }
}
