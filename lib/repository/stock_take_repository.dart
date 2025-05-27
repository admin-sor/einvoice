import '../model/stock_take_detail_model.dart';
import '../model/stock_take_history_model.dart';
import '../model/stock_take_item_model.dart';
import '../model/stock_take_model.dart';
import '../model/stock_take_summary_model.dart';
import '../model/stock_take_summary_status_model.dart';
import 'base_repository.dart';

class StockTakeRepository extends BaseRepository {
  StockTakeRepository({
    required dio,
  }) : super(dio: dio);

  Future<bool> save({
    required String stockTakeItemID,
    required String scanQty,
    required String token,
  }) async {
    await post(
      token: token,
      param: {
        "stockTakeItemID": stockTakeItemID,
        "scanQty": scanQty
      },
      service: "stocktake/save",
    );
    return true;
  }
  Future<List<StockTakeSummaryStatusModel>> listStatus({
    required bool isCurrent,
    required String token,
  }) async {
    final jsonData = await post(
      token: token,
      param: {
        "current": isCurrent ? "1" : "0",
      },
      service: "stocktake/list_status",
    );
    final List<StockTakeSummaryStatusModel> list = List.empty(growable: true);
    jsonData["data"].forEach((e) {
      final model = StockTakeSummaryStatusModel.fromJson(e);
      list.add(model);
    });
    return list;
  }

  Future<List<StockTakeDetailModel>> currentDetail({
    required String stockTakeID,
    required String code,
    required String token,
  }) async {
    final param = {
      "id": stockTakeID,
      "code": code,
    };
    final jsonData = await post(
      param: param,
      token: token,
      service: "stocktake/current_detail/",
    );
    final List<StockTakeDetailModel> list = List.empty(growable: true);

    jsonData["data"].forEach((e) {
      final model = StockTakeDetailModel.fromJson(e);
      list.add(model);
    });
    return list;
  }

  Future<List<GroupSummaryModelV2>> currentSummary({
    required String stockTakeID,
    required String token,
  }) async {
    final param = {
      "id": stockTakeID,
    };
    final jsonData = await post(
      param: param,
      token: token,
      service: "stocktake/current_summary_v2/",
    );
    final List<GroupSummaryModelV2> list = List.empty(growable: true);

    jsonData["data"].forEach((e) {
      final model = GroupSummaryModelV2.fromJson(e);
      list.add(model);
    });
    return list;
  }

  Future<List<StockTakeSummaryModel>> summary({
    required String stockTakeID,
    required String query,
    required String status,
    required String token,
  }) async {
    final param = {
      "id": stockTakeID,
      "status": status,
      "query": query,
    };
    final jsonData = await post(
      param: param,
      token: token,
      service: "stocktake/summary/",
    );

    final List<StockTakeSummaryModel> list = List.empty(growable: true);
    jsonData["data"].forEach((e) {
      final model = StockTakeSummaryModel.fromJson(e);
      list.add(model);
    });
    return list;
  }

  Future<List<StockTakeHistoryModel>> history({
    required int start,
    required int limit,
    required String query,
    required String token,
    required String queryDate,
  }) async {
    final jsonData = await post(
      param: {
        "start": start,
        "limit": limit,
        "qry": query,
        "date": queryDate,
      },
      token: token,
      service: "stocktake/history/",
    );
    final List<StockTakeHistoryModel> list = List.empty(growable: true);
    jsonData["data"].forEach((e) {
      final model = StockTakeHistoryModel.fromJson(e);
      list.add(model);
    });
    return list;
  }

  Future<StockTakeModel?> getEvent({required String token}) async {
    final jsonData =
        await post(token: token, param: {}, service: "stocktake/get_event/");
    if (jsonData["exists"] == "Y") {
      return StockTakeModel.fromJson(jsonData["data"]);
    }
    return null;
  }

  Future<StockTakeModel> create({required String token}) async {
    final jsonData =
        await post(token: token, param: {}, service: "stocktake/start_event/");
    return StockTakeModel.fromJson(jsonData["data"]);
  }

  Future<bool> close({
    required String token,
    required String eventID,
  }) async {
    await post(
        token: token, param: {"eventID": eventID}, service: "stocktake/close");
    return true;
  }

  /* Future<StockTakeScanResponse> scan({ */
  /*   required String token, */
  /*   required String qrCode, */
  /*   required String eventID, */
  /* }) async { */
  /*   final jsonData = await post( */
  /*     token: token, */
  /*     param: { */
  /*       "qrCode": qrCode, */
  /*       "eventID": eventID, */
  /*     }, */
  /*     service: "stocktake/scan", */
  /*   ); */
  /*   final result = StockTakeScanResponse( */
  /*       isValid: jsonData["valid"] == "Y", */
  /*       message: jsonData["message"], */
  /*       info: StockItemInfoModel.fromJson(jsonData["info"])); */
  /*   return result; */
  /* } */

  Future<List<StockTakeMultiScanResponse>> multiScan(
      {required String token,
      required List<String> qrCode,
      required String eventID,
      String storeID = "0"}) async {
    final jsonData = await post(
      token: token,
      param: {
        "qrCode": qrCode,
        "eventID": eventID,
        "storeID": storeID,
      },
      service: "stocktake/multi_scan",
    );
    final List<StockTakeMultiScanResponse> result = List.empty(growable: true);
    jsonData["info"].forEach((e) {
      result.add(
        StockTakeMultiScanResponse(
          isValid: e["valid"] == "Y",
          message: e["message"],
          qrCode: e["qrCode"],
        ),
      );
    });
    return result;
  }
}

class StockTakeScanResponse {
  final bool isValid;
  final String message;
  final StockItemInfoModel info;

  StockTakeScanResponse({
    required this.isValid,
    required this.message,
    required this.info,
  });
}

class StockTakeMultiScanResponse {
  final bool isValid;
  final String message;
  final String qrCode;

  StockTakeMultiScanResponse({
    required this.isValid,
    required this.message,
    required this.qrCode,
  });
}
