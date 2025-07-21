import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/invoice_repository.dart';

import '../../model/invoice_v2_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';

final searchInvoiceV2Provider =
    StateNotifierProvider<SearchInvoiceV2StateNotifier, SearchInvoiceV2State>(
  (ref) => SearchInvoiceV2StateNotifier(ref: ref),
);

class SearchInvoiceV2StateNotifier extends StateNotifier<SearchInvoiceV2State> {
  final Ref ref;
  SearchInvoiceV2StateNotifier({
    required this.ref,
  }) : super(SearchInvoiceV2StateInit());

  void reset() {
    state = SearchInvoiceV2StateInit();
  }

  void search({
    required String startDate,
    required String endDate,
    required String client,
    required String status,
  }) async {
    final dio = ref.read(dioProvider);
    state = SearchInvoiceV2StateLoading();
    try {
      final resp = await InvoiceRepository(dio: dio).searchV2(
        startDate: startDate,
        endDate: endDate,
        client: client,
        status: status,
      );
      state = SearchInvoiceV2StateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SearchInvoiceV2StateError(message: e.message);
      } else {
        state = SearchInvoiceV2StateError(message: e.toString());
      }
    }
  }
}

abstract class SearchInvoiceV2State extends Equatable {
  final DateTime date;
  const SearchInvoiceV2State({required this.date});
  @override
  List<Object?> get props => [date];
}

class SearchInvoiceV2StateInit extends SearchInvoiceV2State {
  SearchInvoiceV2StateInit() : super(date: DateTime.now());
}

class SearchInvoiceV2StateLoading extends SearchInvoiceV2State {
  SearchInvoiceV2StateLoading() : super(date: DateTime.now());
}

class SearchInvoiceV2StateToken extends SearchInvoiceV2State {
  SearchInvoiceV2StateToken() : super(date: DateTime.now());
}

class SearchInvoiceV2StateNoToken extends SearchInvoiceV2State {
  SearchInvoiceV2StateNoToken() : super(date: DateTime.now());
}

class SearchInvoiceV2StateError extends SearchInvoiceV2State {
  final String message;
  SearchInvoiceV2StateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SearchInvoiceV2StateDone extends SearchInvoiceV2State {
  final List<InvoiceV2Model> model;
  SearchInvoiceV2StateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
