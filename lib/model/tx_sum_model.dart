class TxSumModel {
  final String slipNo;
  final String type;
  final String storeName;
  final String toStoreName;
  final String xDate;
  final String status;

  TxSumModel({
    required this.slipNo,
    required this.type,
    required this.storeName,
    required this.toStoreName,
    required this.xDate,
    required this.status,
  });

  // Factory method to create an instance from JSON
  factory TxSumModel.fromJson(Map<String, dynamic> json) {
    return TxSumModel(
      slipNo: json['slipNo'],
      type: json['type'],
      storeName: json['storeName'],
      toStoreName: json['toStoreName'],
      xDate: json['xDate'],
      status: json['status'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'slipNo': slipNo,
      'type': type,
      'storeName': storeName,
      'xDate': xDate,
      'status': status,
    };
  }
}
