import 'package:fitist/model/user_profile.dart';
import 'package:fitist/services/firestore.dart';

/// Cache UserProfile in Memory (not persistence on disk)
class UserProfileService {
  static var _cache = Map<String, UserProfileModel>();

  static Future<UserProfileModel> get(String uid) async {
    if (_cache.containsKey(uid)) {
      // cache hit
      return _cache[uid];
    }

    // userProfile not in local storage, retrieve data from server
    final userData = await getUser(uid);
    if (userData == null || userData.isEmpty) return null;

    // save user
    final userProfile = UserProfileModel.fromJson(userData);
    _cache[uid] = userProfile;

    return userProfile;
  }
}
