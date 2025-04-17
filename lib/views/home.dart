import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zero", style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(child: Text("No calculator yet :c")),
    );
  }
}
