import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/po_summary_response_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/po_repository.dart';

final poSummaryProvider =
    StateNotifierProvider<PoSummaryStateNotifier, PoSummaryState>(
  (ref) => PoSummaryStateNotifier(ref: ref),
);

class PoSummaryStateNotifier extends StateNotifier<PoSummaryState> {
  final Ref ref;
  PoSummaryStateNotifier({
    required this.ref,
  }) : super(PoSummaryStateInit());

  void reset() {
    state = PoSummaryStateInit();
  }

  void list({
    required String search,
    required String vendorID,
    String status = "A",
  }) async {
    final dio = ref.read(dioProvider);
    state = PoSummaryStateLoading();
    try {
      final resp = await PoRepository(dio: dio).summary(
        search: search,
        vendorID: vendorID,
        status: status,
      );
      state = PoSummaryStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = PoSummaryStateError(message: e.message);
      } else {
        state = PoSummaryStateError(message: e.toString());
      }
    }
  }
}

abstract class PoSummaryState extends Equatable {
  final DateTime date;
  PoSummaryState({required this.date});
  @override
  List<Object?> get props => [date];
}

class PoSummaryStateInit extends PoSummaryState {
  PoSummaryStateInit() : super(date: DateTime.now());
}

class PoSummaryStateLoading extends PoSummaryState {
  PoSummaryStateLoading() : super(date: DateTime.now());
}

class PoSummaryStateToken extends PoSummaryState {
  PoSummaryStateToken() : super(date: DateTime.now());
}

class PoSummaryStateNoToken extends PoSummaryState {
  PoSummaryStateNoToken() : super(date: DateTime.now());
}

class PoSummaryStateError extends PoSummaryState {
  final String message;
  PoSummaryStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class PoSummaryStateDone extends PoSummaryState {
  final List<PoSummaryResponseModel> list;
  PoSummaryStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
