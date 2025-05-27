import '../model/tx_in_model.dart';
import 'base_repository.dart';

class TxInRepository extends BaseRepository {
  TxInRepository({
    required dio,
  }) : super(dio: dio);

  Future<bool> delete({
    required String txInID,
    required String slipNo,
    required String token,
  }) async {
    String service = "/tx_in/delete";
    var param = {
      "slipNo": slipNo,
      "txInID": txInID,
    };
    await post(param: param, service: service, token: token);
    return true;
  }

  Future<TxInScanModel> scan({
    required String storeID,
    required String storeToID,
    required String barcode,
    required String slipNo,
    required String token,
  }) async {
    String service = "/tx_in/scan";
    var param = {
      "storeID": storeID,
      "slipNo": slipNo,
      "storeToID": storeToID,
      "barcode": barcode,
    };
    var resp = await post(param: param, service: service, token: token);
    final result = TxInScanModel.fromJson(resp["data"]);
    return result;
  }

  Future<List<TxInListModel>> getBySlip(String slipNo) async {
    var resp = await postWoToken(
        param: {"slipNo": slipNo}, service: "/tx_in/list_by_no");
    var result = List<TxInListModel>.empty(growable: true);
    resp["data"].forEach((e) {
      var model = TxInListModel.fromJson(e);
      result.add(model);
    });
    return result;
  }

  Future<bool> updateQty({
    required String txInID,
    required String barcode,
    required String slipNo,
    required String qty,
    required String token,
  }) async {
    String service = "/tx_in/update_qty";
    var param = {
      "slipNo": slipNo,
      "txInID": txInID,
      "txInPackQty": qty,
      "barcode": barcode,
    };
    await post(param: param, service: service, token: token);
    return true;
  }
}
