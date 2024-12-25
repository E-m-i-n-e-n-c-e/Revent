import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 50.0,
      child: SignInButton(Buttons.google,
          onPressed: onPressed != null ? onPressed! : () {}),
    );
  }
}
