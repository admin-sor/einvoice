import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/client_repository.dart'; // Use ClientRepository
import 'package:sor_inventory/screen/client/client_search_provider.dart'; // Assuming this exists
import '../../provider/shared_preference_provider.dart';

// Define the StateNotifierProvider
final clientDeleteProvider =
    StateNotifierProvider<ClientDeleteNotifier, ClientDeleteState>(
  (ref) => ClientDeleteNotifier(ref: ref),
);

// Define the StateNotifier
class ClientDeleteNotifier extends StateNotifier<ClientDeleteState> {
  Ref ref;
  ClientDeleteNotifier({required this.ref}) : super(ClientDeleteStateInit());

  // Delete method
  void delete({
    required int clientId, // Use int based on ClientRepository
    required String query, // For refreshing the list after deletion
  }) async {
    state = ClientDeleteStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = ClientDeleteStateError(message: "Invalid Token");
        return;
      }

      await ClientRepository(dio: ref.read(dioProvider)).delete(
        // Use ClientRepository
        token: loginModel!.token!,
        evClientID: clientId, // Use evClientID based on ClientRepository
      );

      // Refresh the client search results after successful deletion
      ref
          .read(clientSearchProvider.notifier)
          .search(query: query); // Assuming clientSearchProvider

      state = ClientDeleteStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ClientDeleteStateError(message: e.message);
      } else {
        state = ClientDeleteStateError(message: e.toString());
      }
    }
  }
}

// Abstract base state class
abstract class ClientDeleteState extends Equatable {
  final DateTime date;
  const ClientDeleteState(this.date);

  @override
  List<Object?> get props => [date];
}

// Initial state
class ClientDeleteStateInit extends ClientDeleteState {
  ClientDeleteStateInit() : super(DateTime.now());
}

// Loading state
class ClientDeleteStateLoading extends ClientDeleteState {
  ClientDeleteStateLoading() : super(DateTime.now());
}

// Error state
class ClientDeleteStateError extends ClientDeleteState {
  final String message;
  ClientDeleteStateError({
    required this.message,
  }) : super(DateTime.now());

  @override
  List<Object?> get props => [date, message]; // Include message in props
}

// Done state
class ClientDeleteStateDone extends ClientDeleteState {
  ClientDeleteStateDone() : super(DateTime.now());
}
