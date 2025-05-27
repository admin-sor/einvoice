import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sor_inventory/model/dispose_slip_model.dart';
import 'package:sor_inventory/model/material_return_model_v2.dart';
import 'package:sor_inventory/model/mr_model_v2.dart';
import 'package:sor_inventory/model/scrap_model.dart';

import '../model/contractor_lookup_model.dart';
import '../model/material_return_scan_response.dart';
import '../model/store_model.dart';
import 'base_repository.dart';


class DisposeSlipResponse {
  final Map<String,dynamic> store;
  final List<ScrapModel> list;

  DisposeSlipResponse(this.store, this.list);
}
class DisposeRepository extends BaseRepository {
  DisposeRepository({
    required dio,
  }) : super(dio: dio);

  Future<DisposeSlipResponse> getBySlip(String slipNo) async {
    var param = {"slipNo": slipNo};
    var resp = await postWoToken(param: param, service: "/scrap/by_no");
    var result = List<ScrapModel>.empty(growable: true);
    Map<String,dynamic> sm = {"id":"0","name":""  };
    var first = true;
    resp["data"].forEach((e) {
      if (first){
        sm["id"] = e["storeID"];
        sm["name"]= e["storeName"];
        first = false;
      } 
      result.add(ScrapModel.fromJson(e));
    });
    return DisposeSlipResponse(sm,result);
  }
  Future<List<DisposeSlipModel>> list(String search,String storeID) async {
    var param = {"search": search, "storeID":storeID};
    var resp = await postWoToken(param: param, service: "/scrap/list_slip");
    var result = List<DisposeSlipModel>.empty(growable: true);
    resp["data"].forEach((e) {
      result.add(DisposeSlipModel.fromJson(e));
    });
    return result;
  }
  Future<bool> setDone({
    required String slipNo,
    required String token,
    required String status,
  }) async {
    await post(
        param: {"slipNo": slipNo, "status": status},
        service: "/materialreturn/set_done",
        token: token);
    return true;
  }

  Future<bool> delete({
    required String scrapID,
    required String slipNo,
    required String token,
  }) async {
    var param = {"scrapID": scrapID,  "slipNo": slipNo};
    await post(param: param, token: token, service: "/scrap/delete");
    return true;
  }
  

  Future<List<ScrapModel>> getMaterial(String storeID, String token) async {
    final param = {"storeID": storeID};
    var resp = await post(token: token, param: param, service: "/scrap/by_store");
    var result = List<ScrapModel>.empty(growable: true);
    resp["data"].forEach((e) {
      result.add(ScrapModel.fromJson(e));
    });
    return result;
  }

  Future<String> save(String scrapID, String slipNo, String token, String remark,) async {
    final param = {
      "scrapID": scrapID,
      "remak": remark,
      "slipNo": slipNo
    };
    var resp = await post(token: token, param: param, service: "/scrap/save");
    return resp["slipNo"];
  }

  Future<List<ScrapModel>> get({
    required String slipNo,
  }) async {
    final param = {
      "slipNo": slipNo,
    };
    final resp = await postWoToken(
      param: param,
      service: "/scrap/get",
    );
    final List<ScrapModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(ScrapModel.fromJson(e));
    });
    return list;
  }
}
