import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/screen/po_summary/po_summary_provider.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/po_repository.dart';

final editPoProvider = StateNotifierProvider<EditPoStateNotifier, EditPoState>(
  (ref) => EditPoStateNotifier(ref: ref),
);

class EditPoStateNotifier extends StateNotifier<EditPoState> {
  final Ref ref;
  EditPoStateNotifier({
    required this.ref,
  }) : super(EditPoStateInit());

  void reset() {
    state = EditPoStateInit();
  }

  void saveHeader(
      {required DateTime date,
      required String poNo,
      required String paymentTermID,
      required String poID,
      String vendorID = "",
      String searchPo = ""}) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = EditPoStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = EditPoStateLoading();
    try {
      await PoRepository(dio: dio).saveHeader(
        date: date,
        poNo: poNo,
        poID: poID,
        paymentTermID: paymentTermID,
        token: loginModel!.token!,
      );
      state = EditPoStateDone();
      ref
          .read(poSummaryProvider.notifier)
          .list(search: searchPo, vendorID: vendorID);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = EditPoStateError(message: e.message);
      } else {
        state = EditPoStateError(message: e.toString());
      }
    }
  }
}

abstract class EditPoState extends Equatable {
  final DateTime date;
  const EditPoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class EditPoStateInit extends EditPoState {
  EditPoStateInit() : super(date: DateTime.now());
}

class EditPoStateLoading extends EditPoState {
  EditPoStateLoading() : super(date: DateTime.now());
}

class EditPoStateToken extends EditPoState {
  EditPoStateToken() : super(date: DateTime.now());
}

class EditPoStateNoToken extends EditPoState {
  EditPoStateNoToken() : super(date: DateTime.now());
}

class EditPoStateError extends EditPoState {
  final String message;
  EditPoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class EditPoStateDone extends EditPoState {
  EditPoStateDone() : super(date: DateTime.now());
}
