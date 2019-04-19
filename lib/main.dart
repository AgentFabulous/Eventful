import 'package:flutter/material.dart';
import 'data/app_data.dart';
import 'dart:async';
import 'dart:math' as math;
import 'data/oauth.dart';
import 'ui/buttons.dart';
import 'ui/body.dart';

void main() => runApp(Eventful());

class Eventful extends StatefulWidget {
  @override
  _EventfulState createState() => _EventfulState();
}

class _EventfulState extends State<Eventful> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: null,
        body: SplashScreen(),
      ),
      routes: {
        '/login': (BuildContext context) => App(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    pushAndReplace('/login');
  }

  Future<void> pushAndReplace(String routeName) async {
    // Needed for hero animation
    final current = ModalRoute.of(context);
    Navigator.pushNamed(context, routeName);
    await Future.delayed(Duration(milliseconds: 1000));
    Navigator.removeRoute(context, current);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;

    // Make our life a bit easier.
    AppData().scaleFactorH = MediaQuery.of(context).size.height / 900;
    AppData().scaleFactorW = MediaQuery.of(context).size.width / 450;
    AppData().scaleFactorA = (MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) /
        (900 * 450);

    return Scaffold(
      appBar: null,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
              child: Hero(
            tag: "logo",
            child: Container(
              height: h / 3.75,
              child: Icon(Icons.event_available, size: h / 3.75),
            ),
          )),
        ],
      ),
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool autoSigningIn = true;

  @override
  void initState() {
    signIn(signInAction, true).then((b) => setState(() => autoSigningIn = b));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: null,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            bottom: 0,
            child: Opacity(
              opacity: 0.05,
              child: Align(
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: -math.pi / 4.8,
                  alignment: Alignment.center,
                  child: ClipPath(
                    child: Container(
                        padding: EdgeInsets.only(left: h / 7.5),
                        child: Icon(Icons.event_available, size: h / 2.0)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: h / 3.75,
            left: 0.0,
            right: 0.0,
            child: Hero(
                tag: "logo", child: Icon(Icons.event_available, size: h / 4.5)),
          ),
          Positioned(
            top: h / 1.85,
            left: 0.0,
            right: 0.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: autoSigningIn
                  ? Center(child: CircularProgressIndicator())
                  : GoogleSignInButton(
                      onPressed: signInAction,
                    ),
            ),
          )
        ],
      ),
    );
  }

  void signInAction() {
    Future.delayed(
        Duration(seconds: 5),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            settings: RouteSettings(name: '/home'),
            builder: (context) => AppBody())));
  }
}
