import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/vendor_material_model.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/vendor_repository.dart';

final vendorMaterialSearchProvider = StateNotifierProvider<
    VendorMaterialSearchNotifier, VendorMaterialSearchState>(
  (ref) => VendorMaterialSearchNotifier(ref: ref),
);

class VendorMaterialSearchNotifier
    extends StateNotifier<VendorMaterialSearchState> {
  final Ref ref;
  VendorMaterialSearchNotifier({required this.ref})
      : super(VendorMaterialSearchStateInit());

  void search({
    required String vendorID,
    required String query,
  }) async {
    state = VendorMaterialSearchStateLoading();
    try {
      final resp = await VendorRepository(dio: ref.read(dioProvider))
          .listMaterial(vendorID: vendorID, query: query);
      state = VendorMaterialSearchStateDone(resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = VendorMaterialSearchStateError(e.message);
      } else {
        state = VendorMaterialSearchStateError(e.toString());
      }
    }
  }
}

abstract class VendorMaterialSearchState extends Equatable {
  final DateTime date;

  const VendorMaterialSearchState(this.date);
  @override
  List<Object?> get props => [date];
}

class VendorMaterialSearchStateInit extends VendorMaterialSearchState {
  VendorMaterialSearchStateInit() : super(DateTime.now());
}

class VendorMaterialSearchStateLoading extends VendorMaterialSearchState {
  VendorMaterialSearchStateLoading() : super(DateTime.now());
}

class VendorMaterialSearchStateError extends VendorMaterialSearchState {
  final String message;
  VendorMaterialSearchStateError(this.message) : super(DateTime.now());
}

class VendorMaterialSearchStateDone extends VendorMaterialSearchState {
  final List<VendorMaterialModel> list;
  VendorMaterialSearchStateDone(this.list) : super(DateTime.now());
}
