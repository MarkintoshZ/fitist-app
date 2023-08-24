import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/utils/storage_url.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _KEY = 'my-avatar';

/// Provide [imageProvider] for avatar of the current user
class MyAvatarProvider extends ChangeNotifier {
  /// Is loaded as a [MemoryImage] if image is stored in the local cache, and
  /// loaded as a [NetworkImage] using the current user uid when not in cache
  ImageProvider imageProvider;

  MyAvatarProvider() {
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final bytes = await _loadBytes();
    // ignore the cache when bytes are 4 bytes long
    if (bytes == null || bytes.length <= 4) {
      // no local cache, use network image instead
      final uid = FirebaseAuth.instance.currentUser.uid;
      imageProvider = NetworkImage(uid2avatarUri(uid));
    } else {
      imageProvider = MemoryImage(bytes);
    }
    notifyListeners();
  }

  /// Set the bytes for the new avatar and trigger my avatar widgets to rerender
  void setAndReload(Uint8List bytes) {
    setBytes(bytes);
    imageProvider = MemoryImage(bytes);
    notifyListeners();
  }

  Future<Uint8List> _loadBytes() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey(_KEY)) return null;
    String strData = pref.getString(_KEY);
    return Uint8List.fromList(strData.codeUnits);
  }

  /// Set the bytes for the new avatar
  static Future setBytes(Uint8List bytes) async {
    final pref = await SharedPreferences.getInstance();
    String strData = String.fromCharCodes(bytes);
    await pref.setString(_KEY, strData);
  }
}
