import 'package:intl/intl.dart';
import 'package:sor_inventory/model/lhdn_submit_resp_model.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import '../model/invoice_model.dart';
import '../model/invoice_v2_model.dart';
import '../model/payment_term_response_model.dart';

class InvoiceRepository extends BaseRepository {
  InvoiceRepository({required super.dio});
  Future<bool> deleteDetail({
    required String token,
    required String invoiceDetailID,
  }) async {
    final param = {
      "invoiceDetailID": invoiceDetailID,
    };
    await post(
      param: param,
      service: "/invoice_v2/delete_detail",
      token: token,
    );
    return true;
  }

  Future<bool> validateLhdn({
    required String invoiceID,
    required String token,
  }) async {
    final resp = await post(
      param: {},
      service: "ev_invoice/qrcode/$invoiceID/json",
      token: token,
    );
    return true;
  }

  Future<LhdnSubmitResponseModel> submitLhdn({
    required String invoiceID,
    required String token,
  }) async {
    final resp = await post(
      param: {},
      service: "ev_invoice/submit/$invoiceID",
      token: token,
    );
    return LhdnSubmitResponseModel.fromJson(resp["data"]);
  }

  Future<String> addDetail({
    required String token,
    required String invoiceID,
    required String invoiceNo,
    required String invoiceTerm,
    required String invoiceDate,
    required String clientID,
    required String paymentTermID,
    required String productID,
    required String taxPercent,
    required String qty,
    required String price,
    required String uom,
  }) async {
    final param = {
      "invoiceNo": invoiceNo,
      "invoiceDate": invoiceDate,
      "invoiceTerm": invoiceTerm,
      "clientID": clientID,
      "paymentTermID": paymentTermID,
      "invoiceDetailUnit": uom,
      "invoiceDetailInvoiceID": invoiceID,
      "invoiceDetailEvProductID": productID,
      "invoiceDetailEvProductTaxPercent": taxPercent,
      "invoiceDetailQty": qty,
      "invoiceDetailPrice": price,
    };
    var resp = await post(
      param: param,
      service: "/invoice_v2/add_detail",
      token: token,
    );
    return resp["invoiceID"].toString();
  }

  Future<List<InvoiceDetailModel>> getDetail({
    String invoiceID = "0",
  }) async {
    final resp = await postWoToken(
      param: {},
      service: "/invoice_v2/get_detail/$invoiceID",
    );
    final List<InvoiceDetailModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(InvoiceDetailModel.fromJson(e));
    });
    return list;
  }

  Future<List<PaymentTermResponseModel>> paymentTermLookup({
    String clientID = "0",
  }) async {
    final resp = await postWoToken(
      param: {"clientID": clientID},
      service: "/invoice_v2/payment_term_lookup",
    );
    final List<PaymentTermResponseModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      list.add(PaymentTermResponseModel.fromJson(e));
    });
    return list;
  }

  Future<bool> saveTerm({
    required String invoiceID,
    required String term,
    required String token,
  }) async {
    final param = {
      "invoiceID": invoiceID,
      "term": term,
    };
    await post(
      param: param,
      service: "/invoice_v2/save_term",
      token: token,
    );
    return true;
  }

  Future<InvoiceV2Model> headerV2({
    required String invoiceID,
  }) async {
    String service = "invoice_v2/get_header/" + invoiceID;
    final resp = await postWoToken(param: {}, service: service);

    return InvoiceV2Model.fromJson(resp["data"]);
  }

  Future<String> saveHeader({
    required DateTime date,
    required String invoiceNo,
    required String paymentTermID,
    required String token,
    required String clientID,
    required String invoiceID,
  }) async {
    final sdf = DateFormat("yyyy-MM-dd");
    final sDate = sdf.format(date);
    final param = {
      "date": sDate,
      "invoiceID": invoiceID,
      "clientID": clientID,
      "invoiceNo": invoiceNo,
      "paymentTermID": paymentTermID,
    };
    final resp = await post(
      param: param,
      service: "/invoice_v2/save_header",
      token: token,
    );
    return resp["invoiceID"].toString();
  }

  Future<List<InvoiceV2Model>> searchV2({
    required String startDate,
    required String endDate,
    required String client,
    required String status,
  }) async {
    const service = "invoice_v2/search";
    final param = {
      "startDate": startDate,
      "endDate": endDate,
      "client": client,
      "status": status,
    };
    final resp = await postWoToken(param: param, service: service);

    final List<InvoiceV2Model> list = [];
    if (resp["data"] is List) {
      for (var e in resp["data"]) {
        final model = InvoiceV2Model.fromJson(e);
        list.add(model);
      }
    }
    return list;
  }

  /// Searches for invoices based on various criteria.
  Future<List<InvoiceModel>> search({
    required String startDate,
    required String endDate,
    required String client,
    required String status,
  }) async {
    const service = "ev_invoice/search";
    final param = {
      "start_date": startDate,
      "end_date": endDate,
      "client": client,
      "status": status,
    };
    final resp = await postWoToken(param: param, service: service);

    // Assuming the response data is a list of invoice maps
    final List<InvoiceModel> list = [];
    if (resp["data"] is List) {
      for (var e in resp["data"]) {
        final model = InvoiceModel.fromJson(e);
        list.add(model);
      }
    }
    return list;
  }
}
