import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      body: const Center(
        child: Text('Dashboard Placeholder'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-habit'),
        icon: const Icon(Icons.add),
        label: const Text('Create Habit'),
      ),
    );
  }
}
