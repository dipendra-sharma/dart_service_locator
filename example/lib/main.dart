// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:dart_service_locator/dart_service_locator.dart';
import 'package:flutter/material.dart';

// Define our services
abstract class AuthService {
  Future<bool> login(String username, String password);
  Future<void> logout();
}

class FirebaseAuthService implements AuthService {
  @override
  Future<bool> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Implement actual Firebase login logic here
    return username == 'user' && password == 'password';
  }

  @override
  Future<void> logout() async {
    // Implement logout logic
    print('User logged out');
  }
}

class UserRepository {
  final AuthService _authService;

  UserRepository(this._authService);

  Future<bool> login(String username, String password) {
    return _authService.login(username, password);
  }

  Future<void> logout() {
    return _authService.logout();
  }
}

void setupDependencies() {
  // Register our dependencies
  register<AuthService>(() => FirebaseAuthService());
  registerAsync<UserRepository>(() async {
    final authService = await singleton<AuthService>();
    return UserRepository(authService);
  });
}

void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DI Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final userRepo = await singleton<UserRepository>();
      final success = await userRepo.login(
        _usernameController.text,
        _passwordController.text,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login failed. Please check your credentials.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
