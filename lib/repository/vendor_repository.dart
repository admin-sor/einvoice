import 'package:sor_inventory/app/constants.dart';
import 'package:sor_inventory/model/payment_term_response_model.dart';
import 'package:sor_inventory/model/vendor_material_model.dart';
import 'package:sor_inventory/repository/base_repository.dart';

import '../model/vendor_lookup_material_model.dart';
import '../model/vendor_model.dart';

class VendorRepository extends BaseRepository {
  VendorRepository({required super.dio});

  Future<bool> deleteMaterial({
    required String token,
    required String vendorPriceID,
  }) async {
    const service = "vendor/delete_material";
    final param = {
      "vendorPriceID": vendorPriceID,
    };
    await post(param: param, service: service, token: token);
    return true;
  }

  Future<VendorMaterialModel> editMaterial({
    required String token,
    required String vendorPriceID,
    required String vendorPriceVendorID,
    required String vendorMaterialID,
    required String vendorPriceAmount,
    required String vendorMaterialLeadTime,
    required String vendorPricePackQty,
  }) async {
    const service = "vendor/edit_material";
    final param = {
      "vendorPriceID": vendorPriceID,
      "vendorPriceVendorID": vendorPriceVendorID,
      "vendorPriceMaterialID": vendorMaterialID,
      "vendorPriceAmount": vendorPriceAmount,
      "vendorMaterialLeadTime": vendorMaterialLeadTime,
      "vendorPricePackQty": vendorPricePackQty,
    };
    final resp = await post(param: param, service: service, token: token);
    final VendorMaterialModel result =
        VendorMaterialModel.fromJson(resp["data"]);
    return result;
  }

  Future<List<PaymentTermResponseModel>> paymentTerm() async {
    const service = "vendor/payment_term";
    final resp = await postWoToken(param: {}, service: service);
    final List<PaymentTermResponseModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      final model = PaymentTermResponseModel.fromJson(e);
      list.add(model);
    });
    return list;
  }

  Future<List<VendorLookupMaterialModel>> lookupMaterial({
    required String vendorID,
    required String query,
  }) async {
    const service = "vendor/lookup_material";
    final param = {
      "vendorID": vendorID,
      "query": query,
    };
    final resp = await postWoToken(param: param, service: service);
    final List<VendorLookupMaterialModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      final model = VendorLookupMaterialModel.fromJson(e);
      list.add(model);
    });
    return list;
  }

  Future<List<VendorModel>> search({
    required String query,
  }) async {
    const service = "vendor/search";
    final param = {"query": query};
    final resp = await postWoToken(param: param, service: service);
    final List<VendorModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      final model = VendorModel.fromJson(e);
      list.add(model);
    });
    return list;
  }

  Future<bool> delete({
    required String vendorID,
    required String token,
  }) async {
    const service = "vendor/delete";
    final param = {
      "vendorID": vendorID,
    };
    await post(param: param, service: service, token: token);
    return true;
  }

  Future<VendorModel> edit({
    required String vendorID,
    required String vendorName,
    required String vendorPaymentTermID,
    required String vendorRegNo,
    required String vendorAdd1,
    required String vendorAdd2,
    required String vendorAdd3,
    required String vendorPicName,
    required String vendorPicEmail,
    required String vendorPicPhone,
    String vendorTerm = "",
    required String token,
  }) async {
    const service = "vendor/edit";
    final param = {
      "vendorID": vendorID,
      "vendorName": vendorName,
      "vendorPaymentTermID": vendorPaymentTermID,
      "vendorRegNo": vendorRegNo,
      "vendorAdd1": vendorAdd1,
      "vendorAdd2": vendorAdd2,
      "vendorAdd3": vendorAdd3,
      "vendorPicName": vendorPicName,
      "vendorPicEmail": vendorPicEmail,
      "vendorPicPhone": vendorPicPhone,
      "vendorTerm": vendorTerm,
    };
    final resp = await post(param: param, service: service, token: token);
    final result = VendorModel.fromJson(resp["data"]);
    return result;
  }

  Future<List<VendorMaterialModel>> listMaterial({
    required String vendorID,
    required String query,
  }) async {
    const service = "vendor/list_material";
    final param = {"vendorID": vendorID, "query": query};
    final resp = await postWoToken(param: param, service: service);
    final List<VendorMaterialModel> list = List.empty(growable: true);
    resp["data"].forEach((e) {
      final model = VendorMaterialModel.fromJson(e);
      list.add(model);
    });
    return list;
  }
}
