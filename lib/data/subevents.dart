import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subevents.g.dart';

@JsonSerializable()
class SubEvent {
  SubEvent(
      {this.seId,
      this.name,
      this.venue,
      this.dateTime,
      this.ds,
      bool nullObj = true,
      bool loadFromSeId = false}) {
    if (loadFromSeId)
      Firestore.instance
          .collection('subevents')
          .document(this.seId)
          .get()
          .then((ds) {
        loadFromDs();
      });
    else {
      if (!nullObj) {
        if (ds == null)
          publishDoc();
        else
          loadFromDs();
      }
    }
  }

  Future<void> publishDoc() async {
    DocumentReference ref =
        await Firestore.instance.collection('subevents').add(this.toJson());
    seId = ref.documentID;
    ref.updateData({'seId': seId});
    ds = await ref.get();
    return;
  }

  void loadFromDs() {
    SubEvent se = _$SubEventFromJson(ds.data);
    this.seId = se.seId;
    this.name = se.name;
    this.ds = se.ds;
    this.organisers = se.organisers;
    this.dateTime = se.dateTime;
    this.venue = se.venue;
  }

  String seId;
  String name;
  String venue;
  DateTime dateTime;
  List<String> organisers = List();

  @JsonKey(ignore: true)
  DocumentSnapshot ds;

  factory SubEvent.fromJson(Map<String, dynamic> json) =>
      _$SubEventFromJson(json);

  Map<String, dynamic> toJson() => _$SubEventToJson(this);

  Future<void> delete() async {
    Firestore.instance.collection('subevents').document(seId).delete();
  }

  void addOrganizer(String uid) {
    organisers.add(uid);
    _serverUpdate();
  }

  void removeOrganizer(String uid) {
    organisers.remove(uid);
    _serverUpdate();
  }

  Future<void> _serverUpdate() async {
    if (seId != null && seId != "")
      await Firestore.instance
          .collection('subevents')
          .document(seId)
          .setData(toJson());
  }
}
