import 'package:flutter/material.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import '../constant/routes.dart';
import '../enum/enum.dart';

class NotesView extends StatelessWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton <MenuActions>(
            onSelected: (value) async {
              switch (value){
                case MenuActions.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if(shouldLogout){
                    await AuthService.firebase().logOut();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoutes, 
                    (route) => false,
                    );
                  }
              }
            },
            itemBuilder: (context){
              return [
                const PopupMenuItem<MenuActions>(
                  value: MenuActions.logout,
                  child: Text('Log out'),
                )
              ];
            },
          )
        ],
      ),
      body: const Text('First frontend app'),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context){
  return showDialog<bool>(
    context: context, 
    builder: (context) {
      return  AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            }, 
            child: const Text('Cancel')
            ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(true);
            }, 
            child: const Text('Log out')
            )  
        ],
      );
    },
    ).then((value) => value ?? false);
}