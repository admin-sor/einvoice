import 'package:equatable/equatable.dart';

class StockTakeSummaryStatusModel extends Equatable {
  int? id;
  String? code;
  String? name;

  StockTakeSummaryStatusModel({this.id, this.code, this.name});

  StockTakeSummaryStatusModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    return data;
  }

  @override
  List<Object?> get props => [id, code];
}
