import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitist/model/user_profile.dart';

final store = FirebaseFirestore.instance;
final userCollection = store.collection('Users');

void useEmulator() {
  FirebaseFirestore.instance.settings = Settings(
      host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
}

Future<void> createUser(String uid, String username, String displayName) async {
  final userProfile = UserProfileModel(username, displayName, [], null);
  await userCollection.doc(uid).set(userProfile.toJson());
}

Future<void> deleteUser(String uid) async {
  print("Deleting user!!! $uid");
  await userCollection.doc(uid).delete();
}

Future<Map<String, dynamic>> getUser(String uid) async {
  return (await userCollection.doc(uid).get()).data();
}

Future<DocumentReference> createFriendRequest({String uidFrom, String uidTo}) async {
  return userCollection
      .doc(uidFrom)
      .collection('FriendRequests')
      .add({
        'uidFrom': uidFrom,
        'uidTo': uidTo,
      });
}