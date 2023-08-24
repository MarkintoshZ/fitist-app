import 'dart:io';
import 'package:fitist/providers/my_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/controllers/image_upload_controllers.dart';
import 'package:fitist/views/widgets/user_avatar.dart';

class SetProfilePic extends StatefulWidget {
  final goToHome;

  const SetProfilePic({Key key, this.goToHome}) : super(key: key);

  @override
  _SetProfilePicState createState() => _SetProfilePicState();
}

class _SetProfilePicState extends State<SetProfilePic> {
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
      MyAvatarProvider.setBytes(_image.readAsBytesSync());
      // finish sign up workflow
      widget.goToHome();
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
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _showHeader(),
                if (_image == null)
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.width * 0.35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                else
                  Center(
                    child: UserAvatar(
                      uid: FirebaseAuth.instance.currentUser.uid,
                      srcImgSize: 512,
                      size: MediaQuery.of(context).size.width * 0.35,
                      loading: user == null,
                      file: _image,
                    ),
                  ),
                SizedBox(height: 25),
                MaterialButton(
                  onPressed: () => _getImage(ImageSource.camera),
                  child: ListTile(
                    leading: Icon(Icons.camera_alt_outlined),
                    title: Text('Take a photo'),
                  ),
                ),
                MaterialButton(
                  onPressed: () => _getImage(ImageSource.gallery),
                  child: ListTile(
                    leading: Icon(Icons.upload_file),
                    title: Text('Upload from photos'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    child: Text('Save and Continue'),
                    onPressed: _savable ? () => _saveChanges(context) : null,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ),
        ),
      ),
    );
  }

  Widget _showHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.03,
        bottom: MediaQuery.of(context).size.height * 0.04,
      ),
      child: Column(
        children: [
          Text(
            'Sign Up',
            style: Theme.of(context).textTheme.headline1,
          ),
          SizedBox(height: 2),
          Text(
            "Select your profile picture",
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
