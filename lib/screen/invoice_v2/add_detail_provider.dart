import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/repository/invoice_repository.dart';
import 'package:sor_inventory/screen/invoice_v2/get_detail_provider.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import 'invoice_id_provider.dart';

final addDetailProvider =
    StateNotifierProvider<AddDetailStateNotifier, AddDetailState>(
  (ref) => AddDetailStateNotifier(ref: ref),
);

class AddDetailStateNotifier extends StateNotifier<AddDetailState> {
  final Ref ref;
  AddDetailStateNotifier({
    required this.ref,
  }) : super(AddDetailStateInit());

  void reset() {
    state = AddDetailStateInit();
  }

  void add({
    required String invoiceID,
    required String invoiceNo,
    required DateTime invoiceDate,
    required String paymentTermID,
    required String invoiceTerm,
    required String clientID,
    required String productID,
    required String taxPercent,
    required String qty,
    required String price,
    required String uom,
  }) async {
    final dio = ref.read(dioProvider);
    state = AddDetailStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = AddDetailStateError(message: "Invalid Token");
        return;
      }
      final sdf = DateFormat("yyyy-MM-dd HH:mm:ss");
      final newInvoiceID = await InvoiceRepository(dio: dio).addDetail(
        token: loginModel!.token!,
        invoiceID: invoiceID,
        invoiceNo: invoiceNo,
        invoiceTerm: invoiceTerm,
        invoiceDate: sdf.format(invoiceDate),
        paymentTermID: paymentTermID,
        clientID: clientID,
        productID: productID,
        taxPercent: taxPercent,
        qty: qty,
        uom: uom,
        price: price,
      );
      if (invoiceID == "0") {
        ref.read(invoiceIDProvider.notifier).state = newInvoiceID;
        ref.read(getDetailProvider.notifier).get(invoiceID: newInvoiceID);
      } else {
        ref.read(getDetailProvider.notifier).get(invoiceID: invoiceID);
      }
      state = AddDetailStateDone();
    } catch (e) {
      print(e.toString());
      if (e is BaseRepositoryException) {
        state = AddDetailStateError(message: e.message);
      } else {
        state = AddDetailStateError(message: e.toString());
      }
    }
  }
}

abstract class AddDetailState extends Equatable {
  final DateTime date;
  const AddDetailState({required this.date});
  @override
  List<Object?> get props => [date];
}

class AddDetailStateInit extends AddDetailState {
  AddDetailStateInit() : super(date: DateTime.now());
}

class AddDetailStateLoading extends AddDetailState {
  AddDetailStateLoading() : super(date: DateTime.now());
}

class AddDetailStateToken extends AddDetailState {
  AddDetailStateToken() : super(date: DateTime.now());
}

class AddDetailStateNoToken extends AddDetailState {
  AddDetailStateNoToken() : super(date: DateTime.now());
}

class AddDetailStateError extends AddDetailState {
  final String message;
  AddDetailStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class AddDetailStateDone extends AddDetailState {
  AddDetailStateDone() : super(date: DateTime.now());
}
