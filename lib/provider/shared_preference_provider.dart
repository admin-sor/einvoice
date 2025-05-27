import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/sor_user_model.dart';

final sharedPrefenceProvider = FutureProvider<SharedPreferences>(
    (ref) async => await SharedPreferences.getInstance());

final localAuthProvider = FutureProvider.autoDispose<SorUser?>((ref) async {
  final sp = await ref.read(sharedPrefenceProvider.future);
  final String? strToken = sp.getString("token");
  if (strToken == null) return null;
  try {
    final xtoken = jsonDecode(strToken);
    final SorUser loginModel = SorUser.fromJson(xtoken);
    return loginModel;
  } catch (e, s) {
    return null;
  }
});
