import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/screen/po/get_po_provider.dart';

import '../../model/po_response_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/po_repository.dart';

final deletePoProvider =
    StateNotifierProvider<DeletePoStateNotifier, DeletePoState>(
  (ref) => DeletePoStateNotifier(ref: ref),
);

class DeletePoStateNotifier extends StateNotifier<DeletePoState> {
  final Ref ref;
  DeletePoStateNotifier({
    required this.ref,
  }) : super(DeletePoStateInit());

  void reset() {
    state = DeletePoStateInit();
  }

  void delete({
    required String poNo,
    required String vendorID,
    required String poDetailID,
  }) async {
    final dio = ref.read(dioProvider);
    state = DeletePoStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = DeletePoStateError(message: "Invalid Token");
        return;
      }
      final resp = await PoRepository(dio: dio).delete(
        token: loginModel!.token!,
        poDetailID: poDetailID,
      );
      state = DeletePoStateDone();
      ref.read(getPoProvider.notifier).get(poNo: poNo, vendorID: vendorID);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = DeletePoStateError(message: e.message);
      } else {
        state = DeletePoStateError(message: e.toString());
      }
    }
  }
}

abstract class DeletePoState extends Equatable {
  final DateTime date;
  const DeletePoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class DeletePoStateInit extends DeletePoState {
  DeletePoStateInit() : super(date: DateTime.now());
}

class DeletePoStateLoading extends DeletePoState {
  DeletePoStateLoading() : super(date: DateTime.now());
}

class DeletePoStateToken extends DeletePoState {
  DeletePoStateToken() : super(date: DateTime.now());
}

class DeletePoStateNoToken extends DeletePoState {
  DeletePoStateNoToken() : super(date: DateTime.now());
}

class DeletePoStateError extends DeletePoState {
  final String message;
  DeletePoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class DeletePoStateDone extends DeletePoState {
  DeletePoStateDone() : super(date: DateTime.now());
}
