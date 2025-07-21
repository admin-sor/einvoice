import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/invoice_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/invoice_repository.dart';

final invoiceSearchProvider =
    StateNotifierProvider<InvoiceNotifier, InvoiceSearchState>(
        (ref) => InvoiceNotifier(ref: ref));

class InvoiceNotifier extends StateNotifier<InvoiceSearchState> {
  final Ref ref;
  InvoiceNotifier({required this.ref}) : super(InvoiceSearchStateInit());

  void search({
    required String startDate,
    required String endDate,
    required String clientName,
    required String status,
  }) async {
    state = InvoiceSearchStateLoading();
    try {
      // InvoiceRepository().search does not require a token based on invoice_repository.dart
      final resp = await InvoiceRepository(dio: ref.read(dioProvider)).search(
        startDate: startDate,
        endDate: endDate,
        client: clientName,
        status: status,
      );
      state = InvoiceSearchStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = InvoiceSearchStateError(message: e.message);
      } else {
        state = InvoiceSearchStateError(message: e.toString());
      }
    }
  }
}

abstract class InvoiceSearchState extends Equatable {
  final DateTime date;

  const InvoiceSearchState(this.date);
  @override
  List<Object?> get props => [date];
}

class InvoiceSearchStateInit extends InvoiceSearchState {
  InvoiceSearchStateInit() : super(DateTime.now());
}

class InvoiceSearchStateLoading extends InvoiceSearchState {
  InvoiceSearchStateLoading() : super(DateTime.now());
}

class InvoiceSearchStateError extends InvoiceSearchState {
  final String message;
  InvoiceSearchStateError({
    required this.message,
  }) : super(DateTime.now());
}

class InvoiceSearchStateDone extends InvoiceSearchState {
  final List<InvoiceModel> model;
  InvoiceSearchStateDone({
    required this.model,
  }) : super(DateTime.now());
}
