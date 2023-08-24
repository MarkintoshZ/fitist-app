import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitist/providers/my_user_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

class FCM extends StatefulWidget {
  final Widget child;

  const FCM({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FCMState();
}

class _FCMState extends State<FCM> {
  MyUserProfileProvider _profileProvider;
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    setupFCM();
    _profileProvider = context.read<MyUserProfileProvider>();
    _profileProvider.addListener(setupFCM);
  }

  @override
  void dispose() {
    _profileProvider?.removeListener(setupFCM);
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> setupFCM() async {
    await firebaseMessaging.requestPermission();
    // init settings for firebase messaging
    if (_profileProvider.user == null) return;
    if (_profileProvider.user.FCM_token == null) {
      final token = await firebaseMessaging.getToken();
      await _profileProvider.update({'FCM_token': token});
    }
    firebaseMessaging.onTokenRefresh.listen((token) async {
      await _profileProvider.update({'FCM_token': token});
    });

    _subscription = FirebaseMessaging.onMessage.listen(_messageHandler);
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  void _messageHandler(RemoteMessage message) {
    print("onMessage: $message");
  }

  Future<dynamic> _backgroundMessageHandler(RemoteMessage message) async {
    print('onBackgroundMessage: $message');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
