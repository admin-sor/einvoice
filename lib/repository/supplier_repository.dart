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

  Future<List<SupplierModel>> searchWithOwn({
    required String query,
    CancelToken? cancelToken,
  }) async {
    const service = "supplier/search";
    final param = {
      "query": query,
      "with_own": "X",
    };
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

  Future<bool> add({
    required String evSupplierType,
    required String evSupplierName,
    required String evSupplierBusinessRegNo,
    required String evSupplierBusinessRegType,
    required String evSupplierSstNo,
    required String evSupplierTinNo,
    required String evSupplierAddr1,
    required String evSupplierAddr2,
    required String evSupplierAddr3,
    required String evSupplierPic,
    required String evSupplierEmail,
    required String evSupplierPhone,
    required String token,
  }) async {
    const service = "supplier/add";
    final param = {
      "evSupplierType": evSupplierType,
      "evSupplierName": evSupplierName,
      "evSupplierBusinessRegNo": evSupplierBusinessRegNo,
      "evSupplierBusinessRegType": evSupplierBusinessRegType,
      "evSupplierSstNo": evSupplierSstNo,
      "evSupplierTinNo": evSupplierTinNo,
      "evSupplierAddr1": evSupplierAddr1,
      "evSupplierAddr2": evSupplierAddr2,
      "evSupplierAddr3": evSupplierAddr3,
      "evSupplierPic": evSupplierPic,
      "evSupplierEmail": evSupplierEmail,
      "evSupplierPhone": evSupplierPhone,
    };
    await post(param: param, service: service, token: token);
    return true;
  }

  Future<bool> edit({
    required int evSupplierID,
    required String evSupplierType,
    required String evSupplierName,
    required String evSupplierBusinessRegNo,
    required String evSupplierBusinessRegType,
    required String evSupplierSstNo,
    required String evSupplierTinNo,
    required String evSupplierAddr1,
    required String evSupplierAddr2,
    required String evSupplierAddr3,
    required String evSupplierPic,
    required String evSupplierEmail,
    required String evSupplierPhone,
    required String token,
  }) async {
    const service = "supplier/edit";
    final param = {
      "evSupplierID": evSupplierID,
      "evSupplierType": evSupplierType,
      "evSupplierName": evSupplierName,
      "evSupplierBusinessRegNo": evSupplierBusinessRegNo,
      "evSupplierBusinessRegType": evSupplierBusinessRegType,
      "evSupplierSstNo": evSupplierSstNo,
      "evSupplierTinNo": evSupplierTinNo,
      "evSupplierAddr1": evSupplierAddr1,
      "evSupplierAddr2": evSupplierAddr2,
      "evSupplierAddr3": evSupplierAddr3,
      "evSupplierPic": evSupplierPic,
      "evSupplierEmail": evSupplierEmail,
      "evSupplierPhone": evSupplierPhone,
    };
    await post(param: param, service: service, token: token);
    return true;
  }

  Future<bool> delete({
    required int evSupplierID,
    required String token,
  }) async {
    const service = "supplier/delete";
    final param = {
      "evSupplierID": evSupplierID,
    };
    await post(param: param, service: service, token: token);
    return true;
  }
}
