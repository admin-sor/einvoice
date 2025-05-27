import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMrCpProvider = StateProvider<String>((ref) => "0");

final selectedEditIndex = StateProvider<int>((ref) => 0);
