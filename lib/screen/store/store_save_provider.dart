import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/store_repository.dart';
import 'package:sor_inventory/screen/store/store_search_provider.dart';

import '../../provider/shared_preference_provider.dart';

final storeSaveProvider =
    StateNotifierProvider<StoreSaveNotifier, StoreSaveState>(
  (ref) => StoreSaveNotifier(ref: ref),
);

class StoreSaveNotifier extends StateNotifier<StoreSaveState> {
  final Ref ref;
  StoreSaveNotifier({required this.ref}) : super(StoreSaveStateInit());

  void save({
    required String storeID,
    required String storeName,
    required String storeAddress1,
    required String storeAddress2,
    required String storeAddress3,
    required String storePIC,
    required String storeEmail,
    required String storePhone,
    required String regionID,
    required String query,
  }) async {
    state = StoreSaveStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = StoreSaveStateError(message: "Invalid Token");
        return;
      }
      if (storeID == "0") {
        await StoreRepository(dio: ref.read(dioProvider)).add(
          storeName: storeName,
          storeAdd1: storeAddress1,
          storeAdd2: storeAddress2,
          storeAdd3: storeAddress3,
          storePicName: storePIC,
          storePicEmail: storeEmail,
          storePicPhone: storePhone,
          regionID: regionID,
          token: loginModel!.token!,
        );
      } else {
        await StoreRepository(dio: ref.read(dioProvider)).edit(
          storeID: storeID,
          storeName: storeName,
          storeAdd1: storeAddress1,
          storeAdd2: storeAddress2,
          storeAdd3: storeAddress3,
          storePicName: storePIC,
          storePicEmail: storeEmail,
          storePicPhone: storePhone,
          regionID: regionID,
          token: loginModel!.token!,
        );
      }
      state = StoreSaveStateDone(status: true);
      ref.read(storeSearchProvider.notifier).search(query: query);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StoreSaveStateError(message: e.message);
      } else {
        state = StoreSaveStateError(message: e.toString());
      }
    }
  }
}

abstract class StoreSaveState extends Equatable {
  final DateTime date;
  const StoreSaveState(this.date);

  @override
  List<Object?> get props => [date];
}

class StoreSaveStateInit extends StoreSaveState {
  StoreSaveStateInit() : super(DateTime.now());
}

class StoreSaveStateLoading extends StoreSaveState {
  StoreSaveStateLoading() : super(DateTime.now());
}

class StoreSaveStateError extends StoreSaveState {
  final String message;
  StoreSaveStateError({required this.message}) : super(DateTime.now());
}

class StoreSaveStateDone extends StoreSaveState {
  final bool status;
  StoreSaveStateDone({required this.status}) : super(DateTime.now());
}
