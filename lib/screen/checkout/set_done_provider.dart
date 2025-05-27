import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/contractor_lookup_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/checkout_repository.dart';

final setDoneStateProvider =
    StateNotifierProvider<SetDoneStateNotifier, SetDoneState>(
  (ref) => SetDoneStateNotifier(ref: ref),
);

class SetDoneStateNotifier extends StateNotifier<SetDoneState> {
  final Ref ref;
  SetDoneStateNotifier({
    required this.ref,
  }) : super(SetDoneStateInit());

  void reset() {
    state = SetDoneStateInit();
  }

  void setDone({
    required String slipNo,
    required String status,
  }) async {
    final dio = ref.read(dioProvider);
    state = SetDoneStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = SetDoneStateError(message: "Invalid Token");
        return;
      }
      final resp = await CheckoutRepository(dio: dio).setDone(
        slipNo: slipNo,
        status: status,
        token: loginModel!.token!
      );
      state = SetDoneStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SetDoneStateError(message: e.message);
      } else {
        state = SetDoneStateError(message: e.toString());
      }
    }
  }
}

abstract class SetDoneState extends Equatable {
  final DateTime date;
  SetDoneState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SetDoneStateInit extends SetDoneState {
  SetDoneStateInit() : super(date: DateTime.now());
}

class SetDoneStateLoading extends SetDoneState {
  SetDoneStateLoading() : super(date: DateTime.now());
}

class SetDoneStateToken extends SetDoneState {
  SetDoneStateToken() : super(date: DateTime.now());
}

class SetDoneStateNoToken extends SetDoneState {
  SetDoneStateNoToken() : super(date: DateTime.now());
}

class SetDoneStateError extends SetDoneState {
  final String message;
  SetDoneStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SetDoneStateDone extends SetDoneState {
  SetDoneStateDone() : super(date: DateTime.now());
}
