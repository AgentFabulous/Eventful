import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_data.dart';
import 'cloud_firestore.dart';

final GoogleSignIn _googleSignIn = new GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<bool> signIn(Function action, bool silent) async {
  GoogleSignInAccount gSI = silent
      ? await _googleSignIn.signInSilently(suppressErrors: true)
      : await _googleSignIn.signIn();

  GoogleSignInAuthentication gSA;
  try {
    gSA = await gSI.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );
    _auth.signInWithCredential(credential).then((user) {
      action();
      UserData().fireUser = user;
      updateUserDB();
    });
  } catch (e) {
    return false;
  }
  return true;
}
