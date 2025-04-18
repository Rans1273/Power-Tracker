import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'widgets/bottom_nav.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final dbRef = FirebaseDatabase.instance.ref('notification');

  final topIController = TextEditingController();
  final topPController = TextEditingController();
  final topVController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbRef.once().then((snapshot) {
      final data = snapshot.snapshot.value as Map;
      topIController.text = data['top_I'].toString();
      topPController.text = data['top_P'].toString();
      topVController.text = data['top_V'].toString();
    });
  }

  void save() {
    dbRef.update({
      'top_I': int.parse(topIController.text),
      'top_P': int.parse(topPController.text),
      'top_V': int.parse(topVController.text),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification thresholds updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: topIController, decoration: const InputDecoration(labelText: 'top_I')),
            TextField(controller: topPController, decoration: const InputDecoration(labelText: 'top_P')),
            TextField(controller: topVController, decoration: const InputDecoration(labelText: 'top_V')),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: save, child: const Text('Save')),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}
