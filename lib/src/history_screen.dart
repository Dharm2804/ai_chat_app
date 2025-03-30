import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, String>> messages;

  const HistoryScreen({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat History"),
        backgroundColor: Colors.blue,
        elevation: 0, // Remove shadow
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final message = messages[index];
            bool isUser = message["role"] == "user";

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[50] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUser ? "You" : "AI",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUser ? Colors.blue[800] : Colors.grey[800],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message["text"]!,
                    style: TextStyle(
                      color: isUser ? Colors.blue[900] : Colors.grey[900],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}