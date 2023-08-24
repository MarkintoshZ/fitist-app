import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/controllers/map_data.dart';
import 'package:fitist/providers/map_data.dart';
import 'package:fitist/services/user_profile_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class SessionButton extends StatefulWidget {
  final isMapPage;

  const SessionButton({Key key, this.isMapPage}) : super(key: key);
  static const defaultSessionDuration = Duration(hours: 1);

  @override
  _SessionButtonState createState() => _SessionButtonState();
}

class _SessionButtonState extends State<SessionButton> {
  Duration sessionDuration;
  StreamSubscription _streamSubscription;
  bool inSession = true;

  void setUpListeners() {
    if (_streamSubscription != null) return;
    final provider = Provider.of<MapDataProvider>(context, listen: false);
    _streamSubscription = provider.selfSessionStream.listen((event) {
      if (event != null && !event.isFinished) {
        setState(() {
          inSession = true;
        });
      } else {
        setState(() {
          inSession = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setUpListeners();

    final icon = (inSession) ? Icons.fitness_center : Icons.add;
    final btnColor = (inSession) ? Colors.red : Colors.blue;
    final onPress =  (inSession) ? () {} : onCreateSession;

    return FloatingActionButton(
      backgroundColor: btnColor,
      child: (widget.isMapPage) ? Icon(icon) : Container(),
      onPressed: onPress,
    );
  }

  void onCreateSession() async {
    final duration = await showModalBottomSheet(
      context: context,
      builder: startSessionBottomSheetBuilder,
    );
    if (duration != null) {
      final uid = FirebaseAuth.instance.currentUser.uid;
      final displayName = (await UserProfileService.get(uid)).displayName;
      final loc = await Geolocator.getLastKnownPosition();
      print('Creating session');
      await MapDataController.createSession(
          uid, displayName, duration, loc.latitude, loc.longitude);
    }
  }

  Widget startSessionBottomSheetBuilder(context) {
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
          child: Column(
            children: [
              Text(
                'Duration',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  minuteInterval: 10,
                  initialTimerDuration:
                  SessionButton.defaultSessionDuration,
                  onTimerDurationChanged: (duration) {
                    setState(() {
                      sessionDuration = duration;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(
                        context,
                        sessionDuration ??
                            SessionButton.defaultSessionDuration),
                child: Text('Start Session Now'),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ),
        ),
      ],
    );
  }
}
