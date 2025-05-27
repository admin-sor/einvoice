import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/checkout_model_v2.dart';
import 'package:sor_inventory/repository/checkout_repository.dart';
import 'package:sor_inventory/repository/merge_repository.dart';

import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';

final listBarcodeStateProvider =
    StateNotifierProvider<ListBarcodeStateNotifier, ListBarcodeState>(
  (ref) => ListBarcodeStateNotifier(ref: ref),
);

class ListBarcodeStateNotifier extends StateNotifier<ListBarcodeState> {
  final Ref ref;
  ListBarcodeStateNotifier({
    required this.ref,
  }) : super(ListBarcodeStateInit());

  void reset() {
    state = ListBarcodeStateInit();
  }

  void list({
    required String filter,
    required String search,
    required DateTime from,
    required DateTime to,
    
  }) async {
    final dio = ref.read(dioProvider);
    state = ListBarcodeStateLoading();
    final sdf = DateFormat("y-MM-dd");
    try {
      final resp = await MergeRepository(dio: dio).listSplitMerge(
        filter: filter,
        search: search,
        from: sdf.format(from),
        to: sdf.format(to),
      );
      state = ListBarcodeStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ListBarcodeStateError(message: e.message);
      } else {
        state = ListBarcodeStateError(message: e.toString());
      }
    }
  }
}

abstract class ListBarcodeState extends Equatable {
  final DateTime date;
  ListBarcodeState({required this.date});
  @override
  List<Object?> get props => [date];
}

class ListBarcodeStateInit extends ListBarcodeState {
  ListBarcodeStateInit() : super(date: DateTime.now());
}

class ListBarcodeStateLoading extends ListBarcodeState {
  ListBarcodeStateLoading() : super(date: DateTime.now());
}

class ListBarcodeStateToken extends ListBarcodeState {
  ListBarcodeStateToken() : super(date: DateTime.now());
}

class ListBarcodeStateNoToken extends ListBarcodeState {
  ListBarcodeStateNoToken() : super(date: DateTime.now());
}

class ListBarcodeStateError extends ListBarcodeState {
  final String message;
  ListBarcodeStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ListBarcodeStateDone extends ListBarcodeState {
  final List<SplitMergeResponse> list;
  ListBarcodeStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
