import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  bool _isLoading = false;
  bool _isSignupMode = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signup() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirm = _confirmPasswordController.text.trim();

  if (name.isEmpty) {
    setState(() {
      _errorMessage = "Please enter your name";
      _isLoading = false;
    });
    return;
  }

  if (password != confirm) {
    setState(() {
      _errorMessage = "Passwords do not match";
      _isLoading = false;
    });
    return;
  }

  try {
    // CREATE USER
    UserCredential userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // YOU MUST DEFINE THEM HERE — INSIDE THE FUNCTION
    final user = userCred.user!;
    final uid = user.uid;

    // UPDATE DISPLAY NAME
    await user.updateDisplayName(name);

    // SAVE USER TO FIRESTORE
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } on FirebaseAuthException catch (e) {
    setState(() => _errorMessage = e.message);
  } finally {
    setState(() => _isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    final double width = 600;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Expenditure Buddy',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.wallet, size: 80, color: Colors.blue),
              const SizedBox(height: 30),
              if (_isSignupMode) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: width,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Enter Name",
                      prefixIcon: const Icon(Icons.abc),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              SizedBox(
                width: width,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: width,
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

              if (_isSignupMode) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: width,
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: 400,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _isSignupMode
                          ? _signup
                          : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isSignupMode ? "sign up" : "login",
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _isSignupMode = !_isSignupMode),
                child: Text(
                  _isSignupMode
                      ? "Already have an account? Login"
                      : "Don't have an account? Create one",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
