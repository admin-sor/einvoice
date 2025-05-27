import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/vendor_repository.dart';
import 'vendor_material_search_provider.dart';

final vendorMaterialDeleteProvider = StateNotifierProvider<
    VendorStateMaterialDeleteNotifier, VendorMaterialDeleteState>(
  (ref) => VendorStateMaterialDeleteNotifier(
    (ref),
  ),
);

class VendorStateMaterialDeleteNotifier
    extends StateNotifier<VendorMaterialDeleteState> {
  Ref ref;
  VendorStateMaterialDeleteNotifier(this.ref)
      : super(VendorMaterialDeleteStateInit());

  void delete({
    required String vendorPriceID,
    required String query,
    required String vendorID,
  }) async {
    try {
      state = VendorMaterialDeleteStateLoading();
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = VendorMaterialDeleteStateError("Invalid Token");
        return;
      }
      final resp =
          await VendorRepository(dio: ref.read(dioProvider)).deleteMaterial(
        token: loginModel!.token!,
        vendorPriceID: vendorPriceID,
      );
      state = VendorMaterialDeleteStateDone();
      ref.read(vendorMaterialSearchProvider.notifier).search(
            vendorID: vendorID,
            query: query,
          );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = VendorMaterialDeleteStateError(e.message);
      } else {
        state = VendorMaterialDeleteStateError(e.toString());
      }
    }
  }
}

abstract class VendorMaterialDeleteState extends Equatable {
  final DateTime date;
  const VendorMaterialDeleteState(this.date);
  @override
  List<Object?> get props => [date];
}

class VendorMaterialDeleteStateInit extends VendorMaterialDeleteState {
  VendorMaterialDeleteStateInit() : super(DateTime.now());
}

class VendorMaterialDeleteStateLoading extends VendorMaterialDeleteState {
  VendorMaterialDeleteStateLoading() : super(DateTime.now());
}

class VendorMaterialDeleteStateError extends VendorMaterialDeleteState {
  final String message;
  VendorMaterialDeleteStateError(this.message) : super(DateTime.now());
}

class VendorMaterialDeleteStateDone extends VendorMaterialDeleteState {
  VendorMaterialDeleteStateDone() : super(DateTime.now());
}
