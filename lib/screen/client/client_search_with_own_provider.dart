import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/client_model.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/client_repository.dart';

import '../../provider/dio_provider.dart';

final clientSearchWithOwnProvider =
    StateNotifierProvider<ClientSearchWithOwnNotifier, ClientSearchWithOwnState>(
  (ref) => ClientSearchWithOwnNotifier(ref: ref),
);

class ClientSearchWithOwnNotifier
    extends StateNotifier<ClientSearchWithOwnState> {
  final Ref ref;
  ClientSearchWithOwnNotifier({required this.ref})
      : super(ClientSearchWithOwnStateInit());

  void search({required String query}) async {
    state = ClientSearchWithOwnStateLoading();
    try {
      final resp =
          await ClientRepository(dio: ref.read(dioProvider)).searchWithOwn(
        query: query,
      );
      state = ClientSearchWithOwnStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ClientSearchWithOwnStateError(message: e.message);
      } else {
        state = ClientSearchWithOwnStateError(message: e.toString());
      }
    }
  }
}

abstract class ClientSearchWithOwnState extends Equatable {
  final DateTime date;
  const ClientSearchWithOwnState(this.date);
  @override
  List<Object?> get props => [date];
}

class ClientSearchWithOwnStateInit extends ClientSearchWithOwnState {
  ClientSearchWithOwnStateInit() : super(DateTime.now());
}

class ClientSearchWithOwnStateLoading extends ClientSearchWithOwnState {
  ClientSearchWithOwnStateLoading() : super(DateTime.now());
}

class ClientSearchWithOwnStateError extends ClientSearchWithOwnState {
  final String message;
  ClientSearchWithOwnStateError({required this.message})
      : super(DateTime.now());
}

class ClientSearchWithOwnStateDone extends ClientSearchWithOwnState {
  final List<ClientModel> model;
  ClientSearchWithOwnStateDone({required this.model}) : super(DateTime.now());
}
