import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/invoice_repository.dart';
import 'package:sor_inventory/screen/invoice_v2/get_detail_provider.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final deleteDetailProvider =
    StateNotifierProvider<DeleteDetailStateNotifier, DeleteDetailState>(
  (ref) => DeleteDetailStateNotifier(ref: ref),
);

class DeleteDetailStateNotifier extends StateNotifier<DeleteDetailState> {
  final Ref ref;
  DeleteDetailStateNotifier({
    required this.ref,
  }) : super(DeleteDetailStateInit());

  void reset() {
    state = DeleteDetailStateInit();
  }

  void delete({
    required String invoiceDetailID,
    required String invoiceID,
  }) async {
    final dio = ref.read(dioProvider);
    state = DeleteDetailStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = DeleteDetailStateError(message: "Invalid Token");
        return;
      }
      await InvoiceRepository(dio: dio).deleteDetail(
        token: loginModel!.token!,
        invoiceDetailID: invoiceDetailID,
      );
      ref.read(getDetailProvider.notifier).get(invoiceID: invoiceID);
      state = DeleteDetailStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = DeleteDetailStateError(message: e.message);
      } else {
        state = DeleteDetailStateError(message: e.toString());
      }
    }
  }
}

abstract class DeleteDetailState extends Equatable {
  final DateTime date;
  const DeleteDetailState({required this.date});
  @override
  List<Object?> get props => [date];
}

class DeleteDetailStateInit extends DeleteDetailState {
  DeleteDetailStateInit() : super(date: DateTime.now());
}

class DeleteDetailStateLoading extends DeleteDetailState {
  DeleteDetailStateLoading() : super(date: DateTime.now());
}

class DeleteDetailStateToken extends DeleteDetailState {
  DeleteDetailStateToken() : super(date: DateTime.now());
}

class DeleteDetailStateNoToken extends DeleteDetailState {
  DeleteDetailStateNoToken() : super(date: DateTime.now());
}

class DeleteDetailStateError extends DeleteDetailState {
  final String message;
  DeleteDetailStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class DeleteDetailStateDone extends DeleteDetailState {
  DeleteDetailStateDone() : super(date: DateTime.now());
}
