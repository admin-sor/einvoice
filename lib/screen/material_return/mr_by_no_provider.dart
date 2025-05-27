import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/app/app_route.dart';
import 'package:sor_inventory/repository/material_return_repository.dart';

import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/checkout_repository.dart';

final mrMrByNoStateProvider =
    StateNotifierProvider<MrByNoStateNotifier, MrByNoState>(
  (ref) => MrByNoStateNotifier(ref: ref),
);

class MrByNoStateNotifier extends StateNotifier<MrByNoState> {
  final Ref ref;
  MrByNoStateNotifier({
    required this.ref,
  }) : super(MrByNoStateInit());

  void reset() {
    state = MrByNoStateInit();
  }

  void byNo({
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = MrByNoStateLoading();
    try {
      final resp = await MaterialReturnRepository(dio: dio).getBySlip(
        slipNo,
      );
      state = MrByNoStateDone(
        model: resp,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MrByNoStateError(message: e.message);
      } else {
        state = MrByNoStateError(message: e.toString());
      }
    }
  }
}

abstract class MrByNoState extends Equatable {
  final DateTime date;
  MrByNoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class MrByNoStateInit extends MrByNoState {
  MrByNoStateInit() : super(date: DateTime.now());
}

class MrByNoStateLoading extends MrByNoState {
  MrByNoStateLoading() : super(date: DateTime.now());
}

class MrByNoStateToken extends MrByNoState {
  MrByNoStateToken() : super(date: DateTime.now());
}

class MrByNoStateNoToken extends MrByNoState {
  MrByNoStateNoToken() : super(date: DateTime.now());
}

class MrByNoStateError extends MrByNoState {
  final String message;
  MrByNoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class MrByNoStateDone extends MrByNoState {
  final MrSlipModel model;
  MrByNoStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
