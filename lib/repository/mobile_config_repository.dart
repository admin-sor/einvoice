import 'package:sor_inventory/model/mobile_config_model.dart';
import 'base_repository.dart';

class MobileConfigRepository extends BaseRepository {
  MobileConfigRepository({
    required dio,
  }) : super(dio: dio);

  Future<MobileConfigModel> get({
    required String token,
  }) async {
    final jsonData = await post(
      token: token,
      param: {},
      service: "setting/get_config",
    );
    return MobileConfigModel.fromJson(jsonData["data"]);
  }

  Future<MobileConfigModel> update({
    required String token,
    required MobileConfigModel model,
  }) async {
    final jsonData = await post(
      token: token,
      param: {
        "mobileConfigID": model.mobileconfigID,
        "mobileConfigAutoInvoice": model.mobileConfigAutoInvoice,
      },
      service: "setting/update_config",
    );
    return MobileConfigModel.fromJson(jsonData["data"]);
  }
}
