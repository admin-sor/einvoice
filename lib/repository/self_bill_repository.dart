import 'package:intl/intl.dart';

import '../repository/base_repository.dart';

class SelfBillRepository extends BaseRepository {
  SelfBillRepository({required super.dio});

  Future<String> addDetail({
    required String token,
    required String selfBillID,
    required String invoiceNo,
    required String invoiceTerm,
    required DateTime invoiceDate,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String supplierID,
    required String paymentTermID,
    required String productID,
    required String productDescription,
    required String taxPercent,
    required String qty,
    required String price,
    required String uom,
  }) async {
    final sdf = DateFormat("yyyy-MM-dd HH:mm:ss");
    final param = {
      "invoiceNo": invoiceNo,
      "invoiceDate": sdf.format(invoiceDate),
      "invoiceTerm": invoiceTerm,
      "supplierID": supplierID,
      "paymentTermID": paymentTermID,
      "invoiceDetailUnit": uom,
      "invoiceDetailDateFrom": sdf.format(dateFrom),
      "invoiceDetailDateTo": sdf.format(dateTo),
      "invoiceDetailInvoiceID": selfBillID,
      "invoiceDetailEvProductID": productID,
      "invoiceDetailEvDescription": productDescription,
      "invoiceDetailEvProductTaxPercent": taxPercent,
      "invoiceDetailQty": qty,
      "invoiceDetailPrice": price,
    };
    final resp = await post(
      param: param,
      service: "invoice_v2/self_bill_add_detail",
      token: token,
    );
    return resp["invoiceID"].toString();
  }
}
