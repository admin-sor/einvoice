class StockTakeModel {
  String? stockTakeBranchID;
  String? stockTakeCloseDate;
  String? stockTakeClosedUserID;
  String? stockTakeCreatedUserID;
  String? stockTakeDate;
  String? stockTakeID;
  String? stockTakeIsOpen;
  String? userName;
  String? stockTakeStoreID;

  StockTakeModel({
    this.stockTakeBranchID,
    this.stockTakeCloseDate,
    this.stockTakeClosedUserID,
    this.stockTakeCreatedUserID,
    this.stockTakeDate,
    this.stockTakeID,
    this.stockTakeIsOpen,
    this.userName,
  });

  StockTakeModel.fromJson(Map<String, dynamic> json) {
    stockTakeBranchID = json['stockTakeBranchID'];
    stockTakeCloseDate = json['stockTakeCloseDate'];
    stockTakeClosedUserID = json['stockTakeClosedUserID'];
    stockTakeCreatedUserID = json['stockTakeCreatedUserID'];
    stockTakeDate = json['stockTakeDate'];
    stockTakeID = json['stockTakeID'];
    stockTakeStoreID = json['stockTakeStoreID'] ?? "0";
    stockTakeIsOpen = json['stockTakeIsOpen'];
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stockTakeBranchID'] = stockTakeBranchID;
    data['stockTakeCloseDate'] = stockTakeCloseDate;
    data['stockTakeClosedUserID'] = stockTakeClosedUserID;
    data['stockTakeCreatedUserID'] = stockTakeCreatedUserID;
    data['stockTakeDate'] = stockTakeDate;
    data['stockTakeID'] = stockTakeID;
    data['stockTakeStoreID'] = stockTakeStoreID;
    data['stockTakeIsOpen'] = stockTakeIsOpen;
    data['userName'] = userName;
    return data;
  }
}
