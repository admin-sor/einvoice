import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/material_return_repository.dart';

import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/checkout_repository.dart';

final mrReturnedLookupStateProvider =
    StateNotifierProvider<MrReturnedLookupStateNotifier, MrReturnedLookupState>(
  (ref) => MrReturnedLookupStateNotifier(ref: ref),
);

class MrReturnedLookupStateNotifier extends StateNotifier<MrReturnedLookupState> {
  final Ref ref;
  MrReturnedLookupStateNotifier({
    required this.ref,
  }) : super(MrReturnedLookupStateInit());

  void reset() {
    state = MrReturnedLookupStateInit();
  }

  void lookup({
    required String dbName,
    required String search,
    required String soID,
    required String cpID,
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = MrReturnedLookupStateLoading();
    try {
      final resp = await MaterialReturnRepository(dio: dio).materialLookupReturned(
        cpID,
        soID,
        dbName,
        search,
        slipNo
      );
      state = MrReturnedLookupStateDone(
        model: resp,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MrReturnedLookupStateError(message: e.message);
      } else {
        state = MrReturnedLookupStateError(message: e.toString());
      }
    }
  }
}

abstract class MrReturnedLookupState extends Equatable {
  final DateTime date;
  MrReturnedLookupState({required this.date});
  @override
  List<Object?> get props => [date];
}

class MrReturnedLookupStateInit extends MrReturnedLookupState {
  MrReturnedLookupStateInit() : super(date: DateTime.now());
}

class MrReturnedLookupStateLoading extends MrReturnedLookupState {
  MrReturnedLookupStateLoading() : super(date: DateTime.now());
}

class MrReturnedLookupStateToken extends MrReturnedLookupState {
  MrReturnedLookupStateToken() : super(date: DateTime.now());
}

class MrReturnedLookupStateNoToken extends MrReturnedLookupState {
  MrReturnedLookupStateNoToken() : super(date: DateTime.now());
}

class MrReturnedLookupStateError extends MrReturnedLookupState {
  final String message;
  MrReturnedLookupStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class MrReturnedLookupStateDone extends MrReturnedLookupState {
  final ResponseMaterialReturnScanV2 model;
  MrReturnedLookupStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
