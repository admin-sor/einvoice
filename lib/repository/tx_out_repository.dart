import '../model/tx_out_model.dart';
import 'base_repository.dart';

class TxOutRepository extends BaseRepository {
  TxOutRepository({
    required dio,
  }) : super(dio: dio);

  Future<bool> delete({
    required String slipNo,
    required String txOutID,
    required String token,
  }) async {
    String service = "/tx_out/delete";
    var param = {
      "slipNo": slipNo,
      "txOutID": txOutID,
    };
    await post(param: param, service: service, token: token);
    return true;
  }

  Future<TxOutScanResponseModel> scan({
    required String storeID,
    required String storeToID,
    required String barcode,
    required String slipNo,
    required String token,
  }) async {
    String service = "/tx_out/scan";
    var param = {
      "storeID": storeID,
      "slipNo": slipNo,
      "storeToID": storeToID,
      "barcode": barcode,
    };
    var resp = await post(param: param, service: service, token: token);
    TxOutScanResponseModel result = TxOutScanResponseModel();
    result.slipNo = resp["slipNo"];
    result.storeID = resp["storeID"];
    result.message = "";
    return result;
  }

  Future<List<TxOutListModel>> getBySlip(String slipNo) async {
    var resp = await postWoToken(
        param: {"slipNo": slipNo}, service: "/tx_out/list_out");
    var result = List<TxOutListModel>.empty(growable: true);
    resp["data"].forEach((e) {
      var model = TxOutListModel();
      model.txOutID = e["txOutID"];
      model.code = e["material_code"];
      model.isDeleted = e["isDeleted"];
      model.isLess1Day = e["isLessThen1Day"];
      model.description = e["description"];
      model.qty = e["txOutPackQty"];
      model.isReceived = e["txOutIsReceived"];
      model.barcode = e["txOutBarcode"];
      model.storeID = e["txOutStoreID"];
      model.storeToID = e["txOutToStoreID"];
      result.add(model);
    });
    return result;
  }
}
