import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/material_return_repository.dart';

import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/checkout_repository.dart';

final mrMrMaterialLookupStateProvider =
    StateNotifierProvider<MrMaterialLookupStateNotifier, MrMaterialLookupState>(
  (ref) => MrMaterialLookupStateNotifier(ref: ref),
);

class MrMaterialLookupStateNotifier extends StateNotifier<MrMaterialLookupState> {
  final Ref ref;
  MrMaterialLookupStateNotifier({
    required this.ref,
  }) : super(MrMaterialLookupStateInit());

  void reset() {
    state = MrMaterialLookupStateInit();
  }

  void lookup({
    required String dbName,
    required String search,
    required String soID,
    required String cpID,
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = MrMaterialLookupStateLoading();
    try {
      final resp = await MaterialReturnRepository(dio: dio).materialLookup(
        cpID,
        soID,
        dbName,
        search,
        slipNo
      );
      state = MrMaterialLookupStateDone(
        model: resp,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MrMaterialLookupStateError(message: e.message);
      } else {
        state = MrMaterialLookupStateError(message: e.toString());
      }
    }
  }
}

abstract class MrMaterialLookupState extends Equatable {
  final DateTime date;
  MrMaterialLookupState({required this.date});
  @override
  List<Object?> get props => [date];
}

class MrMaterialLookupStateInit extends MrMaterialLookupState {
  MrMaterialLookupStateInit() : super(date: DateTime.now());
}

class MrMaterialLookupStateLoading extends MrMaterialLookupState {
  MrMaterialLookupStateLoading() : super(date: DateTime.now());
}

class MrMaterialLookupStateToken extends MrMaterialLookupState {
  MrMaterialLookupStateToken() : super(date: DateTime.now());
}

class MrMaterialLookupStateNoToken extends MrMaterialLookupState {
  MrMaterialLookupStateNoToken() : super(date: DateTime.now());
}

class MrMaterialLookupStateError extends MrMaterialLookupState {
  final String message;
  MrMaterialLookupStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class MrMaterialLookupStateDone extends MrMaterialLookupState {
  final ResponseMaterialReturnScanV2 model;
  MrMaterialLookupStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
