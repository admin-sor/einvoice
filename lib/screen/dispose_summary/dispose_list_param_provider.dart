import 'package:hooks_riverpod/hooks_riverpod.dart';

class DisposeSearchParamModel {
  final String storeID;
  final String search;

  DisposeSearchParamModel(this.storeID, this.search);
}

final disposeListParamSearchProvider = StateProvider<DisposeSearchParamModel>(
    (ref) => DisposeSearchParamModel("0", ""));
