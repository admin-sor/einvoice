import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/vendor_material_model.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/vendor_repository.dart';
import 'package:sor_inventory/screen/vendor_material/vendor_material_search_provider.dart';

import '../../provider/shared_preference_provider.dart';

final vendorMaterialSaveProvider =
    StateNotifierProvider<VendorStateMaterialNotifier, VendorMaterialSaveState>(
  (ref) => VendorStateMaterialNotifier(
    (ref),
  ),
);

class VendorStateMaterialNotifier
    extends StateNotifier<VendorMaterialSaveState> {
  Ref ref;
  VendorStateMaterialNotifier(this.ref) : super(VendorMaterialSaveStateInit());

  void save({
    required String vendorPriceID,
    required String vendorPricePackQty,
    required String vendorPriceVendorID,
    required String vendorPriceAmount,
    required String vendorMaterialID,
    required String vendorMaterialLeadTime,
    required String query,
  }) async {
    try {
      state = VendorMaterialSaveStateLoading();
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = VendorMaterialSaveStateError("Invalid Token");
        return;
      }
      final resp = await VendorRepository(dio: ref.read(dioProvider))
          .editMaterial(
              token: loginModel!.token!,
              vendorPriceID: vendorPriceID,
              vendorPriceVendorID: vendorPriceVendorID,
              vendorMaterialID: vendorMaterialID,
              vendorPriceAmount: vendorPriceAmount,
              vendorPricePackQty: vendorPricePackQty,
              vendorMaterialLeadTime: vendorMaterialLeadTime);
      state = VendorMaterialSaveStateDone(resp);
      ref.read(vendorMaterialSearchProvider.notifier).search(
            vendorID: vendorPriceVendorID,
            query: query,
          );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = VendorMaterialSaveStateError(e.message);
      } else {
        state = VendorMaterialSaveStateError(e.toString());
      }
    }
  }
}

abstract class VendorMaterialSaveState extends Equatable {
  final DateTime date;
  const VendorMaterialSaveState(this.date);
  @override
  List<Object?> get props => [date];
}

class VendorMaterialSaveStateInit extends VendorMaterialSaveState {
  VendorMaterialSaveStateInit() : super(DateTime.now());
}

class VendorMaterialSaveStateLoading extends VendorMaterialSaveState {
  VendorMaterialSaveStateLoading() : super(DateTime.now());
}

class VendorMaterialSaveStateError extends VendorMaterialSaveState {
  final String message;
  VendorMaterialSaveStateError(this.message) : super(DateTime.now());
}

class VendorMaterialSaveStateDone extends VendorMaterialSaveState {
  final VendorMaterialModel model;
  VendorMaterialSaveStateDone(this.model) : super(DateTime.now());
}
