import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventful/data/app_data.dart';
import 'package:eventful/ui/user.dart';
import 'package:flutter/material.dart';
import 'package:eventful/data/subevents.dart';
import 'package:eventful/data/event.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class SubEventsListCard extends StatefulWidget {
  final Event event;

  SubEventsListCard({@required this.event});

  @override
  _SubEventsListCardState createState() => _SubEventsListCardState();
}

class _SubEventsListCardState extends State<SubEventsListCard> {
  Event event;

  @override
  void initState() {
    event = widget.event;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BuildContext ctx = context;
    return Theme(
      data: ThemeData.dark(),
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: event.subEvents.length,
            itemBuilder: (context, i) {
              //SubEvent(seId: event.subEvents[i], loadFromSeId: true);
              return FutureBuilder(
                  future: Firestore.instance
                      .collection('subevents')
                      .document(event.subEvents[i])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null)
                      return Container();
                    else {
                      SubEvent subEvent =
                          SubEvent(ds: snapshot.data, nullObj: false);
                      return Card(
                        color: Theme.of(ctx).accentColor,
                        child: Padding(
                          padding:
                              EdgeInsets.all(AppData().scaleFactorH * 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    subEvent.name,
                                    style: TextStyle(
                                        fontSize: AppData().scaleFactorH * 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("Venue: " + subEvent.venue),
                                  Text(subEvent.dateTime.toIso8601String())
                                ],
                              ),
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditSubEventPage(
                                                  subEvent: subEvent)))),
                            ],
                          ),
                        ),
                      );
                    }
                  });
            }),
      ),
    );
  }
}

class EditSubEventPage extends StatefulWidget {
  final SubEvent subEvent;

  EditSubEventPage({@required this.subEvent});

  @override
  _EditSubEventPageState createState() => _EditSubEventPageState();
}

class _EditSubEventPageState extends State<EditSubEventPage> {
  SubEvent subEvent;

  @override
  void initState() {
    subEvent = widget.subEvent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BuildContext ctx = context;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(ctx).push(MaterialPageRoute(
              builder: (ctx) => AddOrganizersPage(subEvent: subEvent))),
          icon: Icon(Icons.person),
          label: Text("Add organizer")),
      appBar: AppBar(
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 10.0 * AppData().scaleFactorH),
            child: Icon(Icons.edit),
          ),
          Text("Edit Sub-event")
        ]),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppData().scaleFactorH * 8.0),
        child: Column(
          children: <Widget>[
            Theme(
              data: ThemeData.dark(),
              child: Card(
                color: Theme.of(ctx).accentColor,
                child: Padding(
                  padding: EdgeInsets.all(AppData().scaleFactorH * 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            subEvent.name,
                            style: TextStyle(
                                fontSize: AppData().scaleFactorH * 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text("Venue: " + subEvent.venue),
                          Text(subEvent.dateTime.toIso8601String())
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            UsersCard(subEvent: subEvent, isEdit: true)
          ],
        ),
      ),
    );
  }
}

class AddSubEventPage extends StatefulWidget {
  final Event event;

  AddSubEventPage({this.event});

  @override
  _AddSubEventPageState createState() => _AddSubEventPageState();
}

class _AddSubEventPageState extends State<AddSubEventPage> {
  final _formKey = GlobalKey<FormState>();
  SubEvent subEvent = SubEvent();
  bool tapSubEvent = false;
  Event event;

  @override
  void initState() {
    event = widget.event;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        tooltip: "Register",
        onPressed: tapSubEvent
            ? null
            : () {
                if (_formKey.currentState.validate()) {
                  setState(() => tapSubEvent = true);
                  subEvent
                      .publishDoc()
                      .then((_) => event.addSubEvent(subEvent.seId));
                  if (mounted) Navigator.of(context).pop();
                }
              },
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 10.0 * AppData().scaleFactorH),
            child: Icon(Icons.add),
          ),
          Text("New Sub-event")
        ]),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(AppData().scaleFactorA * 16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                  decoration: InputDecoration(labelText: "Sub-event Name"),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value.isEmpty)
                      return 'Name cannot be empty!';
                    else
                      subEvent.name = value;
                  }),
              TextFormField(
                  decoration: InputDecoration(labelText: "Venue"),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value.isEmpty)
                      return 'Venue cannot be empty!';
                    else
                      subEvent.venue = value;
                  }),
              DateTimePickerFormField(
                inputType: InputType.both,
                format: DateFormat("MMMM d, yyyy 'at' h:mma"),
                editable: false,
                decoration: InputDecoration(labelText: "Date and time"),
                onChanged: (dt) => setState(() => subEvent.dateTime = dt),
                validator: (value) {
                  if (value == null)
                    return "Please provide date and time!";
                  else
                    subEvent.dateTime = DateTime.parse(value.toIso8601String());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
