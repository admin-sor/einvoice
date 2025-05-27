import 'package:flutter_riverpod/flutter_riverpod.dart';

final stockTakeStreamProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 2), (x) => x);
});
