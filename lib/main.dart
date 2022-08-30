// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/view/login_view.dart';
import 'package:notesapp/view/register_view.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/login/':(context) => const LoginView(),
        '/register/':(context) => const RegisterView(),
      },
    ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
        builder: (context, snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.done:
              // final user = FirebaseAuth.instance.currentUser;
              // if(user ?. emailVerified ?? false){
              //   return const Text('Done');
              // }else{
              //   return const VerifyEmail();
              // }
             return const LoginView();
              
            default:
              return const Text("Loading...");
          }
          
        },
      );
  }
}

class VerifyEmail extends StatelessWidget {
  const VerifyEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email'),),
      body: Column(
          children: [
            const Text('Please verify your email:'),
            TextButton(onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            }, 
            child: const Text('send email verification')
            )
          ],
        ),
    );
  }
}


