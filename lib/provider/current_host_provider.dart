import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/sor_user_model.dart';

final currentConfigProvider = StateProvider<CurrentConfig?>(
    (ref) => CurrentConfig(host: "tkdev.sor.my", clientName: "Unknown Client"));

class CurrentConfig {
  final String host;
  final String clientName;
  final SorUser? user;

  CurrentConfig({
    required this.host,
    this.user,
    required this.clientName,
  });
  String baseUrl() {
    return "https://$host/sor_inv_api/";
  }

  String reportUrl() {
    return "https://$host/reports/";
  }
}
