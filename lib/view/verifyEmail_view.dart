import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constant/routes.dart';

class VerifyEmail extends StatelessWidget {
  const VerifyEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email'),),
      body: Column(
          children: [
            const Text("We've sent you an email verification. Please open it to verify your account."),
            const Text("If you haven't recieved the email verification,  please press the button below."),
            TextButton(onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            }, 
            child: const Text('send email verification')
            ),
            TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(registerRoutes, 
                    (route) => false,
                    );
                  }, 
                  child: const Text('Restart'),
                  ),
          ],
        ),
    );
  }
}