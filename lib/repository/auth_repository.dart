import '../model/dynamic_screen_model.dart';
import '../model/screen_group_model.dart';
import '../model/sor_user_model.dart';
import 'base_repository.dart';

class ScreenFromGroupModel {
  final List<DynamicScreenModel> active;
  final List<DynamicScreenModel> quick;

  ScreenFromGroupModel({required this.active, required this.quick});
}

class AuthRepository extends BaseRepository {
  AuthRepository({
    required dio,
  }) : super(dio: dio);

  Future<bool> changePassword({
    required String password,
    required String token,
  }) async {
    final param = {
      "password": password,
    };
    await post(
        param: param, service: "/sys/auth/change_password", token: token);
    return true;
  }

  Future<SorUser> login({
    required String username,
    required String password,
  }) async {
    final param = {"username": username, "password": password};
    final jsonData = await postWoToken(param: param, service: "sys/auth/login");
    final loginModel = SorUser.fromJson(jsonData["data"]["user"]);
    loginModel.token = jsonData["token"];
    return loginModel;
  }

  Future<ScreenFromGroupModel> groupScreen(
      String token, String screenGroupID) async {
    final jsonData = await post(
      param: {"screenGroupID": screenGroupID},
      service: "sys/auth/group_screen",
      token: token,
    );
    List<DynamicScreenModel> active = List.empty(growable: true);
    for (var d in jsonData["active"]) {
      var model = DynamicScreenModel.fromJson(d);
      active.add(model);
    }
    List<DynamicScreenModel> quick = List.empty(growable: true);
    for (var d in jsonData["quick"]) {
      var model = DynamicScreenModel.fromJson(d);
      quick.add(model);
    }
    return ScreenFromGroupModel(active: active, quick: quick);
  }

  Future<List<ScreenGroupModel>> screenGroup(String token) async {
    final jsonData = await post(
      param: {},
      service: "sys/auth/group_menu",
      token: token,
    );
    List<ScreenGroupModel> result = List.empty(growable: true);
    for (var d in jsonData["data"]) {
      var model = ScreenGroupModel.fromJson(d);
      result.add(model);
    }
    return result;
  }

  Future<SorUser> loginV2({
    required String username,
    required String password,
  }) async {
    final param = {"username": username, "password": password};
    final jsonData =
        await postWoToken(param: param, service: "sys/auth/login_v2");
    final loginModel = SorUser.fromJson(jsonData["data"]);
    loginModel.token = jsonData["token"];
    loginModel.host = ((jsonData["data"]["host"] ?? "tkdev") + ".sor.my");
    loginModel.clientName =
        ((jsonData["data"]["client"] ?? "Client not configured"));
    return loginModel;
  }
}
