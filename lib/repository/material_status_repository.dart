import '../model/material_status_response_model.dart';
import 'base_repository.dart';

class MaterialStatusRepository extends BaseRepository {
  MaterialStatusRepository({
    required dio,
  }) : super(dio: dio);

  Future<List<MaterialStatusResponseModel>> list() async {
    final resp = await postWoToken(
      param: {},
      service: "/materialstatus",
    );
    final List<MaterialStatusResponseModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(MaterialStatusResponseModel.fromJson(e));
    });
    return list;
  }
}
