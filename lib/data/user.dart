import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class User {
  User(
      {@required this.uid,
      this.email,
      this.name,
      this.profileImage,
      this.phone}) {
    _fetchUser(setInitialize: true);
  }

  String uid;
  String email;
  String name;
  String profileImage;
  int phone;
  bool initialized = false;

  void _fetchUser({bool setInitialize = false}) {
    Firestore.instance
        .collection('users')
        .where('id', isEqualTo: this.uid)
        .getDocuments()
        .then((result) {
      if (result.documents.length == 0) return;
      name = result.documents.elementAt(0)['name'];
      email = result.documents.elementAt(0)['email'];
      profileImage = result.documents.elementAt(0)['photoUrl'];
      phone = result.documents.elementAt(0)['phone'];
      _serverUpdate();
      initialized = true;
    });
  }

  void setPhone(int phone) {
    this.phone = phone;
    _serverUpdate();
  }

  Map<String, dynamic> toJson() => {
        "id": uid,
        'email': email,
        'name': name,
        'photoUrl': profileImage,
        'phone': phone
      };

  void _serverUpdate() {
    if (uid != null && uid != "")
      Firestore.instance.collection('users').document(uid).setData(toJson());
  }
}
