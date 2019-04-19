import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventful/data/app_data.dart';
import 'package:eventful/data/methods.dart';
import 'package:eventful/ui/subevents.dart';
import 'package:flutter/material.dart';

import '../data/event.dart';

class EventCard extends StatefulWidget {
  final Event e;
  final bool noRow;

  EventCard({@required this.e, this.noRow = false});

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: widget.noRow
          ? EdgeInsets.all(AppData().scaleFactorH * 16.0)
          : EdgeInsets.only(
              left: AppData().scaleFactorH * 16.0,
              right: AppData().scaleFactorH * 16.0,
              top: AppData().scaleFactorH * 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(widget.e.name,
              style: TextStyle(fontSize: AppData().scaleFactorH * 30.0)),
          widget.e.eid == null ? Container() : Text(widget.e.eid),
          widget.noRow
              ? Container()
              : ButtonBar(
                  children: <Widget>[
                    UserData().fireUser.uid == widget.e.ownerId
                        ? FlatButton(
                            onPressed: () => widget.e.delete(),
                            child: Text("Delete"),
                          )
                        : Container(),
                    FlatButton(
                      onPressed: () => widget.e.password == null ||
                              widget.e.password == ""
                          ? Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ManageEventPage(event: widget.e)))
                          : popupMenuBuilder(
                              context,
                              AlertDialog(
                                title: Text("Password"),
                                content: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      TextFormField(
                                          decoration: InputDecoration(
                                              labelText:
                                                  "Please enter the password"),
                                          obscureText: true,
                                          keyboardType: TextInputType.text,
                                          validator: (value) {
                                            if (value.isEmpty)
                                              return 'This field cannot be empty!';
                                            else if (value != widget.e.password)
                                              return 'Incorrect password!';
                                          }),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text("Cancel"),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ManageEventPage(
                                                        event: widget.e)));
                                      }
                                    },
                                    child: Text("Submit"),
                                  )
                                ],
                              ),
                              dismiss: true),
                      child: Text("Manage"),
                    ),
                  ],
                )
        ],
      ),
    ));
  }
}

class EventContents extends StatefulWidget {
  @override
  _EventContentsState createState() => _EventContentsState();
}

class _EventContentsState extends State<EventContents> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          else
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  int adjIndex = (snapshot.data.documents.length - 1) - index;
                  return EventCard(
                      e: Event(
                          ds: snapshot.data.documents[adjIndex],
                          nullObj: false));
                });
        });
  }
}

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  Event event = Event();
  bool tapEvent = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        tooltip: "Register",
        onPressed: tapEvent
            ? null
            : () {
                if (_formKey.currentState.validate()) {
                  event.ownerId = UserData().fireUser.uid;
                  setState(() => tapEvent = true);
                  event.publishDoc();
                  if (mounted) Navigator.of(context).pop();
                }
              },
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(Icons.add),
          ),
          Text("New Event")
        ]),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(AppData().scaleFactorA * 16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                  decoration: InputDecoration(labelText: "Event Name"),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value.isEmpty)
                      return 'Name cannot be empty!';
                    else
                      event.name = value;
                  }),
              TextFormField(
                  decoration: InputDecoration(labelText: "Password (optional)"),
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value.isEmpty)
                      event.password = null;
                    else
                      event.password = value;
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class ManageEventPage extends StatefulWidget {
  final Event event;

  ManageEventPage({@required this.event});

  @override
  _ManageEventPageState createState() => _ManageEventPageState();
}

class _ManageEventPageState extends State<ManageEventPage> {
  Event event;
  String password;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    event = widget.event;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddSubEventPage(event: event))),
        icon: Icon(Icons.event),
        label: Text("Add sub-event"),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: AppData().scaleFactorH * 10.0),
            child: Icon(Icons.class_),
          ),
          Text("Manage")
        ]),
      ),
      body: Column(
        children: <Widget>[
          EventCard(e: event, noRow: true),
          Card(
            child: Container(
              padding: EdgeInsets.all(AppData().scaleFactorA * 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Actions",
                    style: TextStyle(fontSize: AppData().scaleFactorH * 25.0),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: AppData().scaleFactorA * 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                            child: Text("Delete"),
                            color: Theme.of(context).accentColor,
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pop();
                              event.delete();
                            }),
                        event.password == null
                            ? Container()
                            : RaisedButton(
                                child: Text("Remove password"),
                                color: Theme.of(context).accentColor,
                                textColor: Colors.white,
                                onPressed: () => event
                                    .changePassword(null)
                                    .then((_) => setState(() {}))),
                        RaisedButton(
                            color: Theme.of(context).accentColor,
                            textColor: Colors.white,
                            child: event.password == null
                                ? Text("Add password")
                                : Text("Change password"),
                            onPressed: () {
                              popupMenuBuilder(
                                  context,
                                  AlertDialog(
                                    title: Text("Password"),
                                    content: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "Password"),
                                              obscureText: true,
                                              keyboardType: TextInputType.text,
                                              validator: (value) {
                                                if (value.isEmpty)
                                                  return 'This field cannot be empty!';
                                                else
                                                  password = value;
                                              }),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text("Cancel"),
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          if (_formKey.currentState
                                              .validate()) {
                                            event.changePassword(password);
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Text("Submit"),
                                      )
                                    ],
                                  ),
                                  dismiss: true);
                              event.delete();
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(AppData().scaleFactorA * 16.0),
                child: Text(
                  "Sub-events",
                  style: TextStyle(fontSize: AppData().scaleFactorH * 25.0),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppData().scaleFactorA * 8.0),
                child: SubEventsListCard(event: event),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
