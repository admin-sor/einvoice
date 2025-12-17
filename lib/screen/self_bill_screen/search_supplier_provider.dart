import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/supplier_model.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/supplier_repository.dart';

import '../../provider/dio_provider.dart';

final supplierSearchProvider =
    StateNotifierProvider<SupplierSearchNotifier, SupplierSearchState>(
        (ref) => SupplierSearchNotifier(ref: ref));

class SupplierSearchNotifier extends StateNotifier<SupplierSearchState> {
  final Ref ref;
  SupplierSearchNotifier({required this.ref})
      : super(SupplierSearchStateInit());

  void search({required String query}) async {
    state = SupplierSearchStateLoading();
    try {
      final resp =
          await SupplierRepository(dio: ref.read(dioProvider)).search(
        query: query,
      );
      state = SupplierSearchStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SupplierSearchStateError(message: e.message);
      } else {
        state = SupplierSearchStateError(message: e.toString());
      }
    }
  }
}

abstract class SupplierSearchState extends Equatable {
  final DateTime date;
  const SupplierSearchState(this.date);
  @override
  List<Object?> get props => [date];
}

class SupplierSearchStateInit extends SupplierSearchState {
  SupplierSearchStateInit() : super(DateTime.now());
}

class SupplierSearchStateLoading extends SupplierSearchState {
  SupplierSearchStateLoading() : super(DateTime.now());
}

class SupplierSearchStateError extends SupplierSearchState {
  final String message;
  SupplierSearchStateError({required this.message})
      : super(DateTime.now());
}

class SupplierSearchStateDone extends SupplierSearchState {
  final List<SupplierModel> model;
  SupplierSearchStateDone({required this.model}) : super(DateTime.now());
}
