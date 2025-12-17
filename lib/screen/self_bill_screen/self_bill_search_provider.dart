import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/invoice_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/self_bill_search_repository.dart';

final selfBillSearchProvider =
    StateNotifierProvider<SelfBillSearchNotifier, SelfBillSearchState>(
        (ref) => SelfBillSearchNotifier(ref: ref));

class SelfBillSearchNotifier extends StateNotifier<SelfBillSearchState> {
  final Ref ref;
  SelfBillSearchNotifier({required this.ref})
      : super(SelfBillSearchStateInit());

  void search({
    required String startDate,
    required String endDate,
    required String supplierName,
    required String status,
  }) async {
    state = SelfBillSearchStateLoading();
    try {
      final resp =
          await SelfBillSearchRepository(dio: ref.read(dioProvider)).search(
        startDate: startDate,
        endDate: endDate,
        supplier: supplierName,
        status: status,
      );
      state = SelfBillSearchStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SelfBillSearchStateError(message: e.message);
      } else {
        state = SelfBillSearchStateError(message: e.toString());
      }
    }
  }
}

abstract class SelfBillSearchState extends Equatable {
  final DateTime date;

  const SelfBillSearchState(this.date);
  @override
  List<Object?> get props => [date];
}

class SelfBillSearchStateInit extends SelfBillSearchState {
  SelfBillSearchStateInit() : super(DateTime.now());
}

class SelfBillSearchStateLoading extends SelfBillSearchState {
  SelfBillSearchStateLoading() : super(DateTime.now());
}

class SelfBillSearchStateError extends SelfBillSearchState {
  final String message;
  SelfBillSearchStateError({
    required this.message,
  }) : super(DateTime.now());
}

class SelfBillSearchStateDone extends SelfBillSearchState {
  final List<InvoiceModel> model;
  SelfBillSearchStateDone({
    required this.model,
  }) : super(DateTime.now());
}
