import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/invoice_repository.dart';

import '../../model/invoice_v2_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';

final getInvoiceHeaderProvider =
    StateNotifierProvider<GetInvoiceHeaderStateNotifier, GetInvoiceHeaderState>(
  (ref) => GetInvoiceHeaderStateNotifier(ref: ref),
);

class GetInvoiceHeaderStateNotifier
    extends StateNotifier<GetInvoiceHeaderState> {
  final Ref ref;
  GetInvoiceHeaderStateNotifier({
    required this.ref,
  }) : super(GetInvoiceHeaderStateInit());

  void reset() {
    state = GetInvoiceHeaderStateInit();
  }

  void get({
    required String invoiceID,
  }) async {
    final dio = ref.read(dioProvider);
    state = GetInvoiceHeaderStateLoading();
    try {
      final resp =
          await InvoiceRepository(dio: dio).headerV2(invoiceID: invoiceID);
      state = GetInvoiceHeaderStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = GetInvoiceHeaderStateError(message: e.message);
      } else {
        state = GetInvoiceHeaderStateError(message: e.toString());
      }
    }
  }
}

abstract class GetInvoiceHeaderState extends Equatable {
  final DateTime date;
  const GetInvoiceHeaderState({required this.date});
  @override
  List<Object?> get props => [date];
}

class GetInvoiceHeaderStateInit extends GetInvoiceHeaderState {
  GetInvoiceHeaderStateInit() : super(date: DateTime.now());
}

class GetInvoiceHeaderStateLoading extends GetInvoiceHeaderState {
  GetInvoiceHeaderStateLoading() : super(date: DateTime.now());
}

class GetInvoiceHeaderStateToken extends GetInvoiceHeaderState {
  GetInvoiceHeaderStateToken() : super(date: DateTime.now());
}

class GetInvoiceHeaderStateNoToken extends GetInvoiceHeaderState {
  GetInvoiceHeaderStateNoToken() : super(date: DateTime.now());
}

class GetInvoiceHeaderStateError extends GetInvoiceHeaderState {
  final String message;
  GetInvoiceHeaderStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class GetInvoiceHeaderStateDone extends GetInvoiceHeaderState {
  final InvoiceV2Model model;
  GetInvoiceHeaderStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
