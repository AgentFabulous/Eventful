import 'package:eventful/data/app_data.dart';
import 'package:eventful/data/methods.dart';
import 'package:eventful/ui/event.dart';
import 'package:flutter/material.dart';

class AppBody extends StatefulWidget {
  @override
  _AppBodyState createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  final _formKey = GlobalKey<FormState>();
  int phoneNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (UserData().user.phone == null && UserData().user.initialized)
        popupMenuBuilder(
            context,
            AlertDialog(
              title: Text("Phone number"),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                        "This app requires you to provide your phone number. Please enter it in the field below"),
                    TextFormField(
                        decoration: InputDecoration(labelText: "Phone number"),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value.isEmpty)
                            return 'This field cannot be empty!';
                          else
                            phoneNumber = int.parse(value);
                        }),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      UserData().user.setPhone(phoneNumber);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Submit"),
                )
              ],
            ),
            dismiss: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text("Eventful"), centerTitle: true),
      appBar: null,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Builder(
              builder: (context) => IconButton(
                  icon: Icon(Icons.keyboard_arrow_up),
                  onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => Padding(
                            padding:
                                EdgeInsets.all(AppData().scaleFactorA * 30.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                    "App for managing events and fests.\nMade by Kshitij Gupta, Diya Raghava and Divyanshi Gupta.")
                              ],
                            ),
                          ))),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddEventPage()));
        },
        icon: Icon(Icons.add),
        label: Text("New Event"),
        tooltip: "New event",
      ),
      body: EventContents(),
    );
  }
}
