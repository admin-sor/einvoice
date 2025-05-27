import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/merge_repository.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final mergeByIDStateProvider =
    StateNotifierProvider<MergeByIDStateNotifier, MergeByIDState>(
  (ref) => MergeByIDStateNotifier(ref: ref),
);

class MergeByIDStateNotifier extends StateNotifier<MergeByIDState> {
  final Ref ref;
  MergeByIDStateNotifier({
    required this.ref,
  }) : super(MergeByIDStateInit());

  void reset() {
    state = MergeByIDStateInit();
  }

  void list({
    required String mergeMaterialID,
  }) async {
    final dio = ref.read(dioProvider);
    state = MergeByIDStateLoading();
    try {
      final resp = await MergeRepository(dio: dio).byID(
        mergeMaterialID: mergeMaterialID
      );
      state = MergeByIDStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MergeByIDStateError(message: e.message);
      } else {
        state = MergeByIDStateError(message: e.toString());
      }
    }
  }
}

abstract class MergeByIDState extends Equatable {
  final DateTime date;
  const MergeByIDState({required this.date});
  @override
  List<Object?> get props => [date];
}

class MergeByIDStateInit extends MergeByIDState {
  MergeByIDStateInit() : super(date: DateTime.now());
}

class MergeByIDStateLoading extends MergeByIDState {
  MergeByIDStateLoading() : super(date: DateTime.now());
}

class MergeByIDStateToken extends MergeByIDState {
  MergeByIDStateToken() : super(date: DateTime.now());
}

class MergeByIDStateNoToken extends MergeByIDState {
  MergeByIDStateNoToken() : super(date: DateTime.now());
}

class MergeByIDStateError extends MergeByIDState {
  final String message;
  MergeByIDStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class MergeByIDStateDone extends MergeByIDState {
  final List<ResponseMergeScan> list;
  MergeByIDStateDone({required this.list}) : super(date: DateTime.now());
}
