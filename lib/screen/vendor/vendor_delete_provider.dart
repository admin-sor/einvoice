import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/vendor_repository.dart';
import 'vendor_search_provider.dart';

final vendorDeleteProvider =
    StateNotifierProvider<VendorDeleteNotifier, VendorDeleteState>(
  (ref) => VendorDeleteNotifier(ref: ref),
);

class VendorDeleteNotifier extends StateNotifier<VendorDeleteState> {
  final Ref ref;
  VendorDeleteNotifier({required this.ref}) : super(VendorDeleteStateInit());

  void delete({
    required String vendorID,
    required String query,
  }) async {
    state = VendorDeleteStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = VendorDeleteStateError(message: "Invalid Token");
        return;
      }
      final resp = await VendorRepository(dio: ref.read(dioProvider)).delete(
        vendorID: vendorID,
        token: loginModel!.token!,
      );
      state = VendorDeleteStateDone();
      ref.read(vendorSearchProvider.notifier).search(query: query);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = VendorDeleteStateError(message: e.message);
      } else {
        state = VendorDeleteStateError(message: e.toString());
      }
    }
  }
}

abstract class VendorDeleteState extends Equatable {
  final DateTime date;
  const VendorDeleteState(this.date);

  @override
  List<Object?> get props => [date];
}

class VendorDeleteStateInit extends VendorDeleteState {
  VendorDeleteStateInit() : super(DateTime.now());
}

class VendorDeleteStateLoading extends VendorDeleteState {
  VendorDeleteStateLoading() : super(DateTime.now());
}

class VendorDeleteStateError extends VendorDeleteState {
  final String message;
  VendorDeleteStateError({required this.message}) : super(DateTime.now());
}

class VendorDeleteStateDone extends VendorDeleteState {
  VendorDeleteStateDone() : super(DateTime.now());
}
