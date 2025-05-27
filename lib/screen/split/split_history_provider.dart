import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/split_repository.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final splitHistoryStateProvider =
    StateNotifierProvider<SplitHistoryStateNotifier, SplitHistoryState>(
  (ref) => SplitHistoryStateNotifier(ref: ref),
);

class SplitHistoryStateNotifier extends StateNotifier<SplitHistoryState> {
  final Ref ref;
  SplitHistoryStateNotifier({
    required this.ref,
  }) : super(SplitHistoryStateInit());

  void reset() {
    state = SplitHistoryStateInit();
  }

  void byID({
    required String splitID,
  }) async {
    final dio = ref.read(dioProvider);
    state = SplitHistoryStateLoading();
    try {
      final resp = await SplitRepository(dio: dio).byId(
       splitID: splitID,
      );
      state = SplitHistoryStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SplitHistoryStateError(message: e.message);
      } else {
        state = SplitHistoryStateError(message: e.toString());
      }
    }
  }
}

abstract class SplitHistoryState extends Equatable {
  final DateTime date;
  const SplitHistoryState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SplitHistoryStateInit extends SplitHistoryState {
  SplitHistoryStateInit() : super(date: DateTime.now());
}

class SplitHistoryStateLoading extends SplitHistoryState {
  SplitHistoryStateLoading() : super(date: DateTime.now());
}

class SplitHistoryStateToken extends SplitHistoryState {
  SplitHistoryStateToken() : super(date: DateTime.now());
}

class SplitHistoryStateNoToken extends SplitHistoryState {
  SplitHistoryStateNoToken() : super(date: DateTime.now());
}

class SplitHistoryStateError extends SplitHistoryState {
  final String message;
  SplitHistoryStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SplitHistoryStateDone extends SplitHistoryState {
  final List<ResponseSplitHistoryModel> list;
  SplitHistoryStateDone({required this.list}) : super(date: DateTime.now());
}
