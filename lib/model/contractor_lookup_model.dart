class ContractorLookupModel {
  late String cpId;
  late String name;
  late String shortName;
  late String dbName;
  late String staffId;
  late String staffName;
  late String scheme;

  ContractorLookupModel({
    required this.cpId,
    required this.name,
    required this.shortName,
    required this.staffId,
    required this.staffName,
    required this.scheme,
    this.dbName = "",
  });

  ContractorLookupModel.fromJson(Map<String, dynamic> json) {
    try {
    cpId = json['cp_id'];
    name = json['name'];
    shortName = json['short_name'];
    dbName = json['dbName'];
    staffName = json['staffName'] ?? "";
    staffId = json['staffId'] ?? "0";
    scheme = json['scheme'] ?? "";
    } catch(e){
      print(e);
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cp_id'] = cpId;
    data['name'] = name;
    data['short_name'] = shortName;
    data['dbName'] = dbName;
    data['staffId'] = staffId;
    data['staffName'] = staffName;
    return data;
  }
}
