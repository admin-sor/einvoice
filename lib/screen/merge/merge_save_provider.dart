import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/merge_repository.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final mergeSaveStateProvider =
    StateNotifierProvider<MergeSaveStateNotifier, MergeSaveState>(
  (ref) => MergeSaveStateNotifier(ref: ref),
);

class MergeSaveStateNotifier extends StateNotifier<MergeSaveState> {
  final Ref ref;
  MergeSaveStateNotifier({
    required this.ref,
  }) : super(MergeSaveStateInit());

  void reset() {
    state = MergeSaveStateInit();
  }

  void save({
    required List<ParamMergeSave> merge,
    required String storeID,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = MergeSaveStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = MergeSaveStateLoading();
    try {
      final resp = await MergeRepository(dio: dio).save(
        merge: merge,
        storeID: storeID,
        token: loginModel!.token!,
      );
      state = MergeSaveStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MergeSaveStateError(message: e.message);
      } else {
        state = MergeSaveStateError(message: e.toString());
      }
    }
  }
}

abstract class MergeSaveState extends Equatable {
  final DateTime date;
  const MergeSaveState({required this.date});
  @override
  List<Object?> get props => [date];
}

class MergeSaveStateInit extends MergeSaveState {
  MergeSaveStateInit() : super(date: DateTime.now());
}

class MergeSaveStateLoading extends MergeSaveState {
  MergeSaveStateLoading() : super(date: DateTime.now());
}

class MergeSaveStateToken extends MergeSaveState {
  MergeSaveStateToken() : super(date: DateTime.now());
}

class MergeSaveStateNoToken extends MergeSaveState {
  MergeSaveStateNoToken() : super(date: DateTime.now());
}

class MergeSaveStateError extends MergeSaveState {
  final String message;
  MergeSaveStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class MergeSaveStateDone extends MergeSaveState {
  final ResponseMergeSave model;
  MergeSaveStateDone({required this.model}) : super(date: DateTime.now());
}
