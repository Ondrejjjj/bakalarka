import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavenia'),
      ),
      body: const Center(
        child: Text('Tu budú nastavenia', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
