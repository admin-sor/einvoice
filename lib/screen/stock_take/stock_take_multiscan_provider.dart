import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/stock_take_repository.dart';
import 'stock_take_current_provider.dart';

final stockTakeMultiScanProvider =
    StateNotifierProvider<StockTakeMultiScanNotifier, StockTakeMultiScanState>(
        (ref) => StockTakeMultiScanNotifier(ref: ref));

class StockTakeMultiScanNotifier
    extends StateNotifier<StockTakeMultiScanState> {
  final Ref ref;
  StockTakeMultiScanNotifier({
    required this.ref,
  }) : super(StockTakeMultiScanStateInit());

  void multiScan(String eventID, List<String> qrCode, String storeID) async {
    state = StockTakeMultiScanStateLoading();
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      final result = await StockTakeRepository(dio: dio).multiScan(
        token: token,
        qrCode: qrCode,
        eventID: eventID,
        storeID: storeID,
      );

      ref
          .read(stockTakeCurrentProvider.notifier)
          .currentSummary(stockTakeID: eventID);
      state = StockTakeMultiScanStateDone(list: result);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StockTakeMultiScanStateError(message: e.message);
      } else {
        state = StockTakeMultiScanStateError(message: e.toString());
      }
    }
  }

  void reset() {
    state = StockTakeMultiScanStateInit();
  }
}

abstract class StockTakeMultiScanState extends Equatable {
  final DateTime date = DateTime.now();
  StockTakeMultiScanState();

  @override
  List<Object?> get props => [date];
}

class StockTakeMultiScanStateInit extends StockTakeMultiScanState {}

class StockTakeMultiScanStateLoading extends StockTakeMultiScanState {}

class StockTakeMultiScanStateError extends StockTakeMultiScanState {
  final String message;
  StockTakeMultiScanStateError({required this.message});
}

class StockTakeMultiScanStateDone extends StockTakeMultiScanState {
  final List<StockTakeMultiScanResponse> list;
  StockTakeMultiScanStateDone({
    required this.list,
  });
}
