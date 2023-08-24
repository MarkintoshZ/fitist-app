String storage2uri(String path) {
  path = _trimLeading('/', path);
  path = path.replaceAll('/', '%2F');
  return 'https://firebasestorage.googleapis.com/v0/b/project-fitness-app.appspot.com/o/$path';
}

String _trimLeading(String pattern, String from) {
  int i = 0;
  while (from.startsWith(pattern, i)) i += pattern.length;
  return from.substring(i);
}

String uid2avatarStoragePath(String uid, {int size}) {
  if (size == null) return 'avatars/$uid/avatar';
  return 'avatars/$uid/thumbs/avatar_${size}x$size';
}

String uid2avatarUri(String uid, {int size}) {
  final path = uid2avatarStoragePath(uid, size: size);
  return storage2uri(path + '?alt=media');
}
