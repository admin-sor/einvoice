class StockTakeHistoryModel {
  String? stockTakeID;
  String? stockTakeCloseDate;
  String? stockTakeDate;
  String? stockTakeIsOpen;
  String? userName;
  String? diff;

  StockTakeHistoryModel(
      {this.stockTakeCloseDate,
      this.stockTakeID,
      this.stockTakeDate,
      this.stockTakeIsOpen,
      this.diff,
      this.userName});

  StockTakeHistoryModel.fromJson(Map<String, dynamic> json) {
    stockTakeCloseDate = json['stockTakeCloseDate'];
    stockTakeID = json['stockTakeID'].toString();
    stockTakeDate = json['stockTakeDate'];
    stockTakeIsOpen = json['stockTakeIsOpen'];
    userName = json['userName'];
    diff = json['diff'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stockTakeCloseDate'] = stockTakeCloseDate;
    data['stockTakeDate'] = stockTakeDate;
    data['stockTakeIsOpen'] = stockTakeIsOpen;
    data['userName'] = userName;
    data['diff'] = diff;
    data['stockTakeID'] = stockTakeID.toString();
    return data;
  }
}
