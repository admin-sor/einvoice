import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/store_repository.dart';
import 'store_search_provider.dart';

final storeDeleteProvider =
    StateNotifierProvider<StoreDeleteNotifier, StoreDeleteState>(
  (ref) => StoreDeleteNotifier(ref: ref),
);

class StoreDeleteNotifier extends StateNotifier<StoreDeleteState> {
  final Ref ref;
  StoreDeleteNotifier({required this.ref}) : super(StoreDeleteStateInit());

  void delete({
    required String storeID,
    required String query,
  }) async {
    state = StoreDeleteStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = StoreDeleteStateError(message: "Invalid Token");
        return;
      }
      await StoreRepository(dio: ref.read(dioProvider)).delete(
        storeID: storeID,
        token: loginModel!.token!,
      );
      state = StoreDeleteStateDone();
      ref.read(storeSearchProvider.notifier).search(query: query);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StoreDeleteStateError(message: e.message);
      } else {
        state = StoreDeleteStateError(message: e.toString());
      }
    }
  }
}

abstract class StoreDeleteState extends Equatable {
  final DateTime date;
  const StoreDeleteState(this.date);

  @override
  List<Object?> get props => [date];
}

class StoreDeleteStateInit extends StoreDeleteState {
  StoreDeleteStateInit() : super(DateTime.now());
}

class StoreDeleteStateLoading extends StoreDeleteState {
  StoreDeleteStateLoading() : super(DateTime.now());
}

class StoreDeleteStateError extends StoreDeleteState {
  final String message;
  StoreDeleteStateError({required this.message}) : super(DateTime.now());
}

class StoreDeleteStateDone extends StoreDeleteState {
  StoreDeleteStateDone() : super(DateTime.now());
}
