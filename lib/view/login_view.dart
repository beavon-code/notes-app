// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:notesapp/constant/routes.dart';


class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),),
      body: Column(
            children: [
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                ),
              ),
              TextButton(
                child: const Text('Login'),
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try{
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email, 
                    password: password
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoutes, 
                      (route) => false,
                      );
                  } on FirebaseAuthException catch(e){
                    // ignore: avoid_print
                    if(e.code == "user-not-found"){
                      devtools.log("User Not Found");
                    }else if (e.code == "wrong-password"){
                      devtools.log("Wrong Password");
                    }
                    else{
                      devtools.log("Something else happened to this code");
                      devtools.log(e.code);
                    }
                  }
                  
                },
                // ignore: avoid_print
                
        
                ),
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      registerRoutes, 
                    (route) => false,
                    );
                
                  }, 
                  child: const Text('Register')
                  )
              ],
              ),
    );
  }
  
  
}
