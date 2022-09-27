// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import '../constant/routes.dart';

class VerifyEmail extends StatelessWidget {
  const VerifyEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Column(
        children: [
          const Text(
              "We've sent you an email verification. Please open it to verify your account."),
          const Text(
              "If you haven't recieved the email verification,  please press the button below."),
          TextButton(
              onPressed: () async {
                final user = AuthService.firebase().currentUser;
                if (user != null) {
                  await AuthService.firebase().sendEmailverification();
                }
              },
              child: const Text('send email verification')),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoutes,
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
