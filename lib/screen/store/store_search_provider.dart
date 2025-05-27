import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/base_repository.dart';

import '../../model/store_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/store_repository.dart';

final storeSearchProvider =
    StateNotifierProvider<StoreSearchStateNotifier, StoreSearchState>(
  (ref) => StoreSearchStateNotifier(ref: ref),
);

class StoreSearchStateNotifier extends StateNotifier<StoreSearchState> {
  final Ref ref;
  StoreSearchStateNotifier({required this.ref})
      : super(StoreSearchStateInit());
  void search({required String query}) async {
    state = StoreSearchStateLoading();
    try {
      final resp = await StoreRepository(dio: ref.read(dioProvider))
          .search(query: query);
      state = StoreSearchStateDone(resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StoreSearchStateError(e.message);
      } else {
        state = StoreSearchStateError(e.toString());
      }
    }
  }
}

abstract class StoreSearchState extends Equatable {
  final DateTime date;

  const StoreSearchState(this.date);

  @override
  List<Object?> get props => [date];
}

class StoreSearchStateInit extends StoreSearchState {
  StoreSearchStateInit() : super(DateTime.now());
}

class StoreSearchStateLoading extends StoreSearchState {
  StoreSearchStateLoading() : super(DateTime.now());
}

class StoreSearchStateError extends StoreSearchState {
  final String message;
  StoreSearchStateError(this.message) : super(DateTime.now());
}

class StoreSearchStateDone extends StoreSearchState {
  final List<StoreModel> list;
  StoreSearchStateDone(this.list) : super(DateTime.now());
}
