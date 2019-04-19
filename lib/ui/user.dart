import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventful/data/app_data.dart';
import 'package:eventful/data/subevents.dart';

import '../data/user.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UsersCard extends StatefulWidget {
  final bool isEdit;
  final SubEvent subEvent;
  UsersCard({@required this.subEvent, this.isEdit = false});
  @override
  _UsersCardState createState() => _UsersCardState();
}

class _UsersCardState extends State<UsersCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppData().scaleFactorH * 16.0),
        child: UserList(subEvent: widget.subEvent, isEdit: widget.isEdit),
      ),
    );
  }
}

class UserList extends StatefulWidget {
  final bool isEdit;
  final SubEvent subEvent;
  UserList({@required this.subEvent, this.isEdit = false});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          else
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  int adjIndex = (snapshot.data.documents.length - 1) - index;
                  bool condition = widget.isEdit
                      ? !widget.subEvent.organisers
                          .contains(snapshot.data.documents[adjIndex]['id'])
                      : widget.subEvent.organisers
                          .contains(snapshot.data.documents[adjIndex]['id']);
                  if (condition)
                    return Container();
                  else
                    return UserInfo(
                      isEdit: widget.isEdit,
                      id: snapshot.data.documents[adjIndex]['id'],
                      subEvent: widget.subEvent,
                      cb: () => setState(() {}),
                    );
                  /*return PostWidget(
                      p: Post(ds: snapshot.data.documents[adjIndex]));*/
                });
        });
  }
}

class UserInfo extends StatefulWidget {
  final String id;
  final SubEvent subEvent;
  final VoidCallback cb;
  final bool isEdit;
  UserInfo(
      {@required this.id,
      @required this.subEvent,
      @required this.cb,
      @required this.isEdit});

  @override
  UserInfoState createState() {
    return new UserInfoState();
  }
}

class UserInfoState extends State<UserInfo> {
  String imageUrl;
  String userName = "";
  String email = "";
  int phone;
  BuildContext mContext;

  Future<void> _getData() async {
    var name = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.id)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['name']);
    var mail = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.id)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['email']);
    var url = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.id)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['photoUrl']);
    var phoneNo = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.id)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['phone']);
    try {
      if (this.mounted)
        setState(() {
          userName = name;
          email = mail;
          imageUrl = url;
          phone = phoneNo;
        });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    _getData();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            imageUrl == null
                ? CircularProgressIndicator()
                : CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(imageUrl)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: <Widget>[
                  Text(
                    userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        IconButton(
            icon: widget.isEdit ? Icon(Icons.close) : Icon(Icons.add),
            onPressed: () {
              widget.isEdit
                  ? widget.subEvent.removeOrganizer(widget.id)
                  : widget.subEvent.addOrganizer(widget.id);
              widget.cb();
            })
      ],
    );
  }
}

class AddOrganizersPage extends StatefulWidget {
  final SubEvent subEvent;
  AddOrganizersPage({@required this.subEvent});

  @override
  _AddOrganizersPageState createState() => _AddOrganizersPageState();
}

class _AddOrganizersPageState extends State<AddOrganizersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 10.0 * AppData().scaleFactorH),
            child: Icon(Icons.person),
          ),
          Text("Add organizers")
        ]),
      ),
      body: UsersCard(subEvent: widget.subEvent),
    );
  }
}
