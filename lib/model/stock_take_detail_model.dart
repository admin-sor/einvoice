class StockTakeDetailModel {
  String? drumNo;
  String? isCable;
  String? qty;
  String? serialNo;

  StockTakeDetailModel({this.drumNo, this.isCable, this.qty, this.serialNo});

  StockTakeDetailModel.fromJson(Map<String, dynamic> json) {
    drumNo = json['drumNo'];
    isCable = json['isCable'];
    qty = json['qty'];
    serialNo = json['serialNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['drumNo'] = drumNo;
    data['isCable'] = isCable;
    data['qty'] = qty;
    data['serialNo'] = serialNo;
    return data;
  }
}
