import '../model/invoice_model.dart';
import '../repository/base_repository.dart';

class SelfBillSearchRepository extends BaseRepository {
  SelfBillSearchRepository({required super.dio});

  Future<List<InvoiceModel>> search({
    required String startDate,
    required String endDate,
    required String supplier,
    required String status,
  }) async {
    const service = "invoice_v2/self_bill_search";
    final param = {
      "startDate": startDate,
      "endDate": endDate,
      "supplier": supplier,
      "status": status,
    };
    final resp = await postWoToken(param: param, service: service);
    final List<InvoiceModel> list = [];
    if (resp["data"] is List) {
      for (var e in resp["data"]) {
        list.add(InvoiceModel.fromJson(e));
      }
    }
    return list;
  }
}
