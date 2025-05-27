import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/po_response_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/po_repository.dart';

final getPoProvider = StateNotifierProvider<GetPoStateNotifier, GetPoState>(
  (ref) => GetPoStateNotifier(ref: ref),
);

class GetPoStateNotifier extends StateNotifier<GetPoState> {
  final Ref ref;
  GetPoStateNotifier({
    required this.ref,
  }) : super(GetPoStateInit());

  void reset() {
    state = GetPoStateInit();
  }

  void get({
    required String poNo,
    required String vendorID,
  }) async {
    final dio = ref.read(dioProvider);
    state = GetPoStateLoading();
    try {
      final resp = await PoRepository(dio: dio).get(
        poNo: poNo,
        vendorID: vendorID,
      );
      state = GetPoStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = GetPoStateError(message: e.message);
      } else {
        state = GetPoStateError(message: e.toString());
      }
    }
  }
}

abstract class GetPoState extends Equatable {
  final DateTime date;
  const GetPoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class GetPoStateInit extends GetPoState {
  GetPoStateInit() : super(date: DateTime.now());
}

class GetPoStateLoading extends GetPoState {
  GetPoStateLoading() : super(date: DateTime.now());
}

class GetPoStateToken extends GetPoState {
  GetPoStateToken() : super(date: DateTime.now());
}

class GetPoStateNoToken extends GetPoState {
  GetPoStateNoToken() : super(date: DateTime.now());
}

class GetPoStateError extends GetPoState {
  final String message;
  GetPoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class GetPoStateDone extends GetPoState {
  final PoSaveResponseModel model;
  GetPoStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
