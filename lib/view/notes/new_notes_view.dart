import 'package:flutter/material.dart';

class NewNote extends StatefulWidget {
  const NewNote({super.key});

  @override
  State<NewNote> createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New notes'),
      ),
      body: const Text('waiting for a new note'),
    );
  }
}
