import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/client_repository.dart';
import 'package:sor_inventory/screen/client/client_search_provider.dart';

import '../../provider/shared_preference_provider.dart';

final clientEditProvider =
    StateNotifierProvider<ClientEditNotifier, ClientEditState>(
  (ref) => ClientEditNotifier(ref: ref),
);

class ClientEditNotifier extends StateNotifier<ClientEditState> {
  Ref ref;
  ClientEditNotifier({required this.ref}) : super(ClientEditStateInit());

  void edit({
    required int evClientID,
    required String evClientName,
    required String evClientBusinessRegNo,
    required String evClientBusinessRegType,
    required String evClientSstNo,
    required String evClientTinNo,
    required String evClientAddr1,
    required String evClientAddr2,
    required String evClientAddr3,
    required String evClientPic,
    required String evClientEmail,
    required String evClientPhone,
    required String query, // Parameter to refresh search results
  }) async {
    state = ClientEditStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = ClientEditStateError(message: "Invalid Token");
        return;
      }
      if (evClientID == 0) {
        await ClientRepository(dio: ref.read(dioProvider)).add(
          token: loginModel!.token!,
          evClientName: evClientName,
          evClientBusinessRegNo: evClientBusinessRegNo,
          evClientBusinessRegType: evClientBusinessRegType,
          evClientSstNo: evClientSstNo,
          evClientTinNo: evClientTinNo,
          evClientAddr1: evClientAddr1,
          evClientAddr2: evClientAddr2,
          evClientAddr3: evClientAddr3,
          evClientPic: evClientPic,
          evClientEmail: evClientEmail,
          evClientPhone: evClientPhone,
        );
        // Refresh the client search results after successful edit
      } else {
        await ClientRepository(dio: ref.read(dioProvider)).edit(
          token: loginModel!.token!,
          evClientID: evClientID,
          evClientName: evClientName,
          evClientBusinessRegNo: evClientBusinessRegNo,
          evClientBusinessRegType: evClientBusinessRegType,
          evClientSstNo: evClientSstNo,
          evClientTinNo: evClientTinNo,
          evClientAddr1: evClientAddr1,
          evClientAddr2: evClientAddr2,
          evClientAddr3: evClientAddr3,
          evClientPic: evClientPic,
          evClientEmail: evClientEmail,
          evClientPhone: evClientPhone,
        );
        // Refresh the client search results after successful edit
      }
      ref.read(clientSearchProvider.notifier).search(query: query);
      state = ClientEditStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ClientEditStateError(message: e.message);
      } else {
        state = ClientEditStateError(message: e.toString());
      }
    }
  }
}

abstract class ClientEditState extends Equatable {
  final DateTime date;

  const ClientEditState(this.date);
  @override
  List<Object?> get props => [date];
}

class ClientEditStateInit extends ClientEditState {
  ClientEditStateInit() : super(DateTime.now());
}

class ClientEditStateLoading extends ClientEditState {
  ClientEditStateLoading() : super(DateTime.now());
}

class ClientEditStateError extends ClientEditState {
  final String message;
  ClientEditStateError({
    required this.message,
  }) : super(DateTime.now());
}

class ClientEditStateDone extends ClientEditState {
  ClientEditStateDone() : super(DateTime.now());
}
