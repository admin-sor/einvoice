import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/po_repository.dart';

final checkPoProvider =
    StateNotifierProvider<CheckPoStateNotifier, CheckPoState>(
  (ref) => CheckPoStateNotifier(ref: ref),
);

class CheckPoStateNotifier extends StateNotifier<CheckPoState> {
  final Ref ref;
  CheckPoStateNotifier({
    required this.ref,
  }) : super(CheckPoStateInit());

  void reset() {
    state = CheckPoStateInit();
  }

  void check({
    required String poNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = CheckPoStateLoading();
    try {
      final resp = await PoRepository(dio: dio).checkPoNo(poNo: poNo);
      state = CheckPoStateDone(resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = CheckPoStateError(message: e.message);
      } else {
        state = CheckPoStateError(message: e.toString());
      }
    }
  }
}

abstract class CheckPoState extends Equatable {
  final DateTime date;
  const CheckPoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class CheckPoStateInit extends CheckPoState {
  CheckPoStateInit() : super(date: DateTime.now());
}

class CheckPoStateLoading extends CheckPoState {
  CheckPoStateLoading() : super(date: DateTime.now());
}

class CheckPoStateToken extends CheckPoState {
  CheckPoStateToken() : super(date: DateTime.now());
}

class CheckPoStateNoToken extends CheckPoState {
  CheckPoStateNoToken() : super(date: DateTime.now());
}

class CheckPoStateError extends CheckPoState {
  final String message;
  CheckPoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class CheckPoStateDone extends CheckPoState {
  final bool status;
  CheckPoStateDone(this.status) : super(date: DateTime.now());
}
