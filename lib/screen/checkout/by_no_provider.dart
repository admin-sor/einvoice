import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/contractor_lookup_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/checkout_repository.dart';

final byNoStateProvider = StateNotifierProvider<ByNoStateNotifier, ByNoState>(
  (ref) => ByNoStateNotifier(ref: ref),
);

class ByNoStateNotifier extends StateNotifier<ByNoState> {
  final Ref ref;
  ByNoStateNotifier({
    required this.ref,
  }) : super(ByNoStateInit());

  void reset() {
    state = ByNoStateInit();
  }

  void byNo({
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = ByNoStateLoading();
    try {
      final resp = await CheckoutRepository(dio: dio).getBySlip(
        slipNo,
      );
      state = ByNoStateDone(
        model: resp,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ByNoStateError(message: e.message);
      } else {
        state = ByNoStateError(message: e.toString());
      }
    }
  }
}

abstract class ByNoState extends Equatable {
  final DateTime date;
  ByNoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class ByNoStateInit extends ByNoState {
  ByNoStateInit() : super(date: DateTime.now());
}

class ByNoStateLoading extends ByNoState {
  ByNoStateLoading() : super(date: DateTime.now());
}

class ByNoStateToken extends ByNoState {
  ByNoStateToken() : super(date: DateTime.now());
}

class ByNoStateNoToken extends ByNoState {
  ByNoStateNoToken() : super(date: DateTime.now());
}

class ByNoStateError extends ByNoState {
  final String message;
  ByNoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ByNoStateDone extends ByNoState {
  final CheckoutSlipModel model;
  ByNoStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
