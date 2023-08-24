import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitist/utils/storage_url.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<PickedFile> pickImage(ImageSource source,
    {CameraDevice cameraDevice = CameraDevice.front}) {
  final picker = ImagePicker();
  return picker.getImage(
    source: source,
    preferredCameraDevice: CameraDevice.front,
  );
}

Future<File> cropImage(PickedFile file, CroppingBaseStrategy croppingStrategy) {
  return ImageCropper.cropImage(
    sourcePath: file.path,
    compressQuality: croppingStrategy.compressQuality,
    aspectRatio: croppingStrategy.aspectRatio,
  );
}

abstract class CroppingBaseStrategy {
  final int compressQuality = null;
  final CropAspectRatio aspectRatio = null;
}

class AvatarCroppingStrategy implements CroppingBaseStrategy {
  final compressQuality = 50;
  final aspectRatio = CropAspectRatio(ratioX: 1, ratioY: 1);
}

class ChatPictureCroppingStrategy implements CroppingBaseStrategy {
  final compressQuality = 50;
  final aspectRatio = null;
}

Future<Reference> uploadImage(
    File image, ImageUploadStrategy uploadStrategy) async {
  final ref = uploadStrategy.ref;
  await ref.putFile(image);
  return ref;
}

abstract class ImageUploadStrategy {
  Reference get ref => throw UnimplementedError();
}

class AvatarUploadStrategy implements ImageUploadStrategy {
  @override
  Reference get ref {
    final uid = FirebaseAuth.instance.currentUser.uid;
    final path = uid2avatarStoragePath(uid);
    return FirebaseStorage.instance.ref(path);
  }
}

class CustomImageUploadStrategy implements ImageUploadStrategy {
  final String path;

  CustomImageUploadStrategy(this.path);

  @override
  Reference get ref {
    return FirebaseStorage.instance.ref(path);
  }
}

class ChatPictureUploadStrategy implements ImageUploadStrategy {
  @override
  Reference get ref {
    // return FirebaseStorage.instance.ref('');
    throw UnimplementedError();
  }
}
