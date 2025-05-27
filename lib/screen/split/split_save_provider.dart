import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/split_repository.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final splitSaveStateProvider =
    StateNotifierProvider<SplitSaveStateNotifier, SplitSaveState>(
  (ref) => SplitSaveStateNotifier(ref: ref),
);

class SplitSaveStateNotifier extends StateNotifier<SplitSaveState> {
  final Ref ref;
  SplitSaveStateNotifier({
    required this.ref,
  }) : super(SplitSaveStateInit());

  void reset() {
    state = SplitSaveStateInit();
  }

  void save({
    required String refOrigin,
    required String refID,
    required List<String> split,
    required String storeID,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = SplitSaveStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = SplitSaveStateLoading();
    try {
      final resp = await SplitRepository(dio: dio).save(
        ref: refOrigin,
        refID: refID,
        storeID: storeID,
        split: split,
        token: loginModel!.token!,
      );
      state = SplitSaveStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SplitSaveStateError(message: e.message);
      } else {
        state = SplitSaveStateError(message: e.toString());
      }
    }
  }
}

abstract class SplitSaveState extends Equatable {
  final DateTime date;
  const SplitSaveState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SplitSaveStateInit extends SplitSaveState {
  SplitSaveStateInit() : super(date: DateTime.now());
}

class SplitSaveStateLoading extends SplitSaveState {
  SplitSaveStateLoading() : super(date: DateTime.now());
}

class SplitSaveStateToken extends SplitSaveState {
  SplitSaveStateToken() : super(date: DateTime.now());
}

class SplitSaveStateNoToken extends SplitSaveState {
  SplitSaveStateNoToken() : super(date: DateTime.now());
}

class SplitSaveStateError extends SplitSaveState {
  final String message;
  SplitSaveStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SplitSaveStateDone extends SplitSaveState {
  final List<String> model;
  SplitSaveStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
