// ignore_for_file: avoid_print

// ignore: unused_import
import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:notesapp/constant/routes.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import 'package:notesapp/view/login_view.dart';
import 'package:notesapp/view/notes/new_notes_view.dart';
import 'package:notesapp/view/notes/notes_view.dart';
import 'package:notesapp/view/register_view.dart';
import 'package:notesapp/view/verifyEmail_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes: {
      loginRoutes: (context) => const LoginView(),
      registerRoutes: (context) => const RegisterView(),
      notesRoutes: (context) => const NotesView(),
      verifyEmailRoutes: (context) => const VerifyEmail(),
      newNoteRoute: (context) => const NewNote(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmail();
              }
            } else {
              return const LoginView();
            }
          // return const LoginView();

          default:
            return const Text('Loading...');
        }
      },
    );
  }
}
