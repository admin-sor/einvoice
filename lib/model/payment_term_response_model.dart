import 'package:equatable/equatable.dart';

class PaymentTermResponseModel extends Equatable {
  late String paymentTermCode;
  late String paymentTermDays;
  late String paymentTermID;
  late String paymentTermIsActive;
  late String paymentTermName;
  late String isDefault;

  PaymentTermResponseModel({
    required this.paymentTermCode,
    required this.paymentTermDays,
    required this.paymentTermID,
    required this.paymentTermIsActive,
    required this.paymentTermName,
    this.isDefault = "N",
  });

  PaymentTermResponseModel.fromJson(Map<String, dynamic> json) {
    paymentTermCode = json['paymentTermCode'] ?? "";
    paymentTermDays = json['paymentTermDays'] ?? "";
    paymentTermID = json['paymentTermID'].toString();
    paymentTermIsActive = json['paymentTermIsActive'];
    paymentTermName = json['paymentTermName'] ?? "";
    isDefault = json['isDefault'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentTermCode'] = paymentTermCode;
    data['paymentTermDays'] = paymentTermDays;
    data['paymentTermID'] = paymentTermID;
    data['paymentTermIsActive'] = paymentTermIsActive;
    data['paymentTermName'] = paymentTermName;
    data['isDefault'] = isDefault;
    return data;
  }

  @override
  List<Object?> get props => [paymentTermID];
}
