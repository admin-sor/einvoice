import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/self_bill_repository.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import 'self_bill_id_provider.dart';

final selfBillAddDetailProvider =
    StateNotifierProvider<SelfBillAddDetailNotifier, SelfBillAddDetailState>(
  (ref) => SelfBillAddDetailNotifier(ref: ref),
);

class SelfBillAddDetailNotifier
    extends StateNotifier<SelfBillAddDetailState> {
  final Ref ref;
  SelfBillAddDetailNotifier({required this.ref})
      : super(SelfBillAddDetailStateInit());

  void add({
    required String selfBillID,
    required String invoiceNo,
    required DateTime invoiceDate,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String paymentTermID,
    required String invoiceTerm,
    required String supplierID,
    required String productID,
    required String productDescription,
    required String taxPercent,
    required String qty,
    required String price,
    required String uom,
  }) async {
    final dio = ref.read(dioProvider);
    state = SelfBillAddDetailStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = SelfBillAddDetailStateError(message: "Invalid Token");
        return;
      }
      final newID = await SelfBillRepository(dio: dio).addDetail(
        token: loginModel!.token!,
        selfBillID: selfBillID,
        invoiceNo: invoiceNo,
        invoiceTerm: invoiceTerm,
        invoiceDate: invoiceDate,
        dateFrom: dateFrom,
        dateTo: dateTo,
        paymentTermID: paymentTermID,
        supplierID: supplierID,
        productID: productID,
        productDescription: productDescription,
        taxPercent: taxPercent,
        qty: qty,
        price: price,
        uom: uom,
      );
      ref.read(selfBillIDProvider.notifier).state = newID;
      state = SelfBillAddDetailStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SelfBillAddDetailStateError(message: e.message);
      } else {
        state = SelfBillAddDetailStateError(message: e.toString());
      }
    }
  }
}

abstract class SelfBillAddDetailState extends Equatable {
  final DateTime date;
  const SelfBillAddDetailState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SelfBillAddDetailStateInit extends SelfBillAddDetailState {
  SelfBillAddDetailStateInit() : super(date: DateTime.now());
}

class SelfBillAddDetailStateLoading extends SelfBillAddDetailState {
  SelfBillAddDetailStateLoading() : super(date: DateTime.now());
}

class SelfBillAddDetailStateError extends SelfBillAddDetailState {
  final String message;
  SelfBillAddDetailStateError({required this.message})
      : super(date: DateTime.now());
}

class SelfBillAddDetailStateDone extends SelfBillAddDetailState {
  SelfBillAddDetailStateDone() : super(date: DateTime.now());
}
