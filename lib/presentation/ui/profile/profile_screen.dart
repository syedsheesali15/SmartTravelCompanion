import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          CircleAvatar(
            radius: 48,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=12'),
          ),
          SizedBox(height: 16),
          Text('Aarav Mehta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          Text('Smart Travel Companion • offline-first explorer'),
          SizedBox(height: 16),
          Text(
            'This profile matches the assignment mock. Wire it to your own auth service if you extend the project.',
          ),
        ],
      ),
    );
  }
}
