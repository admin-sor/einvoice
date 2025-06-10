import 'package:sor_inventory/repository/base_repository.dart';

import '../model/client_model.dart';

class ClientRepository extends BaseRepository {
  ClientRepository({required super.dio});

  /// Searches for clients based on a query.
  Future<List<ClientModel>> search({
    required String query,
  }) async {
    const service = "client/search";
    final param = {"query": query};
    final resp = await postWoToken(param: param, service: service);
    // Assuming the response data is a list of client maps
    final List<ClientModel> list = [];
    if (resp["data"] is List) {
      resp["data"].forEach((e) {
        final model = ClientModel.fromJson(e);
        list.add(model);
      });
    }
    return list;
  }

  /// Adds a new client.
  Future<bool> add({
    required String evClientName,
    required String evClientBusinessRegNo,
    required String evClientSstNo,
    required String evClientTinNo,
    required String evClientAddr1,
    required String evClientAddr2,
    required String evClientAddr3,
    required String evClientPic,
    required String evClientEmail,
    required String evClientPhone,
    required String token, // Added token parameter
  }) async {
    const service = "client/add";
    final param = {
      "evClientName": evClientName,
      "evClientBusinessRegNo": evClientBusinessRegNo,
      "evClientSstNo": evClientSstNo,
      "evClientTinNo": evClientTinNo,
      "evClientAddr1": evClientAddr1,
      "evClientAddr2": evClientAddr2,
      "evClientAddr3": evClientAddr3,
      "evClientPic": evClientPic,
      "evClientEmail": evClientEmail,
      "evClientPhone": evClientPhone,
    };
    // Refactored to use post with token
    final resp = await post(param: param, service: service, token: token);
    // Assuming the response data is a single client map
    return true;
  }

  /// Edits an existing client.
  Future<bool> edit({
    required int evClientID, // Assuming int based on typical IDs
    required String evClientName,
    required String evClientBusinessRegNo,
    required String evClientSstNo,
    required String evClientTinNo,
    required String evClientAddr1,
    required String evClientAddr2,
    required String evClientAddr3,
    required String evClientPic,
    required String evClientEmail,
    required String evClientPhone,
    required String token, // Added token parameter
  }) async {
    const service = "client/edit";
    final param = {
      "evClientID": evClientID,
      "evClientName": evClientName,
      "evClientBusinessRegNo": evClientBusinessRegNo,
      "evClientSstNo": evClientSstNo,
      "evClientTinNo": evClientTinNo,
      "evClientAddr1": evClientAddr1,
      "evClientAddr2": evClientAddr2,
      "evClientAddr3": evClientAddr3,
      "evClientPic": evClientPic,
      "evClientEmail": evClientEmail,
      "evClientPhone": evClientPhone,
    };
    // Refactored to use post with token
    final resp = await post(param: param, service: service, token: token);
    // Assuming the response data is a single client map
    return true;
  }

  /// Deletes a client.
  Future<bool> delete({
    required int evClientID, // Assuming int
    required String token, // Added token parameter
  }) async {
    const service = "client/delete";
    final param = {
      "evClientID": evClientID,
    };
    // Refactored to use post with token
    await post(
        param: param,
        service: service,
        token: token); // Assuming successful post means true
    return true; // Or parse response for success status if API returns one
  }
}
