import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/product_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/product_repository.dart';

final productSearchProvider =
    StateNotifierProvider<ProductNotifier, ProductSearchState>(
        (ref) => ProductNotifier(ref: ref));

class ProductNotifier extends StateNotifier<ProductSearchState> {
  final Ref ref;
  ProductNotifier({required this.ref}) : super(ProductSearchStateInit());

  void search({required String query}) async {
    state = ProductSearchStateLoading();
    try {
      // ProductRepository().search does not require a token based on product_repository.dart
      final resp = await ProductRepository(dio: ref.read(dioProvider))
          .search(query: query);
      state = ProductSearchStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ProductSearchStateError(message: e.message);
      } else {
        state = ProductSearchStateError(message: e.toString());
      }
    }
  }
}

abstract class ProductSearchState extends Equatable {
  final DateTime date;

  const ProductSearchState(this.date);
  @override
  List<Object?> get props => [date];
}

class ProductSearchStateInit extends ProductSearchState {
  ProductSearchStateInit() : super(DateTime.now());
}

class ProductSearchStateLoading extends ProductSearchState {
  ProductSearchStateLoading() : super(DateTime.now());
}

class ProductSearchStateError extends ProductSearchState {
  final String message;
  ProductSearchStateError({
    required this.message,
  }) : super(DateTime.now());
}

class ProductSearchStateDone extends ProductSearchState {
  final List<ProductModel> model;
  ProductSearchStateDone({
    required this.model,
  }) : super(DateTime.now());
}
