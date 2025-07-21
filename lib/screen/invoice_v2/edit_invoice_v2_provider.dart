import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/invoice_repository.dart';
import 'package:sor_inventory/screen/invoice_v2/invoice_id_provider.dart';
import 'package:sor_inventory/screen/po_summary/po_summary_provider.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final editInvoiceProvider =
    StateNotifierProvider<EditInvoiceStateNotifier, EditInvoiceState>(
  (ref) => EditInvoiceStateNotifier(ref: ref),
);

class EditInvoiceStateNotifier extends StateNotifier<EditInvoiceState> {
  final Ref ref;
  EditInvoiceStateNotifier({
    required this.ref,
  }) : super(EditInvoiceStateInit());

  void reset() {
    state = EditInvoiceStateInit();
  }

  void saveHeader({
    required DateTime date,
    required String invoiceNo,
    required String paymentTermID,
    required String invoiceID,
    required String clientID,
    String searchInvoice = "",
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = EditInvoiceStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = EditInvoiceStateLoading();
    try {
      final newInvoiceID = await InvoiceRepository(dio: dio).saveHeader(
        date: date,
        invoiceNo: invoiceNo,
        invoiceID: invoiceID,
        clientID: clientID,
        paymentTermID: paymentTermID,
        token: loginModel!.token!,
      );
      ref.read(invoiceIDProvider.notifier).state = newInvoiceID;
      state = EditInvoiceStateDone();
      // ref
      //     .read(poSummaryProvider.notifier)
      //     .list(search: searchInvoice, vendorID: vendorID);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = EditInvoiceStateError(message: e.message);
      } else {
        state = EditInvoiceStateError(message: e.toString());
      }
    }
  }
}

abstract class EditInvoiceState extends Equatable {
  final DateTime date;
  const EditInvoiceState({required this.date});
  @override
  List<Object?> get props => [date];
}

class EditInvoiceStateInit extends EditInvoiceState {
  EditInvoiceStateInit() : super(date: DateTime.now());
}

class EditInvoiceStateLoading extends EditInvoiceState {
  EditInvoiceStateLoading() : super(date: DateTime.now());
}

class EditInvoiceStateToken extends EditInvoiceState {
  EditInvoiceStateToken() : super(date: DateTime.now());
}

class EditInvoiceStateNoToken extends EditInvoiceState {
  EditInvoiceStateNoToken() : super(date: DateTime.now());
}

class EditInvoiceStateError extends EditInvoiceState {
  final String message;
  EditInvoiceStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class EditInvoiceStateDone extends EditInvoiceState {
  EditInvoiceStateDone() : super(date: DateTime.now());
}
