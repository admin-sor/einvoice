import 'package:sor_inventory/repository/base_repository.dart';

import '../model/adm_acl_model.dart';

class AdminAcl extends BaseRepository {
  AdminAcl({required super.dio});

  Future<List<InvAclScreen>> listScreen(String invSecLevelID) async {
    const service = "sys/auth/adm_screen";
    final resp = await postWoToken(
      param: {
        "cmd": "acl-det-list",
        "invSecLevelID": invSecLevelID,
      },
      service: service,
    );
    List<InvAclScreen> result = List.empty(growable: true);
    resp["data"].forEach((e) {
      final obj = InvAclScreen.fromJson(e);
      result.add(obj);
    });
    return result;
  }

  Future<List<InvSecLevelModel>> listSecurityLevel() async {
    const service = "sys/auth/adm_screen";
    final resp = await postWoToken(
      param: {"cmd": "acl-list"},
      service: service,
    );
    List<InvSecLevelModel> result = List.empty(growable: true);
    resp["data"].forEach((e) {
      final obj = InvSecLevelModel.fromJson(e);
      result.add(obj);
    });
    return result;
  }

  Future<InvSecLevelModel> addSecurityLevel({
    required String token,
    required String invSecLevelName,
  }) async {
    const service = "sys/auth/adm_screen";
    final param = {
      "cmd": "acl-add",
      "invSecLevelName": invSecLevelName,
    };

    var resp = await post(param: param, service: service, token: token);
    return InvSecLevelModel(
      invSecLevelID: resp["invSecLevelID"],
      invSecLevelName: resp["invSecLevelName"],
      invSecLevelIsActive: "Y",
    );
  }

  Future<InvSecLevelModel> editSecurityLevel({
    required String token,
    required String invSecLevelID,
    required String invSecLevelName,
  }) async {
    const service = "sys/auth/adm_screen";
    final param = {
      "cmd": "acl-edit",
      "invSecLevelID": invSecLevelID,
      "invSecLevelName": invSecLevelName,
    };

    await post(param: param, service: service, token: token);
    return InvSecLevelModel(
      invSecLevelID: invSecLevelID,
      invSecLevelName: invSecLevelName,
      invSecLevelIsActive: "Y",
    );
  }

  Future<bool> deleteSecurityLevel({
    required String token,
    required String invSecLevelID,
  }) async {
    const service = "sys/auth/adm_screen";
    final param = {
      "cmd": "acl-del",
      "invSecLevelID": invSecLevelID,
    };

    await post(param: param, service: service, token: token);
    return true;
  }
}
