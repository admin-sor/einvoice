import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/material_return_scan_response.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/material_return_repository.dart';

final getMaterialReturnStateProvider = StateNotifierProvider<
    GetMaterialReturnStateNotifier, GetMaterialReturnState>(
  (ref) => GetMaterialReturnStateNotifier(ref: ref),
);

class GetMaterialReturnStateNotifier
    extends StateNotifier<GetMaterialReturnState> {
  final Ref ref;
  GetMaterialReturnStateNotifier({
    required this.ref,
  }) : super(GetMaterialReturnStateInit());

  void reset() {
    state = GetMaterialReturnStateInit();
  }

  void get({
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = GetMaterialReturnStateLoading();
    try {
      final resp = await MaterialReturnRepository(dio: dio).get(
        slipNo: slipNo,
      );
      state = GetMaterialReturnStateDone(
        list: resp,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = GetMaterialReturnStateError(message: e.message);
      } else {
        state = GetMaterialReturnStateError(message: e.toString());
      }
    }
  }
}

abstract class GetMaterialReturnState extends Equatable {
  final DateTime date;
  const GetMaterialReturnState({required this.date});
  @override
  List<Object?> get props => [date];
}

class GetMaterialReturnStateInit extends GetMaterialReturnState {
  GetMaterialReturnStateInit() : super(date: DateTime.now());
}

class GetMaterialReturnStateLoading extends GetMaterialReturnState {
  GetMaterialReturnStateLoading() : super(date: DateTime.now());
}

class GetMaterialReturnStateToken extends GetMaterialReturnState {
  GetMaterialReturnStateToken() : super(date: DateTime.now());
}

class GetMaterialReturnStateNoToken extends GetMaterialReturnState {
  GetMaterialReturnStateNoToken() : super(date: DateTime.now());
}

class GetMaterialReturnStateError extends GetMaterialReturnState {
  final String message;
  GetMaterialReturnStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class GetMaterialReturnStateDone extends GetMaterialReturnState {
  final List<MaterialReturnScanResponseModel> list;
  GetMaterialReturnStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
