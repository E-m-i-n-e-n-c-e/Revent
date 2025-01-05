import 'package:flutter/material.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: const Color(0xFF06222F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildResourceCard(
            'Documents',
            Icons.description,
            () {/* Handle tap */},
          ),
          _buildResourceCard(
            'Guidelines',
            Icons.rule,
            () {/* Handle tap */},
          ),
          _buildResourceCard(
            'Help Center',
            Icons.help,
            () {/* Handle tap */},
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF06222F),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF83ACBD)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF83ACBD),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
