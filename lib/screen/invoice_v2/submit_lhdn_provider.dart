import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/lhdn_submit_resp_model.dart';
import 'package:sor_inventory/repository/invoice_repository.dart';
import 'package:sor_inventory/screen/invoice_v2/get_detail_provider.dart';
import 'package:sor_inventory/screen/invoice_v2/lhdn_validation.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final submitLhdnProvider =
    StateNotifierProvider<SubmitLHDNStateNotifier, SubmitLHDNState>(
  (ref) => SubmitLHDNStateNotifier(ref: ref),
);

class SubmitLHDNStateNotifier extends StateNotifier<SubmitLHDNState> {
  final Ref ref;
  SubmitLHDNStateNotifier({
    required this.ref,
  }) : super(SubmitLHDNStateInit());

  void reset() {
    state = SubmitLHDNStateInit();
  }

  void submit({
    required String invoiceID,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = SubmitLHDNStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = SubmitLHDNStateLoading();
    try {
      final resp = await InvoiceRepository(dio: dio).submitLhdn(
        invoiceID: invoiceID,
        token: loginModel!.token!,
      );
      // if (resp.acceptedDocuments.isNotEmpty) {
      //   ref
      //       .read(lhdnValidationProvider.notifier)
      //       .validate(invoiceID: invoiceID);
      // }

      state = SubmitLHDNStateDone(model: resp);

      // call after state mark as done
      // ref.read(getDetailProvider.notifier).get(invoiceID: invoiceID);
    } catch (e) {
      print(e);
      if (e is BaseRepositoryException) {
        state = SubmitLHDNStateError(message: e.message);
      } else {
        state = SubmitLHDNStateError(message: e.toString());
      }
    }
  }
}

abstract class SubmitLHDNState extends Equatable {
  final DateTime date;
  const SubmitLHDNState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SubmitLHDNStateInit extends SubmitLHDNState {
  SubmitLHDNStateInit() : super(date: DateTime.now());
}

class SubmitLHDNStateLoading extends SubmitLHDNState {
  SubmitLHDNStateLoading() : super(date: DateTime.now());
}

class SubmitLHDNStateToken extends SubmitLHDNState {
  SubmitLHDNStateToken() : super(date: DateTime.now());
}

class SubmitLHDNStateNoToken extends SubmitLHDNState {
  SubmitLHDNStateNoToken() : super(date: DateTime.now());
}

class SubmitLHDNStateError extends SubmitLHDNState {
  final String message;
  SubmitLHDNStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SubmitLHDNStateDone extends SubmitLHDNState {
  final LhdnSubmitResponseModel model;
  SubmitLHDNStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
