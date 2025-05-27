import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/material_return_repository.dart';

final mrSetDoneStateProvider =
    StateNotifierProvider<MrSetDoneStateNotifier, MrSetDoneState>(
  (ref) => MrSetDoneStateNotifier(ref: ref),
);

class MrSetDoneStateNotifier extends StateNotifier<MrSetDoneState> {
  final Ref ref;
  MrSetDoneStateNotifier({
    required this.ref,
  }) : super(MrSetDoneStateInit());

  void reset() {
    state = MrSetDoneStateInit();
  }

  void setDone({
    required String slipNo,
    required String status,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = MrSetDoneStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = MrSetDoneStateLoading();
    try {
      await MaterialReturnRepository(dio: dio)
          .setDone(token: loginModel!.token!, slipNo: slipNo, status: status);
      state = MrSetDoneStateDone(status: status);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MrSetDoneStateError(message: e.message);
      } else {
        state = MrSetDoneStateError(message: e.toString());
      }
    }
  }
}

abstract class MrSetDoneState extends Equatable {
  final DateTime date;
  const MrSetDoneState({required this.date});
  @override
  List<Object?> get props => [date];
}

class MrSetDoneStateInit extends MrSetDoneState {
  MrSetDoneStateInit() : super(date: DateTime.now());
}

class MrSetDoneStateLoading extends MrSetDoneState {
  MrSetDoneStateLoading() : super(date: DateTime.now());
}

class MrSetDoneStateToken extends MrSetDoneState {
  MrSetDoneStateToken() : super(date: DateTime.now());
}

class MrSetDoneStateNoToken extends MrSetDoneState {
  MrSetDoneStateNoToken() : super(date: DateTime.now());
}

class MrSetDoneStateError extends MrSetDoneState {
  final String message;
  MrSetDoneStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class MrSetDoneStateDone extends MrSetDoneState {
  final String status;
  MrSetDoneStateDone({
    required this.status,
  }) : super(date: DateTime.now());
}
