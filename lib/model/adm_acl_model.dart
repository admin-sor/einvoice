class InvSecLevelModel {
  late String invSecLevelID;
  late String invSecLevelName;
  late String invSecLevelIsActive;

  InvSecLevelModel({
    required this.invSecLevelID,
    required this.invSecLevelName,
    required this.invSecLevelIsActive,
  });

  InvSecLevelModel.fromJson(Map<String, dynamic> json) {
    invSecLevelID = json['invSecLevelID'];
    invSecLevelName = json['invSecLevelName'];
    invSecLevelIsActive = json['invSecLevelIsActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['invSecLevelID'] = invSecLevelID;
    data['invSecLevelName'] = invSecLevelName;
    data['invSecLevelIsActive'] = invSecLevelIsActive;
    return data;
  }
}

class InvAclScreen {
  late String screenGroupName;
  late String screenID;
  late String screenCode;
  late String screenTitle;
  late String isActive;

  InvAclScreen({
    required this.screenGroupName,
    required this.screenID,
    required this.screenCode,
    required this.screenTitle,
    required this.isActive,
  });

  InvAclScreen.fromJson(Map<String, dynamic> json) {
    screenGroupName = json['ScreenGroupName'];
    screenID = json['ScreenID'];
    screenCode = json['ScreenCode'];
    screenTitle = json['ScreenTitle'];
    isActive = json['IsActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScreenGroupName'] = screenGroupName;
    data['ScreenID'] = screenID;
    data['ScreenCode'] = screenCode;
    data['ScreenTitle'] = screenTitle;
    data['IsActive'] = isActive;
    return data;
  }
}
