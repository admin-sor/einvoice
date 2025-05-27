import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/split_material_model.dart';
import 'package:sor_inventory/repository/split_repository.dart';

import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';

final splitListStateProvider =
    StateNotifierProvider<SplitListStateNotifier, SplitListState>(
  (ref) => SplitListStateNotifier(ref: ref),
);

class SplitListStateNotifier extends StateNotifier<SplitListState> {
  final Ref ref;
  SplitListStateNotifier({
    required this.ref,
  }) : super(SplitListStateInit());

  void reset() {
    state = SplitListStateInit();
  }

  void search({
    required String storeID,
    required String search,
    required String type,
  }) async {
    final dio = ref.read(dioProvider);
    state = SplitListStateLoading();
    try {
      final resp = await SplitRepository(dio: dio).search(
       storeID: storeID,
       search: search,
       type: type,
      );
      state = SplitListStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SplitListStateError(message: e.message);
      } else {
        state = SplitListStateError(message: e.toString());
      }
    }
  }
}

abstract class SplitListState extends Equatable {
  final DateTime date;
  const SplitListState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SplitListStateInit extends SplitListState {
  SplitListStateInit() : super(date: DateTime.now());
}

class SplitListStateLoading extends SplitListState {
  SplitListStateLoading() : super(date: DateTime.now());
}

class SplitListStateToken extends SplitListState {
  SplitListStateToken() : super(date: DateTime.now());
}

class SplitListStateNoToken extends SplitListState {
  SplitListStateNoToken() : super(date: DateTime.now());
}

class SplitListStateError extends SplitListState {
  final String message;
  SplitListStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SplitListStateDone extends SplitListState {
  final List<SplitMaterialModel> list;
  SplitListStateDone({required this.list}) : super(date: DateTime.now());
}
