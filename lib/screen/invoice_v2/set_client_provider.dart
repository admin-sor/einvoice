import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/client_repository.dart';
import 'package:sor_inventory/repository/invoice_repository.dart';

import '../../model/client_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';

final StateProvider<ClientModel?> setClientStateProvider =
    StateProvider((ref) => null);

final getClientProvider =
    StateNotifierProvider<GetClientStateNotifier, GetClientState>(
  (ref) => GetClientStateNotifier(ref: ref),
);

class GetClientStateNotifier extends StateNotifier<GetClientState> {
  final Ref ref;
  GetClientStateNotifier({
    required this.ref,
  }) : super(GetClientStateInit());

  void reset() {
    state = GetClientStateInit();
  }

  void get({
    required String clientID,
  }) async {
    final dio = ref.read(dioProvider);
    state = GetClientStateLoading();
    try {
      final resp = await ClientRepository(dio: dio).get(
        clientID: clientID,
      );
      // ref.read(setClientStateProvider.notifier).state = resp;
      state = GetClientStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = GetClientStateError(message: e.message);
      } else {
        state = GetClientStateError(message: e.toString());
      }
    }
  }
}

abstract class GetClientState extends Equatable {
  final DateTime date;
  const GetClientState({required this.date});
  @override
  List<Object?> get props => [date];
}

class GetClientStateInit extends GetClientState {
  GetClientStateInit() : super(date: DateTime.now());
}

class GetClientStateLoading extends GetClientState {
  GetClientStateLoading() : super(date: DateTime.now());
}

class GetClientStateToken extends GetClientState {
  GetClientStateToken() : super(date: DateTime.now());
}

class GetClientStateNoToken extends GetClientState {
  GetClientStateNoToken() : super(date: DateTime.now());
}

class GetClientStateError extends GetClientState {
  final String message;
  GetClientStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class GetClientStateDone extends GetClientState {
  final ClientModel model;
  GetClientStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
