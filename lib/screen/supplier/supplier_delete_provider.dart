import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/supplier_repository.dart';
import 'package:sor_inventory/screen/self_bill_screen/search_supplier_provider.dart';

import '../../provider/shared_preference_provider.dart';

final supplierDeleteProvider =
    StateNotifierProvider<SupplierDeleteNotifier, SupplierDeleteState>(
  (ref) => SupplierDeleteNotifier(ref: ref),
);

class SupplierDeleteNotifier extends StateNotifier<SupplierDeleteState> {
  Ref ref;
  SupplierDeleteNotifier({required this.ref}) : super(SupplierDeleteStateInit());

  void delete({
    required int supplierId,
    required String query,
  }) async {
    state = SupplierDeleteStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = SupplierDeleteStateError(message: "Invalid Token");
        return;
      }

      await SupplierRepository(dio: ref.read(dioProvider)).delete(
        token: loginModel!.token!,
        evSupplierID: supplierId,
      );

      ref.read(supplierSearchProvider.notifier).search(query: query);

      state = SupplierDeleteStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SupplierDeleteStateError(message: e.message);
      } else {
        state = SupplierDeleteStateError(message: e.toString());
      }
    }
  }
}

abstract class SupplierDeleteState extends Equatable {
  final DateTime date;
  const SupplierDeleteState(this.date);

  @override
  List<Object?> get props => [date];
}

class SupplierDeleteStateInit extends SupplierDeleteState {
  SupplierDeleteStateInit() : super(DateTime.now());
}

class SupplierDeleteStateLoading extends SupplierDeleteState {
  SupplierDeleteStateLoading() : super(DateTime.now());
}

class SupplierDeleteStateError extends SupplierDeleteState {
  final String message;
  SupplierDeleteStateError({
    required this.message,
  }) : super(DateTime.now());

  @override
  List<Object?> get props => [date, message];
}

class SupplierDeleteStateDone extends SupplierDeleteState {
  SupplierDeleteStateDone() : super(DateTime.now());
}
