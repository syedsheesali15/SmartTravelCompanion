import 'package:flutter/material.dart';

class SimplePage extends StatelessWidget {
  const SimplePage({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
