import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/dispose_slip_model.dart';
import 'package:sor_inventory/repository/dispose_repository.dart';

import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';

final disposeListSlipStateProvider =
    StateNotifierProvider<DisposeListSlipStateNotifier, DisposeListSlipState>(
  (ref) => DisposeListSlipStateNotifier(ref: ref),
);

class DisposeListSlipStateNotifier extends StateNotifier<DisposeListSlipState> {
  final Ref ref;
  DisposeListSlipStateNotifier({
    required this.ref,
  }) : super(DisposeListSlipStateInit());

  void reset() {
    state = DisposeListSlipStateInit();
  }

  void list({
    required String storeID,
    required String search,
  }) async {
    final dio = ref.read(dioProvider);
    state = DisposeListSlipStateLoading();
    try {
      final resp = await DisposeRepository(dio: dio).list(
        search,
        storeID,
      );
      state = DisposeListSlipStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = DisposeListSlipStateError(message: e.message);
      } else {
        state = DisposeListSlipStateError(message: e.toString());
      }
    }
  }
  
}

abstract class DisposeListSlipState extends Equatable {
  final DateTime date;
  DisposeListSlipState({required this.date});
  @override
  List<Object?> get props => [date];
}

class DisposeListSlipStateInit extends DisposeListSlipState {
  DisposeListSlipStateInit() : super(date: DateTime.now());
}

class DisposeListSlipStateLoading extends DisposeListSlipState {
  DisposeListSlipStateLoading() : super(date: DateTime.now());
}

class DisposeListSlipStateToken extends DisposeListSlipState {
  DisposeListSlipStateToken() : super(date: DateTime.now());
}

class DisposeListSlipStateNoToken extends DisposeListSlipState {
  DisposeListSlipStateNoToken() : super(date: DateTime.now());
}

class DisposeListSlipStateError extends DisposeListSlipState {
  final String message;
  DisposeListSlipStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class DisposeListSlipStateDone extends DisposeListSlipState {
  final List<DisposeSlipModel> list;
  DisposeListSlipStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
