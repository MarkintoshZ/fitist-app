import 'package:cloud_firestore/cloud_firestore.dart';

final store = FirebaseFirestore.instance;

class UserProfileModel {
  final String username;
  final String displayName;
  final List<String> friends;

  // ignore: non_constant_identifier_names
  final String FCM_token;

  const UserProfileModel(
      this.username, this.displayName, this.friends, this.FCM_token);

  UserProfileModel.fromJson(Map<String, dynamic> data)
      : username = data['username'],
        displayName = data['displayName'],
        friends = data['friends'].whereType<String>().toList(),
        FCM_token = data['FCM_token'];

  Map<String, dynamic> toJson() => {
        'username': username,
        'displayName': displayName,
        'friends': friends,
        'FCM_token': FCM_token,
      };

  static get initData {
    return const UserProfileModel("", "", [], null);
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
