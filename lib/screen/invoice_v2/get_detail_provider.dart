import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/invoice_v2_model.dart';
import 'package:sor_inventory/repository/invoice_repository.dart';

import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';

final getDetailProvider =
    StateNotifierProvider<GetDetailStateNotifier, GetDetailState>(
  (ref) => GetDetailStateNotifier(ref: ref),
);

class GetDetailStateNotifier extends StateNotifier<GetDetailState> {
  final Ref ref;
  GetDetailStateNotifier({
    required this.ref,
  }) : super(GetDetailStateInit());

  void reset() {
    state = GetDetailStateInit();
  }

  void get({
    required String invoiceID,
  }) async {
    final dio = ref.read(dioProvider);
    state = GetDetailStateLoading();
    try {
      final resp = await InvoiceRepository(dio: dio).getDetail(
        invoiceID: invoiceID,
      );
      state = GetDetailStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = GetDetailStateError(message: e.message);
      } else {
        state = GetDetailStateError(message: e.toString());
      }
    }
  }
}

abstract class GetDetailState extends Equatable {
  final DateTime date;
  const GetDetailState({required this.date});
  @override
  List<Object?> get props => [date];
}

class GetDetailStateInit extends GetDetailState {
  GetDetailStateInit() : super(date: DateTime.now());
}

class GetDetailStateLoading extends GetDetailState {
  GetDetailStateLoading() : super(date: DateTime.now());
}

class GetDetailStateToken extends GetDetailState {
  GetDetailStateToken() : super(date: DateTime.now());
}

class GetDetailStateNoToken extends GetDetailState {
  GetDetailStateNoToken() : super(date: DateTime.now());
}

class GetDetailStateError extends GetDetailState {
  final String message;
  GetDetailStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class GetDetailStateDone extends GetDetailState {
  final List<InvoiceDetailModel> model;
  GetDetailStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
