import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (user != null) Text('Hello, ${user.displayName ?? user.email ?? 'User'}'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              try {
                await AuthService().signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              } catch (e) {
                // optionally handle error, e.g., show a snackbar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sign out failed: $e')),
                  );
                }
              }
            },
            child: const Text('Sign out'),
          ),
        ]),
      ),
    );
  }
}
