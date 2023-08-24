import 'package:cloud_firestore/cloud_firestore.dart';

class RefDataPair<T> {
  final DocumentReference ref;
  final T data;

  RefDataPair(this.ref, this.data);
}
