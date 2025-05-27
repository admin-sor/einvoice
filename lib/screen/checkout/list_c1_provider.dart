import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/checkout_model_v2.dart';

import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/checkout_repository.dart';

final listC1StateProvider =
    StateNotifierProvider<ListC1StateNotifier, ListC1State>(
  (ref) => ListC1StateNotifier(ref: ref),
);

class ListC1StateNotifier extends StateNotifier<ListC1State> {
  final Ref ref;
  ListC1StateNotifier({
    required this.ref,
  }) : super(ListC1StateInit());

  void reset() {
    state = ListC1StateInit();
  }

  void listC1({
    required String fileNum,
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = ListC1StateLoading();
    try {
      final resp = await CheckoutRepository(dio: dio).listC1(
        fileNum: fileNum,
        slipNo: slipNo,
      );
      state = ListC1StateDone(
        model: resp,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ListC1StateError(message: e.message);
      } else {
        state = ListC1StateError(message: e.toString());
      }
    }
  }
}

abstract class ListC1State extends Equatable {
  final DateTime date;
  ListC1State({required this.date});
  @override
  List<Object?> get props => [date];
}

class ListC1StateInit extends ListC1State {
  ListC1StateInit() : super(date: DateTime.now());
}

class ListC1StateLoading extends ListC1State {
  ListC1StateLoading() : super(date: DateTime.now());
}

class ListC1StateToken extends ListC1State {
  ListC1StateToken() : super(date: DateTime.now());
}

class ListC1StateNoToken extends ListC1State {
  ListC1StateNoToken() : super(date: DateTime.now());
}

class ListC1StateError extends ListC1State {
  final String message;
  ListC1StateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ListC1StateDone extends ListC1State {
  final List<MaterialC1> model;
  ListC1StateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
