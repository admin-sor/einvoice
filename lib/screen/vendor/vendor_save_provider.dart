import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/vendor_model.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/vendor_repository.dart';
import 'package:sor_inventory/screen/material_md/material_md_search_provider.dart';
import 'package:sor_inventory/screen/vendor/vendor_search_provider.dart';

import '../../provider/shared_preference_provider.dart';

final vendorSaveProvider =
    StateNotifierProvider<VendorSaveNotifier, VendorSaveState>(
  (ref) => VendorSaveNotifier(ref: ref),
);

class VendorSaveNotifier extends StateNotifier<VendorSaveState> {
  final Ref ref;
  VendorSaveNotifier({required this.ref}) : super(VendorSaveStateInit());

  void save({
    required String vendorID,
    required String vendorName,
    required String vendorAdd1,
    required String vendorPaymentTermID,
    required String vendorAdd2,
    required String vendorAdd3,
    required String vendorRegNo,
    required String vendorPicName,
    required String vendorPicEmail,
    required String vendorPicPhone,
    String vendorTerm = "",
    required String query,
  }) async {
    state = VendorSaveStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = VendorSaveStateError(message: "Invalid Token");
        return;
      }
      final resp = await VendorRepository(dio: ref.read(dioProvider)).edit(
        vendorID: vendorID,
        vendorName: vendorName,
        vendorPaymentTermID: vendorPaymentTermID,
        vendorRegNo: vendorRegNo,
        vendorAdd1: vendorAdd1,
        vendorAdd2: vendorAdd2,
        vendorAdd3: vendorAdd3,
        vendorPicName: vendorPicName,
        vendorPicEmail: vendorPicEmail,
        vendorPicPhone: vendorPicPhone,
        vendorTerm: vendorTerm,
        token: loginModel!.token!,
      );
      state = VendorSaveStateDone(model: resp);
      ref.read(materialMdSearchProvider.notifier).search(query: query);
      ref.read(vendorSearchProvider.notifier).search(query: query);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = VendorSaveStateError(message: e.message);
      } else {
        state = VendorSaveStateError(message: e.toString());
      }
    }
  }
}

abstract class VendorSaveState extends Equatable {
  final DateTime date;
  const VendorSaveState(this.date);

  @override
  List<Object?> get props => [date];
}

class VendorSaveStateInit extends VendorSaveState {
  VendorSaveStateInit() : super(DateTime.now());
}

class VendorSaveStateLoading extends VendorSaveState {
  VendorSaveStateLoading() : super(DateTime.now());
}

class VendorSaveStateError extends VendorSaveState {
  final String message;
  VendorSaveStateError({required this.message}) : super(DateTime.now());
}

class VendorSaveStateDone extends VendorSaveState {
  final VendorModel model;
  VendorSaveStateDone({required this.model}) : super(DateTime.now());
}
