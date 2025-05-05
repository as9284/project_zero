// history_page.dart
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<String> history;
  final VoidCallback onClear;

  const HistoryPage({super.key, required this.history, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onClear();
              Navigator.pop(context);
            },
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 16),
      ),
      body:
          history.isEmpty
              ? const Center(child: Text("No history yet."))
              : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(history[index], style: TextStyle(fontSize: 20)),
                  );
                },
              ),
    );
  }
}
