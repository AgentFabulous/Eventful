import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  Event(
      {this.eid,
      this.name,
      this.password,
      this.ds,
      this.ownerId,
      bool nullObj = true}) {
    if (!nullObj) {
      if (ds == null)
        publishDoc();
      else
        loadFromDs();
    }
  }

  Future<void> publishDoc() async {
    DocumentReference ref =
        await Firestore.instance.collection('events').add(this.toJson());
    eid = ref.documentID;
    ref.updateData({'eid': eid});
    ds = await ref.get();
    return;
  }

  void loadFromDs() {
    Event e = _$EventFromJson(ds.data);
    this.ownerId = e.ownerId;
    this.eid = e.eid;
    this.name = e.name;
    this.password = e.password;
    this.ds = e.ds;
    this.subEvents = e.subEvents;
  }

  String eid;
  String name;
  String password;
  String ownerId;
  List<String> subEvents = List();

  @JsonKey(ignore: true)
  DocumentSnapshot ds;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);

  Future<void> changePassword(String password) async {
    this.password = password;
    await _serverUpdate();
  }

  Future<void> delete() async {
    await Firestore.instance.collection('events').document(eid).delete();
  }

  Future<void> addSubEvent(String seId) async {
    subEvents.add(seId);
    await _serverUpdate();
  }

  Future<void> _serverUpdate() async {
    if (eid != null && eid != "")
      await Firestore.instance
          .collection('events')
          .document(eid)
          .setData(toJson());
  }
}
