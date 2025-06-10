import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/client_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/client_repository.dart';

final clientSearchProvider =
    StateNotifierProvider<ClientNotifier, ClientSearchState>(
        (ref) => ClientNotifier(ref: ref));

class ClientNotifier extends StateNotifier<ClientSearchState> {
  final Ref ref;
  ClientNotifier({required this.ref}) : super(ClientSearchStateInit());

  void search({required String query}) async {
    state = ClientSearchStateLoading();
    try {
      // ClientRepository().search does not require a token based on client_repository.dart
      final resp = await ClientRepository(dio: ref.read(dioProvider))
          .search(query: query);
      state = ClientSearchStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ClientSearchStateError(message: e.message);
      } else {
        state = ClientSearchStateError(message: e.toString());
      }
    }
  }
}

abstract class ClientSearchState extends Equatable {
  final DateTime date;

  const ClientSearchState(this.date);
  @override
  List<Object?> get props => [date];
}

class ClientSearchStateInit extends ClientSearchState {
  ClientSearchStateInit() : super(DateTime.now());
}

class ClientSearchStateLoading extends ClientSearchState {
  ClientSearchStateLoading() : super(DateTime.now());
}

class ClientSearchStateError extends ClientSearchState {
  final String message;
  ClientSearchStateError({
    required this.message,
  }) : super(DateTime.now());
}

class ClientSearchStateDone extends ClientSearchState {
  final List<ClientModel> model;
  ClientSearchStateDone({
    required this.model,
  }) : super(DateTime.now());
}
