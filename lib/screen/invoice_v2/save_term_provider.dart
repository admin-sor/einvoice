import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/invoice_repository.dart';
import 'package:sor_inventory/screen/po_summary/po_summary_provider.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/po_repository.dart';

final saveTermProvider =
    StateNotifierProvider<SaveTermStateNotifier, SaveTermState>(
  (ref) => SaveTermStateNotifier(ref: ref),
);

class SaveTermStateNotifier extends StateNotifier<SaveTermState> {
  final Ref ref;
  SaveTermStateNotifier({
    required this.ref,
  }) : super(SaveTermStateInit());

  void reset() {
    state = SaveTermStateInit();
  }

  void save({
    required String term,
    required String invoiceID,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = SaveTermStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = SaveTermStateLoading();
    try {
      await InvoiceRepository(dio: dio).saveTerm(
        term: term,
        invoiceID: invoiceID,
        token: loginModel!.token!,
      );
      state = SaveTermStateDone();
      // ref
      //     .read(poSummaryProvider.notifier)
      //     .list(search: searchPo, vendorID: vendorID);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SaveTermStateError(message: e.message);
      } else {
        state = SaveTermStateError(message: e.toString());
      }
    }
  }
}

abstract class SaveTermState extends Equatable {
  final DateTime date;
  const SaveTermState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SaveTermStateInit extends SaveTermState {
  SaveTermStateInit() : super(date: DateTime.now());
}

class SaveTermStateLoading extends SaveTermState {
  SaveTermStateLoading() : super(date: DateTime.now());
}

class SaveTermStateToken extends SaveTermState {
  SaveTermStateToken() : super(date: DateTime.now());
}

class SaveTermStateNoToken extends SaveTermState {
  SaveTermStateNoToken() : super(date: DateTime.now());
}

class SaveTermStateError extends SaveTermState {
  final String message;
  SaveTermStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SaveTermStateDone extends SaveTermState {
  SaveTermStateDone() : super(date: DateTime.now());
}
