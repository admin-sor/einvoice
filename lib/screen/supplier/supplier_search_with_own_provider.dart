import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/supplier_model.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/supplier_repository.dart';

import '../../provider/dio_provider.dart';

final supplierSearchWithOwnProvider =
    StateNotifierProvider<SupplierSearchWithOwnNotifier, SupplierSearchWithOwnState>(
  (ref) => SupplierSearchWithOwnNotifier(ref: ref),
);

class SupplierSearchWithOwnNotifier
    extends StateNotifier<SupplierSearchWithOwnState> {
  final Ref ref;
  SupplierSearchWithOwnNotifier({required this.ref})
      : super(SupplierSearchWithOwnStateInit());

  void search({required String query}) async {
    state = SupplierSearchWithOwnStateLoading();
    try {
      final resp =
          await SupplierRepository(dio: ref.read(dioProvider)).searchWithOwn(
        query: query,
      );
      state = SupplierSearchWithOwnStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SupplierSearchWithOwnStateError(message: e.message);
      } else {
        state = SupplierSearchWithOwnStateError(message: e.toString());
      }
    }
  }
}

abstract class SupplierSearchWithOwnState extends Equatable {
  final DateTime date;
  const SupplierSearchWithOwnState(this.date);
  @override
  List<Object?> get props => [date];
}

class SupplierSearchWithOwnStateInit extends SupplierSearchWithOwnState {
  SupplierSearchWithOwnStateInit() : super(DateTime.now());
}

class SupplierSearchWithOwnStateLoading extends SupplierSearchWithOwnState {
  SupplierSearchWithOwnStateLoading() : super(DateTime.now());
}

class SupplierSearchWithOwnStateError extends SupplierSearchWithOwnState {
  final String message;
  SupplierSearchWithOwnStateError({required this.message})
      : super(DateTime.now());
}

class SupplierSearchWithOwnStateDone extends SupplierSearchWithOwnState {
  final List<SupplierModel> model;
  SupplierSearchWithOwnStateDone({required this.model}) : super(DateTime.now());
}
