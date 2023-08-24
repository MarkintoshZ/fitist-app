import 'dart:io';

import 'package:fitist/providers/my_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitist/controllers/image_upload_controllers.dart';
import 'package:fitist/providers/my_user_profile.dart';
import 'package:fitist/views/widgets/user_avatar.dart';

class SetProfilePicturePage extends StatefulWidget {
  const SetProfilePicturePage({Key key}) : super(key: key);

  @override
  _SetProfilePicturePageState createState() => _SetProfilePicturePageState();
}

class _SetProfilePicturePageState extends State<SetProfilePicturePage> {
  File _image;
  bool _savable = false;

  Future _getImage(ImageSource source) async {
    final pickedFile = await pickImage(source);

    if (pickedFile == null) {
      _showSnackBar('No image selected', duration: 2);
      return;
    }

    _image = await cropImage(pickedFile, AvatarCroppingStrategy());
    setState(() {
      _savable = true;
    });
  }

  Future _saveChanges(BuildContext context) async {
    _showSnackBar('Uploading new profile picture');
    setState(() {
      _savable = false;
    });
    try {
      // upload img to firebase storage
      await uploadImage(_image, AvatarUploadStrategy());
      // save self avatar in cache
      context.read<MyAvatarProvider>().setAndReload(_image.readAsBytesSync());
      Navigator.pop(context);
    } catch (e) {
      print(e);
      _showSnackBar('Failed to upload profile picture. Try again later');
      setState(() {
        _savable = true;
      });
    }
  }

  void _showSnackBar(String text, {int duration = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: duration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MyUserProfileProvider>(
        builder: (context, value, child) {
          final user = value.user;
          var textStyle = Theme.of(context)
              .textTheme
              .headline3
              .copyWith(fontWeight: FontWeight.normal);
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'profile_picture',
                    child: UserAvatar(
                      uid: FirebaseAuth.instance.currentUser.uid,
                      srcImgSize: 512,
                      // profileUri: user?.profilePicUri,
                      size: MediaQuery.of(context).size.width * 0.5,
                      loading: user == null,
                      file: _image,
                    ),
                  ),
                  SizedBox(height: 25),
                  MaterialButton(
                    onPressed: () => _getImage(ImageSource.camera),
                    child: ListTile(
                      leading: Icon(Icons.camera_alt_outlined),
                      title: Text(
                        'Take a photo',
                        style: textStyle,
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () => _getImage(ImageSource.gallery),
                    child: ListTile(
                      leading: Icon(Icons.upload_file),
                      title: Text(
                        'Upload from photos',
                        style: textStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  child: Text('Save'),
                  onPressed: _savable ? () => _saveChanges(context) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
