import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/invoice_repository.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final lhdnValidationProvider =
    StateNotifierProvider<LhdnValidationStateNotifier, LhdnValidationState>(
  (ref) => LhdnValidationStateNotifier(ref: ref),
);

class LhdnValidationStateNotifier extends StateNotifier<LhdnValidationState> {
  final Ref ref;
  LhdnValidationStateNotifier({
    required this.ref,
  }) : super(LhdnValidationStateInit());

  void reset() {
    state = LhdnValidationStateInit();
  }

  void validate({
    required String invoiceID,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = LhdnValidationStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = LhdnValidationStateLoading();
    try {
      await InvoiceRepository(dio: dio).validateLhdn(
        invoiceID: invoiceID,
        token: loginModel!.token!,
      );
      state = LhdnValidationStateDone();
      // call after state mark as done
      // ref.read(getDetailProvider.notifier).get(invoiceID: invoiceID);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = LhdnValidationStateError(message: e.message);
      } else {
        state = LhdnValidationStateError(message: e.toString());
      }
    }
  }
}

abstract class LhdnValidationState extends Equatable {
  final DateTime date;
  const LhdnValidationState({required this.date});
  @override
  List<Object?> get props => [date];
}

class LhdnValidationStateInit extends LhdnValidationState {
  LhdnValidationStateInit() : super(date: DateTime.now());
}

class LhdnValidationStateLoading extends LhdnValidationState {
  LhdnValidationStateLoading() : super(date: DateTime.now());
}

class LhdnValidationStateToken extends LhdnValidationState {
  LhdnValidationStateToken() : super(date: DateTime.now());
}

class LhdnValidationStateNoToken extends LhdnValidationState {
  LhdnValidationStateNoToken() : super(date: DateTime.now());
}

class LhdnValidationStateError extends LhdnValidationState {
  final String message;
  LhdnValidationStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class LhdnValidationStateDone extends LhdnValidationState {
  LhdnValidationStateDone() : super(date: DateTime.now());
}
