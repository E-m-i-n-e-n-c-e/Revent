import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    // Sign in and force the user to select an account
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      // User canceled the sign-in, return null
      return null;
    }
    if (!googleUser.email.endsWith("iiitkottayam.ac.in") &&
        !googleUser.email.endsWith("gmail.com")) {
      // User is not from the IIIT Kottayam domain, return null
      await GoogleSignIn().signOut();
      return googleUser;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credentials
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Return the signed-in user
    return googleUser;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}
