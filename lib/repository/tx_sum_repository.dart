import '../model/tx_sum_model.dart';
import 'base_repository.dart';

class TxSumRepository extends BaseRepository {
  TxSumRepository({
    required dio,
  }) : super(dio: dio);

  Future<List<TxSumModel>> list(String token) async {
    var resp = await post(param: {}, service: "/tx_sum/xlist", token: token);
    var result = List<TxSumModel>.empty(growable: true);
    resp["data"].forEach((e) {
      var model = TxSumModel.fromJson(e);
      result.add(model);
    });
    return result;
  }
}
