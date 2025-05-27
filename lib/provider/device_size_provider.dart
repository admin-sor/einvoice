import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final deviceSizeProvider = StateProvider<Size>((ref) => Size(0, 0));
