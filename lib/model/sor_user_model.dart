import 'package:sor_inventory/model/dynamic_screen_model.dart';

class SorUser {
  late String commentName;
  late String email;
  late String flagActive;
  late String flagInv;
  late String gender;
  late String level;
  late String levelId;
  late String login;
  late String name;
  late String userId;
  late String username;
  late String storeID;
  late String viewAllProject;
  String? token;
  String? host;
  String? clientName;
  List<DynamicScreenModel>? screen;

  SorUser({
    required this.commentName,
    required this.email,
    required this.flagActive,
    required this.flagInv,
    required this.gender,
    required this.level,
    required this.levelId,
    required this.login,
    required this.name,
    required this.userId,
    required this.username,
    required this.storeID,
    required this.viewAllProject,
  });

  SorUser.fromJson(Map<String, dynamic> jsonx) {
    var json = jsonx;
    if (jsonx["user"] != null) {
      json = jsonx["user"] as Map<String, dynamic>;
    }

    commentName = json['comment_name'] ?? "";
    email = json['email'] ?? "";
    flagActive = json['flag_active'] ?? "";
    flagInv = json['flag_inv'] ?? "";
    gender = json['gender'] ?? "";
    level = json['level'] ?? "";
    levelId = json['level_id'] ?? "";
    login = json['login'] ?? "";
    name = json['name'] ?? "";
    userId = json['user_id'] ?? "";
    storeID = json['storeID'] ?? "";
    token = json['token'] ?? "";
    username = json['username'] ?? "";
    viewAllProject = json['view_all_project'] ?? "";
    host = json["host"] ?? "tkdev";
    clientName = json["client"] ?? "Unknown ClientName";
    screen = List.empty(growable: true);
    if (jsonx["screen"] != null) {
      jsonx["screen"].forEach((e) {
        var scr = DynamicScreenModel.fromJson(e);
        screen!.add(scr);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['comment_name'] = commentName;
    data['email'] = email;
    data['flag_active'] = flagActive;
    data['flag_inv'] = flagInv;
    data['gender'] = gender;
    data['level'] = level;
    data['level_id'] = levelId;
    data['login'] = login;
    data['name'] = name;
    data['user_id'] = userId;
    data['username'] = username;
    data['storeID'] = storeID;
    data['token'] = token;
    data['host'] = host;
    data['client'] = clientName;
    data['view_all_project'] = viewAllProject;
    data['screen'] = screen;
    return data;
  }
}
