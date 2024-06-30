import 'package:dart_service_locator/dart_service_locator.dart';
import 'package:flutter/material.dart';

class MyService {
  String fetchData() => 'Hello from MyService!';
}

void main() {
  // Register the service
  register<MyService>(() => MyService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final myService = singleton<MyService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Locator Example'),
      ),
      body: Center(
        child: Text(myService.fetchData()),
      ),
    );
  }
}
